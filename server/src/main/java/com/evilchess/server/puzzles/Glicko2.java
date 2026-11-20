package com.evilchess.server.puzzles;

import java.util.List;

/**
 * Glicko-2 rating system (Mark Glickman, "Example of the Glicko-2 system",
 * 2013). Ratings are on the familiar Glicko scale (1500 / 350); the maths
 * runs on the internal Glicko-2 scale.
 */
public final class Glicko2 {

    /** A player's rating, deviation and volatility. */
    public record Rating(double rating, double rd, double volatility) {}

    /** One game in the rating period: opponent and score (1 win, 0.5 draw, 0 loss). */
    public record Result(double opponentRating, double opponentRd, double score) {}

    private static final double SCALE = 173.7178;
    private static final double EPSILON = 0.000001;

    private final double tau;
    private final double minRd;
    private final double maxRd;

    /**
     * @param tau constrains volatility change (0.3–1.2; smaller = steadier)
     * @param minRd lower bound for RD so ratings keep moving
     * @param maxRd upper bound for RD
     */
    public Glicko2(double tau, double minRd, double maxRd) {
        this.tau = tau;
        this.minRd = minRd;
        this.maxRd = maxRd;
    }

    public Rating update(Rating player, List<Result> results) {
        double mu = (player.rating() - 1500) / SCALE;
        double phi = player.rd() / SCALE;
        double sigma = player.volatility();

        if (results.isEmpty()) {
            double phiStar = Math.sqrt(phi * phi + sigma * sigma);
            return new Rating(player.rating(), clamp(phiStar * SCALE), sigma);
        }

        double vInv = 0;
        double deltaSum = 0;
        for (Result r : results) {
            double muJ = (r.opponentRating() - 1500) / SCALE;
            double phiJ = r.opponentRd() / SCALE;
            double g = g(phiJ);
            double e = 1 / (1 + Math.exp(-g * (mu - muJ)));
            vInv += g * g * e * (1 - e);
            deltaSum += g * (r.score() - e);
        }
        double v = 1 / vInv;
        double delta = v * deltaSum;

        double sigmaNew = newVolatility(phi, sigma, v, delta);
        double phiStar = Math.sqrt(phi * phi + sigmaNew * sigmaNew);
        double phiNew = 1 / Math.sqrt(1 / (phiStar * phiStar) + 1 / v);
        double muNew = mu + phiNew * phiNew * deltaSum;

        return new Rating(muNew * SCALE + 1500, clamp(phiNew * SCALE), sigmaNew);
    }

    private static double g(double phi) {
        return 1 / Math.sqrt(1 + 3 * phi * phi / (Math.PI * Math.PI));
    }

    /** Step 5 of the paper: Illinois algorithm for the new volatility. */
    private double newVolatility(double phi, double sigma, double v, double delta) {
        double a = Math.log(sigma * sigma);
        double tau2 = tau * tau;
        java.util.function.DoubleUnaryOperator f = x -> {
            double ex = Math.exp(x);
            double d = phi * phi + v + ex;
            return ex * (delta * delta - phi * phi - v - ex) / (2 * d * d) - (x - a) / tau2;
        };
        double big = a;
        double small;
        if (delta * delta > phi * phi + v) {
            small = Math.log(delta * delta - phi * phi - v);
        } else {
            int k = 1;
            while (f.applyAsDouble(a - k * tau) < 0) k++;
            small = a - k * tau;
        }
        double fA = f.applyAsDouble(big);
        double fB = f.applyAsDouble(small);
        double A = big;
        double B = small;
        while (Math.abs(B - A) > EPSILON) {
            double C = A + (A - B) * fA / (fB - fA);
            double fC = f.applyAsDouble(C);
            if (fC * fB <= 0) {
                A = B;
                fA = fB;
            } else {
                fA = fA / 2;
            }
            B = C;
            fB = fC;
        }
        return Math.exp(A / 2);
    }

    private double clamp(double rd) {
        return Math.max(minRd, Math.min(maxRd, rd));
    }
}

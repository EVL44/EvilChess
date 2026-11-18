package com.evilchess.server.puzzles;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;

import java.util.List;
import org.junit.jupiter.api.Test;

class Glicko2Test {

    /** Worked example from Glickman's paper (tau = 0.5). */
    @Test
    void matchesThePaperExample() {
        Glicko2 glicko = new Glicko2(0.5, 0, 10_000);
        Glicko2.Rating after = glicko.update(
                new Glicko2.Rating(1500, 200, 0.06),
                List.of(
                        new Glicko2.Result(1400, 30, 1),
                        new Glicko2.Result(1550, 100, 0),
                        new Glicko2.Result(1700, 300, 0)));
        assertThat(after.rating()).isCloseTo(1464.06, within(0.01));
        assertThat(after.rd()).isCloseTo(151.52, within(0.01));
        assertThat(after.volatility()).isCloseTo(0.05999, within(0.00001));
    }

    @Test
    void winningAgainstAStrongerPuzzleGainsMore() {
        Glicko2 glicko = new Glicko2(0.75, 45, 350);
        Glicko2.Rating me = new Glicko2.Rating(1500, 80, 0.06);
        double easy = glicko.update(me, List.of(new Glicko2.Result(1300, 75, 1))).rating() - 1500;
        double hard = glicko.update(me, List.of(new Glicko2.Result(1800, 75, 1))).rating() - 1500;
        double lossHard = glicko.update(me, List.of(new Glicko2.Result(1800, 75, 0))).rating() - 1500;
        assertThat(hard).isGreaterThan(easy).isPositive();
        assertThat(lossHard).isNegative();
        assertThat(Math.abs(lossHard)).isLessThan(hard);
    }

    @Test
    void newPlayersMoveFastAndSettle() {
        Glicko2 glicko = new Glicko2(0.75, 45, 350);
        Glicko2.Rating fresh = new Glicko2.Rating(1500, 350, 0.06);
        Glicko2.Rating after = glicko.update(fresh, List.of(new Glicko2.Result(1500, 75, 1)));
        assertThat(after.rating() - 1500).isGreaterThan(100);
        assertThat(after.rd()).isLessThan(350);
    }

    @Test
    void rdStaysWithinBounds() {
        Glicko2 glicko = new Glicko2(0.75, 45, 350);
        Glicko2.Rating r = new Glicko2.Rating(1500, 50, 0.06);
        for (int i = 0; i < 200; i++) {
            r = glicko.update(r, List.of(new Glicko2.Result(1500, 50, i % 2)));
        }
        assertThat(r.rd()).isGreaterThanOrEqualTo(45);
        assertThat(glicko.update(new Glicko2.Rating(1500, 349, 0.5), List.of()).rd())
                .isLessThanOrEqualTo(350);
    }
}

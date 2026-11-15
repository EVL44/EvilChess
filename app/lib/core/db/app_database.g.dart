// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, GameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whiteMeta = const VerificationMeta('white');
  @override
  late final GeneratedColumn<String> white = GeneratedColumn<String>(
    'white',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blackMeta = const VerificationMeta('black');
  @override
  late final GeneratedColumn<String> black = GeneratedColumn<String>(
    'black',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whiteEloMeta = const VerificationMeta(
    'whiteElo',
  );
  @override
  late final GeneratedColumn<int> whiteElo = GeneratedColumn<int>(
    'white_elo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blackEloMeta = const VerificationMeta(
    'blackElo',
  );
  @override
  late final GeneratedColumn<int> blackElo = GeneratedColumn<int>(
    'black_elo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeControlMeta = const VerificationMeta(
    'timeControl',
  );
  @override
  late final GeneratedColumn<String> timeControl = GeneratedColumn<String>(
    'time_control',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<String> speed = GeneratedColumn<String>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ecoMeta = const VerificationMeta('eco');
  @override
  late final GeneratedColumn<String> eco = GeneratedColumn<String>(
    'eco',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingMeta = const VerificationMeta(
    'opening',
  );
  @override
  late final GeneratedColumn<String> opening = GeneratedColumn<String>(
    'opening',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventMeta = const VerificationMeta('event');
  @override
  late final GeneratedColumn<String> event = GeneratedColumn<String>(
    'event',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialFenMeta = const VerificationMeta(
    'initialFen',
  );
  @override
  late final GeneratedColumn<String> initialFen = GeneratedColumn<String>(
    'initial_fen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pliesJsonMeta = const VerificationMeta(
    'pliesJson',
  );
  @override
  late final GeneratedColumn<String> pliesJson = GeneratedColumn<String>(
    'plies_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pgnMeta = const VerificationMeta('pgn');
  @override
  late final GeneratedColumn<String> pgn = GeneratedColumn<String>(
    'pgn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userSideMeta = const VerificationMeta(
    'userSide',
  );
  @override
  late final GeneratedColumn<String> userSide = GeneratedColumn<String>(
    'user_side',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analyzedAtMeta = const VerificationMeta(
    'analyzedAt',
  );
  @override
  late final GeneratedColumn<DateTime> analyzedAt = GeneratedColumn<DateTime>(
    'analyzed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _analysisDepthMeta = const VerificationMeta(
    'analysisDepth',
  );
  @override
  late final GeneratedColumn<int> analysisDepth = GeneratedColumn<int>(
    'analysis_depth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whiteAccuracyMeta = const VerificationMeta(
    'whiteAccuracy',
  );
  @override
  late final GeneratedColumn<double> whiteAccuracy = GeneratedColumn<double>(
    'white_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blackAccuracyMeta = const VerificationMeta(
    'blackAccuracy',
  );
  @override
  late final GeneratedColumn<double> blackAccuracy = GeneratedColumn<double>(
    'black_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    externalId,
    url,
    white,
    black,
    whiteElo,
    blackElo,
    result,
    playedAt,
    timeControl,
    speed,
    eco,
    opening,
    event,
    initialFen,
    pliesJson,
    pgn,
    userSide,
    importedAt,
    analyzedAt,
    analysisDepth,
    whiteAccuracy,
    blackAccuracy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('white')) {
      context.handle(
        _whiteMeta,
        white.isAcceptableOrUnknown(data['white']!, _whiteMeta),
      );
    } else if (isInserting) {
      context.missing(_whiteMeta);
    }
    if (data.containsKey('black')) {
      context.handle(
        _blackMeta,
        black.isAcceptableOrUnknown(data['black']!, _blackMeta),
      );
    } else if (isInserting) {
      context.missing(_blackMeta);
    }
    if (data.containsKey('white_elo')) {
      context.handle(
        _whiteEloMeta,
        whiteElo.isAcceptableOrUnknown(data['white_elo']!, _whiteEloMeta),
      );
    }
    if (data.containsKey('black_elo')) {
      context.handle(
        _blackEloMeta,
        blackElo.isAcceptableOrUnknown(data['black_elo']!, _blackEloMeta),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    if (data.containsKey('time_control')) {
      context.handle(
        _timeControlMeta,
        timeControl.isAcceptableOrUnknown(
          data['time_control']!,
          _timeControlMeta,
        ),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('eco')) {
      context.handle(
        _ecoMeta,
        eco.isAcceptableOrUnknown(data['eco']!, _ecoMeta),
      );
    }
    if (data.containsKey('opening')) {
      context.handle(
        _openingMeta,
        opening.isAcceptableOrUnknown(data['opening']!, _openingMeta),
      );
    }
    if (data.containsKey('event')) {
      context.handle(
        _eventMeta,
        event.isAcceptableOrUnknown(data['event']!, _eventMeta),
      );
    }
    if (data.containsKey('initial_fen')) {
      context.handle(
        _initialFenMeta,
        initialFen.isAcceptableOrUnknown(data['initial_fen']!, _initialFenMeta),
      );
    } else if (isInserting) {
      context.missing(_initialFenMeta);
    }
    if (data.containsKey('plies_json')) {
      context.handle(
        _pliesJsonMeta,
        pliesJson.isAcceptableOrUnknown(data['plies_json']!, _pliesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_pliesJsonMeta);
    }
    if (data.containsKey('pgn')) {
      context.handle(
        _pgnMeta,
        pgn.isAcceptableOrUnknown(data['pgn']!, _pgnMeta),
      );
    } else if (isInserting) {
      context.missing(_pgnMeta);
    }
    if (data.containsKey('user_side')) {
      context.handle(
        _userSideMeta,
        userSide.isAcceptableOrUnknown(data['user_side']!, _userSideMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
        _analyzedAtMeta,
        analyzedAt.isAcceptableOrUnknown(data['analyzed_at']!, _analyzedAtMeta),
      );
    }
    if (data.containsKey('analysis_depth')) {
      context.handle(
        _analysisDepthMeta,
        analysisDepth.isAcceptableOrUnknown(
          data['analysis_depth']!,
          _analysisDepthMeta,
        ),
      );
    }
    if (data.containsKey('white_accuracy')) {
      context.handle(
        _whiteAccuracyMeta,
        whiteAccuracy.isAcceptableOrUnknown(
          data['white_accuracy']!,
          _whiteAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('black_accuracy')) {
      context.handle(
        _blackAccuracyMeta,
        blackAccuracy.isAcceptableOrUnknown(
          data['black_accuracy']!,
          _blackAccuracyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      white: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}white'],
      )!,
      black: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}black'],
      )!,
      whiteElo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}white_elo'],
      ),
      blackElo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}black_elo'],
      ),
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      ),
      timeControl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_control'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speed'],
      )!,
      eco: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eco'],
      ),
      opening: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening'],
      ),
      event: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event'],
      ),
      initialFen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initial_fen'],
      )!,
      pliesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plies_json'],
      )!,
      pgn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pgn'],
      )!,
      userSide: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_side'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      analyzedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}analyzed_at'],
      ),
      analysisDepth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}analysis_depth'],
      ),
      whiteAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}white_accuracy'],
      ),
      blackAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}black_accuracy'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class GameRow extends DataClass implements Insertable<GameRow> {
  final String id;
  final String source;
  final String? externalId;
  final String? url;
  final String white;
  final String black;
  final int? whiteElo;
  final int? blackElo;
  final String result;
  final DateTime? playedAt;
  final String? timeControl;
  final String speed;
  final String? eco;
  final String? opening;
  final String? event;
  final String initialFen;

  /// JSON list of plies (san, uci, fens, clock).
  final String pliesJson;
  final String pgn;

  /// Which colour the linked account played ('white' / 'black'), if known.
  final String? userSide;
  final DateTime importedAt;
  final DateTime? analyzedAt;
  final int? analysisDepth;
  final double? whiteAccuracy;
  final double? blackAccuracy;
  const GameRow({
    required this.id,
    required this.source,
    this.externalId,
    this.url,
    required this.white,
    required this.black,
    this.whiteElo,
    this.blackElo,
    required this.result,
    this.playedAt,
    this.timeControl,
    required this.speed,
    this.eco,
    this.opening,
    this.event,
    required this.initialFen,
    required this.pliesJson,
    required this.pgn,
    this.userSide,
    required this.importedAt,
    this.analyzedAt,
    this.analysisDepth,
    this.whiteAccuracy,
    this.blackAccuracy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['white'] = Variable<String>(white);
    map['black'] = Variable<String>(black);
    if (!nullToAbsent || whiteElo != null) {
      map['white_elo'] = Variable<int>(whiteElo);
    }
    if (!nullToAbsent || blackElo != null) {
      map['black_elo'] = Variable<int>(blackElo);
    }
    map['result'] = Variable<String>(result);
    if (!nullToAbsent || playedAt != null) {
      map['played_at'] = Variable<DateTime>(playedAt);
    }
    if (!nullToAbsent || timeControl != null) {
      map['time_control'] = Variable<String>(timeControl);
    }
    map['speed'] = Variable<String>(speed);
    if (!nullToAbsent || eco != null) {
      map['eco'] = Variable<String>(eco);
    }
    if (!nullToAbsent || opening != null) {
      map['opening'] = Variable<String>(opening);
    }
    if (!nullToAbsent || event != null) {
      map['event'] = Variable<String>(event);
    }
    map['initial_fen'] = Variable<String>(initialFen);
    map['plies_json'] = Variable<String>(pliesJson);
    map['pgn'] = Variable<String>(pgn);
    if (!nullToAbsent || userSide != null) {
      map['user_side'] = Variable<String>(userSide);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || analyzedAt != null) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt);
    }
    if (!nullToAbsent || analysisDepth != null) {
      map['analysis_depth'] = Variable<int>(analysisDepth);
    }
    if (!nullToAbsent || whiteAccuracy != null) {
      map['white_accuracy'] = Variable<double>(whiteAccuracy);
    }
    if (!nullToAbsent || blackAccuracy != null) {
      map['black_accuracy'] = Variable<double>(blackAccuracy);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      source: Value(source),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      white: Value(white),
      black: Value(black),
      whiteElo: whiteElo == null && nullToAbsent
          ? const Value.absent()
          : Value(whiteElo),
      blackElo: blackElo == null && nullToAbsent
          ? const Value.absent()
          : Value(blackElo),
      result: Value(result),
      playedAt: playedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(playedAt),
      timeControl: timeControl == null && nullToAbsent
          ? const Value.absent()
          : Value(timeControl),
      speed: Value(speed),
      eco: eco == null && nullToAbsent ? const Value.absent() : Value(eco),
      opening: opening == null && nullToAbsent
          ? const Value.absent()
          : Value(opening),
      event: event == null && nullToAbsent
          ? const Value.absent()
          : Value(event),
      initialFen: Value(initialFen),
      pliesJson: Value(pliesJson),
      pgn: Value(pgn),
      userSide: userSide == null && nullToAbsent
          ? const Value.absent()
          : Value(userSide),
      importedAt: Value(importedAt),
      analyzedAt: analyzedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(analyzedAt),
      analysisDepth: analysisDepth == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisDepth),
      whiteAccuracy: whiteAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(whiteAccuracy),
      blackAccuracy: blackAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(blackAccuracy),
    );
  }

  factory GameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameRow(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      url: serializer.fromJson<String?>(json['url']),
      white: serializer.fromJson<String>(json['white']),
      black: serializer.fromJson<String>(json['black']),
      whiteElo: serializer.fromJson<int?>(json['whiteElo']),
      blackElo: serializer.fromJson<int?>(json['blackElo']),
      result: serializer.fromJson<String>(json['result']),
      playedAt: serializer.fromJson<DateTime?>(json['playedAt']),
      timeControl: serializer.fromJson<String?>(json['timeControl']),
      speed: serializer.fromJson<String>(json['speed']),
      eco: serializer.fromJson<String?>(json['eco']),
      opening: serializer.fromJson<String?>(json['opening']),
      event: serializer.fromJson<String?>(json['event']),
      initialFen: serializer.fromJson<String>(json['initialFen']),
      pliesJson: serializer.fromJson<String>(json['pliesJson']),
      pgn: serializer.fromJson<String>(json['pgn']),
      userSide: serializer.fromJson<String?>(json['userSide']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      analyzedAt: serializer.fromJson<DateTime?>(json['analyzedAt']),
      analysisDepth: serializer.fromJson<int?>(json['analysisDepth']),
      whiteAccuracy: serializer.fromJson<double?>(json['whiteAccuracy']),
      blackAccuracy: serializer.fromJson<double?>(json['blackAccuracy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'externalId': serializer.toJson<String?>(externalId),
      'url': serializer.toJson<String?>(url),
      'white': serializer.toJson<String>(white),
      'black': serializer.toJson<String>(black),
      'whiteElo': serializer.toJson<int?>(whiteElo),
      'blackElo': serializer.toJson<int?>(blackElo),
      'result': serializer.toJson<String>(result),
      'playedAt': serializer.toJson<DateTime?>(playedAt),
      'timeControl': serializer.toJson<String?>(timeControl),
      'speed': serializer.toJson<String>(speed),
      'eco': serializer.toJson<String?>(eco),
      'opening': serializer.toJson<String?>(opening),
      'event': serializer.toJson<String?>(event),
      'initialFen': serializer.toJson<String>(initialFen),
      'pliesJson': serializer.toJson<String>(pliesJson),
      'pgn': serializer.toJson<String>(pgn),
      'userSide': serializer.toJson<String?>(userSide),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'analyzedAt': serializer.toJson<DateTime?>(analyzedAt),
      'analysisDepth': serializer.toJson<int?>(analysisDepth),
      'whiteAccuracy': serializer.toJson<double?>(whiteAccuracy),
      'blackAccuracy': serializer.toJson<double?>(blackAccuracy),
    };
  }

  GameRow copyWith({
    String? id,
    String? source,
    Value<String?> externalId = const Value.absent(),
    Value<String?> url = const Value.absent(),
    String? white,
    String? black,
    Value<int?> whiteElo = const Value.absent(),
    Value<int?> blackElo = const Value.absent(),
    String? result,
    Value<DateTime?> playedAt = const Value.absent(),
    Value<String?> timeControl = const Value.absent(),
    String? speed,
    Value<String?> eco = const Value.absent(),
    Value<String?> opening = const Value.absent(),
    Value<String?> event = const Value.absent(),
    String? initialFen,
    String? pliesJson,
    String? pgn,
    Value<String?> userSide = const Value.absent(),
    DateTime? importedAt,
    Value<DateTime?> analyzedAt = const Value.absent(),
    Value<int?> analysisDepth = const Value.absent(),
    Value<double?> whiteAccuracy = const Value.absent(),
    Value<double?> blackAccuracy = const Value.absent(),
  }) => GameRow(
    id: id ?? this.id,
    source: source ?? this.source,
    externalId: externalId.present ? externalId.value : this.externalId,
    url: url.present ? url.value : this.url,
    white: white ?? this.white,
    black: black ?? this.black,
    whiteElo: whiteElo.present ? whiteElo.value : this.whiteElo,
    blackElo: blackElo.present ? blackElo.value : this.blackElo,
    result: result ?? this.result,
    playedAt: playedAt.present ? playedAt.value : this.playedAt,
    timeControl: timeControl.present ? timeControl.value : this.timeControl,
    speed: speed ?? this.speed,
    eco: eco.present ? eco.value : this.eco,
    opening: opening.present ? opening.value : this.opening,
    event: event.present ? event.value : this.event,
    initialFen: initialFen ?? this.initialFen,
    pliesJson: pliesJson ?? this.pliesJson,
    pgn: pgn ?? this.pgn,
    userSide: userSide.present ? userSide.value : this.userSide,
    importedAt: importedAt ?? this.importedAt,
    analyzedAt: analyzedAt.present ? analyzedAt.value : this.analyzedAt,
    analysisDepth: analysisDepth.present
        ? analysisDepth.value
        : this.analysisDepth,
    whiteAccuracy: whiteAccuracy.present
        ? whiteAccuracy.value
        : this.whiteAccuracy,
    blackAccuracy: blackAccuracy.present
        ? blackAccuracy.value
        : this.blackAccuracy,
  );
  GameRow copyWithCompanion(GamesCompanion data) {
    return GameRow(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      url: data.url.present ? data.url.value : this.url,
      white: data.white.present ? data.white.value : this.white,
      black: data.black.present ? data.black.value : this.black,
      whiteElo: data.whiteElo.present ? data.whiteElo.value : this.whiteElo,
      blackElo: data.blackElo.present ? data.blackElo.value : this.blackElo,
      result: data.result.present ? data.result.value : this.result,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      timeControl: data.timeControl.present
          ? data.timeControl.value
          : this.timeControl,
      speed: data.speed.present ? data.speed.value : this.speed,
      eco: data.eco.present ? data.eco.value : this.eco,
      opening: data.opening.present ? data.opening.value : this.opening,
      event: data.event.present ? data.event.value : this.event,
      initialFen: data.initialFen.present
          ? data.initialFen.value
          : this.initialFen,
      pliesJson: data.pliesJson.present ? data.pliesJson.value : this.pliesJson,
      pgn: data.pgn.present ? data.pgn.value : this.pgn,
      userSide: data.userSide.present ? data.userSide.value : this.userSide,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      analyzedAt: data.analyzedAt.present
          ? data.analyzedAt.value
          : this.analyzedAt,
      analysisDepth: data.analysisDepth.present
          ? data.analysisDepth.value
          : this.analysisDepth,
      whiteAccuracy: data.whiteAccuracy.present
          ? data.whiteAccuracy.value
          : this.whiteAccuracy,
      blackAccuracy: data.blackAccuracy.present
          ? data.blackAccuracy.value
          : this.blackAccuracy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameRow(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('externalId: $externalId, ')
          ..write('url: $url, ')
          ..write('white: $white, ')
          ..write('black: $black, ')
          ..write('whiteElo: $whiteElo, ')
          ..write('blackElo: $blackElo, ')
          ..write('result: $result, ')
          ..write('playedAt: $playedAt, ')
          ..write('timeControl: $timeControl, ')
          ..write('speed: $speed, ')
          ..write('eco: $eco, ')
          ..write('opening: $opening, ')
          ..write('event: $event, ')
          ..write('initialFen: $initialFen, ')
          ..write('pliesJson: $pliesJson, ')
          ..write('pgn: $pgn, ')
          ..write('userSide: $userSide, ')
          ..write('importedAt: $importedAt, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('analysisDepth: $analysisDepth, ')
          ..write('whiteAccuracy: $whiteAccuracy, ')
          ..write('blackAccuracy: $blackAccuracy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    source,
    externalId,
    url,
    white,
    black,
    whiteElo,
    blackElo,
    result,
    playedAt,
    timeControl,
    speed,
    eco,
    opening,
    event,
    initialFen,
    pliesJson,
    pgn,
    userSide,
    importedAt,
    analyzedAt,
    analysisDepth,
    whiteAccuracy,
    blackAccuracy,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameRow &&
          other.id == this.id &&
          other.source == this.source &&
          other.externalId == this.externalId &&
          other.url == this.url &&
          other.white == this.white &&
          other.black == this.black &&
          other.whiteElo == this.whiteElo &&
          other.blackElo == this.blackElo &&
          other.result == this.result &&
          other.playedAt == this.playedAt &&
          other.timeControl == this.timeControl &&
          other.speed == this.speed &&
          other.eco == this.eco &&
          other.opening == this.opening &&
          other.event == this.event &&
          other.initialFen == this.initialFen &&
          other.pliesJson == this.pliesJson &&
          other.pgn == this.pgn &&
          other.userSide == this.userSide &&
          other.importedAt == this.importedAt &&
          other.analyzedAt == this.analyzedAt &&
          other.analysisDepth == this.analysisDepth &&
          other.whiteAccuracy == this.whiteAccuracy &&
          other.blackAccuracy == this.blackAccuracy);
}

class GamesCompanion extends UpdateCompanion<GameRow> {
  final Value<String> id;
  final Value<String> source;
  final Value<String?> externalId;
  final Value<String?> url;
  final Value<String> white;
  final Value<String> black;
  final Value<int?> whiteElo;
  final Value<int?> blackElo;
  final Value<String> result;
  final Value<DateTime?> playedAt;
  final Value<String?> timeControl;
  final Value<String> speed;
  final Value<String?> eco;
  final Value<String?> opening;
  final Value<String?> event;
  final Value<String> initialFen;
  final Value<String> pliesJson;
  final Value<String> pgn;
  final Value<String?> userSide;
  final Value<DateTime> importedAt;
  final Value<DateTime?> analyzedAt;
  final Value<int?> analysisDepth;
  final Value<double?> whiteAccuracy;
  final Value<double?> blackAccuracy;
  final Value<int> rowid;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.externalId = const Value.absent(),
    this.url = const Value.absent(),
    this.white = const Value.absent(),
    this.black = const Value.absent(),
    this.whiteElo = const Value.absent(),
    this.blackElo = const Value.absent(),
    this.result = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.timeControl = const Value.absent(),
    this.speed = const Value.absent(),
    this.eco = const Value.absent(),
    this.opening = const Value.absent(),
    this.event = const Value.absent(),
    this.initialFen = const Value.absent(),
    this.pliesJson = const Value.absent(),
    this.pgn = const Value.absent(),
    this.userSide = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.analysisDepth = const Value.absent(),
    this.whiteAccuracy = const Value.absent(),
    this.blackAccuracy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    required String id,
    required String source,
    this.externalId = const Value.absent(),
    this.url = const Value.absent(),
    required String white,
    required String black,
    this.whiteElo = const Value.absent(),
    this.blackElo = const Value.absent(),
    required String result,
    this.playedAt = const Value.absent(),
    this.timeControl = const Value.absent(),
    required String speed,
    this.eco = const Value.absent(),
    this.opening = const Value.absent(),
    this.event = const Value.absent(),
    required String initialFen,
    required String pliesJson,
    required String pgn,
    this.userSide = const Value.absent(),
    required DateTime importedAt,
    this.analyzedAt = const Value.absent(),
    this.analysisDepth = const Value.absent(),
    this.whiteAccuracy = const Value.absent(),
    this.blackAccuracy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       source = Value(source),
       white = Value(white),
       black = Value(black),
       result = Value(result),
       speed = Value(speed),
       initialFen = Value(initialFen),
       pliesJson = Value(pliesJson),
       pgn = Value(pgn),
       importedAt = Value(importedAt);
  static Insertable<GameRow> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<String>? externalId,
    Expression<String>? url,
    Expression<String>? white,
    Expression<String>? black,
    Expression<int>? whiteElo,
    Expression<int>? blackElo,
    Expression<String>? result,
    Expression<DateTime>? playedAt,
    Expression<String>? timeControl,
    Expression<String>? speed,
    Expression<String>? eco,
    Expression<String>? opening,
    Expression<String>? event,
    Expression<String>? initialFen,
    Expression<String>? pliesJson,
    Expression<String>? pgn,
    Expression<String>? userSide,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? analyzedAt,
    Expression<int>? analysisDepth,
    Expression<double>? whiteAccuracy,
    Expression<double>? blackAccuracy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (externalId != null) 'external_id': externalId,
      if (url != null) 'url': url,
      if (white != null) 'white': white,
      if (black != null) 'black': black,
      if (whiteElo != null) 'white_elo': whiteElo,
      if (blackElo != null) 'black_elo': blackElo,
      if (result != null) 'result': result,
      if (playedAt != null) 'played_at': playedAt,
      if (timeControl != null) 'time_control': timeControl,
      if (speed != null) 'speed': speed,
      if (eco != null) 'eco': eco,
      if (opening != null) 'opening': opening,
      if (event != null) 'event': event,
      if (initialFen != null) 'initial_fen': initialFen,
      if (pliesJson != null) 'plies_json': pliesJson,
      if (pgn != null) 'pgn': pgn,
      if (userSide != null) 'user_side': userSide,
      if (importedAt != null) 'imported_at': importedAt,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
      if (analysisDepth != null) 'analysis_depth': analysisDepth,
      if (whiteAccuracy != null) 'white_accuracy': whiteAccuracy,
      if (blackAccuracy != null) 'black_accuracy': blackAccuracy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith({
    Value<String>? id,
    Value<String>? source,
    Value<String?>? externalId,
    Value<String?>? url,
    Value<String>? white,
    Value<String>? black,
    Value<int?>? whiteElo,
    Value<int?>? blackElo,
    Value<String>? result,
    Value<DateTime?>? playedAt,
    Value<String?>? timeControl,
    Value<String>? speed,
    Value<String?>? eco,
    Value<String?>? opening,
    Value<String?>? event,
    Value<String>? initialFen,
    Value<String>? pliesJson,
    Value<String>? pgn,
    Value<String?>? userSide,
    Value<DateTime>? importedAt,
    Value<DateTime?>? analyzedAt,
    Value<int?>? analysisDepth,
    Value<double?>? whiteAccuracy,
    Value<double?>? blackAccuracy,
    Value<int>? rowid,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      url: url ?? this.url,
      white: white ?? this.white,
      black: black ?? this.black,
      whiteElo: whiteElo ?? this.whiteElo,
      blackElo: blackElo ?? this.blackElo,
      result: result ?? this.result,
      playedAt: playedAt ?? this.playedAt,
      timeControl: timeControl ?? this.timeControl,
      speed: speed ?? this.speed,
      eco: eco ?? this.eco,
      opening: opening ?? this.opening,
      event: event ?? this.event,
      initialFen: initialFen ?? this.initialFen,
      pliesJson: pliesJson ?? this.pliesJson,
      pgn: pgn ?? this.pgn,
      userSide: userSide ?? this.userSide,
      importedAt: importedAt ?? this.importedAt,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      analysisDepth: analysisDepth ?? this.analysisDepth,
      whiteAccuracy: whiteAccuracy ?? this.whiteAccuracy,
      blackAccuracy: blackAccuracy ?? this.blackAccuracy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (white.present) {
      map['white'] = Variable<String>(white.value);
    }
    if (black.present) {
      map['black'] = Variable<String>(black.value);
    }
    if (whiteElo.present) {
      map['white_elo'] = Variable<int>(whiteElo.value);
    }
    if (blackElo.present) {
      map['black_elo'] = Variable<int>(blackElo.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (timeControl.present) {
      map['time_control'] = Variable<String>(timeControl.value);
    }
    if (speed.present) {
      map['speed'] = Variable<String>(speed.value);
    }
    if (eco.present) {
      map['eco'] = Variable<String>(eco.value);
    }
    if (opening.present) {
      map['opening'] = Variable<String>(opening.value);
    }
    if (event.present) {
      map['event'] = Variable<String>(event.value);
    }
    if (initialFen.present) {
      map['initial_fen'] = Variable<String>(initialFen.value);
    }
    if (pliesJson.present) {
      map['plies_json'] = Variable<String>(pliesJson.value);
    }
    if (pgn.present) {
      map['pgn'] = Variable<String>(pgn.value);
    }
    if (userSide.present) {
      map['user_side'] = Variable<String>(userSide.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt.value);
    }
    if (analysisDepth.present) {
      map['analysis_depth'] = Variable<int>(analysisDepth.value);
    }
    if (whiteAccuracy.present) {
      map['white_accuracy'] = Variable<double>(whiteAccuracy.value);
    }
    if (blackAccuracy.present) {
      map['black_accuracy'] = Variable<double>(blackAccuracy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('externalId: $externalId, ')
          ..write('url: $url, ')
          ..write('white: $white, ')
          ..write('black: $black, ')
          ..write('whiteElo: $whiteElo, ')
          ..write('blackElo: $blackElo, ')
          ..write('result: $result, ')
          ..write('playedAt: $playedAt, ')
          ..write('timeControl: $timeControl, ')
          ..write('speed: $speed, ')
          ..write('eco: $eco, ')
          ..write('opening: $opening, ')
          ..write('event: $event, ')
          ..write('initialFen: $initialFen, ')
          ..write('pliesJson: $pliesJson, ')
          ..write('pgn: $pgn, ')
          ..write('userSide: $userSide, ')
          ..write('importedAt: $importedAt, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('analysisDepth: $analysisDepth, ')
          ..write('whiteAccuracy: $whiteAccuracy, ')
          ..write('blackAccuracy: $blackAccuracy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoveAnalysesTable extends MoveAnalyses
    with TableInfo<$MoveAnalysesTable, MoveAnalysisRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoveAnalysesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _plyMeta = const VerificationMeta('ply');
  @override
  late final GeneratedColumn<int> ply = GeneratedColumn<int>(
    'ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whiteMovedMeta = const VerificationMeta(
    'whiteMoved',
  );
  @override
  late final GeneratedColumn<bool> whiteMoved = GeneratedColumn<bool>(
    'white_moved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("white_moved" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sanMeta = const VerificationMeta('san');
  @override
  late final GeneratedColumn<String> san = GeneratedColumn<String>(
    'san',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uciMeta = const VerificationMeta('uci');
  @override
  late final GeneratedColumn<String> uci = GeneratedColumn<String>(
    'uci',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  @override
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winBeforeMeta = const VerificationMeta(
    'winBefore',
  );
  @override
  late final GeneratedColumn<double> winBefore = GeneratedColumn<double>(
    'win_before',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winAfterMeta = const VerificationMeta(
    'winAfter',
  );
  @override
  late final GeneratedColumn<double> winAfter = GeneratedColumn<double>(
    'win_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evalBeforeMeta = const VerificationMeta(
    'evalBefore',
  );
  @override
  late final GeneratedColumn<String> evalBefore = GeneratedColumn<String>(
    'eval_before',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evalAfterMeta = const VerificationMeta(
    'evalAfter',
  );
  @override
  late final GeneratedColumn<String> evalAfter = GeneratedColumn<String>(
    'eval_after',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestUciMeta = const VerificationMeta(
    'bestUci',
  );
  @override
  late final GeneratedColumn<String> bestUci = GeneratedColumn<String>(
    'best_uci',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestSanMeta = const VerificationMeta(
    'bestSan',
  );
  @override
  late final GeneratedColumn<String> bestSan = GeneratedColumn<String>(
    'best_san',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestLineMeta = const VerificationMeta(
    'bestLine',
  );
  @override
  late final GeneratedColumn<String> bestLine = GeneratedColumn<String>(
    'best_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pieceMeta = const VerificationMeta('piece');
  @override
  late final GeneratedColumn<String> piece = GeneratedColumn<String>(
    'piece',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clockMsMeta = const VerificationMeta(
    'clockMs',
  );
  @override
  late final GeneratedColumn<int> clockMs = GeneratedColumn<int>(
    'clock_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    ply,
    whiteMoved,
    san,
    uci,
    classification,
    accuracy,
    winBefore,
    winAfter,
    evalBefore,
    evalAfter,
    bestUci,
    bestSan,
    bestLine,
    phase,
    piece,
    clockMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'move_analyses';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoveAnalysisRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('ply')) {
      context.handle(
        _plyMeta,
        ply.isAcceptableOrUnknown(data['ply']!, _plyMeta),
      );
    } else if (isInserting) {
      context.missing(_plyMeta);
    }
    if (data.containsKey('white_moved')) {
      context.handle(
        _whiteMovedMeta,
        whiteMoved.isAcceptableOrUnknown(data['white_moved']!, _whiteMovedMeta),
      );
    } else if (isInserting) {
      context.missing(_whiteMovedMeta);
    }
    if (data.containsKey('san')) {
      context.handle(
        _sanMeta,
        san.isAcceptableOrUnknown(data['san']!, _sanMeta),
      );
    } else if (isInserting) {
      context.missing(_sanMeta);
    }
    if (data.containsKey('uci')) {
      context.handle(
        _uciMeta,
        uci.isAcceptableOrUnknown(data['uci']!, _uciMeta),
      );
    } else if (isInserting) {
      context.missing(_uciMeta);
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_classificationMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('win_before')) {
      context.handle(
        _winBeforeMeta,
        winBefore.isAcceptableOrUnknown(data['win_before']!, _winBeforeMeta),
      );
    } else if (isInserting) {
      context.missing(_winBeforeMeta);
    }
    if (data.containsKey('win_after')) {
      context.handle(
        _winAfterMeta,
        winAfter.isAcceptableOrUnknown(data['win_after']!, _winAfterMeta),
      );
    } else if (isInserting) {
      context.missing(_winAfterMeta);
    }
    if (data.containsKey('eval_before')) {
      context.handle(
        _evalBeforeMeta,
        evalBefore.isAcceptableOrUnknown(data['eval_before']!, _evalBeforeMeta),
      );
    } else if (isInserting) {
      context.missing(_evalBeforeMeta);
    }
    if (data.containsKey('eval_after')) {
      context.handle(
        _evalAfterMeta,
        evalAfter.isAcceptableOrUnknown(data['eval_after']!, _evalAfterMeta),
      );
    } else if (isInserting) {
      context.missing(_evalAfterMeta);
    }
    if (data.containsKey('best_uci')) {
      context.handle(
        _bestUciMeta,
        bestUci.isAcceptableOrUnknown(data['best_uci']!, _bestUciMeta),
      );
    }
    if (data.containsKey('best_san')) {
      context.handle(
        _bestSanMeta,
        bestSan.isAcceptableOrUnknown(data['best_san']!, _bestSanMeta),
      );
    }
    if (data.containsKey('best_line')) {
      context.handle(
        _bestLineMeta,
        bestLine.isAcceptableOrUnknown(data['best_line']!, _bestLineMeta),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('piece')) {
      context.handle(
        _pieceMeta,
        piece.isAcceptableOrUnknown(data['piece']!, _pieceMeta),
      );
    } else if (isInserting) {
      context.missing(_pieceMeta);
    }
    if (data.containsKey('clock_ms')) {
      context.handle(
        _clockMsMeta,
        clockMs.isAcceptableOrUnknown(data['clock_ms']!, _clockMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, ply};
  @override
  MoveAnalysisRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoveAnalysisRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      ply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ply'],
      )!,
      whiteMoved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}white_moved'],
      )!,
      san: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}san'],
      )!,
      uci: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uci'],
      )!,
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      winBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}win_before'],
      )!,
      winAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}win_after'],
      )!,
      evalBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eval_before'],
      )!,
      evalAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eval_after'],
      )!,
      bestUci: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}best_uci'],
      ),
      bestSan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}best_san'],
      ),
      bestLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}best_line'],
      ),
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      piece: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}piece'],
      )!,
      clockMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clock_ms'],
      ),
    );
  }

  @override
  $MoveAnalysesTable createAlias(String alias) {
    return $MoveAnalysesTable(attachedDatabase, alias);
  }
}

class MoveAnalysisRow extends DataClass implements Insertable<MoveAnalysisRow> {
  final String gameId;
  final int ply;
  final bool whiteMoved;
  final String san;
  final String uci;
  final String classification;
  final double accuracy;
  final double winBefore;
  final double winAfter;

  /// White-POV evals as JSON ({"cp":..} / {"mate":..}).
  final String evalBefore;
  final String evalAfter;
  final String? bestUci;
  final String? bestSan;

  /// Engine line in SAN, space separated.
  final String? bestLine;
  final String phase;
  final String piece;
  final int? clockMs;
  const MoveAnalysisRow({
    required this.gameId,
    required this.ply,
    required this.whiteMoved,
    required this.san,
    required this.uci,
    required this.classification,
    required this.accuracy,
    required this.winBefore,
    required this.winAfter,
    required this.evalBefore,
    required this.evalAfter,
    this.bestUci,
    this.bestSan,
    this.bestLine,
    required this.phase,
    required this.piece,
    this.clockMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['ply'] = Variable<int>(ply);
    map['white_moved'] = Variable<bool>(whiteMoved);
    map['san'] = Variable<String>(san);
    map['uci'] = Variable<String>(uci);
    map['classification'] = Variable<String>(classification);
    map['accuracy'] = Variable<double>(accuracy);
    map['win_before'] = Variable<double>(winBefore);
    map['win_after'] = Variable<double>(winAfter);
    map['eval_before'] = Variable<String>(evalBefore);
    map['eval_after'] = Variable<String>(evalAfter);
    if (!nullToAbsent || bestUci != null) {
      map['best_uci'] = Variable<String>(bestUci);
    }
    if (!nullToAbsent || bestSan != null) {
      map['best_san'] = Variable<String>(bestSan);
    }
    if (!nullToAbsent || bestLine != null) {
      map['best_line'] = Variable<String>(bestLine);
    }
    map['phase'] = Variable<String>(phase);
    map['piece'] = Variable<String>(piece);
    if (!nullToAbsent || clockMs != null) {
      map['clock_ms'] = Variable<int>(clockMs);
    }
    return map;
  }

  MoveAnalysesCompanion toCompanion(bool nullToAbsent) {
    return MoveAnalysesCompanion(
      gameId: Value(gameId),
      ply: Value(ply),
      whiteMoved: Value(whiteMoved),
      san: Value(san),
      uci: Value(uci),
      classification: Value(classification),
      accuracy: Value(accuracy),
      winBefore: Value(winBefore),
      winAfter: Value(winAfter),
      evalBefore: Value(evalBefore),
      evalAfter: Value(evalAfter),
      bestUci: bestUci == null && nullToAbsent
          ? const Value.absent()
          : Value(bestUci),
      bestSan: bestSan == null && nullToAbsent
          ? const Value.absent()
          : Value(bestSan),
      bestLine: bestLine == null && nullToAbsent
          ? const Value.absent()
          : Value(bestLine),
      phase: Value(phase),
      piece: Value(piece),
      clockMs: clockMs == null && nullToAbsent
          ? const Value.absent()
          : Value(clockMs),
    );
  }

  factory MoveAnalysisRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoveAnalysisRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      ply: serializer.fromJson<int>(json['ply']),
      whiteMoved: serializer.fromJson<bool>(json['whiteMoved']),
      san: serializer.fromJson<String>(json['san']),
      uci: serializer.fromJson<String>(json['uci']),
      classification: serializer.fromJson<String>(json['classification']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      winBefore: serializer.fromJson<double>(json['winBefore']),
      winAfter: serializer.fromJson<double>(json['winAfter']),
      evalBefore: serializer.fromJson<String>(json['evalBefore']),
      evalAfter: serializer.fromJson<String>(json['evalAfter']),
      bestUci: serializer.fromJson<String?>(json['bestUci']),
      bestSan: serializer.fromJson<String?>(json['bestSan']),
      bestLine: serializer.fromJson<String?>(json['bestLine']),
      phase: serializer.fromJson<String>(json['phase']),
      piece: serializer.fromJson<String>(json['piece']),
      clockMs: serializer.fromJson<int?>(json['clockMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'ply': serializer.toJson<int>(ply),
      'whiteMoved': serializer.toJson<bool>(whiteMoved),
      'san': serializer.toJson<String>(san),
      'uci': serializer.toJson<String>(uci),
      'classification': serializer.toJson<String>(classification),
      'accuracy': serializer.toJson<double>(accuracy),
      'winBefore': serializer.toJson<double>(winBefore),
      'winAfter': serializer.toJson<double>(winAfter),
      'evalBefore': serializer.toJson<String>(evalBefore),
      'evalAfter': serializer.toJson<String>(evalAfter),
      'bestUci': serializer.toJson<String?>(bestUci),
      'bestSan': serializer.toJson<String?>(bestSan),
      'bestLine': serializer.toJson<String?>(bestLine),
      'phase': serializer.toJson<String>(phase),
      'piece': serializer.toJson<String>(piece),
      'clockMs': serializer.toJson<int?>(clockMs),
    };
  }

  MoveAnalysisRow copyWith({
    String? gameId,
    int? ply,
    bool? whiteMoved,
    String? san,
    String? uci,
    String? classification,
    double? accuracy,
    double? winBefore,
    double? winAfter,
    String? evalBefore,
    String? evalAfter,
    Value<String?> bestUci = const Value.absent(),
    Value<String?> bestSan = const Value.absent(),
    Value<String?> bestLine = const Value.absent(),
    String? phase,
    String? piece,
    Value<int?> clockMs = const Value.absent(),
  }) => MoveAnalysisRow(
    gameId: gameId ?? this.gameId,
    ply: ply ?? this.ply,
    whiteMoved: whiteMoved ?? this.whiteMoved,
    san: san ?? this.san,
    uci: uci ?? this.uci,
    classification: classification ?? this.classification,
    accuracy: accuracy ?? this.accuracy,
    winBefore: winBefore ?? this.winBefore,
    winAfter: winAfter ?? this.winAfter,
    evalBefore: evalBefore ?? this.evalBefore,
    evalAfter: evalAfter ?? this.evalAfter,
    bestUci: bestUci.present ? bestUci.value : this.bestUci,
    bestSan: bestSan.present ? bestSan.value : this.bestSan,
    bestLine: bestLine.present ? bestLine.value : this.bestLine,
    phase: phase ?? this.phase,
    piece: piece ?? this.piece,
    clockMs: clockMs.present ? clockMs.value : this.clockMs,
  );
  MoveAnalysisRow copyWithCompanion(MoveAnalysesCompanion data) {
    return MoveAnalysisRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      ply: data.ply.present ? data.ply.value : this.ply,
      whiteMoved: data.whiteMoved.present
          ? data.whiteMoved.value
          : this.whiteMoved,
      san: data.san.present ? data.san.value : this.san,
      uci: data.uci.present ? data.uci.value : this.uci,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      winBefore: data.winBefore.present ? data.winBefore.value : this.winBefore,
      winAfter: data.winAfter.present ? data.winAfter.value : this.winAfter,
      evalBefore: data.evalBefore.present
          ? data.evalBefore.value
          : this.evalBefore,
      evalAfter: data.evalAfter.present ? data.evalAfter.value : this.evalAfter,
      bestUci: data.bestUci.present ? data.bestUci.value : this.bestUci,
      bestSan: data.bestSan.present ? data.bestSan.value : this.bestSan,
      bestLine: data.bestLine.present ? data.bestLine.value : this.bestLine,
      phase: data.phase.present ? data.phase.value : this.phase,
      piece: data.piece.present ? data.piece.value : this.piece,
      clockMs: data.clockMs.present ? data.clockMs.value : this.clockMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoveAnalysisRow(')
          ..write('gameId: $gameId, ')
          ..write('ply: $ply, ')
          ..write('whiteMoved: $whiteMoved, ')
          ..write('san: $san, ')
          ..write('uci: $uci, ')
          ..write('classification: $classification, ')
          ..write('accuracy: $accuracy, ')
          ..write('winBefore: $winBefore, ')
          ..write('winAfter: $winAfter, ')
          ..write('evalBefore: $evalBefore, ')
          ..write('evalAfter: $evalAfter, ')
          ..write('bestUci: $bestUci, ')
          ..write('bestSan: $bestSan, ')
          ..write('bestLine: $bestLine, ')
          ..write('phase: $phase, ')
          ..write('piece: $piece, ')
          ..write('clockMs: $clockMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    gameId,
    ply,
    whiteMoved,
    san,
    uci,
    classification,
    accuracy,
    winBefore,
    winAfter,
    evalBefore,
    evalAfter,
    bestUci,
    bestSan,
    bestLine,
    phase,
    piece,
    clockMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoveAnalysisRow &&
          other.gameId == this.gameId &&
          other.ply == this.ply &&
          other.whiteMoved == this.whiteMoved &&
          other.san == this.san &&
          other.uci == this.uci &&
          other.classification == this.classification &&
          other.accuracy == this.accuracy &&
          other.winBefore == this.winBefore &&
          other.winAfter == this.winAfter &&
          other.evalBefore == this.evalBefore &&
          other.evalAfter == this.evalAfter &&
          other.bestUci == this.bestUci &&
          other.bestSan == this.bestSan &&
          other.bestLine == this.bestLine &&
          other.phase == this.phase &&
          other.piece == this.piece &&
          other.clockMs == this.clockMs);
}

class MoveAnalysesCompanion extends UpdateCompanion<MoveAnalysisRow> {
  final Value<String> gameId;
  final Value<int> ply;
  final Value<bool> whiteMoved;
  final Value<String> san;
  final Value<String> uci;
  final Value<String> classification;
  final Value<double> accuracy;
  final Value<double> winBefore;
  final Value<double> winAfter;
  final Value<String> evalBefore;
  final Value<String> evalAfter;
  final Value<String?> bestUci;
  final Value<String?> bestSan;
  final Value<String?> bestLine;
  final Value<String> phase;
  final Value<String> piece;
  final Value<int?> clockMs;
  final Value<int> rowid;
  const MoveAnalysesCompanion({
    this.gameId = const Value.absent(),
    this.ply = const Value.absent(),
    this.whiteMoved = const Value.absent(),
    this.san = const Value.absent(),
    this.uci = const Value.absent(),
    this.classification = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.winBefore = const Value.absent(),
    this.winAfter = const Value.absent(),
    this.evalBefore = const Value.absent(),
    this.evalAfter = const Value.absent(),
    this.bestUci = const Value.absent(),
    this.bestSan = const Value.absent(),
    this.bestLine = const Value.absent(),
    this.phase = const Value.absent(),
    this.piece = const Value.absent(),
    this.clockMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoveAnalysesCompanion.insert({
    required String gameId,
    required int ply,
    required bool whiteMoved,
    required String san,
    required String uci,
    required String classification,
    required double accuracy,
    required double winBefore,
    required double winAfter,
    required String evalBefore,
    required String evalAfter,
    this.bestUci = const Value.absent(),
    this.bestSan = const Value.absent(),
    this.bestLine = const Value.absent(),
    required String phase,
    required String piece,
    this.clockMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       ply = Value(ply),
       whiteMoved = Value(whiteMoved),
       san = Value(san),
       uci = Value(uci),
       classification = Value(classification),
       accuracy = Value(accuracy),
       winBefore = Value(winBefore),
       winAfter = Value(winAfter),
       evalBefore = Value(evalBefore),
       evalAfter = Value(evalAfter),
       phase = Value(phase),
       piece = Value(piece);
  static Insertable<MoveAnalysisRow> custom({
    Expression<String>? gameId,
    Expression<int>? ply,
    Expression<bool>? whiteMoved,
    Expression<String>? san,
    Expression<String>? uci,
    Expression<String>? classification,
    Expression<double>? accuracy,
    Expression<double>? winBefore,
    Expression<double>? winAfter,
    Expression<String>? evalBefore,
    Expression<String>? evalAfter,
    Expression<String>? bestUci,
    Expression<String>? bestSan,
    Expression<String>? bestLine,
    Expression<String>? phase,
    Expression<String>? piece,
    Expression<int>? clockMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (ply != null) 'ply': ply,
      if (whiteMoved != null) 'white_moved': whiteMoved,
      if (san != null) 'san': san,
      if (uci != null) 'uci': uci,
      if (classification != null) 'classification': classification,
      if (accuracy != null) 'accuracy': accuracy,
      if (winBefore != null) 'win_before': winBefore,
      if (winAfter != null) 'win_after': winAfter,
      if (evalBefore != null) 'eval_before': evalBefore,
      if (evalAfter != null) 'eval_after': evalAfter,
      if (bestUci != null) 'best_uci': bestUci,
      if (bestSan != null) 'best_san': bestSan,
      if (bestLine != null) 'best_line': bestLine,
      if (phase != null) 'phase': phase,
      if (piece != null) 'piece': piece,
      if (clockMs != null) 'clock_ms': clockMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoveAnalysesCompanion copyWith({
    Value<String>? gameId,
    Value<int>? ply,
    Value<bool>? whiteMoved,
    Value<String>? san,
    Value<String>? uci,
    Value<String>? classification,
    Value<double>? accuracy,
    Value<double>? winBefore,
    Value<double>? winAfter,
    Value<String>? evalBefore,
    Value<String>? evalAfter,
    Value<String?>? bestUci,
    Value<String?>? bestSan,
    Value<String?>? bestLine,
    Value<String>? phase,
    Value<String>? piece,
    Value<int?>? clockMs,
    Value<int>? rowid,
  }) {
    return MoveAnalysesCompanion(
      gameId: gameId ?? this.gameId,
      ply: ply ?? this.ply,
      whiteMoved: whiteMoved ?? this.whiteMoved,
      san: san ?? this.san,
      uci: uci ?? this.uci,
      classification: classification ?? this.classification,
      accuracy: accuracy ?? this.accuracy,
      winBefore: winBefore ?? this.winBefore,
      winAfter: winAfter ?? this.winAfter,
      evalBefore: evalBefore ?? this.evalBefore,
      evalAfter: evalAfter ?? this.evalAfter,
      bestUci: bestUci ?? this.bestUci,
      bestSan: bestSan ?? this.bestSan,
      bestLine: bestLine ?? this.bestLine,
      phase: phase ?? this.phase,
      piece: piece ?? this.piece,
      clockMs: clockMs ?? this.clockMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (ply.present) {
      map['ply'] = Variable<int>(ply.value);
    }
    if (whiteMoved.present) {
      map['white_moved'] = Variable<bool>(whiteMoved.value);
    }
    if (san.present) {
      map['san'] = Variable<String>(san.value);
    }
    if (uci.present) {
      map['uci'] = Variable<String>(uci.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (winBefore.present) {
      map['win_before'] = Variable<double>(winBefore.value);
    }
    if (winAfter.present) {
      map['win_after'] = Variable<double>(winAfter.value);
    }
    if (evalBefore.present) {
      map['eval_before'] = Variable<String>(evalBefore.value);
    }
    if (evalAfter.present) {
      map['eval_after'] = Variable<String>(evalAfter.value);
    }
    if (bestUci.present) {
      map['best_uci'] = Variable<String>(bestUci.value);
    }
    if (bestSan.present) {
      map['best_san'] = Variable<String>(bestSan.value);
    }
    if (bestLine.present) {
      map['best_line'] = Variable<String>(bestLine.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (piece.present) {
      map['piece'] = Variable<String>(piece.value);
    }
    if (clockMs.present) {
      map['clock_ms'] = Variable<int>(clockMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoveAnalysesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('ply: $ply, ')
          ..write('whiteMoved: $whiteMoved, ')
          ..write('san: $san, ')
          ..write('uci: $uci, ')
          ..write('classification: $classification, ')
          ..write('accuracy: $accuracy, ')
          ..write('winBefore: $winBefore, ')
          ..write('winAfter: $winAfter, ')
          ..write('evalBefore: $evalBefore, ')
          ..write('evalAfter: $evalAfter, ')
          ..write('bestUci: $bestUci, ')
          ..write('bestSan: $bestSan, ')
          ..write('bestLine: $bestLine, ')
          ..write('phase: $phase, ')
          ..write('piece: $piece, ')
          ..write('clockMs: $clockMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PositionEvalsTable extends PositionEvals
    with TableInfo<$PositionEvalsTable, PositionEvalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PositionEvalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fenKeyMeta = const VerificationMeta('fenKey');
  @override
  late final GeneratedColumn<String> fenKey = GeneratedColumn<String>(
    'fen_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _multiPvMeta = const VerificationMeta(
    'multiPv',
  );
  @override
  late final GeneratedColumn<int> multiPv = GeneratedColumn<int>(
    'multi_pv',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<int> depth = GeneratedColumn<int>(
    'depth',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    fenKey,
    multiPv,
    depth,
    json,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'position_evals';
  @override
  VerificationContext validateIntegrity(
    Insertable<PositionEvalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fen_key')) {
      context.handle(
        _fenKeyMeta,
        fenKey.isAcceptableOrUnknown(data['fen_key']!, _fenKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_fenKeyMeta);
    }
    if (data.containsKey('multi_pv')) {
      context.handle(
        _multiPvMeta,
        multiPv.isAcceptableOrUnknown(data['multi_pv']!, _multiPvMeta),
      );
    } else if (isInserting) {
      context.missing(_multiPvMeta);
    }
    if (data.containsKey('depth')) {
      context.handle(
        _depthMeta,
        depth.isAcceptableOrUnknown(data['depth']!, _depthMeta),
      );
    } else if (isInserting) {
      context.missing(_depthMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fenKey, multiPv};
  @override
  PositionEvalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PositionEvalRow(
      fenKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fen_key'],
      )!,
      multiPv: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}multi_pv'],
      )!,
      depth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}depth'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PositionEvalsTable createAlias(String alias) {
    return $PositionEvalsTable(attachedDatabase, alias);
  }
}

class PositionEvalRow extends DataClass implements Insertable<PositionEvalRow> {
  /// First four FEN fields (see `positionKey`).
  final String fenKey;
  final int multiPv;
  final int depth;

  /// JSON of `PositionEval` (scores are White-POV).
  final String json;
  final DateTime updatedAt;
  const PositionEvalRow({
    required this.fenKey,
    required this.multiPv,
    required this.depth,
    required this.json,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fen_key'] = Variable<String>(fenKey);
    map['multi_pv'] = Variable<int>(multiPv);
    map['depth'] = Variable<int>(depth);
    map['json'] = Variable<String>(json);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PositionEvalsCompanion toCompanion(bool nullToAbsent) {
    return PositionEvalsCompanion(
      fenKey: Value(fenKey),
      multiPv: Value(multiPv),
      depth: Value(depth),
      json: Value(json),
      updatedAt: Value(updatedAt),
    );
  }

  factory PositionEvalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PositionEvalRow(
      fenKey: serializer.fromJson<String>(json['fenKey']),
      multiPv: serializer.fromJson<int>(json['multiPv']),
      depth: serializer.fromJson<int>(json['depth']),
      json: serializer.fromJson<String>(json['json']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fenKey': serializer.toJson<String>(fenKey),
      'multiPv': serializer.toJson<int>(multiPv),
      'depth': serializer.toJson<int>(depth),
      'json': serializer.toJson<String>(json),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PositionEvalRow copyWith({
    String? fenKey,
    int? multiPv,
    int? depth,
    String? json,
    DateTime? updatedAt,
  }) => PositionEvalRow(
    fenKey: fenKey ?? this.fenKey,
    multiPv: multiPv ?? this.multiPv,
    depth: depth ?? this.depth,
    json: json ?? this.json,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PositionEvalRow copyWithCompanion(PositionEvalsCompanion data) {
    return PositionEvalRow(
      fenKey: data.fenKey.present ? data.fenKey.value : this.fenKey,
      multiPv: data.multiPv.present ? data.multiPv.value : this.multiPv,
      depth: data.depth.present ? data.depth.value : this.depth,
      json: data.json.present ? data.json.value : this.json,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PositionEvalRow(')
          ..write('fenKey: $fenKey, ')
          ..write('multiPv: $multiPv, ')
          ..write('depth: $depth, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fenKey, multiPv, depth, json, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PositionEvalRow &&
          other.fenKey == this.fenKey &&
          other.multiPv == this.multiPv &&
          other.depth == this.depth &&
          other.json == this.json &&
          other.updatedAt == this.updatedAt);
}

class PositionEvalsCompanion extends UpdateCompanion<PositionEvalRow> {
  final Value<String> fenKey;
  final Value<int> multiPv;
  final Value<int> depth;
  final Value<String> json;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PositionEvalsCompanion({
    this.fenKey = const Value.absent(),
    this.multiPv = const Value.absent(),
    this.depth = const Value.absent(),
    this.json = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PositionEvalsCompanion.insert({
    required String fenKey,
    required int multiPv,
    required int depth,
    required String json,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : fenKey = Value(fenKey),
       multiPv = Value(multiPv),
       depth = Value(depth),
       json = Value(json),
       updatedAt = Value(updatedAt);
  static Insertable<PositionEvalRow> custom({
    Expression<String>? fenKey,
    Expression<int>? multiPv,
    Expression<int>? depth,
    Expression<String>? json,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fenKey != null) 'fen_key': fenKey,
      if (multiPv != null) 'multi_pv': multiPv,
      if (depth != null) 'depth': depth,
      if (json != null) 'json': json,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PositionEvalsCompanion copyWith({
    Value<String>? fenKey,
    Value<int>? multiPv,
    Value<int>? depth,
    Value<String>? json,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PositionEvalsCompanion(
      fenKey: fenKey ?? this.fenKey,
      multiPv: multiPv ?? this.multiPv,
      depth: depth ?? this.depth,
      json: json ?? this.json,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fenKey.present) {
      map['fen_key'] = Variable<String>(fenKey.value);
    }
    if (multiPv.present) {
      map['multi_pv'] = Variable<int>(multiPv.value);
    }
    if (depth.present) {
      map['depth'] = Variable<int>(depth.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PositionEvalsCompanion(')
          ..write('fenKey: $fenKey, ')
          ..write('multiPv: $multiPv, ')
          ..write('depth: $depth, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinkedAccountsTable extends LinkedAccounts
    with TableInfo<$LinkedAccountsTable, LinkedAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinkedAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newestGameAtMeta = const VerificationMeta(
    'newestGameAt',
  );
  @override
  late final GeneratedColumn<DateTime> newestGameAt = GeneratedColumn<DateTime>(
    'newest_game_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    provider,
    username,
    lastSyncedAt,
    newestGameAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'linked_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinkedAccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('newest_game_at')) {
      context.handle(
        _newestGameAtMeta,
        newestGameAt.isAcceptableOrUnknown(
          data['newest_game_at']!,
          _newestGameAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {provider};
  @override
  LinkedAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinkedAccountRow(
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      newestGameAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}newest_game_at'],
      ),
    );
  }

  @override
  $LinkedAccountsTable createAlias(String alias) {
    return $LinkedAccountsTable(attachedDatabase, alias);
  }
}

class LinkedAccountRow extends DataClass
    implements Insertable<LinkedAccountRow> {
  final String provider;
  final String username;
  final DateTime? lastSyncedAt;

  /// Newest game time seen, used for incremental sync.
  final DateTime? newestGameAt;
  const LinkedAccountRow({
    required this.provider,
    required this.username,
    this.lastSyncedAt,
    this.newestGameAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider'] = Variable<String>(provider);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || newestGameAt != null) {
      map['newest_game_at'] = Variable<DateTime>(newestGameAt);
    }
    return map;
  }

  LinkedAccountsCompanion toCompanion(bool nullToAbsent) {
    return LinkedAccountsCompanion(
      provider: Value(provider),
      username: Value(username),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      newestGameAt: newestGameAt == null && nullToAbsent
          ? const Value.absent()
          : Value(newestGameAt),
    );
  }

  factory LinkedAccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinkedAccountRow(
      provider: serializer.fromJson<String>(json['provider']),
      username: serializer.fromJson<String>(json['username']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      newestGameAt: serializer.fromJson<DateTime?>(json['newestGameAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'provider': serializer.toJson<String>(provider),
      'username': serializer.toJson<String>(username),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'newestGameAt': serializer.toJson<DateTime?>(newestGameAt),
    };
  }

  LinkedAccountRow copyWith({
    String? provider,
    String? username,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> newestGameAt = const Value.absent(),
  }) => LinkedAccountRow(
    provider: provider ?? this.provider,
    username: username ?? this.username,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    newestGameAt: newestGameAt.present ? newestGameAt.value : this.newestGameAt,
  );
  LinkedAccountRow copyWithCompanion(LinkedAccountsCompanion data) {
    return LinkedAccountRow(
      provider: data.provider.present ? data.provider.value : this.provider,
      username: data.username.present ? data.username.value : this.username,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      newestGameAt: data.newestGameAt.present
          ? data.newestGameAt.value
          : this.newestGameAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinkedAccountRow(')
          ..write('provider: $provider, ')
          ..write('username: $username, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('newestGameAt: $newestGameAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(provider, username, lastSyncedAt, newestGameAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinkedAccountRow &&
          other.provider == this.provider &&
          other.username == this.username &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.newestGameAt == this.newestGameAt);
}

class LinkedAccountsCompanion extends UpdateCompanion<LinkedAccountRow> {
  final Value<String> provider;
  final Value<String> username;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> newestGameAt;
  final Value<int> rowid;
  const LinkedAccountsCompanion({
    this.provider = const Value.absent(),
    this.username = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.newestGameAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinkedAccountsCompanion.insert({
    required String provider,
    required String username,
    this.lastSyncedAt = const Value.absent(),
    this.newestGameAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : provider = Value(provider),
       username = Value(username);
  static Insertable<LinkedAccountRow> custom({
    Expression<String>? provider,
    Expression<String>? username,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? newestGameAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (provider != null) 'provider': provider,
      if (username != null) 'username': username,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (newestGameAt != null) 'newest_game_at': newestGameAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinkedAccountsCompanion copyWith({
    Value<String>? provider,
    Value<String>? username,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? newestGameAt,
    Value<int>? rowid,
  }) {
    return LinkedAccountsCompanion(
      provider: provider ?? this.provider,
      username: username ?? this.username,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      newestGameAt: newestGameAt ?? this.newestGameAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (newestGameAt.present) {
      map['newest_game_at'] = Variable<DateTime>(newestGameAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinkedAccountsCompanion(')
          ..write('provider: $provider, ')
          ..write('username: $username, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('newestGameAt: $newestGameAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $MoveAnalysesTable moveAnalyses = $MoveAnalysesTable(this);
  late final $PositionEvalsTable positionEvals = $PositionEvalsTable(this);
  late final $LinkedAccountsTable linkedAccounts = $LinkedAccountsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    games,
    moveAnalyses,
    positionEvals,
    linkedAccounts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('move_analyses', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GamesTableCreateCompanionBuilder = GamesCompanion Function({
  required String id,
  required String source,
  Value<String?> externalId,
  Value<String?> url,
  required String white,
  required String black,
  Value<int?> whiteElo,
  Value<int?> blackElo,
  required String result,
  Value<DateTime?> playedAt,
  Value<String?> timeControl,
  required String speed,
  Value<String?> eco,
  Value<String?> opening,
  Value<String?> event,
  required String initialFen,
  required String pliesJson,
  required String pgn,
  Value<String?> userSide,
  required DateTime importedAt,
  Value<DateTime?> analyzedAt,
  Value<int?> analysisDepth,
  Value<double?> whiteAccuracy,
  Value<double?> blackAccuracy,
  Value<int> rowid,
});
typedef $$GamesTableUpdateCompanionBuilder = GamesCompanion Function({
  Value<String> id,
  Value<String> source,
  Value<String?> externalId,
  Value<String?> url,
  Value<String> white,
  Value<String> black,
  Value<int?> whiteElo,
  Value<int?> blackElo,
  Value<String> result,
  Value<DateTime?> playedAt,
  Value<String?> timeControl,
  Value<String> speed,
  Value<String?> eco,
  Value<String?> opening,
  Value<String?> event,
  Value<String> initialFen,
  Value<String> pliesJson,
  Value<String> pgn,
  Value<String?> userSide,
  Value<DateTime> importedAt,
  Value<DateTime?> analyzedAt,
  Value<int?> analysisDepth,
  Value<double?> whiteAccuracy,
  Value<double?> blackAccuracy,
  Value<int> rowid,
});

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, GameRow> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MoveAnalysesTable, List<MoveAnalysisRow>>
  _moveAnalysesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moveAnalyses,
    aliasName: 'games__id__move_analyses__game_id',
  );

  $$MoveAnalysesTableProcessedTableManager get moveAnalysesRefs {
    final manager = $$MoveAnalysesTableTableManager(
      $_db,
      $_db.moveAnalyses,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_moveAnalysesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get white => $composableBuilder(
    column: $table.white,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get black => $composableBuilder(
    column: $table.black,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get whiteElo => $composableBuilder(
    column: $table.whiteElo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blackElo => $composableBuilder(
    column: $table.blackElo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeControl => $composableBuilder(
    column: $table.timeControl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eco => $composableBuilder(
    column: $table.eco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opening => $composableBuilder(
    column: $table.opening,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initialFen => $composableBuilder(
    column: $table.initialFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pliesJson => $composableBuilder(
    column: $table.pliesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pgn => $composableBuilder(
    column: $table.pgn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userSide => $composableBuilder(
    column: $table.userSide,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get analysisDepth => $composableBuilder(
    column: $table.analysisDepth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get whiteAccuracy => $composableBuilder(
    column: $table.whiteAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get blackAccuracy => $composableBuilder(
    column: $table.blackAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> moveAnalysesRefs(
    Expression<bool> Function($$MoveAnalysesTableFilterComposer f) f,
  ) {
    final $$MoveAnalysesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moveAnalyses,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoveAnalysesTableFilterComposer(
            $db: $db,
            $table: $db.moveAnalyses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get white => $composableBuilder(
    column: $table.white,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get black => $composableBuilder(
    column: $table.black,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get whiteElo => $composableBuilder(
    column: $table.whiteElo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blackElo => $composableBuilder(
    column: $table.blackElo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeControl => $composableBuilder(
    column: $table.timeControl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eco => $composableBuilder(
    column: $table.eco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opening => $composableBuilder(
    column: $table.opening,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initialFen => $composableBuilder(
    column: $table.initialFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pliesJson => $composableBuilder(
    column: $table.pliesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pgn => $composableBuilder(
    column: $table.pgn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userSide => $composableBuilder(
    column: $table.userSide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get analysisDepth => $composableBuilder(
    column: $table.analysisDepth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get whiteAccuracy => $composableBuilder(
    column: $table.whiteAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get blackAccuracy => $composableBuilder(
    column: $table.blackAccuracy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get white =>
      $composableBuilder(column: $table.white, builder: (column) => column);

  GeneratedColumn<String> get black =>
      $composableBuilder(column: $table.black, builder: (column) => column);

  GeneratedColumn<int> get whiteElo =>
      $composableBuilder(column: $table.whiteElo, builder: (column) => column);

  GeneratedColumn<int> get blackElo =>
      $composableBuilder(column: $table.blackElo, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<String> get timeControl => $composableBuilder(
    column: $table.timeControl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get eco =>
      $composableBuilder(column: $table.eco, builder: (column) => column);

  GeneratedColumn<String> get opening =>
      $composableBuilder(column: $table.opening, builder: (column) => column);

  GeneratedColumn<String> get event =>
      $composableBuilder(column: $table.event, builder: (column) => column);

  GeneratedColumn<String> get initialFen => $composableBuilder(
    column: $table.initialFen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pliesJson =>
      $composableBuilder(column: $table.pliesJson, builder: (column) => column);

  GeneratedColumn<String> get pgn =>
      $composableBuilder(column: $table.pgn, builder: (column) => column);

  GeneratedColumn<String> get userSide =>
      $composableBuilder(column: $table.userSide, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get analysisDepth => $composableBuilder(
    column: $table.analysisDepth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get whiteAccuracy => $composableBuilder(
    column: $table.whiteAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get blackAccuracy => $composableBuilder(
    column: $table.blackAccuracy,
    builder: (column) => column,
  );

  Expression<T> moveAnalysesRefs<T extends Object>(
    Expression<T> Function($$MoveAnalysesTableAnnotationComposer a) f,
  ) {
    final $$MoveAnalysesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moveAnalyses,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoveAnalysesTableAnnotationComposer(
            $db: $db,
            $table: $db.moveAnalyses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          GameRow,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (GameRow, $$GamesTableReferences),
          GameRow,
          PrefetchHooks Function({bool moveAnalysesRefs})
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String> white = const Value.absent(),
                Value<String> black = const Value.absent(),
                Value<int?> whiteElo = const Value.absent(),
                Value<int?> blackElo = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime?> playedAt = const Value.absent(),
                Value<String?> timeControl = const Value.absent(),
                Value<String> speed = const Value.absent(),
                Value<String?> eco = const Value.absent(),
                Value<String?> opening = const Value.absent(),
                Value<String?> event = const Value.absent(),
                Value<String> initialFen = const Value.absent(),
                Value<String> pliesJson = const Value.absent(),
                Value<String> pgn = const Value.absent(),
                Value<String?> userSide = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<DateTime?> analyzedAt = const Value.absent(),
                Value<int?> analysisDepth = const Value.absent(),
                Value<double?> whiteAccuracy = const Value.absent(),
                Value<double?> blackAccuracy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                source: source,
                externalId: externalId,
                url: url,
                white: white,
                black: black,
                whiteElo: whiteElo,
                blackElo: blackElo,
                result: result,
                playedAt: playedAt,
                timeControl: timeControl,
                speed: speed,
                eco: eco,
                opening: opening,
                event: event,
                initialFen: initialFen,
                pliesJson: pliesJson,
                pgn: pgn,
                userSide: userSide,
                importedAt: importedAt,
                analyzedAt: analyzedAt,
                analysisDepth: analysisDepth,
                whiteAccuracy: whiteAccuracy,
                blackAccuracy: blackAccuracy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String source,
                Value<String?> externalId = const Value.absent(),
                Value<String?> url = const Value.absent(),
                required String white,
                required String black,
                Value<int?> whiteElo = const Value.absent(),
                Value<int?> blackElo = const Value.absent(),
                required String result,
                Value<DateTime?> playedAt = const Value.absent(),
                Value<String?> timeControl = const Value.absent(),
                required String speed,
                Value<String?> eco = const Value.absent(),
                Value<String?> opening = const Value.absent(),
                Value<String?> event = const Value.absent(),
                required String initialFen,
                required String pliesJson,
                required String pgn,
                Value<String?> userSide = const Value.absent(),
                required DateTime importedAt,
                Value<DateTime?> analyzedAt = const Value.absent(),
                Value<int?> analysisDepth = const Value.absent(),
                Value<double?> whiteAccuracy = const Value.absent(),
                Value<double?> blackAccuracy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                source: source,
                externalId: externalId,
                url: url,
                white: white,
                black: black,
                whiteElo: whiteElo,
                blackElo: blackElo,
                result: result,
                playedAt: playedAt,
                timeControl: timeControl,
                speed: speed,
                eco: eco,
                opening: opening,
                event: event,
                initialFen: initialFen,
                pliesJson: pliesJson,
                pgn: pgn,
                userSide: userSide,
                importedAt: importedAt,
                analyzedAt: analyzedAt,
                analysisDepth: analysisDepth,
                whiteAccuracy: whiteAccuracy,
                blackAccuracy: blackAccuracy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GamesTable, GameRow>(table),
                  $$GamesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({moveAnalysesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (moveAnalysesRefs) db.moveAnalyses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (moveAnalysesRefs)
                    await $_getPrefetchedDataByColumns<
                      GameRow,
                      $GamesTable,
                      MoveAnalysisRow,
                      $MoveAnalysesTable
                    >(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences
                          ._moveAnalysesRefsTable(db),
                      managerFromTypedResult: (p0) => $$GamesTableReferences(
                        db,
                        table,
                        p0,
                      ).moveAnalysesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'game_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      GameRow,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (GameRow, $$GamesTableReferences),
      GameRow,
      PrefetchHooks Function({bool moveAnalysesRefs})
    >;
typedef $$MoveAnalysesTableCreateCompanionBuilder =
    MoveAnalysesCompanion Function({
      required String gameId,
      required int ply,
      required bool whiteMoved,
      required String san,
      required String uci,
      required String classification,
      required double accuracy,
      required double winBefore,
      required double winAfter,
      required String evalBefore,
      required String evalAfter,
      Value<String?> bestUci,
      Value<String?> bestSan,
      Value<String?> bestLine,
      required String phase,
      required String piece,
      Value<int?> clockMs,
      Value<int> rowid,
    });
typedef $$MoveAnalysesTableUpdateCompanionBuilder =
    MoveAnalysesCompanion Function({
      Value<String> gameId,
      Value<int> ply,
      Value<bool> whiteMoved,
      Value<String> san,
      Value<String> uci,
      Value<String> classification,
      Value<double> accuracy,
      Value<double> winBefore,
      Value<double> winAfter,
      Value<String> evalBefore,
      Value<String> evalAfter,
      Value<String?> bestUci,
      Value<String?> bestSan,
      Value<String?> bestLine,
      Value<String> phase,
      Value<String> piece,
      Value<int?> clockMs,
      Value<int> rowid,
    });

final class $$MoveAnalysesTableReferences
    extends BaseReferences<_$AppDatabase, $MoveAnalysesTable, MoveAnalysisRow> {
  $$MoveAnalysesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('move_analyses__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoveAnalysesTableFilterComposer
    extends Composer<_$AppDatabase, $MoveAnalysesTable> {
  $$MoveAnalysesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get whiteMoved => $composableBuilder(
    column: $table.whiteMoved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get san => $composableBuilder(
    column: $table.san,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uci => $composableBuilder(
    column: $table.uci,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get winBefore => $composableBuilder(
    column: $table.winBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get winAfter => $composableBuilder(
    column: $table.winAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evalBefore => $composableBuilder(
    column: $table.evalBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evalAfter => $composableBuilder(
    column: $table.evalAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bestUci => $composableBuilder(
    column: $table.bestUci,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bestSan => $composableBuilder(
    column: $table.bestSan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bestLine => $composableBuilder(
    column: $table.bestLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get piece => $composableBuilder(
    column: $table.piece,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clockMs => $composableBuilder(
    column: $table.clockMs,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoveAnalysesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoveAnalysesTable> {
  $$MoveAnalysesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get whiteMoved => $composableBuilder(
    column: $table.whiteMoved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get san => $composableBuilder(
    column: $table.san,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uci => $composableBuilder(
    column: $table.uci,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get winBefore => $composableBuilder(
    column: $table.winBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get winAfter => $composableBuilder(
    column: $table.winAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evalBefore => $composableBuilder(
    column: $table.evalBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evalAfter => $composableBuilder(
    column: $table.evalAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestUci => $composableBuilder(
    column: $table.bestUci,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestSan => $composableBuilder(
    column: $table.bestSan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestLine => $composableBuilder(
    column: $table.bestLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get piece => $composableBuilder(
    column: $table.piece,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clockMs => $composableBuilder(
    column: $table.clockMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoveAnalysesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoveAnalysesTable> {
  $$MoveAnalysesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ply =>
      $composableBuilder(column: $table.ply, builder: (column) => column);

  GeneratedColumn<bool> get whiteMoved => $composableBuilder(
    column: $table.whiteMoved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get san =>
      $composableBuilder(column: $table.san, builder: (column) => column);

  GeneratedColumn<String> get uci =>
      $composableBuilder(column: $table.uci, builder: (column) => column);

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get winBefore =>
      $composableBuilder(column: $table.winBefore, builder: (column) => column);

  GeneratedColumn<double> get winAfter =>
      $composableBuilder(column: $table.winAfter, builder: (column) => column);

  GeneratedColumn<String> get evalBefore => $composableBuilder(
    column: $table.evalBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evalAfter =>
      $composableBuilder(column: $table.evalAfter, builder: (column) => column);

  GeneratedColumn<String> get bestUci =>
      $composableBuilder(column: $table.bestUci, builder: (column) => column);

  GeneratedColumn<String> get bestSan =>
      $composableBuilder(column: $table.bestSan, builder: (column) => column);

  GeneratedColumn<String> get bestLine =>
      $composableBuilder(column: $table.bestLine, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get piece =>
      $composableBuilder(column: $table.piece, builder: (column) => column);

  GeneratedColumn<int> get clockMs =>
      $composableBuilder(column: $table.clockMs, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoveAnalysesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoveAnalysesTable,
          MoveAnalysisRow,
          $$MoveAnalysesTableFilterComposer,
          $$MoveAnalysesTableOrderingComposer,
          $$MoveAnalysesTableAnnotationComposer,
          $$MoveAnalysesTableCreateCompanionBuilder,
          $$MoveAnalysesTableUpdateCompanionBuilder,
          (MoveAnalysisRow, $$MoveAnalysesTableReferences),
          MoveAnalysisRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$MoveAnalysesTableTableManager(_$AppDatabase db, $MoveAnalysesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoveAnalysesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoveAnalysesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoveAnalysesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<int> ply = const Value.absent(),
                Value<bool> whiteMoved = const Value.absent(),
                Value<String> san = const Value.absent(),
                Value<String> uci = const Value.absent(),
                Value<String> classification = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<double> winBefore = const Value.absent(),
                Value<double> winAfter = const Value.absent(),
                Value<String> evalBefore = const Value.absent(),
                Value<String> evalAfter = const Value.absent(),
                Value<String?> bestUci = const Value.absent(),
                Value<String?> bestSan = const Value.absent(),
                Value<String?> bestLine = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> piece = const Value.absent(),
                Value<int?> clockMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoveAnalysesCompanion(
                gameId: gameId,
                ply: ply,
                whiteMoved: whiteMoved,
                san: san,
                uci: uci,
                classification: classification,
                accuracy: accuracy,
                winBefore: winBefore,
                winAfter: winAfter,
                evalBefore: evalBefore,
                evalAfter: evalAfter,
                bestUci: bestUci,
                bestSan: bestSan,
                bestLine: bestLine,
                phase: phase,
                piece: piece,
                clockMs: clockMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                required int ply,
                required bool whiteMoved,
                required String san,
                required String uci,
                required String classification,
                required double accuracy,
                required double winBefore,
                required double winAfter,
                required String evalBefore,
                required String evalAfter,
                Value<String?> bestUci = const Value.absent(),
                Value<String?> bestSan = const Value.absent(),
                Value<String?> bestLine = const Value.absent(),
                required String phase,
                required String piece,
                Value<int?> clockMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoveAnalysesCompanion.insert(
                gameId: gameId,
                ply: ply,
                whiteMoved: whiteMoved,
                san: san,
                uci: uci,
                classification: classification,
                accuracy: accuracy,
                winBefore: winBefore,
                winAfter: winAfter,
                evalBefore: evalBefore,
                evalAfter: evalAfter,
                bestUci: bestUci,
                bestSan: bestSan,
                bestLine: bestLine,
                phase: phase,
                piece: piece,
                clockMs: clockMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoveAnalysesTable, MoveAnalysisRow>(table),
                  $$MoveAnalysesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$MoveAnalysesTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$MoveAnalysesTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MoveAnalysesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoveAnalysesTable,
      MoveAnalysisRow,
      $$MoveAnalysesTableFilterComposer,
      $$MoveAnalysesTableOrderingComposer,
      $$MoveAnalysesTableAnnotationComposer,
      $$MoveAnalysesTableCreateCompanionBuilder,
      $$MoveAnalysesTableUpdateCompanionBuilder,
      (MoveAnalysisRow, $$MoveAnalysesTableReferences),
      MoveAnalysisRow,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$PositionEvalsTableCreateCompanionBuilder =
    PositionEvalsCompanion Function({
      required String fenKey,
      required int multiPv,
      required int depth,
      required String json,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PositionEvalsTableUpdateCompanionBuilder =
    PositionEvalsCompanion Function({
      Value<String> fenKey,
      Value<int> multiPv,
      Value<int> depth,
      Value<String> json,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PositionEvalsTableFilterComposer
    extends Composer<_$AppDatabase, $PositionEvalsTable> {
  $$PositionEvalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fenKey => $composableBuilder(
    column: $table.fenKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get multiPv => $composableBuilder(
    column: $table.multiPv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PositionEvalsTableOrderingComposer
    extends Composer<_$AppDatabase, $PositionEvalsTable> {
  $$PositionEvalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fenKey => $composableBuilder(
    column: $table.fenKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get multiPv => $composableBuilder(
    column: $table.multiPv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PositionEvalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PositionEvalsTable> {
  $$PositionEvalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fenKey =>
      $composableBuilder(column: $table.fenKey, builder: (column) => column);

  GeneratedColumn<int> get multiPv =>
      $composableBuilder(column: $table.multiPv, builder: (column) => column);

  GeneratedColumn<int> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PositionEvalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PositionEvalsTable,
          PositionEvalRow,
          $$PositionEvalsTableFilterComposer,
          $$PositionEvalsTableOrderingComposer,
          $$PositionEvalsTableAnnotationComposer,
          $$PositionEvalsTableCreateCompanionBuilder,
          $$PositionEvalsTableUpdateCompanionBuilder,
          (
            PositionEvalRow,
            BaseReferences<_$AppDatabase, $PositionEvalsTable, PositionEvalRow>,
          ),
          PositionEvalRow,
          PrefetchHooks Function()
        > {
  $$PositionEvalsTableTableManager(_$AppDatabase db, $PositionEvalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PositionEvalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PositionEvalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PositionEvalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fenKey = const Value.absent(),
                Value<int> multiPv = const Value.absent(),
                Value<int> depth = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PositionEvalsCompanion(
                fenKey: fenKey,
                multiPv: multiPv,
                depth: depth,
                json: json,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fenKey,
                required int multiPv,
                required int depth,
                required String json,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PositionEvalsCompanion.insert(
                fenKey: fenKey,
                multiPv: multiPv,
                depth: depth,
                json: json,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PositionEvalsTable, PositionEvalRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PositionEvalsTable,
                    PositionEvalRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PositionEvalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PositionEvalsTable,
      PositionEvalRow,
      $$PositionEvalsTableFilterComposer,
      $$PositionEvalsTableOrderingComposer,
      $$PositionEvalsTableAnnotationComposer,
      $$PositionEvalsTableCreateCompanionBuilder,
      $$PositionEvalsTableUpdateCompanionBuilder,
      (
        PositionEvalRow,
        BaseReferences<_$AppDatabase, $PositionEvalsTable, PositionEvalRow>,
      ),
      PositionEvalRow,
      PrefetchHooks Function()
    >;
typedef $$LinkedAccountsTableCreateCompanionBuilder =
    LinkedAccountsCompanion Function({
      required String provider,
      required String username,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> newestGameAt,
      Value<int> rowid,
    });
typedef $$LinkedAccountsTableUpdateCompanionBuilder =
    LinkedAccountsCompanion Function({
      Value<String> provider,
      Value<String> username,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> newestGameAt,
      Value<int> rowid,
    });

class $$LinkedAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $LinkedAccountsTable> {
  $$LinkedAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get newestGameAt => $composableBuilder(
    column: $table.newestGameAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LinkedAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $LinkedAccountsTable> {
  $$LinkedAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get newestGameAt => $composableBuilder(
    column: $table.newestGameAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LinkedAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinkedAccountsTable> {
  $$LinkedAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get newestGameAt => $composableBuilder(
    column: $table.newestGameAt,
    builder: (column) => column,
  );
}

class $$LinkedAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LinkedAccountsTable,
          LinkedAccountRow,
          $$LinkedAccountsTableFilterComposer,
          $$LinkedAccountsTableOrderingComposer,
          $$LinkedAccountsTableAnnotationComposer,
          $$LinkedAccountsTableCreateCompanionBuilder,
          $$LinkedAccountsTableUpdateCompanionBuilder,
          (
            LinkedAccountRow,
            BaseReferences<
              _$AppDatabase,
              $LinkedAccountsTable,
              LinkedAccountRow
            >,
          ),
          LinkedAccountRow,
          PrefetchHooks Function()
        > {
  $$LinkedAccountsTableTableManager(
    _$AppDatabase db,
    $LinkedAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinkedAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinkedAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinkedAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> provider = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> newestGameAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinkedAccountsCompanion(
                provider: provider,
                username: username,
                lastSyncedAt: lastSyncedAt,
                newestGameAt: newestGameAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String provider,
                required String username,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> newestGameAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinkedAccountsCompanion.insert(
                provider: provider,
                username: username,
                lastSyncedAt: lastSyncedAt,
                newestGameAt: newestGameAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LinkedAccountsTable, LinkedAccountRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LinkedAccountsTable,
                    LinkedAccountRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LinkedAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LinkedAccountsTable,
      LinkedAccountRow,
      $$LinkedAccountsTableFilterComposer,
      $$LinkedAccountsTableOrderingComposer,
      $$LinkedAccountsTableAnnotationComposer,
      $$LinkedAccountsTableCreateCompanionBuilder,
      $$LinkedAccountsTableUpdateCompanionBuilder,
      (
        LinkedAccountRow,
        BaseReferences<_$AppDatabase, $LinkedAccountsTable, LinkedAccountRow>,
      ),
      LinkedAccountRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$MoveAnalysesTableTableManager get moveAnalyses =>
      $$MoveAnalysesTableTableManager(_db, _db.moveAnalyses);
  $$PositionEvalsTableTableManager get positionEvals =>
      $$PositionEvalsTableTableManager(_db, _db.positionEvals);
  $$LinkedAccountsTableTableManager get linkedAccounts =>
      $$LinkedAccountsTableTableManager(_db, _db.linkedAccounts);
}

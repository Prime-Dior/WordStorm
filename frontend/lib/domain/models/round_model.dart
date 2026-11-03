class RoundModel {
  const RoundModel({
    required this.number,
    required this.status,
    this.letter,
    this.startsAt,
    this.endsAt,
    this.answers = const [],
  });

  final int number;
  final String status;
  final String? letter;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final List<RoundAnswerModel> answers;

  factory RoundModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];

    return RoundModel(
      number: _readInt(json['number']),
      status: json['status']?.toString() ?? 'waiting',
      letter: json['letter']?.toString(),
      startsAt: _readDate(json['starts_at']),
      endsAt: _readDate(json['ends_at']),
      answers: rawAnswers is List
          ? rawAnswers
                .whereType<Map<String, dynamic>>()
                .map(RoundAnswerModel.fromJson)
                .toList()
          : const [],
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class RoundAnswerModel {
  const RoundAnswerModel({
    this.playerId,
    this.nickname,
    required this.category,
    this.value,
    this.validationStatus,
    this.dictionarySource,
    this.points,
    this.scoreReason,
  });

  final int? playerId;
  final String? nickname;
  final String category;
  final String? value;
  final String? validationStatus;
  final String? dictionarySource;
  final int? points;
  final String? scoreReason;

  factory RoundAnswerModel.fromJson(Map<String, dynamic> json) {
    return RoundAnswerModel(
      playerId: _readNullableInt(json['player_id']),
      nickname: json['nickname']?.toString(),
      category: json['category']?.toString() ?? '',
      value: json['value']?.toString(),
      validationStatus: json['validation_status']?.toString(),
      dictionarySource: json['dictionary_source']?.toString(),
      points: _readNullableInt(json['points']),
      scoreReason: json['score_reason']?.toString(),
    );
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

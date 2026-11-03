class PlayerModel {
  const PlayerModel({
    required this.id,
    required this.nickname,
    this.isHost = false,
    this.isGuest,
    this.joinedAt,
  });

  final int id;
  final String nickname;
  final bool isHost;
  final bool? isGuest;
  final DateTime? joinedAt;

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: _readInt(json['id']),
      nickname: json['nickname']?.toString() ?? '',
      isHost: json['is_host'] == true,
      isGuest: json['is_guest'] as bool?,
      joinedAt: _readDate(json['joined_at']),
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

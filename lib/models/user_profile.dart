/// 用户信息模型
class UserProfile {
  final String name;
  final String gender; // '男' / '女'
  final int birthYear;
  final int birthMonth;
  final int birthDay;
  final int birthHour;
  final bool isLunar; // 是否农历
  final String birthPlace;

  const UserProfile({
    required this.name,
    required this.gender,
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
    required this.birthHour,
    this.isLunar = false,
    this.birthPlace = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'birthYear': birthYear,
        'birthMonth': birthMonth,
        'birthDay': birthDay,
        'birthHour': birthHour,
        'isLunar': isLunar,
        'birthPlace': birthPlace,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        gender: json['gender'] ?? '男',
        birthYear: json['birthYear'] ?? 1990,
        birthMonth: json['birthMonth'] ?? 1,
        birthDay: json['birthDay'] ?? 1,
        birthHour: json['birthHour'] ?? 0,
        isLunar: json['isLunar'] ?? false,
        birthPlace: json['birthPlace'] ?? '',
      );

  UserProfile copyWith({
    String? name,
    String? gender,
    int? birthYear,
    int? birthMonth,
    int? birthDay,
    int? birthHour,
    bool? isLunar,
    String? birthPlace,
  }) =>
      UserProfile(
        name: name ?? this.name,
        gender: gender ?? this.gender,
        birthYear: birthYear ?? this.birthYear,
        birthMonth: birthMonth ?? this.birthMonth,
        birthDay: birthDay ?? this.birthDay,
        birthHour: birthHour ?? this.birthHour,
        isLunar: isLunar ?? this.isLunar,
        birthPlace: birthPlace ?? this.birthPlace,
      );
}

import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

enum ExperienceCategory {
  internship('Internship'),
  research('Research'),
  volunteer('Volunteer'),
  @JsonValue('part-time')
  partTime('Part-Time'),
  @JsonValue('full-time')
  fullTime('Full-Time'),
  freelance('Freelance'),
  @JsonValue('organizaiton')
  organization('Organization');

  const ExperienceCategory(this.label);

  final String label;
}

/// Portfolio experience synchronized with the Django REST Framework API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    required this.category,
    required this.startedAt,
    this.endedAt,
    this.thumbnail,
    this.id,
    this.isOngoing = false,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final ExperienceCategory category;
  @JsonKey(toJson: _dateToJson)
  final DateTime startedAt;
  @JsonKey(toJson: _dateToJson)
  final DateTime? endedAt;
  final String? thumbnail;
  @JsonKey(includeToJson: false)
  final bool isOngoing;
  @JsonKey(includeToJson: false)
  final int starCount;
  @JsonKey(includeToJson: false)
  final bool isStarred;
  @JsonKey(includeToJson: false)
  final String starredByNames;

  static String? _dateToJson(DateTime? date) =>
      date?.toIso8601String().split('T').first;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}

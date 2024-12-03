  import 'package:json_annotation/json_annotation.dart';
  import 'package:hive/hive.dart';
  part 'post.g.dart';
  @HiveType(typeId: 1)
  @JsonSerializable()
  class Post {
      @HiveField(1)
      @JsonKey(name: "userId")
      final int userId;
      @HiveField(3)
      @JsonKey(name: "id")
      final int id;
      @HiveField(5)
      @JsonKey(name: "title")
      final String title;
      @HiveField(7)
      @JsonKey(name: "body")
      final String body;

      Post({
          required this.userId,
          required this.id,
          required this.title,
          required this.body,
      });

      Post copyWith({
          int? userId,
          int? id,
          String? title,
          String? body,
      }) => 
          Post(
              userId: userId ?? this.userId,
              id: id ?? this.id,
              title: title ?? this.title,
              body: body ?? this.body,
          );

      factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

      Map<String, dynamic> toJson() => _$PostToJson(this);
  }
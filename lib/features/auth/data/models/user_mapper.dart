import 'package:productivity_planner/features/auth/data/models/auth_dtos.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';

extension UserDtoMapper on UserDto {
  User toDomain() => User(
    id: id,
    email: email,
    displayName: displayName,
    timeZone: timeZone,
    locale: locale,
    weekStart: weekStart,
    emailVerified: emailVerified,
  );
}

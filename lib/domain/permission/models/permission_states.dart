import '../../domain.dart';

class PermissionStates {
  PermissionStates({
    this.location = PermissionState.unknown,
    this.notification = PermissionState.unknown,
  });

  final PermissionState location;
  final PermissionState notification;

  PermissionState fromPermission(Permission permission) {
    return switch (permission) {
      Permission.location => location,
      Permission.notification => notification,
    };
  }
}

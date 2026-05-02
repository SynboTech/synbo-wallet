import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

abstract class DeviceSecurityService {
  Future<bool> isBiometricAvailable();
  Future<bool> authenticate({required String reason});
  Future<void> setScreenshotProtection(bool enabled);
}

class PlatformDeviceSecurityService implements DeviceSecurityService {
  PlatformDeviceSecurityService({
    LocalAuthentication? localAuthentication,
    MethodChannel? channel,
  }) : _localAuthentication = localAuthentication ?? LocalAuthentication(),
       _channel = channel ?? const MethodChannel('com.ck.wallet/security');

  final LocalAuthentication _localAuthentication;
  final MethodChannel _channel;

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuthentication.canCheckBiometrics ||
          await _localAuthentication.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setScreenshotProtection(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setScreenshotProtection', enabled);
    } catch (_) {}
  }
}

class NoopDeviceSecurityService implements DeviceSecurityService {
  const NoopDeviceSecurityService({
    this.biometricAvailable = false,
    this.biometricSucceeds = false,
  });

  final bool biometricAvailable;
  final bool biometricSucceeds;

  @override
  Future<bool> authenticate({required String reason}) async {
    return biometricAvailable && biometricSucceeds;
  }

  @override
  Future<bool> isBiometricAvailable() async {
    return biometricAvailable;
  }

  @override
  Future<void> setScreenshotProtection(bool enabled) async {}
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  SecurityService(this._storage, this._localAuthentication);

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuthentication;

  static const String _pinKey = 'pin_hash';

  Future<void> setPin(String pin) async {
    if (pin.length < 4) {
      throw ArgumentError('PIN must contain at least 4 digits.');
    }
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored != null && stored == pin;
  }

  Future<bool> authenticateWithBiometrics() async {
    final canAuthenticate = (await _localAuthentication.canCheckBiometrics) ||
        (await _localAuthentication.isDeviceSupported());
    if (!canAuthenticate) {
      return false;
    }
    return _localAuthentication.authenticate(
      localizedReason: 'Unlock ExpenseIQ',
      options: const AuthenticationOptions(biometricOnly: false),
    );
  }
}

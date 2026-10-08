import 'package:flutter_test/flutter_test.dart';
import 'package:three_bhai/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('nope'), isNotNull);
      expect(Validators.email('chef@3bhai.app'), isNull);
    });

    test('new password needs 8 chars and a number', () {
      expect(Validators.newPassword('short1'), isNotNull);
      expect(Validators.newPassword('longpassword'), isNotNull);
      expect(Validators.newPassword('longpass1'), isNull);
    });

    test('confirm password must match', () {
      final check = Validators.confirmPassword(() => 'secret123');
      expect(check('other'), isNotNull);
      expect(check('secret123'), isNull);
    });
  });
}

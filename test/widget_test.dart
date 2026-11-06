import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/models.dart';

void main() {
  test('Registration JSON round-trip', () {
    final r = Registration(
        id: 'r1', activityId: 'a1', userId: 'u1', userName: 'Tes', status: RegStatus.accepted);
    final back = Registration.fromJson(r.toJson());
    expect(back.status, RegStatus.accepted);
    expect(back.userName, 'Tes');
  });
}
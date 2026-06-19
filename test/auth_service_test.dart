import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulso/features/auth/application/auth_service.dart';
import 'package:pulso/features/auth/data/auth_operations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthOperations extends Mock implements AuthOperations {}

void main() {
  late MockAuthOperations auth;
  late AuthService subject;

  setUp(() {
    auth = MockAuthOperations();
    subject = AuthService(authOperations: auth);
    registerFallbackValue(<String, dynamic>{});
  });

  test('signOut delegates to auth operations', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});
    await subject.signOut();
    verify(() => auth.signOut()).called(1);
  });

  test('signUp with no session completes without profile writes', () async {
    when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => AuthResponse());

    await subject.signUp(
      email: 'a@b.com',
      password: 'secret123',
      firstName: 'Ada',
      lastName: 'Lovelace',
    );
    final captured = verify(
      () => auth.signUp(
        email: 'a@b.com',
        password: 'secret123',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured['first_name'], 'Ada');
    expect(captured['last_name'], 'Lovelace');
    expect(captured['full_name'], 'Ada Lovelace');
  });

  test('signIn delegates to password sign-in', () async {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AuthResponse());

    await subject.signIn(email: 'a@b.com', password: 'x');

    verify(
      () => auth.signInWithPassword(email: 'a@b.com', password: 'x'),
    ).called(1);
  });

  test('signUp forwards StudyGram name metadata', () async {
    when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => AuthResponse());

    await subject.signUp(
      email: 'x@y.com',
      password: 'pass',
      firstName: 'Alice',
      lastName: 'Santos',
    );

    final captured = verify(
      () => auth.signUp(
        email: 'x@y.com',
        password: 'pass',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured['first_name'], 'Alice');
    expect(captured['last_name'], 'Santos');
    expect(captured['full_name'], 'Alice Santos');
  });
}

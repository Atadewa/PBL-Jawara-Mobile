import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_strings.dart';
import 'package:mobile/main.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> _goToRegister(WidgetTester tester) async {
  await _pumpApp(tester);
  final registerLink = find.byKey(const Key('login_register_link'));
  await tester.ensureVisible(registerLink);
  await tester.tap(registerLink);
  await tester.pumpAndSettle();
}

Finder _fieldByKey(String key) => find.byKey(Key(key));
Finder get _fullNameField => _fieldByKey('register_full_name_field');
Finder get _usernameField => _fieldByKey('register_username_field');
Finder get _emailField => _fieldByKey('register_email_field');
Finder get _phoneField => _fieldByKey('register_phone_field');
Finder get _passwordField => _fieldByKey('register_password_field');
Finder get _confirmPasswordField => _fieldByKey('register_confirm_password_field');
Finder get _roleField => _fieldByKey('register_role_field');
Finder get _submitButton => _fieldByKey('register_submit_button');

Future<void> _selectRole(WidgetTester tester, String role) async {
  await tester.ensureVisible(_roleField);
  await tester.tap(_roleField);
  await tester.pumpAndSettle();

  final roleOption = find.text(role).last;
  await tester.ensureVisible(roleOption);
  await tester.tap(roleOption);
  await tester.pumpAndSettle();
}

Future<void> _fillValidData(WidgetTester tester) async {
  await tester.enterText(_fullNameField, 'User Test');
  await tester.enterText(_usernameField, 'user123');
  await tester.enterText(_emailField, 'user@example.com');
  await tester.enterText(_phoneField, '081234567890');
  await _selectRole(tester, 'Warga');
  await tester.enterText(_passwordField, 'password123');
  await tester.enterText(_confirmPasswordField, 'password123');
}

void main() {
  testWidgets(
    'register with valid data shows success and returns to login',
    (tester) async {
      // Arrange: navigate to register and fill with valid data
      await _goToRegister(tester);
      await _fillValidData(tester);

      // Act: submit registration form
      await tester.ensureVisible(_submitButton);
      await tester.tap(_submitButton);
      await tester.pump(); // start loading
      await tester.pump(const Duration(seconds: 2)); // wait for dummy API

      // Assert: success message shown
      expect(find.text(AppStrings.registerSuccess), findsOneWidget);

      // Wait for navigation back to login
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.loginTitle), findsOneWidget);
    },
  );

  testWidgets(
    'register with mismatched passwords shows confirmation error',
    (tester) async {
      // Arrange: navigate to register and fill mismatched passwords
      await _goToRegister(tester);
      await tester.enterText(_fullNameField, 'User Test');
      await tester.enterText(_usernameField, 'user123');
      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_phoneField, '081234567890');
      await _selectRole(tester, 'Pengurus RT');
      await tester.enterText(_passwordField, 'password123');
      await tester.enterText(_confirmPasswordField, 'differentPassword');

      // Act: submit form
      await tester.ensureVisible(_submitButton);
      await tester.tap(_submitButton);
      await tester.pumpAndSettle();

      // Assert: confirmation error is shown and still on register page
      expect(find.text(AppStrings.passwordNotMatch), findsOneWidget);
      expect(find.text(AppStrings.registerTitle), findsOneWidget);
      expect(find.text(AppStrings.loginTitle), findsNothing);
    },
  );

  testWidgets(
    'register with empty fields shows validation errors',
    (tester) async {
      // Arrange: navigate to register without input
      await _goToRegister(tester);

      // Act: submit empty form
      await tester.ensureVisible(_submitButton);
      await tester.tap(_submitButton);
      await tester.pumpAndSettle();

      // Assert: required field errors for all mandatory inputs
      expect(find.text(AppStrings.fieldRequired), findsNWidgets(7));
      expect(find.text(AppStrings.registerTitle), findsOneWidget);
      expect(find.text(AppStrings.registerSuccess), findsNothing);
    },
  );

  testWidgets(
    'register with invalid email shows email validation error',
    (tester) async {
      // Arrange: navigate to register and fill with invalid email
      await _goToRegister(tester);
      await tester.enterText(_fullNameField, 'User Test');
      await tester.enterText(_usernameField, 'user123');
      await tester.enterText(_emailField, 'invalid_email');
      await tester.enterText(_phoneField, '081234567890');
      await _selectRole(tester, 'Pengurus RW');
      await tester.enterText(_passwordField, 'password123');
      await tester.enterText(_confirmPasswordField, 'password123');

      // Act: submit form
      await tester.ensureVisible(_submitButton);
      await tester.tap(_submitButton);
      await tester.pumpAndSettle();

      // Assert: email-specific validation error and remains on register
      expect(find.text(AppStrings.invalidEmail), findsOneWidget);
      expect(find.text(AppStrings.registerTitle), findsOneWidget);
      expect(find.text(AppStrings.registerSuccess), findsNothing);
    },
  );
}

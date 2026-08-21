final _emailRegExp = RegExp(
  r'^[\w.!#$%&’*+/=?^`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
);

bool isValidEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) return false;
  return _emailRegExp.hasMatch(email);
}

bool isPasswordProvided(String value) => value.isNotEmpty;

bool isNameProvided(String value) => value.trim().isNotEmpty;

bool doPasswordsMatch(String password, String confirmPassword) =>
    password == confirmPassword;

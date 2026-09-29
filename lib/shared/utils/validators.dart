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

/// What Supabase Auth itself requires of a new password; checking it here
/// turns the server's error into an inline hint while typing.
const minPasswordLength = 6;

bool isValidNewPassword(String value) => value.length >= minPasswordLength;

const minUsernameLength = 3;
const maxUsernameLength = 20;

/// The one username rule of the product -- sign-up, "Minha conta" and the
/// database's `profiles_username_format` check all say the same thing:
/// 3 to 20 of A-Z, a-z, 0-9, "." and "_" (no spaces, accents or other
/// symbols). Case is kept as typed; uniqueness ignores it.
final usernamePattern = RegExp(r'^[A-Za-z0-9._]+$');

enum UsernameProblem { empty, length, characters }

/// What is wrong with [value] as a username, or null when it is fine.
/// Leading and trailing spaces are ignored (they are trimmed on save).
UsernameProblem? usernameProblem(String value) {
  final username = value.trim();
  if (username.isEmpty) return UsernameProblem.empty;
  if (username.length < minUsernameLength ||
      username.length > maxUsernameLength) {
    return UsernameProblem.length;
  }
  if (!usernamePattern.hasMatch(username)) return UsernameProblem.characters;
  return null;
}

bool isValidUsername(String value) => usernameProblem(value) == null;

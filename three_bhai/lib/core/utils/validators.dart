abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? requiredField(String? value, String message) =>
      (value == null || value.isEmpty) ? message : null;

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your name';
    if (v.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email';
    if (!_email.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Create a password';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!v.contains(RegExp(r'\d'))) return 'Include at least one number';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Re-enter your password';
      if (value != original()) return 'Passwords do not match';
      return null;
    };
  }

  static String? httpsUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the API base URL';
    final uri = Uri.tryParse(v);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return 'Use a valid https:// URL';
    }
    return null;
  }
}

class Validation {
  /// Returns null if valid, or an error message if invalid.
  static String? stellarSecretKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return 'Secret key is required';
    if (!trimmed.startsWith('S')) return "Secret key must start with 'S'";
    if (trimmed.length != 56) {
      return 'Secret key must be exactly 56 characters (got ${trimmed.length})';
    }
    final base32 = RegExp(r'^[A-Z2-7]+$');
    if (!base32.hasMatch(trimmed)) {
      return 'Secret key contains invalid characters (must be A-Z and 2-7)';
    }
    return null;
  }

  static String? stellarPublicKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return 'Address is required';
    if (!trimmed.startsWith('G')) return "Stellar address must start with 'G'";
    if (trimmed.length != 56) {
      return 'Stellar address must be exactly 56 characters (got ${trimmed.length})';
    }
    return null;
  }
}

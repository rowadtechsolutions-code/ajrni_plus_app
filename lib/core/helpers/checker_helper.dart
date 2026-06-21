mixin CheckerHelper {
  bool checkEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool checkUrl(String url) {
    try {
      final uri = Uri.parse(url);

      return (uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty);
    } catch (e) {
      return false;
    }
  }
}

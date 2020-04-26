import 'webdav/client.dart';

/// NextCloudClient class
class NextCloudClient {
  // ignore: public_member_api_docs
  NextCloudClient({
    this.scheme,
    this.host,
    this.username,
    this.password,
    this.port,
  }) {
    host = host.replaceFirst(RegExp(r'/http(s)?:/'), '');

    _webDavClient = WebDavClient(
      scheme: scheme,
      host: host,
      rootPath: "remote.php/webdav",
      username: username,
      password: password,
      port: port,
    );
  }

  // ignore: public_member_api_docs
  String host;

  String scheme;

  String rootPath;

  // ignore: public_member_api_docs
  final int port;

  // ignore: public_member_api_docs
  final String username;

  // ignore: public_member_api_docs
  final String password;

  WebDavClient _webDavClient;

  // ignore: public_member_api_docs
  WebDavClient get webDav => _webDavClient;
}

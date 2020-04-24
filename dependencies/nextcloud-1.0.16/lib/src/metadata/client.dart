import 'package:nextcloud/src/metadata/metadata.dart';
import 'package:nextcloud/src/network.dart';

/// MetaDataClient class
class MetaDataClient {
  // ignore: public_member_api_docs
  MetaDataClient(
    String host,
    String username,
    String password, {
    int port,
  }) {
    if (port == null) {
      _baseUrl = 'http://$host';
    } else {
      _baseUrl = 'http://$host:$port';
    }
    _baseUrl = '$_baseUrl/ocs/v1.php/cloud/users/$username';
    final _httpClient = NextCloudHttpClient(username, password);
    _network = Network(_httpClient);
  }

  String _baseUrl;

  Network _network;

  /// Get the meta data of the user
  Future<MetaData> getMetaData() async {
    final response = await _network.send('GET', _baseUrl, [200]);
    return metaDataFromMetaDataXml(response.body);
  }
}

import 'package:http/http.dart' as http;
import 'package:TrueTrack/constants/env.dart';

class RapidApiClient {
  final http.Client _client;

  RapidApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers(String host) => {
        'X-Rapidapi-Key': Env.rapidApiKey,
        'X-Rapidapi-Host': host,
      };

  Future<http.Response> get(String url, String host) =>
      _client.get(Uri.parse(url), headers: _headers(host));

  Future<http.Response> post(String url, String host, {Object? body}) =>
      _client.post(Uri.parse(url),
          headers: {..._headers(host), 'Content-Type': 'application/json'},
          body: body);

  void dispose() => _client.close();
}

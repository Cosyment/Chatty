import 'dart:convert';

import '../util/extend_http_client.dart';
import 'package:http/http.dart' as http;
import '../util/constants.dart';

class HttpRequest {
  static final SafeHttpClient _httpClient = SafeHttpClient(http.Client());

  static Future<T> request<T>(String url, T Function(dynamic) fromJson,
      {method = 'GET', Map<String, dynamic>? params}) async {
    var headers = {'Content-Type': 'application/json'};
    Uri uri = Uri.parse(Constants.hostUrl + url);
    http.Response? response;
    if (method == 'GET') {
      response = await _httpClient.get(uri, headers: headers);
    } else {
      response = await _httpClient.post(uri, headers: headers, body: params);
    }

    String errorMessage = '';
    try {
      Utf8Decoder decoder = const Utf8Decoder();
      var content = jsonDecode(decoder.convert(response.bodyBytes));
      errorMessage = content['msg'];
      var data = content['data'];
      if (content['code'] == 0 && data != null) {
        return fromJson(data);
      } else {
        return fromJson('');
      }
    } catch (e) {
      print(e);
      errorMessage = 'server internal exception';
    }
    throw Exception(errorMessage);
  }
}

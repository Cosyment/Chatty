import 'dart:convert';
import 'dart:ffi';

import '../util/extend_http_client.dart';
import 'package:http/http.dart' as http;
import '../util/constants.dart';

class HttpRequest {
  static final SafeHttpClient _httpClient = SafeHttpClient(http.Client());

  static Future<dynamic> request<T>(String url, T Function(dynamic) fromJson,
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
        if (data is List) {
          return List<T>.from(data.map((e) => fromJson(e)));
        } else {
          return fromJson(data);
        }
      } else {
        return fromJson('');
      }
    } catch (e) {
      print(e);
      errorMessage = 'server internal exception';
    }
    throw Exception(errorMessage);
  }

  static List<T> _parseResponse<T>(String responseBody) {
    // 在这里根据期望的响应数据类型，将字符串解析为相应的对象
    // 这里需要根据实际情况进行具体的解析逻辑
    // 假设你期望的响应数据类型是`T`，在这里进行相应的解析操作
    // 返回解析后的对象

    // 例如，假设期望的响应数据类型是`List<String>`
    // 则可以使用以下代码进行解析：
    return List<T>.from(jsonDecode(responseBody));

    // 如果无法确定响应数据类型或解析逻辑，请将返回类型改为`dynamic`或`Object`
    // 并在请求后手动处理响应的数据解析

    throw UnimplementedError('Response parsing not implemented for type $T');
  }
}

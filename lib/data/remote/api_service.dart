import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

class ApiService extends GetConnect {
  static const String apiBaseUrl = 'https://api.riderledger.app/v1';

  @override
  void onInit() {
    httpClient.baseUrl = apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    httpClient.defaultContentType = 'application/json';

    httpClient.addRequestModifier<dynamic>((Request<dynamic> request) {
      request.headers['Accept'] = 'application/json';
      return request;
    });

    httpClient.addResponseModifier<dynamic>(
      (Request<dynamic> request, Response<dynamic> response) {
        return response;
      },
    );
    super.onInit();
  }

  Future<Response<dynamic>> getData(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return get<dynamic>(path, query: query);
  }

  Future<Response<dynamic>> postData(String path, Map<String, dynamic> body) {
    return post<dynamic>(path, body);
  }

  Future<Response<dynamic>> putData(String path, Map<String, dynamic> body) {
    return put<dynamic>(path, body);
  }

  Future<Response<dynamic>> deleteData(String path) {
    return delete<dynamic>(path);
  }
}

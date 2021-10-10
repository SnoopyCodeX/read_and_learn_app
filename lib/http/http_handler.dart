import 'package:http/http.dart' as Http;

Future<Http.Response> postData(String url, dynamic data) async {
  return await Http.post(Uri.parse(url), body: data, headers: {"Content-Type": "application/json"});
}

Future<Http.Response> getData(String url) async {
  return await Http.get(Uri.parse(url), headers: {"Content-Type": "application/json"});
}
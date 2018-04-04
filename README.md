# http_test_client
A package for testing http clients on flutter or the Dart vm.


## Example
The following example forces all HTTP requests to return a
successful empty response in a test enviornment.  No actual HTTP requests will be performed.

```dart
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(_) {
    return new HttpTestClient((request, client) {
        // the default response is an empty 200.
        return new HttpTestResponse();
    });
  }
}

void main() {
  group('HttpClient', () {
    setUp(() {
      // overrides all HttpClients.
      HttpOverrides.global = new MyHttpOverrides();
    });

    test('returns OK', () async {
      // this is actually an instance of [HttpTestClient].
      final client = new HttpClient();
      final request = client.getUrl(new Uri.https('google.com'));
      final response = await request.close();

      expect(response.statusCode, HttpStatus.OK);
    });
  });
}
```

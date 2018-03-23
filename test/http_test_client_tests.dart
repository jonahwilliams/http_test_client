import 'dart:io';
import 'dart:convert';

import 'package:http_test_client/http_test_client.dart';
import 'package:test/test.dart';

class HttpTestOverrides extends HttpOverrides {
  HttpTestClient testClient;

  @override
  HttpClient createHttpClient(SecurityContext context) => testClient;
}

void main() {
  final HttpTestOverrides overrides = new HttpTestOverrides();
  HttpOverrides.global = overrides;

  group(HttpTestClient, () {
    setUp(() {
      overrides.testClient = new HttpTestClient(
          (HttpClientRequest request, HttpTestClient client) {
        return new HttpTestResponse(
          body: 'Hello World',
          statusCode: 200,
          headers: {'foo': 'bar'},
        );
      });
    });

    tearDown(() {
      overrides.testClient = null;
    });

    test('can be provided using HttpOverrides', () {
      final HttpClient client = new HttpClient();

      expect(client, const isInstanceOf<HttpTestClient>());
    });

    test('returns a body of "Hello World" and headers', () async {
      final client = new HttpClient();
      final request = await client.getUrl(new Uri.https('google.com', '/'));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      expect(body, 'Hello World');
      expect(response.headers.value('foo'), 'bar');
    });

    group(HttpTestHeaders, () {
      HttpHeaders headers;

      setUp(() async {
        final client = new HttpClient();
        final request = await client.getUrl(new Uri.https('google.com', '/'));
        headers = request.headers;
      });

      tearDown(() {
        headers = null;
      });

      test('return the value if headers.value has one entry', () {
        headers.add('foo', 'bar');

        expect(headers.value('foo'), 'bar');
      });

      test('returns null if headers.value has no entries', () {
        expect(headers.value('bar'), null);
      });

      test('throws if headers.value has more than one entry', () {
        headers..add('foo', 'bar')..add('foo', 'class');

        expect(() => headers.value('foo'),
            throwsA(const isInstanceOf<StateError>()));
      });
    });
  });
}

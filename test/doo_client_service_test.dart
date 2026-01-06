import 'dart:io';

import 'package:dio/dio.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/requests/doo_new_message_request.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/service/doo_client_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'doo_client_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late DOOClientServiceImpl service;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    service = DOOClientServiceImpl("https://test.com", dio: mockDio);
  });

  test('createMessage sends multipart request with correct fields', () async {
    // Arrange
    final tempDir = Directory.systemTemp.createTempSync();
    final tempFile = File('${tempDir.path}/test.png')..createSync();

    final request = DOONewMessageRequest(
      content: "test content",
      echoId: "test_echo_id",
      attachmentPaths: [tempFile.path],
    );

    when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          "id": 1,
          "content": "test content",
          "message_type": 0,
          "content_type": "text",
          "content_attributes": {},
          "created_at": "2023-01-01T00:00:00Z",
          "conversation_id": 1,
          "attachments": [],
          "sender": null,
          "echo_id": "test_echo_id",
        },
        statusCode: 200,
      ),
    );

    // Act
    await service.createMessage(request);

    // Assert
    final verification = verify(mockDio.post(
      argThat(contains("/messages")),
      data: captureAnyNamed('data'),
    ));

    final formData = verification.captured.first as FormData;
    expect(
        formData.fields
            .any((f) => f.key == "content" && f.value == "test content"),
        isTrue);
    expect(
        formData.fields
            .any((f) => f.key == "echo_id" && f.value == "test_echo_id"),
        isTrue);
    // Since we mock MultipartFile.fromFile in reality or just check if it's there
    expect(formData.files.any((f) => f.key == "attachments[]"), isTrue);
  });

  test('createMessage sends multipart request without attachments', () async {
    // Arrange
    final request = DOONewMessageRequest(
      content: "test content",
      echoId: "test_echo_id",
    );

    when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          "id": 1,
          "content": "test content",
          "message_type": 0,
          "content_type": "text",
          "content_attributes": {},
          "created_at": "2023-01-01T00:00:00Z",
          "conversation_id": 1,
          "attachments": [],
          "sender": null,
          "echo_id": "test_echo_id",
        },
        statusCode: 200,
      ),
    );

    // Act
    await service.createMessage(request);

    // Assert
    final verification = verify(mockDio.post(
      argThat(contains("/messages")),
      data: captureAnyNamed('data'),
    ));

    final formData = verification.captured.first as FormData;
    expect(
        formData.fields
            .any((f) => f.key == "content" && f.value == "test content"),
        isTrue);
    expect(formData.files.isEmpty, isTrue);
  });
}

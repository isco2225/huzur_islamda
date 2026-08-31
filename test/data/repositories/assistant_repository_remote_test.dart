import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';

void main() {
  late FakeAssistantService service;
  late AssistantRepositoryRemote repository;

  setUp(() {
    service = FakeAssistantService();
    repository = AssistantRepositoryRemote(assistantService: service);
  });

  test('forwards every argument, including the optional ones', () async {
    service.sendMessageResult = const Ok('Selamün aleyküm');

    final result = await repository.sendMessage(
      message: 'Merhaba',
      senderName: 'Ahmet',
      senderAge: '30',
      senderGender: 'male',
      previousMessages: const ['q1', 'a1'],
      postContent: 'Bir dua',
    );

    expect(result, isA<Ok<String>>());
    expect(result.asOk.value, 'Selamün aleyküm');
    expect(service.sendMessageCalls.single, {
      'message': 'Merhaba',
      'senderName': 'Ahmet',
      'senderAge': '30',
      'senderGender': 'male',
      'previousMessages': ['q1', 'a1'],
      'postContent': 'Bir dua',
    });
  });

  test('passes null for the optional arguments when omitted', () async {
    await repository.sendMessage(
      message: 'Merhaba',
      senderName: 'Ahmet',
      senderAge: '30',
      senderGender: 'male',
    );

    expect(service.sendMessageCalls.single['previousMessages'], isNull);
    expect(service.sendMessageCalls.single['postContent'], isNull);
  });

  test('returns the service Error unchanged', () async {
    service.sendMessageResult = const Error(AssistantUnexpectedError());

    final result = await repository.sendMessage(
      message: 'Merhaba',
      senderName: 'Ahmet',
      senderAge: '30',
      senderGender: 'male',
    );

    expect(result, isA<Error<String>>());
    expect(result.asError.error, isA<AssistantUnexpectedError>());
  });

  test('does not wrap exceptions thrown by the service (no try/catch)', () async {
    // Documents that, unlike the other repositories, this one has no
    // catch-all; callers rely on the service never throwing.
    service.throwOnCall = true;

    await expectLater(
      repository.sendMessage(
        message: 'Merhaba',
        senderName: 'Ahmet',
        senderAge: '30',
        senderGender: 'male',
      ),
      throwsA(isA<Exception>()),
    );
  });
}

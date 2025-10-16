import 'package:custom_camera_app/features/camera_connection/domain/repositories/camera_repository.dart';
import 'package:custom_camera_app/features/camera_connection/domain/usecases/disconnect_camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCameraRepository extends Mock implements CameraRepository {}

void main() {
  late DisconnectCamera useCase;
  late MockCameraRepository mockRepository;

  setUp(() {
    mockRepository = MockCameraRepository();
    useCase = DisconnectCamera(mockRepository);
  });

  group('DisconnectCamera', () {
    const testCameraId = 'camera_123';

    test('should disconnect from camera successfully', () async {
      // Arrange
      when(() => mockRepository.disconnect(testCameraId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase(const DisconnectCameraParams(cameraId: testCameraId));

      // Assert
      verify(() => mockRepository.disconnect(testCameraId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when disconnect fails', () async {
      // Arrange
      when(() => mockRepository.disconnect(testCameraId))
          .thenThrow(Exception('Disconnect failed'));

      // Act & Assert
      expect(
        () => useCase(const DisconnectCameraParams(cameraId: testCameraId)),
        throwsException,
      );
      verify(() => mockRepository.disconnect(testCameraId)).called(1);
    });
  });
}

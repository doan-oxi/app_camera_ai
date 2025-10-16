import 'package:custom_camera_app/features/camera_connection/domain/entities/camera.dart';
import 'package:custom_camera_app/features/camera_connection/domain/repositories/camera_repository.dart';
import 'package:custom_camera_app/features/camera_connection/domain/usecases/connect_camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCameraRepository extends Mock implements CameraRepository {}

void main() {
  late ConnectCamera useCase;
  late MockCameraRepository mockRepository;

  setUp(() {
    mockRepository = MockCameraRepository();
    useCase = ConnectCamera(mockRepository);
  });

  group('ConnectCamera', () {
    const testCameraId = 'camera_123';
    final testCamera = const Camera(
      id: testCameraId,
      name: 'Test Camera',
      status: CameraStatus.connected,
    );

    test('should connect to camera successfully', () async {
      // Arrange
      when(() => mockRepository.connect(testCameraId))
          .thenAnswer((_) async => testCamera);

      // Act
      final result = await useCase(
        const ConnectCameraParams(cameraId: testCameraId),
      );

      // Assert
      expect(result, equals(testCamera));
      verify(() => mockRepository.connect(testCameraId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when connection fails', () async {
      // Arrange
      when(() => mockRepository.connect(testCameraId))
          .thenThrow(Exception('Connection failed'));

      // Act & Assert
      expect(
        () => useCase(const ConnectCameraParams(cameraId: testCameraId)),
        throwsException,
      );
      verify(() => mockRepository.connect(testCameraId)).called(1);
    });
  });
}

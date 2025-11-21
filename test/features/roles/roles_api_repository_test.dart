import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ppv_components/features/roles/data/models/role_models.dart';
import 'package:ppv_components/features/roles/data/repositories/roles_api_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  group('RolesApiRepository', () {
    late _MockDio dio;
    late RolesApiRepository repository;

    setUp(() {
      dio = _MockDio();
      repository = RolesApiRepository(dio: dio);
    });

    test('getRoles returns success on 200', () async {
      final responseData = [
        {
          'roleId': '1',
          'name': 'ADMIN',
          'permissions': ['view-user'],
        },
      ];

      when(() => dio.get('/roles')).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/roles'),
        ),
      );

      final result = await repository.getRoles();

      expect(result.success, true);
      expect(result.data, isNotNull);
      expect(result.data!.roles.length, 1);
      expect(result.data!.roles.first.name, 'ADMIN');
    });

    test('getRoles returns failure on DioException with message', () async {
      when(() => dio.get('/roles')).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/roles'),
          response: Response(
            data: {'message': 'Failed'},
            statusCode: 400,
            requestOptions: RequestOptions(path: '/roles'),
          ),
        ),
      );

      final result = await repository.getRoles();

      expect(result.success, false);
      expect(result.message, 'Failed');
    });

    test('createRole sends correct payload and maps response', () async {
      final request = CreateRoleRequest(
        name: 'MANAGER',
        permissions: ['view-department'],
      );

      when(() => dio.post('/roles', data: request.toJson())).thenAnswer(
        (_) async => Response(
          data: {
            'roleId': '123',
            'name': 'MANAGER',
            'permissions': ['view-department'],
          },
          statusCode: 201,
          requestOptions: RequestOptions(path: '/roles'),
        ),
      );

      final result = await repository.createRole(request);

      expect(result.success, true);
      expect(result.data, isNotNull);
      expect(result.data!.name, 'MANAGER');
    });
  });
}

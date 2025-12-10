import 'package:ppv_components/core/providers/persistent_form_provider.dart';

class CreateDepartmentFormProvider extends PersistentFormProvider {
  CreateDepartmentFormProvider()
      : super(
          storageKey: 'create_department_form_state',
          defaults: const {
            'name': '',
            'description': '',
          },
        );

  String get name => getField<String>('name') ?? '';
  String get description => getField<String>('description') ?? '';
}

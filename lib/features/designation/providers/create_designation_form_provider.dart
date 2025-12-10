import 'package:ppv_components/core/providers/persistent_form_provider.dart';

class CreateDesignationFormProvider extends PersistentFormProvider {
  CreateDesignationFormProvider()
      : super(
          storageKey: 'create_designation_form_state',
          defaults: const {
            'name': '',
            'description': '',
          },
        );

  String get name => getField<String>('name') ?? '';
  String get description => getField<String>('description') ?? '';
}

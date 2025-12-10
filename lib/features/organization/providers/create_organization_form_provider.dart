import 'dart:convert';
import 'dart:typed_data';

import 'package:ppv_components/core/providers/persistent_form_provider.dart';

class CreateOrganizationFormProvider extends PersistentFormProvider {
  CreateOrganizationFormProvider()
      : super(
          storageKey: 'create_organization_form_state',
          defaults: const {
            'name': '',
            'code': '',
            'description': '',
            'projects': <String>[],
          },
        );

  String get name => getField<String>('name') ?? '';
  String get code => getField<String>('code') ?? '';
  String get description => getField<String>('description') ?? '';
  List<String> get projects {
    final list = getField<List<dynamic>>('projects') ?? const [];
    return list.map((e) => e.toString()).toList();
  }

  String? get logoFileName => getField<String>('logoFileName');
  Uint8List? get logoBytes {
    final value = getField<String>('logoBase64');
    if (value == null || value.isEmpty) return null;
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  void updateProjects(List<String> newProjects) {
    updateList('projects', newProjects);
  }

  void updateLogo(Uint8List? bytes, String? fileName) {
    if (bytes == null || bytes.isEmpty) {
      updateField('logoBase64', null);
      updateField('logoFileName', null);
      return;
    }
    updateField('logoBase64', base64Encode(bytes));
    updateField('logoFileName', fileName);
  }
}

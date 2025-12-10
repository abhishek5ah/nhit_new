import 'package:ppv_components/core/providers/persistent_form_provider.dart';

class CreateVendorFormProvider extends PersistentFormProvider {
  CreateVendorFormProvider()
      : super(
          storageKey: 'create_vendor_form_state',
          defaults: const {
            'status': 'Active',
            'bankAccounts': [],
          },
        );

  String get status => getField<String>('status') ?? 'Active';
  String? get fromAccountType => getField<String>('fromAccountType');
  String? get project => getField<String>('project');
  String? get msmeClassification => getField<String>('msmeClassification');
  String? get activityType => getField<String>('activityType');
  String? get vendorCode => getField<String>('vendorCode');

  DateTime? getDate(String key) {
    final value = getField<String>(key);
    return value != null ? DateTime.tryParse(value) : null;
  }

  List<Map<String, dynamic>> get bankAccounts {
    final accounts = getField<List<dynamic>>('bankAccounts');
    if (accounts == null) return [];
    return accounts.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  String getTextField(String key) => getField<String>(key) ?? '';

  void updateStatus(String value) => updateField('status', value);

  void updateDropdown(String key, String? value) => updateField(key, value);

  void updateDate(String key, DateTime? value) =>
      updateField(key, value?.toIso8601String());

  void updateBankAccounts(List<Map<String, dynamic>> accounts) =>
      updateList('bankAccounts', accounts);
}

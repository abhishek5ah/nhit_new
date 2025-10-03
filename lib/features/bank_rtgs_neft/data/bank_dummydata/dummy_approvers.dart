import 'dart:async';

import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/approver_model.dart';


Future<List<Approver>> fetchDummyApprovers() async {
// simulate network / disk latency
  await Future.delayed(const Duration(milliseconds: 350));


  return <Approver>[
    Approver(id: '1', name: 'Ravi Kant Vij', role: 'Approver 1'),
    Approver(id: '2', name: 'Sunil Kumar', role: 'Approver 1'),
    Approver(id: '3', name: 'Arun Kumar Jha', role: 'Approver 2'),
    Approver(id: '4', name: 'Shubhra Bhattacharya', role: 'Approver 2'),
    Approver(id: '5', name: 'Mathew George', role: 'Approver 2'),
    Approver(id: '6', name: 'Suresh Goyal', role: 'Approver 2'),
  ];
}
import 'package:flutter/material.dart';
import 'package:ppv_components/features/organization/model/organization_model.dart';

class OrganizationMockDB {
  static List<Organization> organizations = [
    Organization(
      id: 1,
      name: 'NHIT Southern Projects Private Limited',
      code: 'NSPPL',
      status: 'Active',
      createdBy: 'Super Admin',
      createdDate: 'Nov 03, 2025',
      description: 'Southern region projects',
      badgeColor: Colors.blue[700],
    ),
    Organization(
      id: 2,
      name: 'NHIT Eastern Projects Private Limited',
      code: 'NEPPL',
      status: 'Active',
      createdBy: 'Super Admin',
      createdDate: 'Nov 03, 2025',
      description: 'Eastern region projects',
      badgeColor: Colors.blue[700],
    ),
    Organization(
      id: 3,
      name: 'NHIT Western Projects Private Limited',
      code: 'NWPPL',
      status: 'Active',
      createdBy: 'Super Admin',
      createdDate: 'Nov 03, 2025',
      description: 'Western region projects',
      badgeColor: Colors.blue[700],
    ),
    Organization(
      id: 4,
      name: 'NHIT Default Organization',
      code: 'NHIT',
      status: 'Active',
      createdBy: 'Super Admin',
      createdDate: 'Oct 22, 2025',
      description: 'Default organization for existing users and data',
      badgeColor: Colors.grey[700],
    ),
  ];

  static Organization? getById(int id) {
    try {
      return organizations.firstWhere((org) => org.id == id);
    } catch (e) {
      return null;
    }
  }

  static void add(Organization organization) {
    organizations.add(organization);
  }

  static void update(Organization organization) {
    final index = organizations.indexWhere((org) => org.id == organization.id);
    if (index != -1) {
      organizations[index] = organization;
    }
  }

  static void delete(int id) {
    organizations.removeWhere((org) => org.id == id);
  }
}

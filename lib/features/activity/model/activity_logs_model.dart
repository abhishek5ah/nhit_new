import 'package:intl/intl.dart';

class ActivityLog {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'] ?? json['createdAt'];

    return ActivityLog(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get relativeTime => _formatRelativeTime(createdAt);

  String get createdAtDisplay => DateFormat('dd MMM yyyy, HH:mm').format(createdAt.toLocal());

  static String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime.toLocal());
    }
  }
}

class PaginationMeta {
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;

  PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    dynamic _value(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key];
        }
      }
      return null;
    }

    int _parseInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    final pageRaw = _value(['page', 'currentPage', 'page_number']);
    final pageSizeRaw = _value(['page_size', 'pageSize', 'perPage', 'limit']);
    final totalPagesRaw = _value(['total_pages', 'totalPages', 'pageCount']);
    final totalItemsRaw = _value(['total_items', 'totalItems', 'total_count', 'totalCount']);

    return PaginationMeta(
      page: _parseInt(pageRaw, fallback: 1),
      pageSize: _parseInt(pageSizeRaw, fallback: 10),
      totalPages: _parseInt(totalPagesRaw, fallback: 1),
      totalItems: _parseInt(totalItemsRaw, fallback: 0),
    );
  }
}

class ActivityLogsResponse {
  final List<ActivityLog> logs;
  final PaginationMeta pagination;

  ActivityLogsResponse({
    required this.logs,
    required this.pagination,
  });

  factory ActivityLogsResponse.fromJson(Map<String, dynamic> json) {
    return ActivityLogsResponse(
      logs: (json['logs'] as List<dynamic>? ?? [])
          .map((item) => ActivityLog.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

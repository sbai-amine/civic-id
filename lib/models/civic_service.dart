/// One row from GET `/services` (`data.services` array).
class CivicService {
  const CivicService({
    required this.id,
    required this.name,
    this.description = '',
    this.requiredDocuments = const [],
    this.fees = '',
  });

  final String id;
  final String name;
  final String description;
  final List<String> requiredDocuments;
  final String fees;

  factory CivicService.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String || name is! String) {
      throw FormatException('Invalid service payload: $json');
    }
    final desc = json['description'];
    final fees = json['fees'] ?? json['fee_display'];
    final rawDocs = json['requiredDocuments'] ?? json['required_documents'];
    final List<String> docs = [];
    if (rawDocs is List) {
      for (final e in rawDocs) {
        if (e is String) docs.add(e);
      }
    }
    return CivicService(
      id: id,
      name: name,
      description: desc is String ? desc : '',
      requiredDocuments: docs,
      fees: fees is String ? fees : '',
    );
  }
}

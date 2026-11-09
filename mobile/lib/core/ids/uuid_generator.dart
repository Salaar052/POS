import 'package:uuid/uuid.dart';

/// Generates client-side UUID v4 identifiers for local records.
class UuidGenerator {
  UuidGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  String v4() => _uuid.v4();
}

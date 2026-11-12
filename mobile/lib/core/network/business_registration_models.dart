/// Request body for `POST /businesses/register`.
class RegisterBusinessRequest {
  const RegisterBusinessRequest({
    required this.businessName,
    required this.ownerName,
    required this.ownerEmail,
    required this.password,
    this.businessPhone,
    this.businessEmail,
  });

  final String businessName;
  final String ownerName;
  final String ownerEmail;
  final String password;
  final String? businessPhone;
  final String? businessEmail;

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'password': password,
      if (businessPhone != null && businessPhone!.trim().isNotEmpty)
        'businessPhone': businessPhone!.trim(),
      if (businessEmail != null && businessEmail!.trim().isNotEmpty)
        'businessEmail': businessEmail!.trim(),
    };
  }
}

class RegisteredBusiness {
  const RegisteredBusiness({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.currencyCode,
    required this.timezone,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String currencyCode;
  final String timezone;
  final String status;
  final DateTime createdAt;

  factory RegisteredBusiness.fromJson(Map<String, dynamic> json) {
    return RegisteredBusiness(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      currencyCode: _requiredString(json, 'currencyCode'),
      timezone: _requiredString(json, 'timezone'),
      status: _requiredString(json, 'status'),
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')),
    );
  }
}

class RegisteredOwner {
  const RegisteredOwner({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String status;
  final DateTime createdAt;

  factory RegisteredOwner.fromJson(Map<String, dynamic> json) {
    return RegisteredOwner(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      email: _requiredString(json, 'email'),
      status: _requiredString(json, 'status'),
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')),
    );
  }
}

class RegisteredMembership {
  const RegisteredMembership({
    required this.id,
    required this.role,
    required this.status,
  });

  final String id;
  final String role;
  final String status;

  factory RegisteredMembership.fromJson(Map<String, dynamic> json) {
    return RegisteredMembership(
      id: _requiredString(json, 'id'),
      role: _requiredString(json, 'role'),
      status: _requiredString(json, 'status'),
    );
  }
}

class RegisterBusinessResult {
  const RegisterBusinessResult({
    required this.business,
    required this.owner,
    required this.membership,
  });

  final RegisteredBusiness business;
  final RegisteredOwner owner;
  final RegisteredMembership membership;

  factory RegisterBusinessResult.fromJson(Map<String, dynamic> json) {
    final business = json['business'];
    final owner = json['owner'];
    final membership = json['membership'];
    if (business is! Map<String, dynamic> ||
        owner is! Map<String, dynamic> ||
        membership is! Map<String, dynamic>) {
      throw const FormatException(
        'Registration response is missing required objects',
      );
    }
    return RegisterBusinessResult(
      business: RegisteredBusiness.fromJson(business),
      owner: RegisteredOwner.fromJson(owner),
      membership: RegisteredMembership.fromJson(membership),
    );
  }

  void validateForProvisioning() {
    const uuidPattern =
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$';
    final uuid = RegExp(uuidPattern);
    if (!uuid.hasMatch(business.id)) {
      throw const FormatException('Business id is not a UUID');
    }
    if (membership.role != 'OWNER') {
      throw FormatException('Unexpected membership role: ${membership.role}');
    }
    if (owner.status != 'PENDING_VERIFICATION') {
      throw FormatException('Unexpected owner status: ${owner.status}');
    }
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or invalid $key in registration response');
  }
  return value;
}

class Driver {
  final String id;
  final String fullName;
  final String gender;
  final String? profileImage;

  Driver({
    required this.id,
    required this.fullName,
    required this.gender,
    this.profileImage,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    try {
      return Driver(
        id: json['id'] ?? '',
        fullName: json['full_name'] ?? '',
        gender: json['gender'] ?? '',
        profileImage: json['profile_image'],
      );
    } catch (e) {
      print('Error parsing Driver: $e');
      return Driver(
        id: '',
        fullName: '',
        gender: '',
        profileImage: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'gender': gender,
      'profile_image': profileImage,
    };
  }
}

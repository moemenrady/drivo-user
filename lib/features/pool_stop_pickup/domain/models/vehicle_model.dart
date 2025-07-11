class Vehicle {
  final String brand;
  final String model;
  final String? plateNumber;

  Vehicle({
    required this.brand,
    required this.model,
    this.plateNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    try {
      return Vehicle(
        brand: json['brand'] ?? '',
        model: json['model'] ?? '',
        plateNumber: json['plate_number'] ?? "",
      );
    } catch (e) {
      print('Error parsing Vehicle: $e');
      return Vehicle(
        brand: '',
        model: '',
        plateNumber: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'plate_number': plateNumber,
    };
  }
}

class TodaySummaryModel {
  final int totalAssigned;
  final int completed;
  final int pending;

  const TodaySummaryModel({
    required this.totalAssigned,
    required this.completed,
    required this.pending,
  });

  factory TodaySummaryModel.fromJson(Map<String, dynamic> json) =>
      TodaySummaryModel(
        totalAssigned: json['total_assigned'] ?? 0,
        completed: json['completed'] ?? 0,
        pending: json['pending'] ?? 0,
      );
}

// ── Sub-models ────────────────────────────────────────────────────────────────

class WaterCanItem {
  final String name;
  final int quantity;
  final int litres;
  final String? image;

  const WaterCanItem({
    required this.name,
    required this.quantity,
    required this.litres,
    this.image,
  });

  factory WaterCanItem.fromJson(Map<String, dynamic> json) => WaterCanItem(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        litres: json['litres'] ?? 0,
        image: json['image'] as String?,
      );
}

class ProductItem {
  final String name;
  final int quantity;
  final String? image;

  const ProductItem({
    required this.name,
    required this.quantity,
    this.image,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        image: json['image'] as String?,
      );
}

class AddonItem {
  final String name;
  final int quantity;
  final String? image;

  const AddonItem({
    required this.name,
    required this.quantity,
    this.image,
  });

  factory AddonItem.fromJson(Map<String, dynamic> json) => AddonItem(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        image: json['image'] as String?,
      );
}

// ── Main Order Model ──────────────────────────────────────────────────────────

class OrderModel {
  final int id;
  final String customerName;
  final String phoneNumber;
  final String address;
  final String latitude;
  final String longitude;
  final String status;
  final String deliveryDate;
  final List<WaterCanItem> waterCans;
  final List<ProductItem> products;
  final List<AddonItem> addons;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.deliveryDate,
    required this.waterCans,
    required this.products,
    required this.addons,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] ?? 0,
        customerName: json['customer_name'] ?? '',
        phoneNumber: json['phone_number'] ?? '',
        address: json['address'] ?? '',
        latitude: json['latitude']?.toString() ?? '',
        longitude: json['longitude']?.toString() ?? '',
        status: json['status'] ?? '',
        deliveryDate: json['delivery_date'] ?? '',
        waterCans: (json['water_cans'] as List<dynamic>? ?? [])
            .map((e) => WaterCanItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        products: (json['products'] as List<dynamic>? ?? [])
            .map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        addons: (json['addons'] as List<dynamic>? ?? [])
            .map((e) => AddonItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Convenience: summary label for water cans e.g. "2 × 20L Can"
  String get waterCanSummary {
    if (waterCans.isEmpty) return '';
    return waterCans.map((c) => '${c.quantity} × ${c.name}').join(', ');
  }

  /// Total quantity of all water cans
  int get totalCanQuantity =>
      waterCans.fold(0, (sum, c) => sum + c.quantity);
}
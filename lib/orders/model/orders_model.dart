class OrdersModel {
  final int id;
  final String status;
  final String customerName;
  final String customerAddress;
  final String? latitude;
  final String? longitude;
  final List<OrderCanItem> waterCans;
  final List<OrderProductItem> products;
  final List<OrderAddonItem> addons;
  final int totalLiters;
  final String? deliveredAt;

  const OrdersModel({
    required this.id,
    required this.status,
    required this.customerName,
    required this.customerAddress,
    this.latitude,
    this.longitude,
    required this.waterCans,
    required this.products,
    required this.addons,
    required this.totalLiters,
    this.deliveredAt,
  });

  factory OrdersModel.fromJson(Map<String, dynamic> json) => OrdersModel(
        id: json['id'] ?? 0,
        status: json['status'] ?? '',
        customerName: json['customer_name'] ?? '',
        customerAddress: json['customer_address'] ?? '',
        latitude: json['latitude'] as String?,
        longitude: json['longitude'] as String?,
        waterCans: (json['water_cans'] as List<dynamic>? ?? [])
            .map((e) => OrderCanItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        products: (json['products'] as List<dynamic>? ?? [])
            .map((e) => OrderProductItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        addons: (json['addons'] as List<dynamic>? ?? [])
            .map((e) => OrderAddonItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalLiters: json['total_liters'] ?? 0,
        deliveredAt: json['delivered_at'] as String?,
      );

  String get itemSummary {
    final lines = [
      ...waterCans.map((c) => '${c.quantity} × ${c.name}'),
      ...products.map((p) => '${p.quantity} × ${p.name}'),
    ];
    if (lines.isEmpty) return 'No items';
    return lines.first;
  }
}

class OrderCanItem {
  final String name;
  final int quantity;
  final int litres;
  final String? image;

  const OrderCanItem({
    required this.name,
    required this.quantity,
    required this.litres,
    this.image,
  });

  factory OrderCanItem.fromJson(Map<String, dynamic> json) => OrderCanItem(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        litres: json['litres'] ?? 0,
        image: json['image'] as String?,
      );
}

class OrderProductItem {
  final String name;
  final int quantity;
  final String? image;

  const OrderProductItem({
    required this.name,
    required this.quantity,
    this.image,
  });

  factory OrderProductItem.fromJson(Map<String, dynamic> json) =>
      OrderProductItem(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        image: json['image'] as String?,
      );
}

class OrderAddonItem {
  final String name;
  final String? image;

  const OrderAddonItem({required this.name, this.image});

  factory OrderAddonItem.fromJson(Map<String, dynamic> json) => OrderAddonItem(
        name: json['name'] ?? '',
        image: json['image'] as String?,
      );
}
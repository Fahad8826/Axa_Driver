class OrderDetailModel {
  final int id;
  final String status;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final double customerLat;
  final double customerLng;
  final List<DetailWaterCan> waterCans;
  final List<DetailProduct> products;
  final List<DetailAddon> addons;
  final int totalLiters;
  final String? deliveredAt;
  final String? deliveryProofImage;
  final String? scheduledDate;

  const OrderDetailModel({
    required this.id,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLat,
    required this.customerLng,
    required this.waterCans,
    required this.products,
    required this.addons,
    required this.totalLiters,
    this.deliveredAt,
    this.deliveryProofImage,
    this.scheduledDate,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailModel(
        id: json['id'] ?? 0,
        status: json['status'] ?? '',
        customerName: json['customer_name'] ?? '',
        customerPhone: json['phone_number'] ?? '',
        customerAddress: json['address'] ?? '',
        customerLat: (json['customer_latitude'] as num?)?.toDouble() ?? 0.0,
        customerLng: (json['customer_longitude'] as num?)?.toDouble() ?? 0.0,
        waterCans: (json['water_cans'] as List<dynamic>? ?? [])
            .map((e) => DetailWaterCan.fromJson(e as Map<String, dynamic>))
            .toList(),
        products: (json['products'] as List<dynamic>? ?? [])
            .map((e) => DetailProduct.fromJson(e as Map<String, dynamic>))
            .toList(),
        addons: (json['addons'] as List<dynamic>? ?? [])
            .map((e) => DetailAddon.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalLiters: json['total_liters'] ?? 0,
        deliveredAt: json['delivered_at'] as String?,
        deliveryProofImage: json['delivery_proof_image'] as String?,
        scheduledDate: json['scheduled_date'] as String?,
      );
}

class DetailWaterCan {
  final String name;
  final int quantity;
  final int litres;
  final String? image;

  const DetailWaterCan({
    required this.name,
    required this.quantity,
    required this.litres,
    this.image,
  });

  factory DetailWaterCan.fromJson(Map<String, dynamic> json) => DetailWaterCan(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        litres: json['litres'] ?? 0,
        image: json['image'] as String?,
      );
}

class DetailProduct {
  final String name;
  final int quantity;
  final String? image;

  const DetailProduct({required this.name, required this.quantity, this.image});

  factory DetailProduct.fromJson(Map<String, dynamic> json) => DetailProduct(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        image: json['image'] as String?,
      );
}

class DetailAddon {
  final String name;
  final String? image;

  const DetailAddon({required this.name, this.image});

  factory DetailAddon.fromJson(Map<String, dynamic> json) =>
      DetailAddon(name: json['name'] ?? '', image: json['image'] as String?);
}
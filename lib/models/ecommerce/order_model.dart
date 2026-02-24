class Order {
  final String id;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final int subtotal;
  final int deliveryFee;
  final int total;
  final String note;

  final DateTime createdAt;
  final DateTime? updatedAt;

  final ShippingAddress shippingAddress;
  final List<OrderItem> items;
  final List<StoreOrder> storeOrders;

  Order({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.shippingAddress,
    required this.items,
    required this.storeOrders,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json["_id"] ?? json["id"]).toString(),
      status: (json["status"] ?? "").toString(),
      paymentMethod: (json["paymentMethod"] ?? "").toString(),
      paymentStatus: (json["paymentStatus"] ?? "").toString(),
      subtotal: _toInt(json["subtotal"]),
      deliveryFee: _toInt(json["deliveryFee"]),
      total: _toInt(json["total"]),
      note: (json["note"] ?? "").toString(),
      createdAt: DateTime.tryParse((json["createdAt"] ?? "").toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse((json["updatedAt"] ?? "").toString()),
      shippingAddress: ShippingAddress.fromJson(
        Map<String, dynamic>.from(json["shippingAddress"] ?? const {}),
      ),
      items: (json["items"] is List ? (json["items"] as List) : const [])
          .whereType<Map>()
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      storeOrders: (json["storeOrders"] is List ? (json["storeOrders"] as List) : const [])
          .whereType<Map>()
          .map((e) => StoreOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? "") ?? 0;
  }
}

class OrderItem {
  final String product; // can be id OR populated object -> we keep id string
  final String name;
  final String image;
  final int price;
  final int qty;
  final String store;

  OrderItem({
    required this.product,
    required this.name,
    required this.image,
    required this.price,
    required this.qty,
    required this.store,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final productField = json["product"];
    final productId = (productField is Map)
        ? (productField["_id"] ?? productField["id"]).toString()
        : (productField ?? "").toString();

    return OrderItem(
      product: productId,
      name: (json["name"] ?? "").toString(),
      image: (json["image"] ?? "").toString(),
      price: Order._toInt(json["price"]),
      qty: Order._toInt(json["qty"]),
      store: (json["store"] ?? "").toString(),
    );
  }
}

class StoreOrder {
  final String store; // can be id OR populated store object
  final String status;
  final int subtotal;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  StoreOrder({
    required this.store,
    required this.status,
    required this.subtotal,
    required this.updatedAt,
    required this.items,
  });

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    final storeField = json["store"];
    final storeId = (storeField is Map)
        ? (storeField["_id"] ?? storeField["id"]).toString()
        : (storeField ?? "").toString();

    return StoreOrder(
      store: storeId,
      status: (json["status"] ?? "").toString(),
      subtotal: Order._toInt(json["subtotal"]),
      updatedAt: DateTime.tryParse((json["updatedAt"] ?? "").toString()),
      items: (json["items"] is List ? (json["items"] as List) : const [])
          .whereType<Map>()
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ShippingAddress {
  final String label;
  final String name;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String district;
  final String province;
  final String country;
  final String postalCode;

  ShippingAddress({
    required this.label,
    required this.name,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.district,
    required this.province,
    required this.country,
    required this.postalCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      label: (json["label"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      phone: (json["phone"] ?? "").toString(),
      addressLine1: (json["addressLine1"] ?? "").toString(),
      addressLine2: (json["addressLine2"] ?? "").toString(),
      city: (json["city"] ?? "").toString(),
      district: (json["district"] ?? "").toString(),
      province: (json["province"] ?? "").toString(),
      country: (json["country"] ?? "").toString(),
      postalCode: (json["postalCode"] ?? "").toString(),
    );
  }
}
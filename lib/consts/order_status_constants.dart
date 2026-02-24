class StoreOrderStatuses {
  static const String pending = "PENDING";
  static const String accepted = "ACCEPTED";
  static const String packed = "PACKED";
  static const String shipped = "SHIPPED";
  static const String delivered = "DELIVERED";
  static const String cancelled = "CANCELLED";

  static const List<String> values = [
    pending,
    accepted,
    packed,
    shipped,
    delivered,
    cancelled,
  ];
}

class OrderStatuses {
  static const String pending = "PENDING";
  static const String partiallyFulfilled = "PARTIALLY_FULFILLED";
  static const String fulfilled = "FULFILLED";
  static const String cancelled = "CANCELLED";

  static const List<String> values = [
    pending,
    partiallyFulfilled,
    fulfilled,
    cancelled,
  ];
}

class PaymentStatuses {
  static const String unpaid = "UNPAID";
  static const String paid = "PAID";
  static const String refunded = "REFUNDED";

  static const List<String> values = [
    unpaid,
    paid,
    refunded,
  ];
}
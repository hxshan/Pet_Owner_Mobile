import 'package:flutter/material.dart';

Widget appointmentCard(
    double sw,
    double sh,
    String title,
    String doctor,
    String date,
    String time,
    Color accentColor, {
    String? status,
    String? confirmationStatus,
    String? petName,
    String? clinicName,
  }) {
    Color _statusColor(String s) {
      switch (s.toUpperCase()) {
        case 'BOOKED':
          return Colors.blue;
        case 'COMPLETED':
          return Colors.green;
        case 'CANCELLED':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    Color _confirmColor(String s) {
      switch (s.toUpperCase()) {
        case 'CONFIRMED':
          return Colors.green;
        case 'PENDING':
          return Colors.orange;
        case 'REJECTED':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.03),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(
              Icons.calendar_today,
              color: accentColor,
              size: sw * 0.055,
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + status chips
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (status != null)
                      _chip(sw, status, _statusColor(status)),
                  ],
                ),
                SizedBox(height: sh * 0.004),
                Text(
                  doctor,
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (clinicName != null && clinicName.isNotEmpty) ...[
                  SizedBox(height: sh * 0.003),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: sw * 0.033, color: Colors.grey.shade500),
                      SizedBox(width: sw * 0.008),
                      Expanded(
                        child: Text(
                          clinicName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: sw * 0.03,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (petName != null && petName.isNotEmpty) ...[
                  SizedBox(height: sh * 0.003),
                  Row(
                    children: [
                      Icon(Icons.pets,
                          size: sw * 0.033, color: Colors.grey.shade500),
                      SizedBox(width: sw * 0.008),
                      Text(
                        petName,
                        style: TextStyle(
                          fontSize: sw * 0.03,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: sh * 0.006),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: sw * 0.035,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: sw * 0.01),
                    Text(
                      '$date • $time',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (confirmationStatus != null) ...[
                      SizedBox(width: sw * 0.02),
                      _chip(sw, confirmationStatus,
                          _confirmColor(confirmationStatus)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _chip(double sw, String label, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(
        horizontal: sw * 0.02, vertical: sw * 0.008),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(sw * 0.02),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: sw * 0.025,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

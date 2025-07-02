import 'package:flutter/material.dart';

Widget buildServiceCard(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color backgroundColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 75, // Reduced from 120 to 75
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // Reduced from 20 to 16
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32, // Reduced from 50 to 32
          ),
          const SizedBox(width: 12), // Reduced from 20 to 12
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13, // Reduced from 15 to 13
                height: 1.2, // Reduced from 1.3 to 1.2
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

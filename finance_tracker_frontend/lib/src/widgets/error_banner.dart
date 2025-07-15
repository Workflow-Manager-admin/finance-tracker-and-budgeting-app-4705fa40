import 'package:flutter/material.dart';

// PUBLIC_INTERFACE
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withOpacity(0.95),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

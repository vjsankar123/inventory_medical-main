import 'package:flutter/material.dart';

class IncomeCards extends StatefulWidget {
  final String title;
  final String data;
  final Color color;
  final IconData icon;

  const IncomeCards({
    Key? key,
    required this.title,
    required this.data,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  _IncomeCardsState createState() => _IncomeCardsState();
}

class _IncomeCardsState extends State<IncomeCards> {
  bool isVisible = true;

  void toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 150, // Minimum width to maintain rectangle shape
        minHeight: 150, // Adjusted minimum height to provide more space
      ),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.currency_rupee,
                color: Colors.white,
                size: 18,
              ),
              Text(
                isVisible ? widget.data : '****',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: toggleVisibility,
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
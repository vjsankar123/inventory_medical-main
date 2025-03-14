import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String data;
  final Color color;
  final IconData icon;
  final bool isVisible;
  final VoidCallback? onToggle;

  const CustomCard({
    Key? key,
    required this.title,
    required this.data,
    required this.icon,
    required this.color,
    this.isVisible = true,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 28,
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title == "Sale Amount")
                Text(
                  '₹',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              Text(
                isVisible ? data : '*****',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              if (onToggle != null)
                IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: onToggle,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

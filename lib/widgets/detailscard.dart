import 'package:flutter/material.dart';

class LeadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: const [
          Text("     Older Leads",
              style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

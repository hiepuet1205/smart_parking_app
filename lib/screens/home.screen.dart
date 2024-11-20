import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16191D),
      appBar: AppBar(
        title: const Text('Current Parking'),
        backgroundColor: const Color(0xFF16191D),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: PageView(
                scrollDirection: Axis.horizontal,
                children: [
                  transactionCard(),
                  transactionCard(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recent Sessions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  sessionCard(),
                  sessionCard(),
                  sessionCard(),
                  sessionCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Reserve Spot'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF1E88E5),
      ),
    );
  }

  Widget transactionCard() {
    return Card(
      color: const Color(0xFF1A1D17),
      shadowColor: const Color(0xFF131619),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Color(0xFF1E88E5), width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parking Lot: West Kings',
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
            const SizedBox(height: 8),
            Text(
              'Mon, Jul 8',
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
            const SizedBox(height: 8),
            Text(
              '\$38.97 w/tax',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget sessionCard() {
    return Card(
      color: const Color(0xFF1A1D17),
      shadowColor: const Color(0xFF131619),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Color(0xFF1E88E5), width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Time Left',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ],
            ),
            const Text(
              'Expired',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

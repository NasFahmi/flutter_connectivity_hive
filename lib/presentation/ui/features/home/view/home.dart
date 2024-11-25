import 'package:flutter/material.dart';

class HomeScope extends StatelessWidget {
  const HomeScope({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('your status is online'),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('refresh'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
              itemCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}

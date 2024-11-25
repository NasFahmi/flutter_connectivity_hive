import 'package:flutter/material.dart';

class NotFound extends StatefulWidget {
  const NotFound({super.key});

  @override
  State<NotFound> createState() => NotFoundState();
}

class NotFoundState extends State<NotFound> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text("Not Found"),
        ),
    );
  }
}
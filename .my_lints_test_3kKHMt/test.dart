import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocProvider(
          create: (context) => MyBloc(),
          child: ElevatedButton(
            onPressed: () {
              Future.delayed(Duration(seconds: 1));
            },
            child: Text('Press me'),
          ),
        ),
        BlocProvider(
          create: (context) => AnotherBloc(),
          child: ElevatedButton(
            onPressed: () {
              Future.delayed(Duration(seconds: 1));
            },
            child: Text('Press me'),
          ),
        ),
      ],
    );
  }
}

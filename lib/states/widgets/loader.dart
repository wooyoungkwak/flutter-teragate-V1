import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  const Loader(
      {Key? key,
      this.opacity = 0.0,
      this.dismissibles = false,
      this.color = Colors.white,
      this.loadingTxt = 'Loading...'})
      : super(key: key);

  final double opacity;
  final bool dismissibles;
  final Color color;
  final String loadingTxt;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: opacity,
          child: const ModalBarrier(dismissible: false, color: Colors.black),
        ),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[SpinKitFadingCircle(color: Colors.black)],
          ),
        ),
      ],
    );
  }
}

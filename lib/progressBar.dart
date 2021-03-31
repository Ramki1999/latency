import 'package:percent_indicator/percent_indicator.dart';
import 'palette.dart';
import 'package:flutter/material.dart';

class ProgressBar {
  LinearPercentIndicator showBar(double displayPer,BuildContext context) {
    return new LinearPercentIndicator(
      width: (MediaQuery.of(context).size.width>MediaQuery.of(context).size.height)?500:MediaQuery.of(context).size.width - 40,
      lineHeight: 24.0,
      percent: displayPer / 100.0,
      center: Text(
        displayPer.toStringAsFixed(1) + "%",
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
          color: (displayPer>40.0)?Colors.black:Colors.white,
        ),
      ),
      linearStrokeCap: LinearStrokeCap.roundAll,
      backgroundColor: progressBg,
      progressColor: progressFill,
    );
  }
}

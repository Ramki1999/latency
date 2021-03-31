import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:internet_speed_test/internet_speed_test.dart';
import 'package:internet_speed_test/callbacks_enum.dart';
import 'progressBar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'palette.dart';
import 'testServer.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

final Shader linearGradient = LinearGradient(
  colors: <Color>[Colors.green[800], Colors.green],
).createShader(Rect.fromLTWH(10.0, 0.0, 110.0, 50.0));

final internetSpeedTest = InternetSpeedTest();
final ProgressBar progressBar = ProgressBar();
double downloadRate = 0;
double uploadRate = 0;
String downloadProgress = '0';
String uploadProgress = '0';
double displayRate = 0;
String displayRateTxt = '0.0';
double displayPer = 0;
String unitText = 'Mb/s';

// Using a flag to prevent the user from interrupting running tests
bool isTesting = false;

void protectGauge(double rate) {
  // this function prevents the needle from exceeding the maximum limit of the gauge
  if (rate > 150) {
    displayRateTxt = rate.toStringAsFixed(2);
  } else {
    displayRate = rate;
    displayRateTxt = displayRate.toStringAsFixed(2);
  }
}


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text("Latency",style: GoogleFonts.lobster(textStyle: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,foreground: Paint()..shader = linearGradient),)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.pink[900], Colors.deepPurple[900],Colors.pink[900],
              ]
            )
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: (size.width < size.height)?Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  child: Container(
                    width: 500,
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(height: 10),
                        // Text("",style: GoogleFonts.russoOne(textStyle: TextStyle(
                        //   fontSize: 25.0, color: Colors.white,))),
                        SfRadialGauge(
                            title: GaugeTitle(
                                text: "NETWORK SPEED TEST",
                            textStyle: TextStyle(fontSize: 25,color: Colors.white,)),
                            axes: <RadialAxis>[
                              RadialAxis(
                                  minimum: 0,
                                  maximum: 10,
                                  axisLabelStyle: GaugeTextStyle(
                                    color: txtCol,
                                  ),
                                  ranges: <GaugeRange>[
                                    GaugeRange(
                                        startValue: 0,
                                        endValue: 3.3,
                                        color: gaugeRange1,
                                        startWidth: 10,
                                        endWidth: 10),
                                    GaugeRange(
                                        startValue: 3.3,
                                        endValue: 7,
                                        color: gaugeRange2,
                                        startWidth: 10,
                                        endWidth: 10),
                                    GaugeRange(
                                        startValue: 7,
                                        endValue: 10,
                                        color: gaugeRange1,
                                        startWidth: 10,
                                        endWidth: 10)
                                  ],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(
                                      value: displayRate,
                                      enableAnimation: true,
                                      needleColor: needleCol,
                                    )
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Container(
                                          padding: const EdgeInsets.only(top: 100),
                                          child: Text(
                                            displayRate.toStringAsFixed(2) + ' ' + unitText,
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: txtCol,
                                            ),
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.5)
                                  ])
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RaisedButton(
                              child: Text(" START TEST ",style: GoogleFonts.varela(textStyle: TextStyle(fontSize: 20),)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80.0)),
                              // padding: const EdgeInsets.all(10.0),
                              color: Colors.green,
                              textColor: txtCol,
                              onPressed: () {
                                if (!isTesting) {
                                  setState(() {
                                    isTesting = true;
                                  });
                                  internetSpeedTest.startDownloadTesting(
                                    onDone: (double transferRate, SpeedUnit unit) {
                                      setState(() {
                                        downloadRate = transferRate;
                                        protectGauge(downloadRate);
                                        unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                                        downloadProgress = '100';
                                        displayPer = 100.0;
                                      });
                                      internetSpeedTest.startUploadTesting(
                                        onDone: (double transferRate, SpeedUnit unit) {
                                          setState(() {
                                            uploadRate = transferRate;
                                            uploadRate = uploadRate * 10;
                                            protectGauge(uploadRate);
                                            unitText =
                                            unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                                            uploadProgress = '100';
                                            displayPer = 100.0;
                                            isTesting = false;
                                            // Display speed test results
                                            // Alert(
                                            //   context: context,
                                            //   style: alertStyle,
                                            //   type: AlertType.info,
                                            //   title: "TEST RESULTS",
                                            //   desc: 'Download Speed: ' +
                                            //       downloadRate.toStringAsFixed(2) +
                                            //       ' $unitText\nUpload Speed: ' +
                                            //       uploadRate.toStringAsFixed(2) +
                                            //       ' $unitText',
                                            //   buttons: [
                                            //     DialogButton(
                                            //       child: Text(
                                            //         "OK",
                                            //         style: TextStyle(
                                            //             color: Colors.white, fontSize: 20),
                                            //       ),
                                            //       onPressed: () => Navigator.pop(context),
                                            //       color: Color.fromRGBO(114, 137, 218, 1.0),
                                            //       radius: BorderRadius.circular(0.0),
                                            //     ),
                                            //   ],
                                            // ).show();
                                          });
                                        },
                                        onProgress: (double percent, double transferRate,
                                            SpeedUnit unit) {
                                          setState(() {
                                            uploadRate = transferRate;
                                            uploadRate = uploadRate * 10;
                                            protectGauge(uploadRate);
                                            unitText =
                                            unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                                            uploadProgress = percent.toStringAsFixed(2);
                                            displayPer = percent;
                                          });
                                        },
                                        onError:
                                            (String errorMessage, String speedTestError) {
                                          SnackBar(
                                              content: Text("Upload test failed! Please check your internet connection."));
                                          setState(() {
                                            isTesting = false;
                                          });
                                        },
                                        testServer: uploadServer,
                                        fileSize: 20000000,
                                      );
                                    },
                                    onProgress: (double percent, double transferRate,
                                        SpeedUnit unit) {
                                      setState(() {
                                        downloadRate = transferRate;
                                        protectGauge(downloadRate);
                                        unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                                        downloadProgress = percent.toStringAsFixed(2);
                                        displayPer = percent;
                                      });
                                    },
                                    onError: (String errorMessage, String speedTestError) {
                                      SnackBar(
                                          content: Text('Download test failed! Please check your internet connection.'),);
                                      setState(() {
                                        isTesting = false;
                                      });
                                    },
                                    testServer: downloadServer,
                                    fileSize: 20000000,
                                  );
                                }
                              },
                            ),
                      ],
                    ),
                    ],
                    ),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 50,
                        colors: [
                          Colors.white.withOpacity(0.20),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                    // child: Colors.,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("DOWNLOAD",style: GoogleFonts.fredokaOne(textStyle: TextStyle(color: Colors.green[500],fontWeight: FontWeight.bold,fontSize: 25),)),
                            Text(downloadRate.toStringAsFixed(2),style: GoogleFonts.prompt(textStyle: TextStyle(color: Colors.lightGreenAccent,fontSize: 40),),),
                            Text("$unitText",style: GoogleFonts.fredokaOne(textStyle: TextStyle(color: Colors.green,fontSize: 20),),)
                          ],),

                        Column(children: [
                          Text("UPLOAD",style: GoogleFonts.fredokaOne(textStyle: TextStyle(color: Colors.green[500],fontWeight: FontWeight.bold,fontSize: 25),)),
                          Text(uploadRate.toStringAsFixed(2),style: GoogleFonts.prompt(textStyle: TextStyle(color: Colors.lightGreenAccent,fontSize: 40),),),
                          Text("$unitText",style: GoogleFonts.fredokaOne(textStyle: TextStyle(color: Colors.green,fontSize: 20),),)
                        ],),
                      ],
                    ),
                    SizedBox(height: 15,),
                    Center(child: progressBar.showBar(displayPer,context)),
                  ],
                )
              ],
            ):
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  child: Container(
                    width: 500,
                    height: 550,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("NETWORK SPEED TEST",style: GoogleFonts.russoOne(textStyle: TextStyle(
                            fontSize: 30.0, color: Colors.white,))),
                        SizedBox(height: 20,),
                        SfRadialGauge(
                            title: GaugeTitle(
                                text: "",),
                            axes: <RadialAxis>[
                              RadialAxis(
                                  minimum: 0,
                                  maximum: 100,
                                  axisLabelStyle: GaugeTextStyle(
                                    color: txtCol,
                                  ),
                                  ranges: <GaugeRange>[
                                    GaugeRange(
                                        startValue: 0,
                                        endValue: 50,
                                        color: gaugeRange1,
                                        startWidth: 10,
                                        endWidth: 10),
                                    GaugeRange(
                                        startValue: 50,
                                        endValue: 100,
                                        color: gaugeRange2,
                                        startWidth: 10,
                                        endWidth: 10),
                                    GaugeRange(
                                        startValue: 100,
                                        endValue: 150,
                                        color: gaugeRange1,
                                        startWidth: 10,
                                        endWidth: 10)
                                  ],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(
                                      value: displayRate,
                                      enableAnimation: true,
                                      needleColor: needleCol,
                                    )
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Container(
                                          padding: const EdgeInsets.only(top: 120),
                                          child: Text(
                                            displayRate.toStringAsFixed(2) + ' ' + unitText,
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: txtCol,
                                            ),
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.5)
                                  ])
                            ]),
                            SizedBox(height: 20,),
                            RaisedButton(
                              child: Text(" START TEST ",style: GoogleFonts.varela(textStyle: TextStyle(fontSize: 25),)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80.0)),
                              padding: const EdgeInsets.all(10.0),

                              color: Colors.green,
                              textColor: txtCol,
                              onPressed: () {
                                if (!isTesting) {
                                  setState(() {
                                    isTesting = true;
                                  });
                                  internetSpeedTest.startDownloadTesting(
                                    onDone: (double transferRate, SpeedUnit unit) {
                                      setState(() {
                                        downloadRate = transferRate;
                                        protectGauge(downloadRate);
                                        unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                                        downloadProgress = '100';
                                        displayPer = 100.0;
                                      });
                                      internetSpeedTest.startUploadTesting(
                                        onDone: (double transferRate, SpeedUnit unit) {
                                          setState(() {
                                            uploadRate = transferRate;
                                            uploadRate = uploadRate * 10;
                                            protectGauge(uploadRate);
                                            unitText =
                                            unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                                            uploadProgress = '100';
                                            displayPer = 100.0;
                                            isTesting = false;
                                            // Display speed test results
                                            // Alert(
                                            //   context: context,
                                            //   style: alertStyle,
                                            //   type: AlertType.info,
                                            //   title: "TEST RESULTS",
                                            //   desc: 'Download Speed: ' +
                                            //       downloadRate.toStringAsFixed(2) +
                                            //       ' $unitText\nUpload Speed: ' +
                                            //       uploadRate.toStringAsFixed(2) +
                                            //       ' $unitText',
                                            //   buttons: [
                                            //     DialogButton(
                                            //       child: Text(
                                            //         "OK",
                                            //         style: TextStyle(
                                            //             color: Colors.white, fontSize: 20),
                                            //       ),
                                            //       onPressed: () => Navigator.pop(context),
                                            //       color: Color.fromRGBO(114, 137, 218, 1.0),
                                            //       radius: BorderRadius.circular(0.0),
                                            //     ),
                                            //   ],
                                            // ).show();
                                          });
                                        },
                                        onProgress: (double percent, double transferRate,
                                            SpeedUnit unit) {
                                          setState(() {
                                            uploadRate = transferRate;
                                            uploadRate = uploadRate * 10;
                                            protectGauge(uploadRate);
                                            unitText =
                                            unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                                            uploadProgress = percent.toStringAsFixed(2);
                                            displayPer = percent;
                                          });
                                        },
                                        onError:
                                            (String errorMessage, String speedTestError) {
                                          SnackBar(
                                              content: Text("Upload test failed! Please check your internet connection."));
                                          setState(() {
                                            isTesting = false;
                                          });
                                        },
                                        testServer: uploadServer,
                                        fileSize: 20000000,
                                      );
                                    },
                                    onProgress: (double percent, double transferRate,
                                        SpeedUnit unit) {
                                      setState(() {
                                        downloadRate = transferRate;
                                        protectGauge(downloadRate);
                                        unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
                                        downloadProgress = percent.toStringAsFixed(2);
                                        displayPer = percent;
                                      });
                                    },
                                    onError: (String errorMessage, String speedTestError) {
                                      SnackBar(
                                        content: Text('Download test failed! Please check your internet connection.'),);
                                      setState(() {
                                        isTesting = false;
                                      });
                                    },
                                    testServer: downloadServer,
                                    fileSize: 20000000,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 50,
                        colors: [
                          Colors.white.withOpacity(0.20),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                    // child: Colors.,
                  ),
                ),
                Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text("DOWNLOAD",style: GoogleFonts.fredokaOne(textStyle: TextStyle(color: Colors.green[500],fontWeight: FontWeight.bold,fontSize: 40),)),
                          Text(downloadRate.toStringAsFixed(2),style: GoogleFonts.prompt(textStyle: TextStyle(color: Colors.lightGreenAccent,fontSize: 70),),),
                          Text("$unitText",style: GoogleFonts.fredokaOne(textStyle: TextStyle(color: Colors.green,fontSize: 35),),)
                        ],),

                        Column(children: [
                          Text("UPLOAD",style: GoogleFonts.fredokaOne(textStyle: TextStyle(color: Colors.green[500],fontWeight: FontWeight.bold,fontSize: 40),)),
                          Text(uploadRate.toStringAsFixed(2),style: GoogleFonts.prompt(textStyle: TextStyle(color: Colors.lightGreenAccent,fontSize: 70),),),
                          Text("$unitText",style: GoogleFonts.fredokaOne(textStyle: TextStyle(color: Colors.green,fontSize: 35),),)
                        ],),
                        Container(child: progressBar.showBar(displayPer,context))
                      ],
                    ),
                  ],
            ),
          ),
        ),
      ),
    );
  }
}

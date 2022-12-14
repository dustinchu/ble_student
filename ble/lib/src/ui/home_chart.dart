import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/status/home_ble_chart_status.dart';
import 'package:provider/provider.dart';

class _HomeLineChart extends StatelessWidget {
  _HomeLineChart({required this.isShowingMainData, required this.deviceId});

  final bool isShowingMainData;
  final String deviceId;

  List<Color> chartColor = [
    Color(0xFF7F59FF),
    Color(0xFFC5A1FF),
    Color(0xFF2DBFD2),
    Color(0xFF69B1FB),
    Color(0xFFFF7373),
    Color(0xFFFFF2A7),
    Color(0xFFE5CB27),
    Color(0xFF75E16E),
    Color(0xFFCD3DA9),
    Color(0xFFC63D59),
  ];
  @override
  Widget build(BuildContext context) {
    HomeBleChartStatus bleChartStatus =
        Provider.of<HomeBleChartStatus>(context);

    LineChartBarData getLineChartBarData(int index) {
      return LineChartBarData(
        show: bleChartStatus.type[deviceId] == 1601
            ? bleChartStatus.six[deviceId]![index] != null &&
                bleChartStatus.six[deviceId]![index].isNotEmpty
            : bleChartStatus.type[deviceId] == 1605
                ? bleChartStatus.acc[deviceId]![index] != null &&
                    bleChartStatus.acc[deviceId]![index].isNotEmpty
                : bleChartStatus.type[deviceId] == 1606
                    ? bleChartStatus.gyro[deviceId]![index] != null &&
                        bleChartStatus.gyro[deviceId]![index].isNotEmpty
                    : bleChartStatus.type[deviceId] == 1602
                        ? bleChartStatus.dmpa[deviceId]![index] != null &&
                            bleChartStatus.dmpa[deviceId]![index].isNotEmpty
                        : bleChartStatus.dmpg[deviceId]![index] != null &&
                            bleChartStatus.dmpg[deviceId]![index].isNotEmpty,
        isCurved: true,
        curveSmoothness: 0,
        color: chartColor[index],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        // spots: bleChartStatus.type[deviceId] == 1601
        //     ? bleChartStatus.six[deviceId] == null
        //         ? [const FlSpot(0, 0)]
        //         : bleChartStatus.six[deviceId]![index]
        //     : bleChartStatus.type[deviceId] == 1605
        //         ? bleChartStatus.dmp[deviceId] == null
        //             ? [const FlSpot(0, 0)]
        //             : bleChartStatus.dmp[deviceId]![index]
        //         : bleChartStatus.gyro[deviceId] == null
        //             ? [const FlSpot(0, 0)]
        //             : bleChartStatus.gyro[deviceId]![index],
        spots: bleChartStatus.type[deviceId] == 1601
            ? bleChartStatus.six[deviceId]!.isEmpty
                ? [const FlSpot(0, 0)]
                : bleChartStatus.six[deviceId]![index]
            : bleChartStatus.type[deviceId] == 1605
                ? bleChartStatus.acc[deviceId]!.isEmpty
                    ? [const FlSpot(0, 0)]
                    : bleChartStatus.acc[deviceId]![index]
                : bleChartStatus.type[deviceId] == 1606
                    ? bleChartStatus.gyro.isEmpty
                        ? [const FlSpot(0, 0)]
                        : bleChartStatus.gyro[deviceId]![index]
                    : bleChartStatus.type[deviceId] == 1602
                        ? bleChartStatus.dmpa[deviceId]!.isEmpty
                            ? [const FlSpot(0, 0)]
                            : bleChartStatus.dmpa[deviceId]![index]
                        : bleChartStatus.dmpg[deviceId]!.isEmpty
                            ? [const FlSpot(0, 0)]
                            : bleChartStatus.dmpg[deviceId]![index],
      );
    }

    List<LineChartBarData> lineBarsData2(int lineCount) {
      List<LineChartBarData> d = [];

      for (var i = 0; i < lineCount; i++) {
        d.add(getLineChartBarData(i));
      }
      return d;
    }

    LineChartData sampleData2 = LineChartData(
      lineTouchData: lineTouchData2,
      gridData: gridData,
      titlesData: titlesData2,
      borderData: borderData,
      lineBarsData: bleChartStatus.type[deviceId] == 1601
          ? bleChartStatus.six.isEmpty
              ? null
              : lineBarsData2(6)
          : bleChartStatus.type[deviceId] == 1605
              ? bleChartStatus.acc.isEmpty
                  ? null
                  : lineBarsData2(3)
              : bleChartStatus.type[deviceId] == 1606
                  ? bleChartStatus.gyro.isEmpty
                      ? null
                      : lineBarsData2(3)
                  : bleChartStatus.type[deviceId] == 1602
                      ? bleChartStatus.dmpa.isEmpty
                          ? null
                          : lineBarsData2(6)
                      : bleChartStatus.dmpg.isEmpty
                          ? null
                          : lineBarsData2(3),
      minX: bleChartStatus.minx[deviceId]!.toDouble(),
      maxX: bleChartStatus.maxx[deviceId]!.toDouble(),
      maxY: bleChartStatus.maxy[deviceId]!.toDouble(),
      minY: bleChartStatus.miny[deviceId]!.toDouble(),
    );
    // LateInitializationError: Field 'mostLeftSpot' has not been initialized.
// milliseconds
    return LineChart(
      sampleData2,
      swapAnimationDuration: const Duration(milliseconds: 25),
    );
  }

  LineTouchData get lineTouchData2 => LineTouchData(
        enabled: false,
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        show: false,
      );

  // Widget leftTitleWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     color: Colors.white30,
  //     fontWeight: FontWeight.bold,
  //     fontSize: 14,
  //   );
  //   String text;
  //   switch (value.toInt()) {
  //     case 0:
  //       text = '0';
  //       break;
  //     case 50:
  //       text = '50';
  //       break;
  //     case 100:
  //       text = '100';
  //       break;
  //     case 150:
  //       text = '150';
  //       break;
  //     case 200:
  //       text = '200';
  //       break;
  //     case 250:
  //       text = '250';
  //       break;
  //     case 300:
  //       text = '300';
  //       break;
  //     case 350:
  //       text = '350';
  //       break;
  //     case 400:
  //       text = '400';
  //       break;
  //     case 450:
  //       text = '450';
  //       break;
  //     case 500:
  //       text = '500';
  //       break;
  //     default:
  //       return Container();
  //   }

  //   return Text(text, style: style, textAlign: TextAlign.center);
  // }

  // SideTitles leftTitles() => SideTitles(
  //       getTitlesWidget: leftTitleWidgets,
  //       showTitles: true,
  //       interval: 1,
  //       reservedSize: 40,
  //     );

  FlGridData get gridData => FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: const Color(0xff4af699),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 1.5),
          FlSpot(5, 1.4),
          FlSpot(7, 3.4),
          FlSpot(10, 2),
          FlSpot(12, 2.2),
          FlSpot(13, 1.8),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        color: const Color(0xffaa4cfc),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
          color: const Color(0x00aa4cfc),
        ),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
          FlSpot(10, 2.8),
          FlSpot(12, 2.6),
          FlSpot(13, 3.9),
        ],
      );

  LineChartBarData get lineChartBarData1_3 => LineChartBarData(
        isCurved: true,
        color: const Color(0xff27b6fc),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 2.8),
          FlSpot(3, 1.9),
          FlSpot(6, 3),
          FlSpot(10, 1.3),
          FlSpot(13, 2.5),
        ],
      );
}

class HomeLineChartSample1 extends StatefulWidget {
  HomeLineChartSample1({Key? key, required this.deviceId}) : super(key: key);
  String deviceId;
  @override
  State<StatefulWidget> createState() => HomeLineChartSample1State();
}

class HomeLineChartSample1State extends State<HomeLineChartSample1> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HomeBleChartStatus bleChartStatus =
        Provider.of<HomeBleChartStatus>(context);
    return Center(
      child: AspectRatio(
        aspectRatio: 2,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(18)),
            //   gradient: LinearGradient(
            //     colors: [
            //  Theme.of(context).
            //       Color(0xFF05040F),
            //       Color(0xFF0A0725),
            //     ],
            //     begin: Alignment.bottomCenter,
            //     end: Alignment.topCenter,
            //   ),
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0, left: 6.0),
                      child: _HomeLineChart(
                        isShowingMainData: false,
                        deviceId: widget.deviceId,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: Text((bleChartStatus.type[widget.deviceId] ==
                                  1601 ||
                              bleChartStatus.type[widget.deviceId] == 1605 ||
                              bleChartStatus.type[widget.deviceId] == 1606)
                          ? ""
                          : bleChartStatus.showData[widget.deviceId] ?? ""),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

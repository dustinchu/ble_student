import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_chart_status.dart';
import 'package:provider/provider.dart';

class _LineChart extends StatelessWidget {
  _LineChart({required this.isShowingMainData});

  final bool isShowingMainData;

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
    BleChartStatus bleChartStatus = Provider.of<BleChartStatus>(context);

    LineChartBarData getLineChartBarData(int index) {
      return LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: chartColor[index],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: bleChartStatus.data.isEmpty ? null : bleChartStatus.data[index],
      );
    }

    // print("data1======${bleChartStatus.data[1]}");
    // LineChartBarData lineChartBarData2_1 = LineChartBarData(
    //   isCurved: true,
    //   curveSmoothness: 0,
    //   color: chartColor[0],
    //   barWidth: 1,
    //   isStrokeCapRound: true,
    //   dotData: FlDotData(show: false),
    //   belowBarData: BarAreaData(show: false),
    //   spots: bleChartStatus.data.isEmpty ? null : bleChartStatus.data[0],
    // );

    // LineChartBarData lineChartBarData2_2 = LineChartBarData(
    //   isCurved: true,
    //   curveSmoothness: 0,
    //   color: chartColor[1],
    //   barWidth: 1,
    //   isStrokeCapRound: true,
    //   dotData: FlDotData(show: false),
    //   belowBarData: BarAreaData(show: false),
    //   spots: bleChartStatus.data.isEmpty ? null : bleChartStatus.data[1],
    // );

    // LineChartBarData lineChartBarData2_3 = LineChartBarData(
    //   isCurved: true,
    //   curveSmoothness: 0,
    //   color: chartColor[2],
    //   barWidth: 1,
    //   isStrokeCapRound: true,
    //   dotData: FlDotData(show: false),
    //   belowBarData: BarAreaData(show: false),
    //   spots: bleChartStatus.data.isEmpty ? null : bleChartStatus.data[2],
    // );
    List<LineChartBarData> lineBarsData2() {
      List<LineChartBarData> d = [];
      for (var i = 0; i < bleChartStatus.lineCount; i++) {
        d.add(getLineChartBarData(i));
      }
      return d;
    }

    LineChartData sampleData2 = LineChartData(
      lineTouchData: lineTouchData2,
      gridData: gridData,
      titlesData: titlesData2,
      borderData: borderData,
      lineBarsData: bleChartStatus.data.isEmpty ? null : lineBarsData2(),
      minX: bleChartStatus.minx.toDouble(),
      maxX: bleChartStatus.maxx.toDouble(),
      maxY: bleChartStatus.maxy.toDouble(),
      minY: bleChartStatus.miny.toDouble(),
    );
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
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
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
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.white30, width: 1),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
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

class LineChartSample1 extends StatefulWidget {
  const LineChartSample1({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BleChartStatus bleChartStatus = Provider.of<BleChartStatus>(context);
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
                      child: (bleChartStatus.type == 1602 ||
                              bleChartStatus.type == 1604)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("qw: ${bleChartStatus.qw}"),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text("qx: ${bleChartStatus.qx}"),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text("qy: ${bleChartStatus.qy}"),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text("qz: ${bleChartStatus.qz}"),
                                  ],
                                ),
                              ],
                            )
                          : _LineChart(isShowingMainData: false),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
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

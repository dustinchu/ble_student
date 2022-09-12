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

    LineChartBarData getLineChartBarData(int index, int len) {
      // print("---------chart--------${bleChartStatus.data[index]}");
      return LineChartBarData(
        show: bleChartStatus.type == 1601
            ? bleChartStatus.six[index] != null &&
                bleChartStatus.six[index].isNotEmpty
            : bleChartStatus.type == 1605
                ? bleChartStatus.acc[index] != null &&
                    bleChartStatus.acc[index].isNotEmpty
                : bleChartStatus.type == 1606
                    ? bleChartStatus.gyro[index] != null &&
                        bleChartStatus.gyro[index].isNotEmpty
                    : bleChartStatus.type == 1602
                        ? bleChartStatus.dmpa[index] != null &&
                            bleChartStatus.dmpa[index].isNotEmpty
                        : bleChartStatus.dmpg[index] != null &&
                            bleChartStatus.dmpg[index].isNotEmpty,
        isCurved: true,
        curveSmoothness: 0,
        color: chartColor[index],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: bleChartStatus.type == 1601
            ? bleChartStatus.six.isEmpty
                ? [const FlSpot(0, 0)]
                : bleChartStatus.six[index]
            : bleChartStatus.type == 1605
                ? bleChartStatus.acc.isEmpty
                    ? [const FlSpot(0, 0)]
                    : bleChartStatus.acc[index]
                : bleChartStatus.type == 1606
                    ? bleChartStatus.gyro.isEmpty
                        ? [const FlSpot(0, 0)]
                        : bleChartStatus.gyro[index]
                    : bleChartStatus.type == 1602
                        ? bleChartStatus.dmpa.isEmpty
                            ? [const FlSpot(0, 0)]
                            : bleChartStatus.dmpa[index]
                        : bleChartStatus.dmpg.isEmpty
                            ? [const FlSpot(0, 0)]
                            : bleChartStatus.dmpg[index],
      );
    }

    List<LineChartBarData> lineBarsData2() {
      List<LineChartBarData> d = [];
      for (var i = 0; i < bleChartStatus.lineCount; i++) {
        d.add(getLineChartBarData(i, bleChartStatus.lineCount));
      }
      return d;
    }

    LineChartData sampleData2 = LineChartData(
      lineTouchData: lineTouchData2,
      gridData: gridData,
      titlesData: titlesData2,
      borderData: borderData,
      // lineBarsData: bleChartStatus.data.isEmpty ? null : lineBarsData2(),
      lineBarsData: lineBarsData2(),
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
        show: false,
      );

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
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                bleChartStatus.changeSavaStatus();
                              },
                              icon: Icon(
                                Icons.save_alt_outlined,
                                color: bleChartStatus.saveStatus
                                    ? Colors.white
                                    : Colors.white38,
                              )),
                          SizedBox(
                            width: 10,
                          )
                        ]),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0, left: 6.0),
                      child: _LineChart(isShowingMainData: false),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: Text((bleChartStatus.type == 1601 ||
                              bleChartStatus.type == 1605 ||
                              bleChartStatus.type == 1606)
                          ? ""
                          : bleChartStatus.showData),
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

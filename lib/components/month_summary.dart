import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/datetime/date_time.dart';
import '../constants/colors.dart';

class MonthlySummary extends StatelessWidget {
  final Map<DateTime, int>? datasets;
  final String startdate;

  const MonthlySummary(
      {super.key, required this.datasets, required this.startdate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
            )
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: HeatMap(
              startDate: createDateTimeObject(startdate),
              endDate: DateTime.now(),
              datasets: datasets,
              colorMode: ColorMode.color,
              defaultColor: const Color.fromARGB(255, 58, 52, 52),
              textColor: Colors.white,
              showText: false,
              scrollable: true,
              showColorTip: false,
              size: 15,
              colorsets: {
                1: color1,
                2: color2,
                3: color3,
                4: color4,
                5: color5,
                6: color6,
                7: color7,
                8: color8,
                9: color9,
                10: color10,
              },
              onClick: (value) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(value.toString())));
              },
            ),
          )),
    );
  }
}

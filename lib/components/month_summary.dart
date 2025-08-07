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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(
            "Progress",
            style: TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.w500, 
                fontSize: 30,
                letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 100,),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Center(
            child: HeatMap(
              startDate: createDateTimeObject(startdate),
              endDate: DateTime.now(),
              datasets: datasets,
              colorMode: ColorMode.color,
              margin: const EdgeInsets.all(5),
              defaultColor: Colors.grey,
              textColor: backgroundColor,
              showText: true,
              scrollable: true,
              showColorTip: false,
              size: 25,
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
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(value.toString())));
              },
            ),
          ),
        ),
      ],
    );
  }
}

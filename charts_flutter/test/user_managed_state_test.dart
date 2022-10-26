// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selection can be set programmatically',
      (WidgetTester tester) async {
    final onTapSelection = charts.UserManagedSelectionModel<String>.fromConfig(
        selectedDataConfig: [
          charts.SeriesDatumConfig<String>('Sales', '2016')
        ]);

    charts.SelectionModel<String>? currentSelectionModel;

    void selectionChangedListener(charts.SelectionModel<String> model) {
      currentSelectionModel = model;
    }

    final testChart = TestChart(selectionChangedListener, onTapSelection);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: testChart,
      ),
    );

    expect(currentSelectionModel, isNull);

    await tester.tap(find.byType(charts.BarChart));

    await tester.pump();

    expect(currentSelectionModel, isNotNull);
    expect(currentSelectionModel!.selectedDatum, hasLength(1));
    final selectedDatum =
        currentSelectionModel!.selectedDatum.first.datum as OrdinalSales;
    expect(selectedDatum.year, equals('2016'));
    expect(selectedDatum.sales, equals(100));
    expect(currentSelectionModel!.selectedSeries, hasLength(1));
    expect(currentSelectionModel!.selectedSeries.first.id, equals('Sales'));
  });
}

class TestChart extends StatefulWidget {
  final charts.SelectionModelListener<String> selectionChangedListener;
  final charts.UserManagedSelectionModel<String> onTapSelection;

  TestChart(this.selectionChangedListener, this.onTapSelection);

  @override
  TestChartState createState() {
    return TestChartState(selectionChangedListener, onTapSelection);
  }
}

class TestChartState extends State<TestChart> {
  final charts.SelectionModelListener<String> selectionChangedListener;
  final charts.UserManagedSelectionModel<String> onTapSelection;

  final seriesList = _createSampleData();
  final myState = charts.UserManagedState<String>();

  TestChartState(this.selectionChangedListener, this.onTapSelection);

  @override
  Widget build(BuildContext context) {
    final chart = charts.BarChart(
      seriesList,
      userManagedState: myState,
      selectionModels: [
        charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: widget.selectionChangedListener)
      ],
      // Disable animation and gesture for testing.
      animate: false, //widget.animate,
      defaultInteractions: false,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(child: chart, onTap: handleOnTap),
    );
  }

  void handleOnTap() {
    setState(() {
      myState.selectionModels[charts.SelectionModelType.info] = onTapSelection;
    });
  }
}

/// Create one series with sample hard coded data.
List<charts.Series<OrdinalSales, String>> _createSampleData() {
  final data = [
    OrdinalSales('2014', 5),
    OrdinalSales('2015', 25),
    OrdinalSales('2016', 100),
    OrdinalSales('2017', 75),
  ];

  return [
    charts.Series<OrdinalSales, String>(
      id: 'Sales',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (OrdinalSales sales, _) => sales.year,
      measureFn: (OrdinalSales sales, _) => sales.sales,
      data: data,
    )
  ];
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

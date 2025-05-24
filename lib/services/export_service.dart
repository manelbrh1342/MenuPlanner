import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:menu_planner/models/daily_menu.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';

class ExportService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<File> exportDailyToPdf(DailyMenu menu) async {
    final pdf = pw.Document();

    // Define styles
    final headerStyle = pw.TextStyle(
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue800,
    );


    final mealTypeStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );

    final mealItemStyle = pw.TextStyle(
      fontSize: 14,
      color: PdfColors.grey800,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 40,
          marginRight: 40,
          marginTop: 30,
          marginBottom: 30,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Daily Menu - ${menu.dayName}', style: headerStyle),
              pw.SizedBox(height: 8),
              pw.Text(menu.formattedDate, 
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.blue200),
              pw.SizedBox(height: 20),
              
              _buildCompleteMealSection('Lunch', menu, mealTypeStyle, mealItemStyle),
              pw.SizedBox(height: 25),
              
              _buildCompleteMealSection('Dinner', menu, mealTypeStyle, mealItemStyle),
            ],
          );
        },
      ),
    );

    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/menu_${menu.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> exportWeeklyToPdf(Map<String, DailyMenu> weeklyMenu) async {
    final sortedDays = weeklyMenu.entries.toList()
      ..sort((a, b) => DateTime.parse(a.key).compareTo(DateTime.parse(b.key)));

    final pdf = pw.Document();
    const daysPerPage = 3;

    // Define styles
    final headerStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue800,
    );

    final dayHeaderStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue600,
    );

    final mealTypeStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );

    final mealItemStyle = pw.TextStyle(
      fontSize: 12,
      color: PdfColors.grey800,
    );

    for (int i = 0; i < sortedDays.length; i += daysPerPage) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (i == 0) pw.Text('Weekly Menu Plan', style: headerStyle),
                if (i == 0) pw.SizedBox(height: 15),
                if (i == 0) pw.Divider(thickness: 2, color: PdfColors.blue200),
                if (i == 0) pw.SizedBox(height: 20),
                
                ...sortedDays
                    .sublist(i, math.min(i + daysPerPage, sortedDays.length))
                    .map((entry) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${_getCorrectDayName(DateTime.parse(entry.key))}, ${entry.value.formattedDate}',
                              style: dayHeaderStyle,
                            ),
                            pw.SizedBox(height: 10),
                            
                            _buildCompleteMealSection('Lunch', entry.value, mealTypeStyle, mealItemStyle),
                            pw.SizedBox(height: 15),
                            
                            _buildCompleteMealSection('Dinner', entry.value, mealTypeStyle, mealItemStyle),
                            
                            if (entry != sortedDays[math.min(i + daysPerPage - 1, sortedDays.length - 1)])
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 15),
                                child: pw.Divider(color: PdfColors.grey300),
                              ),
                          ],
                        )),
              ],
            );
          },
        ),
      );
    }

    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/weekly_menu_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildCompleteMealSection(
    String mealType, 
    DailyMenu day, 
    pw.TextStyle headerStyle, 
    pw.TextStyle contentStyle,
  ) {
    final isLunch = mealType == 'Lunch';
    final starter = isLunch ? day.lunchStarter : day.dinnerStarter;
    final main = isLunch ? day.lunchMain : day.dinnerMain;
    final dessert = isLunch ? day.lunchDessert : day.dinnerDessert;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(mealType, style: headerStyle),
        pw.SizedBox(height: 8),
        
        if (starter != null) ...[
          pw.Text('Starter', style: contentStyle.copyWith(fontWeight: pw.FontWeight.bold)),
          pw.Text(starter.name, style: contentStyle),
          if (starter.description.isNotEmpty)
            pw.Text(starter.description, style: contentStyle.copyWith(fontSize: 10)),
          pw.SizedBox(height: 8),
        ],
        
        if (main != null) ...[
          pw.Text('Main Course', style: contentStyle.copyWith(fontWeight: pw.FontWeight.bold)),
          pw.Text(main.name, style: contentStyle),
          // ignore: unnecessary_null_comparison
          if (main.description != null && main.description.isNotEmpty)
            pw.Text(main.description, style: contentStyle.copyWith(fontSize: 10)),
          pw.SizedBox(height: 8),
        ],
        
        if (dessert != null) ...[
          pw.Text('Dessert', style: contentStyle.copyWith(fontWeight: pw.FontWeight.bold)),
          pw.Text(dessert.name, style: contentStyle),
          if (dessert.description.isNotEmpty)
            pw.Text(dessert.description, style: contentStyle.copyWith(fontSize: 10)),
        ],
      ],
    );
  }

  String _getCorrectDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  Future<File> exportDailyToImage(DailyMenu menu) async {
    final widget = MediaQuery(
      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
              child: _buildDayWidget(menu, true),
            ),
          ),
        ),
      ),
    );

    final image = await _screenshotController.captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 200),
      pixelRatio: 2.0,
    );

    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/menu_${menu.id}.png');
    await file.writeAsBytes(image);
    return file;
  }

  Future<List<File>> exportWeeklyToImage(Map<String, DailyMenu> weeklyMenu) async {
    final sortedDays = weeklyMenu.entries.toList()
      ..sort((a, b) => DateTime.parse(a.key).compareTo(DateTime.parse(b.key)));

    const daysPerImage = 2;
    final imageFiles = <File>[];

    final mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    for (int i = 0; i < sortedDays.length; i += daysPerImage) {
      final widget = MediaQuery(
        data: mediaQueryData,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                width: mediaQueryData.size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (i == 0) 
                      const Text(
                        'Weekly Menu',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    if (i == 0) const SizedBox(height: 20),
                    if (i == 0) const Divider(thickness: 2),
                    if (i == 0) const SizedBox(height: 20),
                    
                    ...sortedDays
                        .sublist(i, math.min(i + daysPerImage, sortedDays.length))
                        .map((entry) => Column(
                              children: [
                                _buildDayWidget(entry.value, false),
                                if (entry != sortedDays[math.min(i + daysPerImage - 1, sortedDays.length - 1)])
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Divider(thickness: 1),
                                  ),
                              ],
                            )),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final image = await _screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 200),
        pixelRatio: 2.0,
      );

      final tempDir = Directory.systemTemp;
      final file = File(
        '${tempDir.path}/weekly_menu_${DateFormat('yyyy-MM-dd').format(DateTime.now())}_page${(i ~/ daysPerImage) + 1}.png');
      await file.writeAsBytes(image);
      imageFiles.add(file);
    }

    return imageFiles;
  }

  Widget _buildDayWidget(DailyMenu day, bool isDaily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isDaily ? '${day.dayName}' : '${day.dayName}, ${day.formattedDate}',
          style: TextStyle(
            fontSize: isDaily ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        if (isDaily) Text(day.formattedDate, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 15),
        
        _buildMealWidget('Lunch', day.lunchStarter, day.lunchMain, day.lunchDessert),
        const SizedBox(height: 20),
        
        _buildMealWidget('Dinner', day.dinnerStarter, day.dinnerMain, day.dinnerDessert),
      ],
    );
  }

  Widget _buildMealWidget(String title, Meal? starter, Meal? main, Meal? dessert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        if (starter != null) ...[
          const Text('Starter', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(starter.name),
          if (starter.description.isNotEmpty)
            Text(
              starter.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const SizedBox(height: 8),
        ],
        
        if (main != null) ...[
          const Text('Main Course', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(main.name),
          if (main.description.isNotEmpty)
            Text(
              main.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const SizedBox(height: 8),
        ],
        
        if (dessert != null) ...[
          const Text('Dessert', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(dessert.name),
          if (dessert.description.isNotEmpty)
            Text(
              dessert.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ],
    );
  }
}
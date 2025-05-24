import 'package:flutter/material.dart';
import 'package:menu_planner/services/export_service.dart';
import 'package:menu_planner/providers/menu_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class Exportpage extends StatefulWidget {
  const Exportpage({super.key});

  @override
  State<Exportpage> createState() => _ExportpageState();
}

class _ExportpageState extends State<Exportpage> {
  final _exportService = ExportService();
  bool _isExporting = false;

  Future<void> _exportAsPdf() async {
    setState(() => _isExporting = true);
    try {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      final weeklyMenu = menuProvider.weeklyMenu;
      
      // Export the weekly menu as PDF
      final file = await _exportService.exportWeeklyToPdf(weeklyMenu);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Weekly Menu',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu exported successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error exporting as PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting menu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportAsImage() async {
  setState(() => _isExporting = true);
  try {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final weeklyMenu = menuProvider.weeklyMenu;
    
    // Get list of image files
    final imageFiles = await _exportService.exportWeeklyToImage(weeklyMenu);
    
    // Convert all files to XFiles and share
    await Share.shareXFiles(
      imageFiles.map((file) => XFile(file.path)).toList(),
      text: 'Weekly Menu',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu exported successfully')),
      );
    }
  } catch (e) {
    debugPrint('Error exporting as image: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting menu: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isExporting = false);
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.close, color: Colors.yellow, size: 24),
              ),
            ),
            const Text(
              "Export the \nweekly menu!",
              style: TextStyle(
                color: Color(0xFF02197D),
                fontWeight: FontWeight.w500,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Choose your preferred format.",
              style: TextStyle(color: Color(0xFF949494), fontSize: 12),
            ),
            const SizedBox(height: 20),
            _exportOption(
              "assets/Icons/ExportPDF.png",
              "Export as PDF",
              _isExporting ? null : _exportAsPdf,
            ),
            const SizedBox(height: 10),
            _exportOption(
              "assets/Icons/ExportPicture.png",
              "Export as Picture",
              _isExporting ? null : _exportAsImage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportOption(String imagePath, String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(imagePath),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(color: Color(0xFF69696B), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
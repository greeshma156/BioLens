import 'dart:typed_data'; // Required for handling bytes (Web/Mobile/Desktop)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const BioLensApp());
}

class BioLensApp extends StatelessWidget {
  const BioLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioLens AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const BioLensHome(),
    );
  }
}

class BioLensHome extends StatefulWidget {
  const BioLensHome({super.key});

  @override
  State<BioLensHome> createState() => _BioLensHomeState();
}

class _BioLensHomeState extends State<BioLensHome> {
  Uint8List? _imageData; // Holds the image bytes in memory
  String _statusMessage = "Scan a species to begin";
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // source: ImageSource.camera will open the camera on phones
      // On Windows/Web, it will default to a file picker to simulate the capture
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080, // Optimizing image size for AI processing
      );

      if (photo != null) {
        // Read the image data into memory immediately
        final Uint8List bytes = await photo.readAsBytes();

        setState(() {
          _imageData = bytes;
          _isAnalyzing = true;
          _statusMessage = "Analyzing with AI...";
        });

        // --- THE AI BRAIN (Coming Next!) ---
        // This simulates the network delay to the AI server
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isAnalyzing = false;
          _statusMessage = "Analysis Complete: Result Found!";
        });
      }
    } catch (e) {
      debugPrint("Error capturing image: $e");
      setState(() => _statusMessage = "Error: Camera access denied or not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BIOLENS AI', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // VIEWPORT: Where the image appears
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: _imageData != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Image.memory(_imageData!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_enhance_outlined, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text("No Image Captured", style: TextStyle(color: Colors.white54)),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 32),

            // AI STATUS INDICATOR
            if (_isAnalyzing) 
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(color: Colors.greenAccent),
              ),
            
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            
            const SizedBox(height: 80), // Space for button
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAnalyzing ? null : _pickImage,
        label: const Text("SCAN SPECIES", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.camera_alt),
        backgroundColor: _isAnalyzing ? Colors.grey : Colors.green,
      ),
    );
  }
}
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SkinScannerScreen extends StatefulWidget {
  const SkinScannerScreen({super.key});

  @override
  State<SkinScannerScreen> createState() => _SkinScannerScreenState();
}

class _SkinScannerScreenState extends State<SkinScannerScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;

  // ── YOUR PC IP ADDRESS ──────────────────────────────────────────
  static const String _baseUrl = 'http://192.168.18.96:5000/api/scan/analyze';

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _result = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() => _isAnalyzing = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.fields['userId'] = 'guest';
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      var response = await request.send().timeout(
        const Duration(seconds: 300),
      );
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        setState(() => _result = data);
      } else {
        _showError(data['error'] ?? 'Analysis failed');
      }
    } catch (e) {
      _showError('Connection failed: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Color(0xFFE8836A), size: 18),
          ),
        ),
        title: const Text(
          'Skin Issue Scanner',
          style: TextStyle(
            color: Color(0xFF3D1F0F),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 24),
              _buildImageArea(),
              const SizedBox(height: 24),
              _buildPickerButtons(),
              const SizedBox(height: 24),
              _buildAnalyzeButton(),
              if (_result != null) ...[
                const SizedBox(height: 24),
                _buildResultCard(),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8836A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8836A).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFE8836A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Upload a clear, well-lit photo of the affected skin area for best results.',
              style: TextStyle(
                color: const Color(0xFF3D1F0F).withOpacity(0.75),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return GestureDetector(
      onTap: () => _showPickerOptions(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedImage != null
                ? const Color(0xFFE8836A)
                : const Color(0xFFF5C5B0),
            width: _selectedImage != null ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8836A).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
            : _buildEmptyImagePlaceholder(),
      ),
    );
  }

  Widget _buildEmptyImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFF5C5B0).withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: Color(0xFFE8836A),
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Tap to upload a skin image',
          style: TextStyle(
            color: Color(0xFF3D1F0F),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'JPG, PNG supported',
          style: TextStyle(
            color: const Color(0xFF3D1F0F).withOpacity(0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerButtons() {
    return Row(
      children: [
        Expanded(
          child: _pickerButton(
            icon: Icons.camera_alt_outlined,
            label: 'Take Photo',
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _pickerButton(
            icon: Icons.photo_library_outlined,
            label: 'From Gallery',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _pickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF5C5B0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8836A).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFE8836A), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF3D1F0F),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C5B0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Choose Image Source',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3D1F0F))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _pickerButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pickerButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final bool canAnalyze = _selectedImage != null && !_isAnalyzing;
    return GestureDetector(
      onTap: canAnalyze ? _analyzeImage : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: canAnalyze
              ? const LinearGradient(
                  colors: [Color(0xFFE8836A), Color(0xFFD4614A)],
                )
              : null,
          color: canAnalyze ? null : const Color(0xFFF5C5B0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: canAnalyze
              ? [
                  BoxShadow(
                    color: const Color(0xFFE8836A).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: _isAnalyzing
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Analyzing...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                )
              : Text(
                  _selectedImage != null
                      ? 'Analyze Skin'
                      : 'Select an Image First',
                  style: TextStyle(
                    color:
                        canAnalyze ? Colors.white : const Color(0xFFE8836A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final condition = _result!['condition'] ?? 'Unknown';
    final confidence = (_result!['confidence'] ?? 0.0) as num;
    final tip = _result!['tip'] ?? '';
    final lowConfidence = _result!['lowConfidence'] ?? false;
    final allScores =
        _result!['allScores'] as Map<String, dynamic>? ?? {};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5C5B0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8836A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C5B0).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.document_scanner_outlined,
                    color: Color(0xFFE8836A), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detection Result',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF3D1F0F))),
                    Text(condition,
                        style: const TextStyle(
                            color: Color(0xFFE8836A),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Confidence bar
          Text(
            'Confidence: ${confidence.toStringAsFixed(1)}%',
            style: const TextStyle(
                color: Color(0xFF3D1F0F),
                fontWeight: FontWeight.w500,
                fontSize: 13),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confidence / 100,
              backgroundColor: const Color(0xFFF5C5B0),
              color: confidence > 70
                  ? Colors.green
                  : confidence > 50
                      ? Colors.orange
                      : Colors.red,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),

          // Low confidence warning
          if (lowConfidence)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.orange.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Low confidence. Please consult a dermatologist.',
                      style:
                          TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Tip
          if (tip.isNotEmpty && !lowConfidence) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8836A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Color(0xFFE8836A), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(tip,
                        style: TextStyle(
                            color:
                                const Color(0xFF3D1F0F).withOpacity(0.8),
                            fontSize: 12,
                            height: 1.4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // All scores
          const Text('All Scores:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D1F0F),
                  fontSize: 13)),
          const SizedBox(height: 8),
          ...allScores.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(e.key,
                          style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF3D1F0F)
                                  .withOpacity(0.7))),
                    ),
                    Text('${(e.value as num).toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE8836A))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SkinScannerScreen extends StatefulWidget {
  const SkinScannerScreen({super.key});

  @override
  State<SkinScannerScreen> createState() => _SkinScannerScreenState();
}

class _SkinScannerScreenState extends State<SkinScannerScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;

  // ── Pick image from camera or gallery ──────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // ── Simulate analysis (we'll replace with real API later) ───────
 Future<void> _analyzeImage() async {
  if (_selectedImage == null) return;

  setState(() => _isAnalyzing = true);

  // Simulated delay — will be replaced by Flask API call
  await Future.delayed(const Duration(seconds: 2));

  setState(() => _isAnalyzing = false);

  if (!mounted) return;

  // Temporarily show a snackbar until results screen is ready
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('✅ Image selected! Results screen coming next.'),
      backgroundColor: Color(0xFFE8836A),
      duration: Duration(seconds: 2),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 24),
              _buildImageArea(),
              const SizedBox(height: 24),
              _buildPickerButtons(),
              const Spacer(),
              _buildAnalyzeButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top info banner ─────────────────────────────────────────────
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

  // ── Image preview area ──────────────────────────────────────────
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
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
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

  // ── Camera / Gallery buttons ────────────────────────────────────
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

  // ── Bottom sheet for pick options ───────────────────────────────
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

  // ── Analyze button ──────────────────────────────────────────────
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
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
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
                  _selectedImage != null ? 'Analyze Skin' : 'Select an Image First',
                  style: TextStyle(
                    color: canAnalyze ? Colors.white : const Color(0xFFE8836A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _quickSearchController = TextEditingController();
  final TextEditingController _featureSearchController = TextEditingController();
  String _featureQuery = '';

  final List<Map<String, dynamic>> _quickActions = [
    {'title': 'Scan Skin', 'icon': Icons.camera_alt_outlined},
    {'title': 'Consult Doctor', 'icon': Icons.add_box_outlined},
    {'title': 'Scan Product', 'icon': Icons.qr_code_scanner_outlined},
    {'title': 'AI Chatbot', 'icon': Icons.chat_bubble_outline},
  ];

  final List<Map<String, dynamic>> _modules = [
    {'title': 'Skin Issue\nScanner', 'icon': Icons.document_scanner_outlined},
    {'title': 'AI First Aid\nChatbot', 'icon': Icons.chat_bubble_outline},
    {'title': 'Skin Type\nDetection', 'icon': Icons.face_outlined},
    {'title': 'Weather\nSkin Analysis', 'icon': Icons.wb_sunny_outlined},
    {'title': 'Patient\nHistory', 'icon': Icons.history_outlined},
    {'title': 'Virtual\nDoctor', 'icon': Icons.video_call_outlined},
    {'title': 'Ingredient\nScanner', 'icon': Icons.qr_code_scanner_outlined},
    {'title': 'Diet–Skin\nAnalysis', 'icon': Icons.restaurant_outlined},
    {'title': 'Skin Age\nPrediction', 'icon': Icons.auto_awesome_outlined},
  ];

  List<Map<String, dynamic>> get _filteredModules {
    if (_featureQuery.isEmpty) return _modules;
    return _modules
        .where((m) => (m['title'] as String)
            .toLowerCase()
            .replaceAll('\n', ' ')
            .contains(_featureQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _quickSearchController.dispose();
    _featureSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildFeaturesSection()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF5C5B0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8836A), width: 2),
            ),
            child: const Icon(Icons.person, color: Color(0xFFE8836A), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hi, Eqan',
                  style: TextStyle(
                    color: Color(0xFF3D1F0F),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Last scan: 3 days ago',
                  style: TextStyle(
                    color: const Color(0xFF3D1F0F).withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Skin Score: Good',
                  style: TextStyle(
                    color: const Color(0xFFE8836A).withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C5B0).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Color(0xFFE8836A), size: 22),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8836A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Color(0xFF3D1F0F),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF5C5B0)),
            ),
            child: TextField(
              controller: _quickSearchController,
              style: const TextStyle(fontSize: 13, color: Color(0xFF3D1F0F)),
              decoration: InputDecoration(
                hintText: 'Search Quick Actions',
                hintStyle: TextStyle(
                    color: const Color(0xFF3D1F0F).withOpacity(0.35),
                    fontSize: 13),
                prefixIcon: Icon(Icons.search,
                    color: const Color(0xFF3D1F0F).withOpacity(0.35), size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: _quickActions
                .map((action) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F0),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFFF5C5B0), width: 1),
                            ),
                            child: Column(
                              children: [
                                Icon(action['icon'] as IconData,
                                    color: const Color(0xFFE8836A), size: 26),
                                const SizedBox(height: 6),
                                Text(
                                  action['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF3D1F0F),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Features',
            style: TextStyle(
              color: Color(0xFF3D1F0F),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF5C5B0)),
            ),
            child: TextField(
              controller: _featureSearchController,
              style: const TextStyle(fontSize: 13, color: Color(0xFF3D1F0F)),
              onChanged: (v) => setState(() => _featureQuery = v),
              decoration: InputDecoration(
                hintText: 'Search features...',
                hintStyle: TextStyle(
                    color: const Color(0xFF3D1F0F).withOpacity(0.35),
                    fontSize: 13),
                prefixIcon: Icon(Icons.search,
                    color: const Color(0xFF3D1F0F).withOpacity(0.35), size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: _filteredModules.length,
            itemBuilder: (context, index) {
              final module = _filteredModules[index];
              return GestureDetector(
               onTap: () {
  final title = module['title'].toString().replaceAll('\n', ' ');
  if (title == 'AI First Aid Chatbot') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatbotScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title — Coming Soon'),
        backgroundColor: const Color(0xFFE8836A),
        duration: const Duration(seconds: 1),
      ),
    );
  }
},
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F0),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFFF5C5B0), width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5C5B0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(module['icon'] as IconData,
                            color: const Color(0xFFE8836A), size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        module['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF3D1F0F),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.document_scanner_outlined, 'label': 'Scan'},
      {'icon': Icons.history_outlined, 'label': 'History'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8836A).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF5C5B0).withOpacity(0.4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[index]['icon'] as IconData,
                    color: isSelected
                        ? const Color(0xFFE8836A)
                        : const Color(0xFF3D1F0F).withOpacity(0.35),
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFE8836A)
                          : const Color(0xFF3D1F0F).withOpacity(0.35),
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

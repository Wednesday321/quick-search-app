import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const QuickSearchApp());
}

class QuickSearchApp extends StatelessWidget {
  const QuickSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int? _selectedPlatform;

  final List<Platform> _platforms = [
    Platform('XiaoHongShu', 'assets/xhs.png', const Color(0xFFFE2C55)),
    Platform('Bilibili', 'assets/bili.png', const Color(0FF00A1D6)),
    Platform('Zhihu', 'assets/zhihu.png', const Color(0xFF0066FF)),
    Platform('Bing', 'assets/bing.png', const Color(0xFF008373)),
    Platform('Google', 'assets/google.png', const Color(0xFF4285F4)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _encodeKeyword(String keyword) {
    return Uri.encodeComponent(keyword);
  }

  Future<void> _search() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      _showSnackBar('Please enter a keyword');
      return;
    }
    if (_selectedPlatform == null) {
      _showSnackBar('Please select a platform');
      return;
    }

    final encoded = _encodeKeyword(keyword);
    String url;

    switch (_selectedPlatform) {
      case 0: // XiaoHongShu
        url = 'xhsdiscover://search/result?keyword=$encoded';
        break;
      case 1: // Bilibili
        url = 'bilibili://search?keyword=$encoded';
        break;
      case 2: // Zhihu
        url = 'zhihu://search?q=$encoded';
        break;
      case 3: // Bing
        url = 'https://www.bing.com/search?q=$encoded';
        break;
      case 4: // Google
        url = 'https://www.google.com/search?q=$encoded';
        break;
      default:
        return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Clear after successful search
      _searchController.clear();
      setState(() => _selectedPlatform = null);
    } else {
      _showSnackBar('Cannot open ${_platforms[_selectedPlatform!].name}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Title
              const Text(
                'Quick Search',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Search across platforms instantly',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedPlatform != null
                        ? _platforms[_selectedPlatform!].color
                        : Colors.grey[800]!,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter search keyword...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (_) => _search(),
                  textInputAction: TextInputAction.search,
                ),
              ),
              const SizedBox(height: 24),
              // Platform Grid
              const Text(
                'Select Platform',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _platforms.length,
                  itemBuilder: (context, index) {
                    final platform = _platforms[index];
                    final isSelected = _selectedPlatform == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedPlatform = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? platform.color.withOpacity(0.15)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? platform.color
                                : Colors.grey[800]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconForPlatform(index),
                              size: 32,
                              color: isSelected
                                  ? platform.color
                                  : Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              platform.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? platform.color
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Search Button
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPlatform != null
                        ? _platforms[_selectedPlatform!].color
                        : const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForPlatform(int index) {
    switch (index) {
      case 0: // XiaoHongShu
        return Icons.favorite;
      case 1: // Bilibili
        return Icons.play_circle_outline;
      case 2: // Zhihu
        return Icons.question_answer;
      case 3: // Bing
        return Icons.search;
      case 4: // Google
        return Icons.language;
      default:
        return Icons.search;
    }
  }
}

class Platform {
  final String name;
  final String iconPath;
  final Color color;

  Platform(this.name, this.iconPath, this.color);
}
import 'package:flutter/material.dart';
import '../../data/models/warga_verification_item.dart';
import '../../data/services/warga_verification_service.dart';
import '../widgets/warga_verification_card.dart';
import 'detail_warga_page.dart';

class VerifikasiWargaPage extends StatefulWidget {
  const VerifikasiWargaPage({super.key});

  @override
  State<VerifikasiWargaPage> createState() => _VerifikasiWargaPageState();
}

class _VerifikasiWargaPageState extends State<VerifikasiWargaPage> {
  final WargaVerificationService _service = WargaVerificationService();
  List<WargaVerificationItem> _verifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  Future<void> _loadVerifications() async {
    setState(() => _isLoading = true);
    try {
      final verifications = await _service.getPendingVerifications();
      setState(() {
        _verifications = verifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading verifications: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, 0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verifikasi Warga',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Daftar warga yang menunggu persetujuan',
                            style: TextStyle(
                              color: Color(0xE5FFFEFE),
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 10,
                      offset: Offset(0, 8),
                      spreadRadius: -6,
                    ),
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 25,
                      offset: Offset(0, 20),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6EE7B7),
        ),
      );
    }

    if (_verifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada warga yang menunggu verifikasi',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVerifications,
      color: const Color(0xFF6EE7B7),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _verifications.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              // Navigate to detail page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailWargaPage(
                    warga: _verifications[index],
                  ),
                ),
              );
              // Refresh if needed
              if (result == true) {
                _loadVerifications();
              }
            },
            child: WargaVerificationCard(
              warga: _verifications[index],
            ),
          );
        },
      ),
    );
  }
}

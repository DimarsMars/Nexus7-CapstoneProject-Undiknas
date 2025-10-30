import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _MyEditProfileScreen();
}

class _MyEditProfileScreen extends State<EditProfileScreen> {
  // --- Warna Konsisten (dari desain) ---
  static const Color _darkBlue = Color(0xFF1C314A);
  static const Color _lightGreyText = Color(0xFF6C7B8A);
  static const Color _borderColor = Color(0xFFCBD2D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe9ebee),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            // 4. Padding luar (margin) dari kode Anda
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
            child: Container(
              width: double.infinity,
              // 5. Dekorasi kartu putih (shadow, border radius) dari kode Anda
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),

              // 6. Padding di dalam kartu putih
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  // 7. Rata kiri untuk label, rata tengah untuk sisanya
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    // --- Avatar (Sesuai permintaan Anda, kembali ke versi sederhana) ---
                    const CircleAvatar(
                      radius: 60,
                      // Anda bisa tambahkan gambar di sini
                      // backgroundImage: NetworkImage('...'),
                    ),
                    const SizedBox(height: 30),

                    // --- Label "Name" ---
                    _buildLabel('Name', center: true),
                    const SizedBox(height: 8),

                    // --- Text Field "Name" ---
                    _buildTextField(hint: 'ELALALANG'),
                    const SizedBox(height: 20),

                    // --- Rank ---
                    _buildLabel('Rank\'s', center: true),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: _darkBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Adventurer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _darkBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // --- Birth Date ---
                    _buildLabel('Birth Date'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: '20/12/2000',
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 20),

                    // --- Description ---
                    _buildLabel('Description (likes)'),
                    const SizedBox(height: 8),
                    _buildTextField(hint: 'Adventure, Food, Health, Bike'),
                    const SizedBox(height: 20),

                    // --- Status ---
                    _buildLabel('Status'),
                    const SizedBox(height: 8),
                    _buildStatusField(), // Field khusus untuk Status
                    const SizedBox(height: 40),

                    // --- Tombol Accept & Cancel ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tombol Accept
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 16),
                        // Tombol Cancel
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Footer Text ---
                    const Text(
                      'Personal information on your profile is meant to be used to provide better recommendations to other users in this app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: _lightGreyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// --- WIDGET HELPER DI BAWAH INI ---
  /// (Diletakkan di dalam class _MyProfileScreen, di luar method build)

  // Fungsi _buildAvatar() telah dihapus sesuai permintaan
  
  /// Helper untuk label (Birth Date, Status, dll)
  Widget _buildLabel(String text, {bool center = false}) {
    return Align(
      alignment: center ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: _lightGreyText,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Helper untuk Text Field
  Widget _buildTextField({required String hint, IconData? icon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _darkBlue, fontWeight: FontWeight.bold),
        suffixIcon: icon != null
            ? Icon(icon, color: _lightGreyText)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: _borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: _darkBlue, width: 1.5),
        ),
      ),
    );
  }

  /// Helper khusus untuk field "Status"
  Widget _buildStatusField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _borderColor, width: 1.0),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Family',
            style: TextStyle(color: _darkBlue, fontWeight: FontWeight.bold),
          ),
          Text(
            '(0) Child',
            style: TextStyle(color: _lightGreyText),
          ),
        ],
      ),
    );
  }
}

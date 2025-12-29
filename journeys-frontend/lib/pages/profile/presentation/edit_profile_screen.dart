import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:journeys/models/category_model.dart';
import 'package:journeys/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _MyEditProfileScreen();
}

class _MyEditProfileScreen extends State<EditProfileScreen> {
  static const Color _darkBlue = Color(0xFF1C314A);
  static const Color _lightGreyText = Color(0xFF6C7B8A);
  static const Color _borderColor = Color(0xFFCBD2D9);

  // Api Service
  final ApiService _apiService = ApiService();

  // State untuk gambar profil
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // State untuk tanggal lahir
  DateTime? _selectedDate;
  final TextEditingController _birthDateController = TextEditingController();

  // State untuk status dropdown
  String? _selectedStatus;
  final List<String> _statusOptions = [
    'Married',
    'Single',
    'In Relationship',
    'Adult',
    'Family Friendly'
  ];

  // State untuk description (categories)
  bool _isDescriptionDropdownOpen = false;
  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    // Inisialisasi tanggal awal atau biarkan kosong
    // _selectedDate = DateTime(2000, 12, 20);
    // _birthDateController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _allCategories = categories;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load preferences: $e')),
        );
      }
    }
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _darkBlue, // Warna header
              onPrimary: Colors.white, // Warna teks di header
              onSurface: _darkBlue, // Warna teks tanggal
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _darkBlue, // Warna tombol OK dan Cancel
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe9ebee),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
            child: Container(
              width: double.infinity,
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

              // Padding di dalam kartu putih
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Stack(
                      children: [
                        // --- Foto Profil ---
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200], // Placeholder color
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          child: _imageFile == null
                              ? const Icon(CupertinoIcons.person_fill, size: 60, color: Colors.grey)
                              : null,
                        ),

                        // --- Tombol Edit (Pensil) Custom ---
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 35, // Ukuran kotak
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.white, // Background Putih
                                borderRadius: BorderRadius.circular(10), // Sudut melengkung (Rounded)
                                border: Border.all(
                                  color: const Color(0xFF2196F3), // Warna Biru terang sesuai gambar
                                  width: 1.5, // Ketebalan garis biru
                                ),
                              ),
                              child: const Icon(
                                Icons.edit, // Icon Pensil Solid
                                color: Color(0xFF2196F3), // Warna Icon Biru
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // --- Label "Name" ---
                    _buildLabel('Name', center: true),
                    const SizedBox(height: 8),

                    // --- Text Field "Name" ---
                    _buildTextField(hint: 'ELALALANG', textAlign: TextAlign.center),
                    const SizedBox(height: 20),

                    // --- Rank ---
                    _buildLabel('Rank\'s', center: true),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.shield_fill, 
                                color: Color(0xFF1C314A),
                                size: 32,
                              ),
                              // Angka Level
                              const Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10), 
                          const Text(
                            'Adventurer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C314A),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    
                    // --- Birth Date ---
                    _buildLabel('Birth Date'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: 'Select your birth date',
                      icon: Icons.calendar_today_outlined,
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Description ---
                    _buildLabel('Description (likes)'),
                    const SizedBox(height: 8),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),

                    // --- Status ---
                    _buildLabel('Status'),
                    const SizedBox(height: 8),
                    _buildStatusField(),
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
                          child: const Text('Save'),
                        ),
                        const SizedBox(width: 16),
                        // Tombol Cancel
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
  Widget _buildTextField({
    required String hint,
    IconData? icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    TextAlign textAlign = TextAlign.start, // Tambahkan parameter ini
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      textAlign: textAlign, // Gunakan parameter ini
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _darkBlue, fontWeight: FontWeight.bold),
        suffixIcon: icon != null ? Icon(icon, color: _lightGreyText) : null,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        filled: true, // Tambahkan ini
        fillColor: Colors.white, // Tambahkan ini
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

  /// Helper untuk field "Description" (Multi-select Dropdown)
  Widget _buildDescriptionField() {
    // Filter kategori yang belum dipilih
    final availableCategories = _allCategories
        .where((cat) =>
            !_selectedCategories.any((selected) => selected.id == cat.id))
        .toList();

    return Column(
      children: [
        // --- Kotak input palsu yang menampilkan chips ---
        GestureDetector(
          onTap: () {
            setState(() {
              _isDescriptionDropdownOpen = !_isDescriptionDropdownOpen;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: _borderColor, width: 1.0),
              color: Colors.white, // Background putih agar sama dengan TextField
            ),
            child: Row(
              children: [
                Expanded(
                  child: _selectedCategories.isEmpty
                      ? const Text(
                          'Select Preference',
                          style: TextStyle(color: _darkBlue, fontWeight: FontWeight.bold),
                        )
                      : Wrap(
                          spacing: 6.0,
                          runSpacing: 6.0,
                          children: _selectedCategories.map((category) {
                            return Chip(
                              label: Text(category.name.trim(), style: const TextStyle(fontSize: 12)),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategories.removeWhere(
                                      (c) => c.id == category.id);
                                });
                              },
                              deleteIcon: const Icon(CupertinoIcons.xmark_circle_fill, size: 16),
                              backgroundColor: Colors.grey[200],
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                            );
                          }).toList(),
                        ),
                ),
                Icon(
                  _isDescriptionDropdownOpen
                      ? Icons.arrow_drop_up // Panah ke atas saat terbuka
                      : Icons.arrow_drop_down, // Panah ke bawah saat tertutup
                  color: _lightGreyText,
                  size: 24, // Ukuran ikon default untuk DropdownButtonFormField
                ),
              ],
            ),
          ),
        ),

        // --- Daftar dropdown yang bisa muncul/hilang ---
        if (_isDescriptionDropdownOpen)
          Container(
            height: 200, // Batasi tinggi agar bisa di-scroll
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: _borderColor, width: 1.0),
              color: Colors.white,
            ),
            child: availableCategories.isEmpty
                ? const Center(child: Text('All categories selected or none available.'))
                : ListView.builder(
                    itemCount: availableCategories.length,
                    itemBuilder: (context, index) {
                      final category = availableCategories[index];
                      return ListTile(
                        title: Text(category.name.trim()),
                        onTap: () {
                          setState(() {
                            _selectedCategories.add(category);
                            _isDescriptionDropdownOpen = false; // Tutup dropdown setelah memilih
                          });
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }

  /// Helper khusus untuk field "Status" yang sekarang menjadi Dropdown
  Widget _buildStatusField() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      hint: const Text(
        'Select Status',
        style: TextStyle(color: _darkBlue, fontWeight: FontWeight.bold),
      ),
      isExpanded: true,
      onChanged: (String? newValue) {
        setState(() {
          _selectedStatus = newValue;
        });
      },
      items: _statusOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: _darkBlue, fontWeight: FontWeight.bold)),
        );
      }).toList(),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        filled: true, // Tambahkan ini
        fillColor: Colors.white, // Tambahkan ini
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
}

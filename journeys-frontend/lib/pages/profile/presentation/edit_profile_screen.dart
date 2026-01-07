import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:journeys/models/category_model.dart';
import 'package:journeys/models/user_model.dart';
import 'package:journeys/models/profile_model.dart';
import 'package:journeys/services/api_service.dart';

// Widget utama untuk layar pengeditan profil
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _MyEditProfileScreen();
}

class _MyEditProfileScreen extends State<EditProfileScreen> {
  // Definisi palet warna untuk konsistensi UI
  static const Color _darkBlue = Color(0xFF1C314A);
  static const Color _lightGreyText = Color(0xFF6C7B8A);
  static const Color _borderColor = Color(0xFFCBD2D9);

  // Inisialisasi layanan API
  final ApiService _apiService = ApiService();
  
  // Variabel untuk menangani pemilihan gambar profil
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Controller dan variabel untuk input data diri (Tanggal lahir dan Nama)
  DateTime? _selectedDate;
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Daftar opsi status hubungan untuk dropdown
  String? _selectedStatus;
  final List<String> _statusOptions = [
    'Married',
    'Single',
    'In Relationship',
    'Adult',
    'Family Friendly'
  ];

  // State untuk manajemen multi-select kategori minat (Description)
  bool _isDescriptionDropdownOpen = false;
  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _selectedCategories = [];

  // State untuk manajemen status loading dan penyimpanan data model
  bool _isLoading = true;
  bool _isSaving = false;
  UserModel? _user;
  ProfileModel? _profile;

  // Inisialisasi awal saat layar dibuka
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Membersihkan controller saat widget dihancurkan untuk mencegah kebocoran memori
  @override
  void dispose() {
    _birthDateController.dispose();
    _nameController.dispose(); 
    super.dispose();
  }

  // Fungsi untuk memicu urutan pengambilan data dari server
  Future<void> _loadInitialData() async {
    await _fetchCategories().then((_) {
      _loadProfileData();
    });
  }

  // Fungsi asinkron untuk mengambil data profil dan akun user secara paralel
  Future<void> _loadProfileData() async {
    try {
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getUserMe(),
      ]);
      final profile = results[0] as ProfileModel;
      final user = results[1] as UserModel;

      if (mounted) {
        setState(() {
          _profile = profile;
          _user = user;

          _nameController.text = user.username;

          // Parsing data tanggal lahir jika tersedia dari database
          if (profile.birthDate != null && profile.birthDate!.isNotEmpty) {
            try {
              _selectedDate = DateTime.parse(profile.birthDate!);
              _birthDateController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
            } catch (e) {
              // Abaikan jika format tanggal salah
            }
          }

          // Sinkronisasi status dropdown dengan data profil
          if (profile.status != null && _statusOptions.contains(profile.status)) {
            _selectedStatus = profile.status;
          }

          // Konversi string deskripsi (comma separated) menjadi list kategori terpilih
          if (profile.description != null && profile.description!.isNotEmpty && _allCategories.isNotEmpty) {
            final categoryNames = profile.description!.split(',').map((e) => e.trim().toLowerCase()).toList();
            _selectedCategories = _allCategories.where((cat) => categoryNames.contains(cat.name.trim().toLowerCase())).toList();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data profil: $e')),
        );
      }
    }
  }

  // Fungsi untuk mengambil daftar kategori yang tersedia dari API
  Future<void> _fetchCategories() async {
    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _allCategories = categories;
        });
      }
    } catch (e) {
      // Error ditangani di _loadProfileData
    }
  }

  // Fungsi untuk membuka galeri dan memilih gambar profil baru
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk memunculkan Date Picker (kalender) untuk memilih tanggal lahir
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Kustomisasi tema warna pada dialog kalender
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _darkBlue,
              onPrimary: Colors.white,
              onSurface: _darkBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _darkBlue,
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
        _birthDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Fungsi utama untuk mengirimkan seluruh pembaruan profil ke server
  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      // Format tanggal menjadi YYYY-MM-DD sesuai kebutuhan backend
      final String birthDate = _selectedDate != null
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
          : "";
      // Gabungkan nama-nama kategori menjadi satu string tunggal
      final String description = _selectedCategories.map((c) => c.name.trim()).join(', ');

      // Memanggil service update profil
      await _apiService.updateUserProfile(
        birthDate: birthDate,
        description: description,
        status: _selectedStatus ?? "",
        photo: _imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Kembali ke halaman sebelumnya dengan status sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Pembangunan antarmuka pengguna utama
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe9ebee),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Bagian Foto Profil dengan tombol edit (Stack)
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (_profile?.photo != null && _profile!.photo!.isNotEmpty
                                        ? MemoryImage(base64Decode(_profile!.photo!))
                                        : null) as ImageProvider<Object>?,
                                child: _imageFile == null && (_profile?.photo == null || _profile!.photo!.isEmpty)
                                    ? const Icon(CupertinoIcons.person_fill, size: 60, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF2196F3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(Icons.edit, color: Color(0xFF2196F3), size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Form Input: Nama
                          _buildLabel('Name', center: true),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            readOnly: true,
                            textAlign: TextAlign.center,
                            hint: 'Loading name...',
                          ),
                          const SizedBox(height: 20),
                          // Tampilan Badge Rank (Read-only)
                          _buildLabel('Rank\'s', center: true),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.brightness_7,
                                    color: Color(0xFF1C314A),
                                    size: 34,
                                  ),
                                  Text(
                                    _profile?.rank.split(' ').last.replaceAll('lvl', '') ?? '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _profile?.rank.split(' ').first ?? 'Rank',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1C314A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Form Input: Tanggal Lahir
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
                          // Form Input: Kategori Minat (Deskripsi)
                          _buildLabel('Description (likes)'),
                          const SizedBox(height: 8),
                          _buildDescriptionField(),
                          const SizedBox(height: 20),
                          // Form Input: Status
                          _buildLabel('Status'),
                          const SizedBox(height: 8),
                          _buildStatusField(),
                          const SizedBox(height: 40),
                          // Tombol Aksi: Save dan Cancel
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _isSaving ? null : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _darkBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Save'),
                              ),
                              const SizedBox(width: 16),
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
                          // Catatan Disclaimer di bawah form
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

  // Widget Helper untuk membangun label input
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

  // Widget Helper untuk membangun input teks standar
  Widget _buildTextField({
    required String hint,
    IconData? icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    TextAlign textAlign = TextAlign.start,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      textAlign: textAlign,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _darkBlue, fontWeight: FontWeight.bold),
        suffixIcon: icon != null ? Icon(icon, color: _lightGreyText) : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        filled: true,
        fillColor: Colors.white,
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

  // Widget kustom untuk pemilihan multi-kategori (Description Likes)
  Widget _buildDescriptionField() {
    // Memfilter kategori yang belum dipilih untuk ditampilkan di list dropdown
    final availableCategories = _allCategories
        .where((cat) => !_selectedCategories.any((selected) => selected.id == cat.id))
        .toList();

    return Column(
      children: [
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
              color: Colors.white,
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
                                  _selectedCategories.removeWhere((c) => c.id == category.id);
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
                  _isDescriptionDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: _lightGreyText,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        // Dropdown list yang muncul saat field deskripsi diklik
        if (_isDescriptionDropdownOpen)
          Container(
            height: 200,
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
                            _isDescriptionDropdownOpen = false;
                          });
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }

  // Widget Helper untuk membangun dropdown pilihan Status hubungan
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
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        filled: true,
        fillColor: Colors.white,
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
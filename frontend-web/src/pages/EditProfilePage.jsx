import { useCallback, useEffect, useMemo, useState } from 'react'; // Mengimpor hooks inti React
import { FaCertificate, FaPen, FaTimes, FaChevronDown } from "react-icons/fa"; // Mengimpor ikon-ikon dari react-icons
import { useNavigate } from 'react-router-dom'; // Mengimpor hook untuk navigasi halaman
import { useAuth } from '../context/AuthContext'; // Mengimpor context autentikasi pengguna
import apiService from '../services/apiService'; // Mengimpor layanan untuk komunikasi API

const EditProfilePage = () => {
  const navigate = useNavigate(); // Inisialisasi fungsi navigasi
  const { user: authUser } = useAuth(); // Mengambil data user yang sedang terautentikasi

  // --- STATE MANAGEMENT ---
  
  // State untuk menyimpan semua kategori yang tersedia dari database
  const [categories, setCategories] = useState([]);
  // State untuk menyimpan kategori yang dipilih oleh user
  const [selectedCategories, setSelectedCategories] = useState([]);
  // State untuk mengontrol buka/tutup dropdown kategori
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  // State sementara untuk menyimpan string deskripsi (likes) dari profil
  const [profileDescription, setProfileDescription] = useState(null);

  // State untuk menampilkan Nama dan Rank di bagian header (read-only)
  const [displayUser, setDisplayUser] = useState({
    name: 'Loading...',
    rank: 'Loading...'
  });

  // State untuk mengelola data input formulir (Tanggal lahir, Status, dan Foto)
  const [formData, setFormData] = useState({
    birthDate: '',
    status: '',
    image: '' // Menyimpan string base64 atau objek File hasil upload
  });

  // --- EFFECTS ---

  // Effect untuk mengambil data user dan profil saat komponen dimuat atau authUser berubah
  useEffect(() => {
    const fetchUserData = async () => {
      if (authUser && authUser.idToken) {
        try {
          const userResponse = await apiService.getUserMe();
          const profileResponse = await apiService.getProfileMe();

          // Mengupdate state displayUser berdasarkan respon API
          setDisplayUser({
            name: userResponse.data.username,
            rank: profileResponse.data.rank
          });

          const profile = profileResponse.data;

          // Mengisi nilai awal formulir berdasarkan data profil dari database
          setFormData({
            birthDate: profile.birth_date?.split('T')[0] || "",
            status: profile.status || "",
            image: profile.photo || "" 
          });
          setProfileDescription(profile.description || "");
        } catch (error) {
          console.error("Error fetching user data:", error);
          setDisplayUser({ name: 'Error', rank: 'Error' });
        }
      }
    };

    fetchUserData();
  }, [authUser]);

  // Effect untuk mengambil daftar kategori dari server saat komponen pertama kali muncul
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await apiService.getCategories();        
        if (Array.isArray(response.data)) {
            setCategories(response.data);
        } else {
            console.error("Format data kategori tidak sesuai:", response.data);
        }
      } catch (error) {
        console.error("Gagal mengambil kategori:", error);
      }
    };
    fetchCategories();
  }, []); 

  // Effect untuk mencocokkan string deskripsi profil dengan daftar kategori untuk ditampilkan sebagai tag
  useEffect(() => {
    if (profileDescription !== null && categories.length > 0) {
      const categoryNames = profileDescription.split(',').map(name => name.trim()).filter(name => name);
      if (categoryNames.length > 0) {
        const selected = categories.filter(cat => categoryNames.includes(cat.name.trim()));
        setSelectedCategories(selected);
      }
    }
  }, [profileDescription, categories]);

  // --- MEMOIZED HANDLERS ---

  // Fungsi untuk menambahkan kategori ke daftar pilihan (menggunakan useCallback untuk efisiensi)
  const handleSelectCategory = useCallback((category) => {
    if (!selectedCategories.some(c => c.category_id === category.category_id)) {
        setSelectedCategories(prev => [...prev, category]);
    }
    setIsDropdownOpen(false); 
  }, [selectedCategories]);

  // Fungsi untuk menghapus kategori dari daftar pilihan
  const handleRemoveCategory = useCallback((categoryId) => {
      setSelectedCategories(prev => prev.filter(c => c.category_id !== categoryId));
  }, []); 

  // Fungsi standar untuk menangani perubahan input teks pada formulir
  const handleChange = useCallback((e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  }, []); 

  // Fungsi khusus untuk menangani input file gambar (mengambil objek File)
  const handleImageChange = useCallback((e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData(prev => ({ ...prev, image: file })); 
    }
  }, []);

  // Fungsi untuk mengirimkan perubahan data profil ke server
  const handleSubmit = useCallback(async (e) => {
    e.preventDefault();

    if (!authUser || !authUser.idToken) {
      alert("User not authenticated. Please log in again.");
      navigate('/login');
      return;
    }

    // Mengonversi array kategori terpilih kembali menjadi string yang dipisahkan koma
    const descriptionString = selectedCategories.map(c => c.name.trim()).join(', ');
    const formDataToSend = new FormData();
    formDataToSend.append('birth_date', formData.birthDate);
    formDataToSend.append('description', descriptionString);
    formDataToSend.append('status', formData.status);
    formDataToSend.append('location', 'Solo'); 
    formDataToSend.append('languages', 'ID'); 
    formDataToSend.append('photo', formData.image); 

    try {
      await apiService.updateUserProfile(formDataToSend);
      alert("Profile Updated!");
      setProfileDescription(descriptionString); 
      navigate('/myprofile');
    } catch (error) {
      console.error("Error updating profile:", error);
      alert("Failed to update profile. Please try again.");
    }
  }, [authUser, selectedCategories, formData, navigate]);

  // --- MEMOIZED HELPERS / COMPUTED VALUES ---

  // Fungsi komputasi untuk menentukan sumber URL gambar (pratinjau lokal atau data base64)
  const getImageSrc = useMemo(() => {
    if (!formData.image) return "";

    // Jika user baru saja memilih file baru, buat blob URL untuk preview
    if (formData.image instanceof File) {
      return URL.createObjectURL(formData.image);
    }

    // Jika data dari database (base64), tambahkan prefix data URI
    return `data:image/jpeg;base64,${formData.image}`;
  }, [formData.image]);

  // Filter untuk menampilkan kategori yang belum dipilih di dalam dropdown
  const availableCategories = useMemo(() => {
    return categories.filter(
      c => !selectedCategories.some(selected => selected.category_id === c.category_id)
    );
  }, [categories, selectedCategories]);

  // Helper untuk mengambil angka level dari string rank
  const getRankLevel = (rankString) => {
      if (!rankString) return '?';
      const match = rankString.match(/lvl (\d+)/i);
      return match ? match[1] : '?';
  };

  // Helper untuk mengambil nama rank (menghilangkan bagian level)
  const getRankName = (rankString) => {
      if (!rankString) return '';
      return rankString.replace(/ lvl \d+/i, '').trim();
  };

  // --- RENDER LOGIC ---
  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-28 flex justify-center items-center">
      <div className="bg-white w-full max-w-7xl p-8 md:p-12 rounded-xl shadow-sm">

        {/* BAGIAN HEADER: Foto Profil dan Informasi Nama/Rank */}
        <div className="flex flex-col md:flex-row items-center justify-between px-20 gap-8 md:gap-16 mb-8">
          <div className="relative">
            <div className="w-40 h-40 md:w-48 md:h-48 rounded-full overflow-hidden border-4 border-gray-100">
              {formData.image ? (
                <img
                  src={getImageSrc} 
                  alt="Profile"
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-gray-400">
                  Profile
                </div>
              )}
            </div>

            {/* Input File Tersembunyi untuk Upload Foto */}
            <input
              type="file"
              id="upload-photo"
              accept="image/*"
              onChange={handleImageChange}
              className="hidden"
            />
            <label
              htmlFor="upload-photo"
              className="absolute bottom-2 right-2 bg-white p-2 rounded-lg border border-blue-400 text-blue-500 shadow-sm hover:bg-blue-50 transition cursor-pointer"
            >
              <FaPen size={14} />
            </label>
          </div>

          {/* Menampilkan Nama dan Rank user */}
          <div className="flex flex-col gap-6 w-full md:w-1/2">
            <div>
              <label className="text-gray-600 text-lg mb-1 block">Name</label>
              <div className="rounded px-4 py-2 font-bold text-xl text-slate-900 tracking-wide capitalize">
                {displayUser.name}
              </div>
            </div>

            <div>
              <label className="text-gray-600 text-lg mb-1 block">Rank’s</label>
              <div className="flex items-center gap-2 justify-center">
                <div className="relative flex items-center justify-center text-white">
                  <FaCertificate className="text-slate-900 text-4xl" />
                  <span className="absolute font-bold text-xs">{getRankLevel(displayUser.rank)}</span>
                </div>
                <h2 className="text-xl font-bold text-slate-900">
                  {getRankName(displayUser.rank)}
                </h2>
              </div>
            </div>
          </div>
        </div>

        <hr className="border-t-2 border-[#1e293b] mb-8" />

        {/* FORMULIR PENGEDITAN DATA PROFIL */}
        <form onSubmit={handleSubmit} className="flex flex-col gap-6">

          {/* Input Tanggal Lahir */}
          <div className='text-start px-30'>
            <label className="text-gray-600 text-base mb-2 block">Birth Date</label>
            <input
              type="date"
              name="birthDate"
              value={formData.birthDate}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-4 py-3"
            />
          </div>

          {/* Input Kategori (Likes) dengan Tag System dan Dropdown */}
          <div className='text-start px-30'>
            <label className="text-gray-600 text-base mb-2 block">Description (likes)</label>
            <div className="relative">
              <div 
                className="w-full border border-gray-300 rounded-md px-4 py-2 bg-white min-h-[46px] flex flex-wrap items-center gap-2 cursor-pointer"
                onClick={() => setIsDropdownOpen(!isDropdownOpen)} 
              >
                {/* Menampilkan kategori yang sudah terpilih sebagai tag */}
                {selectedCategories.map((item) => (
                    <div 
                      key={item.category_id} 
                      className="bg-slate-200 text-slate-800 px-2 py-1 rounded text-sm font-medium flex items-center gap-1"
                      onClick={(e) => e.stopPropagation()}
                    >
                      {item.name.trim()}
                      <FaTimes 
                        className="cursor-pointer hover:text-red-500 ml-1" 
                        onClick={() => handleRemoveCategory(item.category_id)} 
                      />
                    </div>
                ))}
                <div className="flex-1 flex items-center justify-between min-w-[100px]">
                    <span className={`${selectedCategories.length === 0 ? 'text-gray-400' : 'text-transparent'}`}>
                      {selectedCategories.length === 0 ? "Select Preference" : ""}
                    </span>
                    <FaChevronDown className={`text-gray-400 text-sm transition-transform ${isDropdownOpen ? 'rotate-180' : ''}`} />
                </div>
              </div>

              {/* Tampilan List Dropdown Kategori */}
              {isDropdownOpen && (
                <div className="absolute top-full mt-1 w-full bg-white rounded-md shadow-lg border border-gray-200 z-10 overflow-hidden">
                    <div className="max-h-60 overflow-y-auto">
                        {availableCategories.map((item) => (
                            <div 
                                key={item.category_id}
                                onClick={() => handleSelectCategory(item)}
                                className="px-4 py-3 hover:bg-gray-100 cursor-pointer text-gray-700 text-sm border-b border-gray-50 last:border-0"
                            >
                                {item.name.trim()}
                            </div>
                        ))}

                        {/* State jika tidak ada kategori tersedia */}
                        {availableCategories.length === 0 && (
                            <div className="px-4 py-3 text-gray-400 text-sm text-center">
                                {categories.length === 0 ? "No categories loaded" : "All categories selected"}
                            </div>
                        )}
                    </div>
                </div>
              )}
            </div>
          </div>

          {/* Input Pilihan Status Hubungan */}
          <div className='text-start px-30'>
            <label className="text-gray-600 text-base mb-2 block">Status</label>
            <select
              name="status"
              value={formData.status}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-4 py-3 bg-white appearance-none cursor-pointer"
            >
              <option value="" disabled>Select Status</option>
              <option value="Married">Married</option>
              <option value="Single">Single</option>
              <option value="In Relationship">In Relationship</option>
              <option value="Adult">Adult</option>
              <option value="Family Friendly">Family Friendly</option>
            </select>
          </div>

          <hr className="border-t-2 border-[#1e293b] mt-4 mb-4" />

          {/* Tombol Aksi: Save dan Cancel */}
          <div className="flex flex-col gap-3">
            <button
              type="submit"
              className="w-full py-2.5 bg-slate-900 text-white text-sm font-semibold rounded-md hover:bg-slate-700 transition shadow-sm tracking-wide"
            >
              Save
            </button>
            <button
              type="button"
              onClick={() => navigate('/myprofile')}
              className="w-full py-2.5 bg-red-600 text-white text-sm font-semibold rounded-md hover:bg-red-700 transition shadow-sm tracking-wide"
            >
              Cancel
            </button>
          </div>

        </form>
      </div>
    </div>
  );
};

export default EditProfilePage;
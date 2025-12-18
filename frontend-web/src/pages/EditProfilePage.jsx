import { useEffect, useState } from 'react';
import { FaCertificate, FaPen } from "react-icons/fa";
import { useNavigate } from 'react-router-dom';
import apiService from '../services/apiService';

const EditProfilePage = () => {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(true);

  // State untuk Data Tampilan (Nama & Role)
  const [displayUser, setDisplayUser] = useState({
    name: '',
    role: ''
  });

  // State untuk Form
  const [formData, setFormData] = useState({
    birthDate: '',
    description: '',
    status: '',
    location: '',
    languages: '',
    imageFile: null,    // Untuk file baru yang diupload
    previewUrl: ''      // Untuk menampilkan gambar (bisa URL lama atau preview baru)
  });

  // 1. FETCH DATA SAAT HALAMAN DIBUKA
  useEffect(() => {
    const fetchInitialData = async () => {
      try {
        // Panggil 2 API sekaligus (User & Profile)
        const [userRes, profileRes] = await Promise.all([
          apiService.getUserMe(),
          apiService.getProfileMe()
        ]);

        const userData = userRes.data;
        const profileData = profileRes.data;

        // Set Tampilan Header
        setDisplayUser({
          name: userData.username,
          role: profileData.rank // Rank diambil dari profile response
        });

        // Set Nilai Awal Form
        setFormData({
          birthDate: profileData.birth_date ? profileData.birth_date.split('T')[0] : "", // Format YYYY-MM-DD
          description: profileData.description || "",
          status: profileData.status || "",
          location: profileData.location || " ",
          languages: profileData.languages || "ID",
          imageFile: null,
          previewUrl: profileData.photo || "" // Foto dari database
        });

      } catch (error) {
        console.error("Gagal mengambil data:", error);
        alert("Gagal memuat data profile.");
      } finally {
        setIsLoading(false);
      }
    };

    fetchInitialData();
  }, []);

  // 2. HANDLE PERUBAHAN TEXT INPUT
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  // 3. HANDLE PERUBAHAN GAMBAR (PREVIEW)
  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData(prev => ({
        ...prev,
        imageFile: file, // Simpan filenya untuk dikirim nanti
        previewUrl: URL.createObjectURL(file) // Buat URL lokal untuk preview
      }));
    }
  };

  // 4. SUBMIT FORM
  const handleSubmit = async (e) => {
    e.preventDefault();

    // Gunakan FormData karena kita mengirim File (Multipart)
    const dataToSend = new FormData();
    
    // Append data text
    dataToSend.append('birth_date', formData.birthDate); // Kirim format YYYY-MM-DD
    dataToSend.append('description', formData.description);
    dataToSend.append('status', formData.status);
    dataToSend.append('location', formData.location);
    dataToSend.append('languages', formData.languages);

    // Append file HANYA JIKA user mengupload foto baru
    if (formData.imageFile) {
      dataToSend.append('photo', formData.imageFile);
    }

    try {
      // Panggil Service (Token sudah otomatis diurus ApiClient)
      await apiService.updateUserProfile(dataToSend);
      
      alert("Profile Berhasil Diupdate!");
    } catch (error) {
      console.error("Error updating profile:", error);
      alert("Gagal mengupdate profile. Silakan coba lagi.");
    }
  };

  if (isLoading) {
    return <div className="min-h-screen flex justify-center items-center">Loading...</div>;
  }

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-28 flex justify-center items-center">
      <div className="bg-white w-full max-w-7xl p-8 md:p-12 rounded-xl shadow-sm">

        {/* HEADER */}
        <div className="flex flex-col md:flex-row items-center justify-between px-20 gap-8 md:gap-16 mb-8">
          
          {/* FOTO PROFIL */}
          <div className="relative">
            <div className="w-40 h-40 md:w-48 md:h-48 rounded-full overflow-hidden border-4 border-gray-100 bg-gray-200">
              {formData.previewUrl ? (
                <img
                  src={formData.previewUrl}
                  alt="Profile"
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-gray-500 font-medium">
                  No Photo
                </div>
              )}
            </div>

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

          {/* INFO NAMA & RANK */}
          <div className="flex flex-col gap-6 w-full md:w-1/2 text-center md:text-left">
            <div>
              <label className="text-gray-600 text-lg mb-1 block">Name</label>
              <div className="rounded font-bold text-2xl text-slate-900 uppercase tracking-wide">
                {displayUser.name}
              </div>
            </div>

            <div>
              <label className="text-gray-600 text-lg mb-1 block">Rank</label>
              <div className="flex items-center gap-3 justify-center md:justify-start">
                <div className="relative flex items-center justify-center text-white">
                  <FaCertificate className="text-slate-900 text-4xl" />
                  {/* Ambil huruf pertama Rank untuk ikon */}
                  <span className="absolute font-bold text-xs uppercase">
                    {displayUser.role ? displayUser.role.charAt(0) : '-'}
                  </span>
                </div>
                <h2 className="text-xl font-bold text-slate-900">
                  {displayUser.role || "Traveller"}
                </h2>
              </div>
            </div>
          </div>
        </div>

        <hr className="border-t-2 border-[#1e293b] mb-8" />

        {/* FORM INPUT */}
        <form onSubmit={handleSubmit} className="flex flex-col gap-6 max-w-3xl mx-auto">

          <div className='flex flex-col text-start'>
            <label className="text-gray-600 text-base mb-2 font-medium">Birth Date</label>
            <input
              type="date"
              name="birthDate"
              value={formData.birthDate}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-4 py-3 focus:outline-none focus:ring-2 focus:ring-slate-500"
            />
          </div>

          <div className='flex flex-col text-start'>
            <label className="text-gray-600 text-base mb-2 font-medium">Description</label>
            <textarea
              name="description"
              rows="3"
              value={formData.description}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-4 py-3 focus:outline-none focus:ring-2 focus:ring-slate-500"
              placeholder="Ceritakan sedikit tentang dirimu..."
            />
          </div>

          <div className='flex flex-col text-start'>
            <label className="text-gray-600 text-base mb-2 font-medium">Status (e.g., Family, Solo, Friends)</label>
            <input
              type="text"
              name="status"
              value={formData.status}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-4 py-3 focus:outline-none focus:ring-2 focus:ring-slate-500"
            />
          </div>
          
          {/* Input Location & Language (Hidden tapi dikirim, atau mau ditampilkan silakan un-comment) */}
          {/* <input type="hidden" name="location" value={formData.location} />
          <input type="hidden" name="languages" value={formData.languages} /> 
          */}

          <hr className="border-t-2 border-[#1e293b] mt-4 mb-4" />

          <div className="flex flex-col gap-3">
            <button
              type="submit"
              className="w-full py-3 bg-slate-900 hover:bg-slate-800 text-white text-lg font-semibold rounded-md transition-colors"
            >
              Save Changes
            </button>
            <button
              type="button"
              onClick={() => navigate('/myprofile')}
              className="w-full py-3 bg-red-500 hover:bg-red-600 text-white text-lg font-semibold rounded-md transition-colors"
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
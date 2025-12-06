import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaCertificate, FaPen } from "react-icons/fa";

const EditProfilePage = ({ user }) => {
  const navigate = useNavigate();

  // STATE FORM
  const [formData, setFormData] = useState({
    name: user.name,
    birthDate: user.birthDate || "",
    description: user.description || "",
    status: user.status || "",
    image: user.image
  });

  // HANDLER INPUT
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
  };

  // HANDLER SUBMIT
  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Data siap dikirim ke Backend:", formData);
    alert("Profile Updated! (Check Console)");
    navigate('/my-profile');
  };

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-5 pt-28 flex justify-center items-center">
      <div className="bg-white w-full max-w-7xl p-8 md:p-12 rounded-xl shadow-sm">
        
        {/* HEADER SECTION */}
        <div className="flex flex-col md:flex-row items-center justify-between px-20 gap-8 md:gap-16 mb-8">
            
            <div className="relative">
                <div className="w-40 h-40 md:w-48 md:h-48 rounded-full overflow-hidden border-4 border-gray-100">
                    <img src={formData.image} alt="Profile" className="w-full h-full object-cover" />
                </div>
                <button className="absolute bottom-2 right-2 bg-white p-2 rounded-lg border border-blue-400 text-blue-500 shadow-sm hover:bg-blue-50 transition">
                    <FaPen size={14} />
                </button>
            </div>

            <div className="flex flex-col gap-6 w-full md:w-1/2">
                <div>
                    <label className="text-gray-600 text-lg mb-1 block">Name</label>
                    <div className="rounded px-4 py-2 font-bold text-xl text-slate-900 uppercase tracking-wide">
                        {formData.name}
                    </div>
                </div>

                <div>
                    <label className="text-gray-600 text-lg mb-1 block">Rank’s</label>
                    <div className="flex items-center gap-2 justify-center">
                         <div className="relative flex items-center justify-center text-white">
                             <FaCertificate className="text-slate-900 text-4xl" /> 
                             <span className="absolute font-bold text-xs">{user.rankLevel}</span>
                        </div>
                        <h2 className="text-xl font-bold text-slate-900">{user.rank}</h2>
                    </div>
                </div>
            </div>
        </div>

        <hr className="border-t-2 border-[#1e293b] mb-8" />

        {/* FORM INPUT SECTION */}
        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
            
            {/* Birth Date */}
            <div className='text-start px-30'>
                <label className="text-gray-600 text-base mb-2 block">Birth Date</label>
                <input 
                    type="date" 
                    name="birthDate"
                    value={formData.birthDate}
                    onChange={handleChange}
                    className="w-full border border-gray-300 rounded-md px-4 py-3 text-gray-700 focus:outline-none focus:border-blue-500 transition"
                />
            </div>

            {/* Description */}
            <div className='text-start px-30'>
                <label className="text-gray-600 text-base mb-2 block">Description (likes)</label>
                <input 
                    type="text" 
                    name="description"
                    value={formData.description}
                    onChange={handleChange}
                    placeholder="Adventure, Food, Health, Bike"
                    className="w-full border border-gray-300 rounded-md px-4 py-3 text-gray-700 focus:outline-none focus:border-blue-500 transition"
                />
            </div>

            {/* Status */}
            <div className='text-start px-30'>
                <label className="text-gray-600 text-base mb-2 block">Status</label>
                <div className="relative">
                    <input 
                        type="text" 
                        name="status"
                        value={formData.status}
                        onChange={handleChange}
                        className="w-full border border-gray-300 rounded-md px-4 py-3 text-gray-700 focus:outline-none focus:border-blue-500 transition"
                    />
                </div>
            </div>

            <hr className="border-t-2 border-[#1e293b] mt-4 mb-4" />

            {/* ACTION BUTTONS */}
            <div className="flex flex-col gap-3">
                <button 
                    type="submit"
                    className="w-full py-2.5 bg-slate-900 text-white text-lg font-medium rounded-md hover:bg-slate-700 transition"
                >
                    Save
                </button>
                <button 
                    type="button"
                    onClick={() => navigate('/myprofile')}
                    className="w-full py-2.5 bg-[#ff0000] text-white text-lg font-medium rounded-md hover:bg-red-700 transition"
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
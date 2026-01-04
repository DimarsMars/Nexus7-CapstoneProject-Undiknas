import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import apiService from '../services/apiService';

const AddCategoryPage = () => {
  const [categoryName, setCategoryName] = useState('');
  const [imageFile, setImageFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const navigate = useNavigate();

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setImageFile(file);
      setPreviewUrl(URL.createObjectURL(file));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!categoryName.trim()) {
      setError('Category name cannot be empty.');
      return;
    }
    if (!imageFile) {
      setError('Please select an image.');
      return;
    }

    setLoading(true);
    setError(null);
    setSuccess(null);

    const formData = new FormData();
    formData.append('name', categoryName);
    formData.append('image', imageFile);

    try {
      const response = await apiService.postCategory(formData);
      setSuccess(`Category "${categoryName}" created successfully!`);
      setCategoryName('');
      setImageFile(null);
      setPreviewUrl(null);
      
      setTimeout(() => navigate('/categories'), 2000);
    } catch (err) {
      console.error('Error creating category:', err);
      setError(err.response?.data?.message || 'Failed to create category. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="w-full max-w-md p-8 space-y-6 bg-white rounded-lg shadow-md">
        <h2 className="text-2xl font-bold text-center text-gray-800">Create New Category</h2>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="categoryName" className="text-sm font-medium text-gray-700">
              Category Name
            </label>
            <input
              id="categoryName"
              name="categoryName"
              type="text"
              required
              className="w-full px-3 py-2 mt-1 text-gray-900 bg-gray-50 border border-gray-300 rounded-md focus:outline-none focus:ring-slate-500 focus:border-slate-500"
              placeholder="e.g., Mountains"
              value={categoryName}
              onChange={(e) => setCategoryName(e.target.value)}
            />
          </div>

          <div>
            <label htmlFor="image" className="text-sm font-medium text-gray-700">
              Category Image
            </label>
            <input
              id="image"
              name="image"
              type="file"
              accept="image/*"
              required
              onChange={handleImageChange}
              className="w-full px-3 py-2 mt-1 text-gray-900 bg-gray-50 border border-gray-300 rounded-md focus:outline-none focus:ring-slate-500 focus:border-slate-500"
            />
          </div>

          {previewUrl && (
            <div className="mt-4">
              <img src={previewUrl} alt="Image Preview" className="w-full h-auto rounded-md max-h-60 object-cover" />
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full py-2 font-bold text-white transition rounded-lg bg-[#1e293b] hover:bg-slate-700 disabled:bg-slate-500"
          >
            {loading ? 'Creating...' : 'Create Category'}
          </button>
        </form>

        {error && <p className="text-sm text-center text-red-500">{error}</p>}
        {success && <p className="text-sm text-center text-green-500">{success}</p>}

        <div className="text-center">
            <button onClick={() => navigate(-1)} className="text-sm text-slate-600 hover:underline">
                Go Back
            </button>
        </div>
      </div>
    </div>
  );
};

export default AddCategoryPage;

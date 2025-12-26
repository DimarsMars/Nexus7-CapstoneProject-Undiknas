import { FaMapMarkerAlt, FaTrash, FaRegBookmark } from "react-icons/fa";
import { useRef, useState } from 'react';

const LocationRouteCard = ({ point, index, onDelete, onEdit, onAddImage, onBookmark }) => {
  const fileInputRef = useRef(null);
  const [isEditing, setIsEditing] = useState(false);
  const [editedName, setEditedName] = useState(point.name);
  const [editedDescription, setEditedDescription] = useState(point.description || "");

  const handleAddImageClick = () => {
    fileInputRef.current.click();
  };

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        onAddImage(index, e.target.result); 
      };
      reader.readAsDataURL(file);
    }
  };

  const handleEditClick = () => {
    setEditedName(point.name);
    setEditedDescription(point.description || "");
    setIsEditing(true);
  };

  const handleSave = () => {
    onEdit(index, { name: editedName, description: editedDescription });
    setIsEditing(false);
  };

  const handleCancel = () => {
    setIsEditing(false);
  };

  return (
    <>
      <div className="bg-white p-4 rounded-lg shadow-sm border border-slate-200 flex items-start gap-5 transition hover:shadow-md">
        <input 
          type="file" 
          ref={fileInputRef} 
          onChange={handleFileChange}
          className="hidden"
          accept="image/*"
        />

        <div className="w-40 h-26 bg-slate-100 rounded-md flex items-center justify-center shrink-0">
          {point.image ? (
              <img src={point.image} alt={point.name} className="w-full h-full object-cover rounded-md" />
          ) : (
              <FaMapMarkerAlt className="text-slate-400 text-2xl" />
          )}
        </div>

        <div className="flex-1 text-left">
          <h4 className="font-bold text-slate-800 text-md mb-1">
            Lokasi {index + 1} : {point.name}
          </h4>
          <p className="text-slate-500 px-3 text-xs leading-relaxed line-clamp-2">
            {point.address}
          </p>
          <p className="text-slate-700  text-sm leading-relaxed line-clamp-2">
            {point.description}
          </p>
          
          <div className="flex flex-wrap gap-2 mt-3">
            {onEdit && (
              <button 
                onClick={handleEditClick}
                className="text-[10px] bg-slate-800 text-white px-2 py-1 rounded hover:bg-slate-700"
              >
                Edit Route
              </button>
            )}
            {onAddImage && (
              <button 
                onClick={handleAddImageClick}
                className="text-[10px] bg-slate-800 text-white px-2 py-1 rounded hover:bg-slate-700"
              >
                Add Image
              </button>
            )}
            {onDelete && (
              <button 
                onClick={() => onDelete(index)}
                className="text-[10px] bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600 flex items-center gap-1"
              >
                <FaTrash size={8} /> Delete
              </button>
            )}
          </div>
        </div>
        {onBookmark && (
            <button
                onClick={() => onBookmark(point.id)}
                className="p-2 text-gray-400 hover:text-slate-800 cursor-pointer transition self-start"
                title="Bookmark this location"
            >
                <FaRegBookmark size={20} />
            </button>
        )}
      </div>

      {isEditing && (
        <div className="fixed inset-0 bg-black/30 backdrop-blur-sm flex justify-center items-center z-50 p-4">
          <div className="bg-white p-6 rounded-lg shadow-xl w-full max-w-md">
            <h3 className="text-lg font-bold mb-4 text-slate-800">Edit Route Details</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 text-left">Location Name</label>
                <input
                  type="text"
                  value={editedName}
                  onChange={(e) => setEditedName(e.target.value)}
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-slate-500 focus:border-slate-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 text-left">Description</label>
                <textarea
                  value={editedDescription}
                  onChange={(e) => setEditedDescription(e.target.value)}
                  rows="3"
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-slate-500 focus:border-slate-500"
                ></textarea>
              </div>
            </div>
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={handleCancel}
                className="bg-red-500 text-white px-4 py-2 rounded-md hover:bg-red-600 transition"
              >
                Cancel
              </button>
              <button
                onClick={handleSave}
                className="bg-slate-800 text-white px-4 py-2 rounded-md hover:bg-slate-700 transition"
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default LocationRouteCard;
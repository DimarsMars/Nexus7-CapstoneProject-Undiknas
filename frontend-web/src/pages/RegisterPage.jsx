import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import backgroundLogin from '../assets/images/backgroundLogin.jpg';
import logoJourneysPutih from '../assets/images/logoJourneysPutih.png';
import { FaEye, FaEyeSlash } from "react-icons/fa";

const RegisterPage = () => {
  const [email, setEmail] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  
  const navigate = useNavigate();
  const { register } = useAuth();

  const handleRegister = async (e) => {
    e.preventDefault();
    setError('');
    if (password !== confirmPassword) {
      return setError("Passwords do not match.");
    }
    if (password.length < 6) {
      return setError("Password must be at least 6 characters long.");
    }
    
    setLoading(true);
    try {
      await register(email, password, username);
      navigate('/homepage');
    } catch (err) {
      const errorMessage = err.response?.data?.error?.message || err.message || "An unexpected error occurred.";
      setError(errorMessage.replace(/_/g, ' '));
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div id="register" className="text-gray-800">
      <div className='flex flex-row w-full h-screen'>

        <div className="flex-2 relative">
          <img src={backgroundLogin} alt="background" className='w-full h-full object-cover' />
          <div className="absolute inset-0 bg-black/30"></div>
          <div className='absolute inset-0 flex flex-col justify-center items-center text-white'>
            <img src={logoJourneysPutih} alt="logoJourneys" className='w-xl h-auto' />
            <p className='text-3xl mt-5'>Your travelling friends</p>
          </div>
        </div>

       <div className="flex-1 flex items-center justify-center px-10">
          <form onSubmit={handleRegister} className="w-full h-full py-16 flex flex-col justify-between">
            <div>
              <h2 className="text-4xl font-bold mb-8 text-center">Register</h2> 
            </div>

            <div className='text-start font-semibold px-10'>       
              <div className="mb-4">
                <label className="block mb-1">Email</label>
                <input
                  type="email"
                  placeholder='email'
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  className="w-full border rounded-lg px-3 py-2"
                />
              </div>

              <div className="mb-4">
                <label className="block mb-1">Username</label>
                <input
                  type="text"
                  placeholder='username'
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                  className="w-full border rounded-lg px-3 py-2"
                />
              </div>

{/* INPUT PASSWORD */}
              <div className="mb-4">
                <label className="block mb-1">Password</label>
                <div className="relative">
                  <input
                    type={showPassword ? "text" : "password"}
                    placeholder='password'
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    className="w-full border rounded-lg px-3 py-2 pr-10 focus:outline-none focus:ring-2 focus:ring-gray-400"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 cursor-pointer"
                  >
                    {showPassword ? <FaEyeSlash size={20} /> : <FaEye size={20} />}
                  </button>
                </div>
              </div>

              {/* INPUT CONFIRM PASSWORD */}
              <div className="mb-4">
                <label className="block mb-1">Confirm Password</label>
                <div className="relative">
                  <input
                    type={showConfirmPassword ? "text" : "password"}
                    placeholder='confirm password'
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                    className="w-full border rounded-lg px-3 py-2 pr-10 focus:outline-none focus:ring-2 focus:ring-gray-400"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 cursor-pointer"
                  >
                    {showConfirmPassword ? <FaEyeSlash size={20} /> : <FaEye size={20} />}
                  </button>
                </div>
              </div>

              {error && <p className="text-red-500 text-sm text-center">{error}</p>}
            </div>

            <div>
              <button type="submit" disabled={loading} className="w-30 bg-gray-900 text-white py-2 rounded-lg hover:bg-gray-700 disabled:bg-gray-400 transition">
                {loading ? 'Registering...' : 'Register'}
              </button>

              <div className="flex justify-center gap-1 mt-4 text-sm">
                <span className="text-gray-600">Have an account?</span>
                <a href="/login" className="text-blue-600 hover:underline">Login</a>
              </div>
            </div>

          </form>
        </div>

      </div>
    </div>
  )
}

export default RegisterPage;
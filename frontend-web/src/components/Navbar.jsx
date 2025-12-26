import { HashLink as Link } from 'react-router-hash-link'; 
import { useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import logoJourneys from '../assets/images/logoJourneys.png';
import iconSearch from '../assets/icons/iconSearch.png';

const Navbar = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const { isAuthenticated, logout } = useAuth();

    const getLinkClass = (path, hash = '') => {
        const baseStyle = "hover:text-slate-700 hover:font-bold transition-all duration-200 cursor-pointer";
        const isActive = location.pathname === path && location.hash === hash;

        return isActive 
            ? `text-black font-bold ${baseStyle}` 
            : `text-gray-500 font-medium ${baseStyle}`;
    };

    return (
        <header className='fixed left-0 w-full top-0 z-500 bg-white/80 backdrop-blur-md shadow-md transition-all duration-300'>
            <nav className='max-w-7xl mx-auto px-5 md:px-5 py-4 flex justify-between items-center'>
                
                {/* Logo */}
                <Link smooth to="/homepage#top">
                    <img src={logoJourneys} alt="Journeys Logo" className='h-8 md:h-10 w-auto hover:opacity-80 transition' />
                </Link>

                {/* Search Bar (visible only if logged in) */}
                {isAuthenticated && (
                    <div className='hidden md:flex items-center bg-gray-100 rounded-full px-4 py-2 w-1/3 border border-transparent focus-within:border-gray-400 focus-within:bg-white transition-all'>
                        <input 
                            type="text" 
                            placeholder="Search destination..." 
                            className='bg-transparent outline-none w-full text-sm text-gray-700 placeholder-gray-400'
                        />
                        <button className='ml-2 p-1 hover:bg-gray-200 rounded-full transition'>
                            <img src={iconSearch} alt="Search" className='h-4 w-4 opacity-60'/>
                        </button>
                    </div>
                )}

                {/* Menu */}
                <div className='hidden md:flex flex-row items-center gap-8 text-md'>
                    {isAuthenticated ? (
                        <>
                            <Link smooth to="/homepage#" className={getLinkClass('/homepage', '')}>Home</Link>
                            <Link smooth to="/explore" className={getLinkClass('/explore')}>Explore</Link>
                            <Link smooth to="/maps" className={getLinkClass('/maps')}>Maps</Link>
                            {/* <Link smooth to="/runtrip" className={getLinkClass('/runtrip')}>Run Trip</Link> */}
                            <Link smooth to="/history" className={getLinkClass('/history')}>History</Link>
                            <Link smooth to="/myprofile" className={getLinkClass('/myprofile')}>Profile</Link>
                        </>
                    ) : (
                        <button onClick={() => navigate('/login')} className="bg-slate-900 text-white text-sm font-medium px-4 py-1.5 rounded-lg hover:bg-gray-700 transition-colors">
                            Login
                        </button>
                    )}
                </div>
                
            </nav>
        </header>
    )
}

export default Navbar;
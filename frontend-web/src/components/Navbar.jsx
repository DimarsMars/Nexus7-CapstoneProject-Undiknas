import { NavHashLink as Link } from 'react-router-hash-link'
import logoJourneys from '../assets/images/logoJourneys.png'
import iconSearch from '../assets/icons/iconSearch.png'

const Navbar = () => {
    return (
        <header className='fixed left-0 w-full top-0 z-70 bg-white/80 backdrop-blur-md shadow-md transition-all duration-300'>
            <nav className='max-w-7xl mx-auto px-5 md:px-5 py-4 flex justify-between items-center'>
                <Link smooth to="/#top">
                    <img src={logoJourneys} alt="Journeys Logo" className='h-8 md:h-10 w-auto hover:opacity-80 transition' />
                </Link>
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

                <div className='hidden md:flex flex-row gap-8 text-gray-500 font-medium text-md'>
                    <Link smooth to="/homepage" className="hover:text-slate-700 hover:font-bold transition-all duration-200">
                        Home
                    </Link>
                    <Link smooth to="/explore" className="hover:text-slate-700 hover:font-bold transition-all duration-200">
                        Explore
                    </Link>
                    <Link smooth to="/homepage#history" className="hover:text-slate-700 hover:font-bold transition-all duration-200">
                        History
                    </Link>
                    <Link smooth to="/myprofile" className="hover:text-slate-700 hover:font-bold transition-all duration-200">
                        Profile
                    </Link>
                </div>
                
            </nav>
        </header>
    )
}

export default Navbar
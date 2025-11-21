import { NavHashLink as Link } from 'react-router-hash-link'
import logoJourneys from '../assets/images/logoJourneys.png'
import iconSearch from '../assets/icons/iconSearch.png'

const Navbar = () => {
    return (
        <header id='navbar' className='bg-white shadow-sm sticky top-0 z-50'>
            <nav className='container mx-auto px-30 py-3 flex justify-between items-center'>
                <div>
                    <img src={logoJourneys} alt="Logo" className='h-10 w-auto' />
                </div>

                <div className='px-5 py-2 rounded-2xl border border-gray-400 text-gray-400'>
                    <div className='flex gap-60 items-center justify-center'>
                        <p>Search Bar</p>
                        <img src={iconSearch} alt="Search" className='h-4 w-auto'/>
                    </div>
                </div>

                <div className='flex flex-row gap-10 text-gray-500 font-medium'>
                    <Link to="" className="hover:font-bold hover:text-slate-600">Home</Link>
                    <Link to="" className="hover:font-bold hover:text-slate-600">Explore</Link>
                    <Link to="" className="hover:font-bold hover:text-slate-600">History</Link>
                    <Link to="" className="hover:font-bold hover:text-slate-600">Profile</Link>
                </div>
            </nav>
        </header>
    )
}

export default Navbar
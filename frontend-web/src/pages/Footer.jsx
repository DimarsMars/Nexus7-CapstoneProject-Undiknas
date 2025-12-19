import { HashLink as Link } from 'react-router-hash-link' 
import logoJourneysPutih from '../assets/images/logoJourneysPutih.png'

const Footer = () => {
    return (
        <section className="bg-slate-900 text-white py-15">
            <div className="container mx-auto px-30 flex flex-col lg:flex-row justify-between gap-10">
                
                <div className="flex flex-col justify-between space-y-8 lg:space-y-0">
                    <div className="mb-6 lg:mb-0">
                        <img src={logoJourneysPutih} alt="Journeys Logo" className="w-48" />
                    </div>

                    <div className="mt-auto">
                        <h3 className="font-bold text-lg mb-1">Contact Us</h3>
                        <p className="text-gray-300 font-light">journeys.app.travel@gmail.com</p>
                    </div>
                </div>

                <div className="flex flex-wrap gap-10 lg:gap-30 text-base font-normal text-left">
                    
                    {/* Kolom 1 */}
                    <div className="flex flex-col space-y-4">
                        <Link smooth to="/homepage#" className="hover:text-blue-900 transition">Home</Link>
                        <Link smooth to="/maps#" className="hover:text-blue-900 transition">Create your plan</Link>
                        <Link smooth to="/categories#" className="hover:text-blue-900 transition">Categories</Link>
                    </div>

                    {/* Kolom 2 */}
                    <div className="flex flex-col space-y-4">
                        <Link smooth to="/explore#" className="hover:text-blue-900 transition">Explore</Link>
                        <Link smooth to="#" className="hover:text-blue-900 transition">Culture</Link>
                        <Link smooth to="#" className="hover:text-blue-900 transition">Eatery</Link>
                        <Link smooth to="#" className="hover:text-blue-900 transition">Health</Link>
                        <Link smooth to="#" className="hover:text-blue-900 transition">Craft's</Link>
                    </div>

                    {/* Kolom 3 */}
                    <div className="flex flex-col space-y-4">
                        <Link smooth to="/bookmarked#" className="hover:text-blue-900 transition">History</Link>
                        <Link smooth to="#" className="hover:text-blue-900 transition">Past Trip</Link>
                        <Link smooth to="/bookmarked#" className="hover:text-blue-900 transition">Favorite</Link>
                    </div>

                    {/* Kolom 4 */}
                    <div className="flex flex-col space-y-4">
                        <Link smooth to="/myprofile#" className="hover:text-blue-900 transition">Profile</Link>
                    </div>

                </div>
            </div>
        </section>
    )
}

export default Footer
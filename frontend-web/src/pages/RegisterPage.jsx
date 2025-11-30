import backgroundLogin from '../assets/images/backgroundLogin.jpg'
import logoJourneysPutih from '../assets/images/logoJourneysPutih.png'

const LoginPage = () => {
  return (
    <div id="login" className="text-gray-800">
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
          <div className="w-full h-full py-25 flex flex-col justify-between">
            <div>
              <h2 className="text-4xl font-bold mb-8 text-center">Register</h2> 
            </div>

            <div className='text-start font-semibold px-10'>       
              <div className="mb-4">
                <label className="block mb-1">Email</label>
                <input
                  type="email"
                  placeholder='email'
                  className="w-full border rounded-lg px-3 py-2"
                />
              </div>

              <div className="mb-4">
                <label className="block mb-1">Username</label>
                <input
                  type="text"
                  placeholder='username'
                  className="w-full border rounded-lg px-3 py-2"
                />
              </div>

              <div className="mb-4">
                <label className="block mb-1">Password</label>
                <input
                  type="password"
                  placeholder='password'
                  className="w-full border rounded-lg px-3 py-2"
                />
              </div>

              <div className="mb-4">
                <label className="block mb-1">Confirm Password</label>
                <input
                  type="password"
                  placeholder='confirm password'
                  className="w-full border rounded-lg px-3 py-2"
                />
              </div>
            </div>

            <div>
              <button className="w-30 bg-gray-900 text-white py-2 rounded-lg">
                Register
              </button>

              <div className="flex justify-center gap-1 mt-4 text-sm">
                <span className="text-gray-600">Have an account?</span>
                <a href="/login" className="text-blue-600 hover:underline">Login</a>
              </div>
            </div>

          </div>
        </div>

      </div>
    </div>
  )
}

export default LoginPage
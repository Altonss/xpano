# DO NOT MODIFY: Auto-generated by the gen_installer.py script from the .github/workflows/windows.yml Github Action

$env:BUILD_TYPE = 'Release'
$env:SDL_VERSION = 'release-2.26.3'
$env:OPENCV_VERSION = '4.7.0'
$env:CATCH_VERSION = 'v3.3.1'
$env:SPDLOG_VERSION = 'v1.11.0'
$env:GENERATOR = 'Ninja Multi-Config'

git submodule update --init


git clone https://github.com/opencv/opencv.git --depth 1 --branch $env:OPENCV_VERSION
cd opencv
cmake -B build -G "$env:GENERATOR" `
  -DBUILD_SHARED_LIBS=OFF `
  -DCMAKE_INSTALL_PREFIX=install `
  @(Get-Content ../misc/build/opencv_minimal_flags.txt)
cmake --build build --target install --config Release
cd ..


git clone https://github.com/libsdl-org/SDL.git --depth 1 --branch $env:SDL_VERSION
cd sdl
cmake -B build -G "$env:GENERATOR" `
  -DBUILD_SHARED_LIBS=OFF `
  -DCMAKE_INSTALL_PREFIX=install `
  -DSDL_FORCE_STATIC_VCRT=ON `
  -DSDL_MISC=OFF
cmake --build build --target install --config Release
cd ..


git clone https://github.com/catchorg/Catch2.git catch --depth 1 --branch $env:CATCH_VERSION
cd catch
cmake -B build -G "$env:GENERATOR" `
  -DCMAKE_INSTALL_PREFIX=install `
  -DBUILD_TESTING=OFF `
  -DCMAKE_POLICY_DEFAULT_CMP0091=NEW `
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
cmake --build build --target install --config $env:BUILD_TYPE
cd ..


git clone https://github.com/gabime/spdlog.git --depth 1 --branch $env:SPDLOG_VERSION
cd spdlog
cmake -B build -G "$env:GENERATOR" `
  -DCMAKE_INSTALL_PREFIX=build/install `
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
cmake --build build --target install --config $env:BUILD_TYPE
cd ..

New-Item -Name "licenses" -ItemType "directory"
Copy-Item "sdl/LICENSE.txt" -Destination "licenses/sdl-license.txt"
Copy-Item "spdlog/LICENSE" -Destination "licenses/spdlog-license.txt"

cmake -B build -G "$env:GENERATOR" `
  -DBUILD_TESTING=ON `
  -DXPANO_EXTRA_LICENSES=licenses `
  -DXPANO_STATIC_VCRT=ON `
  -DCMAKE_INSTALL_PREFIX=install `
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON `
  -DSDL2_DIR="sdl/install/cmake" `
  -DOpenCV_STATIC=ON `
  -DOpenCV_DIR="opencv/install" `
  -Dspdlog_DIR="spdlog/build/install/lib/cmake/spdlog" `
  -DCatch2_DIR="../catch/install/lib/cmake/Catch2" `

cmake --build build --config $env:BUILD_TYPE --target install
cd build
ctest -C $env:BUILD_TYPE
cd ..

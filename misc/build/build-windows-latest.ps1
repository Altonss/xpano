# DO NOT MODIFY: Auto-generated by the gen_installer.py script from the .github/workflows/test.yml Github Action

$env:BUILD_TYPE = 'Release'
$env:SDL_VERSION = 'release-2.28.5'
$env:OPENCV_VERSION = '4.8.1'
$env:CATCH_VERSION = 'v3.4.0'
$env:SPDLOG_VERSION = 'v1.12.0'
$env:EXIV2_VERSION = 'v0.28.1'
$env:GENERATOR = 'Ninja Multi-Config'

git submodule update --init


git clone https://github.com/opencv/opencv.git --depth 1 --branch $env:OPENCV_VERSION
cd opencv
cmake -B build -G "$env:GENERATOR" `
  -DBUILD_SHARED_LIBS=OFF `
  -DCMAKE_INSTALL_PREFIX=install `
  @(Get-Content ../misc/build/opencv-minimal-flags.txt)
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


git clone https://github.com/Exiv2/exiv2.git --depth 1 --branch $env:EXIV2_VERSION
cd exiv2
cmake -B build -G "$env:GENERATOR" `
  -DBUILD_SHARED_LIBS=OFF `
  -DEXIV2_ENABLE_DYNAMIC_RUNTIME=OFF `
  -DCMAKE_INSTALL_PREFIX=install `
  @(Get-Content ../misc/build/exiv2-minimal-flags.txt)
cmake --build build --target install --config $env:BUILD_TYPE
cd ..

New-Item -Name "licenses" -ItemType "directory"
Copy-Item "sdl/LICENSE.txt" -Destination "licenses/sdl-license.txt"
Copy-Item "spdlog/LICENSE" -Destination "licenses/spdlog-license.txt"
Copy-Item "exiv2/COPYING" -Destination "licenses/exiv2-license.txt"

$cwd = (Get-Location).Path -replace "\\", "/"
cmake -B build -G "$env:GENERATOR" `
  -DBUILD_TESTING=ON `
  -DXPANO_EXTRA_LICENSES=licenses `
  -DXPANO_STATIC_VCRT=ON `
  -DCMAKE_INSTALL_PREFIX=install `
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON `
  -DSDL2_DIR="${cwd}/sdl/install/cmake" `
  -DOpenCV_STATIC=ON `
  -DOpenCV_DIR="${cwd}/opencv/install" `
  -Dspdlog_DIR="${cwd}/spdlog/build/install/lib/cmake/spdlog" `
  -DCatch2_DIR="${cwd}/catch/install/lib/cmake/Catch2" `
  -Dexiv2_ROOT="${cwd}/exiv2/install"

cmake --build build --config $env:BUILD_TYPE --target install
cd build
ctest -C $env:BUILD_TYPE --output-on-failure
cd ..

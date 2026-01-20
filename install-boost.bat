setlocal

if not defined RIME_ROOT set RIME_ROOT=%CD%

if not defined boost_version set boost_version=1.89.0

if not defined boost_tarball set boost_tarball=boost_%boost_version:.=_%

if not defined BOOST_ROOT set BOOST_ROOT=%RIME_ROOT%\deps\boost-%boost_version%

if exist "%BOOST_ROOT%\libs" goto boost_found
for %%I in ("%BOOST_ROOT%\.") do set src_dir=%%~dpI
rem download boost source
aria2c https://archives.boost.io/release/%boost_version%/source/%boost_tarball%.7z -d %src_dir%
pushd %src_dir%
7z x %boost_tarball%.7z
ren %boost_tarball% boost-%boost_version%
cd boost-%boost_version%

rem Create user-config.jam
echo using clang-win : : clangcl.exe : > user-config.jam
echo     ^<cxxflags^>"-std=c++14" >> user-config.jam
echo     ^<cxxflags^>"-fms-compatibility-version=19.29" >> user-config.jam
echo     ^<cxxflags^>"-D_CRT_SECURE_NO_WARNINGS" >> user-config.jam
echo     ; >> user-config.jam

call .\bootstrap.bat

rem Build Boost
b2.exe ^
    toolset=clang-win ^
    address-model=64 ^
    variant=release ^
    link=static ^
    threading=multi ^
    runtime-link=static ^
    --build-type=complete ^
    -j%NUMBER_OF_PROCESSORS% ^
    stage

popd
:boost_found

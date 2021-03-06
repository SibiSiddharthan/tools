# Tools
This repository contains a bunch of CMake scripts for legacy yet widely used software.

## Requirements:
* CMake (preferably bleeding edge)
* Git (use Git-for-Windows on Windows)
* python3+

## Supported Platforms:
* Windows 10 - gcc, clang, MSVC
* Linux - gcc, clang

>Note: Windows is primarily tested with clang and MSVC

## Instructions:
``` 
cd to `package`
python prepare.py
cd .build/`package`
mkdir build
cd build
cmake .. -G `your-favourite generator` -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=`your-install-location`
Build, Test and Install
```
>Prefer to use the same install location for all the packages

## Notes:
1) For the tools or libraries which have dependencies, build and install the dependencies first.
2) Few of the packages make use of gnulib. To build and install gnulib refer here https://github.com/SibiSiddharthan/gnulib_with_cmake.
3) Many of the CMake scripts make use of the helper scrpits located in the cmake subfolder.
4) If a package has specific instructions refer to the README.md in its subfolder if it exists.
5) The libiconv subfolder contains the script for building libiconv only, iconv.exe is not built since it depends on libintl(optionally).
prepare.py for libintl downloads the source code for the entire gettext package, but builds only libintl. To build iconv.exe use the separate folder iconv.
Running the tests for iconv means you test libiconv also.

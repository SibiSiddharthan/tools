cmake_minimum_required(VERSION 3.13)
project(libiconv
		VERSION 1.16
		LANGUAGES C)


option(BUILD_SHARED_LIBS "Build Shared Library" ON)
add_compile_definitions(HAVE_CONFIG_H)

set(PACKAGE \"libiconv\")
set(PACKAGE_BUGREPORT \"\")
set(PACKAGE_NAME \"libiconv\")
set(PACKAGE_STRING \"libiconv\ ${PROJECT_VERSION}\")
set(PACKAGE_TARNAME \"libiconv\")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"${PROJECT_VERSION}\")
set(VERSION \"${PROJECT_VERSION}\")

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
include(UtilityFunctions)
include(CheckCSourceCompiles)
include(inline)
include(visibility)

if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
	set(HAVE_VISIBILITY 0) #need to have dllexport
endif()

check_c_headers(dlfcn.h	mach-o/dyld.h stdint.h strings.h wchar.h langinfo.h stdlib.h inttypes.h memory.h unistd.h sys/stat.h sys/types.h)
check_functions(copy_file_range iconv setlocale getc_unlocked _NSGetExecutablePath wcrtomb mbrtowc symlink)
set(CMAKE_EXTRA_INCLUDE_FILES "wchar.h;wctype.h")
check_types(ssize_t mode_t wchar_t)
unset(CMAKE_EXTRA_INCLUDE_FILES)

if(NOT HAVE_SSIZE_T)
	set(ssize_t int)
endif()

if(NOT HAVE_MODE_T)
	set(mode_t int)
endif()

#default options
set(ENABLE_EXTRA 1)
set(ENABLE_RELOCATABLE 1)
set(WORDS_LITTLEENDIAN 1) #x86


check_c_source_compiles("
#include <errno.h>
#ifndef EILSEQ
no
#endif
int main(){return 0;}"
HAVE_EILSEQ)
if(NOT HAVE_EILSEQ)
set(EILSEQ ENOENT)
endif()

check_c_source_compiles("
#include <langinfo.h>
int
main ()
{
	char* cs = nl_langinfo(CODESET); return !cs;
	return 0;
}"
HAVE_LANGINFO_CODESET)

set(ICONV_CONST " ")
configure_file(libiconv-config.h.in config.h)
configure_file(libcharset/include/localcharset.h.build.in localcharset.h @ONLY)
configure_file(libcharset/include/localcharset.h.in ${CMAKE_CURRENT_BINARY_DIR}/install/localcharset.h @ONLY)
configure_file(libcharset/include/libcharset.h.in libcharset.h)

if(HAVE_WCRTOMB OR HAVE_MBRTOWC)
	set(USE_MBSTATE_T 1)
else()
	set(USE_MBSTATE_T 0)
endif()
if(HAVE_WCHAR_H)
	set(BROKEN_WCHAR_H 0)
else()
	set(BROKEN_WCHAR_H 1)
endif()

if(WIN32)
	set(DLL_VARIABLE "__declspec(dllexport)")
endif()

configure_file(include/iconv.h.build.in iconv.h @ONLY)

if(WIN32)
	set(DLL_VARIABLE "__declspec(dllimport)")
endif()

configure_file(include/iconv.h.in ${CMAKE_CURRENT_BINARY_DIR}/install/iconv.h @ONLY)

##
# libcharset
##
set(charset_SOURCES 
	libcharset/lib/localcharset.c libcharset/lib/relocatable-stub.c ${CMAKE_CURRENT_BINARY_DIR}/libcharset.h )
add_library(charset ${charset_SOURCES})
target_compile_definitions(charset PRIVATE BUILDING_LIBCHARSET)
if(BUILD_SHARED_LIBS)
	target_compile_definitions(charset PRIVATE BUILDING_DLL DLL_EXPORT PIC)
	set_target_properties(charset PROPERTIES RUNTIME_OUTPUT_NAME "libcharset-1" ARCHIVE_OUTPUT_NAME "charset")
endif()
if(NOT MSVC)
	target_compile_options(charset PRIVATE -fvisibility=hidden)
endif()
target_include_directories(charset PRIVATE ${CMAKE_CURRENT_BINARY_DIR})


##
# libiconv
##
set(iconv_SOURCES
	lib/iconv.c lib/relocatable.c ${CMAKE_CURRENT_BINARY_DIR}/iconv.h ${CMAKE_CURRENT_BINARY_DIR}/localcharset.h)

if(WIN32)
	list(APPEND iconv_SOURCES woe32dll/iconv-exports.c)
endif()

add_library(libiconv ${iconv_SOURCES})
target_compile_definitions(libiconv PRIVATE BUILDING_LIBICONV ENABLE_RELOCATABLE=1 IN_LIBRARY NO_XMALLOC 
		set_relocation_prefix=libiconv_set_relocation_prefix relocate=libiconv_relocate relocate2=libiconv_relocate2)
if(BUILD_SHARED_LIBS)
	target_compile_definitions(libiconv PRIVATE BUILDING_DLL DLL_EXPORT PIC)
	set_target_properties(libiconv PROPERTIES RUNTIME_OUTPUT_NAME "libiconv-${PROJECT_VERSION}" ARCHIVE_OUTPUT_NAME "iconv")
endif()
if(NOT MSVC)
	target_compile_options(libiconv PRIVATE -fvisibility=hidden)
endif()
target_include_directories(libiconv PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(libiconv charset)

install(TARGETS charset libiconv
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		RUNTIME DESTINATION bin)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/iconv.h ${CMAKE_CURRENT_BINARY_DIR}/install/localcharset.h ${CMAKE_CURRENT_BINARY_DIR}/libcharset.h DESTINATION include)
file(GLOB man_html "man/*3.html")
install(FILES ${man_html} DESTINATION share/doc)
set(man3_files man/iconv.3 man/iconv_close.3 man/iconv_open.3 man/iconv_open_into.3 man/iconvctl.3)
install(FILES ${man3_files} DESTINATION share/man/man3)


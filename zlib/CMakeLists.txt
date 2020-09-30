cmake_minimum_required(VERSION 3.12)
project(zlib
		VERSION 1.2.11
		LANGUAGES C)

option(BUILD_SHARED_LIBS "Build Shared Library" ON)

if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
endif()

include(CheckTypeSize)
include(CheckFunctionExists)
include(CheckIncludeFile)

check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(stddef.h HAVE_STDDEF_H)
check_include_file(unistd.h HAVE_UNISTD_H)
check_include_file(stdarg.h HAVE_STDARG_H)


if(HAVE_STDINT_H)
	add_compile_definitions(HAVE_STDINT_H)
endif()
if(HAVE_STDDEF_H)
	add_compile_definitions(HAVE_STDDEF_H)
endif()
if(HAVE_STDARG_H)
	add_compile_definitions(HAVE_STDARG_H)
endif()
if(HAVE_SYS_TYPES_H)
	add_compile_definitions(HAVE_SYS_TYPES_H)
endif()
if(HAVE_UNISTD_H)
	add_compile_definitions(HAVE_UNISTD_H)
endif()

# For large files
check_type_size(off64_t OFF64_T)
if(HAVE_OFF64_T)
   add_compile_definitions(_LARGEFILE64_SOURCE=1)
endif()

check_function_exists(fseeko HAVE_FSEEKO)
if(NOT HAVE_FSEEKO)
	add_compile_definitions(NO_FSEEKO)
endif()

configure_file(zconf.h.cmakein ${CMAKE_CURRENT_BINARY_DIR}/zconf.h)

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

set(z_SOURCES
adler32.c compress.c crc32.c deflate.c gzclose.c
gzlib.c gzread.c gzwrite.c inflate.c infback.c
inftrees.c inffast.c trees.c uncompr.c zutil.c
zlib.h ${CMAKE_CURRENT_BINARY_DIR}/zconf.h)

add_library(z ${z_SOURCES})
set_target_properties(z PROPERTIES PUBLIC_HEADER "zlib.h;${CMAKE_CURRENT_BINARY_DIR}/zconf.h")
if(BUILD_SHARED_LIBS)
	target_compile_definitions(z PRIVATE ZLIB_DLL)
	set_target_properties(z PROPERTIES RUNTIME_OUTPUT_NAME "zlib-${PROJECT_VERSION}")
endif()

INSTALL(TARGETS z
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		PUBLIC_HEADER DESTINATION include)

install(FILES zlib.3
		DESTINATION share/man/man3)

install(FILES zlib.3.pdf
		DESTINATION share/doc/zlib)

include(CTest)
if(BUILD_TESTING)

add_executable(example test/example.c)
target_link_libraries(example z)
add_test(example example)

add_executable(minigzip test/minigzip.c)
target_link_libraries(minigzip z)

if(HAVE_OFF64_T)
	add_executable(example64 test/example.c)
	target_link_libraries(example64 z)
	target_compile_definitions(example64 PRIVATE _FILE_OFFSET_BITS=64)
	add_test(example64 example64)

	add_executable(minigzip64 test/minigzip.c)
	target_link_libraries(minigzip64 z)
	target_compile_definitions(minigzip64 PRIVATE _FILE_OFFSET_BITS=64)
endif()

endif()


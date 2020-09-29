cmake_minimum_required(VERSION 3.12)
project(BZip2 
		VERSION 1.0.8
		LANGUAGES C)

add_compile_definitions(_FILE_OFFSET_BITS=64)
option(BUILD_SHARED_LIBS "Build Shared Library" ON)

if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
endif()

set(libbzip_SOURCES
blocksort.c huffman.c crctable.c bzlib.h
randtable.c compress.c decompress.c bzlib.c)

add_library(bz2 ${libbzip_SOURCES})
set_target_properties(bz2 PROPERTIES PUBLIC_HEADER bzlib.h)
if(BUILD_SHARED_LIBS)
	set_target_properties(bz2 PROPERTIES RUNTIME_OUTPUT_NAME "bz2-${PROJECT_VERSION}")
	target_compile_definitions(bz2 PRIVATE BZ_BUILD_DLL)
endif()


add_executable(bzip2 bzip2.c)
target_link_libraries(bzip2 bz2)

add_executable(bzip2recover bzip2recover.c)
target_link_libraries(bzip2recover bz2)

install(TARGETS bzip2 bz2 bzip2recover
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		PUBLIC_HEADER DESTINATION include)

install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/bzip2${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_INSTALL_PREFIX}/bin/bunzip2${CMAKE_EXECUTABLE_SUFFIX})")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/bzip2${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_INSTALL_PREFIX}/bin/bzcat${CMAKE_EXECUTABLE_SUFFIX})")

install(PROGRAMS bzgrep bzmore bzdiff
		DESTINATION bin)

install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/bzgrep ${CMAKE_INSTALL_PREFIX}/bin/bzegrep)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/bzgrep ${CMAKE_INSTALL_PREFIX}/bin/bzfgrep)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/bzmore ${CMAKE_INSTALL_PREFIX}/bin/bzless)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/bzdiff ${CMAKE_INSTALL_PREFIX}/bin/bzcmp)")

install(FILES bzip2.1 bzgrep.1 bzmore.1 bzdiff.1
		DESTINATION share/man/man1)

install(CODE "file(WRITE ${CMAKE_INSTALL_PREFIX}/man/man1/bzegrep.1 \".so man1/bzgrep.1\")")
install(CODE "file(WRITE ${CMAKE_INSTALL_PREFIX}/man/man1/bzfgrep.1 \".so man1/bzgrep.1\")")
install(CODE "file(WRITE ${CMAKE_INSTALL_PREFIX}/man/man1/bzmore.1 \".so man1/bzless.1\")")
install(CODE "file(WRITE ${CMAKE_INSTALL_PREFIX}/man/man1/bzdiff.1 \".so man1/bzcmp.1\")")

install(FILES manual.html manual.pdf
		DESTINATION share/doc/bzip2)

include(CTest)
if(BUILD_TESTING)
	find_program(SH_EXE sh)
	add_test(bztest ${SH_EXE} ${CMAKE_CURRENT_SOURCE_DIR}/bztest.sh)
	set_tests_properties(bztest PROPERTIES ENVIRONMENT "srcdir=${CMAKE_CURRENT_SOURCE_DIR};build_dir=${CMAKE_CURRENT_BINARY_DIR}")
endif()
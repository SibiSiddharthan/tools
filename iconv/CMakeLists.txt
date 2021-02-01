#[[
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
]]

cmake_minimum_required(VERSION 3.13)
project(iconv 
		VERSION 1.16
		LANGUAGES C)

set(PACKAGE \"iconv\")
set(PACKAGE_BUGREPORT \"\")
set(PACKAGE_NAME \"iconv\")
set(PACKAGE_STRING \"iconv\ ${PROJECT_VERSION}\")
set(PACKAGE_TARNAME \"iconv\")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"${PROJECT_VERSION}\")
set(VERSION \"${PROJECT_VERSION}\")

add_compile_definitions(HAVE_CONFIG_H)
if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
endif()

include(CheckCSourceCompiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckIncludeFile)
find_package(Iconv REQUIRED)
find_package(Intl)

check_function_exists(setlocale HAVE_SETLOCALE)
check_include_file(unistd.h HAVE_UNISTD_H)
check_symbol_exists(strerror_r string.h HAVE_DECL_STRERROR_R)
check_symbol_exists(__argv stdlib.h HAVE_DECL___ARGV)

if(WIN32 AND NOT HAVE_UNISTD_H)
	configure_file(unistd.h.in unistd.h)
endif()

if(Intl_FOUND)
	set(ENABLE_NLS 1)
endif()

check_c_source_compiles("
#include <stddef.h>
wchar_t foo = (wchar_t)'\\\\0';
int
main ()
{
	return 0;
}"
HAVE_WCHAR_T)

set(ICONV_CONST " ")
set(ENABLE_RELOCATABLE 1)
configure_file(iconv-config.h.in config.h)

configure_file(srclib/uniwidth.in.h uniwidth.h)
configure_file(srclib/unitypes.in.h unitypes.h)

add_library(icrt STATIC srclib/binary-io.c srclib/xmalloc.c srclib/uniwidth/width.c srclib/basename-lgpl.c srclib/xstrdup.c  
srclib/safe-read.c srclib/getprogname.c srclib/error.c srclib/progname.c srclib/progreloc.c)
target_compile_definitions(icrt PRIVATE EXEEXT="${CMAKE_EXECUTABLE_SUFFIX}")
target_include_directories(icrt PUBLIC srclib ${CMAKE_CURRENT_BINARY_DIR} ${Intl_INCLUDE_DIRS})

add_executable(iconv src/iconv.c srclib/relocatable.c)
target_link_libraries(iconv icrt ${Intl_LIBRARIES} Iconv::Iconv)
target_compile_definitions(iconv PRIVATE INSTALLDIR="bin" INSTALLPREFIX="/" LOCALEDIR="../share/locale"
		DEPENDS_ON_LIBICONV DEPENDS_ON_LIBINTL )

install(TARGETS iconv 
		RUNTIME DESTINATION bin)
install(FILES man/iconv.1.html DESTINATION share/doc)
install(FILES man/iconv.1 DESTINATION share/man/man1)

file(GLOB gmo_files "po/*.gmo")
foreach(gmo ${gmo_files})
	string(REPLACE ${CMAKE_CURRENT_SOURCE_DIR}/po "" gmo ${gmo})
	string(REPLACE ".gmo" "" gmo ${gmo})
	install(FILES po/${gmo}.gmo DESTINATION share/locale/${gmo}/LC_MESSAGES/)
	install(CODE "file(RENAME ${CMAKE_INSTALL_PREFIX}/share/locale/${gmo}/LC_MESSAGES/${gmo}.gmo ${CMAKE_INSTALL_PREFIX}/share/locale/${gmo}/LC_MESSAGES/libiconv.mo)")
endforeach()


include(CTest)
find_program(SH_EXE sh)

set(iconv_tests table-from table-to test-shiftseq test-to-wchar genutf8 gengb18030z)
foreach(t ${iconv_tests})
	add_executable(${t} tests/${t})
	target_link_libraries(${t} icrt Iconv::Iconv)
	set_target_properties(${t} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
endforeach()

add_test(test-shiftseq ${CMAKE_CURRENT_BINARY_DIR}/tests/test-shiftseq)
add_test(test-to-wchar ${CMAKE_CURRENT_BINARY_DIR}/tests/test-to-wchar)

set(TEST_EXE ${CMAKE_CURRENT_BINARY_DIR}/iconv${CMAKE_EXECUTABLE_SUFFIX})
configure_file(check-stateful.sh.in check-stateful.sh @ONLY) 

set(stateful_checks
	UCS-2BE UCS-2LE UCS-4BE UCS-4LE UTF-16 UTF-16BE UTF-16LE UTF-32 UTF-32BE UTF-32LE UTF-7 CP1255 CP1258 TCVN ISO-2022-JP 
	ISO-2022-JP-2 ISO-2022-JP-1 ISO-2022-JP-MS ISO-2022-CN ISO-2022-CN-EXT 
	HZ BIG5-HKSCS:1999 BIG5-HKSCS:2001 BIG5-HKSCS:2004 BIG5-HKSCS:2008 ISO-2022-KR ISO-2022-JP-3)


foreach(i ${stateful_checks})
 	add_test(${i}-stateful ${SH_EXE} check-stateful.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests ${i})
endforeach()

set(TABLE_FROM ${CMAKE_CURRENT_BINARY_DIR}/tests/table-from)
set(TABLE_TO ${CMAKE_CURRENT_BINARY_DIR}/tests/table-to)
configure_file(check-stateless.sh.in check-stateless.sh @ONLY) 

set(stateless_checks
	ASCII ISO-8859-1 ISO-8859-2 ISO-8859-3 ISO-8859-4 ISO-8859-5 ISO-8859-6 ISO-8859-7 ISO-8859-8 ISO-8859-9 ISO-8859-10 ISO-8859-11 ISO-8859-13 
	ISO-8859-14 ISO-8859-15 ISO-8859-16 KOI8-R KOI8-U KOI8-RU CP1250 CP1251 CP1252 CP1253 CP1254 CP1255 CP1256 CP1257 CP1258 CP850 CP862 CP866 
	CP1131 MacRoman MacCentralEurope MacIceland MacCroatian MacRomania MacCyrillic MacUkraine MacGreek MacTurkish MacHebrew MacArabic MacThai HP-ROMAN8
	NEXTSTEP ARMSCII-8 Georgian-Academy Georgian-PS KOI8-T PT154 RK1048 MuleLao-1 CP1133 TIS-620 CP874 VISCII TCVN ISO646-JP JIS_X0201 ISO646-CN 
	ISO-IR-165 EUC-JP SHIFT_JIS CP932 EUC-CN GBK CP936 EUC-TW BIG5 CP950 BIG5-HKSCS:1999 BIG5-HKSCS:2001 BIG5-HKSCS:2004 BIG5-HKSCS:2008 EUC-KR
	CP949 JOHAB CP856 CP922 CP1046 CP1124 CP1129 CP1161 CP1162 CP1163 DEC-KANJI DEC-HANYU CP437 CP737 CP775 CP852 CP853 CP855 CP857 CP858 CP860
	CP861 CP863 CP864 CP865 CP869 CP1125 EUC-JISX0213 SHIFT_JISX0213 BIG5-2003 TDS565 ATARIST RISCOS-LATIN1)

foreach(i ${stateless_checks})
 	add_test(${i}-stateless ${SH_EXE} check-stateless.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests ${i})
endforeach()

configure_file(check-translit.sh.in check-translit.sh @ONLY) 
configure_file(check-translitfailure.sh.in check-translitfailure.sh @ONLY) 
configure_file(check-subst.sh.in check-subst.sh @ONLY) 

add_test(translit1 ${SH_EXE} check-translit.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests Quotes UTF-8 ISO-8859-1)
add_test(translit2 ${SH_EXE} check-translit.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests Quotes UTF-8 ASCII)
add_test(translit3 ${SH_EXE} check-translit.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests Translit1 ISO-8859-1 ASCII)
add_test(translitfailure ${SH_EXE} check-translitfailure.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests TranslitFail1 ISO-8859-1 ASCII)
add_test(subst ${SH_EXE} check-subst.sh)

add_custom_command(OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/UTF-8.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.IRREVERSIBLE.TXT
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/tests/genutf8 > UTF-8.TXT
				COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/tests/GB18030-BMP.TXT > t-GB18030.TXT && ${CMAKE_CURRENT_BINARY_DIR}/tests/gengb18030z >> t-GB18030.TXT && cat ${CMAKE_CURRENT_BINARY_DIR}/t-GB18030.TXT | sort > ${CMAKE_CURRENT_BINARY_DIR}/GB18030.TXT
				COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/tests/GB18030.IRREVERSIBLE.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.IRREVERSIBLE.TXT
				DEPENDS genutf8 gengb18030z)

add_custom_target(iconv_test_files ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/UTF-8.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.IRREVERSIBLE.TXT)

add_test(genutf8 ${SH_EXE} check-stateless.sh ${CMAKE_CURRENT_BINARY_DIR} UTF-8)
add_test(gengb18030z ${SH_EXE} check-stateless.sh ${CMAKE_CURRENT_BINARY_DIR} GB18030)

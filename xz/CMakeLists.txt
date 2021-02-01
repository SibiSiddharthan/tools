#[[
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
]]

cmake_minimum_required(VERSION 3.15)
project(xz 
		VERSION 5.2.5
		LANGUAGES C)

option(BUILD_SHARED_LIBS "Build Shared Library" ON)

add_compile_definitions(HAVE_CONFIG_H)
if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE TUKLIB_DOSLIKE)
endif()

add_compile_definitions(LOCALEDIR="../share/locale")

set(PACKAGE \"xz\")
set(PACKAGE_BUGREPORT \"lasse.collin@tukaani.org\")
set(PACKAGE_NAME \"XZ\ Utils\")
set(PACKAGE_STRING \"XZ\ Utils\ 5.2.5\")
set(PACKAGE_TARNAME \"xz\")
set(PACKAGE_URL \"https://tukaani.org/xz/\")
set(PACKAGE_VERSION \"5.2.5\")
set(VERSION \"5.2.5\")

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
include(UtilityFunctions)
include(CheckCSourceCompiles)
include(CheckStructHasMember)
include(LargeFiles)
include(visibility)

find_package(Iconv)
find_package(Intl)

if(Intl_FOUND)
  set(ENABLE_NLS 1)
endif()


set(STDC_HEADERS 1)

check_types(_Bool int32_t int64_t uint16_t uint32_t uint64_t uint8_t uintptr_t size_t mode_t ssize_t)

if(NOT HAVE_MODE_T)
set(mode_t int)
endif()

if(NOT HAVE_SSIZE_T)
set(ssize_t "long\ long")
endif()

check_c_headers(byteswap.h dlfcn.h getopt.h immintrin.h inttypes.h limits.h memory.h sha2.h sha256.h stdbool.h stdint.h stdlib.h strings.h string.h 
sys/byteorder.h sys/capsicum.h sys/endian.h sys/param.h sys/stat.h sys/time.h sys/types.h unistd.h CommonCrypto/CommonDigest.h)

check_functions(futimens futimes futimesat getopt_long posix_fadvise pthread_condattr_setclock SHA256Init SHA256_Init utime utimes wcwidth _futime clock_gettime
CFLocaleCopyCurrent CFLocaleCopyPreferredLanguages CFPreferencesCopyAppValue CC_SHA256_INIT SHA256Init SHA256_Init)

check_symbol_exists(CLOCK_MONOTONIC "time.h" HAVE_DECL_CLOCK_MONOTONIC)
check_symbol_exists(program_invocation_name "errno.h" HAVE_DECL_PROGRAM_INVOCATION_NAME)
check_symbol_exists(_mm_movemask_epi8 "immintrin.h" HAVE__MM_MOVEMASK_EPI8)
check_symbol_exists(optreset "getopt.h" HAVE_OPTRESET)

check_struct_has_member("struct stat" "st_atimensec" "sys/types.h;sys/stat.h" HAVE_STRUCT_STAT_ST_ATIMENSEC)
check_struct_has_member("struct stat" "st_atimespec.tv_nsec" "sys/types.h;sys/stat.h" HAVE_STRUCT_STAT_ST_ATIMESPEC_TV_NSEC)
check_struct_has_member("struct stat" "st_atim.st__tim.tv_nsec" "sys/types.h;sys/stat.h" HAVE_STRUCT_STAT_ST_ATIM_ST__TIM_TV_NSEC)
check_struct_has_member("struct stat" "st_atim.tv_nsec" "sys/types.h;sys/stat.h" HAVE_STRUCT_STAT_ST_ATIM_TV_NSEC)
check_struct_has_member("struct stat" "st_uatime" "sys/types.h;sys/stat.h" HAVE_STRUCT_STAT_ST_UATIME)

check_c_source_compiles("
#include <wchar.h>
int
main ()
{
wchar_t wc;
char const s[] = \"\";
size_t n = 1;
mbstate_t state;
return ! (sizeof state && (mbrtowc) (&wc, s, n, &state));
  ;
  return 0;
}"
HAVE_MBRTOWC)

check_c_source_compiles("
#include <pthread.h>
int
main ()
{
int i = PTHREAD_PRIO_INHERIT;
return i;
}"
HAVE_PTHREAD_PRIO_INHERIT)

check_c_source_compiles("
#include <pthread.h>
int
main ()
{
int attr = PTHREAD_CREATE_JOINABLE; return attr /* ; */
  ;
  return 0;
}"
PTHREAD_CREATE_JOINABLE_attr1)
if(PTHREAD_CREATE_JOINABLE_attr1)
	set(PTHREAD_CREATE_JOINABLE PTHREAD_CREATE_JOINABLE)
else()
check_c_source_compiles("
#include <pthread.h>
int
main ()
{
int attr = PTHREAD_CREATE_UNDETACHED; return attr /* ; */
  ;
  return 0;
}"
PTHREAD_CREATE_JOINABLE_attr2)
	if(PTHREAD_CREATE_JOINABLE_attr2)
		set(PTHREAD_CREATE_JOINABLE PTHREAD_CREATE_UNDETACHED)
	endif()
endif()


check_c_source_compiles("
#include <byteswap.h>
int
main(void)
{
	bswap_16(42);
	return 0;
}"
HAVE_BSWAP_16)

check_c_source_compiles("
#include <byteswap.h>
int
main(void)
{
	bswap_32(42);
	return 0;
}"
HAVE_BSWAP_32)

check_c_source_compiles("
#include <byteswap.h>
int
main(void)
{
	bswap_64(42);
	return 0;
}"
HAVE_BSWAP_64)

check_c_source_compiles("
int
main ()
{
__builtin_bswap16(1);
__builtin_bswap32(1);
__builtin_bswap64(1);
  ;
  return 0;
}"
HAVE___BUILTIN_BSWAPXX)

check_c_source_compiles("
int
main ()
{
__builtin_assume_aligned(\"\", 1);
  ;
  return 0;
}"
HAVE___BUILTIN_ASSUME_ALIGNED)


check_c_source_compiles("
#include <sched.h>
int
main(void)
{
	cpu_set_t cpu_mask;
	sched_getaffinity(0, sizeof(cpu_mask), &cpu_mask);
	return CPU_COUNT(&cpu_mask);
}"
TUKLIB_CPUCORES_SCHED_GETAFFINITY)

check_c_source_compiles("
#include <sys/param.h>
#include <sys/cpuset.h>

int
main(void)
{
	cpuset_t set;
	cpuset_getaffinity(CPU_LEVEL_WHICH, CPU_WHICH_PID, -1,
			sizeof(set), &set);
	return 0;
}"
TUKLIB_CPUCORES_CPUSET)

check_c_source_compiles("
#ifdef __QNX__
compile error
#endif
#include <sys/types.h>
#ifdef HAVE_SYS_PARAM_H
#	include <sys/param.h>
#endif
#include <sys/sysctl.h>
int
main(void)
{
	int name[2] = { CTL_HW, HW_NCPU };
	int cpus;
	size_t cpus_size = sizeof(cpus);
	sysctl(name, 2, &cpus, &cpus_size, NULL, 0);
	return 0;
}
"
TUKLIB_CPUCORES_SYSCTL)

check_c_source_compiles("
#include <unistd.h>
int
main(void)
{
	long i;
#ifdef _SC_NPROCESSORS_ONLN
	/* Many systems using sysconf() */
	i = sysconf(_SC_NPROCESSORS_ONLN);
#else
	/* IRIX */
	i = sysconf(_SC_NPROC_ONLN);
#endif
	return 0;
}"
TUKLIB_CPUCORES_SYSCONF)

check_c_source_compiles("
#include <sys/param.h>
#include <sys/pstat.h>

int
main(void)
{
	struct pst_dynamic pst;
	pstat_getdynamic(&pst, sizeof(pst), 1, 0);
	(void)pst.psd_proc_cnt;
	return 0;
}"
TUKLIB_CPUCORES_PSTAT_GETDYNAMIC)

check_c_source_compiles("
#include <sys/systemcfg.h>

int
main(void)
{
	(void)_system_configuration.physmem;
	return 0;
}"
TUKLIB_PHYSMEM_AIX)

check_c_source_compiles("
#include <unistd.h>
int
main(void)
{
	long i;
	i = sysconf(_SC_PAGESIZE);
	i = sysconf(_SC_PHYS_PAGES);
	return 0;
}"
TUKLIB_PHYSMEM_SYSCONF)

check_c_source_compiles("
#include <sys/types.h>
#ifdef HAVE_SYS_PARAM_H
#	include <sys/param.h>
#endif
#include <sys/sysctl.h>
int
main(void)
{
	int name[2] = { CTL_HW, HW_PHYSMEM };
	unsigned long mem;
	size_t mem_ptr_size = sizeof(mem);
	sysctl(name, 2, &mem, &mem_ptr_size, NULL, 0);
	return 0;
}"
TUKLIB_PHYSMEM_SYSCTL)


check_c_source_compiles("
#include <sys/sysinfo.h>
#include <machine/hal_sysinfo.h>

int
main(void)
{
	int memkb;
	int start = 0;
	getsysinfo(GSI_PHYSMEM, (caddr_t)&memkb, sizeof(memkb), &start);
	return 0;
}"
TUKLIB_PHYSMEM_GETSYSINFO)

check_c_source_compiles("
#include <sys/param.h>
#include <sys/pstat.h>

int
main(void)
{
	struct pst_static pst;
	pstat_getstatic(&pst, sizeof(pst), 1, 0);
	(void)pst.physical_memory;
	(void)pst.page_size;
	return 0;
}"
TUKLIB_PHYSMEM_PSTAT_GETSTATIC)


check_c_source_compiles("
#include <invent.h>
int
main(void)
{
	inv_state_t *st = NULL;
	setinvent_r(&st);
	getinvent_r(st);
	endinvent_r(st);
	return 0;
}"
TUKLIB_PHYSMEM_GETINVENT_R)


check_c_source_compiles("
#include <sys/sysinfo.h>
int
main(void)
{
	struct sysinfo si;
	sysinfo(&si);
	return 0;
}"
TUKLIB_PHYSMEM_SYSINFO)


if(UNIX)
	set(MYTHREAD_POSIX 1)
endif()

if(WIN32)
	set(MYTHREAD_VISTA 1)
endif()

if(NOT HAVE_GETOPT_H OR NOT HAVE_GETOPT_LONG)
	set(__GETOPT_PREFIX rpl_)
	configure_file(lib/getopt.in.h getopt.h)
endif()

set(ASSUME_RAM 128)
set(TUKLIB_FAST_UNALIGNED_ACCESS 1)
set(HAVE_CHECK_CRC32 1)
set(HAVE_CHECK_CRC64 1)
set(HAVE_CHECK_SHA256 1)

set(HAVE_DECODERS 1)
set(HAVE_DECODER_ARM 1)
set(HAVE_DECODER_ARMTHUMB 1)
set(HAVE_DECODER_DELTA 1)
set(HAVE_DECODER_IA64 1)
set(HAVE_DECODER_LZMA1 1)
set(HAVE_DECODER_LZMA2 1)
set(HAVE_DECODER_POWERPC 1)
set(HAVE_DECODER_SPARC 1)
set(HAVE_DECODER_X86 1)

set(HAVE_ENCODERS 1)
set(HAVE_ENCODER_ARM 1)
set(HAVE_ENCODER_ARMTHUMB 1)
set(HAVE_ENCODER_DELTA 1)
set(HAVE_ENCODER_IA64 1)
set(HAVE_ENCODER_LZMA1 1)
set(HAVE_ENCODER_LZMA2 1)
set(HAVE_ENCODER_POWERPC 1)
set(HAVE_ENCODER_SPARC 1)
set(HAVE_ENCODER_X86 1)

set(HAVE_MF_BT2 1)
set(HAVE_MF_BT3 1)
set(HAVE_MF_BT4 1)
set(HAVE_MF_HC3 1)
set(HAVE_MF_HC4 1)

if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(NDEBUG 1)
endif()

option(SMALL_OPTIMIZE OFF)
configure_file(xz-config.h.in config.h)

set(common_SOURCES
common/mythread.h
common/sysdefs.h
common/tuklib_common.h
common/tuklib_config.h
common/tuklib_exit.c
common/tuklib_exit.h
common/tuklib_gettext.h
common/tuklib_integer.h
common/tuklib_mbstr_fw.c
common/tuklib_mbstr.h
common/tuklib_mbstr_width.c
common/tuklib_open_stdxxx.c
common/tuklib_open_stdxxx.h
common/tuklib_progname.c
common/tuklib_progname.h)

list(TRANSFORM common_SOURCES PREPEND "src/")

if(NOT HAVE_GETOPT_H OR NOT HAVE_GETOPT_LONG)
	list(APPEND common_SOURCES lib/getopt.c lib/getopt1.c)
endif()

if(WIN32)
	list(APPEND common_SOURCES lib/gettimeofday.c)
endif()

if(WIN32 AND NOT HAVE_UNISTD_H)
	configure_file(unistd.h.in unistd.h)
endif()

if(NOT HAVE_SYS_TIME_H)
	configure_file(sys_time.h.in sys/time.h)
endif()

add_library(common STATIC ${common_SOURCES})
target_include_directories(common PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${Intl_INCLUDE_DIRS} ${Iconv_INCLUDE_DIRS})

set(liblzma_SOURCES
##### common
common/common.c 
common/common.h 
common/memcmplen.h 
common/block_util.c 
common/easy_preset.c 
common/easy_preset.h 
common/filter_common.c 
common/filter_common.h 
common/hardware_physmem.c 
common/index.c 
common/index.h 
common/stream_flags_common.c 
common/stream_flags_common.h 
common/vli_size.c
common/hardware_cputhreads.c
common/alone_encoder.c 
common/block_buffer_encoder.c 
common/block_buffer_encoder.h 
common/block_encoder.c 
common/block_encoder.h 
common/block_header_encoder.c 
common/easy_buffer_encoder.c 
common/easy_encoder.c 
common/easy_encoder_memusage.c 
common/filter_buffer_encoder.c 
common/filter_encoder.c 
common/filter_encoder.h 
common/filter_flags_encoder.c 
common/index_encoder.c 
common/index_encoder.h 
common/stream_buffer_encoder.c 
common/stream_encoder.c 
common/stream_flags_encoder.c 
common/vli_encoder.c
common/outqueue.c 
common/outqueue.h 
common/stream_encoder_mt.c
common/alone_decoder.c 
common/alone_decoder.h 
common/auto_decoder.c 
common/block_buffer_decoder.c 
common/block_decoder.c 
common/block_decoder.h 
common/block_header_decoder.c 
common/easy_decoder_memusage.c 
common/filter_buffer_decoder.c 
common/filter_decoder.c 
common/filter_decoder.h 
common/filter_flags_decoder.c 
common/index_decoder.c 
common/index_hash.c 
common/stream_buffer_decoder.c 
common/stream_decoder.c 
common/stream_decoder.h 
common/stream_flags_decoder.c 
common/vli_decoder.c
##### check
check/check.c 
check/check.h 
check/crc_macros.h
check/crc32_table.c  #conditional use this or crc32_small.c based on small_optim
check/crc32_table_le.h 
check/crc32_table_be.h
check/crc32_fast.c
check/crc64_table.c 
check/crc64_table_le.h 
check/crc64_table_be.h
check/crc64_fast.c
check/sha256.c
##### delta
delta/delta_common.c 
delta/delta_common.h 
delta/delta_private.h
delta/delta_encoder.c 
delta/delta_encoder.h
delta/delta_decoder.c 
delta/delta_decoder.h
###### lz
lz/lz_encoder.c 
lz/lz_encoder.h 
lz/lz_encoder_hash.h 
lz/lz_encoder_hash_table.h 
lz/lz_encoder_mf.c
lz/lz_decoder.c 
lz/lz_decoder.h
###### lzma
lzma/lzma_encoder_presets.c
lzma/fastpos.h 
lzma/lzma_encoder.h 
lzma/lzma_encoder.c 
lzma/lzma_encoder_private.h 
lzma/lzma_encoder_optimum_fast.c 
lzma/lzma_encoder_optimum_normal.c
lzma/fastpos_table.c
lzma/lzma_decoder.c 
lzma/lzma_decoder.h
lzma/lzma2_encoder.c 
lzma/lzma2_encoder.h
lzma/lzma2_decoder.c 
lzma/lzma2_decoder.h
###### rangecoder
rangecoder/range_encoder.h 
rangecoder/price.h 
rangecoder/price_table.c
rangecoder/range_decoder.h
##### simple
simple/simple_coder.c 
simple/simple_coder.h 
simple/simple_private.h
simple/simple_encoder.c 
simple/simple_encoder.h
simple/simple_decoder.c 
simple/simple_decoder.h
simple/x86.c
simple/powerpc.c
simple/ia64.c
simple/arm.c
simple/armthumb.c
simple/sparc.c)

list(TRANSFORM liblzma_SOURCES PREPEND "src/liblzma/")
list(APPEND liblzma_SOURCES src/common/tuklib_physmem.h src/common/tuklib_cpucores.h
src/common/tuklib_cpucores.c src/common/tuklib_physmem.c)

add_library(lzma ${liblzma_SOURCES})
target_compile_definitions(lzma PRIVATE TUKLIB_SYMBOL_PREFIX=lzma_)
target_include_directories(lzma PUBLIC ${CMAKE_CURRENT_BINARY_DIR} lib src/common
	src/liblzma/api src/liblzma/common src/liblzma/check src/liblzma/lz 
	src/liblzma/rangecoder src/liblzma/lzma src/liblzma/delta src/liblzma/simple ${Intl_INCLUDE_DIRS} ${Iconv_INCLUDE_DIRS})
target_link_libraries(lzma common ${Intl_LIBRARIES} ${Iconv_LIBRARIES})

if(BUILD_SHARED_LIBS)
	target_compile_definitions(lzma PRIVATE DLL_EXPORT)
	set_target_properties(lzma PROPERTIES RUNTIME_OUTPUT_NAME "lzma-${PROJECT_VERSION}")
endif()

add_executable(lzmainfo src/lzmainfo/lzmainfo.c)
target_link_libraries(lzmainfo lzma)

add_executable(xzdec src/xzdec/xzdec.c)
target_compile_definitions(xzdec PRIVATE TUKLIB_GETTEXT=0)
target_link_libraries(xzdec lzma)

add_executable(lzmadec src/xzdec/xzdec.c)
target_compile_definitions(lzmadec PRIVATE LZMADEC)
target_link_libraries(lzmadec lzma)

set(xz_SOURCES
args.c 
args.h 
coder.c 
coder.h 
file_io.c 
file_io.h 
hardware.c 
hardware.h 
main.c 
main.h 
message.c 
message.h 
mytime.c 
mytime.h 
options.c 
options.h 
private.h 
signals.c 
signals.h 
suffix.c 
suffix.h 
util.c 
util.h 
list.c
list.h)

list(TRANSFORM xz_SOURCES PREPEND "src/xz/")

add_executable(xz ${xz_SOURCES})
target_link_libraries(xz lzma)

set(PACKAGE_NAME "XZ Utils")
set(VERSION "5.2.5")
set(xz xz${CMAKE_EXECUTABLE_SUFFIX})

configure_file(src/scripts/xzdiff.in xzdiff @ONLY)
configure_file(src/scripts/xzgrep.in xzgrep @ONLY)
configure_file(src/scripts/xzless.in xzless @ONLY)
configure_file(src/scripts/xzmore.in xzmore @ONLY)


install(TARGETS lzma xz xzdec lzmadec lzmainfo
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib)

install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xz${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_INSTALL_PREFIX}/bin/lzma${CMAKE_EXECUTABLE_SUFFIX})")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xz${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_INSTALL_PREFIX}/bin/xzcat${CMAKE_EXECUTABLE_SUFFIX})")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xz${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_INSTALL_PREFIX}/bin/lzcat${CMAKE_EXECUTABLE_SUFFIX})")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xz${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_INSTALL_PREFIX}/bin/unlzma${CMAKE_EXECUTABLE_SUFFIX})")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xz${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_INSTALL_PREFIX}/bin/unxz${CMAKE_EXECUTABLE_SUFFIX})")

install(DIRECTORY src/liblzma/api/
	DESTINATION include
	FILES_MATCHING PATTERN "*.h")

set(scripts xzdiff xzgrep xzless xzmore)
list(TRANSFORM scripts PREPEND "${CMAKE_CURRENT_BINARY_DIR}/")
install(PROGRAMS ${scripts}	DESTINATION bin)

install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzdiff ${CMAKE_INSTALL_PREFIX}/bin/lzdiff)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzdiff ${CMAKE_INSTALL_PREFIX}/bin/xzcmp)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzdiff ${CMAKE_INSTALL_PREFIX}/bin/lzcmp)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzgrep ${CMAKE_INSTALL_PREFIX}/bin/lzgrep)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzgrep ${CMAKE_INSTALL_PREFIX}/bin/xzegrep)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzgrep ${CMAKE_INSTALL_PREFIX}/bin/xzfgrep)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzgrep ${CMAKE_INSTALL_PREFIX}/bin/lzegrep)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzgrep ${CMAKE_INSTALL_PREFIX}/bin/lzfgrep)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzdiff ${CMAKE_INSTALL_PREFIX}/bin/lzdiff)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzdiff ${CMAKE_INSTALL_PREFIX}/bin/lzdiff)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzless ${CMAKE_INSTALL_PREFIX}/bin/lzless)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/bin/xzmore ${CMAKE_INSTALL_PREFIX}/bin/lzmore)")

file(GLOB gmo_files "po/*.gmo")
foreach(gmo ${gmo_files})
	string(REPLACE ${CMAKE_CURRENT_SOURCE_DIR}/po "" gmo ${gmo})
	string(REPLACE ".gmo" "" gmo ${gmo})
	install(FILES po/${gmo}.gmo DESTINATION share/locale/${gmo}/LC_MESSAGES/)
	install(CODE "file(RENAME ${CMAKE_INSTALL_PREFIX}/share/locale/${gmo}/LC_MESSAGES/${gmo}.gmo ${CMAKE_INSTALL_PREFIX}/share/locale/${gmo}/LC_MESSAGES/xz.mo)")
endforeach()

install(DIRECTORY doc/man/
	DESTINATION share/doc/xz/)

install(FILES src/xz/xz.1 src/xzdec/xzdec.1 src/lzmainfo/lzmainfo.1 src/scripts/xzdiff.1 
		src/scripts/xzgrep.1 src/scripts/xzless.1 src/scripts/xzmore.1
		DESTINATION share/man/man1/)

install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzdec.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzmadec.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xz.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzma.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xz.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzcat.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xz.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzcat.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xz.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/unlzma.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xz.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/unxz.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzdiff.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzdiff.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzdiff.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzcmp.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzdiff.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzcmp.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzgrep.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzgrep.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzgrep.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzegrep.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzgrep.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzfgrep.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzgrep.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzegrep.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzgrep.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzfgrep.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzdiff.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzdiff.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzdiff.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzdiff.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzless.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzless.1)")
install(CODE "file(CREATE_LINK ${CMAKE_INSTALL_PREFIX}/share/man/man1/xzmore.1 ${CMAKE_INSTALL_PREFIX}/share/man/man1/lzmore.1)")

include(CTest)
find_program(SH_EXE sh)

add_executable(create_compress_files tests/create_compress_files.c)
target_link_libraries(create_compress_files lzma)

set(tests check stream_flags filter_flags block_header index bcj_exact_size)

foreach(t ${tests})
	add_executable(test_${t} tests/test_${t}.c)
	target_link_libraries(test_${t} lzma)
	add_test(test_${t} test_${t})
endforeach()

configure_file(test_files.sh.in test_files.sh @ONLY)
add_test(test_files sh ${CMAKE_CURRENT_BINARY_DIR}/test_files.sh)

configure_file(test_compress.sh.in test_compress.sh @ONLY)
add_test(test_compress sh ${CMAKE_CURRENT_BINARY_DIR}/test_compress.sh)
set_tests_properties(test_compress PROPERTIES SKIP_RETURN_CODE 77)

configure_file(test_scripts.sh.in test_scripts.sh @ONLY)
add_test(test_scripts sh ${CMAKE_CURRENT_BINARY_DIR}/test_scripts.sh)

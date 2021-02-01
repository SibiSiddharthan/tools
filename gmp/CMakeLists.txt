#[[
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
]]

cmake_minimum_required(VERSION 3.13)
project(gmp
		VERSION 6.2.0
		LANGUAGES C ASM)

set(PACKAGE "gmp")
set(PACKAGE_BUGREPORT "gmp-bugs@gmplib.org,\ see\ https://gmplib.org/manual/Reporting-Bugs.html")
set(PACKAGE_NAME "GNU\ MP")
set(PACKAGE_STRING "GNU\ MP\ ${PROJECT_VERSION}")
set(PACKAGE_TARNAME "gmp")
set(PACKAGE_URL "http://www.gnu.org/software/gmp/")
set(PACKAGE_VERSION "${PROJECT_VERSION}")
set(VERSION "${PROJECT_VERSION}")

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(DONT_USE_ASM "Don't use any assembly implementation" ON) # -O3 seems to generate more succint code

add_compile_definitions(HAVE_CONFIG_H)
find_program(M4_EXE m4)

if(MSVC OR NOT M4_EXE OR DONT_USE_ASM)
	set(DONT_USE_ASM ON)
	set(NO_ASM 1)
endif()

if(WIN32)
	set(HOST_DOS64 1)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
endif()

set(WANT_FFT 1)#default
set(WANT_TMP_ALLOCA 1) #default

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
include(UtilityFunctions)
include(CheckCSourceCompiles)
include(CheckStructHasMember)
include(CheckCCompilerFlag)
include(alloca)
include(inline)
include(restrict)
include(TimeWithSysTime)

check_c_headers(dlfcn.h fcntl.h float.h inttypes.h invent.h langinfo.h locale.h nl_types.h
nl_types.h stdint.h stdlib.h strings.h string.h machine/hal_sysinfo.h memory.h
sys/attributes.h sys/iograph.h sys/mman.h sys/param.h sys/processor.h sys/pstat.h sys/resource.h sys/stat.h
sys/sysctl.h sys/sysinfo.h sys/syssgi.h sys/systemcfg.h sys/time.h sys/times.h sys/types.h
unistd.h time.h)

check_functions(alarm attr_get clock clock_gettime cputime getpagesize getrusage
gettimeofday getsysinfo localeconv memset mmap mprotect nl_langinfo
obstack_vprintf popen processor_info pstat_getprocessor raise
read_real_time sigaction sigaltstack sigstack syssgi strchr strerror
strnlen strtol strtoul sysconf sysctl sysctlbyname times vsnprintf)

check_functions_declarations(fgetc fscanf optarg ungetc vfprintf sys_errlist sys_nerr)

check_struct_has_member("struct pst_processor" psp_iticksperclktick sys/pstat.h HAVE_PSP_ITICKSPERCLKTICK)

check_types("long double" "long long" stack_t ptrdiff_t quad_t uint_least32_t intmax_t intptr_t
unsigned "unsigned long" "unsigned short" "void *" "long long int")

#true for most systems
math(EXPR SIZEOF_MP_LIMB_T "${SIZEOF_VOID_P}")

#works with gcc and clang and msvc
set(LSYM_PREFIX "L")

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

check_c_source_compiles("
#include <sys/types.h>
#include <signal.h>

int
main ()
{
	return *(signal (0, 0)) (0) == 1;
	return 0;
}"
RETSIGTYPE_TMP)
if(RETSIGTYPE_TMP)
	set(RETSIGTYPE "int")
else()
	set(RETSIGTYPE "void")
endif()

check_c_source_compiles("
int foo (int x) __attribute__ ((const));
int
main ()
{
  return 0;
}"
HAVE_ATTRIBUTE_CONST)

check_c_source_compiles("
void *foo (int x) __attribute__ ((malloc));
int
main ()
{
  return 0;
}"
HAVE_ATTRIBUTE_MALLOC)

check_c_source_compiles("
typedef int SItype __attribute__ ((mode (SI)));
int
main ()
{
  return 0;
}"
HAVE_ATTRIBUTE_MODE)

check_c_source_compiles("
void foo (int x) __attribute__ ((noreturn));
int
main ()
{
  return 0;
}"
HAVE_ATTRIBUTE_NORETURN)

check_c_source_compiles("
void hid() __attribute__ ((visibility(\"hidden\")));
void hid() {}
void pub() __attribute__ ((alias(\"hid\")));
int
main ()
{
  return 0;
}"
HAVE_HIDDEN_ALIAS)

include(HostCPUArch)
set(GMP_COMPILE_FLAGS ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}})
set(GMP_DEFINES -D__GMP_WITHIN_GMP -DHAVE_CONFIG_H )
set(GMP_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

set(GMP_NAIL_BITS 0)
math(EXPR GMP_LIMB_BITS "${SIZEOF_VOID_P}*8")
set(CC "${CMAKE_C_COMPILER_ID}")
set(CFLAGS "${GMP_COMPILE_FLAGS}")
set(DEFN_LONG_LONG_LIMB "#define _LONG_LONG_LIMB 1")

if(BUILD_SHARED_LIBS)
	set(LIBGMP_DLL 1)
else()
	set(LIBGMP_DLL 1)
endif()

set(HAVE_HOST_CPU_FAMILY_powerpc 0)
set(HAVE_HOST_CPU_FAMILY_power 0)
configure_file(gmp-h.in gmp.h @ONLY)
configure_file(gmp-config.h.in config.h)
set(CONFIG_TOP_SRCDIR ${CMAKE_CURRENT_SOURCE_DIR})
if(WIN32 AND NOT HAVE_UNISTD_H)
configure_file(unistd.h.in unistd.h)
endif()


if(DONT_USE_ASM)
	include(mpn-generic)
else()
	configure_file(m4-config.in config.m4 @ONLY NEWLINE_STYLE LF)
	include(mpn-asm)
endif()


add_executable(gen-fib gen-fib.c)
add_executable(gen-fac gen-fac.c)
add_executable(gen-bases gen-bases.c)
add_executable(gen-trialdivtab gen-trialdivtab.c)
add_executable(gen-jacobitab gen-jacobitab.c)
add_executable(gen-psqr gen-psqr.c)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/fac_table.h
					COMMAND gen-fac ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/fac_table.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/fib_table.h ${CMAKE_CURRENT_BINARY_DIR}/fib_table.c
					COMMAND gen-fib header ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/fib_table.h
					COMMAND gen-fib table ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/fib_table.c)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.h ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.c
					COMMAND gen-bases header ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.h
					COMMAND gen-bases table ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.c)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/trialdivtab.h
					COMMAND gen-trialdivtab ${GMP_LIMB_BITS} 8000 > ${CMAKE_CURRENT_BINARY_DIR}/trialdivtab.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jacobitab.h
					COMMAND gen-jacobitab  > ${CMAKE_CURRENT_BINARY_DIR}/jacobitab.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/perfsqr.h
					COMMAND gen-psqr ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/mpn/perfsqr.h)

add_custom_target(gmp_gen
				DEPENDS  ${CMAKE_CURRENT_BINARY_DIR}/fac_table.h ${CMAKE_CURRENT_BINARY_DIR}/fib_table.h ${CMAKE_CURRENT_BINARY_DIR}/fib_table.c
				${CMAKE_CURRENT_BINARY_DIR}/mp_bases.h ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.c ${CMAKE_CURRENT_BINARY_DIR}/trialdivtab.h
				${CMAKE_CURRENT_BINARY_DIR}/jacobitab.h ${CMAKE_CURRENT_BINARY_DIR}/mpn/perfsqr.h )


set(mpf_SOURCES
init.c init2.c inits.c set.c set_ui.c set_si.c set_str.c set_d.c set_z.c
set_q.c iset.c iset_ui.c iset_si.c iset_str.c iset_d.c clear.c clears.c
get_str.c dump.c size.c eq.c reldiff.c sqrt.c random2.c inp_str.c out_str.c
add.c add_ui.c sub.c sub_ui.c ui_sub.c mul.c mul_ui.c div.c div_ui.c
cmp.c cmp_d.c cmp_z.c cmp_si.c cmp_ui.c mul_2exp.c div_2exp.c abs.c neg.c get_d.c
get_d_2exp.c set_dfl_prec.c set_prc.c set_prc_raw.c get_dfl_prec.c get_prc.c
ui_div.c sqrt_ui.c
pow_ui.c urandomb.c swap.c get_si.c get_ui.c int_p.c
ceilfloor.c trunc.c
fits_sint.c fits_slong.c fits_sshort.c
fits_uint.c fits_ulong.c fits_ushort.c
fits_s.h fits_u.h)

list(TRANSFORM mpf_SOURCES PREPEND "mpf/")

set(mpq_SOURCES
abs.c aors.c canonicalize.c clear.c clears.c
cmp.c cmp_si.c cmp_ui.c div.c equal.c
get_d.c get_den.c get_num.c get_str.c
init.c inits.c inp_str.c inv.c md_2exp.c mul.c neg.c out_str.c
set.c set_den.c set_num.c set_si.c set_str.c set_ui.c set_z.c set_d.c
set_f.c swap.c)

list(TRANSFORM mpq_SOURCES PREPEND "mpq/")

set(mpz_SOURCES
aors.h aors_ui.h fits_s.h mul_i.h
2fac_ui.c
add.c add_ui.c abs.c aorsmul.c aorsmul_i.c and.c array_init.c
bin_ui.c bin_uiui.c cdiv_q.c
cdiv_q_ui.c cdiv_qr.c cdiv_qr_ui.c cdiv_r.c cdiv_r_ui.c cdiv_ui.c
cfdiv_q_2exp.c cfdiv_r_2exp.c
clear.c clears.c clrbit.c
cmp.c cmp_d.c cmp_si.c cmp_ui.c cmpabs.c cmpabs_d.c cmpabs_ui.c
com.c combit.c
cong.c cong_2exp.c cong_ui.c
divexact.c divegcd.c dive_ui.c divis.c divis_ui.c divis_2exp.c
dump.c export.c fac_ui.c fdiv_q.c fdiv_q_ui.c
fdiv_qr.c fdiv_qr_ui.c fdiv_r.c fdiv_r_ui.c fdiv_ui.c
fib_ui.c fib2_ui.c
fits_sint.c fits_slong.c fits_sshort.c
fits_uint.c fits_ulong.c fits_ushort.c
gcd.c gcd_ui.c gcdext.c get_d.c get_d_2exp.c get_si.c
get_str.c get_ui.c getlimbn.c hamdist.c
import.c init.c init2.c inits.c inp_raw.c inp_str.c
invert.c ior.c iset.c iset_d.c iset_si.c iset_str.c iset_ui.c
jacobi.c kronsz.c kronuz.c kronzs.c kronzu.c
lcm.c lcm_ui.c limbs_read.c limbs_write.c limbs_modify.c limbs_finish.c
lucnum_ui.c lucnum2_ui.c lucmod.c mfac_uiui.c millerrabin.c
mod.c mul.c mul_2exp.c mul_si.c mul_ui.c n_pow_ui.c neg.c nextprime.c
oddfac_1.c
out_raw.c out_str.c perfpow.c perfsqr.c popcount.c pow_ui.c powm.c
powm_sec.c powm_ui.c pprime_p.c prodlimbs.c primorial_ui.c random.c random2.c
realloc.c realloc2.c remove.c roinit_n.c root.c rootrem.c rrandomb.c
scan0.c scan1.c set.c set_d.c set_f.c set_q.c set_si.c set_str.c
set_ui.c setbit.c size.c sizeinbase.c sqrt.c sqrtrem.c stronglucas.c
sub.c sub_ui.c
swap.c tdiv_ui.c tdiv_q.c tdiv_q_2exp.c tdiv_q_ui.c tdiv_qr.c
tdiv_qr_ui.c tdiv_r.c tdiv_r_2exp.c tdiv_r_ui.c tstbit.c ui_pow_ui.c
ui_sub.c urandomb.c urandomm.c xor.c)

list(TRANSFORM mpz_SOURCES PREPEND "mpz/")

set(mpn_SOURCES
	${CMAKE_CURRENT_BINARY_DIR}/mp_bases.c ${CMAKE_CURRENT_BINARY_DIR}/fib_table.c)

set(printf_SOURCES
asprintf.c asprntffuns.c doprnt.c doprntf.c doprnti.c
fprintf.c obprintf.c obvprintf.c obprntffuns.c
printf.c printffuns.c snprintf.c snprntffuns.c sprintf.c sprintffuns.c
vasprintf.c vfprintf.c vprintf.c vsnprintf.c vsprintf.c
repl-vsnprintf.c)

list(TRANSFORM printf_SOURCES PREPEND "printf/")

set(scanf_SOURCES
doscan.c fscanf.c fscanffuns.c scanf.c sscanf.c sscanffuns.c
vfscanf.c vscanf.c vsscanf.c)

list(TRANSFORM scanf_SOURCES PREPEND "scanf/")

set(rand_SOURCES
rand.c randclr.c randdef.c randiset.c randlc2s.c randlc2x.c randmt.c
randmts.c rands.c randsd.c randsdui.c randbui.c randmui.c)

list(TRANSFORM rand_SOURCES PREPEND "rand/")

#not used here, because we are building a C library only
set(cxx_SOURCES
  cxx/isfuns.cc cxx/ismpf.cc cxx/ismpq.cc cxx/ismpz.cc cxx/ismpznw.cc cxx/limits.cc
  cxx/osdoprnti.cc cxx/osfuns.cc cxx/osmpf.cc cxx/osmpq.cc cxx/osmpz.cc)

set(gmp_SOURCES
gmp-impl.h longlong.h
assert.c compat.c errno.c extract-dbl.c invalid.c memory.c
mp_bpl.c mp_clz_tab.c mp_dv_tab.c mp_minv_tab.c mp_get_fns.c mp_set_fns.c
version.c nextprime.c primesieve.c)

if(WANT_TMP_ALLOCA)
	list(APPEND gmp_SOURCES tal-reent.c)
endif()

add_library(gmp ${gmp_SOURCES} ${mpf_SOURCES} ${mpq_SOURCES} ${mpz_SOURCES} ${mpn_SOURCES} 
	${printf_SOURCES} ${scanf_SOURCES} ${rand_SOURCES})
add_dependencies(gmp gmp_gen)
target_compile_definitions(gmp PRIVATE __GMP_WITHIN_GMP)
target_compile_options(gmp PUBLIC ${GMP_COMPILE_FLAGS})
set_target_properties(gmp PROPERTIES PUBLIC_HEADER ${CMAKE_CURRENT_BINARY_DIR}/gmp.h)
target_link_libraries(gmp ${mpn_links})
if(BUILD_SHARED_LIBS)
	set_target_properties(gmp PROPERTIES RUNTIME_OUTPUT_NAME "gmp-${PROJECT_VERSION}")
endif()

INSTALL(TARGETS gmp
		ARCHIVE DESTINATION lib
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		PUBLIC_HEADER DESTINATION include)
install(FILES doc/gmp.info doc/gmp.info-1 doc/gmp.info-2
		DESTINATION share/info)

include(CTest)
if(BUILD_TESTING)

set(gmp_test_SOURCES
	tests/memory.c tests/misc.c tests/refmpf.c
	tests/refmpn.c tests/refmpq.c tests/refmpz.c
	tests/spinner.c tests/trace.c)

add_library(gmp_tests STATIC ${gmp_test_SOURCES})
target_include_directories(gmp_tests PUBLIC tests)
add_dependencies(gmp_tests gmp)

set(tests
  #top-level tests
  t-bswap t-constants t-count_zeros t-hightomask
  t-modlinv t-popc t-parity t-sub
  #tests/misc
  misc/t-locale misc/t-printf misc/t-scanf
  #tests/mpf
  mpf/t-dm2exp mpf/t-conv mpf/t-add mpf/t-sub mpf/t-sqrt mpf/t-sqrt_ui mpf/t-muldiv mpf/reuse
  mpf/t-cmp_d mpf/t-cmp_si mpf/t-div mpf/t-fits mpf/t-get_d mpf/t-get_d_2exp
  mpf/t-get_si mpf/t-get_ui mpf/t-gsprec mpf/t-inp_str mpf/t-int_p mpf/t-mul_ui
  mpf/t-set mpf/t-set_q mpf/t-set_si mpf/t-set_ui mpf/t-trunc mpf/t-ui_div mpf/t-eq mpf/t-pow_ui
  #tests/mpn
  mpn/t-asmtype mpn/t-aors_1 mpn/t-divrem_1 mpn/t-mod_1 mpn/t-fat mpn/t-get_d
  mpn/t-instrument mpn/t-iord_u mpn/t-mp_bases mpn/t-perfsqr mpn/t-scan mpn/logic
  mpn/t-toom22 mpn/t-toom32 mpn/t-toom33 mpn/t-toom42 mpn/t-toom43 mpn/t-toom44
  mpn/t-toom52 mpn/t-toom53 mpn/t-toom54 mpn/t-toom62 mpn/t-toom63 mpn/t-toom6h mpn/t-toom8h
  mpn/t-toom2-sqr mpn/t-toom3-sqr mpn/t-toom4-sqr mpn/t-toom6-sqr mpn/t-toom8-sqr
  mpn/t-div mpn/t-mul mpn/t-mullo mpn/t-sqrlo mpn/t-mulmod_bnm1 mpn/t-sqrmod_bnm1 mpn/t-mulmid
  mpn/t-hgcd mpn/t-hgcd_appr mpn/t-matrix22 mpn/t-invert mpn/t-bdiv mpn/t-fib2m
  mpn/t-broot mpn/t-brootinv mpn/t-minvert mpn/t-sizeinbase mpn/t-gcd_11 mpn/t-gcd_22 mpn/t-gcdext_1
  #tests/mpq
  mpq/t-aors mpq/t-cmp mpq/t-cmp_ui mpq/t-cmp_si mpq/t-equal mpq/t-get_d mpq/t-get_str
  mpq/t-inp_str mpq/t-inv mpq/t-md_2exp mpq/t-set_f mpq/t-set_str mpq/io mpq/reuse mpq/t-cmp_z
  #tests/mpz
  mpz/reuse mpz/t-addsub mpz/t-cmp mpz/t-mul mpz/t-mul_i mpz/t-tdiv mpz/t-tdiv_ui mpz/t-fdiv
  mpz/t-fdiv_ui mpz/t-cdiv_ui mpz/t-gcd mpz/t-gcd_ui mpz/t-lcm mpz/t-invert mpz/dive mpz/dive_ui mpz/t-sqrtrem
  mpz/convert mpz/io mpz/t-inp_str mpz/logic mpz/bit mpz/t-powm mpz/t-powm_ui mpz/t-pow mpz/t-div_2exp
  mpz/t-root mpz/t-perfsqr mpz/t-perfpow mpz/t-jac mpz/t-bin mpz/t-get_d mpz/t-get_d_2exp mpz/t-get_si
  mpz/t-set_d mpz/t-set_si mpz/t-lucm
  mpz/t-fac_ui mpz/t-mfac_uiui mpz/t-primorial_ui mpz/t-fib_ui mpz/t-lucnum_ui mpz/t-scan mpz/t-fits
  mpz/t-divis mpz/t-divis_2exp mpz/t-cong mpz/t-cong_2exp mpz/t-sizeinbase mpz/t-set_str
  mpz/t-aorsmul mpz/t-cmp_d mpz/t-cmp_si mpz/t-hamdist mpz/t-oddeven mpz/t-popcount mpz/t-set_f
  mpz/t-io_raw mpz/t-import mpz/t-export mpz/t-pprime_p mpz/t-nextprime mpz/t-remove mpz/t-limbs
  #tests/rand
  rand/t-iset rand/t-lc2exp rand/t-mt rand/t-rand rand/t-urbui rand/t-urmui rand/t-urndmm)

foreach(t ${tests})
	string(REPLACE "/" "-" tt ${t})
	add_executable(${tt} tests/${t}.c)
	add_dependencies(${tt} gmp_tests)
	target_link_libraries(${tt} gmp_tests gmp)
	set_target_properties(${tt} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
	add_test(${t} ${CMAKE_CURRENT_BINARY_DIR}/tests/${tt})
endforeach()

endif()

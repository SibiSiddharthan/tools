cmake_minimum_required(VERSION 3.13)
project(mpfr
		VERSION 4.1.0
		LANGUAGES C)

set(PACKAGE_NAME  "MPFR")
set(PACKAGE_VERSION  "${PROJECT_VERSION}")
set(PACKAGE_STRING  "MPFR ${PROJECT_VERSION}")

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(WANT_GMP_INTERNALS "using GMP internals" OFF) #might cause duplicate symbol error
option(MPFR_USE_MINIGMP "using GMP internals" OFF) #experimental
option(MPFR_USE_LOGGING "Use logging" OFF)
option(MPFR_WANT_PROVEN_CODE "Use proven code" OFF)
option(MPFR_WANT_SHARED_CACHE "Use shared cache" OFF)

# 1 normal
#-1 no
# 2 full
# 0 default
if(NOT DEFINED MPFR_WANT_ASSERT)
  set(MPFR_WANT_ASSERT 0)
endif()

add_compile_definitions(HAVE_CONFIG_H)
if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
include(UtilityFunctions)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckStructHasMember)
include(alloca)
include(endianess-check)

find_package(GMP REQUIRED)
include(printf-check)


check_c_headers( dlfcn.h float.h inttypes.h stdint.h wchar.h stdarg.h locale.h
	stdint.h stdlib.h strings.h string.h sys/stat.h sys/types.h sys/time.h
	unistd.h limits.h sys/fpu.h alloca.h)

if(HAVE_SYS_FPU_H)
  set(HAVE_FPC_CSR 1)
endif()

if(HAVE_STDARG_H)
  set(HAVE_STDARG 1)
endif()

check_functions(memmove memset setlocale strtol getrusage
  gettimeofday signal sigaction round trunc floor ceil nearbyint)

set(CMAKE_REQUIRED_LIBRARIES ${GMP_LIBRARIES})
check_functions(__gmpn_sbpi1_divappr_q __gmpn_invert_limb __gmpn_rsblsh1_n)
unset(CMAKE_REQUIRED_LIBRARIES)

check_types("long long" "long double"  intmax_t size_t)

check_struct_has_member("struct lconv" decimal_point locale.h HAVE_STRUCT_LCONV_DECIMAL_POINT)
check_struct_has_member("struct lconv" thousands_sep locale.h HAVE_STRUCT_LCONV_THOUSANDS_SEP)

check_c_source_compiles("
#include <sys/types.h>
#include <sys/time.h>
#include <time.h>

int
main ()
{
	if ((struct tm *) 0)
	return 0;
}"
TIME_WITH_SYS_TIME)

check_c_source_compiles("
int foo (int x) __attribute__ ((const));
int
main ()
{
  return 0;
}"
HAVE_ATTRIBUTE_CONST)

check_c_source_compiles("
typedef int SItype __attribute__ ((mode (SI)));
int
main ()
{
  return 0;
}"
HAVE_ATTRIBUTE_MODE)

check_c_source_compiles("
_Noreturn void foo(int);
int
main ()
{
  return 0;
}"
MPFR_HAVE_NORETURN)

check_c_source_compiles("
int x;
int
main (void)
{
if (x) __builtin_unreachable();

  ;
  return 0;
}"
HAVE_BUILTIN_UNREACHABLE)
if(HAVE_BUILTIN_UNREACHABLE)
	set(MPFR_HAVE_BUILTIN_UNREACHABLE 1)
endif()

check_c_source_compiles("
#include <stdlib.h>
int x = 0;
__attribute__((constructor)) static void
call_f(void) { x = 1742; }
__attribute__((destructor)) static void
call_g(void) { x = 1448; }

int
main (void)
{

    return (x == 1742) ? 0 : 1;

  ;
  return 0;
}"
MPFR_HAVE_CONSTRUCTOR_ATTR)


check_c_source_compiles("
#include <stdarg.h>

int
main (void)
{

   va_list ap1, ap2;
   va_copy(ap1, ap2);
  return 0;
}"
HAVE_VA_COPY)

check_c_source_compiles("
#include <stdarg.h>

int
main (void)
{

   va_list ap1, ap2;
   __va_copy(ap1, ap2);
  return 0;
}"
HAVE___VA_COPY)

check_c_source_compiles("
#include <fenv.h>
int
main (void)
{
fesetround(FE_TONEAREST);
  ;
  return 0;
}"
MPFR_HAVE_FESETROUND)

check_c_source_compiles("
int
main (void)
{
	volatile __float128 x = 0x1.fp+16383q;
	return x == 0;
}"
MPFR_WANT_FLOAT128)

check_c_source_compiles("
_Decimal64 x;
int
main (void)
{
  return 0;
}"
MPFR_WANT_DECIMAL_FLOATS)


check_c_source_compiles("
#define MPFR_USE_THREAD_SAFE 1
#define MPFR_USE_C11_THREAD_SAFE 1
 #include \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-thread.h\"
 MPFR_THREAD_ATTR int x = 17;
 int main (void) {
   return x != 17;
 }"
THREAD_SAFE)
if(THREAD_SAFE)
	set(MPFR_USE_THREAD_SAFE 1)
	set(MPFR_USE_C11_THREAD_SAFE 1)
endif()

check_c_source_compiles("
#include <assert.h>
#include <threads.h>
 mtx_t lock;
 once_flag once = ONCE_FLAG_INIT;
 thrd_t thd_idx;
 int x = 0;
 void once_call (void) { x = 1; }

int
main (void)
{

    int err;
    err = mtx_init(&lock, mtx_plain);
    assert(err == thrd_success);
    err = mtx_lock(&lock);
    assert(err == thrd_success);
    err = mtx_unlock(&lock);
    assert(err == thrd_success);
    mtx_destroy(&lock);
    once_call(&once, once_call);
    return x == 1 ? 0 : -1;
	return 0;
}"
MPFR_HAVE_C11_LOCK)

check_c_source_compiles("
#define MPFR_USE_STATIC_ASSERT 1
#include \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-sassert.h\"

/* Test if Static Assertions work */

int main (void) {
  int x;
  (void) (x = 1);  /* cast to void: avoid a warning, at least with GCC */
  /* Test of the macro after a declaraction and a statement. */
  MPFR_STAT_STATIC_ASSERT(sizeof(short) <= sizeof(int));
  return 0;
}"
MPFR_USE_STATIC_ASSERT)

check_c_source_compiles("
#include <${GMP_INCLUDE_DIRS}/gmp.h>
/* Make sure that a static assertion is used (not MPFR_ASSERTN). */
#undef MPFR_USE_STATIC_ASSERT
#define MPFR_USE_STATIC_ASSERT 1
#include \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-sassert.h\"

int
main (void)
{

  MPFR_STAT_STATIC_ASSERT ((mp_limb_t) -1 >= (unsigned long) -1);
  return 0;

  ;
  return 0;
}"
MPFR_LONG_WITHIN_LIMB)

check_c_source_compiles("
#define MPFR_NEED_INTMAX_H
#include <${GMP_INCLUDE_DIRS}/gmp.h>
#if ${HAVE_STDINT_H} && ${HAVE_INTTYPES_H} && ${HAVE_INTMAX_T}
#include <inttypes.h>
#include <stdint.h>
#endif
/* Make sure that a static assertion is used (not MPFR_ASSERTN). */
#undef MPFR_USE_STATIC_ASSERT
#define MPFR_USE_STATIC_ASSERT 1
#include \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-sassert.h\"
#include \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-intmax.h\"

int
main (void)
{

  MPFR_STAT_STATIC_ASSERT ((mp_limb_t) -1 >= (uintmax_t) -1);
  return 0;

  ;
  return 0;
}"
MPFR_INTMAX_WITHIN_LIMB)

check_c_source_compiles("
#define MPFR_NEED_INTMAX_H
#if ${HAVE_STDINT_H} && ${HAVE_INTTYPES_H} && ${HAVE_INTMAX_T}
#include <inttypes.h>
#include <stdint.h>
#endif
#include  \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-intmax.h\"
int
main (void)
{
  intmax_t x = INTMAX_MAX; (void) x;
  return 0;
}"
MPFR_HAVE_INTMAX_MAX)


check_c_source_runs("
#include <immintrin.h>

int
main (void)
{

 unsigned long long h1, h2;
 _mulx_u64(17, 42, &h1);
 _mulx_u64(-1, -1, &h2);
 return h1 == 0 && h2 == -2 ? 0 : 1;

  ;
  return 0;
}"
HAVE_MULX_U64)

check_c_source_runs("
int main (void) {
  return 1.0 / 0.0 == 1.0 / -0.0;
}"
HAVE_SIGNEDZ)

check_c_source_runs("
#include <stdio.h>
int main (void) {
  float x = 1.17549435082229e-38;
  fprintf (stderr, \"%e\", x / 2.0);
  return 2.0 * (float) (x / 2.0) != x;
}"
HAVE_SUBNORM_FLT)

check_c_source_runs("
#include <stdio.h>
int main (void) {
  double x = 2.22507385850720138309e-308;
  fprintf (stderr, \"%e\", x / 2.0);
  return 2.0 * (double) (x / 2.0) != x;
}"
HAVE_SUBNORM_DBL)

check_c_source_runs("
int main (void) {
  volatile double d = 0.0, x;
  x = 0.0 / d;
  x = 1.0 / d;
  (void) x;
  return 0;
}"
MPFR_ERRDIVZERO_OKAY)
if(NOT MPFR_ERRDIVZERO_OKAY)
  set(MPFR_ERRDIVZERO 1)
endif()



configure_file(mpfr-config.h.in config.h)
configure_file(src/mparam_h.in mparam.h)
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/mpfr_get_patches.c
"#include \"mpfr-impl.h\"
const char *
mpfr_get_patches (void)
{
  return \"\";
}")

set(mpfr_SOURCES
mpfr.h mpf2mpfr.h mpfr-cvers.h mpfr-gmp.h
mpfr-impl.h mpfr-intmax.h mpfr-longlong.h mpfr-sassert.h mpfr-thread.h
exceptions.c extract.c uceil_exp2.c
uceil_log2.c ufloor_log2.c add.c add1.c add_ui.c agm.c clear.c cmp.c
cmpabs.c cmp_si.c cmp_ui.c comparisons.c div_2exp.c div_2si.c
div_2ui.c div.c div_ui.c dot.c dump.c eq.c exp10.c exp2.c exp3.c exp.c
frac.c frexp.c get_d.c get_exp.c get_str.c init.c inp_str.c isinteger.c
isinf.c isnan.c isnum.c const_log2.c log.c modf.c mul_2exp.c mul_2si.c
mul_2ui.c mul.c mul_ui.c neg.c next.c out_str.c printf.c vasprintf.c
const_pi.c pow.c pow_si.c pow_ui.c print_raw.c print_rnd_mode.c
reldiff.c round_prec.c set.c setmax.c setmin.c set_d.c set_dfl_prec.c
set_exp.c set_rnd.c set_f.c set_prc_raw.c set_prec.c set_q.c set_si.c
set_str.c set_str_raw.c set_ui.c set_z.c sqrt.c sqrt_ui.c sub.c sub1.c
sub_ui.c rint.c ui_div.c ui_sub.c urandom.c urandomb.c get_z_exp.c
swap.c factorial.c cosh.c sinh.c tanh.c sinh_cosh.c acosh.c asinh.c
atanh.c atan.c cmp2.c exp_2.c asin.c const_euler.c cos.c sin.c tan.c
fma.c fms.c hypot.c log1p.c expm1.c log2.c log10.c ui_pow.c
ui_pow_ui.c minmax.c dim.c signbit.c copysign.c setsign.c gmp_op.c
init2.c acos.c sin_cos.c set_nan.c set_inf.c set_zero.c powerof2.c
gamma.c set_ld.c get_ld.c cbrt.c volatile.c fits_s.h fits_sshort.c
fits_sint.c fits_slong.c fits_u.h fits_ushort.c fits_uint.c
fits_ulong.c fits_uintmax.c fits_intmax.c get_si.c get_ui.c zeta.c
cmp_d.c erf.c inits.c inits2.c clears.c sgn.c check.c sub1sp.c
version.c mpn_exp.c mpfr-gmp.c mp_clz_tab.c sum.c add1sp.c
free_cache.c si_op.c cmp_ld.c set_ui_2exp.c set_si_2exp.c set_uj.c
set_sj.c get_sj.c get_uj.c get_z.c iszero.c cache.c sqr.c
int_ceil_log2.c isqrt.c strtofr.c pow_z.c logging.c mulders.c get_f.c
round_p.c erfc.c atan2.c subnormal.c const_catalan.c root.c
gen_inverse.h sec.c csc.c cot.c eint.c sech.c csch.c coth.c
round_near_x.c constant.c abort_prec_max.c stack_interface.c lngamma.c
zeta_ui.c set_d64.c get_d64.c jn.c yn.c rem1.c add_d.c
sub_d.c d_sub.c mul_d.c div_d.c d_div.c li2.c rec_sqrt.c min_prec.c
buildopt.c digamma.c bernoulli.c isregular.c set_flt.c get_flt.c
scale2.c set_z_exp.c ai.c gammaonethird.c ieee_floats.h
grandom.c fpif.c set_float128.c get_float128.c rndna.c nrandom.c
random_deviate.h random_deviate.c erandom.c mpfr-mini-gmp.c
mpfr-mini-gmp.h fmma.c log_ui.c gamma_inc.c ubf.c invert_limb.h
invsqrt_limb.h beta.c odd_p.c get_q.c pool.c total_order.c set_d128.c
get_d128.c nbits_ulong.c cmpabs_ui.c)

list(TRANSFORM mpfr_SOURCES PREPEND "src/")
list(APPEND mpfr_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/mpfr_get_patches.c)

add_library(mpfr ${mpfr_SOURCES})
target_precompile_headers(mpfr PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/config.h)
target_include_directories(mpfr PUBLIC ${CMAKE_CURRENT_BINARY_DIR} src)
set_target_properties(mpfr PROPERTIES PUBLIC_HEADER "src/mpfr.h;src/mpf2mpfr.h")
target_link_libraries(mpfr GMP::GMP)
if(BUILD_SHARED_LIBS)
  set_target_properties(mpfr PROPERTIES RUNTIME_OUTPUT_NAME "mpfr-${PROJECT_VERSION}")
endif()
if(WIN32)
  target_compile_options(mpfr PUBLIC -Wno-assume -Wno-implicit-int-float-conversion)
endif()

INSTALL(TARGETS mpfr
		ARCHIVE DESTINATION lib
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		PUBLIC_HEADER DESTINATION include)
install(FILES doc/mpfr.info DESTINATION share/info)

include(CTest)
if(BUILD_TESTING)


set(mpfr_test_SOURCES
  tests/mpfr-test.h tests/memory.c tests/rnd_mode.c tests/tests.c tests/cmp_str.c tests/random2.c)
add_library(mpfr-tests STATIC ${mpfr_test_SOURCES})
target_compile_definitions(mpfr-tests PRIVATE SRCDIR="${CMAKE_CURRENT_SOURCE_DIR}/tests")
target_link_libraries(mpfr-tests mpfr)

set(tests
	 tversion tabort_prec_max tassert tabort_defalloc1
   tabort_defalloc2 talloc tinternals tinits tisqrt tsgn tcheck
   tisnan texceptions tset_exp tset mpf_compat mpfr_compat reuse
   tabs tacos tacosh tadd tadd1sp tadd_d tadd_ui tagm tai
   talloc-cache tasin tasinh tatan tatanh taway tbeta tbuildopt
   tcan_round tcbrt tcmp tcmp2 tcmp_d tcmp_ld tcmp_ui tcmpabs
   tcomparisons tconst_catalan tconst_euler tconst_log2 tconst_pi
   tcopysign tcos tcosh tcot tcoth tcsc tcsch td_div td_sub tdigamma
   tdim tdiv tdiv_d tdiv_ui tdot teint teq terandom terandom_chisq
   terf texp texp10 texp2 texpm1 tfactorial tfits tfma tfmma tfmod
   tfms tfpif tfprintf tfrac tfrexp tgamma tgamma_inc tget_d
   tget_d_2exp tget_f tget_flt tget_ld_2exp tget_q tget_set_d64
   tget_set_d128 tget_sj tget_str tget_z tgmpop tgrandom thyperbolic
   thypot tinp_str
   tj0 tj1 tjn tl2b tlgamma tli2 tlngamma tlog tlog10 tlog1p tlog2
   tlog_ui tmin_prec tminmax tmodf tmul tmul_2exp tmul_d tmul_ui
   tnext tnrandom tnrandom_chisq tout_str toutimpl tpow tpow3
   tpow_all tpow_z tprec_round tprintf trandom trandom_deviate
   trec_sqrt tremquo trint trndna troot trootn_ui tsec tsech
   tset_d tset_f tset_float128 tset_ld tset_q tset_si tset_sj
   tset_str tset_z tset_z_exp tsi_op tsin tsin_cos tsinh tsinh_cosh
   tsprintf tsqr tsqrt tsqrt_ui tstckintc tstdint tstrtofr
   tsub tsub1sp tsub_d tsub_ui tsubnormal tsum tswap ttan ttanh
   ttotal_order ttrunc tui_div tui_pow tui_sub turandom tvalist
   ty0 ty1 tyn tzeta tzeta_ui)

foreach(t ${tests})
	add_executable(${t} tests/${t}.c)
	target_link_libraries(${t} PRIVATE mpfr-tests)
	set_target_properties(${t} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
	add_test(${t} ${CMAKE_CURRENT_BINARY_DIR}/tests/${t})
  set_tests_properties(${t} PROPERTIES SKIP_RETURN_CODE 77)
endforeach()

add_executable(mpfrbench tools/bench/mpfrbench.c)
target_link_libraries(mpfrbench mpfr)

endif()

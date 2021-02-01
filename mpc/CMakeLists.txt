#[[
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
]]

cmake_minimum_required(VERSION 3.13)
project(mpc
		VERSION 1.2.0
		LANGUAGES C)

set(PACKAGE \"mpc\")
set(PACKAGE_BUGREPORT \"mpc-discuss@lists.gforge.inria.fr\")
set(PACKAGE_NAME \"mpc\")
set(PACKAGE_STRING \"mpc\ ${PROJECT_VERSION}\")
set(PACKAGE_TARNAME \"mpc\")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"${PROJECT_VERSION}\")
set(VERSION \"${PROJECT_VERSION}\")

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

add_compile_definitions(HAVE_CONFIG_H)
if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
find_package(MPFR REQUIRED)
find_package(GMP REQUIRED)
include(UtilityFunctions)
include(CheckCSourceCompiles)
include(alloca)
include(TimeWithSysTime)

check_c_headers(dlfcn.h inttypes.h limits.h memory.h locale.h stdint.h
stdlib.h strings.h string.h sys/resource.h sys/stat.h sys/time.h sys/types.h unistd.h)

check_functions(dup dup2 getrusage gettimeofday localeconv setlocale)

check_types(intptr_t size_t)

if(NOT HAVE_INTPTR_T)
	set(intptr_t "long\ int")
endif()

if(NOT HAVE_SIZE_T)
	set(size_t "unsigned\ int")
endif()


check_c_source_compiles("
#include <complex.h>
int
main ()
{
complex double x = 1.0 + 2.0 * I; return (creal (x) + cimag (x));

  ;
  return 0;
}"
HAVE_COMPLEX_H)

set(CMAKE_REQUIRED_LIBRARIES  ${MPFR_LIBRARIES} ${GMP_LIBRARIES})
set(CMAKE_REQUIRED_INCLUDES ${MPFR_INCLUDE_DIRS} ${GMP_INCLUDE_DIRS})
check_c_source_compiles("
#include \"mpfr.h\"
int
main ()
{
mpfr_t x; mpfr_fmma (x, x, x, x, x, 0);

  ;
  return 0;
}"
HAVE_MPFR_FMMA)
if(NOT HAVE_MPFR_FMMA)
	set(HAVE_MPFR_FMMA "0 ")
endif()

set(MPC_CC \"${CMAKE_C_COMPILER_ID}\")
if(${CMAKE_C_COMPILER_ID} STREQUAL "GNU")
	set(MPC_GCC \"yes\")
	set(MPC_GCC_VERSION \"${CMAKE_C_COMPILER_VERSION}\")
endif()


configure_file(mpc-config.h.in config.h)

set(mpc_SOURCES
mpc-impl.h abs.c acos.c acosh.c add.c add_fr.c
add_si.c add_ui.c arg.c asin.c asinh.c atan.c atanh.c clear.c
cmp.c cmp_abs.c cmp_si_si.c conj.c cos.c cosh.c
div_2si.c div_2ui.c div.c div_fr.c div_ui.c
dot.c exp.c fma.c fr_div.c fr_sub.c get_prec2.c get_prec.c
get_version.c get_x.c imag.c init2.c init3.c inp_str.c log.c log10.c
mem.c mul_2si.c mul_2ui.c mul.c mul_fr.c mul_i.c mul_si.c mul_ui.c
neg.c norm.c out_str.c pow.c pow_fr.c
pow_ld.c pow_d.c pow_si.c pow_ui.c pow_z.c proj.c real.c rootofunity.c
urandom.c set.c
set_prec.c set_str.c set_x.c set_x_x.c sin.c sin_cos.c sinh.c sqr.c
sqrt.c strtoc.c sub.c sub_fr.c sub_ui.c sum.c swap.c tan.c tanh.c
uceil_log2.c ui_div.c ui_ui_sub.c)

list(TRANSFORM mpc_SOURCES PREPEND "src/")
add_library(mpc ${mpc_SOURCES})
target_include_directories(mpc PUBLIC ${CMAKE_CURRENT_BINARY_DIR} src)
set_target_properties(mpc PROPERTIES PUBLIC_HEADER src/mpc.h)
target_link_libraries(mpc MPFR::MPFR GMP::GMP)
if(BUILD_SHARED_LIBS)
  set_target_properties(mpc PROPERTIES RUNTIME_OUTPUT_NAME "mpc-${PROJECT_VERSION}")
endif()

INSTALL(TARGETS mpc
		ARCHIVE DESTINATION lib
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		PUBLIC_HEADER DESTINATION include)
install(FILES doc/mpc.info DESTINATION share/info)

include(CTest)
if(BUILD_TESTING)

set(mpc_test_SOURCES
mpc-tests.h check_data.c clear_parameters.c
close_datafile.c comparisons.c copy_parameter.c double_rounding.c
init_parameters.c mpfr_flags.c open_datafile.c print_parameter.c
random.c read_data.c read_description.c read_line.c rounding.c
setprec_parameters.c tpl_gmp.c tpl_mpc.c tpl_mpfr.c tpl_native.c)

list(TRANSFORM mpc_test_SOURCES PREPEND "tests/")
add_library(mpc-tests STATIC ${mpc_test_SOURCES})
target_link_libraries(mpc-tests mpc)

set(tests
tabs tacos tacosh tadd tadd_fr tadd_si tadd_ui targ
tasin tasinh tatan tatanh tcmp_abs tconj tcos tcosh
tdiv tdiv_2si tdiv_2ui tdiv_fr tdiv_ui tdot texp tfma tfr_div tfr_sub
timag tio_str tlog tlog10
tmul tmul_2si tmul_2ui tmul_fr tmul_i tmul_si tmul_ui tneg tnorm tpow
tpow_d tpow_fr tpow_ld tpow_si tpow_ui tpow_z tprec tproj treal
treimref trootofunity
tset tsin tsin_cos tsinh tsqr tsqrt tstrtoc tsub tsub_fr
tsub_ui tsum tswap ttan ttanh tui_div tui_ui_sub tget_version exceptions)

foreach(t ${tests})
	add_executable(${t} tests/${t}.c)
	target_link_libraries(${t} mpc-tests)
	set_target_properties(${t} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
	add_test(${t} ${CMAKE_CURRENT_BINARY_DIR}/tests/${t})
	set_tests_properties(${t} PROPERTIES ENVIRONMENT "srcdir=${CMAKE_CURRENT_SOURCE_DIR}/tests")
endforeach()

add_executable(mpcbench tools/bench/mpcbench.c)
target_link_libraries(mpcbench mpc)

endif()

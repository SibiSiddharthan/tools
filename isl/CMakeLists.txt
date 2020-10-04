cmake_minimum_required(VERSION 3.13)
project(isl
		VERSION 0.22.1
		LANGUAGES C )

set(PACKAGE \"isl\")
set(PACKAGE_BUGREPORT \"isl-development@googlegroups.com\")
set(PACKAGE_NAME \"isl\")
set(PACKAGE_STRING \"isl\ ${PROJECT_VERSION}\")
set(PACKAGE_TARNAME "isl")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"${PROJECT_VERSION}\")
set(VERSION \"${PROJECT_VERSION}\")

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(USE_SMALL_INT_OPT "Use small int optimization" OFF)
option(PREFER_IMATH "Use include imath instead of GMP" OFF)
add_compile_definitions(HAVE_CONFIG_H)

if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
include(UtilityFunctions)
include(CheckCSourceCompiles)

find_package(GMP)
if(GMP_FOUND)
	set(HAVE_LIBGMP 1)
endif()

check_c_headers(dlfcn.h inttypes.h memory.h stdint.h stdlib.h strings.h string.h
	sys/stat.h sys/types.h unistd.h)

set(CMAKE_EXTRA_INCLUDE_FILES intrin.h)
check_functions_declarations(ffs snprintf strcasecmp strncasecmp
_snprintf _stricmp _strnicmp )
unset(CMAKE_EXTRA_INCLUDE_FILES)

#builtin_functions
check_functions(_BitScanForward __builtin_ffs)
if(WIN32)
	if(MSVC OR ${CMAKE_C_COMPILER_ID} STREQUAL "Clang")
		set(HAVE_DECL__BITSCANFORWARD 1)
	endif()
endif()
if(${CMAKE_C_COMPILER_ID} STREQUAL "GNU" OR ${CMAKE_C_COMPILER_ID} STREQUAL "Clang")
	set(HAVE_DECL___BUILTIN_FFS 1)
endif()

check_types(char int long short "void *" )

set(CMAKE_REQUIRED_INCLUDES ${GMP_INCLUDE_DIRS})
set(CMAKE_REQUIRED_LIBRARIES ${GMP_LIBRARIES})
check_symbol_exists(mp_get_memory_functions gmp.h HAVE_DECL_MP_GET_MEMORY_FUNCTIONS)
unset(CMAKE_REQUIRED_INCLUDES)
unset(CMAKE_REQUIRED_LIBRARIES)

if(NOT HAVE_DECL_MP_GET_MEMORY_FUNCTIONS)
	set(NEED_GET_MEMORY_FUNCTIONS 1)
endif()
check_c_source_compiles("
__attribute__((__warn_unused_result__))
 int f(int i) { return i; }
int
main ()
{
  return 0;
}"
GCC_WARN_UNUSED_RESULT)
if(GCC_WARN_UNUSED_RESULT)
	set(GCC_WARN_UNUSED_RESULT __attribute__\(\(__warn_unused_result__\)\))
endif()

check_c_source_compiles("
#include <stdlib.h>
static void foo(void) __attribute__ ((unused));
static void
foo(void) {
	exit(1);
	}

int
main ()
{
  return 0;
}"
HAVE___ATTRIBUTE__)

if(HAVE_LIBGMP)
	set(USE_GMP_FOR_MP 1)
	set(USE_SMALL_INT_OPT 0)
else()
	set(USE_IMATH_FOR_MP 1)
endif()

if(PREFER_IMATH)
	set(USE_IMATH_FOR_MP 1)
	set(USE_GMP_FOR_MP 0)
	set(NEED_GET_MEMORY_FUNCTIONS 0)
endif()

configure_file(isl-config.h.in isl_config.h)
set(OS_SRCDIR ${CMAKE_CURRENT_SOURCE_DIR})
configure_file(isl_srcdir.c.in isl_srcdir.c @ONLY)

set(isl_SOURCES
isl_aff.c
isl_aff_map.c
isl_aff_private.h
isl_affine_hull.c
isl_arg.c
isl_ast.c
isl_ast_private.h
isl_ast_build.c
isl_ast_build_private.h
isl_ast_build_expr.c
isl_ast_build_expr.h
isl_ast_codegen.c
isl_ast_graft.c
isl_ast_graft_private.h
isl_basis_reduction.h
basis_reduction_tab.c
isl_bernstein.c
isl_bernstein.h
isl_blk.c
isl_blk.h
isl_bound.c
isl_bound.h
isl_box.c
isl_coalesce.c
isl_constraint.c
isl_constraint_private.h
isl_convex_hull.c
isl_ctx.c
isl_ctx_private.h
isl_deprecated.c
isl_dim_map.h
isl_dim_map.c
isl_equalities.c
isl_equalities.h
isl_factorization.c
isl_factorization.h
isl_farkas.c
isl_ffs.c
isl_flow.c
isl_fold.c
isl_hash.c
isl_id_to_ast_expr.c
isl_id_to_id.c
isl_id_to_pw_aff.c
isl_ilp.c
isl_ilp_private.h
isl_input.c
isl_int.h
isl_local_private.h
isl_local.h
isl_local.c
isl_local_space_private.h
isl_local_space.c
isl_lp.c
isl_lp_private.h
isl_map.c
isl_map_list.c
isl_map_simplify.c
isl_map_subtract.c
isl_map_private.h
isl_map_to_basic_set.c
isl_mat.c
isl_mat_private.h
isl_morph.c
isl_morph.h
isl_id.c
isl_id_private.h
isl_obj.c
isl_options.c
isl_options_private.h
isl_output.c
isl_output_private.h
isl_point_private.h
isl_point.c
isl_polynomial_private.h
isl_polynomial.c
isl_printer_private.h
isl_printer.c
print.c
isl_range.c
isl_range.h
isl_reordering.c
isl_reordering.h
isl_sample.h
isl_sample.c
isl_scan.c
isl_scan.h
isl_schedule.c
isl_schedule_band.c
isl_schedule_band.h
isl_schedule_node.c
isl_schedule_node_private.h
isl_schedule_read.c
isl_schedule_tree.c
isl_schedule_tree.h
isl_schedule_private.h
isl_schedule_constraints.c
isl_schedule_constraints.h
isl_scheduler.c
isl_set_list.c
isl_sort.c
isl_sort.h
isl_space.c
isl_space_private.h
isl_stream.c
isl_stream_private.h
isl_seq.c
isl_seq.h
isl_set_to_ast_graft_list.c
isl_set_to_ast_graft_list.h
isl_stride.c
isl_tab.c
isl_tab.h
isl_tab_pip.c
isl_tarjan.c
isl_tarjan.h
isl_transitive_closure.c
isl_union_map.c
isl_union_map_private.h
isl_union_set_private.h
isl_val.c
isl_val_private.h
isl_vec_private.h
isl_vec.c
isl_version.c
isl_vertices_private.h
isl_vertices.c
isl_yaml.h)

if(USE_GMP_FOR_MP)
	list(APPEND isl_SOURCES isl_int_gmp.h isl_gmp.c isl_val_gmp.c)
	if(NEED_GET_MEMORY_FUNCTIONS)
		list(APPEND isl_SOURCES mp_get_memory_functions.c)
	endif()
else() #imath
	list(APPEND isl_SOURCES isl_imath.c
	isl_imath.h
	isl_int_imath.h
	imath_wrap/gmp_compat.h
	imath_wrap/imath.h
	imath_wrap/imrat.h
	imath_wrap/wrap.h
	imath_wrap/gmp_compat.c
	imath_wrap/imath.c
	imath_wrap/imrat.c)
	if(USE_SMALL_INT_OPT)
		list(APPEND isl_SOURCES isl_int_sioimath.h isl_int_sioimath.c isl_val_sioimath.c)
	else()
		list(APPEND isl_SOURCES isl_val_imath.c)
	endif()
endif()

set(isl_HEADERS
include/isl/aff.h
include/isl/aff_type.h
include/isl/arg.h
include/isl/ast.h
include/isl/ast_type.h
include/isl/ast_build.h
include/isl/constraint.h
include/isl/ctx.h
include/isl/fixed_box.h
include/isl/flow.h
include/isl/id.h
include/isl/id_type.h
include/isl/id_to_ast_expr.h
include/isl/id_to_id.h
include/isl/id_to_pw_aff.h
include/isl/ilp.h
include/isl/hash.h
include/isl/hmap.h
include/isl/hmap_templ.c
include/isl/list.h
include/isl/local_space.h
include/isl/lp.h
include/isl/mat.h
include/isl/map.h
include/isl/map_to_basic_set.h
include/isl/map_type.h
include/isl/maybe.h
include/isl/maybe_ast_expr.h
include/isl/maybe_basic_set.h
include/isl/maybe_id.h
include/isl/maybe_pw_aff.h
include/isl/maybe_templ.h
include/isl/multi.h
include/isl/obj.h
include/isl/options.h
include/isl/point.h
include/isl/polynomial.h
include/isl/polynomial_type.h
include/isl/printer.h
include/isl/printer_type.h
include/isl/schedule.h
include/isl/schedule_node.h
include/isl/schedule_type.h
include/isl/set.h
include/isl/set_type.h
include/isl/space.h
include/isl/space_type.h
include/isl/stream.h
include/isl/stride_info.h
include/isl/union_map.h
include/isl/union_map_type.h
include/isl/union_set.h
include/isl/union_set_type.h
include/isl/val.h
include/isl/val_type.h
include/isl/vec.h
include/isl/version.h
include/isl/vertices.h)

if(USE_GMP_FOR_MP)
	list(APPEND isl_HEADERS include/isl/val_gmp.h)
endif()

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/gitversion.h "#define GIT_HEAD_ID \"isl-${PROJECT_VERSION}\"")
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/isl/stdint.h 
	"#ifndef _ISL_INCLUDE_ISL_STDINT_H
	#define _ISL_INCLUDE_ISL_STDINT_H 1
	#ifndef _GENERATED_STDINT_H
	#define _GENERATED_STDINT_H \"isl ${PROJECT_VERSION}\"
	#define _STDINT_HAVE_STDINT_H 1
	#include <stdint.h>
	#endif
	#endif")

add_library(isl_O OBJECT ${isl_SOURCES})
target_compile_options(isl_O PUBLIC -fomit-frame-pointer -malign-double -fstrict-aliasing -ffast-math)
target_include_directories(isl_O PUBLIC include ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
if(USE_GMP_FOR_MP)
	target_link_libraries(isl_O GMP::GMP)
endif()

#prevent repeated compilation
add_library(isl isl-dll.def)
set_target_properties(isl PROPERTIES PUBLIC_HEADER "${isl_HEADERS}")
target_link_libraries(isl isl_O)
if(BUILD_SHARED_LIBS)
	set_target_properties(isl PROPERTIES RUNTIME_OUTPUT_NAME "isl-${PROJECT_VERSION}"
			RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
endif()

INSTALL(TARGETS isl
		ARCHIVE DESTINATION lib
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		PUBLIC_HEADER DESTINATION include/isl)
install(FILES doc/manual.pdf DESTINATION share/doc/isl)

include(CTest)
if(BUILD_TESTING)

if(WIN32 AND BUILD_SHARED_LIBS)
	add_library(isl_for_test STATIC)
	target_link_libraries(isl_for_test isl_O)
	set(isl_test_link isl_for_test)
else()
	set(isl_test_link isl)
endif()


set(EXEEXT ${CMAKE_EXECUTABLE_SUFFIX})
set(srcdir ${CMAKE_CURRENT_SOURCE_DIR})

find_program(GREP grep)
find_program(SED sed)
find_program(SH_EXE sh)

configure_file(codegen_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/codegen_test.sh @ONLY)
configure_file(pip_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/pip_test.sh @ONLY)
configure_file(bound_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/bound_test.sh @ONLY)
configure_file(flow_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/flow_test.sh @ONLY)
configure_file(schedule_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/schedule_test.sh @ONLY)

set(test_helpers_1
	isl_test isl_test_int)

if(USE_IMATH_FOR_MP)
	list(APPEND test_helpers_1 isl_test_imath)
endif()

set(test_helpers_2
 pip
	polyhedron_minimize polytope_scan
	polyhedron_detect_equalities cat
	closure bound schedule codegen
	flow flow_cmp schedule_cmp)

foreach(i ${test_helpers_1})
	add_executable(${i} ${i}.c)
	target_link_libraries(${i} ${isl_test_link})
	set_target_properties(${i} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
endforeach()

foreach(i ${test_helpers_2})
	add_executable(isl_${i} ${i}.c)
	target_link_libraries(isl_${i} ${isl_test_link})
	set_target_properties(isl_${i} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
endforeach()

add_test(isl_test ${CMAKE_CURRENT_BINARY_DIR}/tests/isl_test)
add_test(isl_test_int ${CMAKE_CURRENT_BINARY_DIR}/tests/isl_test_int)
if(USE_IMATH_FOR_MP)
	add_test(isl_test_imath ${CMAKE_CURRENT_BINARY_DIR}/tests/isl_test_imath)
endif()
add_test(NAME codegen-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/codegen_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
add_test(NAME pip-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/pip_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
add_test(NAME bound-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/bound_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
add_test(NAME flow-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/flow_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
add_test(NAME schedule-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/schedule_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)


endif()

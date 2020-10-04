find_path(MPFR_INCLUDE_DIR NAMES mpfr.h mpf2mpfr.h)
find_library(MPFR_LIBRARY NAMES mpfr libmpfr NAMES_PER_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MPFR REQUIRED_VARS MPFR_INCLUDE_DIR MPFR_LIBRARY)

#depends on GMP
find_package(GMP REQUIRED)

if(MPFR_FOUND)
  set(MPFR_INCLUDE_DIRS ${MPFR_INCLUDE_DIR})
  set(MPFR_LIBRARIES ${MPFR_LIBRARY})
  if(NOT TARGET MPFR::MPFR)
	add_library(MPFR::MPFR UNKNOWN IMPORTED)
	set_target_properties(MPFR::MPFR PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES ${MPFR_INCLUDE_DIRS}
		INTERFACE_LINK_LIBRARIES ${MPFR_LIBRARIES}
		IMPORTED_LOCATION ${MPFR_LIBRARIES})
  endif()
endif()
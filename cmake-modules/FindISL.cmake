find_path(ISL_INCLUDE_DIR NAMES isl/aff.h) #one of the header files
find_library(ISL_LIBRARY NAMES isl libisl NAMES_PER_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ISL REQUIRED_VARS ISL_INCLUDE_DIR ISL_LIBRARY)

#check if GMP is a prerequisite
find_path(ISL_DEPENDS_ON_GMP NAMES isl/val_gmp.h)


if(ISL_FOUND)
  set(ISL_INCLUDE_DIRS ${ISL_INCLUDE_DIR})
  set(ISL_LIBRARIES ${ISL_LIBRARY})
  if(NOT TARGET ISL::ISL)
	add_library(ISL::ISL UNKNOWN IMPORTED)
	set_target_properties(ISL::ISL PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES ${ISL_INCLUDE_DIRS}
		INTERFACE_LINK_LIBRARIES ${ISL_LIBRARIES}
		IMPORTED_LOCATION ${ISL_LIBRARIES})
	#if(ISL_DEPENDS_ON_GMP)
	#	find_package(GMP REQUIRED)
	#	set_target_properties(ISL::ISL PROPERTIES 
	#	INTERFACE_LINK_LIBRARIES ${ISL_LIBRARIES} GMP::GMP)
	#endif() 
  endif()
endif()
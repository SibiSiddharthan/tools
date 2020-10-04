if(NOT DEFINED HOST_ARCHITECTURE)
	message("NOTE: HOST_ARCHITECTURE not set. Defaulting to x86_64
			Supported host architectures are x86_64, core2, nehalem, westmere,
			sandybridge, ivybridge, haswell, broadwell, skylake, kabylake
			athlon64, k8, k10, bobcat, jaguar, bulldozer, piledriver, steamroller, excavator
			zen, zen2")
	set(HOST_ARCHITECTURE "x86_64")
endif()

#works for intel x86_64
set(HAVE_DOUBLE_IEEE_LITTLE_ENDIAN 1)
set(HAVE_HOST_CPU_FAMILY_x86_64 1)
set(HAVE_LIMB_LITTLE_ENDIAN 1)
set(HAVE_SPEED_CYCLECOUNTER 2)
set(HAVE_HOST_CPU_${HOST_ARCHITECTURE} 1)
set(HAVE_HOST_CPU_ARCH HAVE_HOST_CPU_${HOST_ARCHITECTURE})
list(APPEND mpn_REQUIRED_FILES invert_limb_table)

if(${HOST_ARCHITECTURE} STREQUAL "x86_64")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64")
	set(native "x86_64")
	set(DIRECTORIES mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "core2")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/core2")
	set(native "core2")
	set(DIRECTORIES mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "nehalem" OR ${HOST_ARCHITECTURE} STREQUAL "westmere")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/coreinhm")
	set(native "coreinhm")
	set(DIRECTORIES mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "sandybridge" OR ${HOST_ARCHITECTURE} STREQUAL "ivybridge")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/coreisbr")
	set(native "coreisbr")
	set(DIRECTORIES mpn/x86_64/coreisbr mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "haswell")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/coreihwl")
	set(native "coreihwl")
	set(X86_ASM_MULX 1)
	set(DIRECTORIES mpn/x86_64/coreihwl mpn/x86_64/coreisbr mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "broadwell")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/coreibwl")
	set(native "coreibwl")
	set(X86_ASM_MULX 1)
	set(DIRECTORIES mpn/x86_64/coreibwl mpn/x86_64/coreihwl mpn/x86_64/coreisbr mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "skylake" OR ${HOST_ARCHITECTURE} STREQUAL "kabylake")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/skylake")
	set(native "skylake")
	set(X86_ASM_MULX 1)
	set(DIRECTORIES mpn/x86_64/skylake mpn/x86_64/coreibwl mpn/x86_64/coreihwl mpn/x86_64/coreisbr mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "athlon64" OR ${HOST_ARCHITECTURE} STREQUAL "k8")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/k8")
	set(native "k8")
	set(DIRECTORIES mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "k10")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/k10")
	set(native "k10")
	set(DIRECTORIES mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "bobcat")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/bobcat")
	set(native "bobcat")
	set(DIRECTORIES mpn/x86_64/bobcat mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "jaguar")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/jaguar")
	set(native "jaguar")
	set(DIRECTORIES mpn/x86_64/jaguar mpn/x86_64/bobcat mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "bulldozer")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/bd1")
	set(native "bd1")
	set(DIRECTORIES mpn/x86_64/bd1 mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "piledriver" OR ${HOST_ARCHITECTURE} STREQUAL "steamroller" OR ${HOST_ARCHITECTURE} STREQUAL "excavator")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/bd2")
	set(native "bd2")
	set(X86_ASM_MULX 1)
	set(DIRECTORIES mpn/x86_64/bd2 mpn/x86_64/bd1 mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "zen")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/bd2")
	set(native "zen")
	set(X86_ASM_MULX 1)
	set(DIRECTORIES mpn/x86_64/zen mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "zen2")

	set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/bd2")
	set(native "zen2")
	set(X86_ASM_MULX 1)
	set(DIRECTORIES mpn/x86_64/zen2 mpn/x86_64/zen mpn/x86_64)
else()
message(FATAL_ERROR "Host architecture not supported
					Supported host architectures are x86_64, core2, nehalem, westmere,
					sandybridge, ivybridge, haswell, broadwell, skylake, kabylake
					athlon64, k8, k10, bobcat, jaguar, bulldozer, piledriver, steamroller, excavator
					zen, zen2")

endif()

list(APPEND DIRECTORIES mpn/generic)

#choosing gmp-mparam.h
foreach(d ${DIRECTORIES})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/gmp-mparam.h)
		file(COPY ${d}/gmp-mparam.h DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
		break()
	endif()
endforeach()

#on intel and amd
if(MSVC)
	add_compile_options(/Oy)
else()
	add_compile_options(-fomit-frame-pointer -march=native)
endif()

if(X86_ASM_MULX)
	if(MSVC)
		add_compile_options(/arch:AVX2)
	endif()
endif()
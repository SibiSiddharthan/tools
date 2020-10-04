set(mpn_REQUIRED_FILES
  add add_1 add_n sub sub_1 sub_n cnd_add_n cnd_sub_n cnd_swap neg com
  mul_1 addmul_1 submul_1
  lshift rshift dive_1 diveby3 divis divrem divrem_1 divrem_2
  fib2_ui mod_1 mod_34lsub1 mode1o  pre_mod_1 dump
  mod_1_1 mod_1_2 mod_1_3 mod_1_4 lshiftc
  mul mul_fft mul_n sqr mul_basecase sqr_basecase nussbaumer_mul
  mulmid_basecase toom42_mulmid mulmid_n mulmid
  random random2 pow_1
  rootrem sqrtrem sizeinbase get_str set_str
  scan0 scan1 popcount hamdist cmp zero_p
  perfsqr perfpow
  gcd_1 gcd gcdext_1 gcdext gcd_subdiv_step
  gcdext_lehmer
  div_q tdiv_qr jacbase jacobi_2 jacobi get_d
  matrix22_mul matrix22_mul1_inverse_vector
  hgcd_matrix hgcd2 hgcd_step hgcd_reduce hgcd hgcd_appr
  hgcd2_jacobi hgcd_jacobi
  mullo_n mullo_basecase sqrlo sqrlo_basecase
  toom22_mul toom32_mul toom42_mul toom52_mul toom62_mul
  toom33_mul toom43_mul toom53_mul toom54_mul toom63_mul
  toom44_mul
  toom6h_mul toom6_sqr toom8h_mul toom8_sqr
  toom_couple_handling
  toom2_sqr toom3_sqr toom4_sqr
  toom_eval_dgr3_pm1 toom_eval_dgr3_pm2
  toom_eval_pm1 toom_eval_pm2 toom_eval_pm2exp toom_eval_pm2rexp
  toom_interpolate_5pts toom_interpolate_6pts toom_interpolate_7pts
  toom_interpolate_8pts toom_interpolate_12pts toom_interpolate_16pts
  invertappr invert binvert mulmod_bnm1 sqrmod_bnm1
  div_qr_1  div_qr_2 div_qr_2n_pi1 sbpi1_div_q sbpi1_div_qr sbpi1_divappr_q
  dcpi1_div_q dcpi1_div_qr dcpi1_divappr_q
  mu_div_qr mu_divappr_q mu_div_q
  bdiv_q_1
  sbpi1_bdiv_q sbpi1_bdiv_qr
  dcpi1_bdiv_q dcpi1_bdiv_qr
  mu_bdiv_q mu_bdiv_qr
  bdiv_q bdiv_qr broot brootinv bsqrt bsqrtinv
  divexact bdiv_dbm1c redc_1 redc_2 redc_n powm powlo sec_powm
  sec_mul sec_sqr sec_div_qr sec_div_r sec_pi1_div_qr sec_pi1_div_r
  sec_add_1 sec_sub_1 sec_invert
  trialdiv remove
  and_n andn_n nand_n ior_n iorn_n nior_n xor_n xnor_n
  copyi copyd zero sec_tabselect
  comb_tables)

set(mpn_ERROR_FILES
add_err1_n add_err2_n add_err3_n sub_err1_n sub_err2_n sub_err3_n
div_qr_1n_pi1 div_qr_2u_pi1)

set(mpn_OPTIONAL_FILES
  umul udiv
  invert_limb sqr_diagonal sqr_diag_addlsh1
  mul_2 mul_3 mul_4 mul_5 mul_6
  addmul_2 addmul_3 addmul_4 addmul_5 addmul_6 addmul_7 addmul_8
  addlsh1_n sublsh1_n rsblsh1_n rsh1add_n rsh1sub_n
  addlsh2_n sublsh2_n rsblsh2_n
  addlsh_n sublsh_n rsblsh_n
  add_n_sub_n )#addaddmul_1msb0)


#choosing error files
foreach(f ${mpn_ERROR_FILES})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/${f}.c)
		file(COPY mpn/generic/${f}.c DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/mpn)
		list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	endif()
endforeach()

set(mpn_GSOURCES
add.c div_qr_2u_pi1.c matrix22_mul.c redc_2.c toom_couple_handling.c
add_1.c dive_1.c matrix22_mul1_inverse_vector.c redc_n.c toom_eval_dgr3_pm1.c
add_err1_n.c
 diveby3.c mod_1.c remove.c toom_eval_dgr3_pm2.c
add_err2_n.c divexact.c mod_1_1.c rootrem.c toom_eval_pm1.c
add_err3_n.c divis.c mod_1_2.c rshift.c toom_eval_pm2.c
add_n.c divrem.c mod_1_3.c sbpi1_bdiv_q.c toom_eval_pm2exp.c
add_n_sub_n.c divrem_1.c mod_1_4.c sbpi1_bdiv_qr.c toom_eval_pm2rexp.c
addmul_1.c divrem_2.c mod_34lsub1.c sbpi1_bdiv_r.c toom_interpolate_12pts.c
bdiv_dbm1c.c dump.c mode1o.c sbpi1_div_q.c toom_interpolate_16pts.c
bdiv_q.c fib2_ui.c mu_bdiv_q.c sbpi1_div_qr.c toom_interpolate_5pts.c
bdiv_q_1.c fib2m.c mu_bdiv_qr.c sbpi1_divappr_q.c toom_interpolate_6pts.c
bdiv_qr.c gcd.c mu_div_q.c scan0.c toom_interpolate_7pts.c
binvert.c gcd_1.c mu_div_qr.c scan1.c toom_interpolate_8pts.c
broot.c gcd_11.c mu_divappr_q.c toom2_sqr.c
brootinv.c gcd_22.c mul.c toom22_mul.c
bsqrt.c gcd_subdiv_step.c mul_1.c sec_invert.c toom3_sqr.c
bsqrtinv.c gcdext.c mul_basecase.c sec_mul.c toom32_mul.c
cmp.c gcdext_1.c mul_fft.c toom33_mul.c
cnd_add_n.c gcdext_lehmer.c mul_n.c sec_powm.c toom4_sqr.c
cnd_sub_n.c get_d.c mullo_basecase.c sec_sqr.c toom42_mul.c
cnd_swap.c get_str.c mullo_n.c sec_tabselect.c toom42_mulmid.c
com.c gmp-mparam.h mulmid.c set_str.c toom43_mul.c
comb_tables.c hgcd.c mulmid_basecase.c sizeinbase.c toom44_mul.c
compute_powtab.c hgcd_appr.c mulmid_n.c sqr.c toom52_mul.c
copyd.c hgcd_jacobi.c mulmod_bnm1.c sqr_basecase.c toom53_mul.c
copyi.c hgcd_matrix.c neg.c sqrlo.c toom54_mul.c
dcpi1_bdiv_q.c hgcd_reduce.c nussbaumer_mul.c sqrlo_basecase.c toom6_sqr.c
dcpi1_bdiv_qr.c hgcd_step.c perfpow.c sqrmod_bnm1.c toom62_mul.c
dcpi1_div_q.c hgcd2.c perfsqr.c sqrtrem.c toom63_mul.c
dcpi1_div_qr.c hgcd2_jacobi.c strongfibo.c toom6h_mul.c
dcpi1_divappr_q.c invert.c pow_1.c sub.c toom8_sqr.c
div_q.c invertappr.c powlo.c sub_1.c toom8h_mul.c
div_qr_1.c jacbase.c powm.c
 sub_err1_n.c
  trialdiv.c
div_qr_1n_pi1.c jacobi.c pre_divrem_1.c sub_err2_n.c 
div_qr_1n_pi2.c jacobi_2.c pre_mod_1.c sub_err3_n.c zero.c
div_qr_1u_pi2.c random.c sub_n.c zero_p.c
div_qr_2.c lshift.c random2.c submul_1.c
div_qr_2n_pi1.c lshiftc.c redc_1.c tdiv_qr.c)

list(TRANSFORM mpn_GSOURCES PREPEND "mpn/generic/")

foreach(f ${mpn_GSOURCES} 
	mpn/generic/sec_aors_1.c mpn/generic/sec_div.c mpn/generic/sec_pi1_div.c mpn/generic/popham.c mpn/generic/logops_n.c)
	file(COPY ${f} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/mpn)
endforeach()

list(TRANSFORM mpn_GSOURCES REPLACE "mpn/generic/" "${CMAKE_CURRENT_BINARY_DIR}/mpn/")

add_library(popcount OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/popham.c)
target_compile_definitions(popcount PRIVATE __GMP_WITHIN_GMP OPERATION_popcount)

add_library(hamdist OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/popham.c)
target_compile_definitions(hamdist PRIVATE __GMP_WITHIN_GMP OPERATION_hamdist)

add_library(sec_div_qr OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div.c)
target_compile_definitions(sec_div_qr PRIVATE __GMP_WITHIN_GMP OPERATION_sec_div_qr)

add_library(sec_div_r OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div.c)
target_compile_definitions(sec_div_r PRIVATE __GMP_WITHIN_GMP OPERATION_sec_div_r)

add_library(sec_pi1_div_r OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div.c)
target_compile_definitions(sec_pi1_div_r PRIVATE __GMP_WITHIN_GMP OPERATION_sec_pi1_div_r)

add_library(sec_pi1_div_qr OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div.c)
target_compile_definitions(sec_pi1_div_qr PRIVATE __GMP_WITHIN_GMP OPERATION_sec_pi1_div_qr)

add_library(sec_add_1 OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_aors_1.c)
target_compile_definitions(sec_add_1 PRIVATE __GMP_WITHIN_GMP OPERATION_sec_add_1)

add_library(sec_sub_1 OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_aors_1.c)
target_compile_definitions(sec_sub_1 PRIVATE __GMP_WITHIN_GMP OPERATION_sec_sub_1)

foreach(o and_n andn_n nand_n ior_n iorn_n nior_n xor_n xnor_n)
	add_library(${o} OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/logops_n.c)
	target_compile_definitions(${o} PRIVATE __GMP_WITHIN_GMP OPERATION_${o})
endforeach()

file(COPY mpn/x86_64/aors_err1_n.asm DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/mpn)
file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/mpn/aors_err1_n.asm "
	.section .drectve,\"yn\"
	.ascii \"/EXPORT:__gmpn_add_err1_n\"
")

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/add_err1_n.s
			COMMAND ${M4_EXE} ${GMP_DEFINES} -DOPERATION_add_err1_n -I ${CMAKE_CURRENT_BINARY_DIR}/mpn ${CMAKE_CURRENT_BINARY_DIR}/mpn/aors_err1_n.asm > ${CMAKE_CURRENT_BINARY_DIR}/mpn/add_err1_n.s)
			

add_custom_target(aaa ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/mpn/add_err1_n.s)
add_library(add_err1_n OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/add_err1_n.s)
add_dependencies(add_err1_n aaa)

#add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sub_err1_n.s)

add_library(mpn OBJECT ${mpn_GSOURCES})
add_dependencies(mpn mpn_gen)
target_compile_definitions(mpn PRIVATE __GMP_WITHIN_GMP)
set(mpn_links mpn popcount hamdist sec_div_qr sec_div_r sec_pi1_div_r 
sec_pi1_div_qr and_n andn_n nand_n ior_n iorn_n nior_n xor_n xnor_n sec_add_1 sec_sub_1 )#add_err1_n)

#choosing mpn required files
#[[
foreach(f ${mpn_REQUIRED_FILES})
set(tf ${f})
string(FIND ${tf} "add" a_pos)
string(FIND ${tf} "sub" s_pos)
string(FIND ${tf} "rsb" r_pos)
foreach(d ${DIRECTORIES})

#add or sub
	if(NOT ${a_pos}  EQUAL -1 )
	string(REPLACE "add" "aors" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
#add or right shift
	string(REPLACE "add" "aorr" ttf2 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()
#add or sub
	if(NOT ${s_pos}  EQUAL -1 )
	string(REPLACE "sub" "aors" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()
#sub or right shift
	if(NOT ${r_pos}  EQUAL -1 )
	string(REPLACE "rsb" "aorr" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()


	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()

	if(${tf} STREQUAL "popcount" )
	string(REPLACE "popcount" "popham" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()


	if(${tf} STREQUAL "hamdist" )
	string(REPLACE "hamdist" "popham" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()
endforeach()
endforeach()

#mpn optional files
foreach(f ${mpn_OPTIONAL_FILES})
set(tf ${f})
string(FIND ${tf} "add" a)
string(FIND ${tf} "sub" s)
string(FIND ${tf} "rsb" r)
foreach(d ${DIRECTORIES})
	if(NOT ${a}  EQUAL -1 )
	string(REPLACE "add" "aors" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()

	string(REPLACE "add" "aorr" ttf2 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()

	if(NOT ${s}  EQUAL -1 )
	string(REPLACE "sub" "aors" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()

	if(NOT ${r}  EQUAL -1 )
	string(REPLACE "rsb" "aorr" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
endforeach()
endforeach()

#message("${mpn_S}")

#exceptional cases
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_div.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_qr.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_div.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_qr.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_qr.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES sec_div_qr)

	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_r.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_div.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_r.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_r.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES sec_div_r)
endif()

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_pi1_div.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_qr.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_pi1_div.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_qr.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_qr.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES sec_pi1_div_qr)

	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_r.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_pi1_div.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_r.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_r.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES sec_pi1_div_r)
endif()

foreach(i and_n;andn_n;nand_n;ior_n;iorn_n;nior_n;xor_n;xnor_n)
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/mpn/x86_64/logops_n.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${i}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/x86_64/logops_n.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${i}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${i}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${i})
	set(HAVE_NATIVE_mpn_{i} 1)
endif()
endforeach()

set(HAVE_NATIVE_mpn_copyi 1)
set(HAVE_NATIVE_mpn_copyd 1)



list(LENGTH mpn_REQUIRED_FILES l)
if(NOT ${l} EQUAL 0)
message("${mpn_REQUIRED_FILES}")
message(FATAL_ERROR "missing required files report bug")
endif()
#message("${mpn_OPTIONAL_FILES}")
]]

#[[
foreach(s ${mpn_S})
	string(REPLACE ${CMAKE_CURRENT_BINARY_DIR}/mpn/ "" s ${s})
	string(FIND ${s} ".c" c)
	string(FIND ${s} ".asm" as)
	if(NOT ${c} EQUAL -1)
		set(def ${s})
		string(REPLACE ".c" "" def ${def})
		add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o
							COMMAND ${CMAKE_C_COMPILER} -c ${GMP_COMPILE_FLAGS} ${GMP_DEFINES} -DOPERATION_${def} -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/mpn/${s} -o ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o)
		list(APPEND mpn_O ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o)
	elseif(NOT ${as} EQUAL -1)
		set(def ${s})
		string(REPLACE ".asm" "" def ${def})
		add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o
							COMMAND ${M4_EXE} ${GMP_DEFINES} -DOPERATION_${def} -I ${CMAKE_CURRENT_BINARY_DIR}/mpn ${CMAKE_CURRENT_BINARY_DIR}/mpn/${s} > ${CMAKE_CURRENT_BINARY_DIR}/mpn/${def}.s
							COMMAND ${CMAKE_C_COMPILER} -c ${GMP_COMPILE_FLAGS} ${GMP_DEFINES} -DOPERATION_${def} -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/mpn/${def}.s -o ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o)
		list(APPEND mpn_O ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o)
	endif()
endforeach()

add_custom_target(mpn_obj
					DEPENDS mpn ${mpn_O})
]]
#message(${mpn_S})
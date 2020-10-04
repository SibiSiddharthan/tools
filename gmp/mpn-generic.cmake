set(mpn_GSOURCES
add.c div_qr_2u_pi1.c matrix22_mul.c redc_2.c toom_couple_handling.c
add_1.c dive_1.c matrix22_mul1_inverse_vector.c redc_n.c toom_eval_dgr3_pm1.c
add_err1_n.c diveby3.c mod_1.c remove.c toom_eval_dgr3_pm2.c
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
div_qr_1.c jacbase.c powm.c sub_err1_n.c trialdiv.c
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
add_dependencies(popcount gmp_gen)

add_library(hamdist OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/popham.c)
target_compile_definitions(hamdist PRIVATE __GMP_WITHIN_GMP OPERATION_hamdist)
add_dependencies(hamdist gmp_gen)

add_library(sec_div_qr OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div.c)
target_compile_definitions(sec_div_qr PRIVATE __GMP_WITHIN_GMP OPERATION_sec_div_qr)
add_dependencies(sec_div_qr gmp_gen)

add_library(sec_div_r OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div.c)
target_compile_definitions(sec_div_r PRIVATE __GMP_WITHIN_GMP OPERATION_sec_div_r)
add_dependencies(sec_div_r gmp_gen)

add_library(sec_pi1_div_r OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div.c)
target_compile_definitions(sec_pi1_div_r PRIVATE __GMP_WITHIN_GMP OPERATION_sec_pi1_div_r)
add_dependencies(sec_pi1_div_r gmp_gen)

add_library(sec_pi1_div_qr OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div.c)
target_compile_definitions(sec_pi1_div_qr PRIVATE __GMP_WITHIN_GMP OPERATION_sec_pi1_div_qr)
add_dependencies(sec_pi1_div_qr gmp_gen)

add_library(sec_add_1 OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_aors_1.c)
target_compile_definitions(sec_add_1 PRIVATE __GMP_WITHIN_GMP OPERATION_sec_add_1)
add_dependencies(sec_add_1 gmp_gen)

add_library(sec_sub_1 OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_aors_1.c)
target_compile_definitions(sec_sub_1 PRIVATE __GMP_WITHIN_GMP OPERATION_sec_sub_1)
add_dependencies(sec_sub_1 gmp_gen)

foreach(o and_n andn_n nand_n ior_n iorn_n nior_n xor_n xnor_n)
	add_library(${o} OBJECT ${CMAKE_CURRENT_BINARY_DIR}/mpn/logops_n.c)
	target_compile_definitions(${o} PRIVATE __GMP_WITHIN_GMP OPERATION_${o})
	add_dependencies(${o} gmp_gen)
endforeach()

add_library(mpn OBJECT ${mpn_GSOURCES})
target_compile_definitions(mpn PRIVATE __GMP_WITHIN_GMP)
add_dependencies(mpn gmp_gen)

set(mpn_links mpn popcount hamdist sec_div_qr sec_div_r sec_pi1_div_r 
sec_pi1_div_qr and_n andn_n nand_n ior_n iorn_n nior_n xor_n xnor_n sec_add_1 sec_sub_1)
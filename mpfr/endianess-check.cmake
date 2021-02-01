#[[
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
]]

include(CheckCSourceRuns)

check_c_source_runs("
int
main (void)
{
union ieee_double_extract
{
  double d;
  unsigned char x[8];
} t;
t.d = 2.877939254133025759330166692961938679218292236328125; /* exact */
if (sizeof (double) != 8)
   return 0;
if (sizeof (unsigned char) != 1)
   return 0;
if (t.x[0] == 1 && t.x[1] == 2 && t.x[2] == 3 && t.x[3] == 4 &&
    t.x[4] == 5 && t.x[5] == 6 && t.x[6] == 7 && t.x[7] == 64)
   return 1; /* little endian */
else if (t.x[7] == 1 && t.x[6] == 2 && t.x[5] == 3 && t.x[4] == 4 &&
    t.x[3] == 5 && t.x[2] == 6 && t.x[1] == 7 && t.x[0] == 64)
   return 2; /* big endian */
else
   return 0; /* unknown */
  ;
  return 0;
}"
ENDIANESS_CHECK)
if(${ENDIANESS_CHECK_EXITCODE} EQUAL 1)
	set(HAVE_DOUBLE_IEEE_LITTLE_ENDIAN 1)
	set(HAVE_LITTLE_ENDIAN 1)
elseif(${ENDIANESS_CHECK_EXITCODE} EQUAL 2)
	set(HAVE_DOUBLE_IEEE_BIG_ENDIAN 1)
	set(HAVE_BIG_ENDIAN 1)
else()
	message(FATAL_ERROR "Can't determine Endianess")
endif()

check_c_source_runs("
int
main (void)
{

    union ieee_decimal128
    {
      struct
      {
        unsigned int t3:32;
        unsigned int t2:32;
        unsigned int t1:32;
        unsigned int t0:14;
        unsigned int comb:17;
        unsigned int sig:1;
      } s;
      _Decimal128 d128;
    } x;

    x.d128 = 1.0dl;
    if (x.s.sig == 0 && x.s.comb == 49400 &&
        x.s.t0 == 0 && x.s.t1 == 0 && x.s.t2 == 0 && x.s.t3 == 10)
       return 80; /* little endian */
    else if (x.s.sig == 0 && x.s.comb == 8 &&
             x.s.t0 == 0 && x.s.t1 == 0 && x.s.t2 == 0 && x.s.t3 == 570933248)
       return 81; /* big endian */
    else
       return 82; /* unknown encoding */

  ;
  return 0;
}"
DECIMAL128_CHECK)
if(DECIMAL128_CHECK_COMPILED)
	if(${DECIMAL128_CHECK_EXITCODE} EQUAL 80)
		set(HAVE_DECIMAL128_IEEE_LITTLE_ENDIAN 1)
	elseif(${DECIMAL128_CHECK_EXITCODE} EQUAL 81)
		set(HAVE_DECIMAL128_IEEE_BIG_ENDIAN 1)
	endif()
endif()

check_c_source_runs("
int main()
{
	return (sizeof(long double) == sizeof(double));
}"
HAVE_LDOUBLE_IS_DOUBLE 1)

#set(HAVE_LDOUBLE_IEEE_EXT_LITTLE 1)

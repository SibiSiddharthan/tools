set(CMAKE_REQUIRED_LIBRARIES ${GMP_LIBRARIES})
set(CMAKE_REQUIRED_INCLUDES ${GMP_INCLUDE_DIRS})

check_c_source_runs("
#include <stdio.h>
#include <string.h>

#if ${HAVE_INTTYPES_H}
# include <inttypes.h>
#endif
#if ${HAVE_STDINT_H}
# include <stdint.h>
#endif

#include <gmp.h>

int
main (void)
{

  char s[256];
  intmax_t a = 17;

  /* Contrary to the gmp_sprintf test, do not use the 0 flag with the
     precision, as -Werror=format yields an error, even though this
     flag is allowed by the ISO C standard (it is just ignored).
     https://gcc.gnu.org/bugzilla/show_bug.cgi?id=70813 */
  if (sprintf (s, \"(%.0jd)(%d)\", a, 42) != 8 ||
      strcmp (s, \"(17)(42)\") != 0)
    return 1;

  if (gmp_sprintf (s, \"(%0.0jd)(%d)\", a, 42) == -1 ||
      strcmp (s, \"(17)(42)\") != 0)
    return 1;

  return 0;

  ;
  return 0;
}"
PRINTF_J)
if(NOT PRINTF_J)
	set(NPRINTF_J 1)
endif()

check_c_source_runs("
#include <stdio.h>
#include <string.h>

#if ${HAVE_INTTYPES_H}
# include <inttypes.h>
#endif
#if ${HAVE_STDINT_H}
# include <stdint.h>
#endif

#include <gmp.h>

int
main (void)
{

  char s[256];
  intmax_t a = 17;

  /* Contrary to the gmp_sprintf test, do not use the 0 flag with the
     precision, as -Werror=format yields an error, even though this
     flag is allowed by the ISO C standard (it is just ignored).
     https://gcc.gnu.org/bugzilla/show_bug.cgi?id=70813 */
  if (sprintf (s, \"(%.0lld)(%d)\", a, 42) != 8 ||
  strcmp (s, \"(17)(42)\") != 0)
return 1;

if (gmp_sprintf (s, \"(%0.0lld)(%d)\", a, 42) == -1 ||
  strcmp (s, \"(17)(42)\") != 0)
return 1;

return 0;

  ;
  return 0;
}"
PRINTF_LL)
if(NOT PRINTF_LL)
	set(NPRINTF_LL 1)
endif()

check_c_source_runs("
#include <stdio.h>
#include <string.h>

#if ${HAVE_INTTYPES_H}
# include <inttypes.h>
#endif
#if ${HAVE_STDINT_H}
# include <stdint.h>
#endif

#include <gmp.h>

int
main (void)
{

  char s[256];
  intmax_t a = 17;

  /* Contrary to the gmp_sprintf test, do not use the 0 flag with the
     precision, as -Werror=format yields an error, even though this
     flag is allowed by the ISO C standard (it is just ignored).
     https://gcc.gnu.org/bugzilla/show_bug.cgi?id=70813 */
  if (sprintf (s, \"(%.0hhd)(%d)\", a, 42) != 8 ||
  strcmp (s, \"(17)(42)\") != 0)
return 1;

if (gmp_sprintf (s, \"(%0.0hhd)(%d)\", a, 42) == -1 ||
  strcmp (s, \"(17)(42)\") != 0)
return 1;

return 0;

  ;
  return 0;
}"
PRINTF_HH)
if(NOT PRINTF_HH)
	set(NPRINTF_HH 1)
endif()

check_c_source_runs("
#include <stdio.h>
#include <string.h>

#if ${HAVE_INTTYPES_H}
# include <inttypes.h>
#endif
#if ${HAVE_STDINT_H}
# include <stdint.h>
#endif

#include <gmp.h>

int
main (void)
{

  char s[256];
  intmax_t a = 17;

  /* Contrary to the gmp_sprintf test, do not use the 0 flag with the
     precision, as -Werror=format yields an error, even though this
     flag is allowed by the ISO C standard (it is just ignored).
     https://gcc.gnu.org/bugzilla/show_bug.cgi?id=70813 */
  if (sprintf (s, \"(%.0td)(%d)\", a, 42) != 8 ||
  strcmp (s, \"(17)(42)\") != 0)
return 1;

if (gmp_sprintf (s, \"(%0.0td)(%d)\", a, 42) == -1 ||
  strcmp (s, \"(17)(42)\") != 0)
return 1;

return 0;

  ;
  return 0;
}"
PRINTF_T)
if(NOT PRINTF_T)
	set(NPRINTF_T 1)
endif()

check_c_source_runs("
#include <stdio.h>
#include <string.h>

#if ${HAVE_INTTYPES_H}
# include <inttypes.h>
#endif
#if ${HAVE_STDINT_H}
# include <stdint.h>
#endif

#include <gmp.h>

int
main (void)
{

  char s[256];
  intmax_t a = 17;

  /* Contrary to the gmp_sprintf test, do not use the 0 flag with the
     precision, as -Werror=format yields an error, even though this
     flag is allowed by the ISO C standard (it is just ignored).
     https://gcc.gnu.org/bugzilla/show_bug.cgi?id=70813 */
  if (sprintf (s, \"(%.0Lf)(%d)\", a, 42) != 8 ||
  strcmp (s, \"(17)(42)\") != 0)
return 1;

if (gmp_sprintf (s, \"(%0.0Lf)(%d)\", a, 42) == -1 ||
  strcmp (s, \"(17)(42)\") != 0)
return 1;

return 0;

  ;
  return 0;
}"
PRINTF_L)
if(NOT PRINTF_L)
	set(NPRINTF_L 1)
endif()

check_c_source_runs("
#include <string.h>
#include <gmp.h>

int
main (void)
{

  char s[256];

  if (gmp_sprintf (s, \"%'d\", 17) == -1) return 1;
  return (strcmp (s, \"17\") != 0);

  ;
  return 0;
}"
PRINTF_GROUPFLAG)

unset(CMAKE_REQUIRED_LIBRARIES)
unset(CMAKE_REQUIRED_INCLUDES)
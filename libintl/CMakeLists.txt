#[[
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
]]

cmake_minimum_required(VERSION 3.12)
project(libintl 
		VERSION 0.21 
		LANGUAGES C )

set(PACKAGE \"gettext-runtime\")
set(PACKAGE_BUGREPORT \"bug-gettext@gnu.org\")
set(PACKAGE_NAME \"gettext-runtime\")
set(PACKAGE_STRING \"gettext-runtime\ ${PROJECT_VERSION}\")
set(PACKAGE_TARNAME \"gettext-runtime\")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"${PROJECT_VERSION}\")
set(VERSION \"${PROJECT_VERSION}\")

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
add_compile_definitions(HAVE_CONFIG_H)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
include(UtilityFunctions)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(LargeFiles)
include(alloca)
include(inline)
include(restrict)
include(visibility)

if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
	set(HAVE_VISIBILITY 0) # for declspec
endif()

check_c_headers(alloca.h argz.h features.h iconv.h inttypes.h langinfo.h limits.h 
		pthread.h stddef.h stdint.h stdlib.h sys/param.h threads.h unistd.h wchar.h wctype.h xlocale.h)

check_functions(argz_count argz_next argz_stringify asprintf getcwd getegid geteuid
		getgid getlocalename_l getuid mbrtowc mempcpy munmap newlocale snprintf
		stpcpy strcasecmp strdup strnlen strtoul thrd_create tsearch uselocale
		wcrtomb wcslen wcsnlen wcwidth wprintf __fsetlocking)
check_functions_declarations(clearerr_unlocked feof_unlocked ferror_unlocked fflush_unlocked fgets_unlocked
		_snprintf _snwprintf)
set(CMAKE_EXTRA_INCLUDE_FILES "wchar.h;wctype.h")
check_types("long long int" _Bool size_t uintmax_t ptrdiff_t wchar_t wint_t mbstate_t)
unset(CMAKE_EXTRA_INCLUDE_FILES)

set(CMAKE_EXTRA_INCLUDE_FILES "pthread.h")
check_types(pthread_rwlock_t)
unset(CMAKE_EXTRA_INCLUDE_FILES)

if(HAVE_PTHREAD_RWLOCK_T)
	set(HAVE_PTHREAD_RWLOCK 1)
endif()

if(NOT HAVE_UINTMAX_T)
	set(uintmax_t "unsigned\ long\ long")
endif()

if(NOT HAVE_SIZE_T)
	set(size_t "unsigned\ int")
endif()

if(NOT HAVE_PTRDIFF_T)
	set(ptrdiff_t long)
endif()

if(NOT HAVE_MBSTATE_T)
	set(mbstate_t int)
endif()

find_package(Iconv REQUIRED)
if(Iconv_FOUND)
	set(HAVE_ICONV 1)
	set(HAVE_ICONV_H 1)
endif()

set(ENABLE_RELOCATABLE 1)
set(ICONV_CONST " ")
set(USER_LABEL_PREFIX " ")
set(HAVE_NAMELESS_LOCALES "0 ")
set(SETLOCALE_NULL_ALL_MTSAFE 1)
set(SETLOCALE_NULL_ONE_MTSAFE 1)

if(WIN32)
	set(USE_WINDOWS_THREADS 1)
else()
	set(USE_POSIX_THREADS 1)
endif()

if(HAVE_PTHREAD_H)
	set(HAVE_PTHREAD_API 1)
endif()

check_c_source_compiles("
#include <stdio.h>
#pragma weak fputs
int main ()
{
  return (fputs == NULL);
}"
HAVE_WEAK_SYMBOLS)

check_c_source_compiles("
int
main (int argc, char **argv)
{
   argc = __builtin_expect (argc, 100);
   return argv[argc != 100][0];
}"
HAVE_BUILTIN_1)

check_c_source_compiles("
#include <builtins.h>
int
main (int argc, char **argv)
{
  argc = __builtin_expect (argc, 100);
  return argv[argc != 100][0];
}"
HAVE_BUILTIN_2)

if(HAVE_BUILTIN_1)
	set(HAVE___BUILTIN_EXPECT 1)
elseif(HAVE_BUILTIN_2)
	set(HAVE___BUILTIN_EXPECT 2)
endif()

check_c_source_compiles("
#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
struct m { struct m *next, **list; char name[]; };
struct s { struct s *p; struct m *m; int n; double d[]; };
int
main (void)
{
	int m = getchar ();
	size_t nbytes = offsetof (struct s, d) + m * sizeof (double);
	nbytes += sizeof (struct s) - 1;
	nbytes -= nbytes % sizeof (struct s);
	struct s *p = malloc (nbytes);
	p->p = p;
	p->m = NULL;
	p->d[0] = 0.0;
	return p->d != (double *) NULL;
	return 0;
}"
FLEXIBLE_ARRAY_MEMBER)

if(NOT FLEXIBLE_ARRAY_MEMBER)
	set(FLEXIBLE_ARRAY_MEMBER 1)
else()
	set(FLEXIBLE_ARRAY_MEMBER "/**/") #nothing
endif()

check_c_source_runs("
#include <stdio.h>
#include <string.h>
/* The string \"%2$d %1$d\", with dollar characters protected from the shell's
   dollar expansion (possibly an autoconf bug).  */
static char format[] = { '%', '2', '$', 'd', ' ', '%', '1', '$', 'd', '\\\\0' };
static char buf[100];
int main ()
{
  sprintf (buf, format, 33, 55);
  return (strcmp (buf, \"55 33\") != 0);
}"
HAVE_POSIX_PRINTF)

if(NOT HAVE_POSIX_PRINTF)
	set(HAVE_POSIX_PRINTF 0)
endif()

check_c_source_runs("
#include <locale.h>
#if ${HAVE_XLOCALE_H}
# include <xlocale.h>
#endif
int main ()
{
  locale_t loc1, loc2;
  if (setlocale (LC_ALL, \"de_DE.UTF-8\") == NULL) return 1;
  if (setlocale (LC_ALL, \"fr_FR.UTF-8\") == NULL) return 1;
  loc1 = newlocale (LC_ALL_MASK, \"de_DE.UTF-8\", (locale_t)0);
  loc2 = newlocale (LC_ALL_MASK, \"fr_FR.UTF-8\", (locale_t)0);
  return !(loc1 == loc2);
}"
HAVE_FAKE_LOCALES)

check_c_source_compiles("
#include <sys/types.h>
#include <inttypes.h>

int
main ()
{
	uintmax_t i = (uintmax_t) -1; return !i;
	return 0;
}"
HAVE_INTTYPES_H_WITH_UINTMAX)

check_c_source_compiles("
#include <sys/types.h>
#include <stdint.h>
int
main ()
{
uintmax_t i = (uintmax_t) -1; return !i;
	;
	return 0;
}"
HAVE_STDINT_H_WITH_UINTMAX)

check_c_source_compiles("
#include <langinfo.h>
int
main ()
{
	char* cs = nl_langinfo(CODESET); return !cs;
	return 0;
}"
HAVE_LANGINFO_CODESET)

check_c_source_compiles("
#include <locale.h>
int
main ()
{
	return LC_MESSAGES;
}"
HAVE_LC_MESSAGES)

check_c_source_runs("
#include <locale.h>
#if HAVE_XLOCALE_H
# include <xlocale.h>
#endif
locale_t loc1;
int main ()
{
  uselocale (NULL);
  setlocale (LC_ALL, \"en_US.UTF-8\");
  return 0;
}"
HAVE_WORKING_USELOCALE)

check_c_source_runs("
#include <stdlib.h> /* for exit() */
#include <signal.h>
#if !(defined _WIN32 && !defined __CYGWIN__)
#include <unistd.h> /* for _exit() */
#endif

static void
sigfpe_handler (int sig)
{
  /* Exit with code 0 if SIGFPE, with code 1 if any other signal.  */
  _exit (sig != SIGFPE);
}

int x = 1;
int y = 0;
int z;
int nan;

int main ()
{
  signal (SIGFPE, sigfpe_handler);
/* IRIX and AIX (when \"xlc -qcheck\" is used) yield signal SIGTRAP.  */
#if (defined (__sgi) || defined (_AIX)) && defined (SIGTRAP)
  signal (SIGTRAP, sigfpe_handler);
#endif
/* Linux/SPARC yields signal SIGILL.  */
#if defined (__sparc__) && defined (__linux__)
  signal (SIGILL, sigfpe_handler);
#endif

  z = x / y;
  nan = y / y;
  exit (2);
}"
INTDIV0_RAISES_SIGFPE)

check_c_source_compiles("
#include <inttypes.h>
#ifdef PRId32
char *p = PRId32;
#endif
int main(){return 0;}"
PRI_MACROS_OK)

if(NOT PRI_MACROS_OK)
	set(PRI_MACROS_BROKEN 1)
endif()

check_c_source_compiles("
#include <pthread.h>
int
main ()
{

int x = (int)PTHREAD_MUTEX_RECURSIVE;
return !x;
}"
HAVE_PTHREAD_MUTEX_RECURSIVE)

check_c_source_runs("
#include <errno.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

#define SUCCEED() exit (0)
#define FAILURE() exit (1)
#define UNEXPECTED(n) (exit (10 + (n)))

/* The main thread creates the waiting writer and the requesting reader threads
   in the default way; this guarantees that they have the same priority.
   We can reuse the main thread as first reader thread.  */

static pthread_rwlock_t lock;
static pthread_t reader1;
static pthread_t writer;
static pthread_t reader2;
static pthread_t timer;
/* Used to pass control from writer to reader2 and from reader2 to timer,
   as in a relay race.
   Passing control from one running thread to another running thread
   is most likely faster than to create the second thread.  */
static pthread_mutex_t baton;

static void *
timer_func (void *ignored)
{
  /* Step 13 (can be before or after step 12):
     The timer thread takes the baton, then waits a moment to make sure
     it can tell whether the second reader thread is blocked at step 12.  */
  if (pthread_mutex_lock (&baton))
    UNEXPECTED (13);
  usleep (100000);
  /* By the time we get here, it's clear that the second reader thread is
     blocked at step 12.  This is the desired behaviour.  */
  SUCCEED ();
}

static void *
reader2_func (void *ignored)
{
  int err;

  /* Step 8 (can be before or after step 7):
     The second reader thread takes the baton, then waits a moment to make sure
     the writer thread has reached step 7.  */
  if (pthread_mutex_lock (&baton))
    UNEXPECTED (8);
  usleep (100000);
  /* Step 9: The second reader thread requests the lock.  */
  err = pthread_rwlock_tryrdlock (&lock);
  if (err == 0)
    FAILURE ();
  else if (err != EBUSY)
    UNEXPECTED (9);
  /* Step 10: Launch a timer, to test whether the next call blocks.  */
  if (pthread_create (&timer, NULL, timer_func, NULL))
    UNEXPECTED (10);
  /* Step 11: Release the baton.  */
  if (pthread_mutex_unlock (&baton))
    UNEXPECTED (11);
  /* Step 12: The second reader thread requests the lock.  */
  err = pthread_rwlock_rdlock (&lock);
  if (err == 0)
    FAILURE ();
  else
    UNEXPECTED (12);
}

static void *
writer_func (void *ignored)
{
  /* Step 4: Take the baton, so that the second reader thread does not go ahead
     too early.  */
  if (pthread_mutex_lock (&baton))
    UNEXPECTED (4);
  /* Step 5: Create the second reader thread.  */
  if (pthread_create (&reader2, NULL, reader2_func, NULL))
    UNEXPECTED (5);
  /* Step 6: Release the baton.  */
  if (pthread_mutex_unlock (&baton))
    UNEXPECTED (6);
  /* Step 7: The writer thread requests the lock.  */
  if (pthread_rwlock_wrlock (&lock))
    UNEXPECTED (7);
  return NULL;
}

int
main ()
{
  reader1 = pthread_self ();

  /* Step 1: The main thread initializes the lock and the baton.  */
  if (pthread_rwlock_init (&lock, NULL))
    UNEXPECTED (1);
  if (pthread_mutex_init (&baton, NULL))
    UNEXPECTED (1);
  /* Step 2: The main thread acquires the lock as a reader.  */
  if (pthread_rwlock_rdlock (&lock))
    UNEXPECTED (2);
  /* Step 3: Create the writer thread.  */
  if (pthread_create (&writer, NULL, writer_func, NULL))
    UNEXPECTED (3);
  /* Job done.  Go to sleep.  */
  for (;;)
    {
      sleep (1);
    }
}"
HAVE_PTHREAD_RWLOCK_RDLOCK_PREFER_WRITER)

check_c_source_runs("
/* Thanks to Mike Haertel and Jim Avera for this test.
   Here is a matrix of mmap possibilities:
	mmap private not fixed
	mmap private fixed at somewhere currently unmapped
	mmap private fixed at somewhere already mapped
	mmap shared not fixed
	mmap shared fixed at somewhere currently unmapped
	mmap shared fixed at somewhere already mapped
   For private mappings, we should verify that changes cannot be read()
   back from the file, nor mmap's back from the file at a different
   address.  (There have been systems where private was not correctly
   implemented like the infamous i386 svr4.0, and systems where the
   VM page cache was not coherent with the file system buffer cache
   like early versions of FreeBSD and possibly contemporary NetBSD.)
   For shared mappings, we should conversely verify that changes get
   propagated back to all the places they're supposed to be.

   Grep wants private fixed already mapped.
   The main things grep needs to know about mmap are:
   * does it exist and is it safe to write into the mmap'd area
   * how to use it (BSD variants)  */

#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#if !defined STDC_HEADERS && !defined HAVE_STDLIB_H
char *malloc ();
#endif

/* This mess was copied from the GNU getpagesize.h.  */
#ifndef HAVE_GETPAGESIZE
# ifdef _SC_PAGESIZE
#  define getpagesize() sysconf(_SC_PAGESIZE)
# else /* no _SC_PAGESIZE */
#  ifdef HAVE_SYS_PARAM_H
#   include <sys/param.h>
#   ifdef EXEC_PAGESIZE
#    define getpagesize() EXEC_PAGESIZE
#   else /* no EXEC_PAGESIZE */
#    ifdef NBPG
#     define getpagesize() NBPG * CLSIZE
#     ifndef CLSIZE
#      define CLSIZE 1
#     endif /* no CLSIZE */
#    else /* no NBPG */
#     ifdef NBPC
#      define getpagesize() NBPC
#     else /* no NBPC */
#      ifdef PAGESIZE
#       define getpagesize() PAGESIZE
#      endif /* PAGESIZE */
#     endif /* no NBPC */
#    endif /* no NBPG */
#   endif /* no EXEC_PAGESIZE */
#  else /* no HAVE_SYS_PARAM_H */
#   define getpagesize() 8192	/* punt totally */
#  endif /* no HAVE_SYS_PARAM_H */
# endif /* no _SC_PAGESIZE */

#endif /* no HAVE_GETPAGESIZE */

int
main ()
{
  char *data, *data2, *data3;
  const char *cdata2;
  int i, pagesize;
  int fd, fd2;

  pagesize = getpagesize ();

  /* First, make a file with some known garbage in it. */
  data = (char *) malloc (pagesize);
  if (!data)
    return 1;
  for (i = 0; i < pagesize; ++i)
    *(data + i) = rand ();
  umask (0);
  fd = creat (\"conftest.mmap\", 0600);
  if (fd < 0)
    return 2;
  if (write (fd, data, pagesize) != pagesize)
    return 3;
  close (fd);

  /* Next, check that the tail of a page is zero-filled.  File must have
     non-zero length, otherwise we risk SIGBUS for entire page.  */
  fd2 = open (\"conftest.txt\", O_RDWR | O_CREAT | O_TRUNC, 0600);
  if (fd2 < 0)
    return 4;
  cdata2 = \"\";
  if (write (fd2, cdata2, 1) != 1)
    return 5;
  data2 = (char *) mmap (0, pagesize, PROT_READ | PROT_WRITE, MAP_SHARED, fd2, 0L);
  if (data2 == MAP_FAILED)
    return 6;
  for (i = 0; i < pagesize; ++i)
    if (*(data2 + i))
      return 7;
  close (fd2);
  if (munmap (data2, pagesize))
    return 8;

  /* Next, try to mmap the file at a fixed address which already has
     something else allocated at it.  If we can, also make sure that
     we see the same garbage.  */
  fd = open (\"conftest.mmap\", O_RDWR);
  if (fd < 0)
    return 9;
  if (data2 != mmap (data2, pagesize, PROT_READ | PROT_WRITE,
		     MAP_PRIVATE | MAP_FIXED, fd, 0L))
    return 10;
  for (i = 0; i < pagesize; ++i)
    if (*(data + i) != *(data2 + i))
      return 11;

  /* Finally, make sure that changes to the mapped area do not
     percolate back to the file as seen by read().  (This is a bug on
     some variants of i386 svr4.0.)  */
  for (i = 0; i < pagesize; ++i)
    *(data2 + i) = *(data2 + i) + 1;
  data3 = (char *) malloc (pagesize);
  if (!data3)
    return 12;
  if (read (fd, data3, pagesize) != pagesize)
    return 13;
  for (i = 0; i < pagesize; ++i)
    if (*(data + i) != *(data3 + i))
      return 14;
  close (fd);
  return 0;
}"
HAVE_MMAP)


configure_file(libintl-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/gettext-runtime/config.h)
configure_file(gettext-runtime/intl/libgnuintl.in.h ${CMAKE_CURRENT_BINARY_DIR}/gettext-runtime/libgnuintl.h)
configure_file(gettext-runtime/intl/libgnuintl.in.h ${CMAKE_CURRENT_BINARY_DIR}/libintl.h)

set(intl_SOURCES
bindtextdom.c dcgettext.c dgettext.c  gettext.c finddomain.c hash-string.c loadmsgcat.c
localealias.c textdomain.c l10nflist.c explodename.c dcigettext.c dcngettext.c
dngettext.c ngettext.c plural.c plural-exp.c localcharset.c threadlib.c
lock.c relocatable.c langprefs.c localename.c localename-table.c log.c printf.c
setlocale.c setlocale-lock.c setlocale_null.c version.c xsize.c osdep.c intl-compat.c)

if(WIN32)
list(APPEND intl_SOURCES
	windows-mutex.c windows-rwlock.c windows-recmutex.c windows-once.c)
endif()

list(TRANSFORM intl_SOURCES PREPEND "gettext-runtime/intl/")

add_library(intl ${intl_SOURCES})
target_compile_definitions(intl PRIVATE ENABLE_RELOCATABLE=1 IN_LIBRARY LOCALEDIR="" LOCALE_ALIAS_PATH=""
						NO_XMALLOC BUILDING_LIBINTL IN_LIBINTL IN_LIBRARY set_relocation_prefix=libintl_set_relocation_prefix
						relocate=libintl_relocate relocate2=libintl_relocate2 DEPENDS_ON_LIBICONV=1)
target_include_directories(intl PRIVATE gettext-runtime/gnulib-lib gettext-runtime/intl ${CMAKE_CURRENT_BINARY_DIR}/gettext-runtime)
target_link_libraries(intl Iconv::Iconv)
if(NOT MSVC)
	target_compile_options(intl PRIVATE -fvisibility=hidden)
endif()
if(BUILD_SHARED_LIBS)
	set_target_properties(intl PROPERTIES RUNTIME_OUTPUT_NAME "libintl-${PROJECT_VERSION}" ARCHIVE_OUTPUT_NAME "intl")
	target_compile_definitions(intl PRIVATE BUILDING_DLL)
endif()

install(TARGETS intl
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		RUNTIME DESTINATION bin)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libintl.h 
		DESTINATION include)
file(GLOB man_html "gettext-runtime/man/*3.html")
install(FILES ${man_html} DESTINATION share/doc)
file(GLOB man3_files "gettext-runtime/man/*.3")
install(FILES ${man3_files} DESTINATION share/man/man3)

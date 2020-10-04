cmake_minimum_required(VERSION 3.13)
project(make 
		VERSION 4.2.1
		LANGUAGES C)


set(PACKAGE \"make\")
set(PACKAGE_BUGREPORT \"bug-make@gnu.org\")
set(PACKAGE_NAME \"GNU\ make\")
set(PACKAGE_STRING \"GNU\ make\ ${PROJECT_VERSION}\")
set(PACKAGE_TARNAME \"make\")
set(PACKAGE_URL \"http://www.gnu.org/software/make/\")
set(PACKAGE_VERSION \"${PROJECT_VERSION}\")
set(VERSION \"${PROJECT_VERSION}\")

add_compile_definitions(HAVE_CONFIG_H)
if(WIN32)
	add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE TUKLIB_DOSLIKE)
endif()

option(USE_CUSTOMS "Job exportation to Customs daemon" OFF) #Unsupported

#defaults
set(MAKE_LOAD 1)
set(MAKE_JOBSERVER 1)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
find_package(Iconv)
find_package(Intl)
include(UtilityFunctions)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckLibraryExists)
include(CheckStructHasMember)
include(alloca)
include(fork)
include(LargeFiles)
include(TimeWithSysTime)

if(Intl_FOUND)
	set(HAVE_ICONV)
endif()

if(Intl_FOUND)
  set(ENABLE_NLS 1)
  set(HAVE_GETTEXT 1)
  set(HAVE_DCGETTEXT 1)
endif()


if(NOT HAVE_ALLOCA)
	set(C_ALLOCA 1)
endif()

check_c_headers(dirent.h fcntl.h inttypes.h limits.h locale.h mach/mach.h memory.h ndir.h 
			nlist.h stdint.h stdlib.h strings.h string.h sys/dir.h sys/ndir.h sys/param.h 
			sys/resource.h sys/select.h sys/stat.h sys/timeb.h sys/time.h sys/types.h 
			sys/wait.h unistd.h vfork.h)

check_functions(atexit dup dup2 fdopen fileno fork getcwd getgroups gethostbyname gethostname
			getloadavg getrlimit isatty lstat mkstemp mktemp pipe pselect pstat_getdynamic 
			readlink realpath setegid seteuid setlinebuf setlocale setregid setreuid setrlimit 
			setvbuf sigaction sigsetmask socket strcasecmp strcmpi strcoll strdup strerror stricmp 
			strncasecmp strncmpi strndup strnicmp strsignal ttyname vfork wait3 waitpid gettimeofday)

if(HAVE_LSTAT AND HAVE_READLINK)
	set(MAKE_SYMLINKS 1)
endif()

set(CMAKE_EXTRA_INCLUDE_FILES "dlfcn.h")
set(CMAKE_REQUIRED_LIBRARIES "dl")
check_functions_declarations(dlerror dlopen dlsym)
unset(CMAKE_REQUIRED_LIBRARIES)

set(CMAKE_EXTRA_INCLUDE_FILES "signal.h")
check_functions_declarations(bsd_signal sys_siglist _sys_siglist __sys_siglist)
unset(CMAKE_EXTRA_INCLUDE_FILES)

check_types(uintmax_t "unsigned long long int" gid_t off_t pid_t size_t ssize_t uid_t)

if(NOT HAVE_GID_T)
	set(gid_t int)
endif()

if(NOT HAVE_OFF_T)
	set(off_t "long\ int")
endif()

if(NOT HAVE_PID_T)
	set(pid_t int)
endif()

if(NOT HAVE_SIZE_T)
	set(size_t "unsigned\ int")
endif()

if(NOT HAVE_SSIZE_T)
	set(ssize_t int)
endif()

if(NOT HAVE_UID_T)
	set(uid_t int)
endif()

if(NOT HAVE_UINTMAX_T)
	set(uintmax_t "unsigned\ long\ long\ int")
endif()

check_library_exists(dgc dg_sys_info "" HAVE_LIBDGC)
check_library_exists(kstat kstat_open "" HAVE_LIBKSTAT)

check_struct_has_member("struct stat" "ST_MTIM_NSEC" "sys/stat.h;sys/types.h" ST_MTIM_NSEC)
check_struct_has_member("struct nlist" "n_un.n_name" nlist.h HAVE_STRUCT_NLIST_N_UN_N_NAME)
if(HAVE_STRUCT_NLIST_N_UN_N_NAME)
	set(NLIST_NAME_UNION 1)
endif()

if(NOT HAVE_GETLOADAVG)
	set(C_GETLOADAVG 1)
endif()

if(EXISTS "/usr/sccs/get")
	set(SCCS_GET \"/usr/sccs/get\")
else()
	set(SCCS_GET \"get\")
endif()

if(WIN32)
	set(HAVE_DOS_PATHS 1)
	set(PATH_SEPARATOR_CHAR ';')
	set(WINDOWS32 1)
	set(HAVE_CASE_INSENSITIVE_FS 1)
	set(MAKE_HOST \"Windows32\")
	# have compat replacements
	set(HAVE_DIRENT_H 1)
	set(HAVE_DLFCN_H 1)
	set(SCCS_GET \"echo\ no\ sccs\ get\")
elseif(UNIX)
	set(PATH_SEPARATOR_CHAR ':')
	set(MAKE_HOST \"x86_64-linux-gnu\")
endif()


check_c_source_runs("
#include <dirent.h>
#ifndef __cplusplus
int closedir ();
#endif

int
main (void)
{
	return closedir (opendir (\".\")) != 0;
}"
CLOSEDIR_NOT_VOID)
if(NOT CLOSEDIR_NOT_VOID)
	set(CLOSEDIR_VOID 1)
endif()

check_c_source_compiles("
#include <signal.h>
int
main ()
{
	return SA_RESTART;
}"
HAVE_SA_RESTART)

check_c_source_compiles("
#include <nlist.h>
int
main ()
{
struct nlist nl;
          nl.n_name = \"string\";
          return 0;
  ;
  return 0;
}"
NLIST_STRUCT)

check_c_source_compiles("
#include <sys/types.h>
#include <sys/wait.h>
int
main ()
{
union wait status; int pid; pid = wait (&status);
#ifdef WEXITSTATUS
/* Some POSIXoid systems have both the new-style macros and the old
   union wait type, and they do not work together.  If union wait
   conflicts with WEXITSTATUS et al, we don't want to use it at all.  */
        if (WEXITSTATUS (status) != 0) pid = -1;
#ifdef WTERMSIG
        /* If we have WEXITSTATUS and WTERMSIG, just use them on ints.  */
        -- blow chunks here --
#endif
#endif
#ifdef HAVE_WAITPID
        /* Make sure union wait works with waitpid.  */
        pid = waitpid (-1, &status, 0);
#endif

  return 0;
}"
HAVE_UNION_WAIT)

check_c_source_compiles("
#include <sys/types.h>
#include <sys/stat.h>

#if defined S_ISBLK && defined S_IFDIR
extern char c1[S_ISBLK (S_IFDIR) ? -1 : 1];
#endif

#if defined S_ISBLK && defined S_IFCHR
extern char c2[S_ISBLK (S_IFCHR) ? -1 : 1];
#endif

#if defined S_ISLNK && defined S_IFREG
extern char c3[S_ISLNK (S_IFREG) ? -1 : 1];
#endif

#if defined S_ISSOCK && defined S_IFREG
extern char c4[S_ISSOCK (S_IFREG) ? -1 : 1];
#endif

int main()
{
	return 0;
}"
STAT_MACROS_OKAY)
if(NOT STAT_MACROS_OKAY)
	set(STAT_MACROS_BROKEN 1)
endif()

check_c_source_compiles("
# include <inttypes.h>
#endif
int
main ()
{
char a[0x7fffffff < (uintmax_t)-1 >> 30 ? 1 : -1];
  ;
  return 0;
}"
FILE_TIMESTAMP_HI_RES)

check_c_source_compiles("
#include <sys/types.h>
#include <signal.h>

int
main ()
{
return *(signal (0, 0)) (0) == 1;
  ;
  return 0;
}"
RETSIGTYPE)
if(RETSIGTYPE)
	set(RETSIGTYPE int)
else()
	set(RETSIGTYPE void)
endif()

check_c_source_runs("
int
find_stack_direction (int *addr, int depth)
{
  int dir, dummy = 0;
  if (! addr)
    addr = &dummy;
  *addr = addr < &dummy ? 1 : addr == &dummy ? 0 : -1;
  dir = depth ? find_stack_direction (addr, depth - 1) : 0;
  return dir + dummy;
}

int
main (int argc, char **argv)
{
  return find_stack_direction (0, argc + !argv + 20) < 0;
}"
STACK_DIRECTION)
if(NOT STACK_DIRECTION)
	set(STACK_DIRECTION -1)
endif()

configure_file(make-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)

set(make_SOURCES
	ar.c arscan.c commands.c default.c dir.c expand.c file.c 
	function.c getopt.c getopt1.c guile.c implicit.c job.c load.c 
	loadapi.c main.c misc.c output.c read.c remake.c 
	rule.c signame.c strcache.c variable.c version.c vpath.c 
	hash.c)

if(NOT USE_CUSTOMS)
	list(APPEND make_SOURCES remote-stub.c)
else()
	list(APPEND make_SOURCES remote-cstms.c)
endif()

if(C_ALLOCA)
	list(APPEND make_SOURCES alloca.c)
endif()

if(C_GETLOADAVG)
	list(APPEND make_SOURCES getloadavg.c)
endif()

if(WIN32)
	list(APPEND make_SOURCES 
	w32/subproc/misc.c w32/subproc/sub_proc.c w32/subproc/w32err.c 
			w32/compat/posixfcn.c w32/compat/dirent.c w32/pathstuff.c w32/w32os.c)
else()
	list(APPEND make_SOURCES posixos.c)
endif()

list(APPEND make_SOURCES 
		glob/glob.c glob/glob.h glob/fnmatch.c glob/fnmatch.h)

add_executable(make ${make_SOURCES})
target_include_directories(make PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR} glob)
target_compile_definitions(make PRIVATE LOCALEDIR="../share/locale" INCLUDEDIR="." LIBDIR=".")
set_target_properties(make PROPERTIES PUBLIC_HEADER gnumake.h)
if(WIN32)
	target_include_directories(make PRIVATE w32/include)
	target_link_options(make PRIVATE )
endif()
target_link_libraries(make ${Intl_LIBRARIES} Iconv::Iconv)
if(UNIX)
	target_link_libraries(make ${Intl_LIBRARIES} Iconv::Iconv dl)
endif()

install(TARGETS make 
	RUNTIME DESTINATION bin
	PUBLIC_HEADER DESTINATION include)
install(FILES doc/make.info doc/make.info-1 doc/make.info-2 DESTINATION share/info)
install(FILES make.1 DESTINATION share/man/man1)

file(GLOB gmo_files "po/*.gmo")
foreach(gmo ${gmo_files})
	string(REPLACE ${CMAKE_CURRENT_SOURCE_DIR}/po "" gmo ${gmo})
	string(REPLACE ".gmo" "" gmo ${gmo})
	install(FILES po/${gmo}.gmo DESTINATION share/locale/${gmo}/LC_MESSAGES/)
	install(CODE "file(RENAME ${CMAKE_INSTALL_PREFIX}/share/locale/${gmo}/LC_MESSAGES/${gmo}.gmo ${CMAKE_INSTALL_PREFIX}/share/locale/${gmo}/LC_MESSAGES/make.mo)")
endforeach()

include(CTest)
if(BUILD_TESTING)

set(AM_LDFLAGS )
set(AR ${CMAKE_AR})
set(CC ${CMAKE_C_COMPILER})
set(CFLAGS -O2)
set(CPP "${CMAKE_C_COMPILER}\ -E")

configure_file(tests/config-flags.pm.in ${CMAKE_CURRENT_SOURCE_DIR}/tests/config-flags.pm @ONLY)

find_package(Perl REQUIRED)
add_custom_target(check 
		COMMAND ${PERL_EXECUTABLE} -I. run_make_tests.pl -make_path ${CMAKE_CURRENT_BINARY_DIR}/make${CMAKE_EXECUTABLE_SUFFIX}
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tests
		USES_TERMINAL)
endif()


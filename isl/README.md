## DEPENDS
* GMP
## NOTE
* On Windows platforms we only build the static version of the library.
This is because the library does not export any functions. If we create def file
using the static library and then create a shared library from it, the test executables crash.
This is because all of the test executables use `isl_options_arg` a global variable which is imported.
This variable is defined by a macro which gets assigned to different variable at compile time.
dllimport(ing) this variable throws this error `error: initializer element is not a compile time constant`.
Going through the manual I find no mention of any use of this variable or the macros associated
with it, which leads me to conclude that this variable and the macros are for internal use only.

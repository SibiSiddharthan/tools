## DEPENDS
* GMP
## NOTE
* On Windows platforms we test using the static version of the library.
This is because the library does not export any functions, so we create def file
using the static library, which is then used to create a shared library.
The problem when testing with the shared library is that all of the test executables
use `isl_options_arg` a global variable which is imported. This variable is defined 
in a macro which gets assigned to different variable at compile time. dllimport(ing) this
variable throws this error `error: initializer element is not a compile time constant`.
Going through the manual I find no mention of any use of this variable or the macros associated
with it, which leads me to conclude that this variable and the macros are for internal use only.
Still if you don't want to take the risk configure with `-DBUILD_SHARED_LIBS=OFF`.

## NOTE
* Set Host CPU architecture -DHOST_ARCHITECTURE . By default it sets to x86_64
* Build this package only in Release mode. Due to inlining of functions linking fails during Debug builds.
* Building with assembly is not supported for now. With some introspection I find that Clang -O3 generates better
assembly than the asm files. Some of them outright crash the library.
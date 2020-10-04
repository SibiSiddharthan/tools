## DEPENDS
* libiconv
* libintl
* Perl - only for testing (Run with `-DBUILD_TESTING=OFF`)

## NOTES
* make-4.3 is `BROKEN` on Windows. When I try to test it, perl and cygwin crash the OS. Therefore I am resorting to make-4.2.1
* When testing run `make check` or `ninja check` or `check` target.
* Some tests do fail on Windows, but this version is way better than 4.3

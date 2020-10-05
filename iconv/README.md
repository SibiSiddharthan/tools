## DEPENDS
* libiconv
* libintl

## NOTE
* Don't run the tests in parallel.
* The script only compiles this package on Windows. 
* libiconv and libintl ship as a part of libc, a linux build would require to combine both libiconv and iconv build scripts together.
Since I have decided to build iconv with libintl, I am taking this approach of not supporting Linux for this script.
#!/bin/sh

fail=0

${build_dir=.}/bzip2 -1  < ${srcdir=.}/sample1.ref > ${build_dir=.}/sample1.rb2 || fail=1
${build_dir=.}/bzip2 -2  < ${srcdir=.}/sample2.ref > ${build_dir=.}/sample2.rb2	|| fail=1 
${build_dir=.}/bzip2 -3  < ${srcdir=.}/sample3.ref > ${build_dir=.}/sample3.rb2	|| fail=1
${build_dir=.}/bzip2 -d  < ${srcdir=.}/sample1.bz2 > ${build_dir=.}/sample1.tst	|| fail=1
${build_dir=.}/bzip2 -d  < ${srcdir=.}/sample2.bz2 > ${build_dir=.}/sample2.tst	|| fail=1
${build_dir=.}/bzip2 -ds < ${srcdir=.}/sample3.bz2 > ${build_dir=.}/sample3.tst	|| fail=1

cmp ${srcdir=.}/sample1.bz2 ${build_dir=.}/sample1.rb2 || fail=1
cmp ${srcdir=.}/sample2.bz2 ${build_dir=.}/sample2.rb2 || fail=1
cmp ${srcdir=.}/sample3.bz2 ${build_dir=.}/sample3.rb2 || fail=1
cmp ${srcdir=.}/sample1.ref ${build_dir=.}/sample1.tst || fail=1
cmp ${srcdir=.}/sample2.ref ${build_dir=.}/sample2.tst || fail=1
cmp ${srcdir=.}/sample3.ref ${build_dir=.}/sample3.tst || fail=1

rm ${build_dir=.}/sample*

exit $fail

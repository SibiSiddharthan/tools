'''
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
'''

import urllib.request 
import os
import tarfile
import shutil

filename = "gmp-6.2.0.tar.xz"
directory = ".build/gmp-6.2.0"
patchfile = "gmp-include-stdarg-also.patch"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://ftp.gnu.org/gnu/gmp/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:xz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("gmp-config.h.in","{}/gmp-config.h.in".format(directory))
	shutil.copyfile("m4-config.in","{}/m4-config.in".format(directory))
	os.makedirs("{}/cmake-modules".format(directory),exist_ok=True)
	shutil.copyfile("../support/unistd.h.in","{}/unistd.h.in".format(directory))
	shutil.copyfile("../cmake-modules/UtilityFunctions.cmake","{}/cmake-modules/UtilityFunctions.cmake".format(directory))
	shutil.copyfile("../cmake-modules/inline.cmake","{}/cmake-modules/inline.cmake".format(directory))
	shutil.copyfile("../cmake-modules/restrict.cmake","{}/cmake-modules/restrict.cmake".format(directory))
	shutil.copyfile("../cmake-modules/alloca.cmake","{}/cmake-modules/alloca.cmake".format(directory))
	shutil.copyfile("../cmake-modules/TimeWithSysTime.cmake","{}/cmake-modules/TimeWithSysTime.cmake".format(directory))
	shutil.copyfile("HostCPUArch.cmake","{}/cmake-modules/HostCPUArch.cmake".format(directory))
	shutil.copyfile("mpn-generic.cmake","{}/cmake-modules/mpn-generic.cmake".format(directory))
	shutil.copyfile("mpn-asm.cmake","{}/cmake-modules/mpn-asm.cmake".format(directory))

shutil.copyfile("{}/gmp-h.in".format(directory),"./gmp-h.in")
success = os.system("git --work-tree=. --git-dir=.git apply {}".format(patchfile))
if success == 0:
	shutil.move("./gmp-h.in","{}/gmp-h.in".format(directory))
else : 
	os.remove("./gmp-h.in")

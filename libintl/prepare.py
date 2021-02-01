'''
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
'''

import urllib.request 
import os
import tarfile
import shutil

filename = "gettext-0.21.tar.gz"
directory = ".build/gettext-0.21"
patchfile = "fix-import-export-macros.patch"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://ftp.gnu.org/pub/gnu/gettext/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("libintl-config.h.in","{}/libintl-config.h.in".format(directory))
	os.makedirs("{}/cmake-modules".format(directory),exist_ok=True)
	shutil.copyfile("../cmake-modules/UtilityFunctions.cmake","{}/cmake-modules/UtilityFunctions.cmake".format(directory))
	shutil.copyfile("../cmake-modules/inline.cmake","{}/cmake-modules/inline.cmake".format(directory))
	shutil.copyfile("../cmake-modules/restrict.cmake","{}/cmake-modules/restrict.cmake".format(directory))
	shutil.copyfile("../cmake-modules/visibility.cmake","{}/cmake-modules/visibility.cmake".format(directory))
	shutil.copyfile("../cmake-modules/alloca.cmake","{}/cmake-modules/alloca.cmake".format(directory))
	shutil.copyfile("../cmake-modules/LargeFiles.cmake","{}/cmake-modules/LargeFiles.cmake".format(directory))

shutil.copyfile("{}/gettext-runtime/intl/libgnuintl.in.h".format(directory),"./libgnuintl.in.h")
success = os.system("git --work-tree=. --git-dir=.git apply {}".format(patchfile))
if success == 0:
	shutil.move("./libgnuintl.in.h","{}/gettext-runtime/intl/libgnuintl.in.h".format(directory))
else : 
	os.remove("./libgnuintl.in.h")

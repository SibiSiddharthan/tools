'''
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
'''

import urllib.request 
import os
import tarfile
import shutil

filename = "isl-0.22.1.tar.xz"
directory = ".build/isl-0.22.1"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("http://isl.gforge.inria.fr/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:xz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("isl-config.h.in","{}/isl-config.h.in".format(directory))
	shutil.copyfile("isl-dll.def","{}/isl-dll.def".format(directory))
	os.makedirs("{}/cmake-modules".format(directory),exist_ok=True)
	shutil.copyfile("../cmake-modules/UtilityFunctions.cmake","{}/cmake-modules/UtilityFunctions.cmake".format(directory))
	shutil.copyfile("../cmake-modules/FindGMP.cmake","{}/cmake-modules/FindGMP.cmake".format(directory))

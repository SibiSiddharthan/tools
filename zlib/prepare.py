'''
   Copyright (c) 2020-2021 Sibi Siddharthan

   Distributed under the MIT license.
   Refer to the LICENSE file at the root directory for details.
'''

import urllib.request 
import os
import tarfile
import shutil

filename = "zlib-1.2.11.tar.gz"
directory = ".build/zlib-1.2.11"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://github.com/madler/zlib/archive/v1.2.11.tar.gz", filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))

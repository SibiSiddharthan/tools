import urllib.request 
import os
import tarfile
import shutil

filename = "mpfr-4.1.0.tar.gz"
directory = ".build/mpfr-4.1.0"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://www.mpfr.org/mpfr-current/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("mpfr-config.h.in","{}/mpfr-config.h.in".format(directory))
	os.makedirs("{}/cmake-modules".format(directory),exist_ok=True)
	shutil.copyfile("../cmake-modules/UtilityFunctions.cmake","{}/cmake-modules/UtilityFunctions.cmake".format(directory))
	shutil.copyfile("../cmake-modules/alloca.cmake","{}/cmake-modules/alloca.cmake".format(directory))
	shutil.copyfile("../cmake-modules/FindGMP.cmake","{}/cmake-modules/FindGMP.cmake".format(directory))
	shutil.copyfile("endianess-check.cmake","{}/cmake-modules/endianess-check.cmake".format(directory))
	shutil.copyfile("printf-check.cmake","{}/cmake-modules/printf-check.cmake".format(directory))


import urllib.request 
import os
import tarfile
import shutil

filename = "libiconv-1.16.tar.gz"
directory = ".build/libiconv-1.16"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://ftp.gnu.org/pub/gnu/libiconv/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("libiconv-config.h.in","{}/libiconv-config.h.in".format(directory))
	os.makedirs("{}/cmake-modules".format(directory),exist_ok=True)
	shutil.copyfile("../cmake-modules/UtilityFunctions.cmake","{}/cmake-modules/UtilityFunctions.cmake".format(directory))
	shutil.copyfile("../cmake-modules/inline.cmake","{}/cmake-modules/inline.cmake".format(directory))
	shutil.copyfile("../cmake-modules/visibility.cmake","{}/cmake-modules/visibility.cmake".format(directory))
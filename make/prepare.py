import urllib.request 
import os
import tarfile
import shutil
import platform

filename = "make-4.2.1.tar.gz"
directory = ".build/make-4.2.1"
patchfile_w = "windows.patch"
patchfile_u = "unix.patch"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://ftp.gnu.org/gnu/make/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("make-config.h.in","{}/make-config.h.in".format(directory))
	os.makedirs("{}/cmake-modules".format(directory),exist_ok=True)
	shutil.copyfile("../cmake-modules/UtilityFunctions.cmake","{}/cmake-modules/UtilityFunctions.cmake".format(directory))
	shutil.copyfile("../cmake-modules/fork.cmake","{}/cmake-modules/fork.cmake".format(directory))
	shutil.copyfile("../cmake-modules/alloca.cmake","{}/cmake-modules/alloca.cmake".format(directory))
	shutil.copyfile("../cmake-modules/LargeFiles.cmake","{}/cmake-modules/LargeFiles.cmake".format(directory))

if platform.system() == "Windows":
	shutil.copyfile("{}/makeint.h".format(directory),"./makeint.h")
	shutil.copyfile("{}/w32/compat/posixfcn.c".format(directory),"./posixfcn.c")
	success = os.system("git --work-tree=. --git-dir=.git apply {}".format(patchfile_w))
	if success == 0:
		shutil.move("./makeint.h","{}/makeint.h".format(directory))
		shutil.move("./posixfcn.c","{}/w32/compat/posixfcn.c".format(directory))
	else : 
		os.remove("./makeint.h")
		os.remove("./posixfcn.c")
elif platform.system() == "Linux":
	shutil.copyfile("{}/glob/glob.c".format(directory),"./glob.c")
	success = os.system("git --work-tree=. --git-dir=.git apply {}".format(patchfile_u))
	if success == 0:
		shutil.move("./glob.c","{}/glob/glob.c".format(directory))
	else : 
		os.remove("./glob.c")
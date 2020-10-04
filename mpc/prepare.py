import urllib.request 
import os
import tarfile
import shutil

filename = "mpc-1.2.0.tar.gz"
directory = ".build/mpc-1.2.0"
patchfile = "mpcbench-windows-workaround.patch"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://ftp.gnu.org/gnu/mpc/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("mpc-config.h.in","{}/mpc-config.h.in".format(directory))
	os.makedirs("{}/cmake-modules".format(directory),exist_ok=True)
	shutil.copyfile("../cmake-modules/UtilityFunctions.cmake","{}/cmake-modules/UtilityFunctions.cmake".format(directory))
	shutil.copyfile("../cmake-modules/FindGMP.cmake","{}/cmake-modules/FindGMP.cmake".format(directory))
	shutil.copyfile("../cmake-modules/FindMPFR.cmake","{}/cmake-modules/FindMPFR.cmake".format(directory))
	shutil.copyfile("../cmake-modules/alloca.cmake","{}/cmake-modules/alloca.cmake".format(directory))

shutil.copyfile("{}/tools/bench/mpcbench.c".format(directory),"./mpcbench.c")
success = os.system("git --work-tree=. --git-dir=.git apply {}".format(patchfile))
if success == 0:
	shutil.move("./mpcbench.c","{}/tools/bench/mpcbench.c".format(directory))
else : 
	os.remove("./mpcbench.c")
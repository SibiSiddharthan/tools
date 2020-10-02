import urllib.request 
import os
import tarfile
import shutil

filename = "xz-5.2.5.tar.gz"
directory = ".build/xz-5.2.5"
patchfile = "test-scripts.patch"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://tukaani.org/xz/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("xz-config.h.in","{}/xz-config.h.in".format(directory))
	shutil.copyfile("unistd.h.in","{}/unistd.h.in".format(directory))
	shutil.copyfile("sys_time.h.in","{}/sys_time.h.in".format(directory))
	shutil.copyfile("gettimeofday.c","{}/lib/gettimeofday.c".format(directory))
	os.makedirs("{}/cmake-modules".format(directory),exist_ok=True)
	shutil.copyfile("../cmake-modules/UtilityFunctions.cmake","{}/cmake-modules/UtilityFunctions.cmake".format(directory))
	shutil.copyfile("../cmake-modules/visibility.cmake","{}/cmake-modules/visibility.cmake".format(directory))
	shutil.copyfile("../cmake-modules/LargeFiles.cmake","{}/cmake-modules/LargeFiles.cmake".format(directory))

shutil.copyfile("{}/tests/test_compress.sh".format(directory),"./test_compress.sh")
shutil.copyfile("{}/tests/test_files.sh".format(directory),"./test_files.sh")
shutil.copyfile("{}/tests/test_scripts.sh".format(directory),"./test_scripts.sh")
success = os.system("git --work-tree=. --git-dir=.git apply {}".format(patchfile))
if success == 0:
	shutil.move("./test_compress.sh.in","{}/test_compress.sh.in".format(directory))
	shutil.move("./test_files.sh.in","{}/test_files.sh.in".format(directory))
	shutil.move("./test_scripts.sh.in","{}/test_scripts.sh.in".format(directory))
else :
	os.remove("./test_compress.sh")
	os.remove("./test_files.sh")
	os.remove("./test_scripts.sh")

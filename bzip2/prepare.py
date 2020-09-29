import urllib.request 
import os
import tarfile
import shutil

filename = "bzip2-1.0.8.tar.gz"
directory = ".build/bzip2-1.0.8"
patchfile = "fix-import-export-macros.patch"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://sourceware.org/pub/bzip2/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("bztest.sh","{}/bztest.sh".format(directory))

shutil.copyfile("{}/bzlib.h".format(directory),"./bzlib.h")
success = os.system("git --work-tree=. --git-dir=.git apply {}".format(patchfile))
if success == 0:
	shutil.move("./bzlib.h","{}/bzlib.h".format(directory))
else : 
	os.remove("./bzlib.h")
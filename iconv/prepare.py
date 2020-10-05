import urllib.request 
import os
import tarfile
import shutil

filename = "libiconv-1.16.tar.gz"
directory = ".build/libiconv-1.16"
patchfile = "iconv-tests.patch"

if not os.path.isfile(filename):
	urllib.request.urlretrieve("https://ftp.gnu.org/pub/gnu/libiconv/{}".format(filename), filename)

if not os.path.isdir(directory):
	tar = tarfile.open(filename,"r:gz")
	tar.extractall(".build/")
	tar.close()

if os.path.isdir(directory):
	shutil.copyfile("CMakeLists.txt","{}/CMakeLists.txt".format(directory))
	shutil.copyfile("iconv-config.h.in","{}/iconv-config.h.in".format(directory))
	shutil.copyfile("../support/unistd.h.in","{}/unistd.h.in".format(directory))

shutil.copyfile("{}/tests/check-stateful".format(directory),"./check-stateful")
shutil.copyfile("{}/tests/check-stateless".format(directory),"./check-stateless")
shutil.copyfile("{}/tests/check-subst".format(directory),"./check-subst")
shutil.copyfile("{}/tests/check-translit".format(directory),"./check-translit")
shutil.copyfile("{}/tests/check-translitfailure".format(directory),"./check-translitfailure")
success = os.system("git --work-tree=. --git-dir=.git apply {}".format(patchfile))
if success == 0:
	shutil.move("check-stateful.sh.in","{}/check-stateful.sh.in".format(directory))
	shutil.move("check-stateless.sh.in","{}/check-stateless.sh.in".format(directory))
	shutil.move("check-subst.sh.in","{}/check-subst.sh.in".format(directory))
	shutil.move("check-translit.sh.in","{}/check-translit.sh.in".format(directory))
	shutil.move("check-translitfailure.sh.in","{}/check-translitfailure.sh.in".format(directory))
else :
	os.remove("./check-stateful")
	os.remove("./check-stateless")
	os.remove("./check-subst")
	os.remove("./check-translit")
	os.remove("./check-translitfailure")
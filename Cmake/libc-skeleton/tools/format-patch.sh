$!/bin/bash

##
## if a build server is configured to check for formatting by capturing a patch file, 
## and there are auto-formatting changes that need to be made, a patch file is saved
## and uploaded as a build artifact. If the patch file is empty, no changes are necessary
## and we remove the file
##

find arch src test include -type d \( -path ./src/gdtoa \) -prune -type f \
	-o -iname *.h -o -iname *.c -o -iname *.cpp -o -iname *.hpp \
	| xargs clang-format -style=file -i -fallback-style=none

git diff > clang_format.patch

#Delete if 0 size
if [ ! -s clang_format.patch ]
then
	rm clang_format.patch
fi

include("/mnt/d/code/EA/Cmake/libc-skeleton/cmake/CPM.cmake")
CPMAddPackage("NAME;openlibm;GITHUB_REPOSITORY;JuliaMath/openlibm;VERSION;0.7.0;DOWNLOAD_ONLY")
set(openlibm_FOUND TRUE)
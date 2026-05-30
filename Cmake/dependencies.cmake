include_guard(GLOBAL)

#prefer using pgk-config packaged dependencies
find_package(PkgConfig GLOBAL REQUIRED)

find_package(protobuf CONFIG GLOBAL REQUIRED ) #protobuf pkg-config package on fedora is missing a header (runtime_version.h), so cmake config mode is required
#pkg_check_modules(protobuf GLOBAL REQUIRED IMPORTED_TARGET protobuf)

pkg_check_modules(tbb GLOBAL REQUIRED IMPORTED_TARGET tbb)
pkg_check_modules(tbbmalloc GLOBAL REQUIRED IMPORTED_TARGET tbbmalloc)
pkg_check_modules(mediainfo GLOBAL REQUIRED IMPORTED_TARGET libmediainfo)
pkg_check_modules(ittnotify GLOBAL IMPORTED_TARGET ittnotify)

if(ENABLE_TESTS)
    #find_package(PkgConfig REQUIRED)
    pkg_check_modules(GTEST GLOBAL REQUIRED IMPORTED_TARGET gtest gtest_main)
endif()
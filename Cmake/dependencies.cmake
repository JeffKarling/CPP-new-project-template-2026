include_guard(GLOBAL)

#prefer using pgk-config packaged dependencies
find_package(PkgConfig GLOBAL REQUIRED)

find_package(protobuf CONFIG GLOBAL REQUIRED ) #protobuf pkg-config package on fedora is missing a header (runtime_version.h), so cmake config mode is required
#pkg_check_modules(protobuf GLOBAL REQUIRED IMPORTED_TARGET protobuf)

pkg_check_modules(tbb GLOBAL REQUIRED IMPORTED_TARGET tbb)
if(TARGET PkgConfig::tbb)
    target_compile_definitions(PkgConfig::tbb INTERFACE
        $<$<CONFIG:OneApi_RelWithDebInfo>:TBB_USE_PROFILING_TOOLS=1>
    )
endif()

if(ENABLE_ITT)
    pkg_check_modules(ittnotify GLOBAL IMPORTED_TARGET ittnotify)
endif()

# Only retrieve testing dependencies if standard BUILD_TESTING is enabled
if(BUILD_TESTING)
    #find_package(PkgConfig REQUIRED)
    pkg_check_modules(GTEST GLOBAL REQUIRED IMPORTED_TARGET gtest gtest_main)
endif()
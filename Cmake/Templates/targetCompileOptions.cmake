target_compile_definitions(${DIR_NAME} PRIVATE
        # oneTBB supports Intel® Inspector, Intel® VTune™ Profiler and Intel® Advisor.
        #Full support of these tools requires compiling with macro TBB_USE_PROFILING_TOOLS=1

        #$<$<PLATFORM_ID:Linux>:>
        #$<$<PLATFORM_ID:Windows>:>

        #Clang definitions
        $<$<CONFIG:Clang_Debug>:
            # Modern libc++ hardening (enables all standard safety checks)
            _LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG
        >
        $<$<CONFIG:Clang_Debug_Deep>:
            # Modern libc++ hardening: EXTENSIVE enables exhaustive, heavier runtime STL assertions
            _LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_EXTENSIVE
        >

        $<$<CONFIG:Clang_Release>:NDEBUG _LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST>
        #https://libcxx.llvm.org/Hardening.html#using-hardening-modes
        #https://blog.quarkslab.com/clang-hardening-cheat-sheet-ten-years-later.html
        #https://queue.acm.org/detail.cfm?id=3773097
        #https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p3191r0.pdf
        $<$<CONFIG:Clang_RelWithDebInfo>:_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_NONE>

        $<$<CONFIG:Clang_tidy>:NDEBUG>

        $<$<CONFIG:Clang_UBSan>:NDEBUG>
        $<$<CONFIG:Clang_MemSan>:NDEBUG>
        $<$<CONFIG:Clang_ThreadSan>:NDEBUG>
        $<$<CONFIG:Clang_AddressSan>:NDEBUG>
        $<$<CONFIG:Clang_LeakSan>:NDEBUG>

        #GNU compiler definitions
        $<$<CONFIG:GNU_Debug>:_GLIBCXX_DEBUG DEBUG_LEVEL=2>
        $<$<CONFIG:GNU_Debug_Deep>:_GLIBCXX_DEBUG _GLIBCXX_DEBUG_PEDANTIC DEBUG_LEVEL=2>
        $<$<CONFIG:GNU_Release>:NDEBUG _GLIBCXX_CONCEPT_CHECKS _GLIBCXX_ASSERTIONS>
        $<$<CONFIG:GNU_RelWithDebInfo>:_GLIBCXX_CONCEPT_CHECKS _GLIBCXX_ASSERTIONS>
        $<$<CONFIG:GNU_UBSan>:NDEBUG>
        $<$<CONFIG:GNU_AddressSan>:NDEBUG>

        #OneApi DPC++ compiler definitions
        $<$<CONFIG:OneApi_Debug>:>
        $<$<CONFIG:OneApi_Release>:NDEBUG>
        $<$<CONFIG:OneApi_RelWithDebInfo>:>
)

target_compile_options(${DIR_NAME} PRIVATE
        #-fstack-protector-strong ?

        #Clang custom builds options
        $<$<CONFIG:Clang_Release>:-march=native -O3 -ffast-math -fstack-protector-strong>
        $<$<CONFIG:Clang_Debug>:-march=native -O1 -ggdb -gdwarf-5 -fno-omit-frame-pointer -fno-optimize-sibling-calls
        -Wall -Wextra -Wpedantic -Wswitch-enum -Wmissing-field-initializers -Wshadow -Wfatal-errors -Werror=return-type -Wconversion -Wformat=2
        -Wexit-time-destructors -Wglobal-constructors -Wpessimizing-move -Wrange-loop-construct -Wpadded-bitfield>
        $<$<CONFIG:Clang_Debug_Deep>:-march=native -O1 -ggdb -gdwarf-5 -fno-omit-frame-pointer -fno-optimize-sibling-calls
        -Wall -Wextra -Wpedantic -Wswitch-enum -Wmissing-field-initializers -Wshadow -Wfatal-errors -Werror=return-type -Wconversion -Wformat=2
        -Wexit-time-destructors -Wglobal-constructors -Wpessimizing-move -Wrange-loop-construct -Wpadded-bitfield>
        $<$<CONFIG:Clang_RelWithDebInfo>:-march=native -O3 -ffast-math -ggdb -gdwarf-5 -gline-tables-only -fdebug-info-for-profiling>

        $<$<CONFIG:Clang_tidy>:-march=native -O2 -g>

        # Sanitizers https://www.intel.com/content/www/us/en/docs/dpcpp-cpp-compiler/developer-guide-reference/2025-2/host-side-compiler-sanitizers.html
        $<$<CONFIG:Clang_UBSan>:-march=native -O2 -ggdb -gdwarf-5 -fsanitize=undefined -fno-sanitize-recover=undefined -fno-omit-frame-pointer -fno-optimize-sibling-calls>
        $<$<CONFIG:Clang_MemSan>:-march=native -O2 -g -fno-omit-frame-pointer -fno-optimize-sibling-calls>
        $<$<CONFIG:Clang_ThreadSan>:-march=native -O2 -g -fno-omit-frame-pointer -fno-optimize-sibling-calls>
        $<$<CONFIG:Clang_AddressSan>:-march=native -O2 -g -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls>
        $<$<CONFIG:Clang_LeakSan>:-march=native -O2 -g -fno-omit-frame-pointer -fno-optimize-sibling-calls>

        #GNU custom builds options
        $<$<CONFIG:GNU_Release>:-march=native -O3 -ffast-math>
        $<$<CONFIG:GNU_Debug>:-march=native -O1 -ggdb -gdwarf-5 -fno-omit-frame-pointer -fno-optimize-sibling-calls
        -Wall -Wextra -Wshadow -Wconversion -Wformat=2 -Wduplicated-cond -Wstringop-overflow -Wformat-security
        -Wfloat-equal -Wlogical-not-parentheses -Wnull-dereference
        -Wpessimizing-move -Wrange-loop-construct>
        $<$<CONFIG:GNU_Debug_Deep>:-march=native -O0 -ggdb -gdwarf-5 -fno-omit-frame-pointer -fno-optimize-sibling-calls
        -Wall -Wextra -Wshadow -Wconversion -Wformat=2 -Wduplicated-cond -Wstringop-overflow -Wformat-security
        -Wfloat-equal -Wlogical-not-parentheses -Wnull-dereference
        -Wpessimizing-move -Wrange-loop-construct>
        $<$<CONFIG:GNU_RelWithDebInfo>:-march=native -O2 -g>
        $<$<CONFIG:GNU_UBSan>:-march=native -O2 -g -fsanitize=undefined -fno-omit-frame-pointer -fno-optimize-sibling-calls>
        $<$<CONFIG:GNU_AddressSan>:-march=native -O2 -g -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls>
        #https://gcc.gnu.org/pipermail/gcc-patches/2021-February/565514.html

        #OneApi DPC++ custom builds options
        $<$<CONFIG:OneApi_Release>:-xhost -O3 -ffast-math>
        $<$<CONFIG:OneApi_Debug>:-xhost -O1 -g -ggdb -sox=inline,profile -Wall -Wextra -Wpedantic -Wswitch-enum -Wmissing-field-initializers -Wshadow -Wfatal-errors -Werror=return-type -Wconversion>
        $<$<CONFIG:OneApi_RelWithDebInfo>:-xhost -O2 -g -fno-omit-frame-pointer -fno-optimize-sibling-calls -sox=inline,profile -fdebug-info-for-profiling -qopt-report=3 -qopt-report-file=${PROJECT_SOURCE_DIR}/production_artifacts/profiling/advisor/compiler_opt_report.txt>
        #https://www.intel.com/content/www/us/en/docs/dpcpp-cpp-compiler/developer-guide-reference/2025-2/sox.html
        #https://www.intel.com/content/www/us/en/developer/articles/technical/compiler-optimization-report-news-2025.html
        #https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2024-1/prepare-application.html
)

target_link_options(${DIR_NAME} PRIVATE
        #GNU compiler link-options
        $<$<CXX_COMPILER_ID:GNU>:>
        $<$<CONFIG:GNU_Debug>:>
        $<$<CONFIG:GNU_Release>:>
        $<$<CONFIG:GNU_RelWithDebInfo>:>

        #Clang compiler link-options
        $<$<CXX_COMPILER_ID:Clang>:>
        $<$<CONFIG:Clang_Debug>:>
        $<$<CONFIG:Clang_Release>:>
        $<$<CONFIG:Clang_RelWithDebInfo>:>

        #OneApi DPC++ link-options
        $<$<CXX_COMPILER_ID:IntelLLVM>:>
        $<$<CONFIG:Clang_Debug>:>
        $<$<CONFIG:Clang_Release>:>
        $<$<CONFIG:Clang_RelWithDebInfo>:>

        #Sanitizers
        $<$<CONFIG:Clang_UBSan>:-fsanitize=undefined -fsanitize-trap=all>
        $<$<CONFIG:Clang_MemSan>:-fsanitize=memory -fsanitize-memory-track-origins=2>
        $<$<CONFIG:Clang_ThreadSan>:-fsanitize=thread -pie >
        $<$<CONFIG:Clang_AddressSan>:-fsanitize=address>
        $<$<CONFIG:Clang_LeakSan>:-fsanitize=leak -fPIE>
        $<$<CONFIG:GNU_UBSan>:-fsanitize=undefined>
        $<$<CONFIG:GNU_AddressSan>:-fsanitize=address>
)

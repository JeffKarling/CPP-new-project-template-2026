include_guard(GLOBAL)

# Linux Perf Tool
find_program(PERF "perf")

if (PERF)
    set(PERF_OUT_DIR "${PROJECT_SOURCE_DIR}/production_artifacts/profiling/perf")
    file(MAKE_DIRECTORY "${PERF_OUT_DIR}")

    # Target 1: Standard Perf Stat (Cache, Branching, and Cycles)
    add_custom_target(Perf
            COMMAND echo "$<TARGET_FILE_NAME:${PROJECT_NAME}>"
            COMMAND "${PERF}" stat
                    -e cache-references,branches,branch-misses,cache-misses,instructions,cpu-cycles
                    $<TARGET_FILE:${PROJECT_NAME}>
            COMMENT "Profiling with perf (Hardware Stats), outputs to console"
            DEPENDS ${PROJECT_NAME}
            WORKING_DIRECTORY "${PERF_OUT_DIR}"
            VERBATIM
    )

    # Target 2: Multithreaded Perf Stat (Task clock, migrations, page faults per thread)
    add_custom_target(Perf_multithread
            COMMAND echo "template2026 Multithreaded Perf"
            COMMAND /bin/sh -c "$<TARGET_FILE:${PROJECT_NAME}> & PID=\$! && sleep 0.05 && ${PERF} stat --per-thread -e task-clock,context-switches,cpu-migrations,page-faults -p \$PID && wait \$PID"
            COMMENT "Profiling with perf stat in per-thread mode to capture concurrency metrics"
            DEPENDS ${PROJECT_NAME}
            WORKING_DIRECTORY "${PERF_OUT_DIR}"
            VERBATIM
    )

    # Target 3: Record performance data (perf.data)
    add_custom_target(Perf_record
            COMMAND ${CMAKE_COMMAND} -E rm -f "${PERF_OUT_DIR}/perf.data"
            COMMAND "${PERF}" record -o "${PERF_OUT_DIR}/perf.data"
                    $<TARGET_FILE:${PROJECT_NAME}>
            COMMENT "Profiling with perf record, saves to production_artifacts/profiling/perf/perf.data"
            DEPENDS ${PROJECT_NAME}
            WORKING_DIRECTORY "${PERF_OUT_DIR}"
            VERBATIM
    )

    # Target 4: Report recorded performance data
    add_custom_target(Perf_report
            COMMAND "${PERF}" report -i "${PERF_OUT_DIR}/perf.data"
            COMMENT "Displaying perf report for production_artifacts/profiling/perf/perf.data"
            DEPENDS ${PROJECT_NAME}
            WORKING_DIRECTORY "${PERF_OUT_DIR}"
            VERBATIM
    )

    message(STATUS "[PROFILING] Linux perf tool found at: ${PERF}")
else ()
    message(STATUS "[PROFILING] Linux perf tool NOT found.")
endif ()

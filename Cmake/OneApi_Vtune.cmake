include_guard(GLOBAL)

find_program(VTUNE "vtune" PATHS 
        "/opt/intel/oneapi/vtune/latest/bin64" 
        "/opt/intel/oneapi/vtune/2025.8/bin64" 
        "/opt/intel/oneapi/vtune/2025.4/bin64"
)

find_program(VTUNE_BACKEND "vtune-backend" PATHS 
        "/opt/intel/oneapi/vtune/latest/bin64" 
        "/opt/intel/oneapi/vtune/2025.8/bin64" 
        "/opt/intel/oneapi/vtune/2025.4/bin64"
)

if (VTUNE)
    set(VTUNE_OUT_DIR "${PROJECT_SOURCE_DIR}/production_artifacts/profiling/vtune")

    # Resolve symlinks to absolute physical paths to guarantee source mappings
    get_filename_component(PROJECT_SOURCE_DIR_REAL "${PROJECT_SOURCE_DIR}" REALPATH)
    get_filename_component(CMAKE_BINARY_DIR_REAL "${CMAKE_BINARY_DIR}" REALPATH)

    add_custom_target(Vtune_collect
            COMMAND ${CMAKE_COMMAND} -E rm -rf "${VTUNE_OUT_DIR}"
            COMMAND "${VTUNE}" -collect threading -start-paused -data-limit=500 -result-dir "${VTUNE_OUT_DIR}" 
                    -search-dir "${PROJECT_SOURCE_DIR}" 
                    -search-dir "${PROJECT_SOURCE_DIR_REAL}" 
                    -search-dir "${CMAKE_BINARY_DIR}" 
                    -search-dir "${CMAKE_BINARY_DIR_REAL}" 
                    -- $<TARGET_FILE:${PROJECT_NAME}>
            COMMENT "Profiling with VTune (Threading Analysis - JIT), saving to production_artifacts/profiling/vtune"
            DEPENDS ${PROJECT_NAME}
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
            VERBATIM
    )
    
    add_custom_target(Vtune_gui
            COMMAND bash -c "systemctl --user stop vtune-web.service 2>/dev/null || true; systemd-run --user --unit=vtune-web --property=Restart=always --property=RestartSec=5 \"${VTUNE_BACKEND}\" --web-port=8082 --enable-server-profiling --allow-remote-access --data-directory=\"${PROJECT_SOURCE_DIR}/production_artifacts/profiling/\""
            COMMENT "Starting dynamic Intel VTune Web Server background service (vtune-web.service) on https://localhost:8082/ ..."
            VERBATIM
    )

    message(STATUS "[PROFILING] VTune profiler found at: ${VTUNE} (Backend: ${VTUNE_BACKEND})")
else()
    message(STATUS "[PROFILING] VTune profiler NOT found.")
endif ()

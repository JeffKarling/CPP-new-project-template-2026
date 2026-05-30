include_guard(GLOBAL)

find_program(ADVISOR "advisor" PATHS 
        "/opt/intel/oneapi/advisor/latest/bin64" 
        "/opt/intel/oneapi/advisor/2025.4/bin64"
)

find_program(ADVISOR_GUI "advisor-gui" PATHS 
        "/opt/intel/oneapi/advisor/latest/bin64" 
        "/opt/intel/oneapi/advisor/2025.4/bin64"
)

if (ADVISOR)
    set(ADVISOR_OUT_DIR "${PROJECT_SOURCE_DIR}/production_artifacts/profiling/advisor")
    file(MAKE_DIRECTORY "${ADVISOR_OUT_DIR}")

    # Resolve symlinks to absolute physical paths to guarantee source mappings
    get_filename_component(PROJECT_SOURCE_DIR_REAL "${PROJECT_SOURCE_DIR}" REALPATH)
    get_filename_component(CMAKE_BINARY_DIR_REAL "${CMAKE_BINARY_DIR}" REALPATH)

    add_custom_target(Advisor_collect
            COMMAND ${CMAKE_COMMAND} -E rm -rf "${ADVISOR_OUT_DIR}/e000" "${ADVISOR_OUT_DIR}/advisor.advixeproj" "${ADVISOR_OUT_DIR}/annotations.advidb2" "${ADVISOR_OUT_DIR}/project_read_only.dflgadvixe" "${ADVISOR_OUT_DIR}/project_read_only.infoadvixe"
            # Step 1: Run Survey Analysis (required baseline)
            COMMAND "${ADVISOR}" -collect survey -project-dir "${ADVISOR_OUT_DIR}" 
                    -search-dir src:r="${PROJECT_SOURCE_DIR}" 
                    -search-dir src:r="${PROJECT_SOURCE_DIR_REAL}" 
                    -search-dir bin:r="${CMAKE_BINARY_DIR}" 
                    -search-dir bin:r="${CMAKE_BINARY_DIR_REAL}" 
                    -- $<TARGET_FILE:${PROJECT_NAME}>
            # Step 2: Run Tripcounts & FLOPs Analysis (combines with survey to generate the Roofline Model)
            COMMAND "${ADVISOR}" -collect tripcounts -flop -project-dir "${ADVISOR_OUT_DIR}" 
                    -search-dir src:r="${PROJECT_SOURCE_DIR}" 
                    -search-dir src:r="${PROJECT_SOURCE_DIR_REAL}" 
                    -search-dir bin:r="${CMAKE_BINARY_DIR}" 
                    -search-dir bin:r="${CMAKE_BINARY_DIR_REAL}" 
                    -- $<TARGET_FILE:${PROJECT_NAME}>
            COMMENT "Profiling with Advisor (Roofline Survey + Tripcounts), saving to production_artifacts/profiling/advisor"
            DEPENDS ${PROJECT_NAME}
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
            VERBATIM
    )

    if (ADVISOR_GUI)
        add_custom_target(Advisor_gui
                COMMAND ${CMAKE_COMMAND} -E env GDK_BACKEND=x11 GTK_PATH="" "${ADVISOR_GUI}" "${ADVISOR_OUT_DIR}"
                COMMENT "Opening Intel Advisor GUI with recorded data..."
                WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                VERBATIM
        )
    endif ()

    message(STATUS "[PROFILING] Intel Advisor found at: ${ADVISOR} (GUI: ${ADVISOR_GUI})")
else()
    message(STATUS "[PROFILING] Intel Advisor NOT found.")
endif ()

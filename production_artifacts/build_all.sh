#!/usr/bin/env bash
set -e

# build_all.sh - Unified multi-compiler build and test verification runner
# Usage: ./build_all.sh [custom | default] [release | debug | deep]

TYPE="custom"
MODE="release"

# Parse arguments
if [ "$#" -eq 1 ]; then
    arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    if [ "$arg" = "release" ] || [ "$arg" = "debug" ] || [ "$arg" = "deep" ] || [ "$arg" = "debug_deep" ]; then
        MODE="$arg"
    elif [ "$arg" = "custom" ] || [ "$arg" = "default" ]; then
        TYPE="$arg"
    fi
elif [ "$#" -eq 2 ]; then
    TYPE=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    MODE=$(echo "$2" | tr '[:upper:]' '[:lower:]')
fi

# Capitalize for preset names
if [ "$TYPE" = "custom" ]; then
    P_TYPE="Custom"
else
    P_TYPE="Default"
fi

if [ "$MODE" = "debug" ]; then
    P_MODE="Debug"
elif [ "$MODE" = "deep" ] || [ "$MODE" = "debug_deep" ]; then
    P_MODE="Debug_Deep"
else
    P_MODE="Release"
fi

# Helper function to run a workflow preset
run_workflow() {
    local preset=$1
    local ignore_errors=${2:-false}
    
    echo -e "\n-------------------------------------------------------------"
    echo "⚙️  Executing Workflow: $preset"
    echo "-------------------------------------------------------------"
    
    if cmake --workflow --preset "$preset"; then
        echo -e "✅ [SUCCESS] Workflow $preset completed successfully."
        return 0
    else
        if [ "$ignore_errors" = "true" ]; then
            echo -e "\n⚠️  [WARNING] Workflow $preset failed, ignoring as expected."
            return 0
        else
            echo -e "\n❌ [ERROR] Workflow $preset failed."
            return 1
        fi
    fi
}

echo "================================================================="
echo "  🚀 Starting Verification ($P_TYPE - $P_MODE): GNU -> oneAPI -> Clang"
echo "================================================================="

# 1. Run GNU Verification Workflow
run_workflow "GNU_${P_TYPE}_${P_MODE}_Verify" false

# 2. Run oneAPI Verification Workflow (Skip for Deep Debug since it is only implemented for GNU and Clang)
if [ "$P_MODE" != "Debug_Deep" ]; then
    run_workflow "OneApi_${P_TYPE}_${P_MODE}_Verify" false
else
    echo -e "\n⚠️  [INFO] Skipping oneAPI Verification Workflow (not defined for Deep Debug)."
fi

# 3. Run Clang Verification Workflow (Gracefully handle ABI link failure in Clang)
run_workflow "Clang_${P_TYPE}_${P_MODE}_Verify" true

echo -e "\n================================================================="
echo "  ✅ All Compiler Verification Workflows Processed Successfully! "
echo "================================================================="

#!/bin/bash
set -e

# Path to the original files
GEN_DIR="gen/sv/alpha/typist"
TEST_DIR="tests/sv"
BUILD_TMP="build_tmp"
OBJ_DIR="obj_dir"

mkdir -p $BUILD_TMP

echo "Preparing temporary files for Verilator..."
# Copy original files to BUILD_TMP
cp $GEN_DIR/constants_pkg.sv $BUILD_TMP/
cp $GEN_DIR/constants_test_pkg.sv $BUILD_TMP/

echo "Compiling and running with Verilator..."

verilator --binary -j 0 \
    -Wall \
    -Wno-fatal \
    --trace \
    --top-module constants_test_pkg_tb \
    $BUILD_TMP/constants_pkg.sv \
    $BUILD_TMP/constants_test_pkg.sv \
    $TEST_DIR/constants_test_pkg_tb.sv

# Run the simulation
./$OBJ_DIR/Vconstants_test_pkg_tb

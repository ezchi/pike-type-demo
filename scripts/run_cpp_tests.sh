#!/bin/bash
set -e

BUILD_DIR="build_cpp"
mkdir -p $BUILD_DIR

echo "Compiling C++ tests..."
g++ -std=c++20 -I. tests/cpp/constants_types_test.cpp -o $BUILD_DIR/constants_types_test

echo "Running C++ tests..."
./$BUILD_DIR/constants_types_test

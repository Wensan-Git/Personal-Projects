# CMake generated Testfile for 
# Source directory: /Users/yinjiacheng/Desktop/College/CS211/hw06
# Build directory: /Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(Test_model_test "model_test")
set_tests_properties(Test_model_test PROPERTIES  _BACKTRACE_TRIPLES "/Users/yinjiacheng/Desktop/College/CS211/hw06/.cs211/cmake/211commands.cmake;90;add_test;/Users/yinjiacheng/Desktop/College/CS211/hw06/CMakeLists.txt;25;add_test_program;/Users/yinjiacheng/Desktop/College/CS211/hw06/CMakeLists.txt;0;")
add_test(Test_helper_test "helper_test")
set_tests_properties(Test_helper_test PROPERTIES  _BACKTRACE_TRIPLES "/Users/yinjiacheng/Desktop/College/CS211/hw06/.cs211/cmake/211commands.cmake;90;add_test;/Users/yinjiacheng/Desktop/College/CS211/hw06/CMakeLists.txt;32;add_test_program;/Users/yinjiacheng/Desktop/College/CS211/hw06/CMakeLists.txt;0;")
subdirs(".cs211/lib/catch")
subdirs(".cs211/lib/ge211")

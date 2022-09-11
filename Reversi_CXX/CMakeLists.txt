cmake_minimum_required(VERSION 3.3)
project(reversi CXX)
include(.cs211/cmake/CMakeLists.txt)

# Defines a variable to stand for the .cxx files that implement
# the model.
set(MODEL_SRC
        src/player.cxx
        src/position_set.cxx
        src/move.cxx
        src/board.cxx
        src/model.cxx)

# Adds a program named `reversi` built from the listed source
# files and the common model files.
add_program(reversi
        src/reversi.cxx
        src/controller.cxx
        src/view.cxx
        ${MODEL_SRC})
target_link_libraries(reversi ge211)

# Adds a test program named `model_test` built from the listed
# source file and the common model files.
add_test_program(model_test
        test/model_test.cxx
        ${MODEL_SRC})
target_link_libraries(model_test ge211)

# Adds a test program named `helper_test` for testing the helper
# classes.
add_test_program(helper_test
        test/player_test.cxx
        test/position_set_test.cxx
        test/move_test.cxx
        test/board_test.cxx
        ${MODEL_SRC})
target_link_libraries(helper_test ge211)

# vim: ft=cmake

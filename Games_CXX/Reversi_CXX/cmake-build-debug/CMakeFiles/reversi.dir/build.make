# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.22

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /Applications/CLion.app/Contents/bin/cmake/mac/bin/cmake

# The command to remove a file.
RM = /Applications/CLion.app/Contents/bin/cmake/mac/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/yinjiacheng/Desktop/College/CS211/hw06

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug

# Include any dependencies generated for this target.
include CMakeFiles/reversi.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/reversi.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/reversi.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/reversi.dir/flags.make

CMakeFiles/reversi.dir/src/reversi.cxx.o: CMakeFiles/reversi.dir/flags.make
CMakeFiles/reversi.dir/src/reversi.cxx.o: ../src/reversi.cxx
CMakeFiles/reversi.dir/src/reversi.cxx.o: CMakeFiles/reversi.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/reversi.dir/src/reversi.cxx.o"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/reversi.dir/src/reversi.cxx.o -MF CMakeFiles/reversi.dir/src/reversi.cxx.o.d -o CMakeFiles/reversi.dir/src/reversi.cxx.o -c /Users/yinjiacheng/Desktop/College/CS211/hw06/src/reversi.cxx

CMakeFiles/reversi.dir/src/reversi.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/reversi.dir/src/reversi.cxx.i"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/yinjiacheng/Desktop/College/CS211/hw06/src/reversi.cxx > CMakeFiles/reversi.dir/src/reversi.cxx.i

CMakeFiles/reversi.dir/src/reversi.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/reversi.dir/src/reversi.cxx.s"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/yinjiacheng/Desktop/College/CS211/hw06/src/reversi.cxx -o CMakeFiles/reversi.dir/src/reversi.cxx.s

CMakeFiles/reversi.dir/src/controller.cxx.o: CMakeFiles/reversi.dir/flags.make
CMakeFiles/reversi.dir/src/controller.cxx.o: ../src/controller.cxx
CMakeFiles/reversi.dir/src/controller.cxx.o: CMakeFiles/reversi.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object CMakeFiles/reversi.dir/src/controller.cxx.o"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/reversi.dir/src/controller.cxx.o -MF CMakeFiles/reversi.dir/src/controller.cxx.o.d -o CMakeFiles/reversi.dir/src/controller.cxx.o -c /Users/yinjiacheng/Desktop/College/CS211/hw06/src/controller.cxx

CMakeFiles/reversi.dir/src/controller.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/reversi.dir/src/controller.cxx.i"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/yinjiacheng/Desktop/College/CS211/hw06/src/controller.cxx > CMakeFiles/reversi.dir/src/controller.cxx.i

CMakeFiles/reversi.dir/src/controller.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/reversi.dir/src/controller.cxx.s"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/yinjiacheng/Desktop/College/CS211/hw06/src/controller.cxx -o CMakeFiles/reversi.dir/src/controller.cxx.s

CMakeFiles/reversi.dir/src/view.cxx.o: CMakeFiles/reversi.dir/flags.make
CMakeFiles/reversi.dir/src/view.cxx.o: ../src/view.cxx
CMakeFiles/reversi.dir/src/view.cxx.o: CMakeFiles/reversi.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Building CXX object CMakeFiles/reversi.dir/src/view.cxx.o"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/reversi.dir/src/view.cxx.o -MF CMakeFiles/reversi.dir/src/view.cxx.o.d -o CMakeFiles/reversi.dir/src/view.cxx.o -c /Users/yinjiacheng/Desktop/College/CS211/hw06/src/view.cxx

CMakeFiles/reversi.dir/src/view.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/reversi.dir/src/view.cxx.i"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/yinjiacheng/Desktop/College/CS211/hw06/src/view.cxx > CMakeFiles/reversi.dir/src/view.cxx.i

CMakeFiles/reversi.dir/src/view.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/reversi.dir/src/view.cxx.s"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/yinjiacheng/Desktop/College/CS211/hw06/src/view.cxx -o CMakeFiles/reversi.dir/src/view.cxx.s

CMakeFiles/reversi.dir/src/player.cxx.o: CMakeFiles/reversi.dir/flags.make
CMakeFiles/reversi.dir/src/player.cxx.o: ../src/player.cxx
CMakeFiles/reversi.dir/src/player.cxx.o: CMakeFiles/reversi.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Building CXX object CMakeFiles/reversi.dir/src/player.cxx.o"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/reversi.dir/src/player.cxx.o -MF CMakeFiles/reversi.dir/src/player.cxx.o.d -o CMakeFiles/reversi.dir/src/player.cxx.o -c /Users/yinjiacheng/Desktop/College/CS211/hw06/src/player.cxx

CMakeFiles/reversi.dir/src/player.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/reversi.dir/src/player.cxx.i"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/yinjiacheng/Desktop/College/CS211/hw06/src/player.cxx > CMakeFiles/reversi.dir/src/player.cxx.i

CMakeFiles/reversi.dir/src/player.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/reversi.dir/src/player.cxx.s"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/yinjiacheng/Desktop/College/CS211/hw06/src/player.cxx -o CMakeFiles/reversi.dir/src/player.cxx.s

CMakeFiles/reversi.dir/src/position_set.cxx.o: CMakeFiles/reversi.dir/flags.make
CMakeFiles/reversi.dir/src/position_set.cxx.o: ../src/position_set.cxx
CMakeFiles/reversi.dir/src/position_set.cxx.o: CMakeFiles/reversi.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_5) "Building CXX object CMakeFiles/reversi.dir/src/position_set.cxx.o"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/reversi.dir/src/position_set.cxx.o -MF CMakeFiles/reversi.dir/src/position_set.cxx.o.d -o CMakeFiles/reversi.dir/src/position_set.cxx.o -c /Users/yinjiacheng/Desktop/College/CS211/hw06/src/position_set.cxx

CMakeFiles/reversi.dir/src/position_set.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/reversi.dir/src/position_set.cxx.i"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/yinjiacheng/Desktop/College/CS211/hw06/src/position_set.cxx > CMakeFiles/reversi.dir/src/position_set.cxx.i

CMakeFiles/reversi.dir/src/position_set.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/reversi.dir/src/position_set.cxx.s"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/yinjiacheng/Desktop/College/CS211/hw06/src/position_set.cxx -o CMakeFiles/reversi.dir/src/position_set.cxx.s

CMakeFiles/reversi.dir/src/move.cxx.o: CMakeFiles/reversi.dir/flags.make
CMakeFiles/reversi.dir/src/move.cxx.o: ../src/move.cxx
CMakeFiles/reversi.dir/src/move.cxx.o: CMakeFiles/reversi.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_6) "Building CXX object CMakeFiles/reversi.dir/src/move.cxx.o"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/reversi.dir/src/move.cxx.o -MF CMakeFiles/reversi.dir/src/move.cxx.o.d -o CMakeFiles/reversi.dir/src/move.cxx.o -c /Users/yinjiacheng/Desktop/College/CS211/hw06/src/move.cxx

CMakeFiles/reversi.dir/src/move.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/reversi.dir/src/move.cxx.i"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/yinjiacheng/Desktop/College/CS211/hw06/src/move.cxx > CMakeFiles/reversi.dir/src/move.cxx.i

CMakeFiles/reversi.dir/src/move.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/reversi.dir/src/move.cxx.s"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/yinjiacheng/Desktop/College/CS211/hw06/src/move.cxx -o CMakeFiles/reversi.dir/src/move.cxx.s

CMakeFiles/reversi.dir/src/board.cxx.o: CMakeFiles/reversi.dir/flags.make
CMakeFiles/reversi.dir/src/board.cxx.o: ../src/board.cxx
CMakeFiles/reversi.dir/src/board.cxx.o: CMakeFiles/reversi.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_7) "Building CXX object CMakeFiles/reversi.dir/src/board.cxx.o"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/reversi.dir/src/board.cxx.o -MF CMakeFiles/reversi.dir/src/board.cxx.o.d -o CMakeFiles/reversi.dir/src/board.cxx.o -c /Users/yinjiacheng/Desktop/College/CS211/hw06/src/board.cxx

CMakeFiles/reversi.dir/src/board.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/reversi.dir/src/board.cxx.i"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/yinjiacheng/Desktop/College/CS211/hw06/src/board.cxx > CMakeFiles/reversi.dir/src/board.cxx.i

CMakeFiles/reversi.dir/src/board.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/reversi.dir/src/board.cxx.s"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/yinjiacheng/Desktop/College/CS211/hw06/src/board.cxx -o CMakeFiles/reversi.dir/src/board.cxx.s

CMakeFiles/reversi.dir/src/model.cxx.o: CMakeFiles/reversi.dir/flags.make
CMakeFiles/reversi.dir/src/model.cxx.o: ../src/model.cxx
CMakeFiles/reversi.dir/src/model.cxx.o: CMakeFiles/reversi.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_8) "Building CXX object CMakeFiles/reversi.dir/src/model.cxx.o"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/reversi.dir/src/model.cxx.o -MF CMakeFiles/reversi.dir/src/model.cxx.o.d -o CMakeFiles/reversi.dir/src/model.cxx.o -c /Users/yinjiacheng/Desktop/College/CS211/hw06/src/model.cxx

CMakeFiles/reversi.dir/src/model.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/reversi.dir/src/model.cxx.i"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/yinjiacheng/Desktop/College/CS211/hw06/src/model.cxx > CMakeFiles/reversi.dir/src/model.cxx.i

CMakeFiles/reversi.dir/src/model.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/reversi.dir/src/model.cxx.s"
	/Library/Developer/CommandLineTools/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/yinjiacheng/Desktop/College/CS211/hw06/src/model.cxx -o CMakeFiles/reversi.dir/src/model.cxx.s

# Object files for target reversi
reversi_OBJECTS = \
"CMakeFiles/reversi.dir/src/reversi.cxx.o" \
"CMakeFiles/reversi.dir/src/controller.cxx.o" \
"CMakeFiles/reversi.dir/src/view.cxx.o" \
"CMakeFiles/reversi.dir/src/player.cxx.o" \
"CMakeFiles/reversi.dir/src/position_set.cxx.o" \
"CMakeFiles/reversi.dir/src/move.cxx.o" \
"CMakeFiles/reversi.dir/src/board.cxx.o" \
"CMakeFiles/reversi.dir/src/model.cxx.o"

# External object files for target reversi
reversi_EXTERNAL_OBJECTS =

reversi: CMakeFiles/reversi.dir/src/reversi.cxx.o
reversi: CMakeFiles/reversi.dir/src/controller.cxx.o
reversi: CMakeFiles/reversi.dir/src/view.cxx.o
reversi: CMakeFiles/reversi.dir/src/player.cxx.o
reversi: CMakeFiles/reversi.dir/src/position_set.cxx.o
reversi: CMakeFiles/reversi.dir/src/move.cxx.o
reversi: CMakeFiles/reversi.dir/src/board.cxx.o
reversi: CMakeFiles/reversi.dir/src/model.cxx.o
reversi: CMakeFiles/reversi.dir/build.make
reversi: .cs211/lib/ge211/src/libge211.a
reversi: /usr/local/lib/libSDL2.dylib
reversi: /usr/local/lib/libSDL2_image.dylib
reversi: /usr/local/lib/libSDL2_mixer.dylib
reversi: /usr/local/lib/libSDL2_ttf.dylib
reversi: CMakeFiles/reversi.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_9) "Linking CXX executable reversi"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/reversi.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/reversi.dir/build: reversi
.PHONY : CMakeFiles/reversi.dir/build

CMakeFiles/reversi.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/reversi.dir/cmake_clean.cmake
.PHONY : CMakeFiles/reversi.dir/clean

CMakeFiles/reversi.dir/depend:
	cd /Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/yinjiacheng/Desktop/College/CS211/hw06 /Users/yinjiacheng/Desktop/College/CS211/hw06 /Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug /Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug /Users/yinjiacheng/Desktop/College/CS211/hw06/cmake-build-debug/CMakeFiles/reversi.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/reversi.dir/depend


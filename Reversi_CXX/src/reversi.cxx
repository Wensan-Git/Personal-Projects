#include "controller.hxx"

#include <stdexcept>
#include <string>


int
main(int argc, char *argv[]) {

    try {
        ///
        /// Don't change this command-line processing, as the grader
        /// will expect to be able to start your program this way.
        ///
        int width;
        int height;
        switch (argc) {
            case 1:
                width = 8;
                height = 8;
                break;
            case 3:
                width = std::stoi(argv[1]);
                height = std::stoi(argv[2]);
                break;
            default:
                std::cerr << "Usage: " << argv[0] << " [WIDTH HEIGHT]\n";
                return 1;
        }

        // You can change how you start your game class if you want
        // (but you probably don't need to):
        Controller(width, height).run();

    } catch (std::exception const& e) {
        // This prints out error messages if, say, the command-line argument
        // cannot be parsed as `int`s.
        std::cerr << argv[0] << ": " << e.what() << "\n";
        return 1;
    }

    return 0;
}

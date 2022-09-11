#include "board.hxx"
#include <catch.hxx>
#include <sstream>

using namespace ge211;

TEST_CASE("board operations")
{
    Board b({8, 8});

    b[{2, 1}] = Player::light;

    CHECK(b[{1, 1}] == Player::neither);
    CHECK(b[{2, 1}] == Player::light);
    CHECK(b[{3, 1}] == Player::neither);

    b[{3, 1}] = Player::dark;
    CHECK(b[{1, 1}] == Player::neither);
    CHECK(b[{2, 1}] == Player::light);
    CHECK(b[{3, 1}] == Player::dark);

    b[{1, 1}] = Player::light;
    CHECK(b[{1, 1}] == Player::light);
    CHECK(b[{2, 1}] == Player::light);
    CHECK(b[{3, 1}] == Player::dark);

    CHECK(b.count_player(Player::light) == 2);
    CHECK(b.count_player(Player::dark) == 1);

    b[{0, 1}] = Player::dark;
    b[{1, 1}] = Player::dark;
    b[{2, 1}] = Player::dark;
    CHECK(b[{0, 1}] == Player::dark);
    CHECK(b[{1, 1}] == Player::dark);
    CHECK(b[{2, 1}] == Player::dark);
    CHECK(b[{3, 1}] == Player::dark);

    CHECK(b.count_player(Player::light) == 0);
    CHECK(b.count_player(Player::dark) == 4);

    Board b1(b);

    CHECK(b == b);
    CHECK(b1 == b);
    b1[{3, 4}] = Player::light;
    CHECK(b1 != b);
    b[{3, 4}] = Player::light;
    CHECK(b1 == b);
}

TEST_CASE("board mass operations")
{
    Board b({6, 6});

    CHECK(b.count_player(Player::light) == 0);
    CHECK(b.count_player(Player::dark) == 0);
    CHECK(b.count_player(Player::neither) == 36);

    b.set_all({{1, 1},
               {2, 2},
               {3, 3},
               {4, 4}}, Player::dark);
    CHECK(b.count_player(Player::light) == 0);
    CHECK(b.count_player(Player::dark) == 4);
    CHECK(b.count_player(Player::neither) == 32);

    b.set_all({{2, 0},
               {2, 1},
               {2, 2},
               {2, 4}}, Player::light);
    CHECK(b.count_player(Player::light) == 4);
    CHECK(b.count_player(Player::dark) == 3);
    CHECK(b.count_player(Player::neither) == 29);
}

TEST_CASE("board errors")
{
    Board b({4, 4});

    CHECK(b[{0, 0}] == Player::neither);
    CHECK(b[{3, 3}] == Player::neither);

    CHECK_THROWS_AS((b[{3, 4}]), Client_logic_error);
    CHECK_THROWS_AS((b[{4, 3}]), Client_logic_error);
    CHECK_THROWS_AS((b[{4, 4}]), Client_logic_error);
    CHECK_THROWS_AS((b[{-1, 2}]), Client_logic_error);

    CHECK_THROWS_AS(Board({1, 3}), Client_logic_error);
    CHECK_THROWS_AS(Board({-1, 3}), Client_logic_error);
}

TEST_CASE("board stream insertion")
{
    Board b({4, 4});
    b[{1, 1}] = Player::light;
    b[{2, 2}] = Player::light;
    b[{2, 1}] = Player::dark;
    b[{1, 2}] = Player::dark;

    std::ostringstream oss;
    oss << b;
    CHECK(oss.str() == "____\n"
                       "_LD_\n"
                       "_DL_\n"
                       "____\n");
}

#include "player.hxx"
#include <catch.hxx>
#include <sstream>

TEST_CASE("players equal themselves and not each other")
{
    CHECK(Player::light == Player::light);
    CHECK(Player::dark == Player::dark);
    CHECK(Player::neither == Player::neither);
    CHECK(Player::light != Player::dark);
    CHECK(Player::light != Player::neither);
    CHECK(Player::dark != Player::light);
    CHECK(Player::dark != Player::neither);
    CHECK(Player::neither != Player::light);
    CHECK(Player::neither != Player::dark);
}

TEST_CASE("other_player works")
{
    CHECK(other_player(Player::light) == Player::dark);
    CHECK(other_player(Player::dark) == Player::light);
}

TEST_CASE("stream insertion")
{
    std::ostringstream oss;
    oss << Player::light;
    CHECK(oss.str() == "L");
    oss << Player::neither;
    CHECK(oss.str() == "L_");
    oss << Player::dark;
    CHECK(oss.str() == "L_D");
}

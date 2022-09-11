#include "move.hxx"

#include <catch.hxx>

#include <sstream>

using namespace ge211;

TEST_CASE("moves are equal up to permutation")
{
    Move m1 {
        {2, 3},
        {{2, 3}, {2, 4}, {2, 5}, {2, 6}}
    };
    Move m2 {
        {2, 3},
        {{2, 4}, {2, 5}, {2, 6}, {2, 3}}
    };
    Move m3 {
        {2, 3},
        {{2, 4}, {2, 5}, {2, 6}, {2, 7}}
    };

    CHECK(m1 == m1);
    CHECK(m1 == m2);
    CHECK(m2 == m1);
    CHECK(m2 == m2);
    CHECK(m3 == m3);

    CHECK(m1 != m3);
    CHECK(m2 != m3);
    CHECK(m3 != m1);
    CHECK(m3 != m2);
}

TEST_CASE("move stream insertion")
{
    std::ostringstream oss;

    Move m1 {
        {2, 3},
        {}
    };
    Move m2 {
        {2, 6},
        {{2, 4}, {2, 5}, {2, 6}}
    };

    oss << m1;
    CHECK(oss.str() == "Move{{2, 3}, {}}");

    oss.str("");
    oss << m2;
    CHECK(oss.str() == "Move{{2, 6}, {{2, 4}, {2, 5}, {2, 6}}}");
}

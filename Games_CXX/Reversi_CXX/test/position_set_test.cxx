#include "position_set.hxx"

#include <catch.hxx>

#include <vector>

using namespace ge211;

// The coordinate limit for position sets.
static int const coord_limit = Position_set::coord_limit;

TEST_CASE("Position_set constructors")
{
    Position_set set1;
    CHECK(set1.empty());
    CHECK(set1.size() == 0);

    Position_set
            set2
            {{2, 3},
             {3, 2}};
    CHECK(!set2.empty());
    CHECK(set2.size() == 2);

    std::vector<ge211::Posn<int>>
            v3
            {{2, 3},
             {3, 2},
             {4, 1}};
    Position_set set3(v3.begin(), v3.end());
    CHECK(set3.size() == 3);
}

TEST_CASE("Position_set insert and lookup")
{
    Position_set set;

    CHECK(!set[{3, 4}]);
    CHECK(!set[{3, 5}]);
    CHECK(!set[{3, 6}]);

    set[{3, 4}] = true;

    CHECK(set[{3, 4}]);
    CHECK(!set[{3, 5}]);
    CHECK(!set[{3, 6}]);

    set[{3, 6}] = true;

    CHECK(set[{3, 4}]);
    CHECK(!set[{3, 5}]);
    CHECK(set[{3, 6}]);

    set[{3, 4}] = true;

    CHECK(set[{3, 4}]);
    CHECK(!set[{3, 5}]);
    CHECK(set[{3, 6}]);

    set[{3, 4}] = false;

    CHECK(!set[{3, 4}]);
    CHECK(!set[{3, 5}]);
    CHECK(set[{3, 6}]);
}

TEST_CASE("universe")
{
    // A rectangle containing all possible positions.
    ge211::Rect<int> universe_rect = {0, 0, coord_limit, coord_limit};

    // The set of everything.
    Position_set pset = Position_set::universe();

    // Check that every possible position is in the set.
    for (auto pos : universe_rect) {
        CHECK(pset[pos]);
    }

    // Remove one position from the set.
    ge211::Posn<int> removed = {3, 5};
    pset[removed] = false;

    // Check that every position but the one we removed is in the set.
    for (auto pos : universe_rect) {
        CHECK(pset[pos] == (pos != removed));
    }
}

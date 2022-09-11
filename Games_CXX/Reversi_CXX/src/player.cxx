/*******************************************/
/*** DO NOT CHANGE ANYTHING IN THIS FILE ***/
/*******************************************/

#include "player.hxx"

Player
other_player(Player player)
{
    switch (player) {
    case Player::light:
        return Player::dark;
    case Player::dark:
        return Player::light;
    default:
        return player;
    }
}

std::ostream&
operator<<(std::ostream& os, Player p)
{
    switch (p) {
    case Player::light:
        return os << "L";
    case Player::dark:
        return os << "D";
    default:
        return os << "_";
    }
}


/*******************************************/
/*** DO NOT CHANGE ANYTHING IN THIS FILE ***/
/*******************************************/

#include "move.hxx"

std::ostream&
operator<<(std::ostream& os, Move const& move)
{
    return os
            << "Move{{" << move.first.x << ", " << move.first.y << "}, "
            << move.second << "}";
}

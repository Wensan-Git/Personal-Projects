#include "model.hxx"

using namespace ge211;

Model::Model(int size)
        : Model(size, size)
{ }

Model::Model(int width, int height)
        : board_({width, height})
{
    // TODO: initialize `next_moves_` to `turn_`'s available moves
    compute_next_moves_();
}

Model::Rectangle
Model::board() const
{
    return board_.all_positions();
}

Player
Model::operator[](Position pos) const
{
    return board_[pos];
}

const Move*
Model::find_move(Position pos) const
{
    auto i = next_moves_.find(pos);

    if (i == next_moves_.end()) {
        // Nothing was found, so return NULL (nullptr in C++)
        return nullptr;
    } else {
        // Dereferences the iterator to get the value then returns a pointer
        // to that value. This is safe as the pointer is to a value living
        // within the `next_moves_` structure.
        return &(*i);
    }
}

void
Model::play_move(Position pos)
{
    if (is_game_over()) {
        throw Client_logic_error("Model::play_move: game over");
    }

    const Move* movep = find_move(pos);
    if (movep == nullptr) { // check if there was no such move
        throw Client_logic_error("Model::play_move: no such move");
    }
    really_play_move_(*movep);
    // TODO: actually execute the move, advance the turn, refill
    // `next_moves_`, etc.
}

//
// BELOW ARE HELPER FUNCTIONS
// Our tests will run on the public functions, not the helper functions
// However, you are required to implement the following functions to help the
// public functions
//


Position_set
Model::find_flips_(Position current, Dimensions dir) const
{
    if (!(board_.good_position(current))) {
        return Position_set();
    }
    Position_set set;
    Position next_posn = current + dir;
    while (board_.good_position(next_posn) && turn_ == other_player
            (board_[next_posn])) {
        set[next_posn] = true;
        next_posn = next_posn + dir;
    }
    if (!board_.good_position(next_posn)) {
        return Position_set();
    }
    else if(board_[next_posn] == Player::neither){
        return Position_set();
    }
    else if (board_[next_posn] == turn_) {
        return set;
    } else {
        return Position_set();
    }
}

Position_set
Model::evaluate_position_(Position pos) const
{
    Position_set the_set;
    if (board_[pos] == Player::neither) {
        for (auto direction: board_.all_directions()) {
            the_set |= find_flips_(pos, direction);
        }
    }
    if (!the_set.empty()){
        Position_set x {pos};
        the_set |= x;
        return the_set;
    }
    return the_set;
}

void
Model::compute_next_moves_()
{
    next_moves_.clear();
    //if (next_moves_.empty()) {return;}
    for (Position pos: board_.center_positions()){
        if (board_[pos] == Player::neither){
            next_moves_[pos] = {pos};
        }
    }
    if (!(next_moves_.empty())) {return;}
    for (Position pos: board_.all_positions()) {
        Position_set set = evaluate_position_(pos);
        if (!(set.empty())) {
            next_moves_[pos] = set;
        }
    }
}



bool
Model::advance_turn_()
{
    // TODO: HELPER FUNCTION Wensan should write this
    turn_ = other_player(turn_);
    compute_next_moves_();
    return !next_moves_.empty();
    //return false;
    // ^^^ this is wrong
}

void
Model::set_game_over_()
{
    // TODO: HELPER FUNCTION Wensan should write this
    turn_ = Player::neither;
    size_t dark_num = 0;
    size_t light_num = 0;
    for (auto posn: board_.all_positions()){
        if (board_[posn] == Player::dark){
            dark_num ++;
        }
        else if (board_[posn] == Player::light){
            light_num ++;
        }
    }
    if (dark_num < light_num) {
        winner_ = Player::light;
    }
    else if (dark_num > light_num) {
        winner_ = Player::dark;
    }
    else{
        winner_ = Player::neither;
    }

}
void
Model::really_play_move_(Move move)
{
    // TODO: HELPER FUNCTION Wensan should write this
    for (ge211::Posn<int> pos : move.second) {
        board_[pos] = turn_;
    }
    bool first = advance_turn_();
    bool second = advance_turn_();
    if ((!first) && (!second)) {
        set_game_over_();
    }
    else if (first){
        advance_turn_();
    }
    else{
       return; //If second one succeeds and first one doesn't, it is the
       // first one's turn again!
    }

}

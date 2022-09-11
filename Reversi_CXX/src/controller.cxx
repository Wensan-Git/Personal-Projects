#include "controller.hxx"

Controller::Controller(int size)
        : Controller(size, size)
{ }

Controller::Controller(int width, int height)
        : model_(width, height),
          view_(model_),
          mouse_posn_(ge211::Posn<int> {0,0})
{ }

void
Controller::draw(ge211::Sprite_set& sprites)
{
    view_.draw(sprites, mouse_posn_);
    //
}
View::Dimensions
Controller::initial_window_dimensions() const
{
    return view_.initial_window_dimensions();
}

std::string
Controller::initial_window_title() const
{
    return view_.initial_window_title();
}

void
Controller::on_mouse_up(ge211::Mouse_button button, ge211::Posn<int> posn)
{
    //1 check for left click:
    ge211::Posn<int> board_posn = view_.screen_to_board(posn);
    if (button == ge211::Mouse_button::left){
        if (!model_.is_game_over()){
            if (model_.find_move(board_posn) != nullptr){
                model_.play_move(board_posn);
            }
        }
    }
    // 2. check if the game is over and check if it is valid to play here

}

void Controller::on_mouse_move(ge211::Posn<int> posn)
{
    //update the mouse_posn
    mouse_posn_ = posn;
}


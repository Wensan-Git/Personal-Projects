#include "view.hxx"

// Convenient type aliases:
using Color = ge211::Color;
using Sprite_set = ge211::Sprite_set;

// You can change this or even determine it some other way:
static int const grid_size = 36;

static int const spacing = 3;
View::View(Model const& model)
        : model_(model),
          blank_sprite_({grid_size-spacing,grid_size-spacing}, {0,255,0}),
          dark_sprite_(grid_size/2-spacing, {0, 0, 0}),
          ph_dark_sprite_(grid_size/5, {0,0,0}),
          light_sprite_(grid_size/2-spacing, {255,255,255}),
          ph_light_sprite_(grid_size/5, {255,255,255}),
          good_move_sprite_({grid_size,grid_size}, {255,0,0}),
          loser_sprite_({grid_size,grid_size}, {200,200,200})
// You may want to add sprite initialization here
{
    //dark_sprite_.recolor(Color::white());
}

void View::draw(Sprite_set& set, Position mouse_pos)
{
    //phase 1
    for (Position all_pos: model_.board()) {
        set.add_sprite(blank_sprite_, board_to_screen(all_pos), 0);
        //add_player_sprite_(set, Player::light, board_to_screen(all_pos), 4);
        //printf("%dx,%dy\n", board_to_screen(all_pos).x, board_to_screen
        //(all_pos).y);
        if (model_[all_pos] == Player::dark) {
            set.add_sprite(dark_sprite_, board_to_screen(all_pos), 4);
        }
        else if (model_[all_pos] == Player::light) {
            set.add_sprite(light_sprite_, board_to_screen(all_pos), 4);
        }
    }

    if (model_.is_game_over()) {
        Player loser;
        if (model_.winner() == Player::dark){
            loser = Player::light;
        }
        else if (model_.winner() == Player::light){
            loser = Player::dark;
        }
        else{
            loser = Player::neither; // In case of a tie, there is no gray tile.
        }
        for (Position all_pos: model_.board()){
            if (model_[all_pos] == loser){
                all_pos = board_to_screen(all_pos);
                add_player_sprite_(set, loser, all_pos,1);
            }
        }
    }

    Position pos = screen_to_board(mouse_pos);
    if (model_.find_move(pos) != nullptr) {
        for (Position red: model_.find_move(pos)->second) {
            red = board_to_screen(red);
            add_player_sprite_(set, model_.turn(), red, 3);
        }
        add_player_sprite_(set, model_.turn(), {mouse_pos.x - grid_size/2,
                                                mouse_pos.y - grid_size/2},
                           4);

    } else if (model_.find_move(pos) == nullptr) {
        add_player_sprite_(set, model_.turn(), {mouse_pos.x - grid_size/5,
                                                mouse_pos.y - grid_size/5}, 2);
    }
}



View::Dimensions
View::initial_window_dimensions() const
{
    // You can change this if you want:
    return grid_size * model_.board().dimensions();
}

std::string
View::initial_window_title() const
{
    // You can change this if you want:
    return "Reversi";
}

View::Position
View::board_to_screen(Model::Position pos) const
{
    return {grid_size * pos.x, grid_size * pos.y};
}

Model::Position
View::screen_to_board(View::Position pos) const
{
    return {pos.x / grid_size, pos.y / grid_size};
}

void
View::add_player_sprite_(
        Sprite_set& set,
        Player player,
        Position pos,
        int z)
{
    if (z == 4) {
        if (player == Player::light) {
            set.add_sprite(light_sprite_, pos, z);
        }
        if (player == Player::dark) {
            set.add_sprite(dark_sprite_, pos, z);
        }
    }
    if (z == 2) {
        if (player == Player::light) {
            set.add_sprite(ph_light_sprite_, pos, z);
        }
        if (player == Player::dark) {
            set.add_sprite(ph_dark_sprite_, pos, z);
        }
    }
    if (z == 1){
        set.add_sprite(loser_sprite_, pos, z);
    }
    if (z == 3){
        set.add_sprite(good_move_sprite_,pos,z);
    }
}
#pragma once

#include "model.hxx"

#include <string>

class View
{
public:
    /// View dimensions will use `int` coordinates.
    using Dimensions = ge211::Dims<int>;

    /// View positions will use `int` coordinates.
    using Position = ge211::Posn<int>;

    /// View rectangles will use `int` coordinates.
    using Rectangle = ge211::Rect<int>;

    /// Constructs a view that knows about the given model.
    explicit View(Model const&);

    // TODO: your code here
    // You will probably want to add arguments here so that the
    // controller can communicate UI state (such as a mouse or
    // cursor position):
    void draw(ge211::Sprite_set& set, Position mouse_pos);

    Dimensions initial_window_dimensions() const;

    std::string initial_window_title() const;

    // Converts an abstract board position to a concrete screen
    // position.
    Position
    board_to_screen(Model::Position board_pos) const;

    // Converts a concrete screen (pixel) position to an abstract board
    // position.
    Model::Position
    screen_to_board(Position screen_pos) const;

    // TODO: Add any public member functions you need.

private:
    Model const& model_;
    ge211::Rectangle_sprite blank_sprite_;
    ge211::Circle_sprite dark_sprite_;
    ge211::Circle_sprite ph_dark_sprite_;
    ge211::Circle_sprite light_sprite_;
    ge211::Circle_sprite ph_light_sprite_;
    ge211::Rectangle_sprite good_move_sprite_;
    ge211::Rectangle_sprite loser_sprite_;


    // TODO: Add any additional private members you need, such as helper
    // functions or sprites.

    void
    add_player_sprite_(ge211::Sprite_set&, Player, Position, int z);
};

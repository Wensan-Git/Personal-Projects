#pragma once

#include <ge211.hxx>
#include <game_config.hxx>

const float block_size = 25;

using Position = ge211::Posn<float>;

using Velocity = ge211::Dims<float>;

using Block = ge211::Rect<int>;


struct Shape{


private:
    std::vector<Position> Posn_set;
    Position pivot = {0,0};
    bool live = true;
    int type;

public:
    Shape(Game_config const& config, int which_type);
    bool hits_right_side(Game_config const&);
    void move_right(Game_config const&);
    bool hits_left_side(Game_config const&);
    void rotate(Game_config const&);

    void move_left(Game_config const&);

    bool hits_bottom_screen(Game_config const&);
    void move_down(Game_config const&);

    bool hits_another_position(std::vector<Position>);

    bool alive(void);
    Shape natural_next(Game_config const& config);
    Shape left_next(Game_config const& config);
    Shape right_next(Game_config const& config);
    std::vector<Position> get_posn_set();
    Position get_pivot() const;
    bool get_live();
    int get_type();
    void set_posn_set(std::vector<Position>);
    void set_pivot(Position);
    void set_live(bool);
    void set_type(int);


};


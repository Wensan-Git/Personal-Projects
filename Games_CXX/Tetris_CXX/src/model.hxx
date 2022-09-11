#pragma once

#include <ge211.hxx>
#include "shape.hxx"
#include <iostream>
#include <vector>

class Model
{
public:
    explicit Model(Game_config const& config = Game_config());

    bool check_game_over(void) const;
    void set_game_over(void);

    void actually_move_right();
    void actually_move_left();
    void actually_rotate();
    void actually_move_down();

    void destroy_row();

    void update_full_row();

    void post_destroy_update(float i);

    void settle();

    void on_frame(double dt);

    void immediate_fall();

    void renew_falling_block();

    int get_score();

    void set_game_paused();

    bool get_game_paused();

    void resume_game();

    //Take care of immediately fall down
    std::vector<Position> get_occupied_posn() const;
    Shape get_falling_block() const;

    Game_config get_config() const;

    Shape falling_block;





private:
    std::vector<Position> Occupied_posn;
    Game_config const config;
    std::vector<bool> full_row;

    bool is_game_over = false;

    int score_ = 0;

    float time_passed = 0;
    bool is_game_paused = false;


};
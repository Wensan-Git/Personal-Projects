#include "model.hxx"
#include <iostream>
#include <vector>
#include <algorithm>


Model::Model(Game_config const& config):
        config(config),
        falling_block(Shape(config,1))
{
    for (int i = 0; i < 20; i++){
        full_row.push_back(false);
    }
    std::vector<Position> Occupied_posn;
}

void
Model::set_game_over()
{
    for(Position& posn : Occupied_posn)
    {
        if (posn.y - block_size/2 <= 9){
            is_game_over = true;
        }
    }
}

void
Model::set_game_paused(){
    is_game_paused = true;
}

bool Model::get_game_paused(){
    return is_game_paused;
}

void
Model::resume_game(){
    is_game_paused = false;
}

bool
Model::check_game_over() const
{
    return is_game_over;
}

void
Model::actually_move_right()
{
    if (!(falling_block.right_next(config).hits_another_position
    (Occupied_posn)))
    {
        falling_block.move_right(config);
    }
}

void
Model::actually_move_left()
{
    if (!(falling_block.left_next(config).hits_another_position(Occupied_posn)))
    {
        falling_block.move_left(config);
    }
}


void
Model::actually_rotate()
{
    Shape new_shape = Shape(config, falling_block.get_type());
    new_shape.set_live(falling_block.get_live());
    new_shape.set_pivot(falling_block.get_pivot());
    new_shape.set_posn_set(falling_block.get_posn_set());
    falling_block.rotate(config);
    if (falling_block.hits_another_position(Occupied_posn)){
        falling_block = new_shape;
    }
}

void
Model::actually_move_down()
{
    if (!(falling_block.natural_next(config).hits_another_position
    (Occupied_posn)))
    {
        falling_block.move_down(config);
        //printf("acutally: %f\n", falling_block.get_pivot().y);
    }
}

int
Model::get_score()
{
    return score_;
}

void
Model::settle(){
    if ((falling_block.natural_next(config).hits_another_position
    (Occupied_posn)) || (falling_block.hits_bottom_screen(config))){
        falling_block.set_live(false);
        for (Position& posn: falling_block.get_posn_set()){
            Occupied_posn.push_back(posn);
        }
    }
}

void
Model::update_full_row()
{
    float a = (1.0/2)*block_size;
    for (float i = a; i < config.scene_dims.height; i += block_size){
        int num = 0;
        float b = (1.0/2)*block_size;
        for (float j = b; j < config.scene_dims.width; j+= block_size){
            for (Position& posn : Occupied_posn){
                if ((j == posn.x)&&(i == posn.y)){
                    num ++;
                }
            }
        }
        if (num == 10){
            full_row[(i-a)/block_size] = true;
        }
    }
}

void
Model::destroy_row()
{

    for (float i = 0; i < 20; i++)
    {
        if (full_row[i] == true)
        {
            full_row[i] = false;
            int max_i = Occupied_posn.size();
            for (int j = 0; j < max_i; j++)
            {
                if (block_size*(i+0.5) == Occupied_posn[j].y){

                    Occupied_posn[j] = Occupied_posn.back();
                    Occupied_posn.pop_back();
                    j--;
                    max_i --;

                }
            }
            score_ ++;
            post_destroy_update(i);
        }
    }
}

void
Model::immediate_fall()
{
    while((!falling_block.natural_next(config).hits_another_position
    (Occupied_posn)) && (!falling_block.hits_bottom_screen(config))){
        falling_block.move_down(config);
    }
}

void
Model::post_destroy_update(float i)
{
    for (Position& posn: Occupied_posn)
    {
        if (block_size*i >= posn.y)
        {
            posn.y += block_size;
        }
    }
    //update_full_row(); // newly added
}


void
Model::on_frame(double dt)
{

    if (is_game_paused){
        return;
    }
    time_passed += 4*dt;

    if (time_passed > 1){
        //printf("%f\n", time_passed);
        time_passed = 0;
        if (!is_game_over){
            actually_move_down(); //move down by one
            settle();   // if natural next hits the bottom screen or another
            // occupied, then merge the block to the occupied set
            update_full_row(); //update the rows status
            destroy_row();  //destroy the full rows and move things down
            if (!(falling_block.get_live())){
                if (falling_block.get_type() != 4){
                    falling_block = Shape(config,falling_block.get_type() + 1);
                }
                else{
                    falling_block = Shape(config,1);
                }
            }
        }
        set_game_over();
    }
}


std::vector<Position>
Model::get_occupied_posn() const{
    return Occupied_posn;
}

Shape
Model::get_falling_block() const{
    //printf("gotten: %f\n", falling_block.get_pivot().y);
    return falling_block;
}

Game_config
Model::get_config() const
{
    return config;
}










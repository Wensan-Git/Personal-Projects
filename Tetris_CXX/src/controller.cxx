#include "controller.hxx"

Controller::Controller(Model& model)
        : view_(View(model)),
          model_(model)
{
    //model_ = model
}

void
Controller::draw(ge211::Sprite_set& set)
{
    if (!model_.check_game_over()){
        for (Position& posn: model_.get_occupied_posn()){
            set.add_sprite(view_.block, {int(posn.x)-(int)((block_size/2)-1),
                                         int(posn.y) -
                                                 (int)((block_size/2)-1)});
        }
        //printf("view: %f\n", model_.falling_block.get_pivot().y);
        for (Position& posn: model_.get_falling_block().get_posn_set()){

            set.add_sprite(view_.block, {int(posn.x)-(int)((block_size/2)-1), int(posn.y) - (int)((block_size/2)-1)});
        }
    }
    else{
        ge211::Text_sprite::Builder letter_builder(sans17);
        letter_builder << "Game Over. Your score: " << model_.get_score();
        letter_sprites.reconfigure(letter_builder);
        set.add_sprite(letter_sprites, {(int)25, (int)250});


    }
    //view_.draw(set);
}

View::Dimensions
Controller::initial_window_dimensions() const
{
    return view_.initial_window_dimensions();

}

void
Controller::on_frame(double dt)
{
    model_.on_frame(dt);
}

void
Controller::on_key(ge211::Key key){
    if (!model_.get_game_paused()){
        if (key == ge211::Key::left()){
            model_.actually_move_left();
        }
        else if (key == ge211::Key::right()){
            model_.actually_move_right();
        }
        else if (key == ge211::Key::up()){
            model_.actually_rotate();
        }
        else if (key == ge211::Key::down()){
            model_.immediate_fall();
        }

    }

    if (key == ge211::Key::code(' ')){
        if (model_.get_game_paused()){
            model_.resume_game();
        }
        else{
            model_.set_game_paused();
        }
    }
}
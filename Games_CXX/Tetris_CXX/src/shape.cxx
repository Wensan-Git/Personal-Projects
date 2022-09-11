#include "shape.hxx"
#include "game_config.hxx"


Shape::Shape(Game_config const& config, int which_type)
{
    type = which_type;
    if (which_type == 1) {
        pivot = {(float)9/2 * block_size, (float)3 / 2 * block_size};
        Posn_set.push_back(pivot);
        Posn_set.push_back({pivot.x-block_size, pivot.y});
        Posn_set.push_back({pivot.x + block_size, pivot.y});
        Posn_set.push_back({pivot.x, pivot.y - block_size});
    }
    if (which_type == 2) {
        pivot = {(float)9/2 * block_size, (float)3 / 2 * block_size};
        Posn_set.push_back(pivot);
        Posn_set.push_back({pivot.x, pivot.y - block_size});
        Posn_set.push_back({pivot.x, pivot.y + block_size});
    }
    if (which_type == 3) {
        pivot = {(float)9/2 * block_size, (float)1 / 2 * block_size};
        Posn_set.push_back(pivot);
    }
    if (which_type == 4) {
        pivot = {(float)9/2 * block_size, (float)1 / 2 * block_size};
        Posn_set.push_back(pivot);
        Posn_set.push_back({pivot.x + block_size, pivot.y});
        Posn_set.push_back({pivot.x, (float)3 / 2 * block_size});
        Posn_set.push_back({pivot.x+block_size, (float)3 / 2 * block_size});
    }
}


bool
Shape::hits_right_side(const Game_config& config)
{
    for (Position& posn: Posn_set){
        if (posn.x + 1.0/2*block_size >= config.scene_dims.width){
            return true;
        }
    }
    return false;
}

void
Shape::move_right(Game_config const& config){
    if (hits_right_side(config)){
        return;
    }
    for (Position& posn: Posn_set){
        posn.x = posn.x + block_size;
    }
    pivot.x = pivot.x + block_size;
}

bool
Shape::hits_left_side(const Game_config& config)
{
    for (Position& posn: Posn_set){
        if (posn.x - 1.0/2*block_size <= 0) {
            return true;
        }
    }
    return false;
}

void
Shape::move_left(Game_config const& config)
{
    if (hits_left_side(config)){
        return;
    }
    for (Position& posn: Posn_set){
        posn.x = posn.x - block_size;
    }
    pivot.x = pivot.x - block_size;
}

bool
Shape::hits_bottom_screen(const Game_config& config)
{
    for (Position& posn: Posn_set){
        if (posn.y + 1.0/2*block_size >= config.scene_dims.height) {
            live = false;
            return true;
        }
    }
    return false;
}

void
Shape::move_down(Game_config const& config)
{

    if (hits_bottom_screen(config)){
        return;
    }
    //printf("moving down \n");
    for (Position& posn: Posn_set){
        posn.y = posn.y + block_size;
        //printf("%f \n", posn.y);
    }
    pivot.y = pivot.y + block_size;
}



void
Shape::rotate(Game_config const& config)
{
    if (type == 1){
        if (Posn_set[0].y == Posn_set[3].y +block_size){
            if (Posn_set[0].y + 3/2*block_size <= config.scene_dims.height){
                Posn_set[1] = {Posn_set[3].x,Posn_set[3].y };
                Posn_set[3] = {Posn_set[2].x,Posn_set[2].y};
                Posn_set[2] = {Posn_set[0].x, Posn_set[0].y + block_size};
            }
        }
        else if (Posn_set[0].x == Posn_set[3].x - block_size){
            if (Posn_set[0].x - 3/2*block_size >= 0){
                Posn_set[1] = {Posn_set[3].x,Posn_set[3].y };
                Posn_set[3] = {Posn_set[2].x,Posn_set[2].y};
                Posn_set[2] = {Posn_set[0].x-block_size, Posn_set[0].y};
            }
        }
        else if (Posn_set[0].y == Posn_set[3].y - block_size){
            Posn_set[1] = {Posn_set[3].x,Posn_set[3].y };
            Posn_set[3] = {Posn_set[2].x,Posn_set[2].y};
            Posn_set[2] = {Posn_set[0].x, Posn_set[0].y-block_size};
        }
        else if (Posn_set[0].x == Posn_set[3].x+ block_size){
            if (Posn_set[0].x + 3/2*block_size <= config.scene_dims.width){
                Posn_set[1] = {Posn_set[3].x,Posn_set[3].y };
                Posn_set[3] = {Posn_set[2].x,Posn_set[2].y};
                Posn_set[2] = {Posn_set[0].x+block_size, Posn_set[0].y};
            }
        }
    }


    if (type == 2){
        //scenario 1
        if (Posn_set[0].y  == Posn_set[1].y + block_size){
            if ((Posn_set[0].x + 3/2*block_size <= config.scene_dims.width) &&
                (Posn_set[0].x - 3/2*block_size >= 0) ){
                Posn_set[1] = {Posn_set[0].x+ block_size,Posn_set[0].y};
                Posn_set[2] = {Posn_set[0].x- block_size,Posn_set[0].y};
            }
        }

        //scenario 2
        else if (Posn_set[0].x  == Posn_set[1].x - block_size){
            if (Posn_set[0].y + 3/2*block_size <= config.scene_dims.height) {
                Posn_set[1] = {Posn_set[1].x- block_size,Posn_set[1]
                                                                 .y+block_size};
                Posn_set[2] = {Posn_set[2].x+ block_size,Posn_set[2]
                                                                 .y-block_size};
            }
        }

        else if (Posn_set[0].y  == Posn_set[1].y - block_size){
            if ((Posn_set[0].x + 3/2*block_size <= config.scene_dims.width) &&
                (Posn_set[0].x - 3/2*block_size >= 0) ){
                Posn_set[1] = {Posn_set[1].x- block_size,Posn_set[1].y-block_size};
                Posn_set[2] = {Posn_set[2].x+ block_size,Posn_set[2].y+block_size};
            }
        }

        else if (Posn_set[0].x  == Posn_set[1].x + block_size){
            if (Posn_set[0].y + 3/2*block_size <= config.scene_dims.height) {
                Posn_set[1] = {Posn_set[1].x+ block_size,Posn_set[1]
                                                                 .y-block_size};
                Posn_set[2] = {Posn_set[2].x- block_size,Posn_set[2]
                                                                 .y+block_size};
            }
        }


    }
}

bool
Shape::hits_another_position(std::vector<Position> all_positions){
    for (Position& posn1 : Posn_set){
        for (Position& posn2: all_positions){
            if ((posn1.x == posn2.x) && (posn1.y == posn2.y)){
                return true;
            }
        }
    }
    return false;
}

Shape Shape::natural_next(Game_config const& config){
    Shape new_shape = Shape(config, type);
    new_shape.live = live;
    new_shape.pivot = pivot;
    new_shape.Posn_set = Posn_set;
    for (Position& posn: new_shape.Posn_set){
        posn.y = posn.y + block_size;
    }
    new_shape.pivot.y = new_shape.pivot.y + block_size;
    return new_shape;
}

Shape Shape::right_next(Game_config const& config){
    Shape new_shape = Shape(config, type);
    new_shape.live = live;
    new_shape.pivot = pivot;
    new_shape.Posn_set = Posn_set;
    for (Position& posn: new_shape.Posn_set){
        posn.x = posn.x + block_size;
    }
    new_shape.pivot.x = new_shape.pivot.x + block_size;
    return new_shape;
}

Shape Shape::left_next(Game_config const& config){
    Shape new_shape = Shape(config, type);
    new_shape.live = live;
    new_shape.pivot = pivot;
    new_shape.Posn_set = Posn_set;
    for (Position& posn: new_shape.Posn_set){
        posn.x = posn.x - block_size;
    }
    new_shape.pivot.x = new_shape.pivot.x - block_size;
    return new_shape;
}

Position
Shape::get_pivot() const
{
    return pivot;
}

std::vector<Position>
Shape::get_posn_set()
{
    return Posn_set;
}

bool
Shape::get_live(){
    return live;
}
int
Shape::get_type(){
    return type;
}


void Shape::set_posn_set(std::vector<Position> posn_set){
    Posn_set = posn_set;
}
void Shape::set_pivot(Position piv){
    pivot = piv;
}

void Shape::set_live(bool alive){
    live = alive;
}
void Shape::set_type(int ty){
    type = ty;
}







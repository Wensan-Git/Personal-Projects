#include "view.hxx"
#include "model.hxx"
#include "game_config.hxx"

View::View(Model const& model)
        : model_(model),
          block({int(block_size-2),int(block_size-2)},{255, 255, 255})
{}

void
View::draw(ge211::Sprite_set& set)
{
    // This needs to do something!
    //set.add_sprite(block, {100, 100});



}

View::Dimensions
View::initial_window_dimensions() const
{
    // You can change this if you want:
    return {int(model_.get_config().scene_dims.width),int(model_.get_config()
    .scene_dims.height)};
}

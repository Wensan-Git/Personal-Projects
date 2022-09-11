#pragma once

#include "model.hxx"
#include "view.hxx"

#include <ge211.hxx>

class Controller : public ge211::Abstract_game
{
public:
    Controller(Model&);
    View::Dimensions initial_window_dimensions() const override;
    void on_key(ge211::Key) override;

protected:
    void draw(ge211::Sprite_set& set) override;
    void on_frame(double dt) override;

private:
    Model model_;
    View view_;
    ge211::Font sans17{"sans.ttf", 17};
    ge211::Text_sprite letter_sprites;
};

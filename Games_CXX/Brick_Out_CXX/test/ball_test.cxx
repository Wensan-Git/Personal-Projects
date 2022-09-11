#include "ball.hxx"
#include <catch.hxx>

Block const The_Paddle {100, 400, 100, 20};
Block Different_Paddle {200, 300, 100, 20};
TEST_CASE("Ball::Ball")
{
    Game_config config;
    Ball ball(The_Paddle, config);

    CHECK(ball.center.x == 150);
    CHECK(ball.center.y == 394);
}

TEST_CASE("Ball::hits_side")
{
    Game_config config;
    Ball ball(The_Paddle, config);

    CHECK_FALSE(ball.hits_side(config));
    ball.center.x = 1;
    CHECK(ball.hits_side(config));
    ball.center.x = config.scene_dims.width - 1;
    CHECK(ball.hits_side(config));
    ball.center.x = config.scene_dims.width / 2;
    CHECK_FALSE(ball.hits_side(config));
}

TEST_CASE("a thorough test"){
    Game_config config;
    Ball ball(The_Paddle, config);
    Ball ball2(The_Paddle, config);
    Ball ball3(Different_Paddle, config);
    CHECK(operator==(ball, ball2));
    CHECK_FALSE(operator==(ball, ball3));
    CHECK(ball3.top_left().x == 245);
    //Different_Paddle.x = 300;
    //CHECK(ball3.top_left().x == 350);
    CHECK(ball.top_left().x == 145);
    CHECK(ball.top_left().y == 389);
    ball.center.y = 763;
    CHECK_FALSE(ball.hits_bottom(config));
    ball.center.y += 1;
    CHECK(ball.hits_bottom(config));
    ball.center.y = 5;
    CHECK_FALSE(ball.hits_top(config));
    ball.center.y -= 1;
    CHECK(ball.hits_top(config));
    ball = Ball(The_Paddle, config);
    ball.center.x = 5;
    CHECK_FALSE(ball.hits_side(config));
    ball.center.x -= 1;
    CHECK(ball.hits_side(config));
    ball.center.x = 1019;
    CHECK_FALSE(ball.hits_side(config));
    ball.center.x += 1;
    CHECK(ball.hits_side(config));
    ball = Ball(The_Paddle, config);
    CHECK(ball.next(0.1).center.x == 165);
    CHECK(ball.next(0.1).center.y == 334);
    Block brick(50, 100, 30, 50);
    CHECK_FALSE(ball.hits_block(brick));
    ball.center.x = 50;
    CHECK_FALSE(ball.hits_block(brick));
    ball.center.y = 95;
    CHECK_FALSE(ball.hits_block(brick));
    ball.center.y += 1;
    CHECK(ball.hits_block(brick));
    std::vector<Block> block;
    block.push_back(brick);
    CHECK(block.size() == 1);
    ball.destroy_brick(block);
    CHECK(block.size() == 0);
}

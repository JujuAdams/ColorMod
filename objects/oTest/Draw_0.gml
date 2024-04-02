draw_text(10, 10, string(testIndex) + " of " + string(colorMod.GetModulo()));

var _scale = 8;

colorMod.DebugDrawPalette(50, 50, _scale);
draw_arrow(0, 50 + _scale*(testIndex + 0.5), 40, 50 + _scale*(testIndex + 0.5), 12);
colorMod.DebugDrawOutput(300, 50, 100, 100, "default", testIndex);

draw_sprite_ext(sTest, 0, 500, 400, 10, 10, 0, c_white, 1);

colorMod.SetShader("default");
draw_sprite_ext(sTest, 0, 1000, 400, 10, 10, 0, c_white, 1);
shader_reset();
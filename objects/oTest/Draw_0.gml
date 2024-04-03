var _backgroundAlpha = 0.3;

//Base sprite
var _x = (room_width div 3) - 100;
draw_sprite_ext(sTestBase, 0, _x, 400, 10, 10, 0, c_white, 1);
draw_sprite_ext(sTestHair, 0, _x, 400, 10, 10, 0, c_white, 1);

//Palette swapped sprite
var _x = 2*(room_width div 3) - 100;
colorMod.SetShader(palette);
draw_sprite_ext(sTestBase, 0, _x, 400, 10, 10, 0, c_white, 1);
draw_sprite_ext(sTestHair, 0, _x, 400, 10, 10, 0, c_white, 1);
shader_reset();

//Draw a visualisation for the palette surface
var _x = room_width - 110
var _y = 15;
var _scale = 8;
draw_set_color(c_ltgray);
draw_set_alpha(_backgroundAlpha);
draw_rectangle(_x - 5, _y - 5, _x + _scale*colorMod.PaletteCount() + 5, _y + _scale*colorMod.GetModulo() + 5, false);
colorMod.DebugDrawPalette(_x, _y, _scale);

//Info text
var _string = "";
_string += "ColorMod - Fast palette swapper\n";
_string += "Juju Adams 2024\n";
_string += "\n";
_string += "Press 1/2/3/0 to change palette\n";

var _width  = string_width(_string);
var _height = string_height(_string);

var _x = 10;

draw_set_color(c_black);
draw_set_alpha(_backgroundAlpha);
draw_rectangle(_x, 10, _x + _width + 20, 10 + _height + 20, false);

draw_text(_x + 10, 21, _string);
draw_set_color(c_white);
draw_set_alpha(1);
draw_text(_x + 10, 20, _string);

//Info text
var _string = "";
_string += "This is the actual surface used for colour data --->\n";
_string += "Each column is a palette\n";
_string += "Each row is a replacement colour\n";

var _width  = string_width(_string);
var _height = string_height(_string);

var _x = room_width - 150 - _width;

draw_set_color(c_black);
draw_set_alpha(_backgroundAlpha);
draw_rectangle(_x, 10, _x + _width + 20, 10 + _height + 20, false);

draw_text(_x + 10, 21, _string);
draw_set_color(c_white);
draw_set_alpha(1);
draw_text(_x + 10, 20, _string);
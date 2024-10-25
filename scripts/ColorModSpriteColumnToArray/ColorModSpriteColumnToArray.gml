// Feather disable all

/// Helper function to convert a column of pixels in a sprite into an array of 24-bit RGB colour
/// values.
/// 
/// @param sprite
/// @param image
/// @param x

function ColorModSpriteColumnToArray(_sprite, _image, _x)
{
    var _width  = sprite_get_width(_sprite);
    var _height = sprite_get_height(_sprite);
    
    var _array = array_create(_height, 0x000000);
    
    var _surface = surface_create(_width, _height);
    surface_set_target(_surface);
    draw_sprite(_sprite, _image, sprite_get_xoffset(_sprite), sprite_get_yoffset(_sprite));
    surface_reset_target();
    
    var _buffer = buffer_create(4*_width*_height, buffer_fixed, 1);
    buffer_get_surface(_buffer, _surface, 0);
    surface_free(_surface);
    
    buffer_seek(_buffer, buffer_seek_start, 4*_width*_x);
    
    var _i = 0;
    var _byte = 4*_x;
    repeat(_height)
    {
        _array[_i] = 0xFFFFFF & buffer_peek(_buffer, _byte, buffer_u32);
        
        ++_i;
        _byte += 4*_width;
    }
    
    buffer_delete(_buffer);
    
    return _array;
}
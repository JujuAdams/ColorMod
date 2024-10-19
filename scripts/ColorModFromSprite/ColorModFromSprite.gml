// Feather disable all

/// `ColorModFromSprite(sprite, image, useRows, [debugMode=false])`
/// 
/// Convenience function to create a ColorMod struct from a source sprite. If the `useRows`
/// parameter is set to `true` then the sprite will be processed row by row, if set to `false`
/// the sprite will be processed column by column. The default / unadjusted palette will be the
/// top-most row or left-most column.
/// 
/// Please see the documentation in the `ColorMod` script for a list of methods available on a
/// ColorMod struct.
/// 
/// The name of each palette within the ColorMod struct will be the y position of the row in the
/// sprite (or the x position of the column). The default / unadjusted palette is always index 0.
/// 
/// If the `debugMode` parameter is set to `true` then any colors in the drawn image that are not
/// in the default palette will usually be highlighted in bright fuchsia. Drawing with debug mode
/// turned on will significantly decrease performance so remember to turn it off before compiling
/// your game for other people to play.
/// 
/// N.B. This function is fairly slow and you should generally only call this function once when
///      the game boots.
/// 
/// N.B. ColorMod is not compatible with antialiased art or art drawn with texture filtering /
///      bilinear interpolation switched on. ColorMod should only be used with pixel art.
/// 
/// @param sprite
/// @param image
/// @param useRows
/// @param [debugMode=false]

function ColorModFromSprite(_sprite, _image, _useRows, _debugMode = false)
{
    var _width  = sprite_get_width(_sprite);
    var _height = sprite_get_height(_sprite);
    
    if (_useRows)
    {
        var _sourceArray = ColorModSpriteRowToArray(_sprite, _image, 0);
        var _colorMod = new ColorMod(_sourceArray, _height, _debugMode);
        
        var _y = 0;
        repeat(_height)
        {
            _colorMod.PaletteAdd(_y, ColorModSpriteRowToArray(_sprite, _image, _y));
            ++_y;
        }
    }
    else
    {
        var _sourceArray = ColorModSpriteColumnToArray(_sprite, _image, 0);
        var _colorMod = new ColorMod(_sourceArray, _width, _debugMode);
        
        var _x = 0;
        repeat(_width)
        {
            _colorMod.PaletteAdd(_x, ColorModSpriteColumnToArray(_sprite, _image, _x));
            ++_x;
        }
    }
    
    return _colorMod;
}
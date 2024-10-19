// Feather disable all

/// `ColorModFromSprite(sprite, image, useRows, [debugMode=false])`
/// 
/// Convenience function to create a ColorMod struct from a source sprite. If the `useRows`
/// parameter is set to `true` then the sprite will be processed row by row, if set to `false`
/// the sprite will be processed column by column. The default / unadjusted palette will be the
/// top-most row or left-most column.
/// 
/// The "name" of each palette within the ColorMod struct will be the y position of the row in the
/// sprite (or the x position of the column). The default / unadjusted palette is always index 0.
/// 
/// 
/// 
/// Please see the documentation in the `ColorMod` script for a full list of methods available on
/// a ColorMod struct. Basic use follows:
/// 
/// Step 1: Create a ColorMod struct at the start of the game
///     global.colorModForPlayer = ColorModFromSprite(sPlayerPalette, 0, true);
/// 
/// Step 2: In a Draw event, set the ColorMod shader, draw a sprite, then reset the shader
///     global.colorModForPlayer.SetShader(paletteIndex);
///     draw_sprite(sPlayer, 0, x, y);
///     shader_reset();
/// 
/// 
/// 
/// If the `debugMode` parameter is set to `true` then any colors in the drawn image that are not
/// in the default palette will usually be highlighted in bright fuchsia. Drawing with debug mode
/// turned on will significantly decrease performance so remember to turn it off before compiling
/// your game for other people to play.
/// 
/// The `moduloHint` parameter allows you to provide a pre-calculated modulo value. This skips the
/// slow modulo calculation step when first creating the ColorMod struct. You should calculate a
/// modulo value by running the game then copying that modulo value into your codebase for
/// subsequent runs of the game. You will need to update the modulo hint if your default palette
/// changes (but not alternate palettes).
/// 
/// N.B. This function is fairly slow and you should generally only call this function once when
///      the game boots.
/// 
/// N.B. ColorMod is not compatible with antialiased art or art drawn with texture filtering /
///      bilinear interpolation switched on. ColorMod should only be used with pixel art.
/// 
/// 
/// 
/// @param sprite
/// @param image
/// @param useRows
/// @param [debugMode=false]
/// @param [moduloHint]

function ColorModFromSprite(_sprite, _image, _useRows, _debugMode = false, _moduloHint = undefined)
{
    var _width  = sprite_get_width(_sprite);
    var _height = sprite_get_height(_sprite);
    
    if (_useRows)
    {
        var _sourceArray = ColorModSpriteRowToArray(_sprite, _image, 0);
        var _colorMod = new ColorMod(_sourceArray, _height, _debugMode, _moduloHint);
        
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
        var _colorMod = new ColorMod(_sourceArray, _width, _debugMode, _moduloHint);
        
        var _x = 0;
        repeat(_width)
        {
            _colorMod.PaletteAdd(_x, ColorModSpriteColumnToArray(_sprite, _image, _x));
            ++_x;
        }
    }
    
    _colorMod.EnsureSurface();
    
    return _colorMod;
}
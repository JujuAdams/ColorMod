// Feather disable all

/// ColorMod(targetColorArray, [maxPalettes=30], [debugMode=false]) constructor
/// 
/// Constructor for a ColorMod struct. This struct acts as an interface for customising and
/// enabling palette swaps using the "color modulo" technique. A ColorMod struct has no public
/// variables. Public methods that should be used are listed below.
/// 
/// If "debugMode" is set to <true> then any colors in the drawn image that are not in the target
/// color array will usually be highlighted in bright fuchsia. Drawing with debug mode turned on
/// will significantly decrease performance so remember to turn it off before compiling your game
/// for other people to play.
/// 
/// ColorMod is not compatible with antialiased art or art drawn with texture filtering / bilinear
/// interpolation switched on. ColorMod should only be used with pixel art.
/// 
/// 
/// 
/// .Destroy()
///     Destroys the ColorMod struct, freeing any memory associated with it.
///     
///     N.B. You must call this function when you've finished using a ColorMod struct otherwise you
///          will experience memory leaks that will eventually crash your game.
/// 
/// .SetShader(paletteName)
///     Sets up the palette swap shader for the given palette.
/// 
/// .PaletteAdd(paletteName, [colorArray])
///     Adds a new palette to the ColorMod struct. If no color array is provided, the output colors
///     are copied from the target colors used to create the ColorMod struct. If a palette with the
///     given name already exists, this function will throw an error. The input color array must be
///     the same length as the target color array used to create the ColoeMod struct.
/// 
/// .PaletteOverwrite(paletteName, colorArray, destOffset, [srcOffset], [length])
///     Overwrites a portion of an existing palette using part of a source color array. If a
///     palette with the provided name does not exist, this function with throw an error.
/// 
/// .PaletteEnsure(paletteName, [colorArray])
///     Ensures that a palette exists with the given name and using the given color array. This
///     means a new palette will be created if necessary or an existing palette will be overwritten.
/// 
/// .PaletteClear(paletteName)
///     Clears the contents of a palette, using the original target colors used to create the
///     ColorMod struct.
/// 
/// .PaletteGet(paletteName)
///     Returns the color array being used for the given palette.
/// 
/// .PaletteRemove(paletteName)
///     Removes a palette from the ColorMod struct.
/// 
/// .PaletteExists(paletteName)
///     Returns if a palette has been added for the ColorMod struct.
/// 
/// .PaletteCount()
///     Returns the number of palettes added to the ColorMod struct.
/// 
/// .RemoveAll()
///     Removes all palettes for the ColorMod struct.
/// 
/// .GetModulo()
///     Returns the modulo value for the ColorMod struct, chosen by analysis of the target colors
///     provided when creating the ColorMod struct.
/// 
/// .GetColorCount()
///     Returns the number of target colors provided when creating the ColorMod struct.
/// 
/// .MarkDirty()
///     Marks the ColorMod struct palette surface as "dirty" which will trigger a redraw when
///     .SetShader() is next called.
/// 
/// .DebugDrawPalette(x, y, scale)
///     Draws the entire palette at the given coordinates and with the given scale.
/// 
/// .DebugDrawOutput(x, y, width, height, paletteName, colorIndex)
///     Draws the color value for the given palette and color index, stretched out at the given
///     coordinates. Useful for checking values on the palette surface are what you expect them
///     to be.
/// 
/// @param targetColorArray
/// @param [maxPalettes=30]
/// @param [debugMode=false]

show_debug_message("ColorMod: Welcome to ColorMod by Juju Adams! This is version 1.0.0, 2024-04-02");

function ColorMod(_targetColorArray, _maxPalettes = 30, _debugMode = false) constructor
{
    static _moduloLookup = {};
    
    __targetColorArray = __ArrayClone(_targetColorArray);
    __maxPalettes      = _maxPalettes;
    __debugMode        = _debugMode;
    
    __colorCount = array_length(__targetColorArray);
    
    //Skip searching for a suitable modulo for this set of colors if we can
    var _searchArray = __ArrayClone(_targetColorArray);
    array_sort(_searchArray, true);
    var _searchKey = json_stringify(_searchArray);
    var _modulo = _moduloLookup[$ _searchKey];
    
    if (_modulo == undefined)
    {
        //Welp, didn't find a solution. Do a brute force search instead
        
        var _colorCount = __colorCount;
        var _modulo = _colorCount;
        
        do
        {
            var _success = true;
            var _foundDict = {};
            ++_modulo;
            
            var _i = 0;
            repeat(_colorCount)
            {
                var _value = _targetColorArray[_i] mod _modulo;
                if (variable_struct_exists(_foundDict, _value))
                {
                    _success = false;
                    break;
                }
                
                _foundDict[$ _value] = true;
                
                ++_i;
            }
        }
        until(_success)
        
        _moduloLookup[$ _searchKey] = _modulo;
    }
    
    __modulo = _modulo;
    
    __width  = __maxPalettes;
    __height = __modulo;
    
    __dirty       = true;
    __surface     = -1;
    __destroyed   = false;
    __texture     = undefined;
    __texelWidth  = undefined;
    __texelHeight = undefined;
    
    __outputPaletteArray = [];
    __outputPaletteDict  = {};
    
    
    
    
    
    static PaletteAdd = function(_paletteName, _outputColorArray = undefined)
    {
        if (_outputColorArray == undefined)
        {
            _outputColorArray = __ArrayClone(__targetColorArray);
        }
        
        if (array_length(_outputColorArray) != __colorCount)
        {
            __Error("Color array length (", array_length(_outputColorArray), ") doesn't match target color count ", __colorCount);
            return self;
        }
        
        if (variable_struct_exists(__outputPaletteDict, _paletteName))
        {
            __Error("Palette \"", _paletteName, "\" already exists");
            return self;
        }
        
        var _count = array_length(__outputPaletteArray);
        if (_count >= __maxPalettes)
        {
            __Error("Cannot add palette \"", _paletteName, "\", run out of palette slots (max=", __maxPalettes, ")");
            return self;
        }
        
        var _data = {
            __name: _paletteName,
            __index: _count,
            __colorArray: _outputColorArray,
        };
        
        __outputPaletteDict[$ _paletteName] = _data;
        array_push(__outputPaletteArray, _data);
        
        __dirty = true;
        
        return self;
    }
    
    static PaletteEnsure = function(_paletteName, _outputColorArray = undefined)
    {
        if (variable_struct_exists(__outputPaletteDict, _paletteName))
        {
            PaletteOverwrite(_paletteName, _outputColorArray);
        }
        else
        {
            PaletteAdd(_paletteName, _outputColorArray);
        }
    }
    
    static PaletteOverwrite = function(_paletteName, _outputColorArray = __targetColorArray, _destOffset = 0, _srcOffset = 0, _length = array_length(_outputColorArray))
    {
        var _data = __outputPaletteDict[$ _paletteName];
        if (_data == undefined)
        {
            __Error("Palette \"", _paletteName, "\" doesn't exist");
            return self;
        }
        
        if (_destOffset + _length > __colorCount)
        {
            __Error("Overwrite operation would copy too many colors (dest=", _destOffset, ", length=", _length, ", color count=", __colorCount, ")");
            return self;
        }
        
        array_copy(_data.__colorArray, _destOffset, _outputColorArray, _srcOffset, _length);
        
        __dirty = true;
        
        return self;
    }
    
    static PaletteClear = function(_paletteName)
    {
        var _data = __outputPaletteDict[$ _paletteName];
        if (_data == undefined) return;
        
        array_copy(_data.__colorArray, 0, __targetColorArray, 0, __colorCount);
        
        __dirty = true;
        
        return self;
    }
    
    static PaletteGet = function(_paletteName)
    {
        var _data = __outputPaletteDict[$ _paletteName];
        return (_data == undefined)? undefined : _data.__colorArray;
    }
    
    static PaletteRemove = function(_paletteName)
    {
        var _outputPaletteArray = __outputPaletteArray;
        
        var _data = __outputPaletteDict[$ _paletteName];
        var _index = _data.__index;
        
        variable_struct_remove(__outputPaletteDict, _paletteName);
        array_delete(_outputPaletteArray, _index, 1);
        
        var _i = _index;
        repeat(array_length(_outputPaletteArray) - _index - 1)
        {
            _outputPaletteArray[_i].__index = _i;
            ++_i;
        }
        
        __dirty = true;
        
        return self;
    }
    
    static PaletteExists = function(_paletteName)
    {
        return variable_struct_exists(__outputPaletteDict, _paletteName);
    }
    
    static PaletteCount = function()
    {
        return array_length(__outputPaletteArray);
    }
    
    static RemoveAll = function()
    {
        array_resize(__outputPaletteArray, 0);
        __outputPaletteDict = {};
        
        __dirty = true;
        
        return self;
    }
    
    static Destroy = function()
    {
        __destroyed = true;
        
        if (surface_exists(__surface))
        {
            surface_free(__surface);
            __surface = -1;
        }
    }
    
    static SetShader = function(_paletteName)
    {
        if (__destroyed) return;
        
        static _u_sPalette = shader_get_sampler_index(__shdColorMod, "u_sPalette");
        static _u_vModulo  = shader_get_uniform(__shdColorMod, "u_vModulo");
        static _u_fColumn  = shader_get_uniform(__shdColorMod, "u_fColumn");
        static _u_vTexel   = shader_get_uniform(__shdColorMod, "u_vTexel");
        
        static _u_sPaletteDebug = shader_get_sampler_index(__shdColorModDebug, "u_sPalette");
        static _u_vModuloDebug  = shader_get_uniform(__shdColorModDebug, "u_vModulo");
        static _u_fColumnDebug  = shader_get_uniform(__shdColorModDebug, "u_fColumn");
        static _u_vTexelDebug   = shader_get_uniform(__shdColorModDebug, "u_vTexel");
        
        var _data = __outputPaletteDict[$ _paletteName];
        if (_data == undefined)
        {
            __Error("Palette \"", _paletteName, "\" not found");
            return;
        }
        
        __EnsureSurface();
        
        if (__debugMode)
        {
            shader_set(__shdColorModDebug);
            texture_set_stage(_u_sPaletteDebug, __texture);
            shader_set_uniform_f(_u_vModuloDebug, 1, 0x100 mod __modulo, 0x10000 mod __modulo, __modulo);
            shader_set_uniform_f(_u_fColumnDebug, _data.__index + 1);
            shader_set_uniform_f(_u_vTexelDebug, __texelWidth, __texelHeight);
        }
        else
        {
            shader_set(__shdColorMod);
            texture_set_stage(_u_sPalette, __texture);
            shader_set_uniform_f(_u_vModulo, 1, 0x100 mod __modulo, 0x10000 mod __modulo, __modulo);
            shader_set_uniform_f(_u_fColumn, _data.__index);
            shader_set_uniform_f(_u_vTexel, __texelWidth, __texelHeight);
        }
    }
    
    static GetModulo = function()
    {
        return __modulo;
    }
    
    static GetColorCount = function()
    {
        return __colorCount;
    }
    
    static MarkDirty = function()
    {
        __dirty = true;
    }
    
    static DebugDrawPalette = function(_x, _y, _scale)
    {
        if (__destroyed) return;
        
        __EnsureSurface();
        
        draw_surface_ext(__surface, _x, _y, _scale, _scale, 0, c_white, 1);
    }
    
    static DebugDrawOutput = function(_x, _y, _width, _height, _paletteName, _colorIndex)
    {
        if (__destroyed) return;
        
        static _u_fRow     = shader_get_uniform(__shdColorModDebugOutput, "u_fRow");
        static _u_fColumn  = shader_get_uniform(__shdColorModDebugOutput, "u_fColumn");
        static _u_vTexel   = shader_get_uniform(__shdColorModDebugOutput, "u_vTexel");
        
        __EnsureSurface();
        
        shader_set(__shdColorModDebugOutput);
        shader_set_uniform_f(_u_fRow, __debugMode? (_colorIndex + 1) : _colorIndex);
        shader_set_uniform_f(_u_fColumn, __outputPaletteDict[$ _paletteName].__index);
        shader_set_uniform_f(_u_vTexel, __texelWidth, __texelHeight);
        
        draw_surface_stretched(__surface, _x, _y, _width, _height);
        
        shader_reset();
    }
    
    static __EnsureSurface = function()
    {
        static _identityMatrix = matrix_build_identity();
        
        if (__destroyed) return;
        
        if (not surface_exists(__surface))
        {
            __surface     = surface_create(__debugMode? (__width + 1) : __width, __height);
            __texture     = surface_get_texture(__surface);
            __texelWidth  = texture_get_texel_width(__texture);
            __texelHeight = texture_get_texel_height(__texture);
            
            __dirty = true;
        }
        
        if (__dirty)
        {
            __dirty = false;
            
            var _oldBlendMode = gpu_get_blendmode_ext();
            var _oldWorldMatrix = matrix_get(matrix_world);
            matrix_set(matrix_world, _identityMatrix);
            surface_set_target(__surface);
            
            draw_clear_alpha(c_black, 0);
            
            var _debugMode          = __debugMode;
            var _modulo             = __modulo;
            var _targetColorArray   = __targetColorArray;
            var _colorCount         = __colorCount;
            var _outputPaletteArray = __outputPaletteArray;
            
            if (__debugMode)
            {
                var _i = 0;
                repeat(array_length(_targetColorArray))
                {
                    var _color = _targetColorArray[_i];
                    draw_sprite_ext(__sColorModPixel, 0, 0, _color mod _modulo, 1, 1, 0, _color, 1);
                    ++_i;
                }
            }
            
            var _i = 0;
            repeat(array_length(_outputPaletteArray))
            {
                var _paletteData = _outputPaletteArray[_i];
                var _outputColorArray = _paletteData.__colorArray
                
                var _x = _debugMode? (_i + 1) : _i;
                
                var _j = 0;
                repeat(_colorCount)
                {
                    var _y = _targetColorArray[_j] mod _modulo;
                    draw_sprite_ext(__sColorModPixel, 0, _x, _y, 1, 1, 0, _outputColorArray[_j], 1);
                    ++_j;
                }
                
                ++_i;
            }
            
            gpu_set_blendmode_ext(_oldBlendMode[0], _oldBlendMode[1]);
            matrix_set(matrix_world, _oldWorldMatrix);
            surface_reset_target();
        }
    }
    
    static __Error = function()
    {
        var _string = "ColorMod:\n";
        
        var _i = 0;
        repeat(argument_count)
        {
            _string += string(argument[_i]);
            ++_i;
        }
        
        show_error(_string + "\n ", true);
    }
    
    static __ArrayClone = function(_array)
    {
        var _length = array_length(_array);
        var _newArray = array_create(_length);
        array_copy(_newArray, 0, _array, 0, _length);
        return _newArray;
    }
}
// Feather disable all

/// @param colorMod

function ColorModDestroy(_colorMod)
{
    if (is_struct(_colorMod)) _colorMod.Destroy();
}
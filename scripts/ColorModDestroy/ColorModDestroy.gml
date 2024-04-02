// Feather disable all

/// Convenience function to destroy a ColorMod struct after making a basic safety check.
/// 
/// @param colorMod

function ColorModDestroy(_colorMod)
{
    if (is_struct(_colorMod)) _colorMod.Destroy();
}
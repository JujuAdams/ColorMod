if (mouse_check_button_pressed(mb_left))
{
    if (mouse_y < room_height/2)
    {
        testIndex = (testIndex - 1 + colorMod.GetModulo()) mod colorMod.GetModulo();
    }
    else
    {
        testIndex = (testIndex + 1) mod colorMod.GetModulo();
    }
}
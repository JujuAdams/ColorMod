//Create our ColorMod struct. We need to specify all the colors that we expected to see in images
//drawn with using the ColorMod palette swapper, including colors we don't want to swap
colorMod = new ColorMod(ColorModSpriteRowToArray(sTestPaletteRows, 0, 0));

//Add a default pass-through palette for testing
//Using an empty array will cause ColorMod to not transform the colors at all
colorMod.PaletteAdd("default", []);

//Add our first test palette
colorMod.PaletteAdd("test 1", ColorModSpriteRowToArray(sTestPaletteRows, 0, 1));

//Add a couple more palettes for testing
colorMod.PaletteAdd("test 2", ColorModSpriteRowToArray(sTestPaletteRows, 0, 2));

colorMod.PaletteAdd("test 3", ColorModSpriteRowToArray(sTestPaletteRows, 0, 3));

//Extra variable for the demo
palette = "test 1";
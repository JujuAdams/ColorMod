//Create our ColorMod struct. We need to specify all the colors that we expected to see in images
//drawn with using the ColorMod palette swapper, including colors we don't want to swap
colorMod = new ColorMod([
    //Hair
    #926d59, #8a593f, #754931,
    
    //Skin
    #f0ceb7, #e8b796, #c28569, #a16a50, #7d4d34, #5a3e2f,
    
    //Kit 1
    #a084f1, #8966ea, #6759a4, #524280,
    
    //Kit 2
    #d9b459, #c28500,
    
    //Other colors that we don't want to replace
    #c0cbdc, #181425, #7a5333, #9e2835, #000000, #ffffff,
]);

//Add a default pass-through palette for testing
//Using an empty array will cause ColorMod to not transform the colors at all
colorMod.PaletteAdd("default", []);

//Add our first test palette
colorMod.PaletteAdd("test 1", [
    //Hair
    #5e5451, #534b49, #3a3331,
    
    //Skin
    #8d5651, #694744, #5b3734, #523431, #3c2523, #31201f,
    
    //Kit 1
    #82cc71, #68b656, #539f42, #479234,
    
    //Kit 2
    #f72e45, #d31e34,
    
    //The ColorMod struct has an extra 6 colors at the end that we don't want to replace
    //Instead of redefining those same colors we can just miss them off at the end
    //ColorMod will fill in the gaps if our array is too short
]);

//Add a couple more palettes for testing
colorMod.PaletteAdd("test 2", [
    #554537, #4c3d30, #443333,
    #aa6664, #9b5755, #8d4240, #7c3331, #6a3130, #5a2d2c,
    #555d7a, #4b5168, #3d4255, #30364c,
    #f9f9f9, #d3cdcf,
]);

colorMod.PaletteAdd("test 3", [
    #bb6b58, #b36655, #ab503b,
    #f0ceb7, #e8b796, #c28569, #a16a50, #7d4d34, #5a3e2f,
    #2aaaf3, #249ee3, #2992ce, #1f7db3,
    #80d1ff, #47a7df,
]);

//Extra variable for the demo
palette = "test 1";
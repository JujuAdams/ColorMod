colorMod = new ColorMod([
    //Hair
    #926d59, #8a593f, #754931,
    
    //Skin
    #f0ceb7, #e8b796, #c28569, #a16a50, #7d4d34, #5a3e2f,
    
    //Kit 1
    #a084f1, #8966ea, #6759a4, #524280,
    
    //Kit 2
    #d9b459, #c28500,
    
    //Other colours that we don't want to replace
    #c0cbdc, #181425, #7a5333, #9e2835, #000000, #ffffff,
]);

//Add a default pass-through palette for testing
colorMod.PaletteAdd("default");

colorMod.PaletteAdd("test 1", [
    //Hair
    #5e5451, #534b49, #3a3331,
    
    //Skin
    #8d5651, #694744, #5b3734, #523431, #3c2523, #31201f,
    
    //Kit 1
    #82cc71, #68b656, #539f42, #479234,
    
    //Kit 2
    #f72e45, #d31e34,
    
    //Other colours that we don't want to replace
    #c0cbdc, #181425, #7a5333, #9e2835, #000000, #ffffff,
]);

colorMod.PaletteAdd("test 2", [
    //Hair
    #554537, #4c3d30, #443333,
    
    //Skin
    #aa6664, #9b5755, #8d4240, #7c3331, #6a3130, #5a2d2c,
    
    //Kit 1
    #555d7a, #4b5168, #3d4255, #30364c,
    
    //Kit 2
    #f9f9f9, #d3cdcf,
    
    //Other colours that we don't want to replace
    #c0cbdc, #181425, #7a5333, #9e2835, #000000, #ffffff,
]);

colorMod.PaletteAdd("test 3", [
    //Hair
    #bb6b58, #b36655, #ab503b,
    
    //Skin
    #f0ceb7, #e8b796, #c28569, #a16a50, #7d4d34, #5a3e2f,
    
    //Kit 1
    #2aaaf3, #249ee3, #2992ce, #1f7db3,
    
    //Kit 2
    #80d1ff, #47a7df,
    
    //Other colours that we don't want to replace
    #c0cbdc, #181425, #7a5333, #9e2835, #000000, #ffffff,
]);

//Extra variable for the demo
palette = "test 1";
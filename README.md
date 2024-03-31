# The "Colour Modulo" Palette Swapper

**A method for O(1) palette lookups that avoids pre-processing source images.**

Juju Adams 2024

&nbsp;

## tl;dr

This repo contains a library that does fast palette swapping for an arbitrary number of colours in constant time without modifying the source image. This system will need a short period of time to initialize on boot (depends on the number of colours in the palette but usually on the order of tens of milliseconds). This solution hits the sweet spot between the flexibility of colour searching and the speed of colour indexing. Colour modulo palette swapping is less performant than colour indexing due to the additional texture sample per texel but the colour modulo solution is much more convenient to use in production.

&nbsp;

## Introduction

Something that came up at work this week was the topic of palette swapping. This is a common technique whereby a set of colours in a source image are swapped out for a different colour. It reduces the number of assets that need to be created by allowing things like changing costume colour to be done programmatically. This technique has a long history and dates back to hardware where a game's colour palette was a dedicated space in memory and changing the palette would change the appearance of sprites drawn to the screen. Palette swapping can be used with high res assets - The Swords Of Ditto used a palette swapper, for example - but it's most commonly associated with pixel art games.

You can do palette swapping by splitting an image into many layers and then tinting each layer but this results in a lot of overdraw and its use is limited. Palette swapping is most often accomplished in a fragment (pixel) shader and this is the focus of this particular article. Mapping between input and output colours for a palette swapper are assumed to be 1:1 with no tolerance/threshold values i.e. "old school" or "hard" palette swapping. (Soft palette swapping using tolerances/thresholds is useful for dealing with high res images but that's a topic for another time.)

A note on terminology: I'll be using the word "colour" a lot. It's going to get a bit repetitive but there's no way around that. There are three types of colour that a palette swapper concerns itself with. Firstly, there are the "input" colours. These are colours found by sampling the image that's being drawn. Secondly, there are "target" colours which are the colours we're looking to replace. Not all colours in an image are going to be target colours, a classic example is the whites of a character's eyes. Finally, we have "output" colours. There are the colours that we are using as the replacements. Output colours are typically grouped together in palettes that an artist predefines, though some games allow a playet to define their own colours. In short, input colours that match target colours get turned into the equivalent output colours.

&nbsp;

## Colour Searching

A palette swap takes an input colour sampled from the image itself, finds which target colour that matches, and then spits out a new output colour so that it can be drawn. The output colours are dynamic and can be changed at runtime. The target colours are invariably known at compile time as they need to match the source image. Because output colours can change at runtime, they are stored in an array (or a lookup texture - more on that later) such that output colours can we swapped over at runtime fluidly. This means input colours are first translated into an array index via the target colours and then the output colour is determined by whatever value is stored in that array. 

There are well over 16 million possible combinations of values for a 24-bit RGB colour. It is inadviseable to create a 16 million entry array that handles every possible RGB colour value, and throwing an around of this size isn't possible in a shader anyway. After all, the palette for a sprite is rarely more than a couple dozen colours, if that. Allocating space for every possible outcome is inefficient. Instead, palette swappers must find a way to reduce the amount of space that's needed to match input colours to target colours.

The most basic solution to this problem is to send an array into the shader that contains only exactly the target colours that are relevant. We can then iterate over that array in a fragment shader trying to find a match between our input colour and target colour. Once we know which target colour we're looking at then we get an array index, and that array index can be converted into an output colour. This isn't the worst idea but it's slow and scales poorly due to `O(n)` complexity. Colour searching is very flexible but the trade-off is that the GPU is doing a lot more work to accommodate that flexibility.

&nbsp;

## Colour Indexing

Instead of iterating over an array of colours, smart developers can instead use "colour indexing". This method requires replacing input colours in the image itself before compiling the game. Instead of seeing a colour in an image as an actual colour, the "colour index" skips a search step entirely and encodes the array index as the colour value itself. Colours in the image that are targets are replaced with (typically) a greyscale value. Each greyscale value is actually an array index value that line up with an output colour array.

For example, if you wanted to swap red to blue then you'd process your image to replace every red pixel with a greyscale value. Let's say red is the fourth target colour we have to its colour becomes #030303 (since we're zero-indexed). When drawing this image, you'd use a shader that takes greyscale images and turns it into an index value for an array. #030303 would become `3`. This index is then used to read an output colour from an array sent into the shader. This is really fast and a conceptually elegant technique. We can think of making the pre-processing step as "pre-searching" for an array index and then storing that result for fast access later.

Because the input colour is the array index, the time complexity for finding the correct output colour is `O(1)`. It doesn't matter how many target colours we have, the performance of this method will stay about the same.

The problem with colour indexing is that it requires pre-processing all your images that need colour swapping. It's not a trivial task to write tooling to do that. You also need to ensure that colour indexes match the correct position in the output volout array across all images which is a lot of work to manage and regularly breaks. Finally, if your art assets change (which is often) then you'll need to process your art all over again. And if you've processed all your art then you really should test all your art in-game to make sure nothing id broken. The colour index method is very fast it creates a lot of fiddly work that is liable to break, time-consuming to test, and very obvious to players when it's broken.

&nbsp;

## Modulo

What we want is the speed of colour indexing with the convenience of colour searching. Whilst it's not possible to be quite as memory efficient as either of the two techniques discussed, we can use some simple maths to get both speed and convenience without too much compromise.

Palette swapping is all about taking an input colour finding a matching target colour in an array. The "colour search" solution discovers our array index by iterating over all the target colours and checking for a match one by one. The "colour index" solution treats the input colour itself as an array index, albeit after pre-processing the image before compile. The solution being introduced here will calculate the array index for a given input colour at runtime by using the modulo mathematical function. (I won't explain what modulo does in detail here because if you're implementing a palette swap shader you probably know already. If you don't, [Khan Academy](https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/what-is-modular-arithmetic) has a decent article.)

What're going to do is calculate the array index as simply `arrayIndex = inputColour mod base`. Because we're using modulo, we know that calculated array indexes can never exceed the base of the modulo function. This puts a hard limit on the maximum length of the array. We further choose an appropriate base such that none of the calculated array indexes overlap for the input colours in the image. We want to choose the base that gives us the smallest modulo base possible which means our final array can be as small as possible. We're going to assume all input colours are remappable for the purposes of choosing a base otherwise we might end up in a situation where we have an array index collision leading to the wrong colours being swapped.

Getting an output colour is as simple as `outputColour = array[inputColour mod base]`. This is fast for the GPU to calculate in a fragment shader and doesn't require any image pre-processing. We can do some additional work to improve on this equation to reduce the array size a little bit, but let's keep it simple for now.

Actually finding the right modulo base is a process of brute force, or at least I haven't found a good way of finding the best base without an exaustive search. As a result, this isn't a quick process and can take a while. The good news is that it only needs to happen once and any results can be cached for use later. Potentially these results can even be pre-computed before compiling the game.

Something to point out here is that the array indexes generated by this method will be unordered and non-consecutive. Part of the trade-off of using the modulo solution is not having 100% memory efficiency and there is typically some space between entries in the array. This isn't ideal but it's better than storing data for 16 million colours!

&nbsp;

## Appendix: Look-up Textures

I've been using the word "array" a lot but this solution will regularly require an array that is far larger than a shader can support. If you use an array to contain output colours then, due to the amount of empty space that is typical in the output colour array, you'll hit a limit on how many uniform registers you can use. To make matters worse, where that limit is depends massively on the hardware you're testing on! In reality, an array is unlikely to be suitable to contain the output colours. Instead, we can use a "look-up texture" instead of an array, also called a "LUT". Look-up textures are slower to access than an array but without them this solution wouldn't be viable.

In GameMaker, we could either use a sprite to contain this look-up texture or - more practically - we can use a surface. We make the look-up texture available to the palette swap shader by binding it as a sampler. For the implementation in this repo, each row of the surface is an entry in an array where the index of the array is the y-axis in the surface. Multiple palette can be stored on the surface by using different columns, effectively making the surface a 2D array.

# Modulo Palette Swapper

## Introduction

Something that came up at work this week was the topic of palette swapping. This is a common technique whereby a set of colours in a source image are swapped out for a different colour. This technique has a long history and dates back to hardware where a game's palette was a space in memory that stored colour mapping and changing the palette would change the appearance of sprites drawn to the screen. Palette swapping can be used with high res assets - The Swords Of Ditto used a palette swapper, for example - but it's most commonly associated with pixel art games.

You can do palette swapping by splitting an image into many layers and using vertex colours to tint each layer but this results in a lot of overdraw and each vertices flying around to its use is limited. These days, palette swapping is most often accomplished in a fragment (pixel) shader and this is focus of this particular article. Mapping between input and output colours for a palette swapper are assumed to be 1:1 with no tolerance/threshold values i.e. "old school" or "hard" palette swapping. (Soft palette swapping using tolerances/thresholds are useful for dealing with high res images but that's a topic for another time.)

## Colour Searching

The basic requirements for a palette swapping shader are:

1. Have a "list" of input colours and associated output colours;

2. Be able to find an input colour in that list;

3. Identify the correct output colour based on which input colour has been found.

The first and third requirements are typically met with the use of either a uniform array of colours, or with a look-up texture (also called an "LUT", a similar idea to colour grading LUTs).

The second requirement is the central issue in a palette swapping shader. There are well over 16 million possible combinations of values for a 24-bit RGB colour. It is inadviseable to create a 16 million entry array that handles every single value, and this sort of thing isn't possible in a shader anyway. After all, the palette for a sprite is rarely more than a couple dozen colours. It's sort of possible to make an LUT for 16 million colours as that'd be a 4096x4096 LUT but we can do a lot better than wasting all that space.

The most basic solution to this problem is to send an array (or LUT) into the shader that contains only exactly the input and output colours that are relevant. We can then iterate over that array in a fragment shader trying to find a matching input colour. This isn't the worst idea but it's slow and scales poorly due to O(n) complexity. Furthermore, if you use an array to contain input colours then you'll hit a limit on how many uniform registers you can use which puts a hard limit on the number of colours you can swap. To make matters worse, where that limit is depends massively on the hardware you're testing on! If you opt for an LUT instead of an array then it's even slower due to the expense of texture sampling.

## Colour Indexing

Instead of iterating over an array of colours, smart developers can instead to use "colour indexing". This method requires replacing swappable colours in an image at some point before compiling the game. Instead of seeing a colour in an image as an actual colour, colour index treats colours as mere data. In this case, colours that are swappable are replaced with (typically) a greyscale value. Each greyscale value is actually an index value for a future colour array passed into a shader.

For example, if you wanted to swap red to blue then you'd process your image to replace every red pixel with a greyscale value of #010101. When drawing this image, you'd use a shader that takes greyscale images and turns it into an index value for an array. #010101 would become `1`. This index is then used to read an output colour from an array sent into the shader. (It's less common to use textures for colour indexing but it is an option when replacing a large number of colours.)

The problem with colour indexing is that it requires pre-processing all your images that need colour swapping. It's not a trivial task to write tooling to do that and it is unlikely to be within reach of most indie developers. You also need to ensure that colour indexes match the correct position in the array across all those images which, again, is a lot of work to manage. Finally, if your art assets change (which is always right up until the final moments in production) then you'll need to process your art all over again. And if you've process all your art then you really should all your art to make sure nothing broken. It's a lot of technical, fiddly work that is liable to break exactly when you need it not to.

## Modulo

What we want is the speed of colour indexing with the convenience of colour searching. Whilst it's not possible to be quite as memory efficient as either of the two techniques discussed, we can use some simple maths to improve the situation considerably.

If we look at the "colour search" solution, we discover our array index by iterating over all the input colours. The "colour index" solution treats the input colour itself as an array index (after pre-processing). What we're going to do instead for our new solution is calculate the array index using the modulo mathematical function. (I won't explain what modulo does in detail here because if you're implementing a palette swap shader you probably know already. If you don't, [Khan Academy](https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/what-is-modular-arithmetic) has a decent article.)

What're going to do is calculate the array index as simply `arrayIndex = inputColour mod base`. Because we're using modulo, we know that calculated array indexes can never exceed the base of the modulo function which puts a hard limit on the maximum length of the array. We further choose an appropriate base such that none of the calculated array indexes overlap for the input colours we're concerned with. We want to choose the base that gives us the smallest range of array indexes. This means our final array can be as small as possible.

After doing this work, getting an output colour is as simple as `outputColour = array[(inputColour mod base) - minIndex]`. This is fast for the GPU to calculate in a fragment shader and doesn't require any image processing work.

Actually finding the right modulo base is a process of brute force, or at least I haven't found a good way of finding the best base without a greedy search. As a result, this isn't a quick process and can take a while. The good news is that it only needs to happen once and any results can be cached for use later. Potentially these results can even be pre-computed before compiling the game.

Something to point out here is that the array indexes will be unorder and non-consecutive. There is typically some space between entries in the array. This isn't ideal but it's a lot better than the situation we started with: millions of empty spaces. Part of the trade-off of using the modulo solution is not having 100% memory efficiency.

## Look-up Textures

# The "Colour Modulo" Palette Swapper

**A method for O(1) palette lookups without image pre-processing.**

Juju Adams 2024

&nbsp;

## tl;dr

This repo contains a library that does fast palette swapping for an arbitrary number of colours in constant time without modifying the source image. This system will need a short period of time to initialize when setting up (time taken depends on the number of colours in the palette but around a millisecond for 20 colours in my limited testing). This solution hits the sweet spot between the flexibility of colour searching and the speed of colour indexing. Colour modulo palette swapping is slightly less performant than colour indexing due to the additional maths being run in the fragment shader but the colour modulo solution is much more convenient to use in production.

&nbsp;

## Introduction

Something that came up at work this week was the topic of palette swapping. This is a common technique whereby a set of colours in a source image are swapped out for a different colour. It reduces the number of assets that need to be created by allowing things like changing costume colour to be done programmatically. This technique has a long history and dates back to hardware where a game's colour palette was a dedicated space in memory and changing the palette would change the appearance of sprites drawn to the screen. Palette swapping can be used with high res assets - The Swords Of Ditto used a palette swapper, for example - but it's most commonly associated with pixel art games.

You can do palette swapping by splitting an image into many layers and then tinting each layer but this results in a lot of overdraw and its use is limited. Palette swapping is most often accomplished in a fragment (pixel) shader and this is the focus of this particular article. Mapping between input and output colours for a palette swapper are assumed to be 1:1 with no tolerance/threshold values i.e. "old school" or "hard" palette swapping. (Soft palette swapping using tolerances/thresholds is useful for dealing with high res images but that's a topic for another time.)

A note on terminology: I'll be using the word "colour" a lot. It's going to get a bit repetitive but there's no way around that. There are three types of colour that a palette swapper concerns itself with. Firstly, there are the "input" colours. These are colours found by sampling the image that's being drawn. Secondly, there are "target" colours which are the colours we're looking to replace. Not all colours in an image are going to be target colours, a classic example is the whites of a character's eyes. Finally, we have "output" colours. There are the colours that we are using as the replacements. Output colours are typically grouped together in palettes that an artist predefines, though some games allow a playet to define their own colours. In short, input colours that match target colours get turned into the equivalent output colours.

&nbsp;

## Colour Searching

Let's start with the most basic type of palette swapper: an iterative searcher. This sort of palette swapper, for every texel sampled from the image, iterates over all the target colours until a match is found. Once a match is found, the fragment shader chooses the associated output colour and outputs that. Actually doing this in a shader is pretty easy - send in two arrays of colours (one for the targets and one for the outputs), set up a for-loop, spin round the for-loop until you find a matching colour, output the output colour.

The problems creep in fast though. As you add more colours to the array you'll find that rendering starts to get bogged down. This is because this method is what's called "`O(n)` complex", also known as "linear time complexity". Linear time complexity isn't the slowest kind of algorithm but it isn't exactly *good* either. We want to improve on this (and, indeed, we can). In addition to a larger array making things slower, you'll also find that after a certain point you can't keep adding new colours to the array. Or, at least, you can but the shader doesn't seem to be recognising those colours. That's because shaders can only cope with so much information being sent via uniforms. Sometimes, especially on lower-end hardware, you'll find that extra information sent via uniforms is just cut off (or, worse yet, the shader up and crashes).

There are some advantages to colour searching as a basic palette swapper. Firstly, it's simple, based on straight-forward ideas, and requires little maintainence. It's easy to set up too and there's no tooling required as the bulk of the work is done at runtime. If you've only got two or three colours to replace this method is a-ok and it'll take you a short distance which is often good enough. But sooner or later you're going to want a bit more power.

&nbsp;

## Colour Indexing

Instead of iterating over an array of colours, smart developers can instead use "colour indexing". This method requires replacing input colours in the image itself before compiling the game. Instead of seeing a colour in an image as an actual colour, the "colour index" skips a search step entirely and encodes the array index into the colour value itself. Colours in the image that are targets are replaced with (typically) a greyscale value. Each greyscale value is actually an array index value that line up with an output colour array.

For example, if you wanted to swap red to blue then you'd process your image to replace every red pixel with a greyscale value. Let's say red is the fourth target colour we have so its colour becomes #030303 (since we're zero-indexed). When drawing this image, you'd use a shader that takes greyscale images and turns it into an index value for an array. #030303 would become `3`. This index is then used to read an output colour from an array sent into the shader. This is really fast and a conceptually elegant technique. We can think of making the pre-processing step as "pre-searching" for an array index and then storing that result for fast access later.

Because the input colour is the array index, the time complexity for finding the correct output colour is `O(1)`. It doesn't matter how many target colours we have, the performance of this method will stay the same, more or less.

The problem with colour indexing is that it requires pre-processing all your images that need colour swapping. It's not a trivial task to write tooling to do that. You also need to ensure that colour indexes match the correct position in the output colour array across all images which is a lot of work to manage and regularly breaks. Finally, if your art assets change (which is often) then you'll need to process your art all over again. And if you've processed all your art then you really should test all your art in-game to make sure nothing id broken. The colour index method is very fast it creates a lot of fiddly work that is liable to break, time-consuming to test, and very obvious to players when it's broken.

&nbsp;

## Colour Modulo

What we want is the speed of colour indexing with the convenience of colour searching. Whilst it's not possible to be quite as memory efficient as either of the two techniques discussed, we can use some simple maths to get both speed and convenience without too much compromise.

Palette swapping is all about taking an input colour finding a matching target colour in an array. The "colour search" solution discovers our array index by iterating over all the target colours and checking for a match one by one. The "colour index" solution treats the input colour itself as an array index, albeit after pre-processing the image before compile. The "colour modulo" solution being introduced here will calculate the array index for a given input colour at runtime by using the **modulo** mathematical function. (I won't explain what modulo does in detail here because if you're implementing a palette swap shader you probably know already. If you don't, [Khan Academy](https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/what-is-modular-arithmetic) has a decent article.)

What're going to do is calculate the array index as simply `arrayIndex = inputColour mod base`. Because we're using modulo, we know that calculated array indexes can never exceed the base of the modulo function. This puts a hard limit on the maximum length of the array. We further choose an appropriate base such that none of the calculated array indexes overlap for the input colours in the image. We want to choose the base that gives us the smallest modulo base possible which means our final array can be as small as possible. We're going to assume all input colours are remappable for the purposes of choosing a base otherwise we might end up in a situation where we have an array index collision leading to the wrong colours being swapped.

Getting an output colour is as simple as `outputColour = array[inputColour mod base]`. This is fast for the GPU to calculate in a fragment shader and doesn't require any image pre-processing. We can do some additional work to improve on this equation to reduce the array size a little bit but both synthetic tests and real world use has demonstrated to me that it's not worth the extra effort.

Actually finding the right modulo base is a process of brute force, or at least I haven't found a good way of finding the best base without an exaustive search. As a result, this isn't a quick process and takes enough time that you won't want to be doing it every frame. The good news is that it only needs to happen once per target colour array and any results can be cached for use later. Potentially these results can even be pre-computed before compiling the game.

Something to point out here is that the array indexes generated by this method will be spaese, unordered, and non-consecutive. Part of the trade-off of using the modulo solution is not having 100% memory efficiency and there is typically some space between entries in the array. In reality this doesn't matter and an implementation of the colour modulo technique will hide the quirky nature of the target and output colour arrays from the user.

&nbsp;

## Look-up Textures

I've been using the word "array" a lot but a colour modulo solution will regularly require an array that is larger than a shader can support (the same often applies to colour index solutions too in practice). If you use an array to contain output colours then, due to the amount of empty space that is typical in the output colour array, you'll hit a limit on how many uniform registers you can use. To make matters worse, where that limit is depends on the hardware you're testing on. In reality, an array is unlikely to be suitable to contain the output colours. Instead, we can use a "look-up texture" instead of an array, also called a "LUT". Look-up textures are slower to access than an array but without them the colour modulo solution wouldn't be viable.

In GameMaker, we could either use a sprite to contain this look-up texture or - more practically - we can use a surface. We make the look-up texture available to the palette swap shader by binding it as a sampler. For the implementation in this repo, each row of the surface is an entry in an array where the index of the array is the y-axis in the surface. Multiple palette can be stored on the surface by using different columns, effectively making the surface a 2D array.

&nbsp;

## GLSL ES 1.00 Makes Life Hard

*If you're not using GameMaker (And you still found this repo! Hi there) then you can skip this bit and use a straight-forward implementation. You'll be fine.*

Whilst the colour modulo technique is sound in principle, unfortunately GameMaker's humiliatingly old version of GLSL ES prevents us from using integer modulo in a shader. This means that we have to rely on floating point numbers to be precise when working with integers. Floating point numbers are well known to have devious accuracy and precision issues. Older mobile GPUs especially have problems with this - even when forcing high precision such that we're stuffing a 24-bit integer into a 32-bit float you'll still often run into problems. The naive implementation of colour modulo is tnus unlikely to work reliably in the wild. Fortunately there are some fun modular arithmetic tricks we can do to work around loss of precision.

Here's the naive implementation where we use floats instead of integers:

```
vec4 inputSample = texture2D(gm_BaseTexture, v_vTexcoord);
float colourInteger = (255.0*inputSample.r) + (256.0*255.0*inputSample.g) + (256.*256.0*255.0*inputSample.b);
float moduloValue = mod(colourInteger, u_fModulo);
```

Rewriting this to work around precision issues isn't immediately obvious but if we apply the following identities then we can start to get somewhere:

```
Addition:
(X + Y) mod A = ((X mod A) + (Y mod A)) mod A

Addition (3)
(X + Y + Z) mod A = ((X mod A) + (Y mod A) + (Z mod A)) mod A

Multiplication:
(X * Y) mod A = ((X mod A) * (Y mod A)) mod A

Final Equation:
(255*Red + 256*255*Green + 256*256*255*Blue) mod A = (I*(Red mod A) + J*(Green mod A) + K*(Blue mod A)) mod A
where I = (255 mod A)
where j = (256*255 mod A)
where K = (256*256*255 mod A)
```

Now we've broken down the problem into a set of small modulo operations that are operating over a smaller range of values then we're far more likely to be working within the precision limits that lower-than-high precision floats afford us. Here's what the actual GLSL code looks like in practice:

```
vec4 inputSample = texture2D(gm_BaseTexture, v_vTexcoord);
vec3 moduloVector = u_vModulo.rgb*modV(255.0*inputSample.rgb, u_vModulo.a);
float moduloValue = mod(moduloVector.r + moduloVector.g + moduloVector.b, u_vModulo.a);
```

There're two new tokens introduced here: `modV()` and `moduloVector`. `modV()` is just a function that applies a modulo per component of a vector which some extra rounding to cope with near-integer floating point numbers. `u_vModulo` is a bit spicier. Its `a` component is the colour modulo as described in previous sections of this article. The `rgb` components are the `IJK` terms calculated above. By describing these three terms as a 3-component vector we can make this shader a little more efficient which is always helpful. We calculate `u_vModulo` outside the shader for convenience as well as to avoid any further precision problems. Note that the factor of `255.0` has been moved around - this seems to lead to better stability in edge cases from my limited testing. Your mileage may vary.

&nbsp;

## Putting It All Together

Once a suitable modulo has been found, we've written some code to read colours out from a look-up texture, and the precision issues have been sorted out we're pretty much done. The only thing left to do is write a nice API around this thing and sling it into a project. I won't go into much detail here about what a decent API would look like because I've written a reference implementation with such an API already. Something to note is that I've found adding a nice debug mode to the palette swapper to be beneficial to quickly identify missing or undefined colours. I recommend doing the same.

Further work in this area may be related to using a larger look-up texture, perhaps a similar size to a colour grading LUT, to cope with palette swapping for non-pixel art graphics.

At any rate, colour modulo has been useful in my workplace to alleviate the workload on artists whilst still achieving the same open-ended goals with good performance. Use it well.

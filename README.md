[![Actions Status](https://github.com/raku-community-modules/Image-Resize/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/Image-Resize/actions) [![Actions Status](https://github.com/raku-community-modules/Image-Resize/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/Image-Resize/actions)

NAME
====

Image::Resize - Resize images using GD

SYNOPSIS
========

```raku
use Image::Resize;

# Create a mini-me 1/10th your size
resize-image("me.png", "mini-mi.jpg", 0.1);

# Resize to exactly 400x400 pixels.
resize-image("original.jpg", "resized.gif", 400, 400);

# scale to height 150px, adjust the width accordingly
scale-to-height("me.jpg", "thumbnail.jpg", 150);

# scale to width 150px, adjust the height accordingly
scale-to-width("me.jpg", "thumbnail.jpg", 150);
```

DESCRIPTION
===========

The `Image::Resize` module exports 3 subroutines, each of which take a path to the image file that needs to be resize as the first positional argument, and a path where the resized image should be stored as the second positional argument.

Can read bmp, jpg, png and gif images and store the image in any format (depending on the extension specified for the destination file).

Can also specify the named argument `:no-resample`, which will disable resampling (using "smooth" copying from a large image to a smaller one, using a weighted average of the pixels).

When copying to a jpeg image, you can also specify the named argument `:jpeg-quality` to change the quality of the resized image. The value should be 0 .. 95. A negative value will set it to default jpeg value of GD.

SUBROUTINES
===========

resize-image
------------

```raku
# Create a mini-me 1/10th your size
resize-image("me.png", "mini-mi.jpg", 0.1);

# Resize to exactly 400x400 pixels.
resize-image("original.jpg", "resized.gif", 400, 400);
```

Resizes the image by a given factor (if only a third positional argument specified) or to a given width and height in pixels (if two positional arguments specified).

scale-to-height
---------------

```raku
# scale to height 150px, adjust the width accordingly
scale-to-height("me.jpg", "thumbnail.jpg", 150);
```

Resizes the image to the given height in pixels while preserving the aspect ratio.

scale-to-width
--------------

```raku
# scale to width 150px, adjust the height accordingly
scale-to-width("me.jpg", "thumbnail.jpg", 150);
```

Resizes the image to the given width in pixels while preserving the aspect ratio.

AUTHORS
=======

  * Dagur Valberg Johannsson

  * Raku Community

Source can be located at: https://github.com/raku-community-modules/Image-Resize . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2013 - 2018 Dagur Valberg Johannsson

Copyright 2024, 2026 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


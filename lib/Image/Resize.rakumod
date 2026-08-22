use GD::Raw:ver<0.8+>:auth<zef:raku-community-modules>;

my constant %ext-to-func =
  bmp  => &gdImageCreateFromBmp,
  jpg  => &gdImageCreateFromJpeg,
  jpeg => &gdImageCreateFromJpeg,
  gif  => &gdImageCreateFromGif,
  png  => &gdImageCreateFromPng
;

my class Image::Resize {
    has Str           $!img-path is built;
    has gdImageStruct $!src-img;

    method new(Cool:D $img-path) {
        $img-path.IO.e
          ?? self.bless(:$img-path)
          !! die "File '$img-path' does not exist"
    }

    submethod TWEAK() { self!open-src() }

    method scale-to-width(Cool $dst-path, Int $width, :$no-resample, :$jpeg-quality) {
        my $w = gdImageSX($!src-img);
        my $h = gdImageSY($!src-img);
        my $factor = $width / $w;

        self.resize($dst-path, $width, ($h * $factor).Int, :$no-resample, :$jpeg-quality);
    }

    method scale-to-height(Cool $dst-path, Int $height, :$no-resample, :$jpeg-quality) {
        my $w = gdImageSX($!src-img);
        my $h = gdImageSY($!src-img);
        my $factor = $height / $h;

        self.resize($dst-path, ($w * $factor).Int, $height, :$no-resample, :$jpeg-quality);
    }

    multi method resize(Cool $dst-path, $factor,
        :$no-resample, :$jpeg-quality) {

        my $w = gdImageSX($!src-img);
        my $h = gdImageSY($!src-img);

        self.resize($dst-path, ($w * $factor).Int, ($h * $factor).Int, :$no-resample, :$jpeg-quality);
    }

    multi method resize(Cool $dst-path,
            Int $new-width, Int $new-height,
            :$no-resample, :$jpeg-quality is copy) {

        $jpeg-quality //= -1;

        my $w = gdImageSX($!src-img);
        my $h = gdImageSY($!src-img);

        my $resized = gdImageCreateTrueColor($new-width, $new-height);
        die "Unable to create a resized image {$new-width}x{$new-height}"
            unless $resized;

        ($no-resample ?? &gdImageCopyResized !! &gdImageCopyResampled)(
          $resized, $!src-img, 0, 0, 0, 0, $new-width, $new-height, $w, $h
        );

        self!save-img($resized, $dst-path, :$jpeg-quality);
        gdImageDestroy($resized);

        self
    }


    method !get-ext($path) {
        $path.IO.basename ~~ /'.' (\w+)/;
        my str $ext = $0.Str.lc;
        die "Path '$path' is missing image extension (.png, .jpg etc.)"
            unless $ext;

        die "Unsupported image extension '$ext' in $path"
            unless %ext-to-func{$ext};

        $ext
    }

    method !open-src {

        $!img-path or die "no image path";
        my $fh = fopen($!img-path, "rb")
            or die "unable to open $!img-path for reading";

        my $ext = self!get-ext($!img-path);

        {
            $!src-img = %ext-to-func{$ext}($fh) or {
                    fclose($fh);
                    die "unable to load $!img-path as $ext";
                }();
        }

        fclose($fh);
    }


    method !save-img($img, $dst-path, Int :$jpeg-quality!) {

        my $imgh = fopen($dst-path, "wb")
            or die "Unable top open '$img' for writing";

        my $ext = self!get-ext($dst-path);

        given ($ext) {
            when any <jpg jpeg> {
                gdImageJpeg($img, $imgh, $jpeg-quality);
            }
            when 'bmp' {
                gdImageBmp($img, $imgh, 0);
                CATCH { default { die "Unable to save in format bmp with your libgd" } }
            }
            when 'png' { gdImagePng($img, $imgh) }
            when 'gif' { gdImageGif($img, $imgh) }
            default { die "'$ext' not implemented" }
        }
        fclose($imgh);
    }

    method DESTROY {
        gdImageDestroy($!src-img) if $!src-img;
        $!src-img = Nil;
    }

    method clean {
        gdImageDestroy($!src-img) if $!src-img;
        $!src-img = Nil;
    }
}

proto sub resize-image(|) is export {*}
multi sub resize-image(
  Cool:D  $src-img,
  Cool:D  $dst-img,
          $new-width,
          $new-height,
        :$no-resample,
        :$jpeg-quality
) {
    Image::Resize.new($src-img).resize(
      $dst-img, $new-width, $new-height, :$no-resample, :$jpeg-quality
    ).clean
}

multi sub resize-image(
  Cool:D  $src-img,
  Cool:D  $dst-img,
          $factor,
         :$no-resample,
         :$jpeg-quality
) {
    Image::Resize.new($src-img).resize(
      $dst-img, $factor, :$no-resample, :$jpeg-quality
    ).clean
}

sub scale-to-width(
  Cool:D  $src-img,
  Cool:D  $dst-path,
  Int:D   $width,
         :$no-resample,
         :$jpeg-quality
) is export {
    Image::Resize.new($src-img).scale-to-width(
      $dst-path, $width, :$no-resample, :$jpeg-quality
    ).clean
}

sub scale-to-height(
  Cool:D  $src-img,
  Cool:D  $dst-path,
  Int:D   $height,
         :$no-resample,
         :$jpeg-quality
) is export {
    Image::Resize.new($src-img).scale-to-height(
      $dst-path, $height, :$no-resample, :$jpeg-quality
    ).clean
}

=begin pod

=head1 NAME

Image::Resize - Resize images using GD

=head1 SYNOPSIS

=begin code :lang<raku>

use Image::Resize;

# Create a mini-me 1/10th your size
resize-image("me.png", "mini-mi.jpg", 0.1);

# Resize to exactly 400x400 pixels.
resize-image("original.jpg", "resized.gif", 400, 400);

# scale to height 150px, adjust the width accordingly
scale-to-height("me.jpg", "thumbnail.jpg", 150);

# scale to width 150px, adjust the height accordingly
scale-to-width("me.jpg", "thumbnail.jpg", 150);

=end code

=head1 DESCRIPTION

The C<Image::Resize> module exports 3 subroutines, each of which take
a path to the image file that needs to be resize as the first positional
argument, and a path where the resized image should be stored as the
second positional argument.

Can read bmp, jpg, png and gif images and store the image in any format
(depending on the extension specified for the destination file).

Can also specify the named argument C<:no-resample>, which will disable
resampling (using "smooth" copying from a large image to a smaller one,
using a weighted average of the pixels).

When copying to a jpeg image, you can also specify the named argument
C<:jpeg-quality> to change the quality of the resized image.  The value
should be 0 .. 95.  A negative value will set it to default jpeg value
of GD.

=head1 SUBROUTINES

=head2 resize-image

=begin code :lang<raku>

# Create a mini-me 1/10th your size
resize-image("me.png", "mini-mi.jpg", 0.1);

# Resize to exactly 400x400 pixels.
resize-image("original.jpg", "resized.gif", 400, 400);

=end code

Resizes the image by a given factor (if only a third positional
argument specified) or to a given width and height in pixels (if
two positional arguments specified).

=head2 scale-to-height

=begin code :lang<raku>

# scale to height 150px, adjust the width accordingly
scale-to-height("me.jpg", "thumbnail.jpg", 150);

=end code

Resizes the image to the given height in pixels while preserving
the aspect ratio.

=head2 scale-to-width

=begin code :lang<raku>

# scale to width 150px, adjust the height accordingly
scale-to-width("me.jpg", "thumbnail.jpg", 150);

=end code

Resizes the image to the given width in pixels while preserving
the aspect ratio.

=head1 AUTHORS

=item Dagur Valberg Johannsson
=item Raku Community

=head1 COPYRIGHT AND LICENSE

Copyright 2013 - 2018 Dagur Valberg Johannsson

Copyright 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4

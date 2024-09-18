# strawberry

A Mac-only rotation-based compression tool for (potentially) superior compression compared to other tools' default implementations.

## Usage

First make `strawberry.sh` executable by running:

```bash
chmod +x strawberry.sh
```

Next, run strawberry on your image.
The tool creates a newly compressed image, leaving the input image unmodified.

```bash
./strawberry.sh <input.jpg>
```

## Seeing image quality

The quality of the jpeg can be determined using ImageMagick like so:

```bash
identify -format "%Q" <input.jpg>
```

## Compared to other tools

ImageMagick

```bash
magick <input.jpg> -quality 93 <output-magick.jpg>
```

sips

```bash
sips -s formatOptions 75 <input.jpg> --out <output-sips.jpg>
```

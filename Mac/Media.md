# Media

This should be everything I need to know about managing media—be it videos,
photos, music, or anything else—on my Mac.

## EyeD3

[EyeD3](https://eyed3.readthedocs.io/en/latest/#) is a tool for managing ID3
tags on media files, especially audio files.

First, install it:
```
$ brew install eye-d3
```

The main thing I keep it for is
[removing unnecessary DRM frames](https://www.calvinallen.net/remove-drm-from-google-play-music/)
from .mp3 files, like the DRM on Google Play Music purchases.
You can do this like so:

```
$ eyeD3 --remove-frame PRIV ./
```

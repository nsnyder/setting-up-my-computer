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

## Ripping Subtitles from VOBSUB to SRT

Use MakeMKV to rip the discs. Then open Subler. In Subler:
File > Open > Select Only Subtitle Track > Add > File > Save

Then use FFMPEG to convert the *.m4v file to *.srt. For example:

```bash
$ ffmpeg -i S07E10\ The\ Final.m4v S07E10\ The\ Final.en.srt 
```

In order to run the above for all *.m4v files at once, the following can be used:

```bash
$ for FILENM in *.m4v; do ffmpeg -i $FILENM ${FILENM/.m4v/}.en.srt; done;
```

### Common Replacements

```
_ => .
```

```
II => "
```

```
I => ' (Check "SI " instead of just "I")
```

```
J’ => ♪
```

```
N’ => ♪♪
```

```
| => I
```

This regex replace.
```
([^\d:])0([^\d:]) => $1O$2
```

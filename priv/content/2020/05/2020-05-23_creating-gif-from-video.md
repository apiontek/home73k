---
%{
  title: "Creating a gif from a video",
  id: "creating-gif-from-video",
  date: ~D[2020-05-23],
  author: "Adam Piontek",
  tags: ["cli", "ffmpeg ", "gif", "multimedia", "video", "notes"],
}
---

As a personal note, since I've done it for family a few times now, here are steps one can use to create a gif from a longer video. <!--more-->

### Stage 1: trim out a short video clip

Use ffmpeg to trim out the part you want. It's ok to grab more than you need, you can trim it further in the next stage, but you don't want to upload a massive video to the gif site, so best to trim a small bit first:

```shell
ffmpeg -ss 00:14:23 -t 4 -i "/path/to/source/video.mkv" \
  -c:v copy -an "output_video_clip.mp4"
```

- `-ss` is the timecode you want to start from
- `-t` is the ultimate duration of the clip you want, so, seconds from start time
- `-an` tells it to discard audio since you ultimately want a gif

Sometimes merely copying doesn't work, due to keyframes in the source or whatever. It's ok to re-encode, here's an example with higher-quality settings since it's just a small clip:

```shell
ffmpeg -ss 00:14:23 -t 4 -i "/path/to/source/video.mkv" \
  -c:v libx264 -preset veryslow -crf 16 -an "output_video_clip.mp4"
```

### Stage 2: modify online

I've been using [Kapwing](https://www.kapwing.com/) to create gifs. You can trim more, add subtitles, crop, etc.

Default options tend to create pretty big gifs, so it's a really good idea to set the output size to a custom scale, say, no bigger than 480 on the longest edge? Also a good idea to crop it if there's unecessary stuff.

Scaled properly, then using Settings of "Output: GIF" and "Quality: High" should get pretty good results.

However, if you want to try using ffmpeg to generate the gif, set "Output: Default" for an MP4 file, and try the optional 3rd stage:

### (Optional) Stage 3: convert MP4 to gif

Using the Kapwing MP4 output, here's how to convert to gif with ffmpeg, using 2 passes with a color pallette to get better quality:

```shell
vidname="final_kapwing_video_name"
fps="20"
scale="500"
palette="/tmp/palette.png"
filters="fps=${fps},scale=${scale}:-1:flags=lanczos"
ffmpeg -i "${vidname}.mp4" -vf "$filters,palettegen" -y $palette
ffmpeg -i "${vidname}.mp4" -i $palette \
  -filter_complex "$filters &#91;x]; &#91;x]&#91;1:v] paletteuse" \
  "${vidname}.fps${fps}.scale${scale}.gif"
```

You can play around with the fps &amp; scale to adjust the size but this should give a decent result.

### Final note:

In future, it might be worth exploring doing the 2nd part, or the 1st &amp; 2nd parts, with a video editor like Shotcut or OneShot …. but for now, I'm familiar with Kapwing and it's pretty easy.

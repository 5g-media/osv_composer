#!/bin/bash

mkdir ffmpeg-example && cd ffmpeg-example
capstan package init --name ffmpeg-example --title ffmpeg-example --author example --require osv.ffmpeg
capstan package compose --run "/ffmpeg.so -formats" -s 1G ffmpeg-example
echo "run locally with: capstan run ffmpeg-example -f 8080:8080"

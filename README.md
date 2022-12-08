# prov-ffmpeg
ffmpeg package builder for providence

## Code generation for the base code

Assuming you are in the root of `providence` repo and `OUTDIR=<root of this repo>`

```
cd pipeline/platforms/centos

# For centos7 base
# checkout `centos7` branch of this repo
../tools/builder/createSource --target centos7 --output "$OUTDIR" --getDeps ffmpeg

# For centos6 base
# checkout `centos6` branch of this repo
../tools/builder/createSource --target centos6 --output "$OUTDIR" --getDeps ffmpeg
```

Note that this is *only to generate the base* resources files in `centos7` and `centos6`. The original of the modified files are backed with `.ORG` extension.

# speedtest  in docker

This is speedtest-cli with gnuplot.


## Usage

```
docker run -d --net=host \
	-v <data dir on host>:/data derflocki/speedtest-pot
```
> We don't actually _require_ `--net=host`, but if we're wanting to test native performance then we want direct access to the relevant connections without any overhead.
> 
> -- https://hub.docker.com/r/tianon/speedtest/

Build image

```sh
docker build . -t cncnet-server-image
```

Run container

* `-d` as daemon (detached)
* `-p` publish default ports

```sh
docker run -d -p 50001:50001 -p 50000:50000 cncnet-server-image # server args go here #
```

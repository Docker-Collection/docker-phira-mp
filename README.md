# Docker Phira MP

This is [Phira Multiplayer][phira-mp] server docker image.

## Docker Compose

```yml
version: "3"

services:
  phira_mp:
    container_name: phira_mp
    image: ghcr.io/docker-collection/phira-mp:latest
    ports:
      - 8080:12346
    # environment:
    #   PORT: 12346
```

## Reference

- [Phira][phira]
- [TeamFlos/phira-mp][phira-mp]

[phira]: https://github.com/TeamFlos/phira
[phira-mp]: https://github.com/TeamFlos/phira-mp
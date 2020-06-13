FROM debian:stretch as builder

RUN apt-get update \
    && apt-get install -y wget unzip cpio \
    && export serverUrl=$(wget --spider -nd -l1 -r -A "*terraria-server*" https://terraria.org/about 2>&1 | grep '^--' | awk '{ print $3 }' | grep 'terraria-server' | cut -d '?' -f1) \
    && wget -q "$serverUrl" -O "/tmp/terraria-server.zip" \
    && unzip "/tmp/terraria-server.zip" -d "/tmp/terraria-server-stage" \
    && mv -f "$(find "/tmp/terraria-server-stage" -type d -name "Linux" -print)" "/tmp/ts-bin"

FROM mono:slim as server

COPY --from=builder /tmp/ts-bin /terraria-server

RUN chmod +x /terraria-server/TerrariaServer \
    && chmod +x /terraria-server/TerrariaServer.bin*

EXPOSE 7777

WORKDIR /terraria-server

ENTRYPOINT [ "./TerrariaServer.bin.x86_64" ]

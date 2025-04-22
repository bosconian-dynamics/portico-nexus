FROM gameservermanagers/gameserver:sdtd



COPY config/lgsm/ /data/config-lgsm/sdtdserver/
COPY build/ /tmp/build/

RUN chmod -R +x /tmp/build && \
    /tmp/build/entrypoint.sh && \
    rm -rf /tmp/build

EXPOSE 26900/tcp 26900/udp 26901/udp 26902/udp 26903/udp

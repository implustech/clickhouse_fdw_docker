FROM postgres:11.5-alpine as build

RUN echo 'http://dl-3.alpinelinux.org/alpine/edge/main' > /etc/apk/repositories; \
    apk --no-cache add curl python3 gcc g++ make musl-dev openssl-dev cmake curl-dev util-linux-dev;\
    chmod a+rwx /usr/local/lib/postgresql && \
    chmod a+rwx /usr/local/share/postgresql/extension && \
    mkdir -p /usr/local/share/doc/postgresql/contrib && \
    chmod a+rwx /usr/local/share/doc/postgresql/contrib

RUN wget -c https://github.com/implustech/clickhouse_fdw/archive/master.zip && \
    unzip master.zip && \
    cd clickhouse_fdw-master && mkdir build && cd build && cmake .. && make && make install

FROM postgres:11.5-alpine as install
RUN echo 'http://dl-3.alpinelinux.org/alpine/edge/main' > /etc/apk/repositories; \
    apk --no-cache add libcurl 
COPY --from=build /usr/local/lib/postgresql/clickhouse_fdw.so /usr/local/lib/postgresql/libclickhouse.so /usr/local/lib/postgresql/
COPY --from=build /usr/local/share/postgresql/extension/clickhouse_fdw--1.0.sql /usr/local/share/postgresql/extension/clickhouse_fdw.control /usr/local/share/postgresql/extension/



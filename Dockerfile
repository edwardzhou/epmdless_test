
# ---------------------------------------------------------
# 准备干净的最小化运行环境
# 安装了 tzdata 时区数据， bash, openssl支持 curl telnet
# 并把运行时区设置为 上海
FROM alpine:3.15.0 as app_base

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk upgrade \
 && apk update \
 && apk add ncurses-libs \
        tzdata \
        bash \
        openssl \
        curl \
        busybox-extras \
        libstdc++ \
 && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && echo "Asia/Shanghai" > /etc/timezone

# 默认shell改为bash
RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd


# 准备elixir构建环境
FROM elixir:1.13.3-alpine as app_builder

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk upgrade \
 && apk update \
 && apk add --upgrade apk-tools \
 && apk upgrade \
 && apk update \
 && apk add \
   git \
   build-base \
   alpine-sdk \
   coreutils \
   curl \
   openssh \
   tzdata \
   rsync \
 && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && echo "Asia/Shanghai" > /etc/timezone

# 默认shell改为bash
RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

# 准备erlang包管理工具
RUN mix local.hex --force \
 && mix local.rebar --force


ARG MIX_ENV
ENV MIX_ENV=${MIX_ENV:-"prod"}
ARG APP_ROOT
ENV APP_ROOT=${APP_ROOT:-"/app"}

WORKDIR /app
COPY . /app

COPY rel/deps_get.sh /app/
COPY rel/start_iex.sh /app/

ARG BUILD_HTTPS_PROXY
RUN echo "\${BUILD_HTTPS_PROXY}: ${BUILD_HTTPS_PROXY}"
RUN ./deps_get.sh
RUN mix release


EXPOSE 17012

# ---------------------------------------------------------
# 打包成最终镜像
FROM app_base

# 支持通过构建命令行指定 MIX_ENV, 并固化到环境变量中, 缺省为 prod
# ARG不会跨层传递，此处需要重新指定

ARG MIX_ENV
ENV MIX_ENV=${MIX_ENV:-"prod"}
ARG APP_ROOT
ENV APP_ROOT=${APP_ROOT:-"/app"}

RUN echo "DEBUG: MIX_ENV => ${MIX_ENV}"
RUN echo "DEBUG: APP_ROOT => ${APP_ROOT}"

WORKDIR ${APP_ROOT}

COPY --from=app_builder ${APP_ROOT}/_build/$MIX_ENV/rel/epmdless_test .
COPY rel/start_iex.sh /app/

CMD [ "./start_iex.sh" ]
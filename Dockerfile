# ---------------------------------------------------------
# 准备干净的最小化运行环境
# 安装了 tzdata 时区数据， bash, openssl支持 curl telnet
# 并把运行时区设置为 上海
FROM registry2.leangoo.com:4443/library/alpine_base:3.14.2 as app_base

FROM registry2.leangoo.com:4443/library/elixir_base:1.13.3-alpine as app_builder

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
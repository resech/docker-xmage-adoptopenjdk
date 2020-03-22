# Based on AdoptOpenJDK JRE8 Nightly Image
FROM adoptopenjdk/openjdk8:jre8u-alpine-nightly

# Build and config ENVs

ENV JAVA_MIN_MEMORY=256M \
    JAVA_MAX_MEMORY=2G \
    JAVA_EXTENDED_OPTIONS="-XX:MaxPermSize=256m" \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8' \
    XMAGE_DOCKER_SERVER_ADDRESS="0.0.0.0" \
    XMAGE_DOCKER_PORT="17171" \
    XMAGE_DOCKER_SEONDARY_BIND_PORT="17179" \
    XMAGE_DOCKER_MAX_SECONDS_IDLE="600" \
    XMAGE_DOCKER_AUTHENTICATION_ACTIVATED="false" \
    XMAGE_DOCKER_SERVER_NAME="My XMage Server" \
    XMAGE_DOCKER_ADMIN_PASSWORD="hunter2" \
    XMAGE_DOCKER_MAX_GAME_THREADS="10" \
    XMAGE_DOCKER_MIN_USERNAME_LENGTH="3" \
    XMAGE_DOCKER_MAX_USERNAME_LENGTH="14" \
    XMAGE_DOCKER_MIN_PASSWORD_LENGTH="8" \
    XMAGE_DOCKER_MAX_PASSWORD_LENGTH="100" \
    XMAGE_DOCKER_MAILGUN_API_KEY="X" \
    XMAGE_DOCKER_MAILGUN_DOMAIN="X" \
    XMAGE_DOCKER_SERVER_MSG="Hello! \nWelcome to $XMAGE_DOCKER_SERVER_NAME" \
    XMAGE_DOCKER_MADBOT_ENABLED=0

#Build and Configure Container
WORKDIR /xmage

RUN set -ex && \
    apk -U upgrade && \
    apk add curl ca-certificates jq && \ 
    curl --silent --show-error http://xmage.de/xmage/config.json | jq '.XMage.location' | xargs curl -# -L > xmage.zip \
    && unzip xmage.zip -x "mage-client*" \
    && rm xmage.zip \
    && apk del curl jq

COPY dockerStartServer.sh /xmage/mage-server/

RUN chmod +x \
    /xmage/mage-server/startServer.sh \
    /xmage/mage-server/dockerStartServer.sh

EXPOSE $XMAGE_DOCKER_PORT $XMAGE_DOCKER_SEONDARY_BIND_PORT

WORKDIR /xmage/mage-server

CMD [ "./dockerStartServer.sh" ]

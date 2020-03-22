# XMage Server based on Alpine & AdoptOpenJDK

Based heavily on the work done by [LunarNightShade](https://github.com/LunarNightShade/docker-xmage-openjdk). I've updated the base image to use the AdoptOpenJDK nightly builds and added a few more configuration variables.

## Usage
```
docker run -d -it --rm \
    --name XMage \
    -p 17171:17171 \
    -p 17179:17179 \
    --add-host example.com:0.0.0.0 \
    -e "XMAGE_DOCKER_SERVER_ADDRESS=example.com" \
    --restart unless-stopped \
    resech/docker-xmage-adoptopenjdk
```

XMage needs to know the domain name the server is running on. The `--add-host` option adds an entry to the containers `/etc/hosts` file for this domain. Replace `example.com` with your server IP address or domain name address.  
Using the `XMAGE_*` environment variables you can modify the `config.xml` file.  
You should always set `XMAGE_DOCKER_SERVER_ADDRESS` to the same value as your `--add-host` flag value.  

---

## Available Environment Variables and Default Values

+ JAVA_MIN_MEMORY=256M
+ JAVA_MAX_MEMORY=2G
+ JAVA_EXTENDED_OPTIONS="-XX:MaxPermSize=256m"
+ LANG='en_US.UTF-8'
+ LANGUAGE='en_US:en'
+ LC_ALL='en_US.UTF-8'
+ XMAGE_DOCKER_SERVER_ADDRESS="0.0.0.0"
+ XMAGE_DOCKER_PORT="17171"
+ XMAGE_DOCKER_SEONDARY_BIND_PORT="17179"
+ XMAGE_DOCKER_MAX_SECONDS_IDLE="600"
+ XMAGE_DOCKER_AUTHENTICATION_ACTIVATED="false"
+ XMAGE_DOCKER_SERVER_NAME="My XMage Server"
+ XMAGE_DOCKER_ADMIN_PASSWORD="hunter2"
+ XMAGE_DOCKER_MAX_GAME_THREADS="10"
+ XMAGE_DOCKER_MIN_USERNAME_LENGTH="3"
+ XMAGE_DOCKER_MAX_USERNAME_LENGTH="14"
+ XMAGE_DOCKER_MIN_PASSWORD_LENGTH="8"
+ XMAGE_DOCKER_MAX_PASSWORD_LENGTH="100"
+ XMAGE_DOCKER_MAILGUN_API_KEY="X"
+ XMAGE_DOCKER_MAILGUN_DOMAIN="X"
+ XMAGE_DOCKER_SERVER_MSG=""
+ XMAGE_DOCKER_MADBOT_ENABLED=0

---

If you would like to preserve the database during updates and restarts you can mount a volume at `/xmage/mage-server/db` (Important if you're using user authentication). 

Add `--mount source=xmage-db,target=/xmage/mage-server/db` to your `docker run` command.

---

## Advanced Docker Run Configuration

If you'd like to keep the Player AI enabled, set `XMAGE_DOCKER_MADBOT_ENABLED` to `1`. It's disabled by default as the AI can consume a lot of resources, I'd recommend leaving it disabled unless you have a specific reason to enable it. This doesn't effect the Draftbot, which is always enabled.

You should **ALWAYS** change the admin password, you can do that with the `XMAGE_DOCKER_ADMIN_PASSWORD` variable.

`JAVA_EXTENDED_OPTIONS` can get you in trouble so don't change it unless you know what you are doing. With that said, I've noticed better performance using the G1 Garbage Collector instead of the default CMS collector. Here's how I have the collector setup (assuming a `JAVA_MAX_MEMORY` of 2G): `"JAVA_EXTENDED_OPTIONS=-XX:+UseG1GC -XX:+UseStringDeduplication -XX:G1HeapRegionSize=1m"`. 

`XMAGE_DOCKER_SERVER_MSG` can be used to customise the contents of `server.msg.txt`. This setting actually clobbers the default file so you'll have to recreate it in the variable if you only want to add to the contents. You can use `\n` to add newlines, each line is a message. For example, this would create 3 lines in `server.msg.txt`: `"XMAGE_DOCKER_SERVER_MSG=This is line 1 \nThis is line 2 \nThis is line 3"`. By default we'll just use the original file without modification. 

So an advanced Docker Run Configuration with the G1 Garbage Collector and AI enabled would look like this:
```
docker run -d -it --rm \
    --name XMage \
    -p 17171:17171 \
    -p 17179:17179 \
    --add-host example.com:0.0.0.0 \
    -e "XMAGE_DOCKER_SERVER_ADDRESS=example.com" \
    -e 'XMAGE_DOCKER_ADMIN_PASSWORD=My$up3rS3cR3+P@$$W0rD' \
    -e "JAVA_MIN_MEMORY=256M" \
    -e "JAVA_MAX_MEMORY=2G" \
    -e "JAVA_EXTENDED_OPTIONS=-XX:+UseG1GC -XX:+UseStringDeduplication -XX:G1HeapRegionSize=1m" \
    -e "XMAGE_DOCKER_SERVER_MSG=resech's XMage Server \nHave fun." \
    -e "XMAGE_DOCKER_MADBOT_ENABLED=1" \
    --mount source=xmage-db,target=/xmage/mage-server/db \
    resech/docker-xmage-adoptopenjdk
```

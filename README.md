# Repository
* Github [wenerme/repository](https://github.com/wenerme/repository)
* CDN URL [https://repo.wener.me](https://repo.wener.me)
* RAW URL [https://raw.githubusercontent.com/wenerme/repository/master](https://raw.githubusercontent.com/wenerme/repository/master)

## Alpine
* Packages not in mainline version or version is outdated

```bash
# Or manully setup repo
VER=$(egrep -o '^\d+[.]\d+' /etc/alpine-release)
(cd /etc/apk/keys; sudo curl -LO https://repo.wener.me/alpine/wenermail@gmail.com-5dc8c7cd.rsa.pub )
echo https://repo.wener.me/alpine/v${VER}/community | sudo tee -a /etc/apk/repositories

# Or using https://github.com/wenerme/alpine-admin to setup repo
ansible-playbook adhoc.yaml -e 'task=wener-repo' -l myhost
```

### dev
```bash
# setup builder env by https://github.com/wenerme/alpine-admin 
# builder will accessable throw port 2222 account is admin:admin
ansible-playbook adhoc.yaml -e 'role=dev task=builder-create facts=true host_data_path=/data/build' -l hostwithdocker

# setup build by docker run
WD=$PWD
docker run -d \
    -v $WD:/opt/build \
    -v $WD/packages:/home/admin/packages \
    -v $WD/home:/home/admin \
    -v $WD/distfiles:/var/cache/distfiles \
    -v $WD/cache:/etc/apk/cache \
    -p 2222:22 \
    --name build-server wener/app:builder
#
docker exec build-server sudo chown admin:admin /home/admin /opt/build

# enter the build server
ssh admin@127.0.0.1 -p 2222
# or
docker exec -it -u admin -w /opt/build build-server bash

# copy build files
rsync -avz ~/packages/ alpine/v3.11/
```

### pull distfiles by proxy server

```bash
# prepare proxy server
apk add alpin-sdk
adduser $(whoami) abuild

# push package
rsync -avz aports/community/grpc proxy:~/aports/

# pull distfiles in proxy server
ssh proxy 'cd ~/aports/grpc; abuild checksum'

# pull back distfiles
rsync -avz proxy:/var/cache/distfiles/ distfiles/

# remote-checksum <server> <pkg>
remote-checksum(){
    local svr=$1
    local pkg=$2
    
    [ -e aports/community/$pkg ] && rsync -avzP aports/community/$pkg $svr:~/aports/
    [ -e aports/main/$pkg ] && rsync -avzP aports/community/$pkg $svr:~/aports/
    [ -e aports/testing/$pkg ] && rsync -avzP aports/community/$pkg $svr:~/aports/

    ssh $svr "cd ~/aports/$pkg; abuild checksum"
    rsync -avzP $svr:/var/cache/distfiles/ distfiles/
}
```

# Repository
* Github [wenerme/repository](https://github.com/wenerme/repository)
* CDN URL [https://repo.wener.me](https://repo.wener.me)
* RAW URL [https://raw.githubusercontent.com/wenerme/repository/master](https://raw.githubusercontent.com/wenerme/repository/master)

## Alpine
* Packages not in mainline version or version is outdated

```bash
# Or manully setup repo
(cd /etc/apk/keys; sudo curl -LO https://repo.wener.me/alpine/wenermail@gmail.com-5dc8c7cd.rsa.pub )
echo https://repo.wener.me/alpine/v3.10/community | sudo tee -a /etc/apk/repositories

# Or using https://github.com/wenerme/alpine-admin to setup repo
ansible-playbook adhoc.yaml -e 'task=wener-repo' -l myhost
```

### dev
```bash
# setup builder env by https://github.com/wenerme/alpine-admin 
# builder will accessable throw port 2222 account is admin:admin
ansible-playbook adhoc.yaml -e 'role=dev task=builder-create facts=true host_data_path=/data/build' -l hostwithdocker

# copy build files
rsync -avz packages/ alpine/v3.10/
```

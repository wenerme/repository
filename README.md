# Repository

* CDN Url https://repo.wener.me/
* Raw Url https://raw.githubusercontent.com/wenerme/repository/master

## Alpine
* Packages not in mainline version or version is outdated

```bash
# Using https://github.com/wenerme/alpine-admin to setup build env
# builder will accessable throw port 2222
ansible-playbook adhoc.yaml -e 'role=dev task=builder-create facts=true host_data_path=/data/build' -l mydockerhost

# Use this repo
ansible-playbook adhoc.yaml -e 'task=wener-repo' -l myhost

# Or manully setup repo
(cd /etc/apk/keys; sudo curl -LO https://repo.wener.me/alpine/wenermail@gmail.com-5dc8c7cd.rsa.pub )
echo https://repo.wener.me/alpine/v3.10/community | sudo tee -a /etc/apk/repositories
```

### dev
```bash
# copy files
rsync -avz packages/ alpine/v3.10/
```

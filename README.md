# Monorepo using git submodule


```bash
git submodule init
git submodule add -b main https://github.com/diegograssato/nodejs-service.git services/payments
git submodule add https://github.com/diegograssato/nodejs-service.git services/profile

git submodule set-branch --branch main services/profile

```


# Fix podman on wls

```bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

sudo mkdir -p "$XDG_RUNTIME_DIR"
sudo chmod 700 "$XDG_RUNTIME_DIR"
sudo chown -R $(id -u):$(id -g) /run/user/$(id -u)

ls -ld $XDG_RUNTIME_DIR
```
 
 
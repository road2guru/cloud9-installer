# cloud9-installer
Provide single runable script to install Cloud9 - with support custom installation path

### What does script do?
1. Clone cloud9 core source code to local folder
2. Modify `scripts/install-sdk.sh` to set custom installation path. `.c9` folder which contains all required tools will be moved to installtion path instead of `$HOME`. This letting IDE able to be shared cross system users.
3. Modify all required file to user `process.env.C9_DIR` instead of `process.env.HOME` since `.c9` was moved out of `$HOME`.
4. Create a wrapper script (`bin/run.sh`) to start IDE which make use of new env.

### Next step?
* Support multiple undepedent user environments (IDE user, not system user).

Notice:
* To run script behind proxy, remember to set `http_proxy` and `https_proxy` beforehand, otherwise the tooling installation will failed.

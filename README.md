# rogsoft-BetterApps

BetterApps 的 rogsoft 插件仓库。

## 发布约定

- 插件模块名固定使用小写 `betterapps`。
- 二进制文件名固定使用 `BetterApps`。
- 插件源码仓库不提交编译后的二进制文件，二进制通过 release 产物发布。
- `config.json.js` 使用 `binary_url`、`binary_sha256` 描述预编译二进制。
- 本仓库内的 `build.py` 只用于本地开发和本地打包测试。
- 发布服务器不能执行第三方插件仓库里的 `build.py`、`build.sh`、`build_hnd.sh` 等脚本。
- 发布服务器必须使用 `asusgo-build` 中可信的通用构建器读取 `binary_url`，下载并校验二进制后打包。
- BetterApps 必须在目标 rogsoft 仓库的 `softcenter/modules.json` 和 `koolcenter/modules.json` 中声明，不要在 `asusgo-build` 中写 BetterApps 专用逻辑或额外模块清单。

## 当前预编译二进制

`config.json.js` 当前指向：

```text
https://github.com/linkease/rogsoft-BetterApps/releases/download/prebuild/BetterApps-binary-linux-arm64-v0.1.0.tar.gz
```

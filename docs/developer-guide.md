# 仓颉-Python 互操作库开发者指南

## 开源项目介绍

为了兼容强大的计算和 AI 生态，仓颉支持与 Python 语言的互操作调用，仓颉-Python 互操作库为用户提供该能力。

目前 Python 互操作仅支持在 Linux 平台使用，并且仅支持仓颉编译器的 cjnative 后端。

## 安装和使用指导

### 构建准备

1. 开发者需要Linux平台的 `cangjie SDK`，然后，开发者需要执行对应 `SDK` 的 `envsetup` 脚本，确保 `SDK` 被正确配置。
2. 使用 `python` 构建脚本方式编译，请安装 `python3`。

### 构建步骤

1. 克隆本项目。

2. 通过 `build` 目录下的构建脚本编译仓颉-Python 互操作库：

    ```shell
    cd build
    python3 build.py build -t release
    ```

    当前支持 `debug`、`release` 两种编译类型，开发者需要通过 `-t` 或者 `--build-type` 指定。

3. 安装到指定目录：

    ```shell
    python3 build.py install
    ```

    默认安装到 `target` 目录下，支持开发者通过 `install` 命令的参数 `--prefix` 指定安装目录：

    ```shell
    python3 build.py install --prefix ./output
    ```

    编译产物目录结构为:

    ```text
    output/
    |-- py_interop.cjo                         # cjo文件
    |-- libpy_interop.so                       # 共享库文件
    ```

4. 清理编译中间产物：

   ```shell
   python3 build.py clean
   ```

### 更多构建选项

`build.py` 的 `build` 功能提供如下额外选项：
- `--target TARGET`: 指定编译目标产物的运行平台，默认值为 `native`，即本地平台，当前仅支持 `linux` 平台上编译；
- `-t, --build-type BUILD_TYPE`: 指定构建产物版本，可选值为 `debug/release`；
- `-h, --help`: 打印 `build` 功能的帮助信息。

此外，`build.py` 还提供如下额外功能：

- `install [--prefix PREFIX]`: 将构建产物安装到指定路径，不指定路径时默认为 `target/` 目录；`install` 前需要先正确执行 `build`；
- `clean`: 清除默认路径的构建产物；
- `-h, --help`: 打印 `build.py` 的帮助信息。
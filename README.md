# lulu-runtimes

Lulu 桌面应用「本地配音(TTS)」**运行环境包**的构建与发布仓库。

> 本仓库只含运行环境的**构建脚本与 CI**,**不含 Lulu 应用源码**。
> 内容均为公开/开源依赖的打包逻辑,不涉及任何业务代码。

## 这是什么

某些本地 TTS 模型(VoxCPM2 / IndexTTS2 / GPT-SoVITS 等)的运行依赖互相冲突,无法装进同一个程序环境。因此每个模型打成一个**独立、可重定位的运行环境包**:

- 一个可重定位的 Python(基于 [python-build-standalone](https://github.com/astral-sh/python-build-standalone))
- + 该模型推理所需的开源依赖(如 PyTorch、voxcpm)

**模型权重不在此仓库**——由应用从官方 HuggingFace / ModelScope 下载。本仓库只发布"运行环境",用户解压到任意路径即用。

各模型/平台的运行环境包见 **Releases**。

## 构建

macOS Apple Silicon:

```bash
bash build_tts_runtime.sh local_voxcpm2 ./dist
```

CI(GitHub Actions · `workflow_dispatch`)在 macОС runner 上自动构建并发布到 Releases。

## License

打入运行环境的依赖各自遵循其开源许可证(PyTorch=BSD-3、voxcpm=Apache-2.0 等)。本仓库的脚本以 MIT 提供。

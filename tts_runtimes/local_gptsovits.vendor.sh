#!/usr/bin/env bash
# GPT-SoVITS 运行时包的「vendor 源码 + 额外离线资产」钩子。
# 被 build_tts_runtime.sh 调用,环境变量:STAGE(打包暂存根)、PY(运行时解释器)。
# 产出:$STAGE/vendor/GPT-SoVITS(去 .git/示例媒体/空权重占位)+ $STAGE/python/nltk_data。
# 不含模型权重 —— 权重由 App 安装器从官方 HF/ModelScope 另下(见 runtime_packages.py)。
set -euo pipefail

GSV_REPO="https://github.com/RVC-Boss/GPT-SoVITS.git"
GSV_COMMIT="bf81cdb14a38b674b6e9996dabc97340bc9978d2"   # 2026-06 main,spike 实证;升级上游时同步改这里 + 重建包
VENDOR="$STAGE/vendor"

echo "  [vendor] clone GPT-SoVITS @ ${GSV_COMMIT:0:8}"
mkdir -p "$VENDOR"
git clone --quiet --no-checkout "$GSV_REPO" "$VENDOR/GPT-SoVITS"
git -C "$VENDOR/GPT-SoVITS" checkout --quiet "$GSV_COMMIT"
# 瘦身:去 .git、示例音频/视频、文档图片、其它语言整合脚本里的大文件(权重目录本就空)
rm -rf "$VENDOR/GPT-SoVITS/.git"
find "$VENDOR/GPT-SoVITS" -type d -name "__pycache__" -prune -exec rm -rf {} + 2>/dev/null || true
find "$VENDOR/GPT-SoVITS" \( -iname "*.wav" -o -iname "*.mp3" -o -iname "*.flac" \
  -o -iname "*.mp4" -o -iname "*.gif" -o -iname "*.png" -o -iname "*.jpg" \) \
  -size +200k -delete 2>/dev/null || true

echo "  [vendor] 预置 nltk 数据(英文 G2P 需要,放运行时内随包搬迁)"
NLTK_DIR="$STAGE/python/nltk_data"
mkdir -p "$NLTK_DIR"
"$PY" -I -s - "$NLTK_DIR" <<'PYNLTK'
import sys, nltk
d = sys.argv[1]
# nltk.download 失败只返回 False、不抛错 → 逐个校验,缺一即让构建失败(否则会打出缺数据的坏包)
for r in ("averaged_perceptron_tagger_eng", "averaged_perceptron_tagger", "cmudict"):
    if not nltk.download(r, download_dir=d, quiet=True):
        sys.exit(f"✗ nltk 资源下载失败: {r}")
print("    nltk_data ok")
PYNLTK

echo "  [vendor] 完成:$(du -sh "$VENDOR/GPT-SoVITS" | awk '{print $1}') 源码 + nltk_data"

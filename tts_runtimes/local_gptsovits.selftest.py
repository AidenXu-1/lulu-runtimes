"""GPT-SoVITS 运行时包自检:关键依赖可导入 + vendor 源码可被 import(布好 sys.path 后)。

被 build_tts_runtime.sh 用运行时解释器 `-I -s` 跑;失败即不出包。
不加载权重(权重不在包内),只验「能 import 到推理类」。
"""
import os
import sys
from pathlib import Path

# 关键三方依赖
import torch  # noqa: E402
import torchaudio  # noqa: E402
import onnxruntime  # noqa: E402
import opencc  # noqa: E402
import librosa  # noqa: E402
import soundfile  # noqa: E402
import transformers  # noqa: E402

# vendor 源码(裸 import 风格:需 vendor 根 + vendor/GPT_SoVITS 在 sys.path;
# 且 GPT-SoVITS 部分模块按 os.getcwd() 追加 sys.path(如 sv.py 的 eres2net)→ 必须 chdir 到 vendor 根)
stage = Path(os.environ["STAGE"]).resolve()
vendor = stage / "vendor" / "GPT-SoVITS"
os.chdir(vendor)
sys.path.insert(0, str(vendor))
sys.path.insert(0, str(vendor / "GPT_SoVITS"))
from GPT_SoVITS.TTS_infer_pack.TTS import TTS, TTS_Config  # noqa: E402,F401

print(
    f"  自检 OK · torch {torch.__version__} · torchaudio {torchaudio.__version__} · "
    f"mps {torch.backends.mps.is_available()} · transformers {transformers.__version__} · "
    f"GPT-SoVITS import 成功"
)

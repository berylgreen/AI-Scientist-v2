# Title: 结合大语言模型与 3D 高斯溅射的无界三维场景生成 (Unbounded 3D Scene Generation Combining LLMs and 3D Gaussian Splatting)

## Keywords
3D Scene Generation, Gaussian Splatting, Large Language Models, Layout Generation, Unbounded Scenes

## TL;DR
突破单一物体生成的局限，解决如何生成广阔且具有物理、常识逻辑的大型三维场景（如城市街区、复杂室内）的问题。通过 LLM 规划空间布局，结合 3DGS 实现场景级的高质量生成与无缝组合。

## Abstract
现有的大部分 3D 生成工作都集中在单个物体级别，而生成复杂、多物体组成且空间布局合理的大型 3D 场景（Scene-Level Generation）仍处于起步阶段。这不仅要求生成高保真的几何与纹理，还需要模型具备空间常识和物体间的组合逻辑。本课题提出一种结合大语言模型（LLM）和 3D 高斯溅射（3D Gaussian Splatting）的层次化场景生成网络。首先利用 LLM 的世界知识生成符合逻辑的场景布局图（Layout Graph），确定物体种类、尺度及相对空间位置；随后，引导多视角扩散模型生成局部观测，并利用 3DGS 进行场景的快速重建与融合。该方法支持用户通过长文本交互式地编辑和扩展无界场景（Unbounded Scenes），在虚拟现实、游戏场景自动构建、自动驾驶仿真等领域展现出巨大的应用潜力。

## Rules
**系统强制要求：请全程使用中文思考、拓展并输出所有的相关数据。在最终生成和排版实验论文时，必须且只能使用简体中文来进行写作！**

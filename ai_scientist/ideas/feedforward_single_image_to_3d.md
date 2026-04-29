# Title: 基于前馈 Transformer 的极速单图到高质量 3D 重建 (Ultra-Fast Single-Image to High-Quality 3D Reconstruction using Feed-Forward Transformers)

## Keywords
Single-Image to 3D, Feed-Forward Networks, Vision Transformers, Multi-view Diffusion, Real-time Reconstruction

## TL;DR
传统的基于 SDS（Score Distillation Sampling）损失的单图 3D 生成耗时长且容易出现“多面神”问题。本研究探索基于大规模预训练的 Transformer 模型，实现几秒钟内一次性前馈生成高一致性的 3D 资产。

## Abstract
从单张 2D 图像生成 3D 模型在电商展示、UGC 内容创作等领域需求庞大。以往主流的生成方法通常采用 2D 扩散模型结合 SDS 损失通过数万次迭代进行优化，这种“Per-Scene Optimization”范式不仅耗时（通常需要数十分钟），而且由于 2D 模型缺乏 3D 一致性约束，极易产生“多头/多面神”（Janus Problem）或几何崩塌现象。受近期大规模 3D 重建模型（Large Reconstruction Models, LRM）的启发，本研究提出一种新型的前馈（Feed-Forward）3D 视觉 Transformer 架构。通过在大规模 3D 资产数据集上进行预训练，该模型能够直接将单张图像编码为高度结构化的三维隐式表征（如 Triplane 或 3D 高斯参数），在保留高频纹理细节的同时保证严格的 3D 几何一致性。该方法无需针对单个场景进行耗时的梯度下降优化，可将高质量 3D 资产的生成时间从几十分钟缩短至秒级。

## Rules
**系统强制要求：请全程使用中文思考、拓展并输出所有的相关数据。在最终生成和排版实验论文时，必须且只能使用简体中文来进行写作！**

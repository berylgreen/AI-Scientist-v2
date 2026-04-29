# Title: 基于 4D 高斯溅射的实时可控动态角色生成 (Real-time Controllable Dynamic Character Generation based on 4D Gaussian Splatting)

## Keywords
4D Gaussian Splatting, Dynamic Scene Generation, Real-time Animation, Deformable 3D, Generative AI

## TL;DR
如何在保证高渲染质量的同时实现实时、可控的 3D 角色动态生成？利用 4D 高斯溅射（4DGS）结合骨骼动作先验，突破传统 NeRF 和 3DGS 在动态网格形变和时序一致性上的瓶颈。

## Abstract
近期，3D 高斯溅射（3D Gaussian Splatting, 3DGS）因其极高的实时渲染速度和视觉保真度在三维领域引发了革命。然而，将静态 3DGS 拓展到具备复杂形变和时空演变的 4D 动态角色动画生成仍面临巨大挑战。现有方法在处理快速运动或长时间序列时，极易出现高斯点崩溃（伪影）和失去运动连贯性的问题。本研究旨在提出一种新型的 4D 动态高斯生成框架，将时空形变场（Spatiotemporal Deformation Fields）或 4D 旋转元（4D-Rotors）与骨骼/文本动作先验深度对齐。该方法旨在从单视角/稀疏视角的视频或文本提示中，快速生成可由任意动作序列直接驱动的高保真 4D 角色，实现数百 FPS 的实时渲染，为下一代虚拟人、游戏资产生成及 AR/VR 互动提供极其高效的范式。

## Rules
**系统强制要求：请全程使用中文思考、拓展并输出所有的相关数据。在最终生成和排版实验论文时，必须且只能使用简体中文来进行写作！**

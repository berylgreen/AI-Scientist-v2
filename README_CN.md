<div align="center">
  <a href="https://github.com/SakanaAI/AI-Scientist_v2/blob/main/docs/logo_v1.jpg">
    <img src="docs/logo_v1.png" width="215" alt="AI Scientist v2 Logo" />
  </a>
  <h1>
    <b>AI 科学家 v2：基于智能体树搜索的</b><br>
    <b>研讨会级别自动化科学发现</b>
  </h1>
</div>

<p align="center">
  📚 <a href="https://pub.sakana.ai/ai-scientist-v2/paper">[论文]</a> |
  📝 <a href="https://sakana.ai/ai-scientist-first-publication/"> [博客文章]</a> |
  📂 <a href="https://github.com/SakanaAI/AI-Scientist-ICLR2025-Workshop-Experiment"> [ICLR2025 研讨会实验]</a>
</p>

全自主科学研究系统正变得越来越强大，AI 在推动科学发现方式变革中扮演着关键角色。我们很高兴介绍 AI 科学家 v2 —— 一个通用的端到端智能体系统，它已经生成了第一篇完全由 AI 撰写并通过同行评审被接收的研讨会论文。

该系统能够自主生成假说、运行实验、分析数据并撰写科学论文。与[其前代版本（AI 科学家 v1）](https://github.com/SakanaAI/AI-Scientist)不同，AI 科学家 v2 消除了对人工编写模板的依赖，能够跨机器学习（ML）领域进行泛化，并采用由实验管理智能体引导的渐进式智能体树搜索策略。

> **注意：**
> AI 科学家 v2 不一定比 v1 产出更好的论文，尤其是在有高质量起始模板可用的情况下。v1 遵循定义明确的模板，因而成功率较高；而 v2 采用更广泛、更具探索性的方式，成功率相对较低。v1 最适合目标明确且基础扎实的任务，而 v2 专为开放式科学探索而设计。

> **⚠️ 警告！**
> 本代码库将执行由大语言模型（LLM）编写的代码。这种自主性带来了各种风险和挑战，包括可能使用危险的软件包、不受控制的网络访问以及可能产生意外进程。请确保在受控的沙盒环境中运行（例如 Docker 容器）。使用风险自负。

## 目录

1.  [环境要求](#环境要求)
    *   [安装](#安装)
    *   [支持的模型与 API 密钥](#支持的模型与-api-密钥)
2.  [生成研究想法](#生成研究想法)
3.  [运行 AI 科学家 v2 论文生成实验](#运行-ai-科学家-v2-论文生成实验)
4.  [引用 AI 科学家 v2](#引用-ai-科学家-v2)
5.  [常见问题](#常见问题)
6.  [致谢](#致谢)

## 环境要求

本代码设计在具有 NVIDIA GPU 的 Linux 系统上运行，需要 CUDA 和 PyTorch 支持。

### 安装

```bash
# 创建新的 conda 环境
conda create -n ai_scientist python=3.11
conda activate ai_scientist

# 安装带有 CUDA 支持的 PyTorch（根据你的环境调整 pytorch-cuda 版本）
conda install pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia

# 安装 PDF 和 LaTeX 工具
conda install anaconda::poppler
conda install conda-forge::chktex

# 安装 Python 依赖包
pip install -r requirements.txt
```

安装通常不超过一小时。

### 支持的模型与 API 密钥

#### OpenAI 模型

默认情况下，系统使用 `OPENAI_API_KEY` 环境变量来调用 OpenAI 模型。

#### Gemini 模型

默认情况下，系统通过 OpenAI API 使用 `GEMINI_API_KEY` 环境变量来调用 Gemini 模型。

#### 通过 AWS Bedrock 使用 Claude 模型

要使用 Amazon Bedrock 提供的 Claude 模型，请安装必要的额外依赖包：
```bash
pip install anthropic[bedrock]
```
然后，通过设置以下环境变量来配置有效的 [AWS 凭证](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html)和目标 [AWS 区域](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-regions.html)：`AWS_ACCESS_KEY_ID`、`AWS_SECRET_ACCESS_KEY`、`AWS_REGION_NAME`。

#### Semantic Scholar API（文献检索）

我们的代码可以选择性地使用 Semantic Scholar API 密钥（`S2_API_KEY`）以获取更高的文献检索吞吐量（[如果你有的话](https://www.semanticscholar.org/product/api)）。该 API 在创意生成和论文撰写阶段均会使用。即使没有该密钥，系统也能正常工作，但在创意生成阶段可能会遇到速率限制或新颖性检查功能受限。如果你在使用 Semantic Scholar 时遇到问题，可以在论文生成过程中跳过引文阶段。

#### 设置 API 密钥

请确保为你打算使用的模型提供必要的 API 密钥作为环境变量。例如：
```bash
export OPENAI_API_KEY="你的_OPENAI_密钥"
export S2_API_KEY="你的_S2_密钥"
# 如果使用 Bedrock，请设置 AWS 凭证
# export AWS_ACCESS_KEY_ID="你的_AWS_ACCESS_KEY_ID"
# export AWS_SECRET_ACCESS_KEY="你的_AWS_SECRET_KEY"
# export AWS_REGION_NAME="你的_aws_区域"
```
支持
## 生成研究想法

在运行完整的 AI 科学家 v2 实验流水线之前，你需要先使用 `ai_scientist/perform_ideation_temp_free.py` 脚本来生成潜在的研究想法。该脚本使用 LLM 根据你提供的高层次主题描述进行头脑风暴并细化想法，同时与 Semantic Scholar 等工具交互以检查新颖性。

1.  **准备主题描述文件：** 创建一个 Markdown 文件（例如 `my_research_topic.md`），描述你希望 AI 探索的研究领域或主题。该文件应包含 `Title`（标题）、`Keywords`（关键词）、`TL;DR`（简要概括）和 `Abstract`（摘要）等章节来定义研究范围。请参考示例文件 `ai_scientist/ideas/i_cant_believe_its_not_better.md` 了解期望的结构和内容格式。将你的文件放在脚本可以访问的位置（例如 `ai_scientist/ideas/` 目录）。

2.  **运行创意生成脚本：** 从项目主目录执行脚本，指向你的主题描述文件并指定所需的 LLM。

    ```bash
    python ai_scientist/perform_ideation_temp_free.py \
     --workshop-file "ai_scientist/ideas/my_research_topic.md" \
     --model gpt-4o-2024-05-13 \
     --max-num-generations 20 \
     --num-reflections 5
    ```
    *   `--workshop-file`：你的主题描述 Markdown 文件的路径。
    *   `--model`：用于生成想法的 LLM（确保你已设置相应的 API 密钥）。
    *   `--max-num-generations`：尝试生成的独立研究想法数量。
    *   `--num-reflections`：LLM 对每个想法执行的细化迭代次数。

3.  **输出：** 脚本将生成一个以你的输入 Markdown 文件命名的 JSON 文件（例如 `ai_scientist/ideas/my_research_topic.json`）。该文件包含一系列结构化的研究想法，包括假说、拟议实验和相关工作分析。

4.  **进入实验阶段：** 获得包含研究想法的 JSON 文件后，你可以继续进入下一节运行实验。

此创意生成步骤引导 AI 科学家聚焦于特定的研究兴趣领域，并产出具体的研究方向以在主实验流水线中进行测试。

## 运行 AI 科学家 v2 论文生成实验

使用上一步创意生成阶段产出的 JSON 文件，你现在可以启动 AI 科学家 v2 的主流水线。这包括通过智能体树搜索运行实验、分析结果以及生成论文草稿。

通过命令行参数指定论文撰写和审稿阶段所用的模型。最佳优先树搜索（BFTS）的配置位于 `bfts_config.yaml` 中。请根据需要调整该文件中的参数。

`bfts_config.yaml` 中的关键树搜索配置参数：

-   `agent` 配置：
    -   设置 `num_workers`（并行探索路径数）和 `steps`（最大探索节点数）。例如，如果 `num_workers=3` 且 `steps=21`，树搜索将探索最多 21 个节点，每步同时扩展 3 个节点。
    -   `num_seeds`：当 `num_workers` 小于 3 时，通常应与 `num_workers` 相同。否则，将 `num_seeds` 设为 3。
    -   注意：其他智能体参数如 `k_fold_validation`、`expose_prediction` 和 `data_preview` 在当前版本中未使用。
-   `search` 配置：
    -   `max_debug_depth`：智能体在放弃该搜索路径之前，尝试调试失败节点的最大次数。
    -   `debug_prob`：尝试调试失败节点的概率。
    -   `num_drafts`：第一阶段中初始根节点的数量（即要生长的独立树的数量）。

使用生成的想法文件（例如 `my_research_topic.json`）运行 AI 科学家 v2 的示例命令。请查看 `bfts_config.yaml` 了解详细的树搜索参数（默认配置使用 `claude-3-5-sonnet` 进行实验）。如果你不想用代码片段初始化实验，请不要设置 `load_code`。

```bash
python launch_scientist_bfts.py \
 --load_ideas "ai_scientist/ideas/my_research_topic.json" \
 --load_code \
 --add_dataset_ref \
 --model_writeup o1-preview-2024-09-12 \
 --model_citation gpt-4o-2024-11-20 \
 --model_review gpt-4o-2024-11-20 \
 --model_agg_plots o3-mini-2025-01-31 \
 --num_cite_rounds 20
```

初始实验阶段完成后，你将在 `experiments/` 目录中找到一个带时间戳的日志文件夹。进入该文件夹中的 `experiments/"timestamp_ideaname"/logs/0-run/`，你可以找到树可视化文件 `unified_tree_viz.html`。
所有实验阶段完成后，论文撰写阶段将开始。论文撰写阶段通常总共需要约 20 到 30 分钟。撰写完成后，你应该能在 `timestamp_ideaname` 文件夹中看到 `timestamp_ideaname.pdf`。
在此示例运行中，所有阶段通常在数小时内完成。

## 引用 AI 科学家 v2

如果你在研究中使用了 **AI 科学家 v2**，请按以下方式引用我们的工作：

```bibtex
@article{aiscientist_v2,
  title={The AI Scientist-v2: Workshop-Level Automated Scientific Discovery via Agentic Tree Search},
  author={Yamada, Yutaro and Lange, Robert Tjarko and Lu, Cong and Hu, Shengran and Lu, Chris and Foerster, Jakob and Clune, Jeff and Ha, David},
  journal={arXiv preprint arXiv:2504.08066},
  year={2025}
}
```

## 常见问题

**为什么我的实验没有生成 PDF 或审稿结果？**

AI 科学家 v2 完成实验的成功率取决于所选的基础模型以及想法的复杂程度。使用强大的模型（如 Claude 3.5 Sonnet）进行实验阶段时，通常能观察到更高的成功率。

**每次实验的预估成本是多少？**

创意生成步骤的成本取决于使用的 LLM 以及生成/细化的次数，但通常较低（几美元）。对于主实验流水线，使用 Claude 3.5 Sonnet 进行实验阶段的成本通常约为每次运行 $15–$20。后续的论文撰写阶段在使用示例命令中指定的默认模型时大约增加 $5。建议使用 GPT-4o 作为 `model_citation`，这有助于降低撰写成本。

**如何在不同学科领域运行 AI 科学家 v2？**

首先，执行[生成研究想法](#生成研究想法)步骤。创建一个新的 Markdown 文件来描述你期望的学科领域或主题，遵循示例 `ai_scientist/ideas/i_cant_believe_its_not_better.md` 的结构。使用此文件运行 `perform_ideation_temp_free.py` 脚本来生成相应的 JSON 想法文件。然后，进入[运行 AI 科学家 v2 论文生成实验](#运行-ai-科学家-v2-论文生成实验)步骤，通过 `--load_ideas` 参数将此 JSON 文件与 `launch_scientist_bfts.py` 脚本一起使用。

**如果我在访问 Semantic Scholar API 时遇到问题怎么办？**

Semantic Scholar API 用于评估生成想法的新颖性以及在论文撰写阶段收集引文。如果你没有 API 密钥、遇到速率限制，你可以跳过这些阶段。

**遇到 "CUDA Out of Memory"（显存不足）错误怎么办？**

此错误通常发生在 AI 科学家 v2 尝试加载或运行超出系统可用 GPU 显存的模型时。要解决此问题，你可以尝试更新你的创意生成提示文件（`ai_scientist/ideas/my_research_topic.md`），建议在实验中使用更小的模型。

## 致谢

`ai_scientist` 目录中实现的树搜索组件基于 [AIDE](https://github.com/WecoAI/aideml) 项目构建。我们感谢 AIDE 开发者的宝贵贡献以及他们将工作公开发布。


## Star 历史

[![Star History Chart](https://api.star-history.com/svg?repos=SakanaAI/AI-Scientist-v2&type=Date)](https://star-history.com/#SakanaAI/AI-Scientist-v2&Date)

## ⚖️ 许可证与负责任使用

本项目根据 **AI 科学家源代码许可证**（基于负责任 AI 许可证的衍生版本）进行许可。

**强制披露要求：** 使用本代码即表示你受法律约束，必须在任何由此产生的科学手稿或论文中清晰且显著地披露 AI 的使用。

我们建议在论文的摘要或方法部分添加以下声明：
> "本论文使用 [AI 科学家](https://github.com/SakanaAI/AI-Scientist) 自主生成。"

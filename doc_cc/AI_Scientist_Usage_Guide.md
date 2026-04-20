# AI-Scientist-v2 使用指南

本指南展示了如何使用 Docker 运行和交互操作 AI-Scientist-v2 自动化科研系统。

> [!IMPORTANT]
> **开始前的核心概念：**
> **AI-Scientist 并没有提供任何可视化的网页端界面或链接！** 它是一个完全运行在终端命令行的“自动化科研跑批程序”（Agentic Pipeline）。
> 它的整个工作流非常淳朴：
> 1. 你在本机写好一个**指示文档**。
> 2. 在本机的**终端界面里粘贴一条运行指令**按下回车。
> 3. AI 会通过大模型在后台默默跑很久，跑完后把结果生成的 **PDF 论文存放在你的文件夹里**。

## 1. 启动和状态说明
我已经按照您的指令在系统后台执行了服务的初次构建和启动命令:
```bash
docker compose up -d --build
```

> [!NOTE]
> 初次构建 Docker 镜像通常会花费较长的时间（期间需要下载 PyTorch 环境以及庞大的 LaTeX texlive-full 等依赖），可能长达半小时至一小时。构建完成之后，容器将自动保持在后台运行状态。

你可以通过以下命令在当前 `/root/code/research/AI-Scientist-v2` 目录下查看目前的构建及服务状态：
```bash
docker compose ps
docker compose logs -f    # 实时查看正在构建或运行的日志
```

## 2. 环境准备与配置

在执行科研任务之前，必须要让容器能够访问到相应的 LLM API。系统本身是通过读取本机的环境变量来运作的，结合 Docker Compose 你有两种方式来配置参数：

### 方式一：使用 `.env` 文件持久化配置（推荐）
我们在项目根目录设立了一个环境变量文件 `.env`（Docker Compose 会自动读取并映射给内部系统），利用它可以方便地永久保存密码。
请确保在 `/root/code/research/AI-Scientist-v2/.env` 文件中写入了授权信息（**目前已为你写好了团队专用的 TuneCoder（第三方） API 配置**）：

```env
# /root/code/research/AI-Scientist-v2/.env
OPENAI_API_KEY=sk-chen-UZkl4oHuWqZxoq3ZryX16naTIfXYjgdpJxto6fKX1icdg
OPENAI_BASE_URL=https://chen.custom.tunecoder.com/v1
```

> [!NOTE]
> 注意在 OpenAI 第三方代理或镜像站的用法中，URL 地址后端通常需要带有 `/v1` 以匹配 OpenAI 的标准请求路径。

### 方式二：使用临时 bash 环境变量
如果你不想修改文件，也可以在包含对应任务指令的终端窗口中，通过 `export` 临时声明这些变量（因为我们在 `docker-compose.yml` 配置了透传，它会自动继承系统对应变量）：
```bash
export OPENAI_API_KEY="sk-chen-UZkl4oHuWqZxoq3ZryX16naTIfXYjgdpJxto6fKX1icdg"
export OPENAI_BASE_URL="https://chen.custom.tunecoder.com/v1"
```

## 3. 进行科研推演 (标准工作流)

AI-Scientist-v2 的标准工作流分为两步：“研究点子生成”（Ideation）和“科研推演及论文生成”（Experiments & Write-up）。为了方便，我们在 `Dockerfile` 中内置了一个快捷 `entrypoint` 启动脚本。

### 阶段一：提出研究方向（第一步操作点此开始）
**第 1 步：准备输入文件**
针对你感兴趣的研究主题创建一个大致的 markdown 描述文件（例如 `my_research_topic.md`），存放在宿主机的目录下 `/root/code/research/AI-Scientist-v2/ai_scientist/ideas/`，里面请随意用自然语言写一些 `Title`, `Keywords`, `Abstract`。

**第 2 步：运行构思任务**
打开终端（确保目录在 `/root/code/research/AI-Scientist-v2`），复制粘贴以下的命令按下回车。这相当于启动了程序的“发散想点子”功能：
```bash
docker compose run --rm ai-scientist-v2 ideation \
  --workshop-file "ai_scientist/ideas/my_research_topic.md" \
  --model gpt-5.3-codex \
  --max-num-generations 20 \
  --num-reflections 5
```
> 顺利结束后，该脚本会在 `ideas/` 目录下生成一个扩展好细节的 JSON 文件，如 `my_research_topic.json`。

### 阶段二：实验推理与论文产出（Tree Search）
根据第一阶段产生的 `.json` 文件，正式启动漫长且深度的实验推理及论文排版流程：
```bash
docker compose run --rm ai-scientist-v2 bfts \
  --load_ideas "ai_scientist/ideas/my_research_topic.json" \
  --model_writeup gpt-5.3-codex \
  --model_citation gpt-5.3-codex \
  --model_review gpt-5.3-codex \
  --model_agg_plots gpt-5.3-codex \
  --num_cite_rounds 20
```

> [!TIP]
> 整个过程包括代码编写、实验验证和 LaTeX 编写，通常耗时数小时。一切运行中生成的 logs 记录、图表与最终渲染的 PDF 论文结果，都会被实时同步在 `/root/code/research/AI-Scientist-v2/experiments/` 目录中，可直接在宿主机进行查看。

## 4. 交互式调试
如果你觉得每次使用 `docker compose run` 启动单一任务不够方便，由于服务通过 `docker compose up -d` 是一直长期保持在后台的，你也可以直接进入容器开启交互式终端：
```bash
docker compose exec ai-scientist-v2 bash
```
进入到 shell 后，你就可以像在原生系统下一样自由地运行 `python launch_scientist_bfts.py ...`，或者进行模型代码的深入调试与排查。

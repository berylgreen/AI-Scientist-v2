# CLAUDE.md

此文件为 Claude Code（claude.ai/code）在本仓库中工作时提供指引。

## 仓库概览
AI-Scientist-v2 是一个端到端的智能体科研流水线：可自动生成研究想法、执行分阶段实验搜索、聚合图表、撰写 LaTeX 论文并进行自动评审。该项目会执行由 LLM 生成的代码；建议优先在受控沙箱中运行（仓库已提供 Docker 方案）。

## 常用命令

### 环境安装（本地）
```bash
pip install -r requirements.txt
# 若通过 AWS Bedrock 使用 Claude（可选）：
pip install anthropic[bedrock]
```

### 环境变量（按需）
```bash
export OPENAI_API_KEY="YOUR_OPENAI_KEY_HERE"
export S2_API_KEY="YOUR_S2_KEY_HERE"
# 视提供商/配置而定（可选）：
export OPENAI_BASE_URL="..."
export GEMINI_API_KEY="..."
export ANTHROPIC_API_KEY="..."
# Bedrock 可选：
# export AWS_ACCESS_KEY_ID="..."
# export AWS_SECRET_ACCESS_KEY="..."
# export AWS_REGION_NAME="..."
```

### Docker 工作流
```bash
docker compose up -d --build
docker compose ps
docker compose logs -f
docker compose exec ai-scientist-v2 bash
```

Docker 入口脚本支持两个快捷子命令：
- `ideation` → 实际执行 `python ai_scientist/perform_ideation_temp_free.py ...`
- `bfts` → 实际执行 `python launch_scientist_bfts.py ...`

示例运行：
```bash
docker compose run --rm ai-scientist-v2 ideation \
  --workshop-file "ai_scientist/ideas/my_research_topic.md" \
  --model gpt-5.3-codex \
  --max-num-generations 20 \
  --num-reflections 5

docker compose run --rm ai-scientist-v2 bfts \
  --load_ideas "ai_scientist/ideas/my_research_topic.json" \
  --writeup-language Chinese \
  --model_writeup gpt-5.3-codex \
  --model_citation gpt-5.3-codex \
  --model_review gpt-5.3-codex \
  --model_agg_plots gpt-5.3-codex \
  --num_cite_rounds 20
```

### 直接 Python 入口
```bash
python ai_scientist/perform_ideation_temp_free.py \
  --workshop-file "ai_scientist/ideas/my_research_topic.md" \
  --model gpt-4o-2024-05-13 \
  --max-num-generations 20 \
  --num-reflections 5

python launch_scientist_bfts.py \
  --load_ideas "ai_scientist/ideas/my_research_topic.json" \
  --writeup-language Chinese \
  --model_writeup o1-preview-2024-09-12 \
  --model_citation gpt-4o-2024-11-20 \
  --model_review gpt-4o-2024-11-20 \
  --model_agg_plots o3-mini-2025-01-31 \
  --num_cite_rounds 20
```

### 写作语言控制（本轮新增）
- 主入口 `launch_scientist_bfts.py` 新增参数：`--writeup-language`（默认 `English`）。
- 设为 `Chinese` 时，两条写作链路（normal / icbinb）都会强制叙述性正文使用中文。
- 同时在写作前会对 `latex/template.tex` 的英文占位文本做中文预置（仅在中文模式触发），以降低英文先验。

### Lint 与测试
当前仓库未定义官方 lint/test 流程（未发现项目级测试配置或统一测试入口）。
- 没有文档化的“全量测试”命令。
- 没有文档化的“单测（单个测试）”命令。
- `requirements.txt` 中包含 `black`，但仓库未定义规范化的 lint 命令。

## 高层架构

### 端到端编排
- `launch_scientist_bfts.py`：总控入口。
  1. 加载所选 idea JSON。
  2. 在 `experiments/` 下创建带时间戳的运行目录。
  3. 生成本次运行的 BFTS 配置并启动实验搜索。
  4. 聚合最终图表。
  5. 生成写作稿（normal 或 ICBINB 变体）并编译 PDF。
  6. 执行文本/图像评审并保存产物。

### 想法生成
- `ai_scientist/perform_ideation_temp_free.py`：将 workshop/topic 的 markdown 通过迭代式 LLM 反思与工具调用（Semantic Scholar + finalization）转换为 idea JSON。

### 核心实验引擎（分阶段树搜索）
- `ai_scientist/treesearch/perform_experiments_bfts_with_agentmanager.py`：BFTS 实验入口。
- `ai_scientist/treesearch/agent_manager.py`：阶段推进控制（初始实现 → 基线调优 → 创新研究 → 消融研究）。
- `ai_scientist/treesearch/parallel_agent.py`：并行节点生成/执行、指标解析、绘图与 VLM 图像分析。
- `ai_scientist/treesearch/journal.py`（及节点序列化工具）：跨阶段持久化节点与日志状态。

### 后处理与论文产出
- `ai_scientist/perform_plotting.py`：生成并执行图表聚合代码，产出最终 `figures/`。
- `ai_scientist/perform_writeup.py` 与 `ai_scientist/perform_icbinb_writeup.py`：写作、引文轮次与 LaTeX 编译。
- `ai_scientist/perform_llm_review.py` 与 `ai_scientist/perform_vlm_review.py`：论文文本评审，以及图/标题/引用一致性评审。

### 输出与产物结构
每次运行会写入 `experiments/<timestamp>_<idea_name>_attempt_<id>/`，通常包含：
- `idea.md` / `idea.json`
- `logs/`（阶段日志与汇总）
- `figures/`（聚合图）
- `latex/`（源码与生成 PDF）
- 评审文件（`review_text.txt`、`review_img_cap_ref.json`）
- token 使用统计 JSON

## 规则文件发现情况
仓库内未发现 Cursor/Copilot 本地规则文件：
- 无 `.cursor/rules/`
- 无 `.cursorrules`
- 无 `.github/copilot-instructions.md`
- 在创建本文件前，仓库内无既有 `CLAUDE.md`

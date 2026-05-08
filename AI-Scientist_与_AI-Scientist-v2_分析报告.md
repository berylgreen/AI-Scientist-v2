# AI-Scientist 与 AI-Scientist-v2 分析报告

## 一、项目定位对比

这两个项目都在做“自动化科研流程”（Autonomous AI Research Pipeline），目标是把从选题到实验到论文的流程尽可能自动化。

- **AI-Scientist（v1）**：偏线性流水线，强调模块化分阶段执行。
- **AI-Scientist-v2**：偏搜索驱动，核心是 Best-First Tree Search（BFTS）+ 多阶段研究管理。

---

## 二、AI-Scientist（v1）

### 1) 原理

核心思想是把科研过程拆成固定阶段并串联：

1. Idea 生成
2. Novelty 检索过滤
3. 实验代码迭代执行
4. 绘图与结果整理
5. 论文写作
6. LLM 自动评审

它依赖模板契约（例如 `experiment.py`、`plot.py`、`prompt.json`、`seed_ideas.json`、`latex/template.tex`）来适配不同研究任务。

### 2) 主要流程

入口：`AI-Scientist/launch_scientist.py`

1. 读取模板和参数，调用 `ai_scientist/generate_ideas.py` 生成 ideas。
2. 调用 Semantic Scholar / OpenAlex 做新颖性检查。
3. 对每个 idea 创建独立运行目录，进入实验循环（`ai_scientist/perform_experiments.py`）。
4. 运行 `experiment.py`，根据结果或错误让 LLM 继续修改并重试。
5. 完成后运行 `plot.py`，更新 `notes.txt`。
6. 进入写作（`ai_scientist/perform_writeup.py`）并编译论文。
7. 调用 `ai_scientist/perform_review.py` 做自动评审，必要时改稿。

### 3) 优缺点

**优点**
- 结构清晰，阶段边界明确。
- 模板机制便于迁移到新任务。
- 端到端闭环完整（idea→experiment→paper→review）。

**不足**
- 执行 LLM 生成代码的安全风险较高。
- 错误恢复策略偏粗（多依赖原始 stderr 反馈）。
- 可复现性与并行调度策略有进一步工程化空间。

---

## 三、AI-Scientist-v2

### 1) 原理

v2 的核心升级是把“实验实现”当成搜索问题：

- 使用 **Best-First Tree Search（BFTS）** 扩展、评估、选择实验节点。
- 由 `AgentManager` 管理研究阶段推进（实现、调参、创新、消融）。
- 由 `ParallelAgent` 并行执行节点生成/调试/运行/评估。

### 2) 主要流程

入口：`AI-Scientist-v2/launch_scientist_bfts.py`

1. Ideation：`perform_ideation_temp_free.py` 生成研究想法。
2. 创建实验目录并写入/改写 BFTS 配置（`bfts_config.yaml`、`bfts_utils.py`）。
3. 启动树搜索实验（`treesearch/perform_experiments_bfts_with_agentmanager.py`）。
4. `AgentManager` 控制阶段推进，`ParallelAgent` 并行节点执行与迭代。
5. 聚合绘图（`perform_plotting.py`）。
6. 论文写作与引用完善（`perform_icbinb_writeup.py`）。
7. 论文与图文一致性评审（`perform_llm_review.py`）。

### 3) 优缺点

**优点**
- 相比 v1，探索能力更强，能在更大方案空间中搜索。
- 阶段管理更细，实验管理更接近真实科研流程。
- 并行能力更强，具备更强“自动研究员”特征。

**不足**
- 对 LLM 输出格式与协议解析依赖较重，鲁棒性受影响。
- 部分阶段完成判定偏启发式，稳定性受模型波动影响。
- 运行成本和时延较高。
- 进程清理策略需更严格避免误杀非本任务进程。

---

## 四、改进建议（按优先级）

### P0（优先立即做）

1. **执行沙箱硬化（v1/v2）**
   - 默认容器隔离、网络策略、资源限额、文件系统隔离。
2. **结构化错误分类与恢复（重点 v1）**
   - 将失败分为 OOM、依赖缺失、路径错误、超时等，再做定向恢复策略。
3. **安全化进程清理（重点 v2）**
   - 只清理当前 run 创建的子进程 PID，不做关键词扫杀。

### P1（稳定性与可控性）

4. **阶段 Gate 半规则化（重点 v2）**
   - LLM 判断 + 硬阈值（指标提升、覆盖度、统计要求）联合决策。
5. **模型路由显式化（重点 v2）**
   - 提供是否覆盖配置模型的开关，分任务选择模型，平衡质量与成本。

### P2（运维与复现能力）

6. **统一 Run Manifest（v1/v2）**
   - 记录模型版本、prompt hash、依赖、随机种子、硬件环境、token/cost。
7. **写作前质量门禁（重点 v1）**
   - 达不到最低实验质量阈值则不进入高成本写作/评审阶段。

---

## 五、结论

- **v1**：适合做稳定、可理解的自动科研流水线基座。
- **v2**：适合做高探索性的自动科研系统，但需要更强工程治理来控制风险和成本。
- 若要落地生产化，建议先完成 P0 安全与恢复能力，再推进 P1 判据和路由策略。
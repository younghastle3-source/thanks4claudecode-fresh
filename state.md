# state.md

> **現在地を示す Single Source of Truth**
>
> LLM はセッション開始時に必ずこのファイルを読み、focus と playbook を確認すること。

---

## focus

```yaml
current: gym-business-plan  # 現在作業中のプロジェクト名
project: plan/project.md
```

---

## playbook

```yaml
active: plan/playbook-gym-business-plan.md
branch: claude/gym-business-plan-nYgyP
last_archived: plan/archive/playbook-m082-archive-check.md
```

---

## goal

```yaml
milestone: null  # thanks4claudecode の milestone とは独立した外部タスク
phase: p1
done_criteria:
  - "docs/gym-business/README.md が存在し、全ドキュメントへのインデックスを提供している"
  - "docs/gym-business/business-plan-template.md が存在し、事業計画書の全セクション（9 項目以上）を含む"
  - "docs/gym-business/market-research.md が存在し、市場規模・顧客像・立地観点のリサーチがまとまっている"
  - "docs/gym-business/competitor-analysis.md が存在し、競合カテゴリ（3 種以上）ごとの比較がまとまっている"
  - "docs/gym-business/revenue-model.md が存在し、料金プラン・収支試算・損益分岐点の計算式が含まれている"
  - "docs/gym-business/opening-strategy.md が存在し、開業までのロードマップ（12〜18 ヶ月）が時系列で整理されている"
  - "docs/gym-business/how-to-write-business-plan.md が存在し、事業計画書の書き方ガイド（教育コンテンツ）が含まれている"
```

---

## session

```yaml
last_start: 2025-12-19 01:48:26
last_clear: 2025-12-13 00:30:00
```

---

## config

```yaml
security: admin
toolstack: A  # A: Claude Code only | B: +Codex | C: +Codex+CodeRabbit
roles:
  orchestrator: claudecode  # 監督・調整・設計（常に claudecode）
  worker: claudecode        # 実装担当（A: claudecode, B/C: codex）
  reviewer: claudecode      # レビュー担当（A/B: claudecode, C: coderabbit）
  human: user               # 人間の介入（常に user）
```

---

## 参照

| ファイル | 役割 |
|----------|------|
| CLAUDE.md | LLM の振る舞いルール |
| plan/project.md | プロジェクト計画 |
| docs/repository-map.yaml | 全ファイルマッピング（自動生成） |
| docs/folder-management.md | フォルダ管理ルール |

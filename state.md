# state.md

> **現在地を示す Single Source of Truth**
>
> LLM はセッション開始時に必ずこのファイルを読み、focus と playbook を確認すること。

---

## focus

```yaml
current: plan-template  # 現在作業中のプロジェクト名
project: plan/project.md
```

---

## playbook

```yaml
active: plan/playbook-infographic-skill.md
branch: feat/infographic-skill
last_archived: plan/archive/playbook-discord-ai-secretary-archive.md
```

---

## goal

```yaml
milestone: infographic-skill
phase: p_final
done_criteria:
  - ".claude/skills/html-graphic-recording/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "カラースキーム（palette/primary/accent/mono）の仕様が記載されている"
  - "タイポグラフィ仕様（フォント名・CSSクラス）が記載されている"
  - "レイアウト構造（レスポンシブ・グラスモーフィズム・カード型・黄金比グリッド）が記載されている"
  - "視覚効果・データ可視化技法（シャドウ/テクスチャ/データ可視化/接続線）が記載されている"
  - "技術的仕様の HTML/CSS 実装サンプルが含まれている"
  - "命名・frontmatter 形式が既存スキル（becofit-gym-startup / md-converter 等）と一貫している"
```

---

## session

```yaml
last_start: 2026-06-27 16:32:50
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

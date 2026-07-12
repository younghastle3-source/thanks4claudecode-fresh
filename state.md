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
active: plan/playbook-trust-building-posts-skill.md
branch: feat/trust-building-posts-skill
last_archived: plan/archive/playbook-m082-archive-check.md
```

---

## goal

```yaml
milestone: trust-building-posts-skill
phase: p_final
done_criteria:
  - ".claude/skills/trust-building-posts/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "核心の気づき（フォロワー数より信頼・安心感が申し込みにつながる）が記載されている"
  - "4つの投稿テーマ（悩み寄り添い・解決ヒント・お客様の声・自分の思い）が全て記載されている"
  - "各テーマに具体例または実践のポイントが記載されている"
  - "frontmatter 形式が既存スキル（human-touch-writing, becofit-gym-startup 等）と一貫している"
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

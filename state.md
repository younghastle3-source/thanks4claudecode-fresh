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
active: plan/playbook-peak-week-skill.md
branch: feat/peak-week-skill
last_archived: plan/archive/playbook-discord-ai-secretary-archive.md
```

---

## goal

```yaml
milestone: peak-week-skill
phase: p_final
done_criteria:
  - ".claude/skills/peak-week-water-manipulation/SKILL.md が存在する"
  - "SKILL.md に frontmatter（name, description, triggers）が含まれる"
  - "「水分の移動」核心理論・Day1〜Day7プロトコル・水抜き非推奨・サプリ・応用範囲が漏れなく含まれる"
  - "命名・frontmatter 形式が既存フィットネス系スキル（hyrox-fitness-racing 等）と一貫している"
```

---

## session

```yaml
last_start: 2026-06-27 16:05:13
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

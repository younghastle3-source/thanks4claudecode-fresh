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
active: plan/playbook-hyrox-skill.md
branch: feat/hyrox-skill
last_archived: plan/archive/playbook-discord-ai-secretary-archive.md
```

---

## goal

```yaml
milestone: hyrox-skill
phase: p_final
done_criteria:
  - ".claude/skills/hyrox-fitness-racing/SKILL.md が存在する"
  - "SKILL.md に frontmatter（name, description, triggers）が含まれる"
  - "ユーザー提供の全12セクションの見出しが SKILL.md に存在する"
  - "命名・frontmatter 形式が既存フィットネス系スキルと一貫している"
```

---

## session

```yaml
last_start: 2026-06-27 15:34:02
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

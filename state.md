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
active: plan/playbook-threads-post-checklist-skill.md
branch: feat/threads-post-checklist-skill
last_archived: plan/archive/playbook-m082-archive-check.md
```

---

## goal

```yaml
milestone: threads-post-checklist-skill
phase: p_final
done_criteria:
  - ".claude/skills/threads-post-checklist/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "8つのチェック項目（誰に向けて/投稿時間/読者視点/書き出し/長文/専門用語/詰め込み/日記）が全て記載されている"
  - "各チェック項目に「なぜ重要か」のポイント説明が記載されている"
  - "各チェック項目に3つのサブチェックリストが記載されている"
  - "frontmatter 形式が既存スキル（becofit-gym-startup, threads-shukyaku-7days 等）と一貫している"
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

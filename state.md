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
active: plan/playbook-mark-brand-identity-skill.md
branch: feat/mark-brand-identity-skill
last_archived: plan/archive/playbook-m082-archive-check.md
```

---

## goal

```yaml
milestone: mark-brand-identity-skill
phase: p_final
done_criteria:
  - ".claude/skills/mark-brand-identity/SKILL.md が存在し、frontmatter（name: mark-brand-identity, description, triggers）を含む"
  - "MISSION / VISION / CONCEPT / PHILOSOPHY の4要素が全て記載されている"
  - "CORE MESSAGE「目的地は、人だ」が含まれている"
  - "おっくんのStrength（泥臭く積み上げられること / 人の気持ちが分かること / 構造化して伝えられること）が全て含まれている"
  - "BRAND PROMISE が含まれている"
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

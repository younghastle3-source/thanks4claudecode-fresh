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
active: plan/playbook-threads-shukyaku-skill.md
branch: feat/threads-shukyaku-skill
last_archived: plan/archive/playbook-m082-archive-check.md
```

---

## goal

```yaml
milestone: threads-shukyaku-skill
phase: p_final
done_criteria:
  - ".claude/skills/threads-shukyaku-7days/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "Day1〜Day7 の全ワーク（理想客・自己分析・商品設計・プロフィール・固定投稿・投稿ネタ・導線）が記載されている"
  - "投稿→プロフィール→固定投稿→申し込みの集客導線フローが記載されている"
  - "「土台が整っていないまま投稿を続けてもいいねだけで終わる」という核心哲学が含まれている"
  - "frontmatter 形式が既存スキル（becofit-gym-startup 等）と一貫している"
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

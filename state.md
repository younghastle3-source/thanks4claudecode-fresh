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
active: plan/playbook-threads-pdca-foundation.md
branch: feat/threads-pdca-foundation
last_archived: plan/archive/playbook-m082-archive-check.md
previous: plan/playbook-threads-community-skill.md  # discarded（ユーザー指示によりタスク破棄。playbook ファイルは削除済み・成果物なし）
```

---

## goal

```yaml
milestone: null
phase: p1
done_criteria:
  - "「.claude/skills/threads-pdca/SKILL.md」の先頭 frontmatter ブロック内に『name: threads-pdca』（ディレクトリ名と一致）と description: が存在し、description に「」で囲まれたトリガーフレーズが2個以上含まれている"
  - "SKILL.md に『## ワークフロー1』〜『## ワークフロー4』の4見出しが存在し、各セクション内に『発火フレーズ』行・番号付きステップ3個以上・references/ 配下ファイルへの参照が存在する"
  - "「.claude/skills/threads-pdca/references/pattern-library.md」に A〜G の7型セクションが存在し、各区間内に『出典』『型の構造』『効く理由』と、行頭が【 で始まる構造行が型別の下限数（A〜D:3 / E:7 / F:7 / G:8）以上存在する"
  - "pattern-library.md の各型区間内に、その型の出典アカウント名が正しく記載されている（A〜D: leven_base / E: riki.days_ / F: iam_kk_620 / G: hi.hi.hi999 と tomokazu_0008）"
  - "pattern-library.md の『## 執筆時の一般注意』セクション区間内に、絵文字・タメ口・地域名・活動そのもの に言及する箇条書きが5項目以上存在する"
  - "「.claude/skills/threads-pdca/references/my-posts-log.md」に『ログ』を含む H2 見出しがあり、その区間内の表が2行のみ（データ行0件）で、1行目が5列のテーブルヘッダ行（日付/投稿文（要約）/狙った型/実績（いいね/コメント/保存）/気づき）、2行目が5列の区切り行であり、かつ『## 記入方法』区間内に箇条書きが5項目以上存在する"
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

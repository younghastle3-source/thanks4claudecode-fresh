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
active: plan/playbook-threads-pdca-objection-check.md
branch: feat/threads-pdca-objection-check
last_archived: plan/archive/playbook-m082-archive-check.md
previous: plan/playbook-threads-pdca-foundation.md  # completed（threads-pdca スキル新規構築。main にマージ済み / base_commit 113cff0）
```

---

## goal

```yaml
milestone: null
phase: p_final (done)
done_criteria:
  - "SKILL.md の『## ワークフロー2』区間内に『断らせる』を含む H3 見出しがあり、本体リスト（H3 より前）の既存5ステップと断らせるチェックの導線ステップが inputs 追記文面1 の通りステップ行として逐語存在し、その順序が 内容受取 → 型選択 → 断らせるチェック → 下書き作成 → 一般注意 → ログ記録案内 であり、H3 手順の4ステップ（ペルソナ設定／10個の理由出し／3分類／下書きへの反映）も番号付きステップ行として逐語存在し、その順序が ペルソナ → 10個 → 3分類 → 反映 である"
  - "SKILL.md の『## ワークフロー4』区間内に『断らせる』を含む H3 見出しがあり、本体リストの既存4ステップと原因分析の導線ステップが inputs 追記文面2 の通りステップ行として逐語存在し、その順序が データ行抽出 → 集計 → 傾向分析 → 低反応型の原因分析 → 次 Plan 提案 であり、H3 手順の4ステップ（ペルソナ設定／10個の理由出し／提案化／注記候補に留め自動書き込みしない）も番号付きステップ行として逐語存在し、その順序が ペルソナ → 10個 → 提案 → 注記候補 である"
  - "SKILL.md に『断らせる』と『コツ』を含む H2 見出しが1個だけ存在し、その見出し行が『## ワークフロー4』より後の行にあり、区間内に inputs 追記文面3 の4点が `- ` 箇条書き行として行全体逐語で存在し（4項目以上）、年齢／10個／『今の回答は建前です。同じ質問に、本音で答え直してください』／真に受け／教科書 の5要素を含み、うち4要素が別々の行に分かれている"
  - "SKILL.md の先頭 frontmatter 区間内の description に、既存4トリガーフレーズ（「Threadsの投稿分析して」「Threadsの投稿作って」「投稿の実績を記録して」「Threadsの振り返りして」）が全て残存し、かつ「断らせて」「反応しない理由を出して」が追加されており、さらに『## このスキルでできること』区間に『断らせる』を含む番号付き項目が5個以上ある"
  - "回帰: SKILL.md の『## ワークフロー1』〜『## ワークフロー4』の見出し行4本と、ワークフロー1・3 の区間内容が base_commit(113cff0) 版と1文字も相違なく、ワークフロー2・4 の本体リスト（H3 より前）に既存ステップ本文と発火フレーズ行が逐語で残存し、ワークフロー1〜4 の4区間すべてが『発火フレーズ』行・`references/` 参照・番号付きステップ3個以上を満たす"
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

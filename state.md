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
active: plan/playbook-instagram-pdca-skill.md
branch: feat/instagram-pdca-skill
reviewed: false  # ★ pm による自己点検は完了（test_command 24本を bash/zsh で実測 PASS、デコイ16種で FAIL 検出）。LOOP 開始前に Task(subagent_type="reviewer") で PASS を得ること
last_archived: null  # plan/archive/ は本リポジトリに存在しない。完了/クローズした playbook は plan/ に status 付きで残す運用
previous: plan/playbook-video-editing-ffmpeg-skill.md  # closed（2026-08-15。成果物は main にマージ・push 済み / ab66d3e。reviewer PASS 未取得のため done ではなく closed。詳細は当該 playbook の closure note）
```

---

## goal

```yaml
milestone: null
phase: p1 (pending)
done_criteria:
  - "DW1: .claude/skills/instagram-pdca/SKILL.md の先頭 frontmatter 内に `name: instagram-pdca` の行が存在し、`description:` 行に inputs I-1 の起動フレーズ6個が全て逐語（鍵括弧込み）で含まれる"
  - "DW2: SKILL.md に `## ワークフロー1`〜`## ワークフロー4` の H2 が各1本ずつ存在し、各区間内に『発火フレーズ』を含む行が1行以上・行頭が `{数字}. ` の番号付きステップが3行以上・`references/` を含む行が1行以上存在する。さらに ワークフロー2 区間の番号付きステップ行に『断らせる』が、ワークフロー4 区間の番号付きステップ行に『原因分析』が含まれ、ワークフロー2 区間内に H3 `### 断らせるチェックの手順` が存在し、その区間内で『ペルソナ』の初出行が『**10個**』の初出行より前にある"
  - "DW3: SKILL.md に `## 既存スキルとの役割分担` の H2 が1本存在し、その区間内に `.claude/skills/instagram-フック型ショート台本.md` / `.claude/skills/instagram-日常ブリッジ台本.md` / `.claude/skills/threads-pdca/` / `instagram-pdca` の4文字列が全て逐語で含まれ、『委譲』を含む行が1行以上あり、`|` で始まる表の行が6行以上ある"
  - "DW4: references/pattern-library.md に inputs I-2 の8型の H2（`## IG-R1 `〜`## IG-S1 `）が各1本ずつ存在し、各型区間に `**フォーマット**: {リール|フィード|ストーリーズ}` が I-2 で定めた値と逐語一致で存在し、`**出典**: ` / `**主指標**: ` の行が各1行・`### 型の構造` / `### 効く理由` の H3 が各1本・行頭が `【` の構造行が3行以上存在する。加えて IG-R1 区間に `instagram-フック型ショート台本.md`、IG-R2 区間に `instagram-日常ブリッジ台本.md` が含まれ、`## 使い分け早見表` 区間の `|` 行が10行以上ある"
  - "DW5: references/format-guide.md に `## リール` / `## フィード` / `## ストーリーズ` / `## ハッシュタグ戦略` / `## 指標の定義` の H2 が各1本ずつ存在し、前3者の各区間に `- 役割: ` `- 主指標: ` `- 向いている型: ` `- 選ぶ判断: ` で始まり内容が続く行が各1行ずつ存在し、ハッシュタグ戦略区間に行頭 `- ` の行が5行以上かつ『大規模』『中規模』『小規模』が逐語で含まれ、指標の定義区間に inputs I-3 の7指標の定義行が各1行ずつ存在する"
  - "DW6: references/my-posts-log.md の `## 投稿実績ログ` 区間で `|` で始まる行がちょうど2行（ヘッダ＋区切りのみ＝データ行0件）であり、ヘッダ行が inputs I-4 の12列ヘッダと文字列完全一致する。さらに `## 記入方法` の H2 が存在し、その区間に行頭 `- ` の行が6行以上あり、『ダミーデータ・例示行を入れない』と `format-guide.md` と `pattern-library.md` が逐語で含まれる"
  - "DW7: 非重複: `.claude/skills/instagram-pdca/` 配下の全ファイルにおいて、既存の instagram 台本スキル2本に固有の文字列（`数字×悲劇` / `行動×ネガティブ結果` / `Gap Hook` / `日常ブリッジの5つの入口パターン` / `ブリッジ台本を書く`）を含むファイルが0件である"
  - "DW8: 回帰: base_commit ab66d3e からの追跡済み差分・作業ツリー差分・未追跡ファイルを合わせた全変更ファイル集合において、(a) `.claude/skills/` 配下で `.claude/skills/instagram-pdca/` 以外のファイルが0件であり、(b) inputs I-5 の allowlist に該当しないファイルが0件である"
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

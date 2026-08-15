# state.md

> **現在地を示す Single Source of Truth**
>
> LLM はセッション開始時に必ずこのファイルを読み、focus と playbook を確認すること。

---

## focus

```yaml
current: thanks4claudecode  # 現在作業中のプロジェクト名（本ワークスペース自身のスキル資産を作るタスクのため workspace 層。branch 必須）
project: plan/project.md
```

---

## playbook

```yaml
active: plan/playbook-instagram-pdca-skill.md
branch: feat/instagram-pdca-skill
reviewed: true  # reviewer レビュー実施 → FAIL（Major 4 / Minor 8）→ 必須6点を反映 → reviewer の明示的許可により再レビュー省略。反映後に test_command 26本を bash/zsh で再実測 PASS、デコイ27種で FAIL 検出。詳細は playbook の「pm の自己点検記録 / 5. reviewer 指摘への対応」
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
  - "DW2: SKILL.md に `## ワークフロー1`〜`## ワークフロー4` の H2 が各1本ずつ存在し、各見出し行に inputs I-8 の必須キーワード（1=`分析` / 2=`Plan` / 3=`Check` / 4=`Act`）が逐語で含まれ、各区間内に『発火フレーズ』を含む行が1行以上・行頭が `{数字}. ` の番号付きステップが3行以上・`references/` を含む行が1行以上存在する。さらに ワークフロー2 区間の番号付きステップ行に『断らせる』が、ワークフロー4 区間の番号付きステップ行に『原因分析』が含まれ、ワークフロー2 区間内に H3 `### 断らせるチェックの手順` が存在し、**その H3 区間内（次の H1〜H3 見出しまで）**で『ペルソナ』の初出行が『**10個**』の初出行より前にある"
  - "DW3: SKILL.md に `## 既存スキルとの役割分担` の H2 が1本存在し、その区間内に `.claude/skills/instagram-フック型ショート台本.md` / `.claude/skills/instagram-日常ブリッジ台本.md` / `.claude/skills/threads-pdca/` / `instagram-pdca` の4文字列が全て逐語で含まれ、『委譲』を含む行が1行以上あり、`|` で始まる表の行が6行以上ある"
  - "DW4: references/pattern-library.md の型 H2（`^## IG-`）が**ちょうど8本**であり、それが inputs I-2 の8型（`## IG-R1 `〜`## IG-S1 `）と一致し（9本目の型の追加も、型 ID の改名も FAIL）、各型区間に `**フォーマット**: {リール|フィード|ストーリーズ}` が I-2 で定めた値と逐語一致で存在し、`**出典**: ` / `**主指標**: ` の行が各1行・`### 型の構造` / `### 効く理由` の H3 が各1本・行頭が `【` の構造行が3行以上存在する。加えて IG-R1 区間に `instagram-フック型ショート台本.md`、IG-R2 区間に `instagram-日常ブリッジ台本.md` が含まれ、`## 使い分け早見表` の H2 が1本存在してその区間の `|` 行が10行以上あり、**8型それぞれについて `| {型 ID} |` を含む行がちょうど1行存在し、その行の3列目（フォーマット列）が本文の `**フォーマット**: ` の値と文字列一致する**"
  - "DW5: references/format-guide.md に `## リール` / `## フィード` / `## ストーリーズ` / `## ハッシュタグ戦略` / `## 指標の定義` の H2 が各1本ずつ存在し、前3者の各区間に `- 役割: ` `- 主指標: ` `- 向いている型: ` `- 選ぶ判断: ` で始まり内容が続く行が各1行ずつ存在し、ハッシュタグ戦略区間に行頭 `- ` の行が5行以上かつ『大規模』『中規模』『小規模』が逐語で含まれ、指標の定義区間に inputs I-3 の7指標の定義行（`- {指標}: {内容}`）が各1行ずつ存在する"
  - "DW6: references/my-posts-log.md の `## 投稿実績ログ` 区間で `|` で始まる行がちょうど2行（ヘッダ＋区切りのみ＝データ行0件）であり、ヘッダ行が inputs I-4 の12列ヘッダと文字列完全一致する。さらに `## 記入方法` の H2 が存在し、その区間に行頭 `- ` の行が6行以上あり、『ダミーデータ・例示行を入れない』と `format-guide.md` と `pattern-library.md` が逐語で含まれる"
  - "DW7: 非重複: `.claude/skills/instagram-pdca/` 配下の全ファイルにおいて、inputs I-7 の禁止文字列9個（(a) 既存 instagram 台本スキル2本に固有の5個: `数字×悲劇` / `行動×ネガティブ結果` / `Gap Hook` / `日常ブリッジの5つの入口パターン` / `ブリッジ台本を書く`、(b) threads-pdca に固有の4個: `Threads 投稿 型ライブラリ` / `A〜H の使い分け早見表` / `コミュニティ勧誘特化型` / `大義名分型コミュニティ立ち上げ`）のいずれかを含むファイルが0件である（＝既存スキル・threads-pdca の写経による二重管理が発生していない）"
  - "DW8: 回帰: base_commit ab66d3e からの追跡済み差分・作業ツリー差分・未追跡ファイルを合わせた全変更ファイル集合において、(a) `.claude/skills/` 配下で `.claude/skills/instagram-pdca/` 以外のファイルが0件であり、(b) inputs I-5 の allowlist に該当しないファイルが0件である"
  - "DW9: ファイル間整合性（inputs I-9 の R1〜R5）: (R1) format-guide.md の `- 向いている型: ` に列挙された型 ID が全て pattern-library.md に `## {ID} ` として実在し、(R2) I-2 の8型がそれぞれ自分のフォーマットのセクションの `- 向いている型: ` 行に列挙されており、(R3) pattern-library.md の `**主指標**: ` に列挙された指標名が全て format-guide.md に `- {指標}: ` として実在し、(R5) `.claude/skills/instagram-pdca/` 配下に `TBD` / `TODO` / `FIXME` / `後で書く` を含むファイルが0件である（R4 の早見表フォーマット列の一致は DW4 で検証する）"
```

---

## session

```yaml
last_start: 2026-08-15 00:00:00  # instagram-pdca スキル構築セッション（playbook レビュー反映）
last_clear: 2026-08-15 00:00:00
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

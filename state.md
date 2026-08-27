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
active: plan/playbook-kubota-x-articles-integration.md
branch: feat/kubota-x-articles-skill-integration  # 0f4a038 から新規作成。直前タスクは全てコミット済みのため混在の懸念なし
reviewed: false  # reviewer 未レビュー。worker 実装完了直後の状態（レビューは別ステップ）
last_archived: null  # plan/archive/ は本リポジトリに存在しない。完了/クローズした playbook は plan/ に status 付きで残す運用
previous: plan/playbook-part111-integration.md  # p_final passed（DW1〜DW10）。b4ffa15 でコミット済み
```

---

## goal

```yaml
milestone: 久保田式スキルへの X Article ナレッジ統合
phase: p_final (passed, DW1〜DW11 実測。DW12(d) はスコープ外の未追跡ファイル混入により単独再検証待ち)
done_criteria:
  - "DW1: 2ファイルとも base 0f4a038 の全非空行が逐語で残存し、git diff --numstat の削除0行・追加が marketing 155行以上 / blog 75行以上。既存 H2（14 / 11）が残存"
  - "DW2: H2 が marketing ちょうど23本（既存14＋新規9）・blog ちょうど15本（既存11＋新規4）。新規13 H2 が各1本ずつ、各区間に実体行3行以上"
  - "DW3: 全体像の索引表が `|` 行10行以上（8記事）。予約シート/就業規則/床/5段/前提/20行/参謀/10個 と blog スキルへの相互参照を含む"
  - "DW4: 記事1区間にパーソル総合研究所と6数値（32.4% / 1,840万人 / 16.7% / 26.4分 / 61.2% / 75.4%）、予約シート4項目、`日常業務` の否定"
  - "DW5: 記事3区間に床/倍率/エンゲージ率と閾値、`インプ→フォロワー` の語順、`手動→コピペ→自動`、`他人` を含む全行が否定"
  - "DW6: 記事4区間に認知/信頼/相談/受注/継続、Project NANDA・95%、`受け皿`＋`集客`、`詰ま`＋`先`"
  - "DW7: 記事5区間に 1か所/書き戻/初日/2行/68.9%/総務省、症状別早見表、`モデル|ツール` を含む全行が否定"
  - "DW8: プロンプト設計原則5行以上／blog の就業規則7行（褒めるなの否定＋肯定パターン0件）／規則の育て方の相互参照／両ファイルの出典"
  - "DW9: 記事6区間に6区分（扱う仕事→見る数字→見ない数字→決め方→話し方→出し方）がこの順序、20行/400字/1行1判断、短さの原則、月1回の見直し"
  - "DW10: 記事7区間に5行の指示、忖度/慰め/質問/結論から/加工/勝ち/負け/やらないこと、`事実→施策` の語順、`根拠`＋`行ごと`、`一般論`＋`捨`"
  - "DW11: 記事8区間に4ステップ（前提を渡す→役を振る→断らせる→仕分けさせる）がこの順序、10個/3分類/見出し流用/想定問答、`全部` の否定"
  - "DW12: 正典との30文字以上の逐語一致が0件、禁止文字列8個が0件、行数 marketing 533〜720 / blog 293〜400、変更ファイルが allowlist 内"
```

---

## previous_goal (完了・参考)

```yaml
milestone: CJ Advance ナレッジのスキル基盤整備
phase: p_final (passed)
done_criteria:
  - "DW1: 非破壊。base d407efe の全非空行が逐語で残存し、git diff --numstat が削除0行・追加50行以上（実測 88 0）。既存 H2 7本が残存"
  - "DW2: H2 がちょうど12本（既存7＋新規5）、各新規区間に実体行3行以上、base に0件の必須新規語11個（腰方形筋/小円筋/腸腰筋/内腹斜筋/脊柱起立筋/三角筋後部/肩峰/僧帽筋/対角線/過緊張/内旋）がファイル全体に存在"
  - "DW3: トラブル①区間に 上腕二頭筋長頭腱/肩峰/内旋/インピンジメント/小円筋/三角筋後部/外旋/リリース があり、肩峰の行が「ぶつかる/挟まる」に言及"
  - "DW4: トラブル②の「逆」の理解。腰方形筋/広背筋/引き伸ば/過緊張/アライメント/リリース があり、縮の行が否定を伴い、マッサージを含む全行が否定文脈（肯定形で書くと FAIL）"
  - "DW5: トラブル③の左右交差。腸腰筋/内腹斜筋/脊柱起立筋/代償/仰向け/股関節 があり、`左…腰…右…股関節` を1行で含み、腸腰筋を含む全行が右を含み、`左の股関節`/`左の腸腰筋` が0件"
  - "DW6: 評価の原理区間に 痛い場所に原因があるとは限らない/対角線/拮抗筋 があり、3対応（肩前⇔外旋筋 / 僧帽筋⇔腰方形筋・広背筋 / 左腰⇔右股関節）が各1行以上"
  - "DW7: `## いつ使うか` が 僧帽筋/腰痛/肩 に言及し3行以上、既存段落が逐語残存"
  - "DW8: 出典に Part111 のリポジトリ内パス・repo URL・YouTube URL・既存 Part123 行の逐語残存"
  - "DW9: 索引の `## スキル化済みの講義` が `|` 行ちょうど7行・5対応がディレクトリ実在。回帰として `## 講義一覧` の生の行数86かつ NFC 後も pinned tree と集合一致"
  - "DW10: 禁止10語（TBD/TODO/FIXME/後で書く/Transcript:/以下原文/Getty Images/Shutterstock/こんにちは/image1）が0件、SKILL.md が137〜260行（実測175行）、base からの全変更が allowlist 内"
```

---

## known_issues

```yaml
pre_existing_uncommitted:
  count: 2
  files: .claude/skills/instagram-pdca/references/my-posts-log.md / .claude/skills/instagram-pdca/references/pattern-library.md
  note: 本タスク（久保田X記事統合）開始前から作業ツリーに浮いている先行差分。本タスクの成果物ではないため絶対にコミットしないこと（playbook の I-10 PRE / ft3 参照）

kubota_canon_grew_during_planning:
  note: 正典 plan/inputs-kubota-x-articles-20260827.md は playbook 作成中に 5記事(563行) → 6記事(710行) → 8記事(968行) と増えた。playbook は8記事版に改訂済み。さらに追加された場合は H2 本数・行数閾値・DW 番号の3点を必ず同時に更新すること

kubota_article678_not_mock_tested:
  note: 記事6・7・8 に対応する条件（p1.7 / p1.8 / p2.3 と p_final.8 / .9 / .10）はモックによる正常系の実測を経ていなかったが、実装後に全 test_command を実行し PASS を確認済み（2026-08-27）。過検出は発生しなかった

repository_map_generator_broken:
  script: .claude/hooks/generate-repository-map.sh
  symptom: docs/repository-map.yaml が更新されない（skills.count が 11 のまま。新規2スキルが載らない）
  cause: set -euo pipefail 下で `find "$PLAN_DIR/active"` を実行しているが plan/active と plan/archive が本リポジトリに存在せず、pipefail によりスクリプトが中断して出力ファイルを書かずに終了する
  status: 未修正（本タスクのスコープ外）

stray_untracked_file_kubota_task:
  file: plan/inputs-ai-tools-articles-20260827.md
  note: 久保田X記事統合タスクの実装中（2026-08-27）に作業ツリーへ出現した未追跡ファイル。本タスクの成果物ではなく、正典（plan/inputs-kubota-x-articles-20260827.md）とも無関係。playbook の I-10 allowlist に含まれないため、DW12(d)（変更ファイル集合の allowlist 検証）を単独実行すると `outside:1` で FAIL する。本タスクでは add/commit していない（ft3 は明示パス指定のため巻き込まれない）。ファイルの出所・要否はユーザー確認が必要
```

## session

```yaml
last_start: 2026-08-27 10:09:18
last_end: 2026-08-26 06:50:38
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

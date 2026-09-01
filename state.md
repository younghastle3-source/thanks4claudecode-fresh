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
active: plan/playbook-kubota-proposal-note-skill.md
branch: feat/kubota-proposal-note-skill  # f39feb9 から新規作成。main（d407efe）は大きく遅れているため使わない（理由は playbook の meta 参照）
reviewed: false  # reviewer 未レビュー。pm 作成直後。★ LOOP 開始前に必ず reviewer を通すこと
last_archived: null  # plan/archive/ は本リポジトリに存在しない。完了/クローズした playbook は plan/ に status 付きで残す運用
previous: plan/playbook-threads-pdca-auto-log.md  # p_final passed（DW1〜DW11 実測）。f39feb9 でコミット済み
```

---

## goal

```yaml
milestone: 久保田式提案書ノートスキル（meikara-proposal）の新規作成
phase: p_final (passed, DW1〜DW12 実測。コミットは ft3 待ち)
previous_milestone: threads-pdca スキルの実績データを自動収集ログに切り替え、型/CV を分離ログ化（p_final passed, DW1〜DW11 実測。f39feb9 でコミット済み。記録は previous_goal_3 参照）
decisions:
  - "D1（ユーザー決定 2026-09-01）: 既存の久保田系2スキル（meikara-marketing / meikara-blog）には1バイトも追記せず、新規スキル久保田式提案書ノートmeikara-proposalとして独立させる。記事2（下調べ）→記事1（骨組み）の時系列で1本のワークフローに統合し、コピペ用の指示文2本（ステップ4・ステップ5）のみ正典から逐語保持する"
done_criteria:
  - "DW1: `.claude/skills/久保田式提案書ノートmeikara-proposal/` が存在し、その配下の**ファイルがちょうど1件（`SKILL.md`）**。frontmatter に `name: meikara-proposal` があり、`description:` が1行かつ60文字以上で `NotebookLM` / `受注` / `失注` / `下調べ` / `骨組み` の5語を全て含み、`triggers:` 直下の `  - ` 行が6行以上。ファイル全体の行数が190〜380行で、フェンス対応 H2C で数えた H2 がちょうど16本"
  - "DW2: I-3 で指定した16本の H2 が各1本ずつ存在し、コピペ用2セクション（ステップ4 / ステップ5）を除く14区間に実体行（`- ` / `{数字}. ` / `\|` 始まり）が3行以上、コピペ用2区間には解説の実体行（`- ` / `{数字}. ` 始まり）が2行以上ある"
  - "DW3: 既存2スキル `久保田式マーケメソッドmeikara-marketing/SKILL.md` と `久保田式ライティングmeikara-blog/SKILL.md` が base_commit f39feb9 から**完全に無変更**である（`git diff --numstat` が空、かつ `cmp -s` でバイト一致）"
  - "DW4: `## 参照リポジトリ（GitHub・おっくん自身のナレッジ）` 区間に `gh api repos/younghastle3-source/marketing/contents/AI_CONTEXT.md` と `一次情報` が含まれる。`## いつ使うか（発火フレーズ）` 区間に `- 「…」` 形式の行が6行以上あり `提案書の骨組み` / `提案ノート` / `下調べ` を含む"
  - "DW5: `## 全体像：下調べ→骨組みの2フェーズ` 区間に `\|` 始まりの行が6行以上あり、`下調べ` / `骨組み` / `準備プロンプト` / `4段階` を全て含み、**`下調べ` の初出行が `骨組み` の初出行より前にある**（記事2 → 記事1 の時系列）"
  - "DW6: `## 前提：勝ちパターンは自分の過去にしかない` 区間に `フリーランス白書2025` / `人脈` / `過去と現在の取引先` / `エージェント` / `Gemini Notebook` / `2026年7月16日` / `窓の杜` / `読書` が全て含まれ、実体行が4行以上あり、(a) `一般論` を含む行が1行以上ありそのうち1行以上が否定語を伴い、(b) `読書` を含む行のうち1行以上が `案件` または `下調べ` を含む"
  - "DW7: `## ステップ1：ノートに入れる資料4種類` 区間に `公開情報` / `採用ページ` / `受注` / `失注` / `5件` / `3件` / `文字起こし` / `ファイル名` が全て含まれ、`\|` 行が6行以上あり、(a) `要約` を含む行が1行以上ありそのうち1行以上が否定語を伴い、(b) `失注` と `差` を同時に含む行が1行以上、(c) `採用ページ` と `本音` を同時に含む行が1行以上ある"
  - "DW8: `## ステップ2：入れる前のマスキング3点` 区間に `A社` / `金額` / `担当者名` / `守秘義務` が含まれ `{数字}. ` 行が3行以上あり、`そのまま` を含む行のうち1行以上が否定語を伴う。`## ステップ3：ノートを1つ作る（入れすぎない）` 区間に `10個以内` / `30分` / `迷ったら外す` が含まれ、`案件ごと` / `全部` を含む行のうち各1行以上が否定語を伴う"
  - "DW9: `## ステップ4：下調べの準備プロンプト（コピペ用）` 区間に正典の**2つ目**のコピーブロック7行が全て逐語で存在し、必須語4つとフェンス2行以上。`## ステップ5：骨組みを出す4段階の指示文（コピペ用）` 区間に正典の**1つ目**のコピーブロック5行が全て逐語で存在し、プレースホルダとフェンス2行以上"
  - "DW10: `## ステップ6：4段階の読み方（4つ目が本体）` 区間に `5つ` / `10個` / `見出しだけ` / `忖度` / `失注` が含まれ表6行以上、`4つ目`＋`本体|価値`、`褒め`＋否定語、`褒めてもら|褒めさせ|褒めるように` が0件"
  - "DW11: `## ステップ7：骨を提案書に仕上げる（判断は人がやる）` 区間に `今回だけ` / `判断` / `出典` / `数字`、実体行4行以上、`そのまま`＋否定語、`作業`＋`判断` 同一行。`## ステップ8：週1回10分の追加運用` 区間に `10分` / `3か月` / `1年` / `受注` / `失注`、`週`＋`1回` 同一行、実体行3行以上"
  - "DW12: (a)〜(g) つまずき/応用/境界/出典の必須語・行数、(e) 逐語コピペ検出0件（2コピーブロック12行を除く）、(f) 禁止文字列10個が0件、(g) 変更ファイル集合が allowlist（NEW 5 + PRE 7）内"
```

---

## previous_goal_3 (完了・参考)

```yaml
milestone: threads-pdca スキルの実績データを自動収集ログに切り替え、型/CV を分離ログ化
phase: p_final (passed, DW1〜DW11 実測)
done_criteria:
  - "DW1: SKILL.md の保護区間3つ（参照リポジトリ / ワークフロー1 / 断らせるチェックのコツ）が base 574b9ad とバイト単位で一致し、H2 見出し行そのものも逐語一致し、ワークフロー2手順1〜5と2つの H3 ブロックが逐語残存"
  - "DW2: references/pattern-library.md と draft-queue.md が base から無変更（git diff --numstat が空＋cmp -s 一致）、threads-pdca 配下の新規ファイルが type-log.md と conversion-log.md の2件のみ"
  - "DW3: my-posts-log.md のデータ行がちょうど40行で、`^|` 行の並び全体（42行）が base と diff 完全一致（順序含む）。冒頭に凍結宣言と 2026-08-20、移行先4語（threads-pdca-log / marketing / type-log.md / conversion-log.md）を含む"
  - "DW4: `## 自動収集データの読み方` が1本あり、フェンス対応 SEC で抽出した区間に gh api 2行以上＋取得元8語＋指標5語（views/likes/replies/reposts/quotes）＋3指標（床/倍率/エンゲージ率）＋okkun_lifestyle＋鮮度警告（7日・古い）を含む"
  - "DW5: 同区間にデータの落とし穴3点（計測不可を0扱いしない / 中央値と外れ値 / text が null）と jq のクラッシュ回避（`// []` と `select(`）が明記"
  - "DW6: 閾値は threads-pdca-criteria.md 側が正であり SKILL.md にハードコードしない旨と、followers_count 欠損時のフォールバックが明記"
  - "DW7: ワークフロー3の見出しから `記録` が消え、発火フレーズ『スレッズの実績』『今週のスレッズ』を含み、旧手順の痕跡5件が0件"
  - "DW8: ワークフロー4が共通手順を参照し、my-posts-log.md 言及行の全行が凍結文脈を伴い（ALL）、type-log.md と突き合わせ、pattern-library.md を読み取り専用で型推定に使う"
  - "DW9: frontmatter description / できること / 参照ファイル（新2ファイル含む）/ draft-queue 説明 / ワークフロー2手順6・7 / conversion-log 言及 / 使い方 の7箇所が新方式に整合（旧文言5件が0件）"
  - "DW10: 禁止文字列10個（トークン系5種を含む）が0件、SKILL.md 165〜320行・my-posts-log.md 52〜95行、H2C で数えた H2 がちょうど10本、変更ファイルが allowlist 内"
  - "DW11: type-log.md（日付/URL/狙った型・自動追記の旨・ダミー行0件）と conversion-log.md（日付/コンバージョン/メモ・手動・低頻度の旨）が要件どおり存在"
```

---

## previous_goal_2 (完了・参考)

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
  count: 7  # modified 4 + untracked 3（2026-09-01 実測。reviewer 指摘 C1 で playbook-kubota-ai-adoption-order.md を追加）
  files: |
    M .claude/skills/instagram-pdca/references/my-posts-log.md
    M .claude/skills/instagram-pdca/references/pattern-library.md
    M .claude/skills/video-editing-ffmpeg/SKILL.md
    M .claude/skills/video-editing-ffmpeg/references/shooting-basics.md
    ?? plan/inputs-ai-tools-articles-20260827.md
    ?? plan/inputs-kubota-ai-adoption-order-20260901.md
    ?? plan/playbook-kubota-ai-adoption-order.md
  note: 現タスク（久保田式提案書ノートスキルの新規作成）開始前・作成中から作業ツリーに浮いている先行差分。本タスクの成果物ではないため絶対にコミットしないこと（playbook の I-8 PRE / ft3 参照）。`git add -A` / `git commit -a` / `git checkout .` / `git reset --hard` は全て禁止

kubota_ai_adoption_order_task_in_parallel:
  files:
    - plan/inputs-kubota-ai-adoption-order-20260901.md   # 正典（90行）
    - plan/playbook-kubota-ai-adoption-order.md          # playbook（87,627 バイト・別 pm が作成）
  note: |
    久保田亮の X Article「ChatGPTを社員に配って終わる会社と、変わる会社。最初に任せた仕事が違いました。」
    を 久保田式マーケメソッドmeikara-marketing へ統合する**別タスク**の資産。
    正典の冒頭に「マーケメソッド追記用」と明記されている。
    2026-09-01 の提案書ノートスキル作成タスクと**並行して**作業ツリーに出現した
    （playbook のほうは提案書ノートタスクの playbook 作成中に別 pm が作成）。
    提案書ノートタスクの正典（plan/inputs-kubota-proposal-notebooklm-20260901.md）とは無関係。
    提案書ノートタスク側からは PRE 扱いで一切コミットしない。
    2タスクが同一ブランチ上で並走している状態のため、どちらの ft3 でも
    `git add -A` / `git commit -a` は特に危険（相手の未完成の成果物を巻き込む）
    提案書ノートタスク（本タスク）は完了時点でこの2ファイルにまだ未着手。
    marketing への統合は別タスクとして今後 playbook-kubota-ai-adoption-order.md 側で進める

threads_pdca_manual_log_has_real_data:
  file: .claude/skills/threads-pdca/references/my-posts-log.md
  note: ユーザーは「Workflow3 を一度も使ったことがない＝空のテンプレート」と認識していたが、実際には 2026-07-17〜2026-08-20 の実投稿40行が入っている（`^| 2026` が40行。2026-08-31 に pm が実測）。`狙った型` / `コンバージョン` / `気づき` の3列は Threads API の自動ログから復元できないため、このファイルは削除せず凍結アーカイブ化する（playbook の I-6 / DW3）

draft_queue_stale_reference:
  file: .claude/skills/threads-pdca/references/draft-queue.md
  note: 冒頭に「投稿したら my-posts-log.md に実績を記録し」とあるが、my-posts-log.md が凍結されるとこの記述は古くなる。ユーザーが draft-queue.md を明示的に保護対象に指定しているため本タスクでは直さない（直すと DW2 で FAIL する）。更新が必要になったらユーザー確認のうえ別タスクとする

playbook_section_extraction_needs_fence_awareness:
  note: |
    Markdown の見出し区間を awk で切り出すとき、終端に `/^#{1,2} /` を使うと
    コードブロック内の bash コメント行（`# 1) ...`）にマッチして区間が途中で切れる。
    同様に `grep -c '^## '` は ```markdown フェンス内の引用見出しを数えてしまう。
    本リポジトリの playbook で SKILL.md 等を検証する際は、必ずフェンス対応版
    （plan/playbook-threads-pdca-auto-log.md の「実行前提と検証規約」の SEC/BSEC/H2C）を使うこと。
    2026-08-31 に threads-pdca の playbook で実際に踏み、正しい実装が全 FAIL する状態だった

playbook_table_verification_pipe_in_ere:
  note: |
    Markdown 表の行を `grep -E '^| 日付 |'` で検証してはいけない。`|` は ERE の選択演算子なので
    「空文字列にマッチ」＝常に真になり、検査が黙って無効化される。
    また行ごとの `grep -qxF` 照合は**行の並べ替えを検出できない**。
    表の逐語＋順序の検証は `diff <(git show BASE:f | grep '^|') <(grep '^|' f)` を使うこと

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
last_start: 2026-08-31 22:30:00
last_end: 2026-08-31 23:20:47
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

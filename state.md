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
active: plan/playbook-kubota-ai-adoption-order.md
branch: feat/kubota-ai-adoption-order  # 574b9ad（久保田 X 記事8本の統合コミット）から分岐。main（d407efe）は8記事統合を含まないため使わない（理由は playbook の meta / 実行前提と検証規約 参照）
worktree: .claude/worktrees/kai  # 本タスクは linked worktree で実施。本体ツリー（並行タスク feat/kubota-proposal-note-skill が使用中）には一切触れていない
reviewed: true  # reviewer PASS（実測ベース。p0〜ft6 を worktree 上で実際に動かして検証済み）
last_archived: null  # plan/archive/ は本リポジトリに存在しない。完了/クローズした playbook は plan/ に status 付きで残す運用
previous: plan/playbook-kubota-proposal-note-skill.md  # p_final passed（DW1〜DW12 実測）。feat/kubota-proposal-note-skill 側で進行
```

---

## goal

```yaml
milestone: 久保田式マーケメソッドへの AI導入順序ナレッジ（2記事）の追記
phase: p_final (passed, DW1〜DW11 実測。ft3 でコミット済み)
previous_milestone: 久保田式提案書ノートスキル（meikara-proposal）の新規作成（p_final passed, DW1〜DW12 実測。feat/kubota-proposal-note-skill 側。記録は previous_goal_4 参照）
decisions:
  - "D1（pm 決定 2026-09-01）: 新規スキルは作らず、既存の 久保田式マーケメソッドmeikara-marketing/SKILL.md に H2 5本を非破壊で追記する。他スキル（meikara-blog / threads-pdca / instagram-pdca / video-editing-ffmpeg）には1バイトも触らない"
  - "D2（pm 決定 2026-09-01）: 2記事は「AI導入の最初の一手」の両輪であり、SKILL.md 上は 記事②（人を単位に選ぶ）→ 記事①（数字を読ませる仕事）の順に並べ、1段目＝誰の時間を空けるか／2段目＝その人のどの仕事を渡すか の2段構成として読めるようにする（正典の並び順とは逆）"
  - "D3（本タスク限定の例外）: 各記事の「コピペ用の指示文」だけはコードフェンス内に逐語で収録し、正典から動的に抽出したブロックと diff で完全一致を要求する。それ以外の本文の逐語コピペは従来どおり禁止（機械検証）"
  - "D4（pm 決定 2026-09-01）: 本体ツリーは並行タスクが使用中のため、linked worktree `.claude/worktrees/kai` を作って作業を完結させる。本体ツリーの HEAD・ブランチ・作業ツリーは一切変更しない"
done_criteria:
  - "DW1: base_commit 574b9ad 時点の SKILL.md の**全非空行が逐語で残存**し、`git diff --numstat 574b9ad` の**削除が0行**、追加が**100行以上**であり、base 側の H2 が23本・フェンス行が12行であること（base_commit の指定ミスを検出する自己診断）"
  - "DW2: `H2C` で数えた H2 が**ちょうど28本**（既存23＋新規5）であり、新規5 H2 が各1本ずつ存在し、既存の `## 出典（久保田亮のX記事・2026-08）` が1本のまま残り、新規5 H2 が**既存の出典セクションより後ろに I-3 の順序どおり**並び、各区間の**フェンス外**実体行が ①25行以上 / ②5行以上 / ③12行以上 / ④5行以上 / ⑤7行以上ある"
  - "DW3: 区間①（人を単位に選ぶ）に `断り文句` / `特殊` / `工程` / `単位` / `番頭` / `1人目` / `社長` / `部下` / `1段目` / `2段目` / `2段` が全て含まれ、`\|` 始まりの行が11行以上あり、(a) `1人目` を含む**全行**が `社長` を含み、**かつ競合する対象語（`担当者` / `社員` / `部下` / `若手` / `現場の人`）を1つも含まない**、(a') `1人目(は|を|に)社長` に一致する行が1行以上ある、(b) `1段目` と `誰` を同時に含む行が1行以上、(c) `2段目` と `数字` を同時に含む行が1行以上、(d) `業務` と `単位` を同時に含む行のうち1行以上が `止ま|残り|できない|一部しか|数える単位` を伴う"
  - "DW4: 区間①に最初の1本を選ぶ3条件と線引きが書かれている。`{数字}. ` 始まりの行が3行以上あり、`毎週` / `1ヶ月` / `型` / `社外` / `内と外` / `一次情報` / `何時間` が全て含まれ、(a) `渡` と `判断` と `残` を同時に含む行が1行以上、(b) `何時間` を含む**全行**が `ではな|でなく|意味がな|数えな|決まらな` を伴う"
  - "DW5: 区間①に裏づけ調査が数値つきで書かれている。`中小企業基盤整備機構` / `1,647` / `20.4%` / `18.6%` / `39.0%` / `87.0%` / `32.3%` / `83.2%` / `68.3%` / `34.9%` / `82.6%` / `38.6%` / `29.0%` / `26.4%` / `smrj.go.jp` / `効率化` / `品質向上` / `増収` が全て含まれ、(a) `因果` を含む**全行**が `ではな|言い切れな|とまでは` を伴う、(b) `効率化` と `入口` を同時に含む行が1行以上"
  - "DW6: 区間②（社長の1週間を仕分ける指示文）のコードフェンスが**ちょうど1組**で、フェンス本文が `CANONBLK` で正典から抽出した記事②の指示文ブロック（11行）と `diff` で**完全一致**し、区間②に `【自社の業種】` / `【役職や立場】` / `2箇所` / `業務コンサルタント` / `情報が足りない` / `事実と推測を分けて` / `任せてはいけない仕事を3つ` / `指示文の下書き` / `専門用語を使わずに` / `粒度` / `先週` / `10分` / `3条件` が全て含まれる"
  - "DW7: 区間③（数字を読ませる仕事）に `議事録` / `試算表` / `時短` / `経営者` / `決裁` / `検索` / `文章` / `数字を読` が全て含まれ、`\|` 始まりの行が9行以上・`{数字}. ` 始まりの行が5行以上あり、(a) `時短` を含む**全行**が `個人|本人|完結|担当者|見えな|届かな|決裁` を伴い、(b) `文章` を含む行のうち1行以上が `弱` を伴い、(c) 断定・推奨形6個が0件、(d) `最初の一手` と `数字` を同時に含む行が1行以上ある"
  - "DW8: 区間③に3つの理由・実例3件・導入前の2つが書かれている。`完結` / `属人` / `個人技` / `指示文` / `誰が` / `繁忙期` / `社長` / `宿` / `報告書` / `月次` / `読み上げ` / `月内` / `月末` / `入れ替わ` / `人の目` / `内と外` / `1ヶ月` / `向き不向き` / `毎朝` が全て含まれ、`指示文`＋`誰が` / `やめ`＋`困` / `月内`＋`月末` / `人の目`＋`外` / `順番`＋`向き不向き` の5組が各1行以上"
  - "DW9: 区間④（数字を読ませる指示文）のコードフェンスが**ちょうど1組**で、フェンス本文が `CANONBLK` で抽出した記事①の指示文ブロック（11行）と `diff` で**完全一致**し、区間④に `【自社の業種】` / `【会社名や店舗名】` / `2箇所` / `経理アドバイザー` / `データからは分からない` / `変化が大きい数字を3つ` / `理由の候補を数字ごとに2つずつ` / `今週中に確認した方がよいことを1つ` / `もっともらし` / `答え合わせ` / `10分` / `試算表` が全て含まれる"
  - "DW10: 区間⑤（出典）に `久保田亮` / `@Charlie_no_site` / `plan/inputs-kubota-ai-adoption-order-20260901.md` / `2026-08` / `例外` / `コピペ` / `2段` が全て含まれ、`^- 記事1：` と `^- 記事2：` が各1行あり、フェンス境界が守られている（区間①③⑤のフェンス行0 / 区間②④が各2 / ファイル全体でちょうど16 / `^- 記事[12]：` 行がちょうど2）"
  - "DW11: (a) 禁止文字列10個（TBD / TODO / FIXME / 後で書く / では、始めます / 最終章 / 僕が現場で / 心当たりがある / ここからコピー / ↑ここまで）が0件。(b) 行数が700〜950行。(c) **フェンス内と `^- 記事[12]：` 行を除いた**どの行も、正典と30文字以上（記号・空白除去後）一致しない。(d) `git diff --name-only 574b9ad HEAD` の全ファイルが I-8 の allowlist（4パス）に該当する"
evidence:
  - "実測（2026-09-01・worktree .claude/worktrees/kai）: SKILL.md 600行 → 768行（追加168 / 削除0）、H2 23本 → 28本、フェンス行 12 → 16、`^- 記事[12]：` 2行"
  - "p1.1〜p1.5 / p2.1〜p2.6 / p_final.1〜p_final.9 の全 test_command が PASS。逐語コピペ検出（閾値30）0件"
```

---

## previous_goal_4 (完了・参考)

```yaml
milestone: 久保田式提案書ノートスキル（meikara-proposal）の新規作成
phase: p_final (passed, DW1〜DW12 実測。feat/kubota-proposal-note-skill 側で進行)
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
  count: 8  # modified 5 + untracked 3（2026-09-01 実測。**本体ツリー /Users/kosei/thanks4claudecode-fresh 側の値**。worktree からは見えない）
  files: |
    M .claude/skills/instagram-pdca/references/my-posts-log.md
    M .claude/skills/instagram-pdca/references/pattern-library.md
    M .claude/skills/video-editing-ffmpeg/SKILL.md
    M .claude/skills/video-editing-ffmpeg/references/shooting-basics.md
    M state.md
    ?? plan/inputs-ai-tools-articles-20260827.md
    ?? plan/inputs-kubota-ai-adoption-order-20260901.md
    ?? plan/playbook-kubota-ai-adoption-order.md
  note: |
    本体ツリー（並行タスク feat/kubota-proposal-note-skill が使用中）に浮いている先行差分。
    本タスクは linked worktree `.claude/worktrees/kai` の中だけで完結しており、この一覧には一切触れていない。
    取得方法: `git -C /Users/kosei/thanks4claudecode-fresh status --porcelain`（並行タスクの進行で増減するのでコピーで済ませない）。
    `git add -A` / `git commit -a` / `git checkout .` / `git reset --hard` は worktree の中でも全て禁止

kubota_ai_adoption_order_task_in_parallel:
  files:
    - plan/inputs-kubota-ai-adoption-order-20260901.md   # 正典（200行。記事2の追記で91行から増えた）
    - plan/playbook-kubota-ai-adoption-order.md          # playbook（2記事版・worktree 方式に全面改訂済み）
  note: |
    久保田亮の X Article 2本（「ChatGPTを社員に配って終わる会社と、変わる会社。」/
    「ChatGPTに任せる仕事は、業務でなく人で選びます」）を
    久保田式マーケメソッドmeikara-marketing へ統合するタスク。
    **`feat/kubota-ai-adoption-order`（linked worktree `.claude/worktrees/kai`）で完了した。**
    2026-09-01 の提案書ノートスキル作成タスクと並行して走ったが、
    worktree 方式にしたため本体ツリーの HEAD・ブランチ・作業ツリーには一切影響していない。
    本体ツリーには上記2ファイルの**未追跡コピーが残っている**（p0.1 のコピー元）。
    マージ後に削除してよいが、本タスクからは削除していない

kubota_ai_adoption_order_worktree_split_view:
  note: |
    `feat/kubota-ai-adoption-order` は 574b9ad から分岐しているため、この worktree からは
    threads-pdca 自動ログ化（f39feb9）と提案書ノートスキル（a3e4da7 以降）の成果物が見えない。
    失われてはおらず、それぞれ `feat/threads-pdca-auto-log` / `feat/kubota-proposal-note-skill` に残っている。
    main へのマージ順（574b9ad 自体がまだ main に入っていない）はユーザー判断

kubota_ai_adoption_canon_grew_during_planning:
  note: |
    正典 plan/inputs-kubota-ai-adoption-order-20260901.md は playbook 作成中に
    1記事(91行) → 2記事(200行) に増えた。さらに追加された場合は
    H2 本数・フェンス数・行数閾値・DW 番号・CANONBLK アンカーの5点を必ず同時に更新すること

linked_worktree_task_pattern:
  note: |
    本タスクは本体ツリーが並行タスクで塞がっていたため、linked worktree
    `.claude/worktrees/kai` を作って作業を完結させた（`.claude/worktrees/` は .gitignore 済みなので
    worktree の存在自体が本体ツリーの git status を汚さない）。
    正典・playbook が本体ツリーで未追跡の場合は worktree に存在しないため `cp -n` で明示コピーが要る。
    同じ構成をとる場合は plan/playbook-kubota-ai-adoption-order.md の p0 と「リスクとロールバック」を参照すること

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
last_start: 2026-09-01 00:00:00
last_end: 2026-09-01 00:00:00
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

# playbook-threads-pdca-foundation.md

> **実行前提**: 本 playbook の全 test_command はリポジトリルート
> （`/Users/kosei/thanks4claudecode-fresh`）をカレントディレクトリとして実行すること。
> 相対パスは全てリポジトリルート起点で記述している。
>
> **区間抽出の共通仕様**: セクション内容の検証は
> `awk '/^## 見出し/{f=1;next} /^#{1,2} /{f=0} f'` で見出し区間を切り出してから行う。
> 終端を `^#{1,2} ` にしているのは、H1（`# 付録` 等）でも区間を閉じるため
> （`^## ` のみだと H1 やファイル末尾に内容を逃がして偽 PASS を作れる）。
> `### ` / `#### ` のサブ見出しでは閉じない。
> 見出し記号のドットは `[.]` で表記する（macOS awk の `-v` はバックスラッシュを落とすため
> `\.` が任意1文字メタに化け、`## A〜G の使い分け早見表` のような見出しに誤マッチする）。
>
> **複数型の一括検証**: 型ごとに期待値（出典アカウント・構造行数）が異なるため、
> `printf '%s\n' "型|期待値" ... | while IFS='|' read -r ...` 形式で検証する。
> シェル配列は bash と zsh でインデックス基点が異なるため使用しない。
> パイプ内の `exit` は親シェルに伝播しないため、失敗を文字列に蓄積して最後に空判定する。

---

## meta

```yaml
project: thanks4claudecode
branch: feat/threads-pdca-foundation
created: 2026-08-05
issue: null
derives_from: null  # ユーザー資産（スキル）の新規構築であり project.done_when に対応なし
reviewed: true
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: Threads 投稿の PDCA を回す基盤（7型の型ライブラリ＋投稿ログ＋PDCAワークフロースキル）を .claude/skills/threads-pdca/ に新規構築する
done_when:
  - "「.claude/skills/threads-pdca/SKILL.md」の先頭 frontmatter ブロック内に『name: threads-pdca』（ディレクトリ名と一致）と description: が存在し、description に「」で囲まれたトリガーフレーズが2個以上含まれている"
  - "SKILL.md に『## ワークフロー1』〜『## ワークフロー4』の4見出しが存在し、各セクション内に『発火フレーズ』行・番号付きステップ3個以上・references/ 配下ファイルへの参照が存在する"
  - "「.claude/skills/threads-pdca/references/pattern-library.md」に A〜G の7型セクションが存在し、各区間内に『出典』『型の構造』『効く理由』と、行頭が【 で始まる構造行が型別の下限数（A〜D:3 / E:7 / F:7 / G:8）以上存在する"
  - "pattern-library.md の各型区間内に、その型の出典アカウント名が正しく記載されている（A〜D: leven_base / E: riki.days_ / F: iam_kk_620 / G: hi.hi.hi999 と tomokazu_0008）"
  - "pattern-library.md の『## 執筆時の一般注意』セクション区間内に、絵文字・タメ口・地域名・活動そのもの に言及する箇条書きが5項目以上存在する"
  - "「.claude/skills/threads-pdca/references/my-posts-log.md」に『ログ』を含む H2 見出しがあり、その区間内の表が2行のみ（データ行0件）で、1行目が5列のテーブルヘッダ行（日付/投稿文（要約）/狙った型/実績（いいね/コメント/保存）/気づき）、2行目が5列の区切り行であり、かつ『## 記入方法』区間内に箇条書きが5項目以上存在する"
```

---

## inputs（合意済み素材）

> **本セクションが worker の参照すべき唯一の正典（source of truth）である。**
> CLAUDE.md §7「Trust state files over chat history」に従い、
> 7型の定義・出典・共通ルールをチャット文脈ではなく本ファイルに固定する。
>
> **worker への指示**: 以下の内容を pattern-library.md に反映すること。
> test_command はキーワードの有無しか検証できないため、
> キーワードだけを散りばめた独自解釈・創作による捏造ライブラリは禁止。
> 内容の忠実性は本セクションとの逐語的な突き合わせで担保する。
>
> **A〜G の7型が最終ラインナップである**（ユーザーが「これでラストにする」と明言済み。以降の型追加は別 playbook）。

### 7型一覧

| 型 | 名称 | 出典アカウント | 役割 |
|---|---|---|---|
| A | 日常実況型 | leven_base | CTAなしの低負荷投稿。「毎日投稿してる人」という信頼の土台作り |
| B | 共感質問型 | leven_base | 弱み・悩みの告白＋質問で終えてコメントを誘発する |
| C | 物語・哲学連投型 | leven_base | 本音→理由→人生観の連投でブランド人格を構築し滞在時間を稼ぐ |
| D | イベント告知＋ベネフィット再定義型 | leven_base | 日時明示＋感情的ベネフィットへの言い換え＋低摩擦CTAで集客する |
| E | コミュニティ勧誘特化型 | riki.days_ | 毎投稿ほぼ同じ骨格＋毎回ハードCTA。短期集客・立ち上げ期向け |
| F | 大義名分型コミュニティ立ち上げ | iam_kk_620 | 社会課題としての大義名分と運営者の弱み開示で参加動機を作る |
| G | 参加者体験談型（UGC） | hi.hi.hi999 / tomokazu_0008 | 参加者目線の第三者証明。A〜F の主催者投稿を補強する |

> **出典アカウントの位置づけ**: A〜D は leven_base（ランニングコミュニティ運営アカウント / 投稿9件を分析）。
> E は riki.days_、F は iam_kk_620。G は hi.hi.hi999 と tomokazu_0008（いずれも leven_base コミュニティの**参加者**アカウント）。
> **worker は各型セクションに、その型の出典アカウント名を必ず明記すること。全型を leven_base と書くのは誤り。**

### A. 日常実況型（出典: leven_base）

```
【1】場所＋今やってること（「今から」「〜来ました」）
【2】絵文字1つで感情を添える
【3】ハッシュタグ（地域名 or 活動名、1個だけ）
```

CTAなし。目的は「毎日投稿してる人」という信頼の土台作り。

### B. 共感質問型（出典: leven_base）

```
【1】具体的な身体感覚・弱みの告白（例:「一生下半身筋肉痛」「呼吸キツくなってもういいかな」）
【2】笑・絵文字でシリアスにしすぎない
【3】「みんな出来てるの？」「普通？」で終える → 断定せず質問で余白を残す
```

弱みの開示が起点。「これ自分だけ？」と思ってる人が思わずコメントしたくなる設計。

### C. 物語・哲学連投型（出典: leven_base）

```
【1】本音の告白（例:「正直、ランニング好きじゃない」）→ 引きで1/2を終える
【2】理由の開示（例:「逃げてる自分でいたくないから」）
【3】人生観への昇華（例:「誰にも見られてない時間の選択が人生を決める」）
```

地域名もCTAもゼロ。連投（1/2, 2/2）でスクロールを止めさせ、滞在時間とプロフィール遷移を狙う。

### D. イベント告知＋ベネフィット再定義型（出典: leven_base）

```
【1】日時・場所・タイムスケジュールを具体的に明示
【2】「ただ運動するだけじゃなく」で活動そのものの価値を下げ、コミュニティ・友好・趣味トークという“本当の価値”に差し替える
【3】ソフトCTA：「オープンチャット参加お待ちしてます」ではなく「コメント待ってます」「興味ある人いますか？」← 心理的ハードルが低い
```

### E. コミュニティ勧誘特化型（出典: riki.days_）

```
【1】フック（1〜2行）→ 活動宣言／日常実況／共感の一言／共感質問のどれか1つ
【2】ベネフィット描写 → 「運動＋食事/カフェ」のセットで生活の充実を見せる
【3】タメ口の誘い文句 → 「〜しない？」「〜行こうよ」「〜だい？」で距離を詰める
【4】地域＋活動内容の明示 → 「〇〇でランニングチーム運営してます」固定フレーズ
【5】（任意）ハードル除去 → 「1人でもいいから」「勇気出して」で初参加の不安を下げる
【6】CTA固定フレーズ → 毎回「オープンチャット」に言及して参加を促す
【7】ハッシュタグ → 地域名＋運動系＋クラブ名（3〜7個）
```

verbatim CTA バリエーション（そのまま記録すること）:
「オープンチャットのご参加お待ちしてます💭」
「是非コミュニティの参加お待ちしております🤳🏽」
「オープンチャット参加してみてください☀️」
「オープンチャット貼っておくから追加して詳細待っててね👍🏽」

効く理由 / 特徴: leven_base（型A〜D）と違い、毎投稿がほぼ同じ骨格で、毎回ハードCTA（明確な参加呼びかけ）を含む。短期集客・立ち上げ期向け。

### F. 大義名分型コミュニティ立ち上げ（出典: iam_kk_620）

```
【1】大義名分フレーミング → 個人の趣味ではなく社会課題として提示（例:「高齢化が進んでる栃木を盛り上げる為に」「大人になるにつれて運動する機会減ってきてない？」）
【2】反語的同意フレーズの多用 → 「〜じゃない？」「〜だよね」で否定させない（例:「最高じゃない？」「そしたらみんなハッピーだよね」「参加する理由なんてなくていいじゃん」）
【3】社会的証明の開示（進捗報告） → FOMOを煽る（例:「ぞくぞくとお声がけいただいて嬉しいです」「反応良くてめちゃくちゃ嬉しい」）
【4】運営者の弱み・限界の開示 → 「あなたが必要」という参加の大義名分を与える（例:「1人で栃木盛り上げるのは限界があるから」）
【5】イベント実務情報は別投稿で淡々と切り出す → 感情装飾を抑え、日時・場所・時間のみ
【6】CTAは常に疑問形、命令形を避ける（例:「興味ある人いるかな🤔」「一緒に走ってくれる人いますか？」）
【7】ハッシュタグはほぼ使わない。地域名を投稿冒頭のタグ的位置に置くのみ
```

効く理由 / 特徴: 高テンション・感嘆符多用。leven_base / riki.days_ にはない「社会課題としての大義名分」「運営者自身の弱みの開示」が特徴。

### G. 参加者体験談型（UGC）（出典: hi.hi.hi999, tomokazu_0008）

```
【1】素直な弱み・不安の告白から入る（例:「人見知りだけど」「1キロも走れない」「正直ちょっと迷ってたけど」）
【2】参加した結果のギャップを描写する（例:「自然と仲良くなれた」「疲れたと言える環境がありがたい」「一歩踏み出して正解だった」）
【3】感情のピークを絵文字で強調（🤍❤️‍🔥🫶）＋「次も参加したい」「もっと早く知りたかった」で継続意欲を見せる
【4】主催アカウントに言及・タグ付け（@leven_base）→ 第三者の信頼を橋渡しする
```

**G2（tomokazu_0008 のみに見られるハイブリッド、体験談＋告知）**

```
【5】過去の自分との対比で変化を語る（例:「太ってた時の自分じゃ想像できてなかった」）
【6】「1人じゃ不安、1人じゃ頑張れないかも」という共感フックの後に「一緒にやりましょう！！」
【7】自らイベント情報（日時・場所・内容）も発信し、ベネフィットを箇条書きで提示（例:「・新しい友達の発見 ・ランニングってそんなに辛くないじゃん ・週末の楽しみのきっかけ」）
【8】CTAは常に疑問形「一緒にやりましょう？」「一緒に走りましょう？」
```

効く理由 / 特徴: 主催者目線ではなく参加者目線。第三者の社会的証明として、A〜F型の主催者投稿を補強する役割。将来的に「参加者に発信してもらう」戦略オプションとしても記録価値あり。

> **見出しレベルの記法制約（重要 / 全型共通）**
>
> 1. **各型は `## A.` 〜 `## G.` の H2 見出し**で pattern-library.md に書くこと。
>    本 `## inputs` セクション内では playbook の階層構造の都合で `### A.` の H3 で記載しているが、
>    **これをそのまま H3 で写経すると全型が区間抽出にヒットせず FAIL する**（偽 FAIL）。
>    成果物側では必ず H2 に格上げすること。
> 2. **G2 は `### ` の H3 サブ見出し**として `## G.` セクションの内部に書くこと。
>    `## G2.` のような H2 で書くと G セクションが閉じ、
>    【5】〜【8】が G の区間外に出て検証が FAIL する（実測確認済み）。
> 3. `### 型の構造` `### 効く理由` などの小見出しは H3 を使うこと（H2 にすると型セクションが閉じる）。

### 共通ルール（leven_base 全体を貫く / 執筆時の一般注意）

- 絵文字は1〜2個まで
- 「☺︎」「🙏」など柔らかい絵文字で毒気を抜く
- タメ口＋短文＋改行を多用
- 地域名は告知系の投稿にだけ出す
- 「本来の目的は活動そのものではない」ことを繰り返し明言する

### PDCA 全体設計（ユーザーと合意済み）

```yaml
データ取得: 参考アカウントの投稿は毎回ユーザーがコピペで手渡し（API/スクレイピングなし）
型ライブラリの粒度: アカウント別ではなく型を統合した1つのライブラリ
自分の実績データ: 投稿後にユーザーが手入力で報告
PDCA を回す頻度: 投稿ごとの簡易チェックと、週次/月次のまとめ振り返りの両方を使い分ける
```

---

## exclusions（このタスクでやらないこと）

```yaml
out_of_scope:
  - Threads API / スクレイピングによる投稿データの自動取得
    → 参考アカウントの投稿・自分の実績は毎回ユーザーが手渡しする（合意済み）
  - アカウント別の型ライブラリ分割 → 型を統合した1ライブラリのみ（合意済み）
  - A〜G 以外の型の追加 → 7型で確定。以降の型追加は別 playbook で起票
  - my-posts-log.md への実データ投入 → テンプレート（ヘッダのみ）まで
  - 既存スキル（instagram-フック型ショート台本.md / X運用.md 等）の改変
    → frontmatter 形式・トーンを参照するのみ。既存ファイルは変更しない
  - 実際の Threads 投稿の作成・投稿代行
  - 参加者（G型アカウント）への発信依頼など運用施策の実行 → 型としての記録のみ
  - project.md への milestone / done_when 追加（ユーザー資産追加のため derives_from: null）
  - .claude/agents/critic.md の未コミット変更、.claude/worktrees/ の untracked 対応
    → 本タスク以前から存在する変更。触らない（final_tasks の git add でも対象外）
  - plan/playbook-setup-instagram-skills.md（前 playbook, untracked）の再開・削除
    → 本タスクでは触らない
  - feat/threads-community-skill ブランチの削除
    → 同一コミット列が chore/setup-instagram-skills と origin に存在するため放置で安全
```

---

## 破棄タスクの後処理（前提記録）

```yaml
破棄対象: playbook-threads-community-skill（riki.days_ 地域コミュニティ勧誘型スキル）

判断と対応:
  - plan/playbook-threads-community-skill.md: 削除済み
    理由: untracked（一度もコミットされていない）かつタスク自体が破棄決定のため、
          放置すると playbook ディレクトリに死んだ計画が残り誤読の原因になる
    影響: untracked ファイル1件の削除のみ。git 履歴・main には一切影響なし
    備考: 当該タスクで扱っていた riki.days_ の分析は、本 playbook の型E として吸収済み
  - 成果物ファイル（.claude/skills/threads-地域コミュニティ勧誘型.md）: そもそも未作成のため対応不要
  - feat/threads-community-skill ブランチ: 放置（削除しない）
    理由: 同ブランチ上の 14 コミット（各種スキル追加、6b89e13 まで）は破棄タスクとは無関係の
          ユーザー資産である。同じ 6b89e13 はローカルの chore/setup-instagram-skills と
          本作業ブランチ feat/threads-pdca-foundation からも到達可能なため、
          仮に削除してもコミットは失われない。ただし削除する利得もないため放置する。
    注記（2026-08-05 実測）: origin/chore/setup-instagram-skills は 2cb6af0 であり、
          最新の 6b89e13（スキルファイル名の日本語リネーム）は未 push である。
          したがって「リモートにも同一コミットがある」わけではない。
          ローカル2ブランチから到達可能なため結論（放置で安全）は変わらないが、
          6b89e13 のバックアップはローカルのみである点に留意すること。

新ブランチ:
  name: feat/threads-pdca-foundation
  base: 6b89e13（= feat/threads-community-skill の HEAD）
  base を main にしなかった理由: |
    main（6a4030e）には既存スキル 14 コミットがまだマージされていない。
    main から分岐すると作業ツリーから既存スキル群が消え、
    「既存スキルの frontmatter 形式・トーンに合わせる」という要件を
    同一ブランチ上で検証できなくなるため。
    main へは一切コミットしていない（CLAUDE.md 8章 branch_rule 遵守）。
```

---

## rollback

```yaml
手順:
  1. rm -rf .claude/skills/threads-pdca
  2. state.md の playbook.active / branch / goal.done_criteria を本 playbook 適用前の値に戻す
  3. rm plan/playbook-threads-pdca-foundation.md
  4. git checkout chore/setup-instagram-skills && git branch -D feat/threads-pdca-foundation

影響範囲: 新規ディレクトリ .claude/skills/threads-pdca/ の追加のみ。
副作用: なし（既存スキル・Hook・main に影響しない）
```

---

## phases

### p1: 型ライブラリ（pattern-library.md）の構築

**goal**: `## inputs` に固定した A〜G の7型と共通ルールを、再利用可能な構造で pattern-library.md に格納する

#### subtasks

- [ ] **p1.1**: `.claude/skills/threads-pdca/references/` ディレクトリが存在する
  - executor: claudecode
  - test_command: `test -d .claude/skills/threads-pdca/references && echo PASS || echo FAIL`
  - validations:
    - technical: "ディレクトリが実際に作成されている"
    - consistency: "既存スキルの配置規約（.claude/skills/ 配下）に従っている"
    - completeness: "SKILL.md と references/ の2階層が作れる状態である"

- [ ] **p1.2**: pattern-library.md の A〜G の7型セクションが、各区間内に『出典』『型の構造』『効く理由』と行頭 `【` の構造行を型別下限（A〜D:3 / E:7 / F:7 / G:8）以上持つ
  - executor: claudecode
  - test_command: |
    F=.claude/skills/threads-pdca/references/pattern-library.md
    test -f "$F" || { echo "FAIL(ファイルなし)"; exit 1; }
    FAILS=$(printf '%s\n' "A|3" "B|3" "C|3" "D|3" "E|7" "F|7" "G|8" | while IFS='|' read -r T MIN; do
      SEC=$(awk -v s="^## ${T}[.]" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$F")
      echo "$SEC" | grep -q '出典' || echo "[$T:出典なし]"
      echo "$SEC" | grep -q '型の構造' || echo "[$T:型の構造なし]"
      echo "$SEC" | grep -q '効く理由' || echo "[$T:効く理由なし]"
      [ "$(echo "$SEC" | grep -c '^【')" -ge "$MIN" ] || echo "[$T:構造行が${MIN}未満]"
    done)
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "`[.]` により早見表見出しへの誤マッチを回避し、終端 `^#{1,2} ` により H1 への内容逃がしを封じた上で、7型全てが型別下限を満たす"
    - consistency: "型記号 A〜G が `## inputs` の7型一覧表および SKILL.md の参照表記と一致している"
    - completeness: "A〜G の7型が全て揃い、E/F は7要素、G は G2 を含む8要素が記録されている"

- [ ] **p1.3**: pattern-library.md の各型区間内に、その型の出典アカウント名と型固有キーワードが記載されている
  - executor: claudecode
  - test_command: |
    F=.claude/skills/threads-pdca/references/pattern-library.md
    FAILS=$(printf '%s\n' \
      "A|leven_base" "A|ハッシュタグ" "A|CTA" \
      "B|leven_base" "B|弱み" "B|質問" \
      "C|leven_base" "C|連投" "C|人生観" \
      "D|leven_base" "D|日時" "D|ベネフィット" "D|コメント待ってます" \
      "E|riki.days_" "E|オープンチャット" "E|タメ口" \
      "F|iam_kk_620" "F|大義名分" "F|疑問形" \
      "G|hi.hi.hi999" "G|tomokazu_0008" "G|G2" "G|@leven_base" \
      | while IFS='|' read -r T KW; do
      SEC=$(awk -v s="^## ${T}[.]" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$F")
      echo "$SEC" | grep -qF "$KW" || echo "[$T:$KW なし]"
    done)
    ECNT=$(awk -v s="^## E[.]" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$F" | grep -c 'オープンチャット')
    [ "$ECNT" -ge 3 ] || FAILS="${FAILS}[E:オープンチャット出現${ECNT}回(verbatim CTA の記録漏れ。3回以上必要)]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "出典アカウント名を grep -F（固定文字列）で照合するため riki.days_ 等のドットが正規表現メタとして誤作動しない。全型を leven_base と書く手抜きは E/F/G で FAIL する。E 区間の『オープンチャット』出現回数を3回以上とすることで verbatim CTA 4種の記録漏れを検出する（忠実な転記なら【6】＋CTA 3種で4回出現する）"
    - consistency: "本 playbook `## inputs` の7型定義と逐語的に照合し、齟齬がない（キーワードだけの創作でないことを目視確認する）"
    - completeness: "各型の構造・効く理由・出典に加え、G は G2 サブ見出しまで記録されている"

- [ ] **p1.4**: pattern-library.md の『## 執筆時の一般注意』区間内に共通ルールの箇条書きが5項目以上あり、絵文字・タメ口・地域名・活動そのもの に言及している
  - executor: claudecode
  - test_command: |
    F=.claude/skills/threads-pdca/references/pattern-library.md
    SEC=$(awk '/^## 執筆時の一般注意/{f=1;next} /^#{1,2} /{f=0} f' "$F")
    echo "$SEC" | grep -q '絵文字' && echo "$SEC" | grep -q 'タメ口' && echo "$SEC" | grep -q '地域名' && echo "$SEC" | grep -q '活動そのもの' && [ "$(echo "$SEC" | grep -c '^- ')" -ge 5 ] && echo PASS || echo FAIL
  - validations:
    - technical: "見出し区間の抽出結果に対して5項目以上の箇条書きが検出される"
    - consistency: "`## inputs` の共通ルール5点と逐語的に一致し、A〜G の各型記述とも矛盾しない"
    - completeness: "合意済みの共通ルール5点が全て記録されている"

**status**: pending
**max_iterations**: 5
**priority**: high

---

### p2: 投稿ログ（my-posts-log.md）テンプレートの作成

**goal**: 自分の投稿実績を毎回追記していくためのテーブルテンプレートと記入方法を用意する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: my-posts-log.md の『ログ』を含む H2 見出し区間内の1行目が5列ヘッダ行、2行目が5列の区切り行である
  - executor: claudecode
  - test_command: |
    L=.claude/skills/threads-pdca/references/my-posts-log.md
    test -f "$L" || { echo "FAIL(ファイルなし)"; exit 1; }
    [ "$(grep -c '^## .*ログ' "$L")" -ge 1 ] || { echo "FAIL(ログ見出しなし)"; exit 1; }
    ROWS=$(awk '/^## .*ログ/{f=1;next} /^#{1,2} /{f=0} f' "$L" | grep -E '^\|')
    echo "$ROWS" | head -1 | grep -qF '| 日付 | 投稿文（要約） | 狙った型 | 実績（いいね/コメント/保存） | 気づき |' || { echo "FAIL(ヘッダ行がログ区間内にない)"; exit 1; }
    echo "$ROWS" | sed -n 2p | grep -qE '^\|[-: ]+\|[-: ]+\|[-: ]+\|[-: ]+\|[-: ]+\|$' && echo PASS || echo "FAIL(5列の区切り行が直後にない)"
  - validations:
    - technical: "ヘッダ行と区切り行の両方を『ログ区間内の表の1行目・2行目』として位置指定で検証する。ファイル全体 grep ではないため、別セクションに正しいヘッダを置いてログ区間には無関係な表を書く偽装が通らない"
    - consistency: "列名『狙った型』が pattern-library.md の A〜G 記号と対応している"
    - completeness: "区切り行を5セル固定の正規表現で検証するため、3列など列数の異なる表を PASS させない"

- [ ] **p2.2**: my-posts-log.md の『ログ』を含む H2 見出し区間内のテーブル行がヘッダ＋区切りの2行のみである（データ行0件）
  - executor: claudecode
  - test_command: |
    L=.claude/skills/threads-pdca/references/my-posts-log.md
    [ "$(grep -c '^## .*ログ' "$L")" -ge 1 ] || { echo "FAIL(ログ見出しなし)"; exit 1; }
    SEC=$(awk '/^## .*ログ/{f=1;next} /^#{1,2} /{f=0} f' "$L")
    [ "$(echo "$SEC" | grep -cE '^\|')" -eq 2 ] && echo PASS || echo FAIL
  - validations:
    - technical: "見出し名を `/^## .*ログ/` で緩く受けつつ、見出しの存在自体は別途必須化し、区間内テーブル行数を厳密に2行へ限定している"
    - consistency: "done_when 6 が要求する『ログを含む H2 見出し』の存在と一致する"
    - completeness: "ダミーデータや例示行が混入していない"

- [ ] **p2.3**: my-posts-log.md の『## 記入方法』区間内に箇条書きが5項目以上存在し、『狙った型』の記入規則が説明されている
  - executor: claudecode
  - test_command: |
    L=.claude/skills/threads-pdca/references/my-posts-log.md
    SEC=$(awk '/^## 記入方法/{f=1;next} /^#{1,2} /{f=0} f' "$L")
    [ "$(echo "$SEC" | grep -c '^- ')" -ge 5 ] && echo "$SEC" | grep -q '狙った型' && echo "$SEC" | grep -q 'pattern-library' && echo PASS || echo FAIL
  - validations:
    - technical: "記入方法区間に5項目以上の説明が存在する"
    - consistency: "『狙った型』欄に A〜G の記号を書く旨が pattern-library.md 参照とともに説明されている"
    - completeness: "5列全ての記入ルールが説明されている"

**status**: pending
**max_iterations**: 5
**priority**: high

---

### p3: PDCA ワークフロースキル（SKILL.md）の作成

**goal**: 新規アカウント分析 / Plan / Check / Act の4ワークフローを持つスキル本体を作成する

**depends_on**: [p1, p2]

#### subtasks

- [ ] **p3.1**: SKILL.md の先頭 frontmatter ブロック内に `name: threads-pdca`（ディレクトリ名と一致）と description: が存在し、description に「」で囲まれたトリガーフレーズが2個以上含まれている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$S")
    echo "$FM" | grep -q '^name: threads-pdca$' && echo "$FM" | grep -q '^description:' && [ "$(echo "$FM" | grep -o '「' | wc -l | tr -d ' ')" -ge 2 ] && echo PASS || echo FAIL
  - validations:
    - technical: "1行目から始まる frontmatter ブロックのみを抽出して検証している（本文の name: を誤検出しない）"
    - consistency: "ディレクトリ形式スキル（lint-checker / state / plan-management）と同じく name がディレクトリ名と一致し、小文字ハイフン表記である。description の文体は既存スキルの『〜と伝えると起動します』に合わせる"
    - completeness: "4ワークフロー全ての発火フレーズが description に反映されている"

- [ ] **p3.2**: SKILL.md の『## ワークフロー1』〜『## ワークフロー4』の各区間内に『発火フレーズ』行・番号付きステップ3個以上・references/ 配下ファイルへの参照が存在する
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    for N in 1 2 3 4; do
      SEC=$(awk -v s="^## ワークフロー${N}" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$S")
      echo "$SEC" | grep -q '発火フレーズ' && echo "$SEC" | grep -q 'references/' && [ "$(echo "$SEC" | grep -cE '^[0-9]+\.')" -ge 3 ] || { echo "FAIL(WF$N)"; exit 1; }
    done; echo PASS
  - validations:
    - technical: "4セクション全てが区間内検証を PASS し、H1 やファイル末尾への内容逃がしが効かない"
    - consistency: "各ワークフローが参照するファイルパスが p1/p2 で作成した実ファイルと一致する"
    - completeness: "新規アカウント分析 / Plan / Check / Act の4種が揃っている"

- [ ] **p3.3**: 各ワークフローの区間内に、そのワークフロー固有の処理（型の統合ルール／型選択／ログ追記／集計）が明記されている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    W1=$(awk '/^## ワークフロー1/{f=1;next} /^#{1,2} /{f=0} f' "$S"); W2=$(awk '/^## ワークフロー2/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    W3=$(awk '/^## ワークフロー3/{f=1;next} /^#{1,2} /{f=0} f' "$S"); W4=$(awk '/^## ワークフロー4/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    echo "$W1" | grep -q 'pattern-library.md' && echo "$W1" | grep -q '統合' && echo "$W1" | grep -q '出典' &&
    echo "$W2" | grep -q 'pattern-library.md' && echo "$W2" | grep -q '下書き' &&
    echo "$W3" | grep -q 'my-posts-log.md' && echo "$W3" | grep -qE 'いいね|コメント' &&
    echo "$W4" | grep -q 'my-posts-log.md' && echo "$W4" | grep -qE '集計|傾向' &&
    echo PASS || echo FAIL
  - validations:
    - technical: "各ワークフロー区間に固有キーワードが存在する"
    - consistency: "ワークフロー1の追記先と p1 で作った pattern-library.md の構造（型記号・出典の書式）が矛盾しない"
    - completeness: "『重複なら統合・新規なら追加・出典アカウント名を残す』という合意済み仕様が明記されている"

- [ ] **p3.4**: SKILL.md 内に references/ 配下への参照パスが2種類以上あり、その全てが実在ファイルに解決する
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    PATHS=$(grep -oE 'references/[a-z0-9./-]+\.md' "$S" 2>/dev/null | sort -u)
    [ "$(echo "$PATHS" | grep -c 'references/')" -ge 2 ] || { echo "FAIL(参照が2種類未満)"; exit 1; }
    MISS=$(echo "$PATHS" | while IFS= read -r P; do [ -n "$P" ] && { test -f ".claude/skills/threads-pdca/$P" || echo "$P"; }; done)
    [ -z "$MISS" ] && echo PASS || echo "FAIL(MISSING: $MISS)"
  - validations:
    - technical: "参照が0件のときに空振り PASS しない（2種類以上を下限として要求）。zsh でも単語分割に依存しない while read 方式"
    - consistency: "ディレクトリ構成（SKILL.md と references/ が同階層）と一致している"
    - completeness: "リンク切れが0件である"

**status**: pending
**max_iterations**: 5
**priority**: high

---

### p_final: 完了検証（必須）

> **goal.done_when が実際に満たされているか最終検証する。存在チェックのみは禁止。**

#### subtasks

- [ ] **p_final.1**: done_when 1（SKILL.md frontmatter）が満たされている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    test -f "$S" || { echo FAIL; exit 1; }
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$S")
    echo "$FM" | grep -q '^name: threads-pdca$' && echo "$FM" | grep -q '^description:' && [ "$(echo "$FM" | grep -o '「' | wc -l | tr -d ' ')" -ge 2 ] && echo PASS || echo FAIL
  - validations:
    - technical: "frontmatter ブロック区間のみで検証が成立する"
    - consistency: "name がディレクトリ名 threads-pdca と一致する"
    - completeness: "name / description の両方が存在する"

- [ ] **p_final.2**: done_when 2（4ワークフローの中身）が満たされている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    for N in 1 2 3 4; do
      SEC=$(awk -v s="^## ワークフロー${N}" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$S")
      echo "$SEC" | grep -q '発火フレーズ' && echo "$SEC" | grep -q 'references/' && [ "$(echo "$SEC" | grep -cE '^[0-9]+\.')" -ge 3 ] || { echo "FAIL(WF$N)"; exit 1; }
    done; echo PASS
  - validations:
    - technical: "4セクション全てが区間内検証を PASS する"
    - consistency: "参照パスが実ファイルに解決する（p3.4 と整合）"
    - completeness: "4ワークフロー全てに発火条件・手順・参照先がある"

- [ ] **p_final.3**: done_when 3（A〜G の7型セクションと型別構造行下限）が満たされている
  - executor: claudecode
  - test_command: |
    F=.claude/skills/threads-pdca/references/pattern-library.md
    test -f "$F" || { echo "FAIL(ファイルなし)"; exit 1; }
    FAILS=$(printf '%s\n' "A|3" "B|3" "C|3" "D|3" "E|7" "F|7" "G|8" | while IFS='|' read -r T MIN; do
      SEC=$(awk -v s="^## ${T}[.]" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$F")
      echo "$SEC" | grep -q '出典' || echo "[$T:出典なし]"
      echo "$SEC" | grep -q '型の構造' || echo "[$T:型の構造なし]"
      echo "$SEC" | grep -q '効く理由' || echo "[$T:効く理由なし]"
      [ "$(echo "$SEC" | grep -c '^【')" -ge "$MIN" ] || echo "[$T:構造行が${MIN}未満]"
    done)
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "7型全ての区間内検証が型別下限つきで PASS する"
    - consistency: "型記号 A〜G が SKILL.md / my-posts-log.md の記述と一致する"
    - completeness: "構造・効く理由・出典の3要素が全型に揃い、G は G2 を含む8構造行がある"

- [ ] **p_final.4**: done_when 4（各型の出典アカウント名）が満たされている
  - executor: claudecode
  - test_command: |
    F=.claude/skills/threads-pdca/references/pattern-library.md
    FAILS=$(printf '%s\n' "A|leven_base" "B|leven_base" "C|leven_base" "D|leven_base" "E|riki.days_" "F|iam_kk_620" "G|hi.hi.hi999" "G|tomokazu_0008" | while IFS='|' read -r T ACC; do
      SEC=$(awk -v s="^## ${T}[.]" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$F")
      echo "$SEC" | grep -qF "$ACC" || echo "[$T:$ACC なし]"
    done)
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "grep -F によりドットを含むアカウント名（riki.days_）を誤作動なく照合する"
    - consistency: "`## inputs` の7型一覧表の出典列と完全に一致する"
    - completeness: "G は2アカウント（hi.hi.hi999 / tomokazu_0008）とも記載されている"

- [ ] **p_final.5**: done_when 5（共通ルール）が満たされている
  - executor: claudecode
  - test_command: |
    F=.claude/skills/threads-pdca/references/pattern-library.md
    SEC=$(awk '/^## 執筆時の一般注意/{f=1;next} /^#{1,2} /{f=0} f' "$F")
    echo "$SEC" | grep -q '絵文字' && echo "$SEC" | grep -q 'タメ口' && echo "$SEC" | grep -q '地域名' && echo "$SEC" | grep -q '活動そのもの' && [ "$(echo "$SEC" | grep -c '^- ')" -ge 5 ] && echo PASS || echo FAIL
  - validations:
    - technical: "共通ルール区間に5項目以上の箇条書きが存在する"
    - consistency: "`## inputs` の共通ルール5点と一致し、各型の記述と矛盾しない"
    - completeness: "合意済みの5ルールが全て記録されている"

- [ ] **p_final.6**: done_when 6（投稿ログテンプレート）が満たされている
  - executor: claudecode
  - test_command: |
    L=.claude/skills/threads-pdca/references/my-posts-log.md
    test -f "$L" || { echo "FAIL(ファイルなし)"; exit 1; }
    [ "$(grep -c '^## .*ログ' "$L")" -ge 1 ] || { echo "FAIL(ログ見出しなし)"; exit 1; }
    ROWS=$(awk '/^## .*ログ/{f=1;next} /^#{1,2} /{f=0} f' "$L" | grep -E '^\|')
    [ "$(echo "$ROWS" | grep -c '^|')" -eq 2 ] || { echo "FAIL(ログ区間の表がヘッダ+区切りの2行でない)"; exit 1; }
    echo "$ROWS" | head -1 | grep -qF '| 日付 | 投稿文（要約） | 狙った型 | 実績（いいね/コメント/保存） | 気づき |' || { echo "FAIL(ヘッダ行がログ区間内にない)"; exit 1; }
    echo "$ROWS" | sed -n 2p | grep -qE '^\|[-: ]+\|[-: ]+\|[-: ]+\|[-: ]+\|[-: ]+\|$' || { echo "FAIL(5列の区切り行なし)"; exit 1; }
    SEC=$(awk '/^## 記入方法/{f=1;next} /^#{1,2} /{f=0} f' "$L")
    [ "$(echo "$SEC" | grep -c '^- ')" -ge 5 ] && echo PASS || echo "FAIL(記入方法)"
  - validations:
    - technical: "ログ区間内の表が『2行のみ・1行目が5列ヘッダ・2行目が5列区切り』を同時に満たすことを位置指定で検証する。別セクションへの逃がしもデータ行の混入も通らない"
    - consistency: "列定義が SKILL.md の Check ワークフローの記録項目と一致する"
    - completeness: "テーブルと記入方法の両方が存在する"

- [ ] **p_final.7**: state.md の playbook.active / branch / goal.done_criteria が本 playbook と一致している
  - executor: claudecode
  - test_command: |
    grep -q 'active: plan/playbook-threads-pdca-foundation.md' state.md &&
    grep -q 'branch: feat/threads-pdca-foundation' state.md &&
    grep -q 'threads-pdca/SKILL.md' state.md &&
    grep -q 'threads-pdca/references/pattern-library.md' state.md &&
    grep -q 'threads-pdca/references/my-posts-log.md' state.md &&
    grep -qF 'riki.days_' state.md && grep -q 'iam_kk_620' state.md && grep -q 'tomokazu_0008' state.md &&
    [ "$(awk '/^done_criteria:/{f=1;next} /^```/{f=0} f' state.md | grep -c '^  - ')" -eq 6 ] &&
    [ "$(git branch --show-current)" = "feat/threads-pdca-foundation" ] && echo PASS || echo FAIL
  - validations:
    - technical: "state.md の done_criteria が6件あり、3成果物パスと E/F/G の出典アカウント名に言及している"
    - consistency: "四つ組（focus / state / playbook / branch）の整合性が取れている"
    - completeness: "playbook の goal.done_when（6件）と state.md の goal.done_criteria（6件）が同一内容である"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: repository-map.yaml を更新する
  - command: `bash .claude/hooks/generate-repository-map.sh`
  - status: pending

- [ ] **ft2**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: pending

- [ ] **ft3**: 本タスクの成果物のみをステージしてコミットする
  - command: `git add .claude/skills/threads-pdca plan/playbook-threads-pdca-foundation.md state.md && git commit -m "feat(skills): Threads PDCA 基盤スキル追加（7型ライブラリ）" && git status --short`
  - status: pending
  - note: |
      `git add -A` は禁止。exclusions で「触らない」と明記した
      .claude/agents/critic.md / .claude/worktrees/（embedded git repo 2件・約4.5MB・.gitignore 未登録）/
      plan/playbook-setup-instagram-skills.md を巻き込むため。

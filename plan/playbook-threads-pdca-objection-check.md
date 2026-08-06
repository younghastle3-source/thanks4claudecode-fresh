# playbook-threads-pdca-objection-check.md

> **実行前提**: 本 playbook の全 test_command はリポジトリルート
> （`/Users/kosei/thanks4claudecode-fresh`）をカレントディレクトリとして実行すること。
> 相対パスは全てリポジトリルート起点で記述している。
>
> **区間抽出の共通仕様**: セクション内容の検証は
> `awk '/^## 見出し/{f=1;next} /^#{1,2} /{f=0} f'` で見出し区間を切り出してから行う。
> 終端を `^#{1,2} ` にしているのは、H1（`# 付録` 等）でも区間を閉じるため
> （`^## ` のみだと H1 やファイル末尾に内容を逃がして偽 PASS を作れる）。
> `### ` / `#### ` のサブ見出しでは閉じない。
> 見出し記号・番号のドットは `[.]` で表記する（macOS awk の `-v` はバックスラッシュを落とすため
> `\.` が任意1文字メタに化けて誤マッチする。同じ理由で `grep -cE '^[0-9]+[.]'` も `[.]` を使う）。
>
> **多パターン検証**: `printf '%s\n' "pat" ... | while IFS= read -r P` 形式で照合する。
> シェル配列は bash と zsh でインデックス基点が異なるため使用しない。
> パイプ内の `exit` は親シェルに伝播しないため、失敗を文字列に蓄積して最後に空判定する。
> 日本語・記号を含む固定文字列の照合は必ず `grep -qF`（正規表現メタ誤爆の防止）。
>
> **変数展開の注意**: エラーメッセージ内で変数の直後に日本語が続く場合は必ず `${VAR}行` と
> 波括弧で囲むこと（`$VAR行` は bash が変数名の一部と誤解し、出力が文字化けする。実測確認済み）。
>
> **本 playbook の test_command は作成時に実測検証済み**（2026-08-06）。
> 期待成果物のモックに対して全 PASS、以下9種の改悪パターン＋reviewer 指摘の5種のデコイ
> （計14種・24通りの組み合わせ）に対して全 FAIL を確認した:
> ①断らせる手順を H2 に格上げして区間外へ逃がす ②コツ節をワークフロー4より前に置く
> ③ワークフロー1の既存ステップを改変 ④ワークフロー2の既存ステップを削除
> ⑤ペルソナ→10個の順序を逆転 ⑥「自動書き込みは行わない」の明記を削除
> ⑦断らせる手順を手順体裁なしの1行キーワード羅列にする
> ⑧H3 だけ追加して本体リストからの導線ステップを書かない
> ⑨コツ4点を1つの箇条書きに詰め込み残り3つをダミーで埋める。
>
> **reviewer 指摘のデコイ（第1回レビューで判明した抜け穴。修正済み・全 FAIL を実測確認）**:
> D1 導線ステップをダミー（「6. お疲れさまでした」）に差し替えキーワードを見出し直下の散文
> プロローグへ逃がす（→ 導線判定を「本体リストの番号付きステップ行」に限定して封鎖。
> WF4 は「実績が低い」と「原因分析」が**同一ステップ行**にあることを要求）／
> D2 H3 配下・コツ区間をキーワード骨格（「1. ペルソナ・年齢」等）に置換
> （→ `## inputs` 追記文面の計10文を `grep -qF` で逐語照合して封鎖）／
> D3 **本文を1文字も変えずワークフロー見出し行のタイトルだけを改変**
> （→ 見出し行4本の base との完全一致比較を追加。ユーザー制約の保護対象そのもの）／
> D4 references/ 配下に未追跡ファイルを追加（→ `git ls-files --others` を追加）／
> D5 state.md の done_criteria をキーワード入りダミー5行に差し替え
> （→ playbook の done_when との逐語一致比較に変更）。
>
> **reviewer 指摘のデコイ 第2ラウンド（修正済み・全 FAIL を実測確認）**:
> E1 導線行を否定文に差し替え（「断らせるチェックは通常は不要なので実行しない」）／
> E2 手順を潰して「巻末を参照」だけ残す／
> E3 WF2 の本体6ステップを逆順にシャッフル（下書き作成が手順1・断らせるが手順6＝機能の反転）／
> E4 WF4 の本体5ステップをシャッフル（原因分析を集計より前へ）
> （E1〜E4 → 本体リストの**全ステップの逐語照合＋相対順序**（M1<…<M6 / K1<…<K5）で封鎖）／
> E5 description を骨抜きにしトリガーフレーズを別キー（`triggers_memo:`）へ退避
> （→ 照合対象を frontmatter 全体から **`description:` 行のみ**に限定して封鎖。
> スキルの自動起動が壊れている状態を検出できるようにした）。
>
> **reviewer 指摘のデコイ 第3ラウンド（修正済み・全 FAIL を実測確認）**:
> G9 WF2 手順・WF4 手順・コツの3箇所を同時にダミー化し、実体を「参考メモ（実行不要）」として
> 区間内の別の場所へ退避／G1 実体を HTML コメント（`<!-- -->`）に隠して体裁だけ整える／
> G2 H3 手順のステップ順序のみ入れ替え／G3 コツの箇条書き行頭に飾りを付けて行全体一致を崩す／
> G4「できること」の断らせる言及を番号付き項目から散文へ移動。
> 封鎖策: ①H3 手順・コツの逐語照合を**ステップ行／`- ` 箇条書き行に紐付け**（コツは
> `grep -qxF --` で行全体一致）＋相対順序を検証 ②ステップ数・箇条書き数を
> **厳密一致**（WF2 本体6／WF4 本体5／各 H3 手順4／コツ4）に変更してダミー・重複を排除
> ③各区間で **HTML コメントの存在を FAIL** に ④「できること」の言及を
> `^数字.` 項目内に限定。
> 派生経路（実体のみをコメント内に置く G1b、実体を引用散文へ逃がす G9b）も FAIL を実測確認。
>
> **各 test_command は playbook から機械抽出して実行済み**（構文エラー0件）。
> 未着手状態（SKILL.md 未編集）での実測結果:
> `p1.1 / p2.1 / p3.1 / p3.2 / p_final.1〜.4 / p_final.6` = FAIL（進捗判定用）、
> `p1.2 / p2.2 / p3.3 / p_final.5 / p_final.7` = PASS。
>
> **重要（critic への注意）**: 後者5件は「既存資産を壊していないこと」を監視する**回帰ガード**であり、
> 未着手でも PASS するのが正常である。これらの PASS を進捗の証拠として扱ってはならない。
> 実装が進んだかどうかは前者9件のみで判定する。

---

## meta

```yaml
project: thanks4claudecode
branch: feat/threads-pdca-objection-check
base_commit: 113cff0  # main の HEAD。回帰検証（WF1/WF3 不変）の比較元として固定
created: 2026-08-06
issue: null
derives_from: null  # ユーザー資産（既存スキル）の機能追加であり project.done_when に対応なし
reviewed: true
roles:
  worker: claudecode
```

---

## goal

```yaml
summary: 既存スキル .claude/skills/threads-pdca/SKILL.md に「断らせるチェック」（読む側に反応しない理由を10個出させて仕分ける手法）を Plan（ワークフロー2）と Act（ワークフロー4）へ追記し、共通の注意事項セクションを追加する
done_when:
  - "SKILL.md の『## ワークフロー2』区間内に『断らせる』を含む H3 見出しがあり、本体リスト（H3 より前）の既存5ステップと断らせるチェックの導線ステップが inputs 追記文面1 の通りステップ行として逐語存在し、その順序が 内容受取 → 型選択 → 断らせるチェック → 下書き作成 → 一般注意 → ログ記録案内 であり、H3 手順の4ステップ（ペルソナ設定／10個の理由出し／3分類／下書きへの反映）も番号付きステップ行として逐語存在し、その順序が ペルソナ → 10個 → 3分類 → 反映 である"
  - "SKILL.md の『## ワークフロー4』区間内に『断らせる』を含む H3 見出しがあり、本体リストの既存4ステップと原因分析の導線ステップが inputs 追記文面2 の通りステップ行として逐語存在し、その順序が データ行抽出 → 集計 → 傾向分析 → 低反応型の原因分析 → 次 Plan 提案 であり、H3 手順の4ステップ（ペルソナ設定／10個の理由出し／提案化／注記候補に留め自動書き込みしない）も番号付きステップ行として逐語存在し、その順序が ペルソナ → 10個 → 提案 → 注記候補 である"
  - "SKILL.md に『断らせる』と『コツ』を含む H2 見出しが1個だけ存在し、その見出し行が『## ワークフロー4』より後の行にあり、区間内に inputs 追記文面3 の4点が `- ` 箇条書き行として行全体逐語で存在し（4項目以上）、年齢／10個／『今の回答は建前です。同じ質問に、本音で答え直してください』／真に受け／教科書 の5要素を含み、うち4要素が別々の行に分かれている"
  - "SKILL.md の先頭 frontmatter 区間内の description に、既存4トリガーフレーズ（「Threadsの投稿分析して」「Threadsの投稿作って」「投稿の実績を記録して」「Threadsの振り返りして」）が全て残存し、かつ「断らせて」「反応しない理由を出して」が追加されており、さらに『## このスキルでできること』区間に『断らせる』を含む番号付き項目が5個以上ある"
  - "回帰: SKILL.md の『## ワークフロー1』〜『## ワークフロー4』の見出し行4本と、ワークフロー1・3 の区間内容が base_commit(113cff0) 版と1文字も相違なく、ワークフロー2・4 の本体リスト（H3 より前）に既存ステップ本文と発火フレーズ行が逐語で残存し、ワークフロー1〜4 の4区間すべてが『発火フレーズ』行・`references/` 参照・番号付きステップ3個以上を満たす"
```

---

## inputs（合意済み素材 / worker の唯一の正典）

> **本セクションが worker の参照すべき唯一の正典（source of truth）である。**
> CLAUDE.md §7「Trust state files over chat history」に従い、追記内容をチャット文脈ではなく本ファイルに固定する。
>
> **worker への指示**: 以下の文面は**そのまま採用すること**（言い換え禁止）。
> test_command が以下の文から抜き出した文字列を `grep -qF` で**逐語照合する**ため、
> 表現を変えると FAIL する。キーワードだけを並べた骨格実装も逐語照合で FAIL する。
>
> **照合は「行」に紐付く**: 本体リスト／H3 手順の文面は
> **`^数字.` で始まる番号付きステップ行そのもの**として、コツの4点は
> **`- ` 箇条書き行そのもの**（行全体一致 `grep -qxF`）として照合される。
> ダミーのステップ／箇条書きを並べ、実体を散文・注記・HTML コメントに置く構成は
> ステップ数が足りていても FAIL する。
>
> **逐語照合される文字列（これらは1文字も変えないこと）**:
> - 追記文面1（WF2 手順）: `「この投稿に反応しない・参加しない理由」を**10個**、正直に挙げさせる` /
>   `出た10個を3分類する` / `Threads は短文なので10個全部は盛り込まない`
> - 追記文面2（WF4 手順）: `「なぜこの投稿に反応しなかったのか、正直な理由」を**10個**挙げさせる` /
>   `次の Plan で避けるべき言い回しと追加すべき要素` /
>   `注記候補として提示するに留め、ファイルへの自動書き込みは行わない`
> - 追記文面3（コツ）: `「客の立場で考えて」のような抽象的な指定では弱い` /
>   `3個程度だと当たり障りのない建前しか出ない` / `出力が薄いと感じたら` /
>   `過去に実際に言われた・見られた反応に近いものを優先し`
> - 追記文面1 の**導線ステップ（WF2 本体リスト）**:
>   `下記「断らせるチェックの手順」を実行し、読む側が反応しない理由を洗い出す`
> - 追記文面2 の**導線ステップ（WF4 本体リスト）**:
>   `実績が低い型（特に E・F 型のような勧誘・理念発信系）が見つかった場合は、下記「低反応の型の原因分析」を実行する`
>
> 上記以外の箇所（既存5ステップ／4ステップの本文）も削除・言い換え禁止（逐語照合される）。
>
> **本体リストの並び順も検証される**: WF2 は
> 「内容・状況を受け取る → 型を選ぶ → **断らせるチェック** → 下書き作成 → 一般注意 → ログ記録の案内」、
> WF4 は「データ行抽出 → 集計 → 傾向分析 → **低反応型の原因分析** → 次 Plan の提案」の順であること。
> 各ステップの逐語一致に加えて相対順序（M1<…<M6 / K1<…<K5）を検証するため、
> 並べ替えると FAIL する（断らせるチェックが下書き作成の後に来ると機能が反転するため）。

### 手法の出典と適応方針

```yaml
元ネタ: 提案書・LP 作成の文脈で語られた「AI に客を演じさせて買わない理由を10個出させる」手法
元の手順:
  1. AI に前提（商品・価格・相手）を素のまま渡す
  2. 具体的な客のペルソナを演じさせる（年齢・状況・過去の失敗体験まで指定。「客の立場で考えて」は弱い）
  3. 「買わない理由を10個、正直に言ってください。遠慮はいらない、丁寧な断り文句でなく本音で」
     → 3個だと当たり障りのないものしか出ない。10個と指定すると後半に本音が出る
  4. 10個を「先に潰す」「口頭で答える」「そもそも捨てる（この客層には売らない）」に仕分ける
  5. 一番強い断り文句を文章の最初に持ってくる（読む側の警戒を下げる）
  6. 出力が薄いときの対処: ペルソナの具体化 / 提案説明を盛らずに素っ気なく渡す /
     「今の回答は建前です。同じ質問に、本音で答え直してください」を追加
  7. AI の反論を全部真に受けない。過去に実際に言われた反論を優先し、教科書的な指摘は優先度を下げる

Threads 向け適応（ユーザーと合意済み）:
  Plan（ワークフロー2）: 下書き作成前に、読む側のペルソナを立てて
    「この投稿に反応しない・参加しない理由」を10個出させ、
    「先に触れる」「触れない（コメント返信等で対応）」「今回のターゲット外と割り切る」の3つに仕分ける。
    Threads は短文なので10個全部は盛り込まず、「先に触れる」に選んだ1つ程度を下書きに反映する。
  Act（ワークフロー4）: my-posts-log.md の集計で実績が低い型（特に E・F 型のような勧誘・理念発信系）が
    見つかったら、その投稿を見る側のペルソナを演じさせ「なぜ反応しなかったか、正直な理由」を10個出させる。
    出た理由から次の Plan で避けるべき言い回し・追加すべき要素を「提案」としてまとめ、
    pattern-library.md の「効く理由」欄への注記候補として提示する。
    **ファイルへの自動書き込みは行わない**（提案に留める）。
```

> **実測データの裏付け（`references/my-posts-log.md` 現況 / 全17件）**: E 型 4いいね・2いいね、
> F 型 1いいね（全17件中最下位）、対して C 型（物語・哲学）が 46・41 いいねで1〜2位。
> ワークフロー4 で「E・F 型のような勧誘・理念発信系」を例示するのは、この実績に基づく。

### 追記文面1: ワークフロー2（Plan）

> **既存の5ステップは本文を1文字も変えず、新ステップを手順3として挿入し以降を繰り下げる。**
> （繰り下げによる番号のズレのみ許容。ステップ本文の削除・改変は p1.2 で FAIL する）

```markdown
1. ユーザーから伝えたい内容・状況（日常/告知/振り返り 等）を受け取る
2. `references/pattern-library.md` を参照し、状況に最も合う型（A〜G）を1つ選ぶ（複数型の組み合わせも可）
3. 下記「断らせるチェックの手順」を実行し、読む側が反応しない理由を洗い出す
4. 選んだ型の「型の構造」に沿って**下書き**を作成する。verbatim CTA がある型（E）はそのまま流用してよい
5. 執筆時の一般注意（絵文字1〜2個・タメ口・地域名は告知系のみ）に沿っているか確認する
6. 下書きと「狙った型」をユーザーに提示し、投稿後に `references/my-posts-log.md` へ記録する旨を伝える

### 断らせるチェックの手順（手順3 / 下書き作成前）

1. 読む側の**ペルソナ**を具体的に立てる（年齢・状況・過去の失敗体験・本音の疑いまで指定する）
2. そのペルソナを演じさせ、「この投稿に反応しない・参加しない理由」を**10個**、正直に挙げさせる
3. 出た10個を3分類する: ①今回の投稿で**先に触れる** ②**触れない**（コメント返信等で対応する） ③このペルソナは今回の**ターゲット外**と割り切る
4. Threads は短文なので10個全部は盛り込まない。①に選んだ1つ程度の理由だけを下書きに反映し、一番強い断り文句は文章の最初に置いて警戒を下げる
```

### 追記文面2: ワークフロー4（Act）

> **既存の4ステップは本文を1文字も変えず、新ステップを手順4として挿入し以降を繰り下げる。**

```markdown
1. `references/my-posts-log.md` の投稿実績ログを読み込み、対象期間（週次/月次）のデータ行を抽出する
2. 型（A〜G）別に実績を**集計**し、いいね・コメント・保存の平均や合計を出す
3. 効果が高い型・低い型の**傾向**を分析し、気づき欄の内容も踏まえて要因を推定する
4. 実績が低い型（特に E・F 型のような勧誘・理念発信系）が見つかった場合は、下記「低反応の型の原因分析」を実行する
5. 分析結果をユーザーに報告し、次の Plan（ワークフロー2）で優先すべき型を提案する

### 低反応の型の原因分析（断らせるチェック / オプション）

1. その低反応投稿を見る側の**ペルソナ**を具体的に立て（年齢・状況・過去の失敗体験）、そのペルソナを演じさせる
2. 「なぜこの投稿に反応しなかったのか、正直な理由」を**10個**挙げさせる
3. 出た理由から、次の Plan で避けるべき言い回しと追加すべき要素をまとめ、ユーザーへの**提案**として提示する
4. `references/pattern-library.md` の該当型の「効く理由」欄への注記候補として提示するに留め、ファイルへの自動書き込みは行わない
```

### 追記文面3: コツセクション（ワークフロー4 の後、`## このスキルの使い方` の前に H2 で新設）

```markdown
## 断らせるチェックのコツ（本音を引き出すコツ）

ワークフロー2・ワークフロー4 の「断らせるチェック」を実行するときは、以下に注意する。

- ペルソナは「客の立場で考えて」のような抽象的な指定では弱い。年齢・状況・過去の失敗体験まで具体的に指定する
- 反応しない理由は必ず**10個**と数を指定する（3個程度だと当たり障りのない建前しか出ない。10個だと後半に本音が出る）
- 出力が薄いと感じたら「今の回答は建前です。同じ質問に、本音で答え直してください」を追加で投げる
- 出てきた理由を全部真に受けない。過去に実際に言われた・見られた反応に近いものを優先し、教科書的すぎる指摘は優先度を下げる
```

### 追記文面4: frontmatter description（既存フレーズを消さず末尾に2語追加）

```markdown
description: Threads 投稿の PDCA（新規アカウント分析→Plan→Check→Act）を回すスキル。7型の型ライブラリと自分の投稿実績ログを使って、投稿の型選定・下書き・振り返りを支援する。「Threadsの投稿分析して」「Threadsの投稿作って」「投稿の実績を記録して」「Threadsの振り返りして」「断らせて」「反応しない理由を出して」と伝えると起動します。
```

### 追記文面5: 「このスキルでできること」への項目追加（発見性の担保）

```markdown
5. 読む側に**断らせる**（反応しない理由を出させる）ことで、下書きの精度と低反応型の原因分析を上げる
```

---

## 記法制約（重要 / 偽 FAIL・偽 PASS の防止）

```yaml
1. ワークフロー2・4 の内部に追加する見出しは必ず H3（`### `）にすること。
   H2（`## `）で書くと区間抽出（終端 `^#{1,2} `）がそこで閉じ、
   追記内容がワークフロー区間の外に出て FAIL する（実測確認済み・改悪パターン①）。
2. コツセクションは H2（`## `）で、`## ワークフロー4` より後の行に置くこと。
   ワークフロー2 とワークフロー3 の間などに置くと配置チェックで FAIL する（改悪パターン②）。
   配置は `## ワークフロー4` セクションの後、`## このスキルの使い方` の前を推奨。
3. ワークフロー1・3 は1文字も触らないこと（base_commit との完全一致を検証する）。
4. ワークフロー2・4 の既存ステップ本文・発火フレーズ行は逐語で保持すること。
   許容されるのは新ステップ挿入に伴う**番号の繰り下げのみ**。
   **ステップの並べ替えは FAIL する**（本体リストの相対順序を検証しているため）。
   新ステップの挿入位置は WF2 = 手順3（型選択の後・下書き作成の前）、
   WF4 = 手順4（傾向分析の後・次 Plan の提案の前）で固定。
5. `## ワークフロー1`〜`## ワークフロー4` の見出し行そのものを変更・削除しないこと。
6. 見出し番号のドットを awk の `-v` 経由で渡す場合は `[.]` 表記を使うこと。
7. 追加する H3 サブセクションは**番号付きステップ4個以上**で書くこと。
   キーワードを1行に羅列した要約文では FAIL する（改悪パターン⑦）。
7-2. H3 手順の4ステップ・コツの4箇条書きは、`## inputs` の文面を
   **行そのものとして**書くこと（H3 手順は `^数字.` のステップ行、コツは `- ` 箇条書き行として
   行全体が一致することを検証する）。ダミーのステップ／箇条書きを並べて実体を散文・注記・
   HTML コメント等へ逃がすと FAIL する（デコイ G1 / G9）。
7-3. **ステップ数・箇条書き数は「以上」ではなく厳密一致**で検証する:
   WF2 本体 = 6、WF4 本体 = 5、各 H3 手順 = 4、コツの箇条書き = 4。
   ダミーを足して数を稼ぐ／実体を重複させて別の場所に置く構成はすべて FAIL する。
   要素を増やしたい場合は playbook 側（inputs と test_command と done_when と state.md）を
   先に更新すること。
7-4. ワークフロー2・4 の区間とコツ区間に **HTML コメント（`<!--`）を書かないこと**。
   実体をコメントに隠して体裁だけ整える偽装を防ぐため、存在検出で FAIL させている。
8. ワークフロー2・4 の**本体番号リストにも導線ステップを1つ挿入**すること。
   導線は「`^数字.` で始まる番号付きステップ行そのもの」に書くこと（散文・プロローグでは不可）。
   - WF2: そのステップ行に `断らせる` を含めること
   - WF4: **同一のステップ行**に `実績が低い`（または `低反応`）と `原因分析` の両方を含めること
   H3 を足すだけ、あるいは散文に逃がすと FAIL する（改悪⑧ / デコイ D1）。
8-2. `## inputs` の追記文面は**逐語照合される**（計10文）。言い換え・要約・キーワード骨格化は
   すべて FAIL する（デコイ D2）。文面をそのままコピーすること。
8-3. `## ワークフロー1`〜`## ワークフロー4` の**見出し行は base と1文字も変えない**こと。
   本文だけ保って見出しタイトルを変える改変も FAIL する（デコイ D3）。
8-4. `.claude/skills/threads-pdca/` 配下に**新規ファイルを作らない**こと（未追跡ファイルも FAIL / D4）。
8-5. state.md の `done_criteria` は playbook の `goal.done_when` と**逐語一致**させること（D5）。
   done_when を修正したら state.md も同時に更新する。
9. コツセクションの4点は**それぞれ別の箇条書き行**に書くこと。
   1行に詰め込んでダミー行で数を稼ぐと FAIL する（改悪パターン⑨）。
10. ワークフロー2・4 の各区間に置く H3 サブセクションは**1個だけ**にすること
   （区間内の最初の `### ` 以降をサブセクションとして抽出するため、
   2個以上あると2個目以降が抽出範囲外になり検証が不安定になる）。
```

---

## exclusions（このタスクでやらないこと）

```yaml
out_of_scope:
  - references/pattern-library.md の変更 → SKILL.md 本体のみの変更（ユーザー明示）
  - references/my-posts-log.md の変更（実データ行の追記・削除・注記の書き込みを含む）
    → 「効く理由」欄への注記は runtime の提案に留める仕様であり、本タスクでファイルは触らない
  - 新しい型（H 型以降）の追加、既存 A〜G 型の定義変更
  - ワークフロー5 以降の新規ワークフロー追加 → 既存4ワークフローへの追記のみ
  - ワークフロー1・3 の改変
  - 実際の Threads 投稿の作成・投稿代行、断らせるチェックの実演
  - plan/playbook-threads-pdca-foundation.md のアーカイブ移動・削除
    → 前 playbook（完了済み・main にマージ済み）。本タスクでは触らない
  - .claude/agents/critic.md の未コミット変更、.claude/worktrees/（untracked）、
    plan/playbook-setup-instagram-skills.md（untracked）
    → 本タスク以前から存在する変更。触らない（final_tasks の git add でも対象外）
  - project.md への milestone / done_when 追加（ユーザー資産の追加のため derives_from: null）
```

---

## rollback

```yaml
手順:
  1. git checkout 113cff0 -- .claude/skills/threads-pdca/SKILL.md
  2. state.md の playbook.active / branch / goal.done_criteria を本 playbook 適用前の値
     （active: plan/playbook-threads-pdca-foundation.md / branch: feat/threads-pdca-foundation /
      done_criteria 6件）に戻す
  3. rm plan/playbook-threads-pdca-objection-check.md
  4. git checkout main && git branch -D feat/threads-pdca-objection-check

影響範囲: SKILL.md 1ファイルの追記のみ。
副作用: なし（references/ 配下・他スキル・Hook・main に影響しない）
```

---

## phases

### p1: ワークフロー2（Plan）へ断らせるチェックを追記

**goal**: 下書き作成前の事前チェックとして「ペルソナ設定 → 10個の理由出し → 3分類 → 下書きへの反映」を、既存5ステップを壊さずワークフロー2 区間内に追加する

#### subtasks

- [ ] **p1.1**: ワークフロー2 区間内に『断らせる』を含む H3 見出しと4ステップ以上の手順があり、本体リストが6ステップ以上で導線を持ち、手順内に7語（ペルソナ/年齢/過去の失敗/10個/先に触れる/触れない/ターゲット外）が別々の行で ペルソナ → 10個 → 先に触れる の順に存在する
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    SEC=$(awk '/^## ワークフロー2/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    MAIN=$(echo "$SEC" | awk '/^### /{exit} {print}')
    SUB=$(echo "$SEC" | awk '/^### .*断らせる/{f=1;next} /^#{1,3} /{f=0} f')
    FAILS=""
    echo "$SEC" | grep -qE '^### .*断らせる' || FAILS="${FAILS}[H3見出しなし]"
    [ "$(echo "$MAIN" | grep -cE '^[0-9]+[.]')" -eq 6 ] || FAILS="${FAILS}[WF2本体リストのステップ数が6でない(ダミー/重複混入)]"
    echo "$SEC" | grep -q '<!--' && FAILS="${FAILS}[WF2区間にHTMLコメント(実体の隠蔽)]"
    STEPS=$(echo "$MAIN" | grep -nE '^[0-9]+[.]')
    M1=$(echo "$STEPS" | grep -F 'ユーザーから伝えたい内容・状況（日常/告知/振り返り 等）を受け取る' | head -1 | cut -d: -f1)
    M2=$(echo "$STEPS" | grep -F '状況に最も合う型（A〜G）を1つ選ぶ（複数型の組み合わせも可）' | head -1 | cut -d: -f1)
    M3=$(echo "$STEPS" | grep -F '下記「断らせるチェックの手順」を実行し、読む側が反応しない理由を洗い出す' | head -1 | cut -d: -f1)
    M4=$(echo "$STEPS" | grep -F '選んだ型の「型の構造」に沿って**下書き**を作成する' | head -1 | cut -d: -f1)
    M5=$(echo "$STEPS" | grep -F '絵文字1〜2個・タメ口・地域名は告知系のみ' | head -1 | cut -d: -f1)
    M6=$(echo "$STEPS" | grep -F 'へ記録する旨を伝える' | head -1 | cut -d: -f1)
    { [ -n "$M1" ] && [ -n "$M2" ] && [ -n "$M3" ] && [ -n "$M4" ] && [ -n "$M5" ] && [ -n "$M6" ] \
      && [ "$M1" -lt "$M2" ] && [ "$M2" -lt "$M3" ] && [ "$M3" -lt "$M4" ] && [ "$M4" -lt "$M5" ] && [ "$M5" -lt "$M6" ]; } \
      || FAILS="${FAILS}[WF2本体:導線の逐語or順序NG:${M1},${M2},${M3},${M4},${M5},${M6}]"
    [ "$(echo "$SUB" | grep -cE '^[0-9]+[.]')" -eq 4 ] || FAILS="${FAILS}[断らせる手順のステップ数が4でない(ダミー/重複混入)]"
    FAILS="${FAILS}$(printf '%s\n' "ペルソナ" "年齢" "過去の失敗" "10個" "先に触れる" "触れない" "ターゲット外" | while IFS= read -r P; do
      echo "$SUB" | grep -qF "$P" || echo "[WF2手順:${P}なし]"
    done)"
    SUBSTEPS=$(echo "$SUB" | grep -nE '^[0-9]+[.]')
    S1=$(echo "$SUBSTEPS" | grep -F '読む側の**ペルソナ**を具体的に立てる（年齢・状況・過去の失敗体験・本音の疑いまで指定する）' | head -1 | cut -d: -f1)
    S2=$(echo "$SUBSTEPS" | grep -F 'そのペルソナを演じさせ、「この投稿に反応しない・参加しない理由」を**10個**、正直に挙げさせる' | head -1 | cut -d: -f1)
    S3=$(echo "$SUBSTEPS" | grep -F '出た10個を3分類する: ①今回の投稿で**先に触れる** ②**触れない**（コメント返信等で対応する） ③このペルソナは今回の**ターゲット外**と割り切る' | head -1 | cut -d: -f1)
    S4=$(echo "$SUBSTEPS" | grep -F 'Threads は短文なので10個全部は盛り込まない。①に選んだ1つ程度の理由だけを下書きに反映し、一番強い断り文句は文章の最初に置いて警戒を下げる' | head -1 | cut -d: -f1)
    { [ -n "$S1" ] && [ -n "$S2" ] && [ -n "$S3" ] && [ -n "$S4" ] \
      && [ "$S1" -lt "$S2" ] && [ "$S2" -lt "$S3" ] && [ "$S3" -lt "$S4" ]; } \
      || FAILS="${FAILS}[WF2手順:ステップ行の逐語or順序NG:${S1},${S2},${S3},${S4}]"
    LP=$(echo "$SUB" | grep -nF 'ペルソナ' | head -1 | cut -d: -f1)
    LT=$(echo "$SUB" | grep -nF '10個' | head -1 | cut -d: -f1)
    LC=$(echo "$SUB" | grep -nF '先に触れる' | head -1 | cut -d: -f1)
    { [ -n "$LP" ] && [ -n "$LT" ] && [ -n "$LC" ] && [ "$LP" -lt "$LT" ] && [ "$LT" -lt "$LC" ]; } || FAILS="${FAILS}[順序NG:P=${LP},T=${LT},C=${LC}]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "H3 見出しを要求することで H2 による区間外への逃がし（改悪①）を封じる。本体リストは6ステップ全ての逐語照合＋相対順序（M1<…<M6）を要求するため、導線のダミー化・否定文化（D1 / E1 / E2）も並べ替えによる機能反転（E3）も FAIL する。H3 手順も同様に4ステップの逐語照合＋相対順序（S1<S2<S3<S4）を**ステップ行に紐付けて**検証するため、ダミーステップを並べて実体を『参考メモ（実行不要）』や引用散文へ逃がす偽装（G9 / G9b）が FAIL する。ステップ数を厳密一致（本体6・手順4）にして重複退避を排除し、区間内の HTML コメント存在を FAIL にして隠蔽（G1 / G1b）も封じている"
    - consistency: "`## inputs` 追記文面1 と逐語で一致し、既存ステップの下書き作成（手順4）より前に実行する旨が明記されている"
    - completeness: "ペルソナ設定・10個指定・3分類・下書きへの反映（1つ程度・冒頭配置）の4段が揃っている"

- [ ] **p1.2**: ワークフロー2 の本体リスト（H3 より前）に既存5ステップの本文と発火フレーズ行が逐語で残存している
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    SEC=$(awk '/^## ワークフロー2/{f=1;next} /^#{1,2} /{f=0} f' "$S" | awk '/^### /{exit} {print}')
    FAILS="$(printf '%s\n' \
      "発火フレーズ: 「Threadsの投稿作って」「今日の投稿の下書きお願い」「このネタで投稿書いて」" \
      "伝えたい内容・状況（日常/告知/振り返り 等）を受け取る" \
      "状況に最も合う型（A〜G）を1つ選ぶ（複数型の組み合わせも可）" \
      "verbatim CTA がある型（E）はそのまま流用してよい" \
      "絵文字1〜2個・タメ口・地域名は告知系のみ" \
      "へ記録する旨を伝える" | while IFS= read -r P; do
      echo "$SEC" | grep -qF "$P" || echo "[WF2既存欠落:${P}]"
    done)"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "grep -qF による逐語照合で既存ステップの削除・言い換えを検出する（改悪④で実測 FAIL 確認）。番号の繰り下げのみなら本文は一致するため PASS する。照合対象を本体リスト（H3 より前）に限定しているため、既存ステップを H3 サブセクション側へ移動させる改変も検出できる"
    - consistency: "発火フレーズ行が base_commit 版と同一であり、ユーザーの既存呼び出し方法が壊れていない"
    - completeness: "既存5ステップの本文と発火フレーズ行の6要素すべてを照合している（ステップ数の下限は p1.1 で検証）"

**status**: pending
**max_iterations**: 5
**priority**: high

---

### p2: ワークフロー4（Act）へ低反応型の原因分析を追記

**goal**: 集計で低反応の型（E・F 等）が見つかった場合のオプション手順として、断らせるチェックによる原因分析と「提案に留める」ルールをワークフロー4 区間内に追加する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: ワークフロー4 区間内に『断らせる』を含む H3 見出しと4ステップ以上の原因分析手順があり、本体リストが5ステップ以上で低反応型の検出条件と導線を持ち、手順内に5語（ペルソナ/10個/references/pattern-library.md/効く理由/提案）と自動書き込み禁止の記述、区間内に E・F の明示があり、『断らせる』が『集計』より後に出現する
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    SEC=$(awk '/^## ワークフロー4/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    MAIN=$(echo "$SEC" | awk '/^### /{exit} {print}')
    SUB=$(echo "$SEC" | awk '/^### /{f=1;next} /^#{1,3} /{f=0} f')
    FAILS=""
    echo "$SEC" | grep -qE '^### .*断らせる' || FAILS="${FAILS}[H3見出しに断らせるなし]"
    [ "$(echo "$MAIN" | grep -cE '^[0-9]+[.]')" -eq 5 ] || FAILS="${FAILS}[WF4本体リストのステップ数が5でない(ダミー/重複混入)]"
    echo "$SEC" | grep -q '<!--' && FAILS="${FAILS}[WF4区間にHTMLコメント(実体の隠蔽)]"
    STEPS=$(echo "$MAIN" | grep -nE '^[0-9]+[.]')
    K1=$(echo "$STEPS" | grep -F '対象期間（週次/月次）のデータ行を抽出する' | head -1 | cut -d: -f1)
    K2=$(echo "$STEPS" | grep -F 'いいね・コメント・保存の平均や合計を出す' | head -1 | cut -d: -f1)
    K3=$(echo "$STEPS" | grep -F '気づき欄の内容も踏まえて要因を推定する' | head -1 | cut -d: -f1)
    K4=$(echo "$STEPS" | grep -F '実績が低い型（特に E・F 型のような勧誘・理念発信系）が見つかった場合は、下記「低反応の型の原因分析」を実行する' | head -1 | cut -d: -f1)
    K5=$(echo "$STEPS" | grep -F '次の Plan（ワークフロー2）で優先すべき型を提案する' | head -1 | cut -d: -f1)
    { [ -n "$K1" ] && [ -n "$K2" ] && [ -n "$K3" ] && [ -n "$K4" ] && [ -n "$K5" ] \
      && [ "$K1" -lt "$K2" ] && [ "$K2" -lt "$K3" ] && [ "$K3" -lt "$K4" ] && [ "$K4" -lt "$K5" ]; } \
      || FAILS="${FAILS}[WF4本体:導線の逐語or順序NG:${K1},${K2},${K3},${K4},${K5}]"
    [ "$(echo "$SUB" | grep -cE '^[0-9]+[.]')" -eq 4 ] || FAILS="${FAILS}[原因分析手順のステップ数が4でない(ダミー/重複混入)]"
    FAILS="${FAILS}$(printf '%s\n' "ペルソナ" "10個" "references/pattern-library.md" "効く理由" "提案" | while IFS= read -r P; do
      echo "$SUB" | grep -qF "$P" || echo "[WF4手順:${P}なし]"
    done)"
    SUBSTEPS=$(echo "$SUB" | grep -nE '^[0-9]+[.]')
    T1=$(echo "$SUBSTEPS" | grep -F 'その低反応投稿を見る側の**ペルソナ**を具体的に立て（年齢・状況・過去の失敗体験）、そのペルソナを演じさせる' | head -1 | cut -d: -f1)
    T2=$(echo "$SUBSTEPS" | grep -F '「なぜこの投稿に反応しなかったのか、正直な理由」を**10個**挙げさせる' | head -1 | cut -d: -f1)
    T3=$(echo "$SUBSTEPS" | grep -F '出た理由から、次の Plan で避けるべき言い回しと追加すべき要素をまとめ、ユーザーへの**提案**として提示する' | head -1 | cut -d: -f1)
    T4=$(echo "$SUBSTEPS" | grep -F '`references/pattern-library.md` の該当型の「効く理由」欄への注記候補として提示するに留め、ファイルへの自動書き込みは行わない' | head -1 | cut -d: -f1)
    { [ -n "$T1" ] && [ -n "$T2" ] && [ -n "$T3" ] && [ -n "$T4" ] \
      && [ "$T1" -lt "$T2" ] && [ "$T2" -lt "$T3" ] && [ "$T3" -lt "$T4" ]; } \
      || FAILS="${FAILS}[WF4手順:ステップ行の逐語or順序NG:${T1},${T2},${T3},${T4}]"
    echo "$SEC" | grep -qE 'E・F|E/F|E、F' || FAILS="${FAILS}[WF4:低反応型E・Fの明示なし]"
    echo "$SUB" | grep -qE '書き込みは行わない|書き込まない|書き込みは行わず|自動更新しない' || FAILS="${FAILS}[WF4:自動書き込み禁止の明記なし]"
    LA=$(echo "$SEC" | grep -nF '集計' | head -1 | cut -d: -f1)
    LB=$(echo "$SEC" | grep -nF '断らせる' | head -1 | cut -d: -f1)
    { [ -n "$LA" ] && [ -n "$LB" ] && [ "$LA" -lt "$LB" ]; } || FAILS="${FAILS}[順序NG:集計=${LA},断らせる=${LB}]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "自動書き込み禁止の記述を H3 手順内に必須化しており、これを省くと FAIL する（改悪⑥）。本体リストは5ステップ全ての逐語照合＋相対順序（K1<…<K5）を要求し、導線ステップ K4 は逐語一致を要求するため、条件と参照先を散文へ分散させる偽装（D1）も、集計より前に原因分析を置く並べ替え（E4）も FAIL する。H3 手順も4ステップの逐語照合＋相対順序（T1<T2<T3<T4）を**ステップ行に紐付けて**検証し、ステップ数を厳密一致（本体5・手順4）にしたうえで区間内の HTML コメントを FAIL にしているため、ダミー化＋実体退避（G9 / G9b）と隠蔽（G1 / G1b）が通らない"
    - consistency: "参照先 `references/pattern-library.md` は実在し、その『効く理由』は pattern-library.md の各型内の H3 見出し名と一致する。exclusions の『my-posts-log.md / pattern-library.md を変更しない』とも矛盾しない（提案に留める仕様）"
    - completeness: "低反応型の検出条件・ペルソナ・10個・提案化・注記候補の提示・自動書き込み禁止の5要素が揃っている"

- [ ] **p2.2**: ワークフロー4 の本体リスト（H3 より前）に既存4ステップの本文と発火フレーズ行が逐語で残存している
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    SEC=$(awk '/^## ワークフロー4/{f=1;next} /^#{1,2} /{f=0} f' "$S" | awk '/^### /{exit} {print}')
    FAILS="$(printf '%s\n' \
      "発火フレーズ: 「Threadsの振り返りして」「今週の投稿まとめて」「月次でどの型が効いてるか教えて」" \
      "対象期間（週次/月次）のデータ行を抽出する" \
      "いいね・コメント・保存の平均や合計を出す" \
      "気づき欄の内容も踏まえて要因を推定する" \
      "次の Plan（ワークフロー2）で優先すべき型を提案する" | while IFS= read -r P; do
      echo "$SEC" | grep -qF "$P" || echo "[WF4既存欠落:${P}]"
    done)"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "逐語照合で既存ステップの削除・改変を検出する。照合対象を本体リストに限定しているため H3 側への移動も検出できる"
    - consistency: "発火フレーズ行が base_commit 版と同一である"
    - completeness: "既存4ステップの本文と発火フレーズ行の5要素すべてを照合している（ステップ数の下限は p2.1 で検証）"

**status**: pending
**max_iterations**: 5
**priority**: high

---

### p3: コツセクション新設・frontmatter 更新・非破壊性の回帰検証

**goal**: 両ワークフロー共通の「本音を引き出すコツ」4点を H2 セクションとして追加し、トリガーフレーズを description に追記した上で、既存スキルが壊れていないことを検証する

**depends_on**: [p1, p2]

#### subtasks

- [ ] **p3.1**: 『断らせる』と『コツ』を含む H2 見出しが1個だけ存在し、`## ワークフロー4` より後の行にあり、区間内に `- ` 箇条書き4項目以上と5要素（年齢/10個/建前の言い直し文/真に受け/教科書）があり、うち4要素が別々の行に分かれている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    FAILS=""
    [ "$(grep -cE '^## .*断らせる.*コツ' "$S")" -eq 1 ] || FAILS="${FAILS}[コツH2見出しが1個でない]"
    HW=$(grep -nE '^## ワークフロー4' "$S" | head -1 | cut -d: -f1)
    HK=$(grep -nE '^## .*断らせる.*コツ' "$S" | head -1 | cut -d: -f1)
    { [ -n "$HW" ] && [ -n "$HK" ] && [ "$HK" -gt "$HW" ]; } || FAILS="${FAILS}[配置NG:WF4=${HW},コツ=${HK}]"
    SEC=$(awk '/^## .*断らせる.*コツ/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    [ "$(echo "$SEC" | grep -c '^- ')" -eq 4 ] || FAILS="${FAILS}[コツの箇条書き数が4でない(ダミー/重複混入)]"
    echo "$SEC" | grep -q '<!--' && FAILS="${FAILS}[コツ区間にHTMLコメント(実体の隠蔽)]"
    FAILS="${FAILS}$(printf '%s\n' "年齢" "10個" "今の回答は建前です。同じ質問に、本音で答え直してください" "真に受け" "教科書" | while IFS= read -r P; do
      echo "$SEC" | grep -qF "$P" || echo "[コツ:${P}なし]"
    done)"
    FAILS="${FAILS}$(printf '%s\n' \
      "- ペルソナは「客の立場で考えて」のような抽象的な指定では弱い。年齢・状況・過去の失敗体験まで具体的に指定する" \
      "- 反応しない理由は必ず**10個**と数を指定する（3個程度だと当たり障りのない建前しか出ない。10個だと後半に本音が出る）" \
      "- 出力が薄いと感じたら「今の回答は建前です。同じ質問に、本音で答え直してください」を追加で投げる" \
      "- 出てきた理由を全部真に受けない。過去に実際に言われた・見られた反応に近いものを優先し、教科書的すぎる指摘は優先度を下げる" | while IFS= read -r P; do
      echo "$SEC" | grep -qxF -- "$P" || echo "[コツ:箇条書き行の逐語欠落:${P}]"
    done)"
    LNS=$(printf '%s\n' "年齢" "10個" "今の回答は建前です。同じ質問に、本音で答え直してください" "真に受け" | while IFS= read -r P; do
      echo "$SEC" | grep -nF "$P" | head -1 | cut -d: -f1
    done | sort -u | grep -c '[0-9]')
    [ "$LNS" -eq 4 ] || FAILS="${FAILS}[4要素が別々の行に分かれていない(${LNS}行)]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "見出しが1個だけ・ワークフロー4 より後という位置条件を行番号で検証するため配置ミス（改悪②）が FAIL する。4要素の初出行番号のユニーク数が4であることを要求するため1行詰め込み＋ダミー行（改悪⑨）も FAIL する。追記文面3 の4点は `grep -qxF --` による **`- ` 箇条書き行の行全体一致**で照合するため、キーワード骨格（D2）・行頭への飾り付けや語尾の追記（G3）が FAIL する。さらに箇条書き数を厳密に4とし HTML コメントを禁止しているため、ダミー行＋実体退避（G9）や隠蔽（G1）も通らない"
    - consistency: "`## inputs` 追記文面3 の4点と逐語で一致し、ワークフロー2・4 の断らせる手順（ペルソナ具体化・10個指定）と矛盾しない"
    - completeness: "ユーザー指定の4点（具体的ペルソナ／10個指定／本音で答え直して／全部を真に受けない）が全て箇条書きで存在する"

- [ ] **p3.2**: frontmatter の description に既存4トリガーフレーズが残存し「断らせて」「反応しない理由を出して」が追加され、かつ『## このスキルでできること』区間に『断らせる』を含む番号付き項目が5個以上ある
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$S")
    FAILS=""
    echo "$FM" | grep -q '^name: threads-pdca$' || FAILS="${FAILS}[nameNG]"
    DESC=$(echo "$FM" | grep '^description:')
    [ -n "$DESC" ] || FAILS="${FAILS}[descriptionなし]"
    FAILS="${FAILS}$(printf '%s\n' "「Threadsの投稿分析して」" "「Threadsの投稿作って」" "「投稿の実績を記録して」" "「Threadsの振り返りして」" "「断らせて」" "「反応しない理由を出して」" | while IFS= read -r P; do
      echo "$DESC" | grep -qF "$P" || echo "[FM description:${P}なし]"
    done)"
    CAN=$(awk '/^## このスキルでできること/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    [ "$(echo "$CAN" | grep -cE '^[0-9]+[.]')" -ge 5 ] || FAILS="${FAILS}[できること項目5未満]"
    echo "$CAN" | grep -qE '^[0-9]+[.].*断らせる' || FAILS="${FAILS}[できること:番号付き項目に断らせるの言及なし]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "1行目から始まる frontmatter ブロックを抽出したうえで、トリガーフレーズ6種の照合対象を **`description:` 行そのもの**に限定している。frontmatter 全体を対象にすると、description を骨抜きにしてフレーズを `triggers_memo:` 等の別キーへ退避させてもPASS してしまい、スキルの自動起動が壊れていることを検出できない（デコイ E5）。行限定にすることでこれを FAIL させる。既存4フレーズを逐語必須にしているため、description の書き直しで既存トリガーを失う事故も FAIL する"
    - consistency: "description の文体（〜と伝えると起動します）と name: threads-pdca（ディレクトリ名一致）を維持している"
    - completeness: "新機能のトリガーフレーズ2種が追加され、スキル冒頭の機能一覧にも断らせるチェックが載っている"

- [ ] **p3.3**: ワークフロー1〜4 の見出し行が base_commit(113cff0) 版と1文字も相違なく、ワークフロー1・3 の区間内容も完全一致し、ワークフロー1〜4 の全区間が『発火フレーズ』・`references/` 参照・番号付きステップ3個以上を満たす
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    B=$(mktemp)
    git show 113cff0:.claude/skills/threads-pdca/SKILL.md > "$B" || { echo "FAIL(base取得失敗)"; exit 1; }
    FAILS=""
    for N in 1 2 3 4; do
      NEWH=$(grep -E "^## ワークフロー${N}" "$S" | head -1)
      OLDH=$(grep -E "^## ワークフロー${N}" "$B" | head -1)
      { [ -n "$OLDH" ] && [ "$NEWH" = "$OLDH" ]; } || FAILS="${FAILS}[WF${N}見出し行が改変:${NEWH}]"
    done
    for N in 1 3; do
      NEWSEC=$(awk -v s="^## ワークフロー${N}" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$S")
      OLDSEC=$(awk -v s="^## ワークフロー${N}" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$B")
      [ -n "$OLDSEC" ] || FAILS="${FAILS}[base WF${N}抽出失敗]"
      [ "$NEWSEC" = "$OLDSEC" ] || FAILS="${FAILS}[WF${N}が改変されている]"
    done
    for N in 1 2 3 4; do
      SEC=$(awk -v s="^## ワークフロー${N}" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$S")
      echo "$SEC" | grep -q '発火フレーズ' || FAILS="${FAILS}[WF${N}:発火フレーズなし]"
      echo "$SEC" | grep -q 'references/' || FAILS="${FAILS}[WF${N}:references参照なし]"
      [ "$(echo "$SEC" | grep -cE '^[0-9]+[.]')" -ge 3 ] || FAILS="${FAILS}[WF${N}:番号付きステップ3未満]"
    done
    [ "$(grep -cE '^## ワークフロー[1-4]' "$S")" -eq 4 ] || FAILS="${FAILS}[ワークフロー見出しが4個でない]"
    grep -q '^## このスキルの使い方' "$S" || FAILS="${FAILS}[このスキルの使い方セクション欠落]"
    rm -f "$B"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "base 抽出が空のときに空文字同士の一致で偽 PASS しないよう `[ -n \"$OLDSEC\" ]` / `[ -n \"$OLDH\" ]` を先に要求している。ワークフロー1 の1語だけの改変（改悪③）に加え、**本文を変えずに見出し行のタイトルだけを改変する偽装（デコイ D3）も見出し行の完全一致比較で検出する**。ユーザー制約『既存ワークフローの番号や発火フレーズを削除・変更しないこと』の保護対象そのものを強制している"
    - consistency: "前 playbook（threads-pdca-foundation）の done_when 2 と同一の健全性条件を再検証しており、既存 playbook の受け入れ基準を回帰させていない"
    - completeness: "4ワークフローの見出し・発火フレーズ・参照・ステップ数と、末尾セクションの存在まで確認している"

**status**: pending
**max_iterations**: 5
**priority**: high

---

### p_final: 完了検証（必須）

> **goal.done_when が実際に満たされているか最終検証する。存在チェックのみは禁止。**

#### subtasks

- [ ] **p_final.1**: done_when 1（ワークフロー2 の断らせるチェック）が満たされている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    test -f "$S" || { echo "FAIL(ファイルなし)"; exit 1; }
    SEC=$(awk '/^## ワークフロー2/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    MAIN=$(echo "$SEC" | awk '/^### /{exit} {print}')
    SUB=$(echo "$SEC" | awk '/^### .*断らせる/{f=1;next} /^#{1,3} /{f=0} f')
    FAILS=""
    echo "$SEC" | grep -qE '^### .*断らせる' || FAILS="${FAILS}[H3見出しなし]"
    [ "$(echo "$MAIN" | grep -cE '^[0-9]+[.]')" -eq 6 ] || FAILS="${FAILS}[WF2本体リストのステップ数が6でない(ダミー/重複混入)]"
    echo "$SEC" | grep -q '<!--' && FAILS="${FAILS}[WF2区間にHTMLコメント(実体の隠蔽)]"
    STEPS=$(echo "$MAIN" | grep -nE '^[0-9]+[.]')
    M1=$(echo "$STEPS" | grep -F 'ユーザーから伝えたい内容・状況（日常/告知/振り返り 等）を受け取る' | head -1 | cut -d: -f1)
    M2=$(echo "$STEPS" | grep -F '状況に最も合う型（A〜G）を1つ選ぶ（複数型の組み合わせも可）' | head -1 | cut -d: -f1)
    M3=$(echo "$STEPS" | grep -F '下記「断らせるチェックの手順」を実行し、読む側が反応しない理由を洗い出す' | head -1 | cut -d: -f1)
    M4=$(echo "$STEPS" | grep -F '選んだ型の「型の構造」に沿って**下書き**を作成する' | head -1 | cut -d: -f1)
    M5=$(echo "$STEPS" | grep -F '絵文字1〜2個・タメ口・地域名は告知系のみ' | head -1 | cut -d: -f1)
    M6=$(echo "$STEPS" | grep -F 'へ記録する旨を伝える' | head -1 | cut -d: -f1)
    { [ -n "$M1" ] && [ -n "$M2" ] && [ -n "$M3" ] && [ -n "$M4" ] && [ -n "$M5" ] && [ -n "$M6" ] \
      && [ "$M1" -lt "$M2" ] && [ "$M2" -lt "$M3" ] && [ "$M3" -lt "$M4" ] && [ "$M4" -lt "$M5" ] && [ "$M5" -lt "$M6" ]; } \
      || FAILS="${FAILS}[WF2本体:導線の逐語or順序NG:${M1},${M2},${M3},${M4},${M5},${M6}]"
    [ "$(echo "$SUB" | grep -cE '^[0-9]+[.]')" -eq 4 ] || FAILS="${FAILS}[断らせる手順のステップ数が4でない(ダミー/重複混入)]"
    FAILS="${FAILS}$(printf '%s\n' "ペルソナ" "年齢" "過去の失敗" "10個" "先に触れる" "触れない" "ターゲット外" | while IFS= read -r P; do
      echo "$SUB" | grep -qF "$P" || echo "[WF2手順:${P}なし]"
    done)"
    SUBSTEPS=$(echo "$SUB" | grep -nE '^[0-9]+[.]')
    S1=$(echo "$SUBSTEPS" | grep -F '読む側の**ペルソナ**を具体的に立てる（年齢・状況・過去の失敗体験・本音の疑いまで指定する）' | head -1 | cut -d: -f1)
    S2=$(echo "$SUBSTEPS" | grep -F 'そのペルソナを演じさせ、「この投稿に反応しない・参加しない理由」を**10個**、正直に挙げさせる' | head -1 | cut -d: -f1)
    S3=$(echo "$SUBSTEPS" | grep -F '出た10個を3分類する: ①今回の投稿で**先に触れる** ②**触れない**（コメント返信等で対応する） ③このペルソナは今回の**ターゲット外**と割り切る' | head -1 | cut -d: -f1)
    S4=$(echo "$SUBSTEPS" | grep -F 'Threads は短文なので10個全部は盛り込まない。①に選んだ1つ程度の理由だけを下書きに反映し、一番強い断り文句は文章の最初に置いて警戒を下げる' | head -1 | cut -d: -f1)
    { [ -n "$S1" ] && [ -n "$S2" ] && [ -n "$S3" ] && [ -n "$S4" ] \
      && [ "$S1" -lt "$S2" ] && [ "$S2" -lt "$S3" ] && [ "$S3" -lt "$S4" ]; } \
      || FAILS="${FAILS}[WF2手順:ステップ行の逐語or順序NG:${S1},${S2},${S3},${S4}]"
    LP=$(echo "$SUB" | grep -nF 'ペルソナ' | head -1 | cut -d: -f1)
    LT=$(echo "$SUB" | grep -nF '10個' | head -1 | cut -d: -f1)
    LC=$(echo "$SUB" | grep -nF '先に触れる' | head -1 | cut -d: -f1)
    { [ -n "$LP" ] && [ -n "$LT" ] && [ -n "$LC" ] && [ "$LP" -lt "$LT" ] && [ "$LT" -lt "$LC" ]; } || FAILS="${FAILS}[順序NG:P=${LP},T=${LT},C=${LC}]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "区間抽出＋H3 要求＋ステップ数下限＋厳密昇順の4重で、区間外への逃がし・1行キーワード羅列・順不同を排除している"
    - consistency: "p1.1 と同一条件であり、Phase 判定と最終判定が食い違わない"
    - completeness: "ペルソナ・10個・3分類の3要素が全て存在する"

- [ ] **p_final.2**: done_when 2（ワークフロー4 の低反応型の原因分析）が満たされている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    SEC=$(awk '/^## ワークフロー4/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    MAIN=$(echo "$SEC" | awk '/^### /{exit} {print}')
    SUB=$(echo "$SEC" | awk '/^### /{f=1;next} /^#{1,3} /{f=0} f')
    FAILS=""
    echo "$SEC" | grep -qE '^### .*断らせる' || FAILS="${FAILS}[H3見出しに断らせるなし]"
    [ "$(echo "$MAIN" | grep -cE '^[0-9]+[.]')" -eq 5 ] || FAILS="${FAILS}[WF4本体リストのステップ数が5でない(ダミー/重複混入)]"
    echo "$SEC" | grep -q '<!--' && FAILS="${FAILS}[WF4区間にHTMLコメント(実体の隠蔽)]"
    STEPS=$(echo "$MAIN" | grep -nE '^[0-9]+[.]')
    K1=$(echo "$STEPS" | grep -F '対象期間（週次/月次）のデータ行を抽出する' | head -1 | cut -d: -f1)
    K2=$(echo "$STEPS" | grep -F 'いいね・コメント・保存の平均や合計を出す' | head -1 | cut -d: -f1)
    K3=$(echo "$STEPS" | grep -F '気づき欄の内容も踏まえて要因を推定する' | head -1 | cut -d: -f1)
    K4=$(echo "$STEPS" | grep -F '実績が低い型（特に E・F 型のような勧誘・理念発信系）が見つかった場合は、下記「低反応の型の原因分析」を実行する' | head -1 | cut -d: -f1)
    K5=$(echo "$STEPS" | grep -F '次の Plan（ワークフロー2）で優先すべき型を提案する' | head -1 | cut -d: -f1)
    { [ -n "$K1" ] && [ -n "$K2" ] && [ -n "$K3" ] && [ -n "$K4" ] && [ -n "$K5" ] \
      && [ "$K1" -lt "$K2" ] && [ "$K2" -lt "$K3" ] && [ "$K3" -lt "$K4" ] && [ "$K4" -lt "$K5" ]; } \
      || FAILS="${FAILS}[WF4本体:導線の逐語or順序NG:${K1},${K2},${K3},${K4},${K5}]"
    [ "$(echo "$SUB" | grep -cE '^[0-9]+[.]')" -eq 4 ] || FAILS="${FAILS}[原因分析手順のステップ数が4でない(ダミー/重複混入)]"
    FAILS="${FAILS}$(printf '%s\n' "ペルソナ" "10個" "references/pattern-library.md" "効く理由" "提案" | while IFS= read -r P; do
      echo "$SUB" | grep -qF "$P" || echo "[WF4手順:${P}なし]"
    done)"
    SUBSTEPS=$(echo "$SUB" | grep -nE '^[0-9]+[.]')
    T1=$(echo "$SUBSTEPS" | grep -F 'その低反応投稿を見る側の**ペルソナ**を具体的に立て（年齢・状況・過去の失敗体験）、そのペルソナを演じさせる' | head -1 | cut -d: -f1)
    T2=$(echo "$SUBSTEPS" | grep -F '「なぜこの投稿に反応しなかったのか、正直な理由」を**10個**挙げさせる' | head -1 | cut -d: -f1)
    T3=$(echo "$SUBSTEPS" | grep -F '出た理由から、次の Plan で避けるべき言い回しと追加すべき要素をまとめ、ユーザーへの**提案**として提示する' | head -1 | cut -d: -f1)
    T4=$(echo "$SUBSTEPS" | grep -F '`references/pattern-library.md` の該当型の「効く理由」欄への注記候補として提示するに留め、ファイルへの自動書き込みは行わない' | head -1 | cut -d: -f1)
    { [ -n "$T1" ] && [ -n "$T2" ] && [ -n "$T3" ] && [ -n "$T4" ] \
      && [ "$T1" -lt "$T2" ] && [ "$T2" -lt "$T3" ] && [ "$T3" -lt "$T4" ]; } \
      || FAILS="${FAILS}[WF4手順:ステップ行の逐語or順序NG:${T1},${T2},${T3},${T4}]"
    echo "$SEC" | grep -qE 'E・F|E/F|E、F' || FAILS="${FAILS}[E・F明示なし]"
    echo "$SUB" | grep -qE '書き込みは行わない|書き込まない|書き込みは行わず|自動更新しない' || FAILS="${FAILS}[自動書き込み禁止の明記なし]"
    LA=$(echo "$SEC" | grep -nF '集計' | head -1 | cut -d: -f1)
    LB=$(echo "$SEC" | grep -nF '断らせる' | head -1 | cut -d: -f1)
    { [ -n "$LA" ] && [ -n "$LB" ] && [ "$LA" -lt "$LB" ]; } || FAILS="${FAILS}[順序NG:集計=${LA},断らせる=${LB}]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "自動書き込み禁止の明記を H3 手順内に必須化し、exclusions（references/ を変更しない）と実装の整合を文面レベルで担保する。ステップ数下限により1行羅列・H3 追加のみの手抜きも排除する"
    - consistency: "p2.1 と同一条件である"
    - completeness: "低反応型検出→ペルソナ→10個→提案化→注記候補提示の流れが揃っている"

- [ ] **p_final.3**: done_when 3（コツセクション）が満たされている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    FAILS=""
    [ "$(grep -cE '^## .*断らせる.*コツ' "$S")" -eq 1 ] || FAILS="${FAILS}[コツH2見出しが1個でない]"
    HW=$(grep -nE '^## ワークフロー4' "$S" | head -1 | cut -d: -f1)
    HK=$(grep -nE '^## .*断らせる.*コツ' "$S" | head -1 | cut -d: -f1)
    { [ -n "$HW" ] && [ -n "$HK" ] && [ "$HK" -gt "$HW" ]; } || FAILS="${FAILS}[配置NG:WF4=${HW},コツ=${HK}]"
    SEC=$(awk '/^## .*断らせる.*コツ/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    [ "$(echo "$SEC" | grep -c '^- ')" -eq 4 ] || FAILS="${FAILS}[コツの箇条書き数が4でない(ダミー/重複混入)]"
    echo "$SEC" | grep -q '<!--' && FAILS="${FAILS}[コツ区間にHTMLコメント(実体の隠蔽)]"
    FAILS="${FAILS}$(printf '%s\n' "年齢" "10個" "今の回答は建前です。同じ質問に、本音で答え直してください" "真に受け" "教科書" | while IFS= read -r P; do
      echo "$SEC" | grep -qF "$P" || echo "[コツ:${P}なし]"
    done)"
    FAILS="${FAILS}$(printf '%s\n' \
      "- ペルソナは「客の立場で考えて」のような抽象的な指定では弱い。年齢・状況・過去の失敗体験まで具体的に指定する" \
      "- 反応しない理由は必ず**10個**と数を指定する（3個程度だと当たり障りのない建前しか出ない。10個だと後半に本音が出る）" \
      "- 出力が薄いと感じたら「今の回答は建前です。同じ質問に、本音で答え直してください」を追加で投げる" \
      "- 出てきた理由を全部真に受けない。過去に実際に言われた・見られた反応に近いものを優先し、教科書的すぎる指摘は優先度を下げる" | while IFS= read -r P; do
      echo "$SEC" | grep -qxF -- "$P" || echo "[コツ:箇条書き行の逐語欠落:${P}]"
    done)"
    LNS=$(printf '%s\n' "年齢" "10個" "今の回答は建前です。同じ質問に、本音で答え直してください" "真に受け" | while IFS= read -r P; do
      echo "$SEC" | grep -nF "$P" | head -1 | cut -d: -f1
    done | sort -u | grep -c '[0-9]')
    [ "$LNS" -eq 4 ] || FAILS="${FAILS}[4要素が別々の行に分かれていない(${LNS}行)]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "位置条件・項目数・逐語照合（追記文面3 の4文）・4要素の行分散の4点を同時に検証する（1行詰め込み＋ダミー行の偽装、キーワード骨格のみの偽装を排除）"
    - consistency: "p3.1 と同一条件である"
    - completeness: "ユーザー指定の4点が全て含まれている"

- [ ] **p_final.4**: done_when 4（frontmatter のトリガーフレーズ）が満たされている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$S")
    FAILS=""
    echo "$FM" | grep -q '^name: threads-pdca$' || FAILS="${FAILS}[nameNG]"
    DESC=$(echo "$FM" | grep '^description:')
    [ -n "$DESC" ] || FAILS="${FAILS}[descriptionなし]"
    FAILS="${FAILS}$(printf '%s\n' "「Threadsの投稿分析して」" "「Threadsの投稿作って」" "「投稿の実績を記録して」" "「Threadsの振り返りして」" "「断らせて」" "「反応しない理由を出して」" | while IFS= read -r P; do
      echo "$DESC" | grep -qF "$P" || echo "[FM description:${P}なし]"
    done)"
    CAN=$(awk '/^## このスキルでできること/{f=1;next} /^#{1,2} /{f=0} f' "$S")
    [ "$(echo "$CAN" | grep -cE '^[0-9]+[.]')" -ge 5 ] || FAILS="${FAILS}[できること項目5未満]"
    echo "$CAN" | grep -qE '^[0-9]+[.].*断らせる' || FAILS="${FAILS}[できること:番号付き項目に断らせるの言及なし]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "frontmatter 区間限定の抽出により本文の誤検出がなく、さらにトリガーフレーズの照合対象を `description:` 行に限定しているため、別キーへの退避（デコイ E5）を FAIL させる。`## このスキルでできること` 区間の項目チェックを p3.2 から移植したため、Phase 完了後に当該項目を消しても最終ゲートで検出できる"
    - consistency: "既存4フレーズが残り、name はディレクトリ名と一致している"
    - completeness: "新規2フレーズの追加と、スキル冒頭の機能一覧への反映（追記文面5）の両方を検証している"

- [ ] **p_final.5**: done_when 5（非破壊性の回帰）が満たされている
  - executor: claudecode
  - test_command: |
    S=.claude/skills/threads-pdca/SKILL.md
    B=$(mktemp)
    git show 113cff0:.claude/skills/threads-pdca/SKILL.md > "$B" || { echo "FAIL(base取得失敗)"; exit 1; }
    FAILS=""
    for N in 1 2 3 4; do
      NEWH=$(grep -E "^## ワークフロー${N}" "$S" | head -1)
      OLDH=$(grep -E "^## ワークフロー${N}" "$B" | head -1)
      { [ -n "$OLDH" ] && [ "$NEWH" = "$OLDH" ]; } || FAILS="${FAILS}[WF${N}見出し行が改変:${NEWH}]"
    done
    for N in 1 3; do
      NEWSEC=$(awk -v s="^## ワークフロー${N}" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$S")
      OLDSEC=$(awk -v s="^## ワークフロー${N}" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$B")
      [ -n "$OLDSEC" ] || FAILS="${FAILS}[base WF${N}抽出失敗]"
      [ "$NEWSEC" = "$OLDSEC" ] || FAILS="${FAILS}[WF${N}が改変されている]"
    done
    W2=$(awk '/^## ワークフロー2/{f=1;next} /^#{1,2} /{f=0} f' "$S" | awk '/^### /{exit} {print}')
    W4=$(awk '/^## ワークフロー4/{f=1;next} /^#{1,2} /{f=0} f' "$S" | awk '/^### /{exit} {print}')
    FAILS="${FAILS}$(printf '%s\n' \
      "発火フレーズ: 「Threadsの投稿作って」「今日の投稿の下書きお願い」「このネタで投稿書いて」" \
      "伝えたい内容・状況（日常/告知/振り返り 等）を受け取る" \
      "状況に最も合う型（A〜G）を1つ選ぶ（複数型の組み合わせも可）" \
      "verbatim CTA がある型（E）はそのまま流用してよい" \
      "絵文字1〜2個・タメ口・地域名は告知系のみ" \
      "へ記録する旨を伝える" | while IFS= read -r P; do
      echo "$W2" | grep -qF "$P" || echo "[WF2既存欠落:${P}]"
    done)"
    FAILS="${FAILS}$(printf '%s\n' \
      "発火フレーズ: 「Threadsの振り返りして」「今週の投稿まとめて」「月次でどの型が効いてるか教えて」" \
      "対象期間（週次/月次）のデータ行を抽出する" \
      "いいね・コメント・保存の平均や合計を出す" \
      "気づき欄の内容も踏まえて要因を推定する" \
      "次の Plan（ワークフロー2）で優先すべき型を提案する" | while IFS= read -r P; do
      echo "$W4" | grep -qF "$P" || echo "[WF4既存欠落:${P}]"
    done)"
    for N in 1 2 3 4; do
      SEC=$(awk -v s="^## ワークフロー${N}" '$0 ~ s {f=1;next} /^#{1,2} /{f=0} f' "$S")
      echo "$SEC" | grep -q '発火フレーズ' || FAILS="${FAILS}[WF${N}:発火フレーズなし]"
      echo "$SEC" | grep -q 'references/' || FAILS="${FAILS}[WF${N}:references参照なし]"
      [ "$(echo "$SEC" | grep -cE '^[0-9]+[.]')" -ge 3 ] || FAILS="${FAILS}[WF${N}:番号付きステップ3未満]"
    done
    [ "$(grep -cE '^## ワークフロー[1-4]' "$S")" -eq 4 ] || FAILS="${FAILS}[ワークフロー見出しが4個でない]"
    rm -f "$B"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "見出し行の完全一致比較（デコイ D3 対策）と base コミット固定の区間比較、既存ステップの逐語照合により既存スキルの破壊を検出する。逐語照合は本体リスト（H3 より前）限定のため、既存ステップを H3 側へ移動する改変も検出する（p1.2 / p2.2 と同じ厳しさに揃えた）"
    - consistency: "前 playbook の受け入れ条件（4ワークフローの健全性）を維持している"
    - completeness: "ワークフロー1〜4 の見出し行・全区間・既存ステップ本文を網羅している"

- [ ] **p_final.6**: references/ 配下2ファイルが base_commit から未変更で、SKILL.md 以外の追加変更・未追跡ファイルがない
  - executor: claudecode
  - test_command: |
    FAILS=""
    DIFF=$(git diff --name-only 113cff0 -- .claude/skills/threads-pdca/)
    [ "$DIFF" = ".claude/skills/threads-pdca/SKILL.md" ] || FAILS="${FAILS}[変更対象が SKILL.md 単独でない:${DIFF}]"
    UNTR=$(git ls-files --others --exclude-standard -- .claude/skills/threads-pdca/)
    [ -z "$UNTR" ] || FAILS="${FAILS}[未追跡ファイルあり:${UNTR}]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "git diff --name-only の出力が SKILL.md の1行のみであることを厳密比較する（未変更で空の場合も FAIL する）。さらに git ls-files --others で未追跡ファイルの混入も検出するため、references/ 配下に新規ファイルを置く逃げ道（デコイ D4）を封じている"
    - consistency: "exclusions（pattern-library.md / my-posts-log.md は変更しない）と一致する"
    - completeness: "スキルディレクトリ配下に想定外のファイル追加（追跡・未追跡の双方）がない"

- [ ] **p_final.7**: state.md の playbook.active / branch / goal.done_criteria が本 playbook と一致している
  - executor: claudecode
  - test_command: |
    P=plan/playbook-threads-pdca-objection-check.md
    FAILS=""
    grep -q 'active: plan/playbook-threads-pdca-objection-check.md' state.md || FAILS="${FAILS}[active不一致]"
    grep -q 'branch: feat/threads-pdca-objection-check' state.md || FAILS="${FAILS}[branch不一致]"
    DWR=$(awk '/^done_when:/{f=1;next} f&&!/^  /{exit} f' "$P" | grep '^  - ')
    DCR=$(awk '/^done_criteria:/{f=1;next} f&&!/^  /{exit} f' state.md | grep '^  - ')
    [ "$(echo "$DWR" | grep -c '^  - ')" -eq 5 ] || FAILS="${FAILS}[playbook の done_when が5件でない]"
    [ "$(echo "$DCR" | grep -c '^  - ')" -eq 5 ] || FAILS="${FAILS}[state.md の done_criteria が5件でない]"
    [ "$(echo "$DWR" | tr -s ' ')" = "$(echo "$DCR" | tr -s ' ')" ] || FAILS="${FAILS}[done_criteria が playbook の done_when と逐語一致しない]"
    [ "$(git branch --show-current)" = "feat/threads-pdca-objection-check" ] || FAILS="${FAILS}[作業ブランチ不一致]"
    [ -z "$FAILS" ] && echo PASS || echo "FAIL($FAILS)"
  - validations:
    - technical: "done_criteria を『キーワードが含まれるか』ではなく playbook の done_when との**逐語一致**で検証する（`tr -s ' '` で空白の揺れのみ正規化）。キーワード入りのダミー5行に差し替えるドリフト（デコイ D5）が FAIL する。両ブロックの件数を独立に5件と要求するため、両方空で一致する偽 PASS も起きない"
    - consistency: "四つ組（focus / state / playbook / branch）の整合性が取れている"
    - completeness: "playbook の goal.done_when（5件）と state.md の goal.done_criteria（5件）が逐語同一である"

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
  - command: `git add .claude/skills/threads-pdca/SKILL.md plan/playbook-threads-pdca-objection-check.md state.md && git commit -m "feat(threads-pdca): 断らせるチェックを Plan/Act ワークフローに追加" && git status --short`
  - status: pending
  - note: |
      `git add -A` は禁止。exclusions で「触らない」と明記した
      .claude/agents/critic.md / .claude/worktrees/（embedded git repo・.gitignore 未登録）/
      plan/playbook-setup-instagram-skills.md を巻き込むため。

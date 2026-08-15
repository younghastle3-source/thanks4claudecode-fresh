# playbook-instagram-pdca-skill.md

> **`.claude/skills/threads-pdca/` の PDCA 設計思想を Instagram に移植し、
> リール / フィード / ストーリーズの使い分けとハッシュタグ戦略を加えた
> `.claude/skills/instagram-pdca/` を新規構築する。**

---

## 実行前提と検証規約

> **本セクションの規約は全 test_command に適用される。**

- **CWD**: 全 test_command はリポジトリルート（`/Users/kosei/thanks4claudecode-fresh`）を
  カレントディレクトリとして実行する。相対パスは全てリポジトリルート起点。
- **シェル**: `bash` / `zsh` のどちらでも同じ結果になるよう記述する（本 playbook の test_command は
  両方で実測済み）。
- **区間抽出**: セクション内容の検証は必ず以下のヘルパで見出し区間を切り出してから行う。

  ```bash
  SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
  ```

  終端を `^#{1,2} ` にしているのは H1（`# 付録` 等）でも区間を閉じるため
  （`^## ` のみだと H1 やファイル末尾に内容を逃がして偽 PASS を作れる）。
  `### ` / `#### ` のサブ見出しでは閉じない（H3 の手順を区間内に留めるため）。
- **見出しにドットを使わない**: 型 ID の見出しは `## IG-R1 フック型リール` の形式とし、
  `## IG-R1. ...` のようにドットを入れない。macOS の awk は `-v` に渡した文字列の
  バックスラッシュを落とすため、`\.` が任意1文字メタに化けて誤マッチするリスクを構造的に排除する。
  番号付きステップの照合が必要な箇所では `grep -cE '^[0-9]+[.] '` のように `[.]` を使う。
- **複数パターンの照合**: `for P in "..." "..."; do ... done` を使う。
  `printf | while read` はパイプがサブシェルを作り、ループ内の失敗が親に伝播しないため使わない。
  シェル配列も bash と zsh でインデックス基点が異なるため使わない。
  失敗は変数 `M` に文字列として蓄積し、最後に空判定する。
- **日本語・記号を含む固定文字列の照合は必ず `grep -qF` / `grep -cF`**（正規表現メタ誤爆の防止）。
- **git のパスは常に `git -c core.quotepath=false`**。これを付けないと非 ASCII を含むパスが
  `"tmp/AI\303\227..."` のように8進エスケープ＋ダブルクォート付きで出力され、パス照合が黙って失敗する
  （本リポジトリの `tmp/AI×営業.html` で実測確認済み）。
- **変数をコマンド名として展開しない**（`G="git -c ..."; $G diff` は zsh が単語分割せず
  `command not found` になる。実測確認済み）。

---

## meta

```yaml
project: thanks4claudecode
branch: feat/instagram-pdca-skill
base_commit: ab66d3e  # main の HEAD（video-editing-ffmpeg スキルのマージ後）。回帰検証の比較元として固定
created: 2026-08-15
issue: null
derives_from: null  # ユーザー資産（スキル）の新規構築であり project.done_when に対応なし
reviewed: true  # reviewer レビュー（Major 4 / Minor 8）の必須6点を反映済み。reviewer の明示的許可に基づき再レビュー省略。反映内容と実測は「pm の自己点検記録 / 5. reviewer 指摘への対応」参照
roles:
  worker: claudecode  # toolstack A（state.md config.roles と一致）
```

---

## goal

```yaml
summary: >
  threads-pdca の PDCA 設計（新規アカウント分析 → Plan → Check → Act ＋ 断らせるチェック）を
  Instagram に移植し、リール/フィード/ストーリーズの使い分け・ハッシュタグ戦略・
  Instagram 固有指標（リーチ/フォロワー外率/保存/シェア/プロフアクセス）を反映した
  .claude/skills/instagram-pdca/ を SKILL.md + references/ 3本の構成で新規構築する。
  既存の instagram 台本スキル2本とは「台本は書かない・型選定と計測に徹する」形で役割分担する。
done_when:
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

## inputs（合意済み素材 / worker の唯一の正典）

> **本セクションが worker の参照すべき唯一の正典（source of truth）である。**
> **ここに無い事実（実アカウントの投稿データ・数値実績・外部の型知識）を worker が創作してはならない。**
> 実アカウント（@okkun_lifestyle）の Instagram 実績データは本 playbook のスコープ外であり、
> スキル完成後にワークフロー1・3を通じてユーザーが手渡しで蓄積する。

### I-1. SKILL.md の起動フレーズ（description に逐語で埋め込む6個）

```
「インスタの投稿分析して」
「インスタの投稿作って」
「インスタの実績を記録して」
「インスタの振り返りして」
「リールとフィードどっちがいい」
「ハッシュタグ考えて」
```

> 鍵括弧込みで逐語一致させること。threads-pdca の description と同じ書式に揃える。
>
> **`description:` は必ず1行で書く。** YAML の folded 記法（`description: >`）や literal 記法
> （`description: |`）で複数行に折り返してはならない。DW1 / p4.1 の判定は
> `grep '^description:'` で1行だけを取り出して照合するため、折り返すと起動フレーズが
> 継続行に落ちて6個すべてが検出できず FAIL する（実測確認済み）。
> 行が長くなっても改行しないこと（threads-pdca の `SKILL.md` も1行で書かれている）。

### I-2. 型ライブラリの初期ラインナップ（8型 / 出典はリポジトリ内資産）

| 型 ID | 名称 | **フォーマット** の値 | 出典（リポジトリ内の一次情報） |
|---|---|---|---|
| IG-R1 | フック型リール | リール | `.claude/skills/instagram-フック型ショート台本.md` |
| IG-R2 | 日常ブリッジ型リール | リール | `.claude/skills/instagram-日常ブリッジ台本.md` |
| IG-R3 | 業界考察・示唆型リール | リール | threads-pdca H型（okkun_lifestyle） |
| IG-F1 | 共感質問型フィード | フィード | threads-pdca B型（leven_base） |
| IG-F2 | 物語・哲学型カルーセル | フィード | threads-pdca C型（leven_base） |
| IG-F3 | イベント告知＋ベネフィット再定義型フィード | フィード | threads-pdca D型（leven_base） |
| IG-F4 | 参加者体験談型（UGC） | フィード | threads-pdca G型（hi.hi.hi999 / tomokazu_0008） |
| IG-S1 | 日常実況型ストーリーズ | ストーリーズ | threads-pdca A型（leven_base） |

> **導出根拠**: IG-R1 / IG-R2 は `.claude/skills/instagram-フック型ショート台本.md` と
> `.claude/skills/instagram-日常ブリッジ台本.md` の実在する構造から、
> IG-R3 / IG-F1〜F4 / IG-S1 は `.claude/skills/threads-pdca/references/pattern-library.md` の
> A〜H 型から、それぞれ Instagram のフォーマットへ割り当てて導出する。
> **型の「構造」はこれらの出典に書かれている内容の範囲で書くこと。**
> Instagram 実績による裏付けはまだ無いため、各型の「効く理由」には
> 出典側の根拠（Threads での実績等）と「Instagram では未検証」である旨を書く。
>
> **意図的に移植しない型**: threads-pdca の E型（コミュニティ勧誘特化）と F型（大義名分型）は、
> `my-posts-log.md` で最下位クラスの実績（1〜4いいね）が確認されているため初期ラインナップから外す。
> 必要になればワークフロー1で後から追加する。
> **したがって型の総数はちょうど8本**（`pattern-library.md` の `^## IG-` が8行）であり、
> 9本目以降を勝手に足してはならない（DW4 の `typecount` で検出される）。
> 除外した型に言及したい場合は「threads-pdca の E型 / F型」と型記号で書き、
> threads 側の型名称を写経しないこと（DW7 の禁止文字列に登録済み）。

#### 使い分け早見表の列順（`pattern-library.md` の `## 使い分け早見表`）

```
| 型 ID | 名称 | フォーマット | 主指標 | 使いどころ |
```

> **3列目を「フォーマット」に固定する。** DW4 は早見表の各行の3列目（`awk -F'|'` の `$4`）を
> 本文の `**フォーマット**: ` の値と突き合わせるため、列順を変えると FAIL する。
> 区切り行は `|---|` を5個並べた行とし、8型の行を各1行ずつ置く（ヘッダ＋区切り＋8行＝10行）。

### I-3. `## 指標の定義` に必須の7指標（`- {指標}: {内容}` の形式で各1行）

```
リーチ
フォロワー外
いいね
コメント
保存
シェア
プロフィールへのアクセス
```

### I-4. `my-posts-log.md` の表ヘッダ（この1行と文字列完全一致させる）

```
| 日付 | 投稿（要約） | フォーマット | 狙った型 | リーチ | フォロワー外% | いいね | コメント | 保存 | シェア | プロフアクセス | 気づき |
```

区切り行は `|---|` を12個並べた行とする。
**テンプレート時点でデータ行（例示行・ダミー行）を1行も入れないこと**
（threads-pdca の `my-posts-log.md` の記入方法と同じ方針。DW6 で機械的に検出される）。

### I-5. DW8 回帰検証の allowlist（この集合以外のファイルが変更されていたら FAIL）

```
^\.claude/skills/instagram-pdca/
^plan/playbook-instagram-pdca-skill\.md$
^plan/playbook-video-editing-ffmpeg-skill\.md$
^state\.md$
^docs/repository-map\.yaml$
^\.claude/agents/critic\.md$
^plan/playbook-setup-instagram-skills\.md$
^tmp/
```

> `.claude/agents/critic.md`（modified）・`plan/playbook-setup-instagram-skills.md`（untracked）・
> `tmp/AI×営業.html`（deleted）は本タスク開始時点で既に作業ツリーに存在した**先行の未コミット差分**であり、
> 本タスクの成果物ではない。allowlist に含めるが、**コミットしてはならない**（final_tasks ft3 参照）。
> `plan/playbook-video-editing-ffmpeg-skill.md` は前タスクのクローズ処理による変更。

### I-6. 既存スキルとの役割分担（`## 既存スキルとの役割分担` に表として記載する4行）

| スキル | 担当範囲 | 呼び出す場面 |
|---|---|---|
| 本スキル（instagram-pdca） | フォーマット選定・型選定・キャプション・ハッシュタグ・実績記録・振り返り | 投稿の企画時と投稿後 |
| `.claude/skills/instagram-フック型ショート台本.md` | リールの一言目（フック）と台本の文体 | IG-R1 を選んだ後、台本を書くとき |
| `.claude/skills/instagram-日常ブリッジ台本.md` | リールの構成設計（日常→本題への導線） | IG-R2 を選んだ後、構成を組むとき |
| `.claude/skills/threads-pdca/` | Threads 側の PDCA（型 A〜H・Threads 実績ログ） | Threads の投稿を扱うとき |

> **本スキルはリール台本本文を書かない。** 台本の生成・添削は既存2スキルに委譲する。
> `pattern-library.md` にフックの型名・文体ルールを書き写すと二重管理になるため禁止（DW7 で検出）。
> Threads の型ライブラリとは統合しない（指標も最適フォーマットも異なるため）。
>
> **既知の重複（本タスクでは解消しない）**: 以下2組はリポジトリ内で**内容が完全一致**している
> （`diff` で差分0を実測確認済み）。
>
> | 単体ファイル | 同内容のスキル |
> |---|---|
> | `.claude/skills/instagram-フック型ショート台本.md` | `.claude/skills/しゅうへい式リールshort-video-hook/SKILL.md` |
> | `.claude/skills/instagram-日常ブリッジ台本.md` | `.claude/skills/daily-bridge/SKILL.md` |
>
> 本 playbook は**単体ファイル側のパスを正**として参照する（I-6 の表・DW3・DW4 の委譲先はすべて単体ファイル）。
> 既存の重複自体の統廃合は**本タスクのスコープ外**（DW8 の allowlist により、
> これらのファイルへの変更は回帰 FAIL になる）。整理が必要なら別 playbook を立てる。

### I-7. 非重複の禁止文字列（`.claude/skills/instagram-pdca/` 配下に出現してはならない）

**(a) 既存の instagram 台本スキル2本に固有の見出し・型名**

```
数字×悲劇
行動×ネガティブ結果
Gap Hook
日常ブリッジの5つの入口パターン
ブリッジ台本を書く
```

**(b) threads-pdca に固有の見出し・型名**（Threads 側からの写経を防ぐ）

```
Threads 投稿 型ライブラリ
A〜H の使い分け早見表
コミュニティ勧誘特化型
大義名分型コミュニティ立ち上げ
```

> (a) は既存の instagram 台本スキル2本、(b) は `.claude/skills/threads-pdca/references/pattern-library.md`
> に実在する文字列（`grep` で存在を実測確認済み。`A〜H の使い分け早見表` は「H」と「の」の間の
> **半角スペース込み**が正）。
> 参照したい場合はファイルパスへのポインタで示し、内容を写経しないこと。
>
> **(b) の意図**: threads-pdca は本スキルの設計上の親であり、pattern-library をそのまま
> 貼り付けると (1) A〜H 型が Instagram 用の8型と二重に存在し、(2) 意図的に除外した E型/F型が
> 復活する。(b) の4文字列は threads の型ライブラリを全文コピーすると必ず混入するため、
> 写経を構造的に検出できる（threads の `pattern-library.md` を全文追記して FAIL を実測済み）。
> なお threads の `SKILL.md` を全文コピーした場合は `## ワークフロー{N}` が重複するため
> DW2 の `h2:{N}` で検出される（実測済み）。

### I-8. ワークフロー見出しの規約（PDCA の並びを固定する）

| 見出し | 必須キーワード（見出し行に逐語で含める） | 対応する PDCA |
|---|---|---|
| `## ワークフロー1: ...` | `分析` | 新規アカウント分析（Research） |
| `## ワークフロー2: ...` | `Plan` | 型選定・下書き |
| `## ワークフロー3: ...` | `Check` | 実績記録 |
| `## ワークフロー4: ...` | `Act` | 集計・振り返り |

> threads-pdca の `SKILL.md`（分析→Plan→Check→Act）と並びを揃えるための規約。
> キーワードを見出し行に固定することで、**番号と中身が入れ替わった状態を検出できる**
> （WF1 の見出しを「週次の集計」に差し替えると `kw:1/分析` で FAIL することを実測済み）。
> 見出し全体は `## ワークフロー2: Plan（フォーマット選定→型選定→下書き）` のように
> 「番号 + 必須キーワード + 補足」の形式で書く。

### I-9. ファイル間整合性の規約（3ファイルを機械的に突き合わせる）

```yaml
R1_型IDの実在:
  ルール: format-guide.md の `- 向いている型: ` に書く型 ID は、
          全て pattern-library.md に `## {ID} ` として実在すること
  記法: 複数列挙は `/` 区切り（例: `- 向いている型: IG-R1/IG-R2/IG-R3`）

R2_型IDの網羅:
  ルール: I-2 の8型は、それぞれ**自分のフォーマットのセクション**の
          `- 向いている型: ` に必ず列挙されること
          （IG-S1 は `## ストーリーズ` の行に載る。`## リール` の行に載せてはいけない）

R3_指標名の実在:
  ルール: pattern-library.md の `**主指標**: ` に書く指標名は、
          全て format-guide.md の `## 指標の定義` に `- {指標}: ` として実在すること
  記法: 複数列挙は `/` 区切り（例: `**主指標**: リーチ/フォロワー外`）
  注意: I-3 の7指標の表記をそのまま使う（「エンゲージメント率」等の新語を作らない）

R4_早見表の一致:
  ルール: `## 使い分け早見表` の各行の3列目（フォーマット）が、
          その型の本文 `**フォーマット**: ` の値と文字列一致すること

R5_プレースホルダ禁止:
  ルール: `.claude/skills/instagram-pdca/` 配下に
          `TBD` / `TODO` / `FIXME` / `後で書く` を含むファイルが0件であること
  意図: 見出しと箇条書きの体裁だけ整えて中身を空にする逃げ道を塞ぐ
  注意: 「未検証」「暫定」は正当な記述なので禁止語に含めない
```

> R1〜R5 は DW9 / p2.6 / p_final.9 で機械検証する。
> **散文の validations に書くだけでは検証されない**（レビューで指摘された穴の是正）。

---

## phases

### p1: フォーマット・指標ガイドの作成

**goal**: `references/format-guide.md` に、リール/フィード/ストーリーズの使い分け・ハッシュタグ戦略・Instagram 指標の定義を書き、以降の Phase が参照できる土台を作る

#### subtasks

- [ ] **p1.1**: `.claude/skills/instagram-pdca/references/format-guide.md` が存在し、`## リール` / `## フィード` / `## ストーリーズ` / `## ハッシュタグ戦略` / `## 指標の定義` の H2 が各1本ずつ存在する
  - executor: claudecode
  - test_command: |
    F=.claude/skills/instagram-pdca/references/format-guide.md; M=""
    test -f "$F" || M="$M nofile;"
    for H in リール フィード ストーリーズ ハッシュタグ戦略 指標の定義; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "ファイルが存在し、5つの H2 が重複なく各1本ずつ検出できる"
    - consistency: "見出し名が pattern-library.md の `**フォーマット**` の値（リール/フィード/ストーリーズ）と同じ表記で揃っている"
    - completeness: "使い分け3種＋ハッシュタグ＋指標の5要素が全て揃っている"

- [ ] **p1.2**: リール / フィード / ストーリーズの各区間に `- 役割: ` `- 主指標: ` `- 向いている型: ` `- 選ぶ判断: ` で始まり内容が続く行が各1行ずつ存在する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/format-guide.md; M=""
    for H in リール フィード ストーリーズ; do
      B=$(SEC "$F" "^## $H\$")
      for K in 役割 主指標 向いている型 選ぶ判断; do
        [ "$(echo "$B" | grep -cE "^- $K: .+")" -eq 1 ] || M="$M $H/$K;"
      done
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "区間抽出が H2 で閉じ、他セクションの行を拾っていない（見出しを消すと FAIL になることをデコイ D11/D12 で実測済み）"
    - consistency: "`- 向いている型:` に列挙する型 ID が I-2 の8型の ID と一致している"
    - completeness: "3フォーマット × 4項目 = 12行が全て埋まっている"

- [ ] **p1.3**: `## ハッシュタグ戦略` 区間に行頭 `- ` の行が5行以上あり、『大規模』『中規模』『小規模』が逐語で含まれる
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/format-guide.md; M=""
    B=$(SEC "$F" "^## ハッシュタグ戦略\$")
    [ "$(echo "$B" | grep -cE '^- .+')" -ge 5 ] || M="$M lines;"
    for K in 大規模 中規模 小規模; do echo "$B" | grep -qF "$K" || M="$M tag:$K;"; done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "区間内の箇条書き行数と3キーワードの逐語存在を同時に検証している"
    - consistency: "地域タグの扱いが pattern-library.md の IG-F3（告知系のみ地域名）と矛盾しない"
    - completeness: "規模3区分・個数の目安・地域タグの扱い・合計の目安が揃っている"

- [ ] **p1.4**: `## 指標の定義` 区間に I-3 の7指標の定義行（`- {指標}: {内容}`）が各1行ずつ存在する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/format-guide.md; M=""
    B=$(SEC "$F" "^## 指標の定義\$")
    for K in リーチ フォロワー外 いいね コメント 保存 シェア プロフィールへのアクセス; do
      [ "$(echo "$B" | grep -cE "^- $K: .+")" -eq 1 ] || M="$M kpi:$K;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "7指標それぞれが定義行として1行ずつ存在する（1行削ると FAIL になることをデコイ D10 で実測済み）"
    - consistency: "指標名が my-posts-log.md のヘッダ列（I-4）と対応が取れている"
    - completeness: "リールの評価軸（フォロワー外）とフィードの評価軸（保存・コメント）が両方定義されている"

**status**: pending
**max_iterations**: 5
**time_limit**: 30min
**priority**: high

---

### p2: 型ライブラリの作成

**goal**: `references/pattern-library.md` に I-2 の8型を、出典・フォーマット・主指標・構造・効く理由つきで定義する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: `references/pattern-library.md` の型 H2（`^## IG-`）がちょうど8本であり、それが I-2 の8型（`## IG-R1 `〜`## IG-S1 `）と一致する
  - executor: claudecode
  - test_command: |
    F=.claude/skills/instagram-pdca/references/pattern-library.md; M=""
    test -f "$F" || M="$M nofile;"
    N=$(grep -c '^## IG-' "$F"); [ "$N" -eq 8 ] || M="$M typecount:$N(want8);"
    for ID in IG-R1 IG-R2 IG-R3 IG-F1 IG-F2 IG-F3 IG-F4 IG-S1; do
      [ "$(grep -c "^## $ID " "$F")" -eq 1 ] || M="$M h2:$ID;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "8型の H2 が重複なく各1本ずつ検出できる（ID を改名すると FAIL することをデコイ D9 で実測済み）。総数を8本に固定しているため、I-2 で意図的に除外した E型/F型 相当を9本目として足すと `typecount:9` で FAIL する（デコイ D21 で実測済み）"
    - consistency: "型 ID が I-2 の表・format-guide.md の `- 向いている型:` と一致している"
    - completeness: "リール3型・フィード4型・ストーリーズ1型の計8型が揃っている"

- [ ] **p2.2**: 各型区間に `**フォーマット**: {I-2 で定めた値}` が逐語で存在し、`**出典**: ` / `**主指標**: ` の行が各1行、`### 型の構造` / `### 効く理由` の H3 が各1本存在する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/pattern-library.md; M=""
    for T in "IG-R1 リール" "IG-R2 リール" "IG-R3 リール" "IG-F1 フィード" "IG-F2 フィード" \
             "IG-F3 フィード" "IG-F4 フィード" "IG-S1 ストーリーズ"; do
      ID=${T% *}; FMT=${T#* }
      B=$(SEC "$F" "^## $ID ")
      echo "$B" | grep -qxF "**フォーマット**: $FMT" || M="$M fmt:$ID;"
      [ "$(echo "$B" | grep -cE '^\*\*出典\*\*: .+')" -eq 1 ] || M="$M src:$ID;"
      [ "$(echo "$B" | grep -cE '^\*\*主指標\*\*: .+')" -eq 1 ] || M="$M kpi:$ID;"
      [ "$(echo "$B" | grep -c '^### 型の構造')" -eq 1 ] || M="$M struct:$ID;"
      [ "$(echo "$B" | grep -c '^### 効く理由')" -eq 1 ] || M="$M why:$ID;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "`grep -qxF` の行完全一致でフォーマット値を照合しており、ID とフォーマットの対応を入れ替えると FAIL する（デコイ D7 で実測済み）"
    - consistency: "`**主指標**` の指標名が format-guide.md の `## 指標の定義` の7指標に含まれている"
    - completeness: "8型 × 5要素が全て揃っている"

- [ ] **p2.3**: 各型区間に行頭が `【` の構造行が3行以上存在する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/pattern-library.md; M=""
    for ID in IG-R1 IG-R2 IG-R3 IG-F1 IG-F2 IG-F3 IG-F4 IG-S1; do
      [ "$(SEC "$F" "^## $ID " | grep -c '^【')" -ge 3 ] || M="$M lines:$ID;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "構造行を1行削ると FAIL する（デコイ D8 で実測済み）"
    - consistency: "構造の記法（`【1】`〜）が threads-pdca の pattern-library.md と揃っている"
    - completeness: "全8型が骨格3行以上の実体を持ち、見出しだけの空型が存在しない"

- [ ] **p2.4**: IG-R1 区間に `instagram-フック型ショート台本.md`、IG-R2 区間に `instagram-日常ブリッジ台本.md` が逐語で含まれる（出典と委譲先の明示）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/pattern-library.md; M=""
    SEC "$F" "^## IG-R1 " | grep -qF 'instagram-フック型ショート台本.md' || M="$M delegR1;"
    SEC "$F" "^## IG-R2 " | grep -qF 'instagram-日常ブリッジ台本.md' || M="$M delegR2;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "該当区間内に限定して逐語照合しており、他セクションへの記載では PASS しない"
    - consistency: "SKILL.md の `## 既存スキルとの役割分担`（I-6）の委譲先と一致している"
    - completeness: "リール2型の両方に委譲先が明示されている"

- [ ] **p2.5**: `## 使い分け早見表` の H2 が1本存在し、区間の `|` 行が10行以上あり、8型それぞれの行がちょうど1行ずつあり、各行の3列目（フォーマット列）が本文の `**フォーマット**: ` と一致する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/pattern-library.md; M=""
    [ "$(grep -c '^## 使い分け早見表$' "$F")" -eq 1 ] || M="$M h2;"
    B=$(SEC "$F" "^## 使い分け早見表\$")
    [ "$(echo "$B" | grep -c '^|')" -ge 10 ] || M="$M rows;"
    for T in "IG-R1 リール" "IG-R2 リール" "IG-R3 リール" "IG-F1 フィード" "IG-F2 フィード" \
             "IG-F3 フィード" "IG-F4 フィード" "IG-S1 ストーリーズ"; do
      ID=${T% *}; FMT=${T#* }
      R=$(echo "$B" | grep -cF "| $ID |"); [ "$R" -eq 1 ] || { M="$M row:$ID($R);"; continue; }
      RF=$(echo "$B" | grep -F "| $ID |" | awk -F'|' '{gsub(/ /,"",$4); print $4}')
      [ "$RF" = "$FMT" ] || M="$M rowfmt:$ID($RF);"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "早見表を型 ID の無い別表に差し替えると `row:{ID}(0)` で、フォーマット列を本文と矛盾させると `rowfmt:{ID}` で FAIL する（デコイ D17/D18 で実測済み）。列順は I-2 の規約（3列目＝フォーマット）に固定されている"
    - consistency: "早見表の型 ID・フォーマットが本文の各型セクション（p2.2）と機械的に突き合わされている"
    - completeness: "8型全てが早見表にちょうど1行ずつ載っており、本文にあって表に無い型・表で重複した型が存在しない"

- [ ] **p2.6**: format-guide.md と pattern-library.md の整合性（I-9 の R1〜R3）が成立している
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    S=.claude/skills/instagram-pdca
    G=$S/references/format-guide.md; P=$S/references/pattern-library.md; M=""
    for ID in $(grep -h '^- 向いている型: ' "$G" | sed 's/^- 向いている型: //' | tr '/' ' '); do
      grep -q "^## $ID " "$P" || M="$M badid:$ID;"
    done
    for KPI in $(grep -h '^\*\*主指標\*\*: ' "$P" | sed 's/^\*\*主指標\*\*: //' | tr '/' ' '); do
      grep -qF -- "- $KPI: " "$G" || M="$M badkpi:$KPI;"
    done
    for T in "IG-R1 リール" "IG-R2 リール" "IG-R3 リール" "IG-F1 フィード" "IG-F2 フィード" \
             "IG-F3 フィード" "IG-F4 フィード" "IG-S1 ストーリーズ"; do
      ID=${T% *}; FMT=${T#* }
      SEC "$G" "^## $FMT\$" | grep '^- 向いている型: ' | grep -qF -- "$ID" || M="$M unlisted:$ID/$FMT;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "実在しない型 ID を書くと `badid:`、format-guide に無い指標名を書くと `badkpi:`、型を誤ったフォーマット欄に置くと `unlisted:` で FAIL する（デコイ D19/D20/D22 で実測済み）"
    - consistency: "散文の validations ではなく test_command で2ファイル間の参照整合性を検証している（R1〜R3）"
    - completeness: "型 ID は双方向（実在＋網羅）、指標名は片方向（実在）で検証している"

**status**: pending
**max_iterations**: 5
**time_limit**: 45min
**priority**: high

---

### p3: 投稿実績ログテンプレートの作成

**goal**: `references/my-posts-log.md` を Instagram 指標に対応した12列の空テンプレートとして作成する

**depends_on**: [p1]

#### subtasks

- [ ] **p3.1**: `references/my-posts-log.md` の `## 投稿実績ログ` 区間で `|` 始まりの行がちょうど2行（データ行0件）であり、ヘッダ行が I-4 の12列ヘッダと文字列完全一致する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/my-posts-log.md; M=""
    test -f "$F" || M="$M nofile;"
    [ "$(grep -c '^## 投稿実績ログ$' "$F")" -eq 1 ] || M="$M h2;"
    B=$(SEC "$F" "^## 投稿実績ログ\$")
    N=$(echo "$B" | grep -c '^|'); [ "$N" -eq 2 ] || M="$M rows:$N(want2);"
    HDR=$(echo "$B" | grep '^|' | head -1)
    EXP='| 日付 | 投稿（要約） | フォーマット | 狙った型 | リーチ | フォロワー外% | いいね | コメント | 保存 | シェア | プロフアクセス | 気づき |'
    [ "$HDR" = "$EXP" ] || M="$M header;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "ダミー行を1行入れると rows:3 で FAIL し、列を1つ削ると header で FAIL する（デコイ D13/D14 で実測済み）"
    - consistency: "12列が I-4 と完全一致し、指標名が format-guide.md の `## 指標の定義` と対応している"
    - completeness: "日付・要約・フォーマット・型・7指標・気づきの12列が揃っている"

- [ ] **p3.2**: `## 記入方法` の H2 が1本存在し、その区間に行頭 `- ` の行が6行以上あり、『ダミーデータ・例示行を入れない』『format-guide.md』『pattern-library.md』が逐語で含まれる
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/my-posts-log.md; M=""
    [ "$(grep -c '^## 記入方法$' "$F")" -eq 1 ] || M="$M h2;"
    B=$(SEC "$F" "^## 記入方法\$")
    [ "$(echo "$B" | grep -cE '^- .+')" -ge 6 ] || M="$M lines;"
    for P in "ダミーデータ・例示行を入れない" "format-guide.md" "pattern-library.md"; do
      echo "$B" | grep -qF -- "$P" || M="$M miss:$P;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "6行以上の記入ルールと3つの逐語文字列を同時に検証している"
    - consistency: "型記号の記入例（IG-R1 等）が pattern-library.md の ID と一致している"
    - completeness: "全12列それぞれの記入ルールと、取得不能時の `-` の扱いが書かれている"

**status**: pending
**max_iterations**: 5
**time_limit**: 20min
**priority**: medium

---

### p4: SKILL.md（ルーティング・4ワークフロー・役割分担）の作成

**goal**: 4つのワークフローと既存スキルとの役割分担を定義した `SKILL.md` を作成し、スキルとして起動可能にする

**depends_on**: [p1, p2, p3]

#### subtasks

- [ ] **p4.1**: `SKILL.md` の先頭 frontmatter 内に `name: instagram-pdca` の行が存在し、`description:` 行に I-1 の起動フレーズ6個が全て逐語（鍵括弧込み）で含まれる
  - executor: claudecode
  - test_command: |
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    test -f "$F" || M="$M nofile;"
    head -1 "$F" | grep -qx -- '---' || M="$M nofrontmatter;"
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$F")
    echo "$FM" | grep -qx 'name: instagram-pdca' || M="$M name;"
    D=$(echo "$FM" | grep '^description:'); [ -n "$D" ] || M="$M nodesc;"
    for P in "「インスタの投稿分析して」" "「インスタの投稿作って」" "「インスタの実績を記録して」" \
             "「インスタの振り返りして」" "「リールとフィードどっちがいい」" "「ハッシュタグ考えて」"; do
      echo "$D" | grep -qF -- "$P" || M="$M phrase:$P;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "frontmatter を1行目の `---` から次の `---` までに限定して抽出しており、本文への記載では PASS しない。フレーズを1個削ると FAIL する（デコイ D1/D2 で実測済み）"
    - consistency: "`name` がディレクトリ名 `instagram-pdca` と一致している（threads-pdca と同じ規約）"
    - completeness: "6フレーズが全て含まれ、リール/フィード判断とハッシュタグの導線も起動可能になっている"

- [ ] **p4.2**: `## ワークフロー1`〜`## ワークフロー4` の H2 が各1本ずつ存在し、各見出し行に I-8 の必須キーワード（分析/Plan/Check/Act）が含まれ、各区間内に『発火フレーズ』を含む行が1行以上・番号付きステップが3行以上・`references/` を含む行が1行以上存在する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    for T in "1 分析" "2 Plan" "3 Check" "4 Act"; do
      W=${T% *}; KW=${T#* }
      [ "$(grep -c "^## ワークフロー$W" "$F")" -eq 1 ] || { M="$M h2:$W;"; continue; }
      grep "^## ワークフロー$W" "$F" | grep -qF -- "$KW" || M="$M kw:$W/$KW;"
      B=$(SEC "$F" "^## ワークフロー$W")
      [ "$(echo "$B" | grep -cF '発火フレーズ')" -ge 1 ] || M="$M trigger:$W;"
      [ "$(echo "$B" | grep -cE '^[0-9]+[.] ')" -ge 3 ] || M="$M steps:$W;"
      [ "$(echo "$B" | grep -cF 'references/')" -ge 1 ] || M="$M ref:$W;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "ステップを2個に減らす／references 参照を消すと FAIL する（デコイ D16 で実測済み）。WF1 と WF4 の見出しを入れ替えると `kw:{N}/{キーワード}` で FAIL する（デコイ D24 で実測済み）"
    - consistency: "4ワークフローの並びと役割が threads-pdca の SKILL.md（分析→Plan→Check→Act）と対応しており、I-8 の規約で番号と中身の対応が固定されている"
    - completeness: "全ワークフローが手順・発火フレーズ・参照ファイル・PDCA キーワードの4点を備えている"

- [ ] **p4.3**: 断らせるチェックの導線が構造として成立している（WF2 の番号付きステップ行に『断らせる』、WF4 の番号付きステップ行に『原因分析』、WF2 区間内に H3 `### 断らせるチェックの手順` が存在し、**その H3 区間の内側で**『ペルソナ』の初出が『**10個**』の初出より前）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    SEC "$F" "^## ワークフロー2" | grep -E '^[0-9]+[.] ' | grep -qF '断らせる' || M="$M wf2step;"
    SEC "$F" "^## ワークフロー4" | grep -E '^[0-9]+[.] ' | grep -qF '原因分析' || M="$M wf4step;"
    B=$(SEC "$F" "^## ワークフロー2")
    echo "$B" | grep -q '^### 断らせるチェックの手順' || M="$M h3;"
    B3=$(echo "$B" | awk '/^### 断らせるチェックの手順/{f=1;next} /^#{1,3} /{f=0} f')
    PN=$(echo "$B3" | grep -nF 'ペルソナ' | head -1 | cut -d: -f1)
    TN=$(echo "$B3" | grep -nF '**10個**' | head -1 | cut -d: -f1)
    { [ -n "$PN" ] && [ -n "$TN" ] && [ "$PN" -lt "$TN" ]; } || M="$M order;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "H3 を H2 に格上げして区間外へ逃がす／導線ステップをダミーに差し替える／ペルソナと10個の順序を逆転させる の3改悪で FAIL する（デコイ D3/D4/D5 で実測済み）。順序判定を H3 区間（`### 断らせるチェックの手順` から次の H1〜H3 まで）に限定しているため、**H3 の外側に『ペルソナ』の語を1つ置いて H3 内の順序を逆転させる**回避も FAIL する（デコイ D23 で実測済み。区間限定前は同じ改悪が PASS することも実測済み）"
    - consistency: "断らせるチェックの手順が threads-pdca の SKILL.md と同じ4ステップ構造（ペルソナ→10個→3分類→反映）になっている"
    - completeness: "Plan 側（WF2）と Act 側（WF4）の両方に断らせるチェックが組み込まれている"

- [ ] **p4.4**: `## 既存スキルとの役割分担` の H2 が1本存在し、区間内に I-6 の4文字列が全て逐語で含まれ、『委譲』を含む行が1行以上、`|` 始まりの表の行が6行以上ある
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    [ "$(grep -c '^## 既存スキルとの役割分担$' "$F")" -eq 1 ] || M="$M h2;"
    B=$(SEC "$F" "^## 既存スキルとの役割分担\$")
    for P in ".claude/skills/instagram-フック型ショート台本.md" \
             ".claude/skills/instagram-日常ブリッジ台本.md" \
             ".claude/skills/threads-pdca/" "instagram-pdca"; do
      echo "$B" | grep -qF -- "$P" || M="$M miss:$P;"
    done
    [ "$(echo "$B" | grep -cF '委譲')" -ge 1 ] || M="$M delegation;"
    [ "$(echo "$B" | grep -c '^|')" -ge 6 ] || M="$M table;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "パスを短縮表記に変えると FAIL する（デコイ D6 で実測済み）。フルパスでの逐語照合により実在ファイルへの導線を保証している"
    - consistency: "表の4行が I-6 と一致し、pattern-library.md の IG-R1/IG-R2 の委譲先（p2.4）と矛盾しない"
    - completeness: "既存 instagram 台本スキル2本と threads-pdca の3方向すべてとの境界が定義されている"

- [ ] **p4.5**: `.claude/skills/instagram-pdca/` 配下に I-7 の禁止文字列9個（台本スキル5個＋threads-pdca 4個）を含むファイルが0件である（既存スキル・threads-pdca の写経が無い）
  - executor: claudecode
  - test_command: |
    S=.claude/skills/instagram-pdca; M=""
    for P in "数字×悲劇" "行動×ネガティブ結果" "Gap Hook" "日常ブリッジの5つの入口パターン" "ブリッジ台本を書く" \
             "Threads 投稿 型ライブラリ" "A〜H の使い分け早見表" "コミュニティ勧誘特化型" "大義名分型コミュニティ立ち上げ"; do
      N=$(grep -rlF -- "$P" "$S" 2>/dev/null | wc -l | tr -d ' ')
      [ "$N" -eq 0 ] || M="$M dup:$P;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "既存スキル固有の型名を1つでも書き写すと FAIL する（デコイ D15 で実測済み）。threads-pdca の `references/pattern-library.md` を全文追記すると4文字列が同時に検出されて FAIL する（デコイ D25 で実測済み）"
    - consistency: "役割分担（p4.4）で宣言した『台本は書かない』『Threads の型ライブラリとは統合しない』が実ファイルの中身でも守られている"
    - completeness: "SKILL.md と references/ 3本の全ファイルを再帰的に走査しており、写経元の2方向（台本スキル / threads-pdca）を両方カバーしている"

**status**: pending
**max_iterations**: 5
**time_limit**: 45min
**priority**: high

---

### p_final: 完了検証（必須）

> **playbook の done_when（DW1〜DW9）が実際に満たされているか最終検証する。**
> **DW1〜DW7・DW9 は下記の一括スクリプトを一度実行し、その出力行を各 subtask の証拠として引用してよい。**
> **DW8 は git 状態に依存するため、ft1〜ft3 の実行後に単独で再実行すること。**

```bash
# p_final 一括実行スクリプト（リポジトリルートで実行）
S=".claude/skills/instagram-pdca"
SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
# 各 subtask の test_command を DW1..DW7, DW9 の順に実行し、"DWn PASS" / "DWn FAIL{理由}" を出力する
```

#### subtasks

- [ ] **p_final.1**: DW1 が満たされている（SKILL.md frontmatter の name と起動フレーズ6個）
  - executor: claudecode
  - test_command: |
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    head -1 "$F" | grep -qx -- '---' || M="$M nofrontmatter;"
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$F")
    echo "$FM" | grep -qx 'name: instagram-pdca' || M="$M name;"
    D=$(echo "$FM" | grep '^description:')
    for P in "「インスタの投稿分析して」" "「インスタの投稿作って」" "「インスタの実績を記録して」" \
             "「インスタの振り返りして」" "「リールとフィードどっちがいい」" "「ハッシュタグ考えて」"; do
      echo "$D" | grep -qF -- "$P" || M="$M phrase:$P;"
    done
    [ -z "$M" ] && echo "DW1 PASS" || echo "DW1 FAIL$M"
  - validations:
    - technical: "frontmatter 限定抽出＋逐語照合。デコイ D1/D2 で FAIL を実測済み"
    - consistency: "p4.1 と同一の判定ロジックであり、Phase 判定と完了判定が乖離しない"
    - completeness: "name と6フレーズの全項目を検証している"

- [ ] **p_final.2**: DW2 が満たされている（4ワークフローの構造と断らせるチェックの導線）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    for T in "1 分析" "2 Plan" "3 Check" "4 Act"; do
      W=${T% *}; KW=${T#* }
      [ "$(grep -c "^## ワークフロー$W" "$F")" -eq 1 ] || { M="$M h2:$W;"; continue; }
      grep "^## ワークフロー$W" "$F" | grep -qF -- "$KW" || M="$M kw:$W/$KW;"
      B=$(SEC "$F" "^## ワークフロー$W")
      [ "$(echo "$B" | grep -cF '発火フレーズ')" -ge 1 ] || M="$M trigger:$W;"
      [ "$(echo "$B" | grep -cE '^[0-9]+[.] ')" -ge 3 ] || M="$M steps:$W;"
      [ "$(echo "$B" | grep -cF 'references/')" -ge 1 ] || M="$M ref:$W;"
    done
    SEC "$F" "^## ワークフロー2" | grep -E '^[0-9]+[.] ' | grep -qF '断らせる' || M="$M wf2step;"
    SEC "$F" "^## ワークフロー4" | grep -E '^[0-9]+[.] ' | grep -qF '原因分析' || M="$M wf4step;"
    B=$(SEC "$F" "^## ワークフロー2")
    echo "$B" | grep -q '^### 断らせるチェックの手順' || M="$M h3;"
    B3=$(echo "$B" | awk '/^### 断らせるチェックの手順/{f=1;next} /^#{1,3} /{f=0} f')
    PN=$(echo "$B3" | grep -nF 'ペルソナ' | head -1 | cut -d: -f1)
    TN=$(echo "$B3" | grep -nF '**10個**' | head -1 | cut -d: -f1)
    { [ -n "$PN" ] && [ -n "$TN" ] && [ "$PN" -lt "$TN" ]; } || M="$M order;"
    [ -z "$M" ] && echo "DW2 PASS" || echo "DW2 FAIL$M"
  - validations:
    - technical: "デコイ D3/D4/D5/D16/D23/D24 の6種で FAIL を実測済み。順序判定は H3 区間の内側に限定してあり、H3 の外に『ペルソナ』を置く回避が効かない"
    - consistency: "p4.2 と p4.3 の判定を統合しており、両者と同一の閾値・同一の区間抽出（`B3`）を使っている"
    - completeness: "4ワークフロー × 4要素（見出しキーワード・発火フレーズ・ステップ・参照）＋ 断らせる導線4点を検証している"

- [ ] **p_final.3**: DW3 が満たされている（既存スキルとの役割分担）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    [ "$(grep -c '^## 既存スキルとの役割分担$' "$F")" -eq 1 ] || M="$M h2;"
    B=$(SEC "$F" "^## 既存スキルとの役割分担\$")
    for P in ".claude/skills/instagram-フック型ショート台本.md" \
             ".claude/skills/instagram-日常ブリッジ台本.md" \
             ".claude/skills/threads-pdca/" "instagram-pdca"; do
      echo "$B" | grep -qF -- "$P" || M="$M miss:$P;"
    done
    [ "$(echo "$B" | grep -cF '委譲')" -ge 1 ] || M="$M delegation;"
    [ "$(echo "$B" | grep -c '^|')" -ge 6 ] || M="$M table;"
    [ -z "$M" ] && echo "DW3 PASS" || echo "DW3 FAIL$M"
  - validations:
    - technical: "デコイ D6 で FAIL を実測済み"
    - consistency: "参照先パスが実在することを別途 `test -f` で確認する（下記 completeness 参照）"
    - completeness: "照合した2つの台本スキルパスが実在することも併せて確認する（`test -f '.claude/skills/instagram-フック型ショート台本.md'` / `test -f '.claude/skills/instagram-日常ブリッジ台本.md'`）"

- [ ] **p_final.4**: DW4 が満たされている（型ライブラリ8型の完全性）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/pattern-library.md; M=""
    N=$(grep -c '^## IG-' "$F"); [ "$N" -eq 8 ] || M="$M typecount:$N(want8);"
    T2=$(SEC "$F" "^## 使い分け早見表\$")
    for T in "IG-R1 リール" "IG-R2 リール" "IG-R3 リール" "IG-F1 フィード" "IG-F2 フィード" \
             "IG-F3 フィード" "IG-F4 フィード" "IG-S1 ストーリーズ"; do
      ID=${T% *}; FMT=${T#* }
      [ "$(grep -c "^## $ID " "$F")" -eq 1 ] || { M="$M h2:$ID;"; continue; }
      B=$(SEC "$F" "^## $ID ")
      echo "$B" | grep -qxF "**フォーマット**: $FMT" || M="$M fmt:$ID;"
      [ "$(echo "$B" | grep -cE '^\*\*出典\*\*: .+')" -eq 1 ] || M="$M src:$ID;"
      [ "$(echo "$B" | grep -cE '^\*\*主指標\*\*: .+')" -eq 1 ] || M="$M kpi:$ID;"
      [ "$(echo "$B" | grep -c '^### 型の構造')" -eq 1 ] || M="$M struct:$ID;"
      [ "$(echo "$B" | grep -c '^### 効く理由')" -eq 1 ] || M="$M why:$ID;"
      [ "$(echo "$B" | grep -c '^【')" -ge 3 ] || M="$M lines:$ID;"
      R=$(echo "$T2" | grep -cF "| $ID |"); [ "$R" -eq 1 ] || { M="$M row:$ID($R);"; continue; }
      RF=$(echo "$T2" | grep -F "| $ID |" | awk -F'|' '{gsub(/ /,"",$4); print $4}')
      [ "$RF" = "$FMT" ] || M="$M rowfmt:$ID($RF);"
    done
    SEC "$F" "^## IG-R1 " | grep -qF 'instagram-フック型ショート台本.md' || M="$M delegR1;"
    SEC "$F" "^## IG-R2 " | grep -qF 'instagram-日常ブリッジ台本.md' || M="$M delegR2;"
    [ "$(grep -c '^## 使い分け早見表$' "$F")" -eq 1 ] || M="$M h2table;"
    [ "$(echo "$T2" | grep -c '^|')" -ge 10 ] || M="$M table;"
    [ -z "$M" ] && echo "DW4 PASS" || echo "DW4 FAIL$M"
  - validations:
    - technical: "デコイ D7/D8/D9/D17/D18/D21 の6種で FAIL を実測済み。早見表は行数だけでなく**8型それぞれの行の存在（ちょうど1行）とフォーマット列の本文一致**まで検証しており、型 ID の無い別表への差し替えでは PASS しない"
    - consistency: "p2.1〜p2.5 の判定を統合しており、同一の閾値・同一の列位置（`awk -F'|'` の `$4`）を使っている"
    - completeness: "型総数8本 ＋ 8型 × 6要素 ＋ 委譲先2件 ＋ 早見表（行数・行の存在・フォーマット一致）を検証している"

- [ ] **p_final.5**: DW5 が満たされている（フォーマット・指標ガイド）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/format-guide.md; M=""
    for H in リール フィード ストーリーズ ハッシュタグ戦略 指標の定義; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    for H in リール フィード ストーリーズ; do
      B=$(SEC "$F" "^## $H\$")
      for K in 役割 主指標 向いている型 選ぶ判断; do
        [ "$(echo "$B" | grep -cE "^- $K: .+")" -eq 1 ] || M="$M $H/$K;"
      done
    done
    B=$(SEC "$F" "^## ハッシュタグ戦略\$")
    [ "$(echo "$B" | grep -cE '^- .+')" -ge 5 ] || M="$M taglines;"
    for K in 大規模 中規模 小規模; do echo "$B" | grep -qF "$K" || M="$M tag:$K;"; done
    B=$(SEC "$F" "^## 指標の定義\$")
    for K in リーチ フォロワー外 いいね コメント 保存 シェア プロフィールへのアクセス; do
      [ "$(echo "$B" | grep -cE "^- $K: .+")" -eq 1 ] || M="$M kpi:$K;"
    done
    [ -z "$M" ] && echo "DW5 PASS" || echo "DW5 FAIL$M"
  - validations:
    - technical: "デコイ D10/D11/D12 の3種で FAIL を実測済み"
    - consistency: "p1.1〜p1.4 の判定を統合しており、同一の閾値を使っている"
    - completeness: "5セクション ＋ 12の使い分け行 ＋ ハッシュタグ3区分 ＋ 7指標を検証している"

- [ ] **p_final.6**: DW6 が満たされている（実績ログテンプレートが12列・データ行0件）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/my-posts-log.md; M=""
    [ "$(grep -c '^## 投稿実績ログ$' "$F")" -eq 1 ] || M="$M h2log;"
    B=$(SEC "$F" "^## 投稿実績ログ\$")
    N=$(echo "$B" | grep -c '^|'); [ "$N" -eq 2 ] || M="$M rows:$N(want2);"
    HDR=$(echo "$B" | grep '^|' | head -1)
    EXP='| 日付 | 投稿（要約） | フォーマット | 狙った型 | リーチ | フォロワー外% | いいね | コメント | 保存 | シェア | プロフアクセス | 気づき |'
    [ "$HDR" = "$EXP" ] || M="$M header;"
    [ "$(grep -c '^## 記入方法$' "$F")" -eq 1 ] || M="$M h2howto;"
    B2=$(SEC "$F" "^## 記入方法\$")
    [ "$(echo "$B2" | grep -cE '^- .+')" -ge 6 ] || M="$M howtolines;"
    for P in "ダミーデータ・例示行を入れない" "format-guide.md" "pattern-library.md"; do
      echo "$B2" | grep -qF -- "$P" || M="$M miss:$P;"
    done
    [ -z "$M" ] && echo "DW6 PASS" || echo "DW6 FAIL$M"
  - validations:
    - technical: "デコイ D13/D14 で FAIL を実測済み。データ行0件をちょうど2行で機械判定している"
    - consistency: "p3.1 と p3.2 の判定を統合しており、同一のヘッダ文字列を使っている"
    - completeness: "表の構造・ダミー行の不在・記入ルールの3点を検証している"

- [ ] **p_final.7**: DW7 が満たされている（既存台本スキル・threads-pdca の写経が0件）
  - executor: claudecode
  - test_command: |
    S=.claude/skills/instagram-pdca; M=""
    for P in "数字×悲劇" "行動×ネガティブ結果" "Gap Hook" "日常ブリッジの5つの入口パターン" "ブリッジ台本を書く" \
             "Threads 投稿 型ライブラリ" "A〜H の使い分け早見表" "コミュニティ勧誘特化型" "大義名分型コミュニティ立ち上げ"; do
      N=$(grep -rlF -- "$P" "$S" 2>/dev/null | wc -l | tr -d ' ')
      [ "$N" -eq 0 ] || M="$M dup:$P;"
    done
    [ -z "$M" ] && echo "DW7 PASS" || echo "DW7 FAIL$M"
  - validations:
    - technical: "デコイ D15/D25 で FAIL を実測済み（D25 = threads-pdca の pattern-library.md を全文追記）"
    - consistency: "既存2スキル・threads-pdca との二重管理を構造的に防いでおり、役割分担の宣言と実体が一致する"
    - completeness: "instagram-pdca 配下の全ファイルを再帰走査し、写経元の2方向を両方カバーしている。threads-pdca の SKILL.md 全文コピーは DW2 の `h2:{N}`（見出し重複）で別途検出される"

- [ ] **p_final.8**: DW8 が満たされている（回帰: 他スキル無変更＋allowlist 外の変更0件）
  - executor: claudecode
  - test_command: |
    BASE=ab66d3e; M=""
    { git -c core.quotepath=false diff --name-only "$BASE" HEAD
      git -c core.quotepath=false diff --name-only HEAD
      git -c core.quotepath=false ls-files --others --exclude-standard; } | sort -u > /tmp/ig_changeset.txt
    A=$(grep '^\.claude/skills/' /tmp/ig_changeset.txt | grep -vc '^\.claude/skills/instagram-pdca/')
    [ "$A" -eq 0 ] || M="$M otherskills:$A;"
    ALLOW='^\.claude/skills/instagram-pdca/|^plan/playbook-instagram-pdca-skill\.md$|^plan/playbook-video-editing-ffmpeg-skill\.md$|^state\.md$|^docs/repository-map\.yaml$|^\.claude/agents/critic\.md$|^plan/playbook-setup-instagram-skills\.md$|^tmp/'
    V=$(grep -vcE "$ALLOW" /tmp/ig_changeset.txt)
    [ "$V" -eq 0 ] || { M="$M outside:$V;"; grep -vE "$ALLOW" /tmp/ig_changeset.txt; }
    [ -z "$M" ] && echo "DW8 PASS" || echo "DW8 FAIL$M"
  - validations:
    - technical: "`core.quotepath=false` を付けないと非 ASCII パス（`tmp/AI×営業.html`）が8進エスケープされて allowlist に当たらず偽 FAIL になることを実測確認済み。本コマンドは現在の作業ツリーで PASS を実測済み"
    - consistency: "allowlist が I-5 と逐語一致している"
    - completeness: "追跡済み差分・作業ツリー差分・未追跡ファイルの3経路を全て集計している"

- [ ] **p_final.9**: DW9 が満たされている（3ファイル間の整合性 R1〜R3・R5）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    S=.claude/skills/instagram-pdca
    G=$S/references/format-guide.md; P=$S/references/pattern-library.md; M=""
    for ID in $(grep -h '^- 向いている型: ' "$G" | sed 's/^- 向いている型: //' | tr '/' ' '); do
      grep -q "^## $ID " "$P" || M="$M badid:$ID;"
    done
    for KPI in $(grep -h '^\*\*主指標\*\*: ' "$P" | sed 's/^\*\*主指標\*\*: //' | tr '/' ' '); do
      grep -qF -- "- $KPI: " "$G" || M="$M badkpi:$KPI;"
    done
    for T in "IG-R1 リール" "IG-R2 リール" "IG-R3 リール" "IG-F1 フィード" "IG-F2 フィード" \
             "IG-F3 フィード" "IG-F4 フィード" "IG-S1 ストーリーズ"; do
      ID=${T% *}; FMT=${T#* }
      SEC "$G" "^## $FMT\$" | grep '^- 向いている型: ' | grep -qF -- "$ID" || M="$M unlisted:$ID/$FMT;"
    done
    N=$(grep -rlE 'TBD|TODO|FIXME|後で書く' "$S" 2>/dev/null | wc -l | tr -d ' ')
    [ "$N" -eq 0 ] || M="$M placeholder:$N;"
    [ -z "$M" ] && echo "DW9 PASS" || echo "DW9 FAIL$M"
  - validations:
    - technical: "デコイ D19（実在しない型 ID）/ D20（format-guide に無い指標名）/ D22（型を誤ったフォーマット欄に配置）/ D26（構造行を全て `TBD` に置換）の4種で FAIL を実測済み"
    - consistency: "p2.6 と同一ロジックであり、Phase 判定と完了判定が乖離しない。R4（早見表のフォーマット列）は DW4 側で検証しており、DW9 と DW4 で I-9 の R1〜R5 を漏れなく分担している"
    - completeness: "型 ID は双方向（実在・網羅）、指標名は実在、プレースホルダは全ファイル再帰で検証している"

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

- [ ] **ft3**: 本タスクの成果物のみを**明示パス指定で** add し、**同じ pathspec を付けて** commit する
  - command: |
    git add .claude/skills/instagram-pdca plan/playbook-instagram-pdca-skill.md plan/playbook-video-editing-ffmpeg-skill.md state.md docs/repository-map.yaml
    git commit -m "feat(skills): add instagram-pdca skill" -- .claude/skills/instagram-pdca plan/playbook-instagram-pdca-skill.md plan/playbook-video-editing-ffmpeg-skill.md state.md docs/repository-map.yaml
  - note: |
    `.claude/agents/critic.md` / `plan/playbook-setup-instagram-skills.md` / `tmp/` 配下は
    本タスク開始前から存在する先行の未コミット差分。**絶対に add / commit しない。**
    `git add -A` および `git commit -a` は禁止。
  - status: pending

- [ ] **ft4**: コミット結果を allowlist で検証する（成果物**4ファイル全て**がコミットされ、許可外のファイルが1件も含まれない）
  - command: |
    git -c core.quotepath=false show --name-only --pretty=format: HEAD | sed '/^$/d' | sort -u > /tmp/ig_commit.txt
    M=""
    for P in '^\.claude/skills/instagram-pdca/SKILL\.md$' \
             '^\.claude/skills/instagram-pdca/references/format-guide\.md$' \
             '^\.claude/skills/instagram-pdca/references/pattern-library\.md$' \
             '^\.claude/skills/instagram-pdca/references/my-posts-log\.md$'; do
      grep -qE "$P" /tmp/ig_commit.txt || M="$M missing:$P;"
    done
    V=$(grep -vcE '^\.claude/skills/instagram-pdca/|^plan/playbook-instagram-pdca-skill\.md$|^plan/playbook-video-editing-ffmpeg-skill\.md$|^state\.md$|^docs/repository-map\.yaml$' /tmp/ig_commit.txt)
    [ "$V" -eq 0 ] || { M="$M outside:$V;"; grep -vE '^\.claude/skills/instagram-pdca/|^plan/playbook-instagram-pdca-skill\.md$|^plan/playbook-video-editing-ffmpeg-skill\.md$|^state\.md$|^docs/repository-map\.yaml$' /tmp/ig_commit.txt; }
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - note: |
    SKILL.md だけを見ると `references/` 3本がコミットに含まれていなくても PASS してしまうため、
    **成果物4ファイル全てのパス存在**を個別に検証する（レビュー指摘の是正）。
  - status: pending

---

## pm の自己点検記録（2026-08-15 / playbook 作成時に実測）

> **目的**: レビュー往復を減らすため、playbook 提出前に test_command が
> 「正しい成果物で PASS し、改悪された成果物で FAIL する」ことを実測で確認した。
>
> **検証方法**: 本 playbook の Markdown から `- test_command: |` ブロック **26個を機械的に逐語抽出**し、
> 期待成果物のモックに対して実行した（手で書き写したものではなく、この playbook のテキストそのものを実行している）。
>
> **改訂（2026-08-15 / reviewer 指摘の反映後に再実測）**: 下記の記録は
> reviewer レビュー（Major 4件・Minor 8件）の修正を反映した**現行テキスト**に対する再実測結果である。
> 反映内容の一覧は「5. reviewer 指摘への対応」を参照。

### 1. 正常系（モックに対する全 PASS）

期待成果物のモック（`SKILL.md` ＋ `references/format-guide.md` / `pattern-library.md` / `my-posts-log.md`）を
作成し、抽出した26ブロックを `bash` と `zsh` の両方で実行:

```
p1.1 / p1.2 / p1.3 / p1.4                          -> PASS
p2.1 / p2.2 / p2.3 / p2.4 / p2.5 / p2.6            -> PASS
p3.1 / p3.2                                         -> PASS
p4.1 / p4.2 / p4.3 / p4.4 / p4.5                   -> PASS
p_final.1〜7 -> DW1〜DW7 PASS
p_final.9    -> DW9 PASS
p_final.8    -> DW8 PASS（本リポジトリの実作業ツリーに対して実行）
=> 26ブロック × 2シェル = 52実行すべて PASS（ALL GREEN）
```

`final_tasks` の `ft4` も同様に逐語抽出し、コミット済みファイル一覧のモックに対して実行:

```
成果物4本 + playbook + state.md がコミット済み            -> PASS
references/ 3本がコミット漏れ                              -> FAIL missing:{3パス}
許可外ファイル（.claude/agents/critic.md）が混入          -> FAIL outside:1
```

### 2. 異常系（27種のデコイに対する FAIL 検出）

> モックに改悪を加えたコピーを作り、**本 playbook から抽出した p_final の test_command** で判定した。
> 「実測結果」列は実際の標準出力の逐語。

| # | 改悪内容 | 期待 | 実測結果 |
|---|---|---|---|
| D1 | description から起動フレーズ「ハッシュタグ考えて」を1個削除 | DW1 FAIL | `DW1 FAIL phrase:「ハッシュタグ考えて」;` |
| D2 | frontmatter の name を `instagram_pdca` に改名 | DW1 FAIL | `DW1 FAIL name;` |
| D3 | 断らせるチェックの手順を H3 → H2 に格上げして区間外へ逃がす | DW2 FAIL | `DW2 FAIL h3; order;` |
| D4 | WF2 の断らせるチェック導線ステップをダミー文に差し替え | DW2 FAIL | `DW2 FAIL wf2step;` |
| D5 | ペルソナ→10個 の順序を逆転 | DW2 FAIL | `DW2 FAIL order;` |
| D6 | 役割分担の委譲先パスを短縮表記 `instagram-bridge.md` に変更 | DW3 FAIL | `DW3 FAIL miss:.claude/skills/instagram-日常ブリッジ台本.md;` |
| D7 | IG-F1 のフォーマットを フィード → リール に改竄 | DW4 FAIL | `DW4 FAIL fmt:IG-F1;` |
| D8 | IG-F1 の構造行を3行→2行に削減 | DW4 FAIL | `DW4 FAIL lines:IG-F1;` |
| D9 | IG-S1 の型 ID を IG-S9 に改名 | DW4 FAIL | `DW4 FAIL h2:IG-S1;` |
| D10 | 指標の定義から「保存」の定義行を削除 | DW5 FAIL | `DW5 FAIL kpi:保存;` |
| D11 | フィード区間の `- 向いている型:` 行を削除 | DW5 FAIL | `DW5 FAIL フィード/向いている型;` |
| D12 | `## ハッシュタグ戦略` を `## ハッシュタグ` に改名 | DW5 FAIL | `DW5 FAIL h2:ハッシュタグ戦略; taglines; tag:大規模; tag:中規模; tag:小規模;` |
| D13 | 実績ログにダミーの例示行を1行追加 | DW6 FAIL | `DW6 FAIL rows:3(want2);` |
| D14 | 実績ログのヘッダから2列削除 | DW6 FAIL | `DW6 FAIL header;` |
| D15 | 既存スキルの型名「数字×悲劇（Gap Hook）」を型ライブラリに写経 | DW7 FAIL | `DW7 FAIL dup:数字×悲劇; dup:Gap Hook;` |
| D16 | WF3 の番号付きステップを削減し `references/` 参照を削除 | DW2 FAIL | `DW2 FAIL steps:3; ref:3;` |
| D17 | 早見表を**型 ID の無い別表**に差し替え（`|` 行10行は維持） | DW4 FAIL | `DW4 FAIL row:IG-R1(0); row:IG-R2(0); ...（8型分）` |
| D18 | 早見表の IG-F1 のフォーマット列を本文（フィード）と矛盾する `リール` に改竄 | DW4 FAIL | `DW4 FAIL rowfmt:IG-F1(リール);` |
| D19 | format-guide の `- 向いている型:` を実在しない `IG-F9` に改竄 | DW9 FAIL | `DW9 FAIL badid:IG-F9; unlisted:IG-F2/フィード;` |
| D20 | pattern-library の `**主指標**:` を format-guide に無い `エンゲージメント率` に改竄 | DW9 FAIL | `DW9 FAIL badkpi:エンゲージメント率;` |
| D21 | 意図的に除外した E型相当（IG-F5）を9型目として追加 | DW4 FAIL | `DW4 FAIL typecount:9(want8);` |
| D22 | IG-S1 を `## ストーリーズ` の `- 向いている型:` から外す | DW9 FAIL | `DW9 FAIL unlisted:IG-S1/ストーリーズ;` |
| D23 | **H3 の外側に「ペルソナ」を1語置き、H3 内の順序を逆転**（区間限定前は PASS していた回避） | DW2 FAIL | `DW2 FAIL order;` |
| D24 | WF1 の見出しを「週次の集計」に差し替え（WF1↔WF4 の入れ替え相当） | DW2 FAIL | `DW2 FAIL kw:1/分析;` |
| D25 | threads-pdca の `references/pattern-library.md` を**全文追記** | DW7 FAIL | `DW7 FAIL dup:Threads 投稿 型ライブラリ; dup:A〜H の使い分け早見表; dup:コミュニティ勧誘特化型; dup:大義名分型コミュニティ立ち上げ;` |
| D26 | 全ての `【n】` 構造行を `TBD` に置換（体裁だけ整えて中身を空にする） | DW9 FAIL | `DW9 FAIL placeholder:1;` |
| D27 | `description` を YAML folded 記法（`description: >`）で3行に折り返す | DW1 FAIL | `DW1 FAIL phrase:{6個すべて};` |

**27/27 で期待どおり FAIL を検出**（見逃し0件）。
補足: threads-pdca の `SKILL.md` を全文追記した場合は `## ワークフロー{N}` が重複するため
`DW2 FAIL h2:1; h2:2; h2:3; h2:4;` で検出される（実測済み）。

### 3. 環境依存の落とし穴（実測で発見・規約に反映済み）

- `git diff --name-only` は非 ASCII パスを `"tmp/AI\303\227\345\226\266\346\245\255.html"` と
  8進エスケープ＋クォート付きで出力するため、`^tmp/` の照合が黙って外れる
  → 全 git コマンドに `-c core.quotepath=false` を必須化した。
- `G="git -c core.quotepath=false"; $G diff` は zsh が単語分割せず `command not found` になる
  → 変数をコマンド名として展開しない規約を明記した。
- 型 ID の見出しからドットを排除（`## IG-R1 フック型リール`）することで、
  macOS awk の `-v` におけるバックスラッシュ脱落問題を構造的に回避した。

### 4. 残る未検証事項（構造上、機械検証できないもの）

- 型の**内容の質**（8型の骨格が Instagram で実際に機能するか）は機械検証できない。
  I-2 で出典を repo 内資産に限定し創作を禁じること、および DW9 の R5（プレースホルダ禁止）で
  「体裁だけ整えて中身を空にする」逃げ道を塞ぐことで、可能な範囲を担保している。
  **本質的な質の判断は critic / ユーザーの目視に委ねる。**
- 実アカウント（@okkun_lifestyle）の Instagram 実績データは本 playbook のスコープ外。
  `my-posts-log.md` は空テンプレートとして作り、実データはスキル完成後にワークフロー3で蓄積する。
- p1〜p4 の subtask test_command は p_final の DW 判定のサブセットであり、
  同一ロジックを2箇所に書いている。乖離しないよう閾値を揃えてあるが、
  片方だけ修正されるリスクは残る。

### 5. reviewer 指摘への対応（2026-08-15 / FAIL: Major 4 + Minor 8）

> reviewer から「修正後は再レビュー不要と判断できる程度に軽微。以下6点の反映確認をもって
> `reviewed: true` としてよい」との判断を得た。以下は反映内容と、その反映を裏付ける実測。

| 指摘 | 内容 | 反映箇所 | 反映を裏付けるデコイ |
|---|---|---|---|
| Major-1 | ペルソナ→10個 の順序判定が WF2 区間全体を見ており、H3 の外に「ペルソナ」を置けば回避できた | p4.3 / p_final.2 の `B3`（H3 区間を `^#{1,3} ` で切り出し）、DW2 本文 | D23 |
| Major-2 | 完了ゲート p_final.4 が早見表を `|` 行数10行でしか見ておらず、型 ID の無い別表に差し替えても PASS した | p2.5 / p_final.4 に `row:{ID}`（ちょうど1行）と `rowfmt:{ID}`（3列目＝本文一致）を追加、DW4 本文を強化、I-2 に列順規約を追加 | D17 / D18 / D18b |
| Major-3 | 3ファイル間の整合性が散文の validations だけで機械検証されていなかった | I-9（R1〜R5）を新設、p2.6 / p_final.9（DW9）を新設 | D19 / D20 / D22 |
| Major-4 | DW7 が台本スキル2本のみ対象で threads-pdca からの写経を素通しし、除外したはずの E型 を足しても検出できなかった | I-7 に threads-pdca 固有の4文字列を追加（p4.5 / p_final.7 / DW7）、p2.1 / p_final.4 に `typecount`（ちょうど8本）を追加 | D25 / D21 |
| Minor-3 | `description` を YAML folded 記法で書くと DW1 が全滅する | I-1 に「1行で書く。`>` / `|` 記法を使わない」を明記 | D27 |
| Minor-4 | `ft4` が SKILL.md しか見ておらず、`references/` 3本のコミット漏れを検出できなかった | ft4 に成果物4ファイルのパス存在チェックを追加 | ft4 の異常系2種 |
| Minor-1 | 型の中身を `TBD` に置換しても PASS した | DW9 の R5（`TBD` / `TODO` / `FIXME` / `後で書く` が0件） | D26 |
| Minor-2 | WF1 と WF4 の見出しを入れ替えても PASS した | I-8（見出しの必須キーワード規約）、p4.2 / p_final.2 の `kw:` 判定 | D24 |
| Minor-5 | state.md の done_criteria と playbook の done_when が逐語一致していなかった | state.md の done_criteria を DW1〜DW9 の**逐語コピー**に更新 | — |
| Minor-6 | state.md の focus / session が陳腐化していた | `focus.current` を `thanks4claudecode` に、`session.last_start` を更新 | — |
| Minor-7/8 | 既存資産の完全重複（単体ファイル ≡ 別スキルの SKILL.md）への言及が無かった | I-6 に「既知の重複」表を追加（`diff` 差分0を実測済み）。統廃合はスコープ外と明記 | — |

**回帰確認**: 修正で書き換えた `p_final.2` / `p_final.4` / `p_final.7` について、
旧デコイ D3 / D4 / D5 / D16 / D7 / D8 / D9 / D15 を再実行し、**全て引き続き FAIL を検出**することを確認した
（強化はしたが、既存の検出力を落としていない）。

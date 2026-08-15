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
reviewed: false
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
  - "DW2: SKILL.md に `## ワークフロー1`〜`## ワークフロー4` の H2 が各1本ずつ存在し、各区間内に『発火フレーズ』を含む行が1行以上・行頭が `{数字}. ` の番号付きステップが3行以上・`references/` を含む行が1行以上存在する。さらに ワークフロー2 区間の番号付きステップ行に『断らせる』が、ワークフロー4 区間の番号付きステップ行に『原因分析』が含まれ、ワークフロー2 区間内に H3 `### 断らせるチェックの手順` が存在し、その区間内で『ペルソナ』の初出行が『**10個**』の初出行より前にある"
  - "DW3: SKILL.md に `## 既存スキルとの役割分担` の H2 が1本存在し、その区間内に `.claude/skills/instagram-フック型ショート台本.md` / `.claude/skills/instagram-日常ブリッジ台本.md` / `.claude/skills/threads-pdca/` / `instagram-pdca` の4文字列が全て逐語で含まれ、『委譲』を含む行が1行以上あり、`|` で始まる表の行が6行以上ある"
  - "DW4: references/pattern-library.md に inputs I-2 の8型の H2（`## IG-R1 `〜`## IG-S1 `）が各1本ずつ存在し、各型区間に `**フォーマット**: {リール|フィード|ストーリーズ}` が I-2 で定めた値と逐語一致で存在し、`**出典**: ` / `**主指標**: ` の行が各1行・`### 型の構造` / `### 効く理由` の H3 が各1本・行頭が `【` の構造行が3行以上存在する。加えて IG-R1 区間に `instagram-フック型ショート台本.md`、IG-R2 区間に `instagram-日常ブリッジ台本.md` が含まれ、`## 使い分け早見表` 区間の `|` 行が10行以上ある"
  - "DW5: references/format-guide.md に `## リール` / `## フィード` / `## ストーリーズ` / `## ハッシュタグ戦略` / `## 指標の定義` の H2 が各1本ずつ存在し、前3者の各区間に `- 役割: ` `- 主指標: ` `- 向いている型: ` `- 選ぶ判断: ` で始まり内容が続く行が各1行ずつ存在し、ハッシュタグ戦略区間に行頭 `- ` の行が5行以上かつ『大規模』『中規模』『小規模』が逐語で含まれ、指標の定義区間に inputs I-3 の7指標の定義行（`- {指標}: {内容}`）が各1行ずつ存在する"
  - "DW6: references/my-posts-log.md の `## 投稿実績ログ` 区間で `|` で始まる行がちょうど2行（ヘッダ＋区切りのみ＝データ行0件）であり、ヘッダ行が inputs I-4 の12列ヘッダと文字列完全一致する。さらに `## 記入方法` の H2 が存在し、その区間に行頭 `- ` の行が6行以上あり、『ダミーデータ・例示行を入れない』と `format-guide.md` と `pattern-library.md` が逐語で含まれる"
  - "DW7: 非重複: `.claude/skills/instagram-pdca/` 配下の全ファイルにおいて、既存の instagram 台本スキル2本に固有の文字列（`数字×悲劇` / `行動×ネガティブ結果` / `Gap Hook` / `日常ブリッジの5つの入口パターン` / `ブリッジ台本を書く`）を含むファイルが0件である（＝既存スキルの写経による二重管理が発生していない）"
  - "DW8: 回帰: base_commit ab66d3e からの追跡済み差分・作業ツリー差分・未追跡ファイルを合わせた全変更ファイル集合において、(a) `.claude/skills/` 配下で `.claude/skills/instagram-pdca/` 以外のファイルが0件であり、(b) inputs I-5 の allowlist に該当しないファイルが0件である"
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

### I-7. 非重複の禁止文字列（`.claude/skills/instagram-pdca/` 配下に出現してはならない）

```
数字×悲劇
行動×ネガティブ結果
Gap Hook
日常ブリッジの5つの入口パターン
ブリッジ台本を書く
```

> いずれも既存の instagram 台本スキル2本に固有の見出し・型名。
> 参照したい場合はファイルパスへのポインタで示し、内容を写経しないこと。

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

- [ ] **p2.1**: `references/pattern-library.md` に I-2 の8型の H2（`## IG-R1 `〜`## IG-S1 `）が各1本ずつ存在する
  - executor: claudecode
  - test_command: |
    F=.claude/skills/instagram-pdca/references/pattern-library.md; M=""
    test -f "$F" || M="$M nofile;"
    for ID in IG-R1 IG-R2 IG-R3 IG-F1 IG-F2 IG-F3 IG-F4 IG-S1; do
      [ "$(grep -c "^## $ID " "$F")" -eq 1 ] || M="$M h2:$ID;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "8型の H2 が重複なく各1本ずつ検出できる（ID を改名すると FAIL することをデコイ D9 で実測済み）"
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

- [ ] **p2.5**: `## 使い分け早見表` の H2 が1本存在し、その区間の `|` で始まる行が10行以上ある（ヘッダ＋区切り＋8型）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/references/pattern-library.md; M=""
    [ "$(grep -c '^## 使い分け早見表$' "$F")" -eq 1 ] || M="$M h2;"
    B=$(SEC "$F" "^## 使い分け早見表\$")
    [ "$(echo "$B" | grep -c '^|')" -ge 10 ] || M="$M rows;"
    for ID in IG-R1 IG-R2 IG-R3 IG-F1 IG-F2 IG-F3 IG-F4 IG-S1; do
      echo "$B" | grep -qF "| $ID |" || M="$M row:$ID;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "表の行数と8型 ID の逐語存在を同時に検証している"
    - consistency: "早見表の型 ID・フォーマット・出典が本文の各型セクション（p2.2）と矛盾しない"
    - completeness: "8型全てが早見表に載っており、本文にあって表に無い型が存在しない"

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

- [ ] **p4.2**: `## ワークフロー1`〜`## ワークフロー4` の H2 が各1本ずつ存在し、各区間内に『発火フレーズ』を含む行が1行以上・番号付きステップが3行以上・`references/` を含む行が1行以上存在する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    for W in 1 2 3 4; do
      [ "$(grep -c "^## ワークフロー$W" "$F")" -eq 1 ] || { M="$M h2:$W;"; continue; }
      B=$(SEC "$F" "^## ワークフロー$W")
      [ "$(echo "$B" | grep -cF '発火フレーズ')" -ge 1 ] || M="$M trigger:$W;"
      [ "$(echo "$B" | grep -cE '^[0-9]+[.] ')" -ge 3 ] || M="$M steps:$W;"
      [ "$(echo "$B" | grep -cF 'references/')" -ge 1 ] || M="$M ref:$W;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "ステップを2個に減らす／references 参照を消すと FAIL する（デコイ D16 で実測済み）"
    - consistency: "4ワークフローの並びと役割が threads-pdca の SKILL.md（分析→Plan→Check→Act）と対応している"
    - completeness: "全ワークフローが手順・発火フレーズ・参照ファイルの3点を備えている"

- [ ] **p4.3**: 断らせるチェックの導線が構造として成立している（WF2 の番号付きステップ行に『断らせる』、WF4 の番号付きステップ行に『原因分析』、WF2 区間内に H3 `### 断らせるチェックの手順` が存在し、その区間で『ペルソナ』の初出が『**10個**』の初出より前）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/instagram-pdca/SKILL.md; M=""
    SEC "$F" "^## ワークフロー2" | grep -E '^[0-9]+[.] ' | grep -qF '断らせる' || M="$M wf2step;"
    SEC "$F" "^## ワークフロー4" | grep -E '^[0-9]+[.] ' | grep -qF '原因分析' || M="$M wf4step;"
    B=$(SEC "$F" "^## ワークフロー2")
    echo "$B" | grep -q '^### 断らせるチェックの手順' || M="$M h3;"
    PN=$(echo "$B" | grep -nF 'ペルソナ' | head -1 | cut -d: -f1)
    TN=$(echo "$B" | grep -nF '**10個**' | head -1 | cut -d: -f1)
    { [ -n "$PN" ] && [ -n "$TN" ] && [ "$PN" -lt "$TN" ]; } || M="$M order;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "H3 を H2 に格上げして区間外へ逃がす／導線ステップをダミーに差し替える／ペルソナと10個の順序を逆転させる の3改悪で FAIL する（デコイ D3/D4/D5 で実測済み）"
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

- [ ] **p4.5**: `.claude/skills/instagram-pdca/` 配下に I-7 の禁止文字列5個を含むファイルが0件である（既存スキルの写経が無い）
  - executor: claudecode
  - test_command: |
    S=.claude/skills/instagram-pdca; M=""
    for P in "数字×悲劇" "行動×ネガティブ結果" "Gap Hook" "日常ブリッジの5つの入口パターン" "ブリッジ台本を書く"; do
      N=$(grep -rlF -- "$P" "$S" 2>/dev/null | wc -l | tr -d ' ')
      [ "$N" -eq 0 ] || M="$M dup:$P;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "既存スキル固有の型名を1つでも書き写すと FAIL する（デコイ D15 で実測済み）"
    - consistency: "役割分担（p4.4）で宣言した『台本は書かない』が実ファイルの中身でも守られている"
    - completeness: "SKILL.md と references/ 3本の全ファイルを再帰的に走査している"

**status**: pending
**max_iterations**: 5
**time_limit**: 45min
**priority**: high

---

### p_final: 完了検証（必須）

> **playbook の done_when（DW1〜DW8）が実際に満たされているか最終検証する。**
> **DW1〜DW7 は下記の一括スクリプトを一度実行し、その出力行を各 subtask の証拠として引用してよい。**

```bash
# p_final 一括実行スクリプト（リポジトリルートで実行）
S=".claude/skills/instagram-pdca"
SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
# 各 subtask の test_command を DW1..DW7 の順に実行し、"DWn PASS" / "DWn FAIL{理由}" を出力する
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
    for W in 1 2 3 4; do
      [ "$(grep -c "^## ワークフロー$W" "$F")" -eq 1 ] || { M="$M h2:$W;"; continue; }
      B=$(SEC "$F" "^## ワークフロー$W")
      [ "$(echo "$B" | grep -cF '発火フレーズ')" -ge 1 ] || M="$M trigger:$W;"
      [ "$(echo "$B" | grep -cE '^[0-9]+[.] ')" -ge 3 ] || M="$M steps:$W;"
      [ "$(echo "$B" | grep -cF 'references/')" -ge 1 ] || M="$M ref:$W;"
    done
    SEC "$F" "^## ワークフロー2" | grep -E '^[0-9]+[.] ' | grep -qF '断らせる' || M="$M wf2step;"
    SEC "$F" "^## ワークフロー4" | grep -E '^[0-9]+[.] ' | grep -qF '原因分析' || M="$M wf4step;"
    B=$(SEC "$F" "^## ワークフロー2")
    echo "$B" | grep -q '^### 断らせるチェックの手順' || M="$M h3;"
    PN=$(echo "$B" | grep -nF 'ペルソナ' | head -1 | cut -d: -f1)
    TN=$(echo "$B" | grep -nF '**10個**' | head -1 | cut -d: -f1)
    { [ -n "$PN" ] && [ -n "$TN" ] && [ "$PN" -lt "$TN" ]; } || M="$M order;"
    [ -z "$M" ] && echo "DW2 PASS" || echo "DW2 FAIL$M"
  - validations:
    - technical: "デコイ D3/D4/D5/D16 の4種で FAIL を実測済み"
    - consistency: "p4.2 と p4.3 の判定を統合しており、両者と同一の閾値を使っている"
    - completeness: "4ワークフロー × 3要素 ＋ 断らせる導線4点を検証している"

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
    done
    SEC "$F" "^## IG-R1 " | grep -qF 'instagram-フック型ショート台本.md' || M="$M delegR1;"
    SEC "$F" "^## IG-R2 " | grep -qF 'instagram-日常ブリッジ台本.md' || M="$M delegR2;"
    [ "$(SEC "$F" "^## 使い分け早見表\$" | grep -c '^|')" -ge 10 ] || M="$M table;"
    [ -z "$M" ] && echo "DW4 PASS" || echo "DW4 FAIL$M"
  - validations:
    - technical: "デコイ D7/D8/D9 の3種で FAIL を実測済み"
    - consistency: "p2.1〜p2.5 の判定を統合しており、同一の閾値を使っている"
    - completeness: "8型 × 6要素 ＋ 委譲先2件 ＋ 早見表を検証している"

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

- [ ] **p_final.7**: DW7 が満たされている（既存台本スキルの写経が0件）
  - executor: claudecode
  - test_command: |
    S=.claude/skills/instagram-pdca; M=""
    for P in "数字×悲劇" "行動×ネガティブ結果" "Gap Hook" "日常ブリッジの5つの入口パターン" "ブリッジ台本を書く"; do
      N=$(grep -rlF -- "$P" "$S" 2>/dev/null | wc -l | tr -d ' ')
      [ "$N" -eq 0 ] || M="$M dup:$P;"
    done
    [ -z "$M" ] && echo "DW7 PASS" || echo "DW7 FAIL$M"
  - validations:
    - technical: "デコイ D15 で FAIL を実測済み"
    - consistency: "既存2スキルとの二重管理を構造的に防いでおり、役割分担の宣言と実体が一致する"
    - completeness: "instagram-pdca 配下の全ファイルを再帰走査している"

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

- [ ] **ft4**: コミット結果を allowlist で検証する（成果物がコミットされ、許可外のファイルが1件も含まれない）
  - command: |
    git -c core.quotepath=false show --name-only --pretty=format: HEAD | sed '/^$/d' | sort -u > /tmp/ig_commit.txt
    grep -q '^\.claude/skills/instagram-pdca/SKILL\.md$' /tmp/ig_commit.txt && \
    [ "$(grep -vcE '^\.claude/skills/instagram-pdca/|^plan/playbook-instagram-pdca-skill\.md$|^plan/playbook-video-editing-ffmpeg-skill\.md$|^state\.md$|^docs/repository-map\.yaml$' /tmp/ig_commit.txt)" -eq 0 ] && echo PASS || echo FAIL
  - status: pending

---

## pm の自己点検記録（2026-08-15 / playbook 作成時に実測）

> **目的**: レビュー往復を減らすため、playbook 提出前に test_command が
> 「正しい成果物で PASS し、改悪された成果物で FAIL する」ことを実測で確認した。
>
> **検証方法**: 本 playbook の Markdown から `- test_command: |` ブロック **24個を機械的に逐語抽出**し、
> 期待成果物のモックに対して実行した（手で書き写したものではなく、この playbook のテキストそのものを実行している）。

### 1. 正常系（モックに対する全 PASS）

期待成果物のモック（`SKILL.md` ＋ `references/format-guide.md` / `pattern-library.md` / `my-posts-log.md`）を
作成し、抽出した24ブロックを `bash` と `zsh` の両方で実行:

```
p1.1 / p1.2 / p1.3 / p1.4                     -> PASS
p2.1 / p2.2 / p2.3 / p2.4 / p2.5              -> PASS
p3.1 / p3.2                                    -> PASS
p4.1 / p4.2 / p4.3 / p4.4 / p4.5              -> PASS
p_final.1〜7 -> DW1〜DW7 PASS
p_final.8    -> DW8 PASS（本リポジトリの実作業ツリーに対して実行）
=> 24ブロック × 2シェル = 48実行すべて PASS（ALL GREEN）
```

### 2. 異常系（16種のデコイに対する FAIL 検出）

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
| D16 | WF3 の番号付きステップを削減し `references/` 参照を削除 | DW2 FAIL | `DW2 FAIL ref:3;` |

**16/16 で期待どおり FAIL を検出**（見逃し0件）。

### 3. 環境依存の落とし穴（実測で発見・規約に反映済み）

- `git diff --name-only` は非 ASCII パスを `"tmp/AI\303\227\345\226\266\346\245\255.html"` と
  8進エスケープ＋クォート付きで出力するため、`^tmp/` の照合が黙って外れる
  → 全 git コマンドに `-c core.quotepath=false` を必須化した。
- `G="git -c core.quotepath=false"; $G diff` は zsh が単語分割せず `command not found` になる
  → 変数をコマンド名として展開しない規約を明記した。
- 型 ID の見出しからドットを排除（`## IG-R1 フック型リール`）することで、
  macOS awk の `-v` におけるバックスラッシュ脱落問題を構造的に回避した。

### 4. 未検証事項（reviewer に見てほしい点）

- 型の**内容の質**（8型の骨格が Instagram で実際に機能するか）は機械検証できない。
  I-2 で出典を repo 内資産に限定し、創作を禁じることで担保している。
- 実アカウント（@okkun_lifestyle）の Instagram 実績データは本 playbook のスコープ外。
  `my-posts-log.md` は空テンプレートとして作り、実データはスキル完成後にワークフロー3で蓄積する。
- p1〜p4 の subtask test_command は p_final の DW 判定のサブセットであり、
  同一ロジックを2箇所に書いている。乖離しないよう閾値を揃えてあるが、
  片方だけ修正されるリスクは残る。

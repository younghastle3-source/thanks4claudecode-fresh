# playbook-part111-integration.md

> **CJ Advance Part111「現場で多い3大トラブルの改善方法」の内容を、
> 既存スキル `.claude/skills/shoulder-pain-rehabilitation/SKILL.md`（Part123 由来・87行）に統合する。
> 新規スキルは作らない。既存1ファイルの非破壊拡張＋索引1行の追加のみ。**

---

## 実行前提と検証規約

> **本セクションの規約は全 test_command に適用される。**

- **CWD**: 全 test_command はリポジトリルート（`/Users/kosei/thanks4claudecode-fresh`）を
  カレントディレクトリとして実行する。相対パスは全てリポジトリルート起点。
- **シェル**: `bash` / `zsh` のどちらでも同じ結果になるよう記述する
  （本 playbook の全 test_command は両方で実測済み。「pm の自己点検記録」参照）。
- **ネットワーク**: DW9 の「講義一覧86件」回帰検証のみ `gh api` を使う（`gh auth status` が通ること）。
  それ以外の DW は全てローカルで完結する。
- **参照先の固定**: training リポジトリは毎週更新されるため、
  **commit SHA `8164d0d992ed88d275498ccd56779f6eeb719375`（直前タスクと同一の pin）に固定**して検証する。
  Part111 の実ファイルはこの SHA に `636306` バイトで実在することを実測確認済み（I-1）。
- **base_commit の固定**: 非破壊検証（DW1）と回帰検証（DW10）は
  **`d407efe`（main の HEAD、かつ現ブランチの HEAD）を起点**にする。
  Phase 途中でコミットしても判定がぶれない。
- **区間抽出**: セクション内容の検証は必ず以下のヘルパで見出し区間を切り出してから行う。

  ```bash
  SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
  ```

  終端を `^#{1,2} ` にしているのは H1 でも区間を閉じるため。`### ` では閉じない。
  **`---`（水平線）でも閉じない**ため、統合先ファイルの既存 `---` 区切りは区間に含まれる。
  実体行のカウントは必ず `^- ` / `^{数字}. ` / `^|` のいずれかに限定すること
  （`---` を実体行として数えないため。既存 `## いつ使うか` 区間は非空行2行だがうち1行は `---` である、と実測済み）。
- **Unicode 正規化**: 索引のパス列と GitHub API が返すパスの照合は必ず以下の `NFC` ヘルパを通す
  （`【Part100】ボディメイクvs機能改善.md` が NFC / NFD の2エントリとして tree に存在するため）。

  ```bash
  NFC() { python3 -c "import sys,unicodedata;print('\n'.join(sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})))"; }
  ```

  なお `【Part111】現場で多い3大トラブルの改善方法.md` は **tree 上で NFC 正規形と一致**する
  （`unicodedata.normalize('NFC', path) == path` が True。実測済み）ので、
  出典パスの逐語照合は NFC 正規化なしでも通る。
- **日本語・記号を含む固定文字列の照合は必ず `grep -qF` / `grep -cF`**（正規表現メタ誤爆の防止）。
- **git のパスは常に `git -c core.quotepath=false`**。これを付けないと非 ASCII を含むパス
  （`.claude/skills/クロニクルジャパンcj-advance/...`, `tmp/AI×営業.html`）が8進エスケープ＋
  ダブルクォート付きで出力され、パス照合が黙って失敗する。
- **非 ASCII を含むパスは必ずダブルクォートで囲む**。
- **変数をコマンド名として展開しない**（`G="git -c ..."; $G diff` は zsh が単語分割せず失敗する）。
- **`gh api` の URL は必ずクォートする**（`?recursive=1` の `?` が zsh のグロブに食われる）。
- **`grep -vc` を空入力に対して実行しない**（空文字列が1行として数えられ偽 FAIL になる）。
  本 playbook では該当箇所を全て `if [ -z "$X" ]` でガードしている。

---

## meta

```yaml
project: thanks4claudecode
branch: feat/cj-advance-skill-expansion  # 新規に切らず、直前タスクのブランチをそのまま使う（下記の注意を必ず読むこと）
base_commit: d407efe  # 現ブランチの HEAD かつ main の HEAD。DW1（非破壊）/ DW10（回帰）の比較元として固定
created: 2026-08-25
issue: null
derives_from: null  # ユーザー資産（スキル）の整備であり project.done_when に対応なし
reviewed: false  # reviewer 未レビュー。pm 作成直後の状態
roles:
  worker: claudecode  # toolstack A（state.md config.roles と一致）
source_repo:
  name: younghastle3-source/training
  pinned_sha: 8164d0d992ed88d275498ccd56779f6eeb719375
```

> **ブランチに関する判断（実行前に必ず読むこと）**
>
> **新しいブランチを切らず、`feat/cj-advance-skill-expansion` で続行する。**
>
> 理由: 直前タスク（playbook-cj-advance-skill-expansion）の成果物
> （`.claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md` /
> `personal-session-communication/` / `skeletal-exercise-selection/` /
> `plan/playbook-cj-advance-skill-expansion.md`）が**まだ未コミットで作業ツリーに乗っている**
> （`git status --porcelain` で `?? ` として実測確認済み、2026-08-25）。
> ここで新ブランチを切ると、直前タスクの差分がそのまま持ち越されて本タスクの差分と混ざり、
> どちらのブランチの成果物か判別できなくなる。
>
> さらに本タスクは**直前タスクが作った `lecture-index.md` を編集する**ため、
> 直前タスクの成果物が同じブランチ上にあることが前提条件でもある。
>
> ```bash
> git branch --show-current   # => feat/cj-advance-skill-expansion であることを確認するだけ。checkout -b はしない
> ```
>
> 加えて、タスク開始前から浮いている**先行の未コミット差分15件**（I-9 の PRE）が存在する。
> **これらは本タスクの成果物ではないため、絶対にコミットしてはならない**
> （`git add -A` / `git commit -a` は禁止。final_tasks ft3 参照）。

---

## goal

```yaml
summary: >
  Part111（現場で多い3大トラブル）の3症例——右肩前方の痛み（上腕二頭筋長頭腱）/ 右僧帽筋の過度な張り /
  左の腰痛——を、既存の shoulder-pain-rehabilitation スキルに5つの H2 として追記し、
  「痛い場所に原因があるとは限らない・対角線と拮抗筋を見る」という評価原理を明示する。
  既存の Part123 由来の記述は1行も削除・改変しない（git diff --numstat の削除0行で機械検証）。
  ディレクトリ名の改名はしない（参照が壊れるため）。代わりに `## いつ使うか` を肩以外にも広げる。
  索引 lecture-index.md の `## スキル化済みの講義` に Part111 の1行を追加し、
  `## 講義一覧` の86件という不変条件を壊さないことを回帰検証する。
done_when:
  - "DW1: `.claude/skills/shoulder-pain-rehabilitation/SKILL.md` について、base_commit d407efe 時点の**全非空行が逐語で残存**し、`git diff --numstat d407efe` の**削除が0行**・追加が**50行以上**であり、既存 H2 7本（`参照リポジトリ（GitHub・おっくん自身のナレッジ）` / `いつ使うか` / `評価ステップ（ヒアリング〜触診）` / `改善アプローチ：相反抑制の活用` / `よくあるNG` / `重要な気づき` / `出典`）が各1本ずつ残っている"
  - "DW2: 同ファイルの H2 が**ちょうど12本**であり、新規5 H2（`現場で多い3大トラブル（Part111）` / `トラブル①：肩前方の痛み（上腕二頭筋長頭腱の炎症）` / `トラブル②：僧帽筋の過度な張り` / `トラブル③：左の腰痛（前屈・運搬時）` / `評価の原理：対角線と拮抗筋を見る`）が各1本ずつ存在し、その各区間に実体行（`- ` / `{数字}. ` / `|` 始まり）が3行以上あり、ファイル全体に I-8 の必須新規キーワード11個が全て逐語で含まれる"
  - "DW3: `## トラブル①：肩前方の痛み（上腕二頭筋長頭腱の炎症）` 区間に `上腕二頭筋長頭腱` / `肩峰` / `内旋` / `インピンジメント` / `小円筋` / `三角筋後部` / `外旋` / `リリース` が全て含まれ、`肩峰` と（`ぶつ` または `挟`）を同時に含む行が1行以上あり（＝挟み込みの機序が書かれている）、実体行が4行以上ある"
  - "DW4: `## トラブル②：僧帽筋の過度な張り` 区間について、(a) `腰方形筋` / `広背筋` / `引き伸ば` / `過緊張` / `アライメント` / `リリース` が全て含まれ、(b) `縮` を含む行のうち1行以上が `ではな` / `逆` / `わけではな` のいずれかを含み（＝『縮んで固まっているのではない』が明示されている）、(c) `引き伸ば` を含む行が `僧帽筋` または `耐え` を含み、(d) `マッサージ` を含む行が1行以上存在し、**その全行**が `ではな` / `しない` / `逆` / `禁` のいずれかを含む（＝僧帽筋を揉むのが正解だと読める記述が1行も無い）"
  - "DW5: `## トラブル③：左の腰痛（前屈・運搬時）` 区間について、(a) `腸腰筋` / `内腹斜筋` / `脊柱起立筋` / `代償` / `仰向け` / `股関節` が全て含まれ、(b) `左`→`腰`→`右`→`股関節` または `右`→`股関節`→`左`→`腰` の順で4語を同時に含む行が1行以上あり（＝左右の交差が1文で明示されている）、(c) `腸腰筋` を含む行が1行以上存在し**その全行が `右` を含み**、(d) `左の股関節` / `左の腸腰筋` / `左側の腸腰筋` が区間内に0件である"
  - "DW6: `## 評価の原理：対角線と拮抗筋を見る` 区間に `痛い場所に原因があるとは限らない` / `対角線` / `拮抗筋` が全て逐語で含まれ、行頭 `- ` の行が3行以上あり、そのうち (a) `肩` と `外旋` を同時に含む行、(b) `僧帽筋` と（`腰方形筋` または `広背筋`）を同時に含む行、(c) `左`→`腰`→`右`→`股関節` の順で4語を含む行、の3種が全て存在する"
  - "DW7: `## いつ使うか` 区間に `僧帽筋` / `腰痛` / `肩` が全て含まれ、行頭 `- ` の行が3行以上あり、かつ base 時点の本文（`外転（横に上げる）時にコリッという引っ掛かり感` を含む段落）が逐語で残存している（＝肩以外に適用範囲を広げつつ既存記述を消していない）"
  - "DW8: `## 出典` 区間に (a) `cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md`、(b) `github.com/younghastle3-source/training`、(c) `https://www.youtube.com/watch?v=8sadHyESZAA`、(d) 既存の `Part123「肩外転時の痛みに対する改善方法」(2026-07-17) - シジアドバンス` が全て逐語で含まれ、行頭 `- ` の行が2行以上ある"
  - "DW9: 索引 `.claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md` の `## スキル化済みの講義` 区間の `|` 始まりの行が**ちょうど7行**（ヘッダ＋区切り＋データ5行）であり、Part111 / Part122 / Part123 / Part126 / Part128 の5行が各1行ずつ存在し各行のスキルディレクトリが `test -d` で実在し、かつ**回帰**として `## 講義一覧` のパス列（第5フィールドが `cj advance/` 始まり）の**生の行数がちょうど86行**（重複排除前）であり、かつ NFC 正規化後の集合が pinned tree の実データ（NFC 正規化・重複排除後86件）と `diff` で完全一致する"
  - "DW10: (a) `.claude/skills/shoulder-pain-rehabilitation/` 配下に I-8 の禁止文字列10個を含むファイルが0件、(b) `SKILL.md` の行数が137行以上260行以下（＝実体が入っており、かつ文字起こしの丸写しになっていない）、(c) base_commit d407efe からの追跡済み差分・作業ツリー差分・未追跡ファイルを合わせた全変更ファイル集合において I-9 の allowlist に該当しないファイルが0件、かつ `.claude/skills/` 配下で許可6ディレクトリ以外のファイルが0件"
```

---

## inputs（合意済み素材 / worker の唯一の正典）

> **本セクションが worker の参照すべき唯一の正典（source of truth）である。**
> **講義の中身は必ず `gh api` で実ファイルを読んでから書くこと。記憶や一般論で埋めてはならない。**

### I-1. 出典ファイルと取得手順

```yaml
リポジトリ: github.com/younghastle3-source/training
パス: cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md
pinned_sha: 8164d0d992ed88d275498ccd56779f6eeb719375
サイズ: 636306 バイト（実測）
正規化: tree 上のパスは NFC 正規形と一致（実測 True）。NFD 重複は無い
YouTube 原文: https://www.youtube.com/watch?v=8sadHyESZAA
```

> **サイズに騙されないこと。** 636KB のうち大半は base64 埋め込み画像であり、
> **本文の実体は H3 が4本のみ**（トラブル①②③＋まとめ）。実測で
> 生ファイル97行 → 画像参照を除去して91行、うち**要約本文は先頭65行**、
> それ以降は YouTube 原文の文字起こし（`以下原文` 以降）である。

**執筆前に必ず実行する取得コマンド（画像除去つき）**

```bash
TREE=8164d0d992ed88d275498ccd56779f6eeb719375
P="cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md"
gh api "repos/younghastle3-source/training/contents/$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$P")?ref=$TREE" \
  --jq .content | base64 -d \
  | sed 's/!\[[^]]*\]\[image[0-9]*\]//g' \
  | grep -v '^\[image[0-9]*\]:' > /tmp/part111.md
sed -n '1,65p' /tmp/part111.md   # 要約本文（H3 4本）
grep -n '^### ' /tmp/part111.md  # => トラブル①/②/③/まとめ の4本
```

> 文字起こし部分（`以下原文` 以降）は**読んでもよいが写経してはならない**（I-8 の禁止文字列で検出される）。

### I-2. 統合先ファイルの現状（base_commit d407efe 時点・実測）

```yaml
パス: .claude/skills/shoulder-pain-rehabilitation/SKILL.md
行数: 87
frontmatter: 無し（H1 `# 肩外転時の痛み（インピンジメント）評価・改善プロセス` から始まるプレーン Markdown）
末尾改行: 有り（純粋な追記が可能）
由来: Part123「肩外転時の痛みに対する改善方法」
```

**既存 H2（7本・この順序を変えない）**

```
## 参照リポジトリ（GitHub・おっくん自身のナレッジ）
## いつ使うか
## 評価ステップ（ヒアリング〜触診）
## 改善アプローチ：相反抑制の活用
## よくあるNG
## 重要な気づき
## 出典
```

> **非破壊の規約（DW1 が機械検証する）**
>
> - 既存の**全非空行**をそのまま残す。並べ替え・言い換え・表記ゆれ修正も禁止。
> - 追記は「既存行の**間または後ろ**に新しい行を差し込む」形だけを使う。
>   既存行の末尾に文字を足すのも改変（`git diff --numstat` の削除が1になる）なので禁止。
> - `## いつ使うか` と `## 出典` は内容を**追加**するが、既存の段落・既存の1行はそのまま残す。
> - frontmatter は追加しない（既存スキル群と同じくプレーン Markdown のまま）。
>   追加すると1行目の H1 との位置関係が変わり、非破壊の判定が壊れる。

### I-3. 追加する H2 5本と配置

| # | H2（この文字列と完全一致させる） | 配置 |
|---|---|---|
| 1 | `## 現場で多い3大トラブル（Part111）` | `## 重要な気づき` の後ろ |
| 2 | `## トラブル①：肩前方の痛み（上腕二頭筋長頭腱の炎症）` | 1 の後ろ |
| 3 | `## トラブル②：僧帽筋の過度な張り` | 2 の後ろ |
| 4 | `## トラブル③：左の腰痛（前屈・運搬時）` | 3 の後ろ |
| 5 | `## 評価の原理：対角線と拮抗筋を見る` | 4 の後ろ・`## 出典` の前 |

> - **見出し文字列に半角スペースを含めない**（test_command が `for H in ...` で単語分割するため）。
> - 各区間に実体行（`- ` / `{数字}. ` / `|` 始まり）を3行以上置く（DW2）。
> - 1 は3トラブルの一覧表とし、`|` 始まりの行を5行以上（ヘッダ＋区切り＋3データ行）置く。
>   表には**症状の出る場所と真の原因が別であること**が読めるよう、
>   `外旋筋` / `腰方形筋` / `右の股関節` の3語を必ず含める。

**各区間の必須内容（機械検証される条件）**

| 区間 | 条件 |
|---|---|
| `## 現場で多い3大トラブル（Part111）` | `\|` 始まりの行が5行以上 |
| `## トラブル①：...` | `上腕二頭筋長頭腱` / `肩峰` / `内旋` / `インピンジメント` / `小円筋` / `三角筋後部` / `外旋` / `リリース` を全て含む。`肩峰` と（`ぶつ`\|`挟`）を同時に含む行が1行以上。実体行4行以上 |
| `## トラブル②：...` | I-4 の全条件 |
| `## トラブル③：...` | I-5 の全条件 |
| `## 評価の原理：...` | `痛い場所に原因があるとは限らない` / `対角線` / `拮抗筋` を含み、`- ` 行3行以上。3対応（肩前⇔外旋筋 / 僧帽筋⇔腰方形筋・広背筋 / 左腰⇔右股関節）が各1行以上 |

> `拮抗筋` と `インピンジメント` と `広背筋` は**既存本文にも出現する**ため、
> ファイル全体の grep では「読んだ証拠」にならない。**必ず区間限定で検証すること**
> （DW3〜DW6 は全て `SEC` で区間を切ってから照合している）。

### I-4. トラブル②の「逆」の理解（最も誤読しやすい箇所）

```yaml
症状: 右の僧帽筋（首〜肩）が常に張る。サイドレイズ等で右僧帽筋ばかり先に疲れる
誤読されがちな解釈: 「僧帽筋が縮んで固まっている」→ 僧帽筋をマッサージして緩める
出典の実際の主張（逆）: |
  僧帽筋は縮んで固まっているのではない。
  右の広背筋・腰方形筋が縮んで固まり、右肩全体を下に引っ張って落としている。
  その結果、上の僧帽筋は「引き伸ばされた状態で常に耐えている（過緊張）」ためパンパンに張る。
改善: |
  張っている僧帽筋をマッサージするのではなく、右の腰方形筋・広背筋をリリースして緩めるのが先決。
  右の肋骨・肩を引き上げ、左右の肩の高さ（アライメント）を正常な位置に戻してからトレーニングする。
  これで僧帽筋への異常な負荷が消え、正しく三角筋を使えるようになる。
```

**機械検証される条件**

1. 区間に `腰方形筋` / `広背筋` / `引き伸ば` / `過緊張` / `アライメント` / `リリース` が全て含まれる
2. `縮` を含む行のうち1行以上が `ではな` / `逆` / `わけではな` を含む（＝否定が明示されている）
3. `引き伸ば` を含む行が `僧帽筋` または `耐え` を含む（＝伸ばされているのが僧帽筋だと分かる）
4. `マッサージ` を含む行が1行以上あり、**その全行**が `ではな` / `しない` / `逆` / `禁` を含む

> 4 は「僧帽筋をマッサージして緩めましょう」と肯定形で書いた瞬間に FAIL する設計。
> **誤読をそのまま書くと通らない**ようにするための条件であり、単なるキーワード充填では突破できない。

### I-5. トラブル③の左右の交差（2番目に誤読しやすい箇所）

```yaml
症状: 左の腰痛（前屈時・ルーマニアンデッドリフト・物を運ぶとき）
誤読されがちな解釈: 「左の腰が痛い → 左の股関節・左の腸腰筋を見る」
出典の実際の主張（交差）: |
  根本原因は「右の股関節の屈曲がうまくできていない」こと。
  右の脊柱起立筋が過剰に働き、右の腸腰筋・内腹斜筋がサボっている。
  右側がうまく引けない（曲がらない）ため、左側が代償して体を支え、左腰に負担が集中する。
改善: |
  右の腸腰筋を活性化させる。仰向けになり、足首（つま先）を上に向けた状態で、
  右膝を胸に近づけるように引き上げる（誰かに抵抗をかけてもらうとより効果的）。
  右の股関節が引き込めるようになると、左腰への代償動作が消失する。
```

**機械検証される条件**

1. 区間に `腸腰筋` / `内腹斜筋` / `脊柱起立筋` / `代償` / `仰向け` / `股関節` が全て含まれる
2. `左` → `腰` → `右` → `股関節` の順、または `右` → `股関節` → `左` → `腰` の順で
   4語を同時に含む行が1行以上ある（＝交差が1文で読める）
3. `腸腰筋` を含む行が1行以上あり、**その全行が `右` を含む**
4. `左の股関節` / `左の腸腰筋` / `左側の腸腰筋` が区間内に**0件**

> 3 と 4 は、左右を取り違えた記述（＝最も起こりやすい実害のある誤り）を直接検出する。

### I-6. `## いつ使うか` の拡張仕様

```yaml
現状（base）: |
  「胸のトレーニング（ペックフライ・ベンチプレス等）後に肩を痛めた時、または外転（横に上げる）時に
   コリッという引っ掛かり感・詰まり感が出る時に参照する。」という1段落のみ。
   ディレクトリ名 shoulder-pain-rehabilitation と整合しているが、Part111 統合後は肩以外も扱う。
やること: 上記の段落は**そのまま残し**、その後ろに適用範囲を列挙した `- ` 3行以上を追記する
必須語: 僧帽筋 / 腰痛 / 肩
```

> 例（そのまま使ってよい構造。文言は出典に合わせて調整すること）:
>
> ```
> - 肩の外転・前方に痛みや詰まりが出る（Part123 / Part111 トラブル①）
> - 片側の僧帽筋だけが慢性的に張る・サイドレイズで先に疲れる（Part111 トラブル②）
> - 前屈や運搬で片側の腰痛が出る（Part111 トラブル③）
> ```
>
> **ディレクトリ名は変更しない。** 改名は本タスクのスコープ外（後述）。

### I-7. `## 出典` の記載仕様

既存の1行を**残したまま**、Part111 の行を追記する。区間に以下4つが全て逐語で含まれること。

```
cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md
github.com/younghastle3-source/training
https://www.youtube.com/watch?v=8sadHyESZAA
Part123「肩外転時の痛みに対する改善方法」(2026-07-17) - シジアドバンス
```

> 最後の1行は**既存行の逐語**（base の87行目）。これが消えると DW1 と DW8 の両方で FAIL する。

### I-8. 禁止文字列（10個）と行数の上下限

**`.claude/skills/shoulder-pain-rehabilitation/` 配下に出現してはならない文字列**

```
TBD
TODO
FIXME
後で書く
Transcript:
以下原文
Getty Images
Shutterstock
こんにちは
image1
```

> **意図**:
> - 前半4個は「見出しと箇条書きの体裁だけ整えて中身を空にする」逃げ道を塞ぐ。
> - `Transcript:` / `以下原文` / `こんにちは` は出典ファイルの**文字起こし部分**に実在する文字列。
>   YouTube 逐語の丸写しを検出する。
> - `Getty Images` / `Shutterstock` / `image1` は出典の画像クレジット・画像参照。
>   出典を機械的にコピペした場合に混入する。

**行数の上下限（`SKILL.md`）**

```yaml
最小: 137 行  # base 87 行 + 追加50行（DW1 の「追加50行以上」と整合）
最大: 260 行  # 文字起こしの丸写し・出典の全文コピーを防ぐ上限
```

**ファイル全体に逐語で含まれるべき必須新規キーワード（11個 / DW2）**

```
腰方形筋
小円筋
腸腰筋
内腹斜筋
脊柱起立筋
三角筋後部
肩峰
僧帽筋
対角線
過緊張
内旋
```

> 11語とも**base の87行には1度も出現しない**（実測確認済み）ため、
> 「出典を実際に読んだか」の代理指標として機能する。
> 一方 `上腕二頭筋長頭腱` / `インピンジメント` / `拮抗筋` / `広背筋` は base に既出のため
> ファイル全体の grep では代理指標にならず、区間限定でのみ検証する（DW3 / DW4 / DW6）。

### I-9. 索引の更新仕様と不変条件

**ファイル**: `.claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md`

**`## スキル化済みの講義` に追加する行（この書式に合わせる）**

```
| Part111 | `.claude/skills/shoulder-pain-rehabilitation/` | 済 |
```

追加後の当該区間の `|` 始まりの行は**ちょうど7行**（ヘッダ1＋区切り1＋データ5）になる。

```
| Part | 切り出し先スキル | 状態 |
|---|---|---|
| Part111 | `.claude/skills/shoulder-pain-rehabilitation/` | 済 |
| Part122 | `.claude/skills/速筋遅筋-weight-training-theory/` | 済 |
| Part123 | `.claude/skills/shoulder-pain-rehabilitation/` | 済 |
| Part126 | `.claude/skills/personal-session-communication/` | 済 |
| Part128 | `.claude/skills/skeletal-exercise-selection/` | 済 |
```

> Part111 と Part123 が**同じディレクトリを指すのは意図どおり**（1スキルに2講義を統合したため）。

**壊してはならない不変条件（DW9 が回帰検証する）**

```yaml
不変条件: |
  `## 講義一覧` の表のうち、`|` 始まりの行で第5フィールドが `cj advance/` で始まるものが
  **生の行数でちょうど86行**であり、かつ NFC 正規化後の集合が pinned tree（8164d0d）の
  実データ（NFC 正規化・重複排除後86件）と diff で完全一致する。
重要（生の行数を別に数える理由）: |
  NFC ヘルパは Python の set で重複を排除するため、**同じパスの行を2行書いても
  正規化後は1件に潰れて 86 のまま**になる。実際にデコイ D8（Part111 の行を
  `## 講義一覧` に重複追加）が NFC 後のカウントだけでは検出できず PASS してしまうことを実測した。
  そのため `RAW`（NFC を通す前の行数）を別に数えて 86 と比較する。
安全である理由: |
  `## スキル化済みの講義` の表は3列なので `awk -F'|'` の第5フィールドが空になり、
  `grep '^cj advance/'` で除外される。実測で現状の4行構成のまま86件が得られることを確認済み。
  したがって Part111 の1行追加はこの不変条件に影響しない。
注意: |
  `## 講義一覧` 側には**すでに Part111 の行が存在する**（80行目）。
  そのため `grep -cF "| Part111 |"` をファイル全体に対して実行すると 2 になる。
  必ず SEC で `## スキル化済みの講義` 区間に限定してから数えること。
```

### I-10. DW10(c) 回帰検証の allowlist

**本タスクで変更してよいファイル（NEW）**

```
^\.claude/skills/shoulder-pain-rehabilitation/
^\.claude/skills/クロニクルジャパンcj-advance/
^plan/playbook-part111-integration\.md$
^state\.md$
^docs/repository-map\.yaml$
```

**直前タスクの成果物（PREV / 同一ブランチ上に存在する。触らないが変更集合には現れる）**

```
^\.claude/skills/personal-session-communication/
^\.claude/skills/skeletal-exercise-selection/
^plan/playbook-cj-advance-skill-expansion\.md$
```

**タスク開始前から作業ツリーに存在した先行の未コミット差分（PRE / 15件）**

```
^\.claude/agents/critic\.md$
^\.claude/settings\.json$
^\.claude/skills/instagram-pdca/
^\.claude/skills/video-editing-ffmpeg/
^plan/playbook-setup-instagram-skills\.md$
^tmp/
```

> `.claude/skills/` 配下で許可されるディレクトリは以下の**6つのみ**（DW10(c) の後半で検証）:
> `shoulder-pain-rehabilitation` / `クロニクルジャパンcj-advance` /
> `personal-session-communication` / `skeletal-exercise-selection` /
> `instagram-pdca` / `video-editing-ffmpeg`。
>
> **PREV と PRE は本タスクの成果物ではない。allowlist には含めるが、本タスクのコミットに混ぜない**
> （PREV は直前タスク名義で別コミットにする。ft0 参照）。

---

## スコープ外（本タスクでは扱わない）

> **以下は「やらない」と明示的に合意済み。着手したら DW10(c) の回帰検証で FAIL する。**

```yaml
改名（フォローアップ候補・別 playbook）:
  - `.claude/skills/shoulder-pain-rehabilitation/` の改名
    （Part111 統合により肩以外＝僧帽筋・腰も扱うようになり、ディレクトリ名と中身がずれる）
  - 改名しない理由: 以下から参照されており、改名すると全て壊れる
      * `.claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md`（Part123 行 / Part111 行）
      * 直前タスクで新設した personal-session-communication / skeletal-exercise-selection の
        `## 既存スキルとの役割分担` からの参照
  - 改名する場合に必要な作業（別 playbook のスコープ）:
      1. ディレクトリ名の決定（例: musculoskeletal-troubleshooting）
      2. `git mv` と全参照元の一括更新
      3. 参照が0件残っていないことの grep 検証

統合作業（別 playbook で扱う）:
  - Part127（パーソナル業界・資格・経営）を おっくん哲学self-coaching に統合する作業
  - Part91 / Part92（下肢・上半身のストレッチ）を クロニクルジャパンcj-advance に統合する作業

その他:
  - 既存の未コミット変更15件（I-10 の PRE）の整理・コミット
  - 直前タスクの成果物（I-10 の PREV）の内容改訂
  - `## 講義一覧` の86行の内容改訂（Part111 行の書き換えを含む）
  - `.claude/hooks/generate-repository-map.sh` の既知バグの修正（state.md の known_issues 参照）
  - Part111 の YouTube 文字起こし全文の取り込み（I-8 の禁止文字列で検出される）
```

---

## phases

### p1: Part111 の3トラブルを SKILL.md に非破壊で統合する

**goal**: 既存 87 行を1行も壊さずに、新規5 H2（3大トラブル一覧 / トラブル①②③ / 評価の原理）を追記し、`## いつ使うか` と `## 出典` を追加行のみで拡張する

#### subtasks

- [ ] **p1.1**: base_commit d407efe 時点の全非空行が逐語で残存し、`git diff --numstat` の削除が0行・追加が50行以上で、既存 H2 7本が各1本ずつ残っている
  - executor: claudecode
  - prerequisites: "I-1 の取得コマンドで Part111 の要約本文（先頭65行 / H3 4本）を読んでから書くこと"
  - test_command: |
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    test -f "$F" || { echo "FAIL nofile"; exit 0; }
    for H in 参照リポジトリ（GitHub・おっくん自身のナレッジ） いつ使うか 評価ステップ（ヒアリング〜触診） \
             改善アプローチ：相反抑制の活用 よくあるNG 重要な気づき 出典; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    MISS=$(git show d407efe:"$F" | while IFS= read -r L; do
      [ -n "$L" ] || continue
      grep -qxF -- "$L" "$F" || echo "$L"
    done | head -3)
    [ -z "$MISS" ] || { M="$M baseline;"; echo "$MISS"; }
    NS=$(git -c core.quotepath=false diff --numstat d407efe -- "$F")
    A=$(echo "$NS" | awk '{print $1}'); D=$(echo "$NS" | awk '{print $2}')
    [ -n "$A" ] || { A=0; D=0; M="$M nodiff;"; }
    [ "$D" -eq 0 ] || M="$M deleted:$D;"
    [ "$A" -ge 50 ] || M="$M added:$A(min50);"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "`git diff --numstat` は純粋な追記で `N 0`、既存行を1行でも書き換えると `N 1` 以上を返す。加えて base の全非空行を `grep -qxF` で1行ずつ照合しており、行を消して別の場所に言い換えて書き直す抜け道も塞がれている"
    - consistency: "base_commit を d407efe に固定しているため、Phase 途中でコミットしても判定が変わらない。I-2 の非破壊規約と逐語で対応している"
    - completeness: "既存 H2 の残存・全行の残存・削除0行・追加下限の4点を同時に検証している"

- [ ] **p1.2**: H2 がちょうど12本で、新規5 H2 が各1本ずつ存在し各区間に実体行が3行以上あり、I-8 の必須新規キーワード11個がファイル全体に含まれる
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    T=$(grep -c '^## ' "$F"); [ "$T" -eq 12 ] || M="$M h2total:$T(want12);"
    for H in 現場で多い3大トラブル（Part111） トラブル①：肩前方の痛み（上腕二頭筋長頭腱の炎症） \
             トラブル②：僧帽筋の過度な張り トラブル③：左の腰痛（前屈・運搬時） \
             評価の原理：対角線と拮抗筋を見る; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || { M="$M h2:$H;"; continue; }
      [ "$(SEC "$F" "^## $H\$" | grep -cE '^(- |[0-9]+[.] |\|).+')" -ge 3 ] || M="$M lines:$H;"
    done
    [ "$(SEC "$F" '^## 現場で多い3大トラブル（Part111）$' | grep -c '^|')" -ge 5 ] || M="$M overview;"
    for P in 外旋筋 腰方形筋 右の股関節; do
      SEC "$F" '^## 現場で多い3大トラブル（Part111）$' | grep -qF -- "$P" || M="$M ov:$P;"
    done
    for P in 腰方形筋 小円筋 腸腰筋 内腹斜筋 脊柱起立筋 三角筋後部 肩峰 僧帽筋 対角線 過緊張 内旋; do
      grep -qF -- "$P" "$F" || M="$M kw:$P;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "見出しだけ作って中身を空にすると `lines:{見出し}` で FAIL する。11キーワードは base の87行に1度も出現しないことを実測済みなので、出典を読まずに書いた場合に `kw:` で検出される"
    - consistency: "H2 総数12（既存7＋新規5）が I-2 / I-3 の構成と一致しており、既存見出しを削って新規に置き換えた場合は p1.1 の `h2:` と本条件の両方で FAIL する"
    - completeness: "総数・個別存在・実体行・一覧表の列数・必須語の5点を同時に検証している"

- [ ] **p1.3**: `## トラブル①：肩前方の痛み（上腕二頭筋長頭腱の炎症）` 区間に挟み込みの機序と改善（外旋筋群）が書かれている
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## トラブル①：肩前方の痛み（上腕二頭筋長頭腱の炎症）$')
    for P in 上腕二頭筋長頭腱 肩峰 内旋 インピンジメント 小円筋 三角筋後部 外旋 リリース; do
      echo "$B" | grep -qF -- "$P" || M="$M t1:$P;"
    done
    echo "$B" | grep -F '肩峰' | grep -qE 'ぶつ|挟' || M="$M t1mech;"
    [ "$(echo "$B" | grep -cE '^(- |[0-9]+[.] |\|).+')" -ge 4 ] || M="$M t1lines;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "`肩峰` を含む行が衝突・挟み込みに言及していることまで確認しており、用語を並べただけでは `t1mech` で FAIL する"
    - consistency: "`インピンジメント` / `上腕二頭筋長頭腱` は base にも既出のため区間限定で照合しており、既存記述の再利用では PASS しない"
    - completeness: "原因（内旋→肩峰との衝突）と改善（前方リリース＋小円筋・三角筋後部）の両方の語が揃っている"

- [ ] **p1.4**: `## トラブル②：僧帽筋の過度な張り` 区間が「僧帽筋は縮んでいるのではなく引き伸ばされて耐えている」という**逆**の理解で書かれている
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## トラブル②：僧帽筋の過度な張り$')
    for P in 腰方形筋 広背筋 引き伸ば 過緊張 アライメント リリース; do
      echo "$B" | grep -qF -- "$P" || M="$M t2:$P;"
    done
    echo "$B" | grep -F '縮' | grep -qE 'ではな|逆|わけではな' || M="$M t2neg;"
    echo "$B" | grep -F '引き伸ば' | grep -qE '僧帽筋|耐え' || M="$M t2stretch;"
    MZ=$(echo "$B" | grep -F 'マッサージ')
    if [ -z "$MZ" ]; then M="$M t2nomassage;"; else
      BADM=$(echo "$MZ" | grep -vcE 'ではな|しない|逆|禁')
      [ "$BADM" -eq 0 ] || { M="$M t2massage:$BADM;"; echo "$MZ" | grep -vE 'ではな|しない|逆|禁'; }
    fi
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "「僧帽筋をマッサージして緩める」と肯定形で書くと `t2massage:` で FAIL し、「縮んで固まっている」とだけ書くと `t2neg` で FAIL する。誤読をそのまま書いた場合に必ず落ちる設計（デコイ D3 / D4 で実測済み）"
    - consistency: "I-4 の4条件と逐語で1対1対応しており、p_final.4（DW4）と同一ロジック"
    - completeness: "真の原因（腰方形筋・広背筋）・状態（引き伸ばされた過緊張）・否定の明示・改善の順序（アライメント→トレーニング）の全てを検証している"

- [ ] **p1.5**: `## トラブル③：左の腰痛（前屈・運搬時）` 区間が「左腰痛の原因は右の股関節屈曲不全」という左右の交差で書かれている
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## トラブル③：左の腰痛（前屈・運搬時）$')
    for P in 腸腰筋 内腹斜筋 脊柱起立筋 代償 仰向け 股関節; do
      echo "$B" | grep -qF -- "$P" || M="$M t3:$P;"
    done
    echo "$B" | grep -qE '左.*腰.*右.*股関節|右.*股関節.*左.*腰' || M="$M t3cross;"
    IZ=$(echo "$B" | grep -F '腸腰筋')
    if [ -z "$IZ" ]; then M="$M t3noiliopsoas;"; else
      BADI=$(echo "$IZ" | grep -vc '右')
      [ "$BADI" -eq 0 ] || { M="$M t3side:$BADI;"; echo "$IZ" | grep -v '右'; }
    fi
    for P in 左の股関節 左の腸腰筋 左側の腸腰筋; do
      echo "$B" | grep -qF -- "$P" && M="$M t3wrong:$P;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "`腸腰筋` を含む行が1行でも `右` を欠くと `t3side:` で FAIL し、左右を取り違えると `t3wrong:` で FAIL する（デコイ D5 で実測済み）"
    - consistency: "I-5 の4条件と逐語で1対1対応しており、p_final.5（DW5）と同一ロジック"
    - completeness: "原因（右脊柱起立筋の過活動・右腸腰筋/内腹斜筋のサボり）・代償の説明・具体的なエクササイズ（仰向け）・交差の明示を全て検証している"

- [ ] **p1.6**: `## 評価の原理：対角線と拮抗筋を見る` 区間に「痛い場所に原因があるとは限らない」と3対応が書かれている
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## 評価の原理：対角線と拮抗筋を見る$')
    for P in 痛い場所に原因があるとは限らない 対角線 拮抗筋; do
      echo "$B" | grep -qF -- "$P" || M="$M pr:$P;"
    done
    L=$(echo "$B" | grep -E '^- .+')
    [ "$(echo "$L" | grep -c .)" -ge 3 ] || M="$M prlines;"
    echo "$L" | grep -F '肩' | grep -qF '外旋' || M="$M pr1;"
    echo "$L" | grep -F '僧帽筋' | grep -qE '腰方形筋|広背筋' || M="$M pr2;"
    echo "$L" | grep -qE '左.*腰.*右.*股関節' || M="$M pr3;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "3対応それぞれを別々の条件（`pr1` / `pr2` / `pr3`）で検証しており、原理を1行のスローガンだけで済ませると FAIL する"
    - consistency: "`拮抗筋` は base の43行目にも出現するため区間限定で照合しており、既存記述では PASS しない"
    - completeness: "原理の言明・3トラブルへの対応づけ・対角線/拮抗筋という評価軸の3点が揃っている"

- [ ] **p1.7**: `## いつ使うか` が肩以外（僧帽筋の張り・腰痛）にも広がり、`## 出典` に Part111 の出典3点が追記され、既存記述が両区間とも残っている
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## いつ使うか$')
    for P in 僧帽筋 腰痛 肩; do echo "$B" | grep -qF -- "$P" || M="$M when:$P;"; done
    [ "$(echo "$B" | grep -cE '^- .+')" -ge 3 ] || M="$M whenlines;"
    echo "$B" | grep -qF '外転（横に上げる）時にコリッという引っ掛かり感' || M="$M whenbase;"
    B2=$(SEC "$F" '^## 出典$')
    echo "$B2" | grep -qF -- 'cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md' || M="$M srcpath;"
    echo "$B2" | grep -qF -- 'github.com/younghastle3-source/training' || M="$M srcrepo;"
    echo "$B2" | grep -qF -- 'https://www.youtube.com/watch?v=8sadHyESZAA' || M="$M srcurl;"
    echo "$B2" | grep -qF -- 'Part123「肩外転時の痛みに対する改善方法」(2026-07-17) - シジアドバンス' || M="$M src123;"
    [ "$(echo "$B2" | grep -cE '^- .+')" -ge 2 ] || M="$M srclines;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "既存の段落（`whenbase`）と既存の出典行（`src123`）を逐語で要求しているため、『書き直して整える』と FAIL する。p1.1 の非破壊検証と二重に効く"
    - consistency: "出典パスは I-1 の pinned tree に実在する値と逐語一致しており、索引の `## 講義一覧` の80行目のパス列とも同一である"
    - completeness: "適用範囲の拡張（3語＋3行以上）と出典の4要素を同時に検証している"

**status**: pending
**max_iterations**: 5
**time_limit**: 45min
**priority**: high

---

### p2: 索引への登録と不変条件の回帰検証

**goal**: `lecture-index.md` の `## スキル化済みの講義` に Part111 の1行を追加し、`## 講義一覧` の86件という不変条件を壊していないことを確認する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: `## スキル化済みの講義` の `|` 行がちょうど7行で、Part111 / 122 / 123 / 126 / 128 の5行が各1行ずつ存在し、各行のスキルディレクトリが実在する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    IDX=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    test -f "$IDX" || { echo "FAIL noindex"; exit 0; }
    B=$(SEC "$IDX" '^## スキル化済みの講義$')
    R=$(echo "$B" | grep -c '^|'); [ "$R" -eq 7 ] || M="$M rows:$R(want7);"
    for T in "Part111 .claude/skills/shoulder-pain-rehabilitation/" \
             "Part122 .claude/skills/速筋遅筋-weight-training-theory/" \
             "Part123 .claude/skills/shoulder-pain-rehabilitation/" \
             "Part126 .claude/skills/personal-session-communication/" \
             "Part128 .claude/skills/skeletal-exercise-selection/"; do
      ID=${T% *}; DIR=${T#* }
      C=$(echo "$B" | grep -cF "| $ID |"); [ "$C" -eq 1 ] || { M="$M row:$ID($C);"; continue; }
      echo "$B" | grep -F "| $ID |" | grep -qF "$DIR" || M="$M dir:$ID;"
      test -d "$DIR" || M="$M nodir:$DIR;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "行数をちょうど7に固定しているため、行の追加漏れも重複追加も検出できる。`## 講義一覧` 側にも Part111 の行が存在する（80行目）が、SEC で区間を限定しているため誤カウントしない"
    - consistency: "Part111 と Part123 が同じディレクトリを指すのは I-9 の意図どおりであり、`test -d` で両方とも実在が確認される"
    - completeness: "行数・5行の個別存在・ディレクトリ名の一致・ディレクトリの実在を同時に検証している"

- [ ] **p2.2**: 回帰 — `## 講義一覧` のパス列が pinned tree の実データと集合一致し、ちょうど86件のままである
  - executor: claudecode
  - test_command: |
    TREE=8164d0d992ed88d275498ccd56779f6eeb719375
    NFC() { python3 -c "import sys,unicodedata;print('\n'.join(sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})))"; }
    IDX=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    gh api "repos/younghastle3-source/training/git/trees/$TREE?recursive=1" \
      --jq '.tree[]|select(.type=="blob")|select(.size>1)|.path' \
      | grep '^cj advance/' | grep '\.md$' | grep -v '/README\.md$' | NFC > /tmp/p111_expect.txt
    awk -F'|' '/^\|/{gsub(/^ +| +$/,"",$5); print $5}' "$IDX" | grep '^cj advance/' > /tmp/p111_raw.txt
    NFC < /tmp/p111_raw.txt > /tmp/p111_actual.txt
    RAW=$(grep -c . /tmp/p111_raw.txt)
    E=$(grep -c . /tmp/p111_expect.txt); N=$(grep -c . /tmp/p111_actual.txt)
    [ "$RAW" -eq 86 ] || M="$M rawrows:$RAW(want86);"
    [ "$E" -eq 86 ] || M="$M expect:$E(want86);"
    [ "$N" -eq 86 ] || M="$M rows:$N(want86);"
    diff /tmp/p111_expect.txt /tmp/p111_actual.txt > /dev/null || { M="$M setmismatch;"; diff /tmp/p111_expect.txt /tmp/p111_actual.txt | head -10; }
    grep -qF -- 'cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md' /tmp/p111_actual.txt || M="$M no111;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "3列の `## スキル化済みの講義` の行は第5フィールドが空になるため `grep '^cj advance/'` で除外される（現状の4行構成で86件が得られることを実測済み）。もし誤って `## 講義一覧` 側に Part111 を二重登録すると `rows:87` と `setmismatch` で FAIL する"
    - consistency: "期待値をハードコードせず pinned tree の実データから毎回生成しており、直前タスク（DW1）が守っていた不変条件と同一のロジック・同一の pin を使っている"
    - completeness: "件数・集合一致・Part111 行の実在の3点を検証している"

**status**: pending
**max_iterations**: 3
**time_limit**: 20min
**priority**: high

---

### p_final: 完了検証（必須）

> **playbook の done_when（DW1〜DW10）が実際に満たされているか最終検証する。**
> **DW10(c) は git 状態に依存するため、ft0〜ft3 の実行後に単独で再実行すること。**
> **DW9 はネットワーク（`gh api`）を使用する。**

#### subtasks

- [ ] **p_final.1**: DW1 が満たされている（既存87行の非破壊）
  - executor: claudecode
  - test_command: |
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    test -f "$F" || { echo "DW1 FAIL nofile"; exit 0; }
    for H in 参照リポジトリ（GitHub・おっくん自身のナレッジ） いつ使うか 評価ステップ（ヒアリング〜触診） \
             改善アプローチ：相反抑制の活用 よくあるNG 重要な気づき 出典; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    MISS=$(git show d407efe:"$F" | while IFS= read -r L; do
      [ -n "$L" ] || continue
      grep -qxF -- "$L" "$F" || echo "$L"
    done | head -3)
    [ -z "$MISS" ] || { M="$M baseline;"; echo "$MISS"; }
    NS=$(git -c core.quotepath=false diff --numstat d407efe -- "$F")
    A=$(echo "$NS" | awk '{print $1}'); D=$(echo "$NS" | awk '{print $2}')
    [ -n "$A" ] || { A=0; D=0; M="$M nodiff;"; }
    [ "$D" -eq 0 ] || M="$M deleted:$D;"
    [ "$A" -ge 50 ] || M="$M added:$A(min50);"
    [ -z "$M" ] && echo "DW1 PASS" || echo "DW1 FAIL$M"
  - validations:
    - technical: "p1.1 と同一ロジック。base 全行の逐語残存と numstat 削除0の二重検証であり、片方だけ通る改変（行の移動＋言い換え）も検出される（デコイ D1 / D2 で実測済み）"
    - consistency: "base_commit 起点なので Phase 途中のコミット有無で判定が変わらない"
    - completeness: "H2 残存・全行残存・削除0・追加下限の4点"

- [ ] **p_final.2**: DW2 が満たされている（新規5 H2 と必須キーワード11個）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    T=$(grep -c '^## ' "$F"); [ "$T" -eq 12 ] || M="$M h2total:$T(want12);"
    for H in 現場で多い3大トラブル（Part111） トラブル①：肩前方の痛み（上腕二頭筋長頭腱の炎症） \
             トラブル②：僧帽筋の過度な張り トラブル③：左の腰痛（前屈・運搬時） \
             評価の原理：対角線と拮抗筋を見る; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || { M="$M h2:$H;"; continue; }
      [ "$(SEC "$F" "^## $H\$" | grep -cE '^(- |[0-9]+[.] |\|).+')" -ge 3 ] || M="$M lines:$H;"
    done
    [ "$(SEC "$F" '^## 現場で多い3大トラブル（Part111）$' | grep -c '^|')" -ge 5 ] || M="$M overview;"
    for P in 外旋筋 腰方形筋 右の股関節; do
      SEC "$F" '^## 現場で多い3大トラブル（Part111）$' | grep -qF -- "$P" || M="$M ov:$P;"
    done
    for P in 腰方形筋 小円筋 腸腰筋 内腹斜筋 脊柱起立筋 三角筋後部 肩峰 僧帽筋 対角線 過緊張 内旋; do
      grep -qF -- "$P" "$F" || M="$M kw:$P;"
    done
    [ -z "$M" ] && echo "DW2 PASS" || echo "DW2 FAIL$M"
  - validations:
    - technical: "p1.2 と同一ロジック。11キーワードは base に0件のため、出典を読まずに書くと `kw:` で FAIL する（デコイ D6 で実測済み）"
    - consistency: "H2 総数12が I-2（既存7）＋ I-3（新規5）と一致している"
    - completeness: "総数・個別存在・実体行・一覧表・必須語の5点"

- [ ] **p_final.3**: DW3 が満たされている（トラブル①）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## トラブル①：肩前方の痛み（上腕二頭筋長頭腱の炎症）$')
    for P in 上腕二頭筋長頭腱 肩峰 内旋 インピンジメント 小円筋 三角筋後部 外旋 リリース; do
      echo "$B" | grep -qF -- "$P" || M="$M t1:$P;"
    done
    echo "$B" | grep -F '肩峰' | grep -qE 'ぶつ|挟' || M="$M t1mech;"
    [ "$(echo "$B" | grep -cE '^(- |[0-9]+[.] |\|).+')" -ge 4 ] || M="$M t1lines;"
    [ -z "$M" ] && echo "DW3 PASS" || echo "DW3 FAIL$M"
  - validations:
    - technical: "p1.3 と同一ロジック。区間限定なので base の既存記述では PASS しない"
    - consistency: "I-3 の表の条件と逐語対応"
    - completeness: "原因の機序と改善手段の両方"

- [ ] **p_final.4**: DW4 が満たされている（トラブル②の「逆」の理解）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## トラブル②：僧帽筋の過度な張り$')
    for P in 腰方形筋 広背筋 引き伸ば 過緊張 アライメント リリース; do
      echo "$B" | grep -qF -- "$P" || M="$M t2:$P;"
    done
    echo "$B" | grep -F '縮' | grep -qE 'ではな|逆|わけではな' || M="$M t2neg;"
    echo "$B" | grep -F '引き伸ば' | grep -qE '僧帽筋|耐え' || M="$M t2stretch;"
    MZ=$(echo "$B" | grep -F 'マッサージ')
    if [ -z "$MZ" ]; then M="$M t2nomassage;"; else
      BADM=$(echo "$MZ" | grep -vcE 'ではな|しない|逆|禁')
      [ "$BADM" -eq 0 ] || { M="$M t2massage:$BADM;"; echo "$MZ" | grep -vE 'ではな|しない|逆|禁'; }
    fi
    [ -z "$M" ] && echo "DW4 PASS" || echo "DW4 FAIL$M"
  - validations:
    - technical: "デコイ D3（『僧帽筋が縮んで固まっているのでマッサージで緩める』と書き換え）で `t2neg; t2massage:1;` を実測、デコイ D4（`引き伸ば` の行を削除）で `t2:引き伸ば; t2stretch;` を実測"
    - consistency: "p1.4 と同一ロジック。I-4 の4条件と1対1対応"
    - completeness: "原因・状態・否定の明示・改善順序の4点"

- [ ] **p_final.5**: DW5 が満たされている（トラブル③の左右の交差）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## トラブル③：左の腰痛（前屈・運搬時）$')
    for P in 腸腰筋 内腹斜筋 脊柱起立筋 代償 仰向け 股関節; do
      echo "$B" | grep -qF -- "$P" || M="$M t3:$P;"
    done
    echo "$B" | grep -qE '左.*腰.*右.*股関節|右.*股関節.*左.*腰' || M="$M t3cross;"
    IZ=$(echo "$B" | grep -F '腸腰筋')
    if [ -z "$IZ" ]; then M="$M t3noiliopsoas;"; else
      BADI=$(echo "$IZ" | grep -vc '右')
      [ "$BADI" -eq 0 ] || { M="$M t3side:$BADI;"; echo "$IZ" | grep -v '右'; }
    fi
    for P in 左の股関節 左の腸腰筋 左側の腸腰筋; do
      echo "$B" | grep -qF -- "$P" && M="$M t3wrong:$P;"
    done
    [ -z "$M" ] && echo "DW5 PASS" || echo "DW5 FAIL$M"
  - validations:
    - technical: "デコイ D5（`右の腸腰筋` → `左の腸腰筋` に反転）で `t3side:1; t3wrong:左の腸腰筋;` を実測済み"
    - consistency: "p1.5 と同一ロジック。I-5 の4条件と1対1対応"
    - completeness: "必須語・交差の明示・活性化側の左右・誤読パターンの不在の4点"

- [ ] **p_final.6**: DW6 が満たされている（評価の原理と3対応）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## 評価の原理：対角線と拮抗筋を見る$')
    for P in 痛い場所に原因があるとは限らない 対角線 拮抗筋; do
      echo "$B" | grep -qF -- "$P" || M="$M pr:$P;"
    done
    L=$(echo "$B" | grep -E '^- .+')
    [ "$(echo "$L" | grep -c .)" -ge 3 ] || M="$M prlines;"
    echo "$L" | grep -F '肩' | grep -qF '外旋' || M="$M pr1;"
    echo "$L" | grep -F '僧帽筋' | grep -qE '腰方形筋|広背筋' || M="$M pr2;"
    echo "$L" | grep -qE '左.*腰.*右.*股関節' || M="$M pr3;"
    [ -z "$M" ] && echo "DW6 PASS" || echo "DW6 FAIL$M"
  - validations:
    - technical: "p1.6 と同一ロジック。原理の言明だけ書いて3対応を落とすと `pr1` / `pr2` / `pr3` で FAIL する"
    - consistency: "3対応が p_final.3 / .4 / .5 で検証した3トラブルの内容と整合している"
    - completeness: "言明・軸（対角線/拮抗筋）・3対応の3点"

- [ ] **p_final.7**: DW7 が満たされている（`## いつ使うか` の適用範囲拡張）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## いつ使うか$')
    for P in 僧帽筋 腰痛 肩; do echo "$B" | grep -qF -- "$P" || M="$M when:$P;"; done
    [ "$(echo "$B" | grep -cE '^- .+')" -ge 3 ] || M="$M whenlines;"
    echo "$B" | grep -qF '外転（横に上げる）時にコリッという引っ掛かり感' || M="$M whenbase;"
    [ -z "$M" ] && echo "DW7 PASS" || echo "DW7 FAIL$M"
  - validations:
    - technical: "既存段落の逐語（`whenbase`）を要求しているため、書き直して整えると FAIL する。`---` は `^- ` にマッチしないため実体行としてカウントされない（実測確認済み）"
    - consistency: "ディレクトリ名を改名しない代わりに `## いつ使うか` で適用範囲を明示する、という設計判断（スコープ外セクション）と対応している"
    - completeness: "3語の言及・3行以上の列挙・既存段落の残存"

- [ ] **p_final.8**: DW8 が満たされている（出典の4要素）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md; M=""
    B=$(SEC "$F" '^## 出典$')
    echo "$B" | grep -qF -- 'cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md' || M="$M srcpath;"
    echo "$B" | grep -qF -- 'github.com/younghastle3-source/training' || M="$M srcrepo;"
    echo "$B" | grep -qF -- 'https://www.youtube.com/watch?v=8sadHyESZAA' || M="$M srcurl;"
    echo "$B" | grep -qF -- 'Part123「肩外転時の痛みに対する改善方法」(2026-07-17) - シジアドバンス' || M="$M src123;"
    [ "$(echo "$B" | grep -cE '^- .+')" -ge 2 ] || M="$M srclines;"
    [ -z "$M" ] && echo "DW8 PASS" || echo "DW8 FAIL$M"
  - validations:
    - technical: "既存の Part123 行を逐語で要求しており、出典セクションを Part111 で上書きすると `src123` で FAIL する（デコイ D7 で実測済み）"
    - consistency: "出典パスは pinned tree に実在し、索引の `## 講義一覧` 80行目のパス列とも同一値（p_final.9 で索引側の実在が保証される）"
    - completeness: "リポジトリ内パス・リポジトリ名・YouTube 原典・既存出典の4要素"

- [ ] **p_final.9**: DW9 が満たされている（索引への登録と86件の回帰）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    NFC() { python3 -c "import sys,unicodedata;print('\n'.join(sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})))"; }
    TREE=8164d0d992ed88d275498ccd56779f6eeb719375
    IDX=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    test -f "$IDX" || { echo "DW9 FAIL noindex"; exit 0; }
    B=$(SEC "$IDX" '^## スキル化済みの講義$')
    R=$(echo "$B" | grep -c '^|'); [ "$R" -eq 7 ] || M="$M rows:$R(want7);"
    for T in "Part111 .claude/skills/shoulder-pain-rehabilitation/" \
             "Part122 .claude/skills/速筋遅筋-weight-training-theory/" \
             "Part123 .claude/skills/shoulder-pain-rehabilitation/" \
             "Part126 .claude/skills/personal-session-communication/" \
             "Part128 .claude/skills/skeletal-exercise-selection/"; do
      ID=${T% *}; DIR=${T#* }
      C=$(echo "$B" | grep -cF "| $ID |"); [ "$C" -eq 1 ] || { M="$M row:$ID($C);"; continue; }
      echo "$B" | grep -F "| $ID |" | grep -qF "$DIR" || M="$M dir:$ID;"
      test -d "$DIR" || M="$M nodir:$DIR;"
    done
    gh api "repos/younghastle3-source/training/git/trees/$TREE?recursive=1" \
      --jq '.tree[]|select(.type=="blob")|select(.size>1)|.path' \
      | grep '^cj advance/' | grep '\.md$' | grep -v '/README\.md$' | NFC > /tmp/p111_expect.txt
    awk -F'|' '/^\|/{gsub(/^ +| +$/,"",$5); print $5}' "$IDX" | grep '^cj advance/' > /tmp/p111_raw.txt
    NFC < /tmp/p111_raw.txt > /tmp/p111_actual.txt
    RAW=$(grep -c . /tmp/p111_raw.txt)
    E=$(grep -c . /tmp/p111_expect.txt); N=$(grep -c . /tmp/p111_actual.txt)
    [ "$RAW" -eq 86 ] || M="$M rawrows:$RAW(want86);"
    [ "$E" -eq 86 ] || M="$M expect:$E(want86);"
    [ "$N" -eq 86 ] || M="$M rows86:$N(want86);"
    diff /tmp/p111_expect.txt /tmp/p111_actual.txt > /dev/null || M="$M setmismatch;"
    grep -qF -- 'cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md' /tmp/p111_actual.txt || M="$M no111;"
    [ -z "$M" ] && echo "DW9 PASS" || echo "DW9 FAIL$M"
  - validations:
    - technical: "p2.1 と p2.2 を統合したもの。デコイ D8（Part111 行を `## 講義一覧` 側に重複追加）で `rows86:87; setmismatch;` を実測済み"
    - consistency: "直前タスクが守っていた86件の不変条件を同一の pin・同一のロジックで再検証しており、索引の整合性が本タスクで劣化していないことを保証する"
    - completeness: "登録側（7行・5対応・ディレクトリ実在）と回帰側（86件・集合一致）の両方"

- [ ] **p_final.10**: DW10 が満たされている（禁止文字列0件・行数の上下限・回帰 allowlist）
  - executor: claudecode
  - test_command: |
    F=.claude/skills/shoulder-pain-rehabilitation/SKILL.md
    S=.claude/skills/shoulder-pain-rehabilitation; M=""
    for P in "TBD" "TODO" "FIXME" "後で書く" "Transcript:" "以下原文" "Getty Images" "Shutterstock" "こんにちは" "image1"; do
      N=$(grep -rlF -- "$P" "$S" 2>/dev/null | wc -l | tr -d ' ')
      [ "$N" -eq 0 ] || M="$M ban:$P;"
    done
    L=$(wc -l < "$F" | tr -d ' ')
    [ "$L" -ge 137 ] || M="$M short:$L(min137);"
    [ "$L" -le 260 ] || M="$M long:$L(max260);"
    BASE=d407efe
    { git -c core.quotepath=false diff --name-only "$BASE" HEAD
      git -c core.quotepath=false diff --name-only HEAD
      git -c core.quotepath=false ls-files --others --exclude-standard; } | sed '/^$/d' | sort -u > /tmp/p111_changeset.txt
    NEW='^\.claude/skills/shoulder-pain-rehabilitation/|^\.claude/skills/クロニクルジャパンcj-advance/|^plan/playbook-part111-integration\.md$|^state\.md$|^docs/repository-map\.yaml$'
    PREV='^\.claude/skills/personal-session-communication/|^\.claude/skills/skeletal-exercise-selection/|^plan/playbook-cj-advance-skill-expansion\.md$'
    PRE='^\.claude/agents/critic\.md$|^\.claude/settings\.json$|^\.claude/skills/instagram-pdca/|^\.claude/skills/video-editing-ffmpeg/|^plan/playbook-setup-instagram-skills\.md$|^tmp/'
    ALLOW="$NEW|$PREV|$PRE"
    SKILLOK='^\.claude/skills/shoulder-pain-rehabilitation/|^\.claude/skills/クロニクルジャパンcj-advance/|^\.claude/skills/personal-session-communication/|^\.claude/skills/skeletal-exercise-selection/|^\.claude/skills/instagram-pdca/|^\.claude/skills/video-editing-ffmpeg/'
    A=$(grep '^\.claude/skills/' /tmp/p111_changeset.txt | grep -vcE "$SKILLOK")
    [ "$A" -eq 0 ] || { M="$M otherskills:$A;"; grep '^\.claude/skills/' /tmp/p111_changeset.txt | grep -vE "$SKILLOK"; }
    V=$(grep -vcE "$ALLOW" /tmp/p111_changeset.txt)
    [ "$V" -eq 0 ] || { M="$M outside:$V;"; grep -vE "$ALLOW" /tmp/p111_changeset.txt; }
    [ -z "$M" ] && echo "DW10 PASS" || echo "DW10 FAIL$M"
  - validations:
    - technical: "`core.quotepath=false` を付けないと非 ASCII パス（`.claude/skills/クロニクルジャパンcj-advance/...`, `tmp/AI×営業.html`）が8進エスケープされ allowlist に当たらず偽 FAIL になる。禁止文字列は `Transcript:` / `以下原文` / `Getty Images` を含み、出典の文字起こし・画像クレジットを写経すると検出される（デコイ D9 / D10 で実測済み）"
    - consistency: "allowlist が I-10 の NEW / PREV / PRE と逐語一致しており、スコープ外作業（ディレクトリの改名・Part127 統合等）に着手すると `otherskills:` または `outside:` で検出される"
    - completeness: "禁止文字列・行数下限（実体が入っている）・行数上限（丸写しでない）・変更集合の3経路（追跡済み差分／作業ツリー差分／未追跡）を全て検証している"

**status**: pending
**max_iterations**: 3

---

## final_tasks

- [ ] **ft0**: 直前タスク（playbook-cj-advance-skill-expansion）の成果物のコミット状態を確認する
  - command: |
    git -c core.quotepath=false ls-files --error-unmatch \
      ".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md" >/dev/null 2>&1 \
      && echo "OK: 直前タスクはコミット済み。ft3 に進んでよい" \
      || echo "ACTION: 直前タスクが未コミット。plan/playbook-cj-advance-skill-expansion.md の ft3 を先に実行し、PREV を別コミットにすること"
  - note: |
    `lecture-index.md` は直前タスクが新規作成したファイルであり、本タスクはそれを**編集**する。
    直前タスクが未コミットのまま本タスクの ft3 を実行すると、
    直前タスクの成果物（PREV）が本タスクのコミットに丸ごと巻き込まれ、
    どちらのタスクの成果物か履歴から判別できなくなる。
    **必ず ft0 → （必要なら直前タスクの ft3）→ 本タスクの ft3 の順で実行する。**
  - status: pending

- [ ] **ft1**: repository-map.yaml を更新し、失敗した場合は残骸を掃除する
  - command: |
    bash .claude/hooks/generate-repository-map.sh || echo "known bug: 生成スクリプトは失敗する（下記 note 参照）"
    rm -f docs/repository-map.yaml.tmp
    test -f docs/repository-map.yaml.tmp && echo "FAIL tmpleft" || echo "OK"
  - note: |
    `.claude/hooks/generate-repository-map.sh` は**既知のバグで動作しない**（state.md の
    known_issues `repository_map_generator_broken` 参照）。
    `set -euo pipefail` 下で存在しない `plan/active` を `find` して中断し、
    `docs/repository-map.yaml` を書かずに `docs/repository-map.yaml.tmp` を残す。
    したがって本 ft1 の目的は「更新の試行」と「`.tmp` 残骸を残さないこと」であり、
    `docs/repository-map.yaml` が更新されないこと自体は FAIL としない
    （スクリプトの修正はスコープ外）。`.tmp` が残ると未追跡ファイルとして
    DW10(c) の変更集合に現れ、allowlist 外として偽 FAIL を起こすため必ず削除する。
  - status: pending

- [ ] **ft2**: state.md を本タスクの内容に更新する
  - command: |
    # playbook.active / branch / goal.done_criteria(DW1〜DW10) / previous を更新する。
    # 以下は確認用（編集は Edit ツールで行う）
    grep -n 'active:\|branch:\|previous:' state.md
  - note: |
    `playbook.active` を `plan/playbook-part111-integration.md`、
    `previous` を `plan/playbook-cj-advance-skill-expansion.md` に更新する。
    `branch` は `feat/cj-advance-skill-expansion` のまま（新ブランチを切らないため）。
    known_issues の `pre_existing_uncommitted` は引き続き有効なので残すこと。
  - status: pending

- [ ] **ft3**: 本タスクの成果物のみを**明示パス指定で** add し、**同じ pathspec を付けて** commit する
  - command: |
    git add .claude/skills/shoulder-pain-rehabilitation \
            ".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md" \
            plan/playbook-part111-integration.md state.md
    git commit -m "feat(skills): integrate Part111 three common troubles into shoulder-pain-rehabilitation" -- \
            .claude/skills/shoulder-pain-rehabilitation \
            ".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md" \
            plan/playbook-part111-integration.md state.md
  - note: |
    - **`git add -A` および `git commit -a` は禁止。**
    - I-10 の PRE 15件（`.claude/agents/critic.md` / `.claude/settings.json` /
      `.claude/skills/instagram-pdca/` / `.claude/skills/video-editing-ffmpeg/` /
      `plan/playbook-setup-instagram-skills.md` / `tmp/`）は
      本タスク開始前から存在する先行の未コミット差分。**絶対に add / commit しない。**
    - I-10 の PREV 3件（`personal-session-communication/` / `skeletal-exercise-selection/` /
      `plan/playbook-cj-advance-skill-expansion.md`）は直前タスクの成果物。
      **本タスクのコミットに含めない**（ft0 で別コミット済みにしておく）。
    - `docs/repository-map.yaml` は ft1 の既知バグで更新されないため add 対象に含めない。
      万一更新された場合のみ、追加で add すること。
  - status: pending

- [ ] **ft4**: コミット結果を検証する（成果物2ファイルが全てコミットされ、許可外のファイルが1件も含まれない）
  - command: |
    git -c core.quotepath=false show --name-only --pretty=format: HEAD | sed '/^$/d' | sort -u > /tmp/p111_commit.txt
    M=""
    for P in '^\.claude/skills/shoulder-pain-rehabilitation/SKILL\.md$' \
             '^\.claude/skills/クロニクルジャパンcj-advance/references/lecture-index\.md$'; do
      grep -qE "$P" /tmp/p111_commit.txt || M="$M missing:$P;"
    done
    OK='^\.claude/skills/shoulder-pain-rehabilitation/|^\.claude/skills/クロニクルジャパンcj-advance/references/lecture-index\.md$|^plan/playbook-part111-integration\.md$|^state\.md$|^docs/repository-map\.yaml$'
    V=$(grep -vcE "$OK" /tmp/p111_commit.txt)
    [ "$V" -eq 0 ] || { M="$M outside:$V;"; grep -vE "$OK" /tmp/p111_commit.txt; }
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - note: |
    SKILL.md だけを見ると索引の更新漏れが、索引だけを見ると SKILL.md の漏れが検出できないため、
    **成果物2ファイル両方のパス存在**を個別に検証する。
    `outside:` が出た場合は PRE / PREV を巻き込んでいる。`git reset --soft HEAD~1` でやり直すこと。
  - status: pending

---

## pm の自己点検記録（2026-08-25 / playbook 作成時に実測）

> **目的**: レビュー往復を減らすため、提出前に「実データに基づく事実」と
> 「test_command が正しい成果物で PASS し、改悪された成果物で FAIL する」ことを実測で確認した。

### 1. 実データの確認

**出典（training@8164d0d に対して実行）**

| 確認項目 | 実測結果 |
|---|---|
| Part111 のパス | `cj advance/ハイパフォーマンス学/【Part111】現場で多い3大トラブルの改善方法.md` |
| サイズ | 636306 バイト |
| Unicode 正規化 | tree 上のパスは NFC 正規形と一致（`normalize('NFC',p)==p` が True）。NFD 重複なし |
| 画像除去後の行数 | 生97行 → 91行。うち**要約本文は先頭65行**、以降は YouTube 文字起こし |
| H3 の本数 | **4本のみ**（トラブル① / トラブル② / トラブル③ / まとめ） |
| YouTube 原典 | https://www.youtube.com/watch?v=8sadHyESZAA |
| 索引での在籍 | `## 講義一覧` の80行目に既に登録済み（1行） |

> 内容確認（実文で確認済み・創作ではない）:
> 「右腕は使用頻度が高く内旋が強い→巻き肩→肩峰と上腕二頭筋長頭腱が挟まる」
> 「改善は前方のリリース＋小円筋・三角筋後部（外旋筋群）の強化」
> 「僧帽筋は縮んでいるのではなく**逆**。右の広背筋・腰方形筋が肩を下へ引き、僧帽筋は引き伸ばされて耐えている（過緊張）」
> 「僧帽筋をマッサージするのではなく腰方形筋・広背筋をリリースし、アライメントを戻してからトレーニング」
> 「左腰痛の根本原因は**右**の股関節屈曲不全。右の脊柱起立筋が過活動、右の腸腰筋・内腹斜筋がサボり、左が代償」
> 「仰向けで足首を上に向け右膝を胸に近づける。抵抗をかけるとより効果的」
> 「痛い場所に原因があるとは限らない。対角線・拮抗筋のバランスを評価する」

**統合先（base_commit d407efe に対して実行）**

| 確認項目 | 実測結果 |
|---|---|
| `shoulder-pain-rehabilitation/SKILL.md` | 87行 / frontmatter 無し / 末尾改行あり |
| 既存 H2 | **7本**（参照リポジトリ / いつ使うか / 評価ステップ / 改善アプローチ / よくあるNG / 重要な気づき / 出典） |
| 現在の差分 | `git diff --numstat d407efe` が空（未変更） |
| `## いつ使うか` 区間の非空行 | 2行。ただし**うち1行は `---`**（SEC は `---` で区間を閉じないため。実体行のカウントは `^- ` に限定して回避） |
| I-8 の必須新規キーワード11個 | base の87行には**0件**（＝出典を読んだかの代理指標として有効） |
| `拮抗筋` / `インピンジメント` / `広背筋` / `上腕二頭筋長頭腱` | base に**既出**（＝ファイル全体の grep では代理指標にならない。区間限定でのみ検証） |

**索引（`lecture-index.md`）**

| 確認項目 | 実測結果 |
|---|---|
| `## スキル化済みの講義` の `\|` 行 | 6行（ヘッダ＋区切り＋データ4行: Part122/123/126/128） |
| `## 講義一覧` のパス列（生の行数） | **86** |
| `## 講義一覧` のパス列（NFC 後） | **86**（pinned tree の実データと集合一致） |
| 3列表が86件カウントに与える影響 | **無し**（第5フィールドが空になり `grep '^cj advance/'` で除外される。実測で確認） |

**git / ブランチ**

```
branch: feat/cj-advance-skill-expansion（HEAD = d407efe、main と同一コミット）
直前タスクの成果物: 未コミット（?? として作業ツリーに存在）
先行の未コミット差分: 15件（I-10 の PRE）
```

### 2. 構文チェック

本 playbook の Markdown から `- test_command: |` ブロック **19個を機械的に逐語抽出**し
（手で書き写したものではなく、この playbook のテキストそのものを実行している）、
`bash -n` / `zsh -n` の構文チェックを全19本で通過。

### 3. 正常系（期待成果物のモックに対する全 PASS）

実リポジトリ上に期待成果物のモックを構築して実行した:

- `SKILL.md`: base 87行に対し**純粋な追記のみ**で新規5 H2 と `## いつ使うか` の3行、`## 出典` の2行を追加
  （結果: 170行 / `git diff --numstat d407efe` = `83  0` = 追加83・削除0）
- `lecture-index.md`: `## スキル化済みの講義` に Part111 の1行を追加（`|` 行が 6 → 7）

```
p1.1 / p1.2 / p1.3 / p1.4 / p1.5 / p1.6 / p1.7        -> PASS
p2.1 / p2.2                                           -> PASS
p_final.1  -> DW1 PASS    p_final.2  -> DW2 PASS
p_final.3  -> DW3 PASS    p_final.4  -> DW4 PASS
p_final.5  -> DW5 PASS    p_final.6  -> DW6 PASS
p_final.7  -> DW7 PASS    p_final.8  -> DW8 PASS
p_final.9  -> DW9 PASS    p_final.10 -> DW10 PASS
=> 19ブロック × 2シェル（bash / zsh）= 38実行すべて PASS（ALL GREEN）
```

**実装前の実リポジトリに対する結果**（期待どおり FAIL することを確認）:

```
p_final.1  -> DW1 FAIL nodiff; added:0(min50);
p_final.7  -> DW7 FAIL when:僧帽筋; when:腰痛; whenlines;
p_final.9  -> DW9 FAIL rows:6(want7); row:Part111(0);
p_final.10 -> DW10 FAIL short:87(min137);   ← allowlist 部分（otherskills / outside）は現状で PASS
```

> モック検証後、`SKILL.md` と `lecture-index.md` を**チェックサム一致で完全復元**したことを確認済み
> （`shasum` が検証前の値と一致 / `git status --porcelain` が検証前と同一 + 本 playbook の1件）。

### 4. 異常系（14種のデコイに対する FAIL 検出）

> モックに改悪を加えて、**本 playbook から抽出した test_command** で判定した。
> 「実測結果」列は実際の標準出力の逐語。

| # | 改悪内容 | 期待 | 実測結果 |
|---|---|---|---|
| D1 | 既存の `## よくあるNG` の表の1行を言い換え（意味は同じ） | DW1 FAIL | `DW1 FAIL baseline; deleted:1;` |
| D2 | 既存の触診の1行（`結節間溝...`）を削除 | DW1 FAIL | `DW1 FAIL baseline; deleted:1;` |
| D3 | **トラブル②を誤読で記述**（僧帽筋が縮んで固まっている→マッサージして緩める） | DW4 FAIL | `DW4 FAIL t2neg; t2massage:1;` |
| D4 | 「引き伸ばされた状態で耐えている」の行を削除し `過緊張` だけ残す | DW4 FAIL | `DW4 FAIL t2:引き伸ば; t2stretch;` |
| D5 | **トラブル③の左右を反転**（`右の腸腰筋を活性化` → `左の腸腰筋を活性化`） | DW5 FAIL | `DW5 FAIL t3side:1; t3wrong:左の腸腰筋;` |
| D6 | 必須キーワード `腰方形筋` を曖昧語（`僧帽筋まわり`）に置換 | DW2 FAIL | `DW2 FAIL ov:腰方形筋; kw:腰方形筋;` |
| D7 | `## 出典` の既存 Part123 行を削除して Part111 で置き換え | DW8 / DW1 FAIL | `DW8 FAIL src123;` / `DW1 FAIL baseline; deleted:1;` |
| D8 | `## 講義一覧` に Part111 の行を**重複追加**（86 → 87行） | DW9 FAIL | `DW9 FAIL rawrows:87(want86);` |
| D9 | YouTube 文字起こしを SKILL.md に写経 | DW10 FAIL | `DW10 FAIL ban:Transcript:; ban:こんにちは;` |
| D10 | 評価の原理の対応を反転（`左の腰が痛いなら左の股関節`） | DW6 FAIL | `DW6 FAIL pr3;` |
| D11 | トラブル①の機序の行を用語の羅列に置換（`肩峰と長頭腱の位置関係を確認する`） | DW3 FAIL | `DW3 FAIL t1mech;` |
| D12 | `## スキル化済みの講義` に Part111 行を重複追加 | DW9 FAIL | `DW9 FAIL rows:8(want7); row:Part111(2);` |
| D13 | スコープ外のスキル（`hyrox-supplementary/NOTE.md`）を新規作成 | DW10 FAIL | `DW10 FAIL otherskills:1; outside:1;` |
| D14 | SKILL.md を410行まで水増し | DW10 FAIL | `DW10 FAIL long:410(max260);` |

**14/14 の改悪で期待どおり FAIL を検出。** 全デコイの復元後に対応する DW が再び PASS することも確認済み。

> **D8 は当初 `DW9 PASS` になっていた（偽 PASS）**。原因は `NFC` ヘルパが Python の `set` で
> 重複を排除するため、同じパスの行を2行書いても正規化後は86件に潰れること。
> これは直前タスク（playbook-cj-advance-skill-expansion）の DW1 にも存在した検出漏れである。
> 本 playbook では NFC を通す**前**の生の行数（`RAW`）を別に数える条件を追加して塞いだ
> （I-9 の「重要（生の行数を別に数える理由）」参照）。修正後に `rawrows:87(want86)` で検出される。

### 5. 残る未検証事項（構造上、機械検証できないもの）

- **本文の質**（3トラブルの説明が現場で使える粒度になっているか、既存の Part123 パートと
  文体・詳しさが揃っているか）は機械検証できない。
  出典を読まなければ書けない語（`腰方形筋` / `小円筋` / `腸腰筋` / `内腹斜筋` / `脊柱起立筋` /
  `三角筋後部` / `肩峰` / `過緊張`）を必須にし、誤読パターン（DW4 の `t2massage` /
  DW5 の `t3side` `t3wrong` / DW6 の `pr3`）を直接検出する条件を置くことで
  「読まずに一般論で埋める」「左右を取り違える」ことは検出できるが、
  **質の判断は critic / ユーザーの目視に委ねる**。
- **`## いつ使うか` の記述が実際に検索・起動の役に立つか**。
  DW7 は `僧帽筋` / `腰痛` / `肩` の3語と3行以上しか見ておらず、表現の適切さは見ていない。
- **ディレクトリ名と中身のずれ**。本タスク完了後、`shoulder-pain-rehabilitation` という名前は
  僧帽筋・腰を含む内容と一致しなくなる。これは**意図的に受け入れた技術的負債**であり
  （改名すると索引と新規2スキルからの参照が壊れるため）、スコープ外セクションに
  フォローアップ候補として記載した。**この playbook では解消しない。**
- **`docs/repository-map.yaml` が更新されないこと**。生成スクリプトの既知バグ
  （state.md の `repository_map_generator_broken`）により、本タスク後も skills.count は古いまま。
  ft1 は「試行して `.tmp` 残骸を残さない」ことのみを保証する。
- p1 / p2 の subtask test_command は p_final の DW 判定のサブセットであり、
  同一ロジックを2箇所に書いている。閾値は揃えてあるが、片方だけ修正されるリスクは残る。

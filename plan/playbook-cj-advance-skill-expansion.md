# playbook-cj-advance-skill-expansion.md

> **`github.com/younghastle3-source/training` の `cj advance/` 配下（毎週更新される講義ノート群）を、
> この repo の Skills として使える形に整備する。
> 「索引 → Part126（セッション運営コミュニケーション）→ Part128（骨格個人差ベースの種目選択）」の3フェーズ。**

---

## 実行前提と検証規約

> **本セクションの規約は全 test_command に適用される。**

- **CWD**: 全 test_command はリポジトリルート（`/Users/kosei/thanks4claudecode-fresh`）を
  カレントディレクトリとして実行する。相対パスは全てリポジトリルート起点。
- **シェル**: `bash` / `zsh` のどちらでも同じ結果になるよう記述する（本 playbook の主要 test_command は
  両方で実測済み。「pm の自己点検記録」参照）。
- **ネットワーク必須**: 索引の検証は `gh api` で training リポジトリの実データを取得して突き合わせる。
  オフラインでは実行できない（`gh auth status` が通ること）。
- **参照先の固定**: training リポジトリは毎週更新されるため、本 playbook は
  **commit SHA `8164d0d992ed88d275498ccd56779f6eeb719375`（2026-08-25T12:38:22Z 時点の main HEAD）に固定**して検証する。
  タスク実行中に training 側が更新されても判定がぶれない。
  タスク完了後に新しい講義が追加された場合は、索引に1行追加し I-1 の `TREE` を更新する（`## 更新方法` に記載する運用）。
- **区間抽出**: セクション内容の検証は必ず以下のヘルパで見出し区間を切り出してから行う。

  ```bash
  SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
  ```

  終端を `^#{1,2} ` にしているのは H1 でも区間を閉じるため。`### ` では閉じない。
- **Unicode 正規化が必須**: macOS のファイル名は NFD、GitHub API が返すパスは
  NFD / NFC が混在する（実際に `【Part100】ボディメイクvs機能改善.md` が
  NFC と NFD の2エントリとして tree に存在することを実測済み。I-3 参照）。
  パス集合の比較は必ず以下の `NFC` ヘルパを通してから行う。

  ```bash
  NFC() { python3 -c "import sys,unicodedata;print('\n'.join(sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})))"; }
  ```

  これを通さないと「見た目は同じなのに diff が出る」偽 FAIL、および
  「NFD で1行書いて重複を誤魔化す」偽 PASS の両方が起きる（両方とも実測確認済み）。
- **日本語・記号を含む固定文字列の照合は必ず `grep -qF` / `grep -cF`**（正規表現メタ誤爆の防止）。
- **git のパスは常に `git -c core.quotepath=false`**。これを付けないと非 ASCII を含むパス
  （`.claude/skills/クロニクルジャパンcj-advance/...`, `tmp/AI×営業.html`）が8進エスケープ＋
  ダブルクォート付きで出力され、パス照合が黙って失敗する（本リポジトリで実測確認済み）。
- **非 ASCII を含むパスは必ずダブルクォートで囲む**
  （`".claude/skills/クロニクルジャパンcj-advance/SKILL.md"`）。
- **変数をコマンド名として展開しない**（`G="git -c ..."; $G diff` は zsh が単語分割せず
  `command not found` になる）。
- **`gh api` の URL は必ずクォートする**（`?recursive=1` の `?` が zsh のグロブに食われて
  `no matches found` になる。実測確認済み）。

---

## meta

```yaml
project: thanks4claudecode
branch: feat/cj-advance-skill-expansion  # main（d407efe）から新規に切る
base_commit: d407efe  # main の HEAD。回帰検証（DW9）の比較元として固定
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

> **ブランチに関する注意（実行前に必ず読むこと）**
>
> 本 playbook 作成時点のブランチは `chore/scratchpad-cleanup` であり、
> **本タスクとは無関係な未コミット変更が15件浮いている**（I-6 の PRE リスト）。
> `chore/scratchpad-cleanup` の HEAD は `main` と同一コミット（d407efe / ahead 0・behind 0）なので、
> **その場で `git checkout -b feat/cj-advance-skill-expansion` を切れば未コミット変更は
> そのまま新ブランチに持ち越される**（stash 不要・成果物にも影響しない）。
>
> ```bash
> git checkout -b feat/cj-advance-skill-expansion   # d407efe から分岐。未コミット15件は持ち越し
> ```
>
> ただし **この15件は本タスクの成果物ではないため、絶対にコミットしてはならない**
> （`git add -A` / `git commit -a` は禁止。final_tasks ft3 参照）。

---

## goal

```yaml
summary: >
  training リポジトリの cj advance/ 配下（86本の講義ノート）を、Part 番号↔テーマ↔領域↔パスの
  索引としてスキル化し（毎週の更新が1行追加で済む運用）、既存11スキルに存在しない空白領域
  ——「セッション運営中のトレーナー自身の振る舞い（Part126）」と
  「骨格個人差から種目・ストローク幅を決める判断アルゴリズム（Part128）」——
  を独立スキルとして新設する。既存ファイルの改変は cj-advance の SKILL.md への参照指示追記のみに限定する。
done_when:
  - "DW1: `.claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md` が存在し、`## 講義一覧` 区間の表のヘッダ行が inputs I-2 の4列ヘッダと文字列完全一致し、パス列（4列目）に `cj advance/` 始まりの値を持つデータ行が**ちょうど86行**あり、その集合が I-1 の pinned tree から抽出した実ファイル集合（NFC 正規化・重複排除後86件）と `diff` で完全一致する"
  - "DW2: 索引の全データ行について、(a) 3列目（領域）がパス列の第2要素（ディレクトリ名）と文字列一致し、(b) 1列目（Part）がパス列に含まれる `Part[0-9]+` と文字列一致する（Part 番号を持たないファイルの行は `-`）、(c) 2列目（テーマ）が空でない、の3条件が**全行で**成立する"
  - "DW3: 索引に `## 既知の異常` の H2 が1本存在し、その区間に `Part100` / `NFD` / `87` / `86` の4文字列が全て逐語で含まれる（＝Unicode 正規化違いによる重複エントリが記録されている）"
  - "DW4: 索引に `## 更新方法` の H2 が1本存在し、その区間に行頭 `- ` または `{数字}. ` の行が3行以上あり、`1行` / `gh api` / `lecture-index.md` の3文字列が全て逐語で含まれる（毎週の更新が索引への1行追加で完結する運用が明文化されている）"
  - "DW5: `.claude/skills/クロニクルジャパンcj-advance/SKILL.md` の `## 参照リポジトリ` 区間に `references/lecture-index.md` を含む行が1行以上存在し、かつ base_commit d407efe から当該ファイルへの差分が**削除0行・追加3行以内**である（既存本文の改変が最小限に抑えられている）"
  - "DW6: `.claude/skills/personal-session-communication/SKILL.md` が存在し、frontmatter 内に `name: personal-session-communication` の行があり `description:` 行（1行）に I-4 の起動フレーズ6個が全て逐語（鍵括弧込み）で含まれ、I-4 の H2 7本が各1本ずつ存在し、`## 出典` 区間に Part126 のリポジトリ内パスが逐語で含まれ、I-4 の必須キーワード7個（`パーソナルスペース` / `斜め` / `笑顔` / `8本〜12本` / `30分` / `8分` / `アイスブレイク`）がファイル全体に全て含まれ、`## 段階別のセッション設計` 区間に `初回` と `2回目以降` が含まれ、`## 出典` と `## 既存スキルとの役割分担` を除く5つの H2 区間それぞれに行頭 `- ` の行が3行以上ある"
  - "DW7: `.claude/skills/skeletal-exercise-selection/SKILL.md` が存在し、frontmatter 内に `name: skeletal-exercise-selection` の行があり `description:` 行（1行）に I-5 の起動フレーズ6個が全て逐語で含まれ、I-5 の H2 7本が各1本ずつ存在し、`## 出典` 区間に Part128 のリポジトリ内パスが逐語で含まれ、`## 骨格の個人差を見る4つの視点` 区間に `腕の長さ` / `鎖骨の長さ` / `肩幅` / `胸椎` が全て含まれ、`## 判断アルゴリズム` 区間に行頭 `{数字}. ` の行が4行以上あり `スミス` / `ダンベル` / `マシン` が全て含まれ、`## 種目選択の判断` 区間に `|` 始まりの行が5行以上あり、ファイル全体に `モーメントアーム` / `水平内転` / `前突` が逐語で含まれる"
  - "DW8: 索引の `## スキル化済みの講義` 区間に I-8 の4行（Part122 / Part123 / Part126 / Part128）が各1行ずつ存在し、各行に書かれたスキルディレクトリが `test -d` で実在し、かつ新規2スキルの `## 出典` 区間に書かれた講義パスが索引の `## 講義一覧` のパス列に実在する"
  - "DW9: (a) `.claude/skills/personal-session-communication/` と `.claude/skills/skeletal-exercise-selection/` 配下に I-7 の禁止文字列10個のいずれかを含むファイルが0件であり、(b) base_commit d407efe からの追跡済み差分・作業ツリー差分・未追跡ファイルを合わせた全変更ファイル集合において、I-6 の allowlist に該当しないファイルが0件、かつ `.claude/skills/` 配下で本タスクの3ディレクトリと先行差分の2ディレクトリ以外のファイルが0件である"
```

---

## inputs（合意済み素材 / worker の唯一の正典）

> **本セクションが worker の参照すべき唯一の正典（source of truth）である。**
> **講義の中身は必ず `gh api` で実ファイルを読んでから書くこと。記憶や一般論で埋めてはならない。**

### I-1. 索引の対象集合（pinned tree からの機械抽出）

```yaml
TREE: 8164d0d992ed88d275498ccd56779f6eeb719375
対象: cj advance/ 配下の .md ファイル
除外: README.md / size が 1 バイト以下のプレースホルダ
正規化: NFC に正規化して重複排除
件数: 86（実測済み）
```

**正典となる抽出コマンド（この出力が索引の対象そのもの）**:

```bash
TREE=8164d0d992ed88d275498ccd56779f6eeb719375
NFC() { python3 -c "import sys,unicodedata;print('\n'.join(sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})))"; }
gh api "repos/younghastle3-source/training/git/trees/$TREE?recursive=1" \
  --jq '.tree[]|select(.type=="blob")|select(.size>1)|.path' \
  | grep '^cj advance/' | grep '\.md$' | grep -v '/README\.md$' | NFC
```

**領域（ディレクトリ）別の内訳（実測値・索引作成後の目視確認用）**:

| 領域 | 件数 |
|---|---|
| トレーニング学 | 46 |
| ハイパフォーマンス学 | 24 |
| 栄養生理学 | 6 |
| 1on1 | 4 |
| ポージング学 | 3 |
| 特典動画 | 1 |
| 神経系生理学 | 1 |
| 訓練学 | 1 |
| **合計** | **86** |

> Part 番号を持つファイル 58件 / 持たないファイル 28件（実測）。
> Part 番号は一意ではない（`Part109` が `トレーニング学` と `訓練学` に各1件ずつ存在する）ため、
> **Part 番号を主キーにしてはいけない**。索引の主キーはパスである。
> `cj advance/神経系生理学/README.`（拡張子なし・1バイト）は `.md` フィルタで除外される。

### I-2. 索引のフォーマット（`lecture-index.md`）

**パス**: `.claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md`

**必須の H2（各1本）**: `## 講義一覧` / `## スキル化済みの講義` / `## 既知の異常` / `## 更新方法`

**`## 講義一覧` の表ヘッダ（この1行と文字列完全一致させる）**:

```
| Part | テーマ | 領域 | パス |
```

区切り行は `|---|` を4個並べた行とする。データ行は以下の形式:

```
| Part128 | 大胸筋の徹底解説 | ハイパフォーマンス学 | cj advance/ハイパフォーマンス学/2026-08-21_Part128_大胸筋の徹底解説_YouTube.md |
| - | 機能解剖学から見る肩トレーニング | トレーニング学 | cj advance/トレーニング学/機能解剖学から見る肩トレーニング.md |
```

> - 1列目は `Part{数字}`（ファイル名に `Part[0-9]+` を含む場合）または `-`。
> - 3列目はパスの第2要素（ディレクトリ名）と**完全一致**させる。
> - 4列目は `cj advance/` から始まるリポジトリ内パス（前後にバッククォートを付けない。DW1 の照合が壊れる）。
> - **テーマ列に `|` を含めてはならない**（`awk -F'|'` の列位置がずれて DW1/DW2 が壊れる）。
> - 行の並びは任意（DW1 は集合として比較する）。

**表の生成コマンド（手打ち禁止・これで生成してから内容を整える）**:

```bash
TREE=8164d0d992ed88d275498ccd56779f6eeb719375
gh api "repos/younghastle3-source/training/git/trees/$TREE?recursive=1" \
  --jq '.tree[]|select(.type=="blob")|select(.size>1)|.path' \
  | grep '^cj advance/' | grep '\.md$' | grep -v '/README\.md$' \
  | python3 -c "
import sys,re,unicodedata
ps=sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})
for p in ps:
    area=p.split('/')[1]; fn=p.split('/')[-1][:-3]
    m=re.search(r'Part(\d+)',fn); part='Part'+m.group(1) if m else '-'
    theme=re.sub(r'^[\d\-_]*[【]?Part\d+[】]?[_\s]*','',fn).strip() or fn
    print('| %s | %s | %s | %s |'%(part,theme,area,p))
"
```

> テーマ列は生成結果をそのまま使ってよいが、`（前半）`/`（後半）` 等が落ちていないか、
> 明らかに読めない値（`ジョイント・バイ・ジョイント理論に基づく包括的コンディショニング（後ろ半`
> のようにファイル名側が途中で切れているもの）が無いかを目視で確認し、必要なら手で整える。
> **パス列だけは絶対に手で書き換えないこと**（DW1 が実データとの集合一致で検証する）。

### I-3. 既知の異常（`## 既知の異常` に必ず記録する）

```yaml
異常:
  対象: cj advance/トレーニング学/【Part100】ボディメイクvs機能改善.md
  症状: 同一サイズ（67575 バイト）の blob が git tree に2エントリ存在する
  原因: ファイル名の Unicode 正規化違い（NFC と NFD）。見た目は完全に同一
  影響: 生データは87エントリだが、NFC 正規化後の実体は86件
  対応: 本タスクでは索引側で NFC に正規化して1行に統合する。training 側の重複解消はスコープ外
```

> `## 既知の異常` 区間には `Part100` / `NFD` / `87` / `86` の4文字列を必ず含めること（DW3）。

### I-4. Part126 由来スキルの仕様（セッション運営コミュニケーション）

```yaml
パス: .claude/skills/personal-session-communication/SKILL.md
name: personal-session-communication
出典: cj advance/ハイパフォーマンス学/2026-08-21_Part126_パーソナルトレーニングや人間関係で疲れる時の対処法_YouTube.md
埋める空白: |
  既存11スキルは全て「知識（トレーニング理論・栄養・リハビリ）」か「発信（SNS・営業）」であり、
  パーソナルセッション中のトレーナー自身の振る舞い——目線配分・立ち位置・雑談・疲れない接客設計——
  を扱うスキルが存在しない。本スキルはその空白のみを埋める（トレーニング理論は書かない）。
```

**起動フレーズ（`description:` に逐語・鍵括弧込みで埋め込む6個）**

```
「セッション中の目線ってどうすればいい」
「パーソナルで疲れない接客を考えたい」
「初回セッションの進め方」
「クライアントとの雑談のネタ」
「立ち位置ってどこがいい」
「1日何本もセッションして疲れる」
```

> **`description:` は必ず1行で書く。** YAML の folded 記法（`description: >`）や literal 記法
> （`description: |`）で複数行に折り返すと DW6 の判定が継続行を拾えず全滅する
> （同じ罠を playbook-instagram-pdca-skill で実測済み）。
> `triggers:` リストにも同じ6フレーズを列挙する。

**必須の H2（各1本）**

```
## 出典
## 目線とアイコンタクトの設計
## 立ち位置とパーソナルスペース
## 段階別のセッション設計
## 雑談の設計
## 疲れないセッション運営
## 既存スキルとの役割分担
```

**必須キーワード（ファイル全体に逐語で含める7個 / 出典の実内容に対応）**

```
パーソナルスペース
斜め
笑顔
8本〜12本
30分
8分
アイスブレイク
```

> これらは出典ファイルに実在する記述に対応する（`8本〜12本` = 1日のセッション本数、
> `30分` / `8分` = 会話30分中に目を合わせるのは8分程度、`笑顔` = 相手が笑ったときは見る）。
> **一般論では書けない値であるため、「出典を実際に読んだか」の機械的な代理指標になる。**
> `## 段階別のセッション設計` には `初回` と `2回目以降` の両方を含める。

**執筆前に必ず実行する取得コマンド**

```bash
TREE=8164d0d992ed88d275498ccd56779f6eeb719375
P="cj advance/ハイパフォーマンス学/2026-08-21_Part126_パーソナルトレーニングや人間関係で疲れる時の対処法_YouTube.md"
gh api "repos/younghastle3-source/training/contents/$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$P")?ref=$TREE" --jq .content | base64 -d
```

### I-5. Part128 由来スキルの仕様（骨格個人差ベースの種目選択）

```yaml
パス: .claude/skills/skeletal-exercise-selection/SKILL.md
name: skeletal-exercise-selection
出典: cj advance/ハイパフォーマンス学/2026-08-21_Part128_大胸筋の徹底解説_YouTube.md
主目的: |
  大胸筋の解剖知識のダイジェストではなく、
  「腕の長さ・鎖骨の長さ・肩幅・胸椎の柔軟性 → ストローク幅の設定 → マシン/スミス vs ダンベルの選択」
  という判断アルゴリズムを抽出すること。
```

**起動フレーズ（`description:` に逐語・鍵括弧込みで埋め込む6個）**

```
「この骨格だとどの種目がいい」
「胸のトレーニングで肩に逃げる」
「ストローク幅どれくらい取ればいい」
「腕が長い人の胸トレ」
「マシンとダンベルどっちがいい」
「大胸筋上部が入らない」
```

**必須の H2（各1本）**

```
## 出典
## 骨格の個人差を見る4つの視点
## ストローク幅の設定
## 種目選択の判断
## 判断アルゴリズム
## 適用範囲と限界
## 既存スキルとの役割分担
```

**各セクションの必須内容**

| セクション | 機械検証される条件 |
|---|---|
| `## 骨格の個人差を見る4つの視点` | `腕の長さ` / `鎖骨の長さ` / `肩幅` / `胸椎` の4語を全て含む |
| `## 判断アルゴリズム` | 行頭 `{数字}. ` の手順が4行以上、`スミス` / `ダンベル` / `マシン` を全て含む |
| `## 種目選択の判断` | `\|` 始まりの表の行が5行以上（ヘッダ＋区切り＋3行以上） |
| ファイル全体 | `モーメントアーム` / `水平内転` / `前突` を逐語で含む |

> `モーメントアーム` / `水平内転` / `前突` は出典に実在する用語であり、
> 出典を読まずに書くと出てこない。「実際に読んだか」の代理指標。
> `## 適用範囲と限界` には「この判断アルゴリズムが大胸筋の講義から抽出されたものであること」
> 「骨格はトレーニングで変えられないこと」を書く。

**執筆前に必ず実行する取得コマンド**

```bash
TREE=8164d0d992ed88d275498ccd56779f6eeb719375
P="cj advance/ハイパフォーマンス学/2026-08-21_Part128_大胸筋の徹底解説_YouTube.md"
gh api "repos/younghastle3-source/training/contents/$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$P")?ref=$TREE" --jq .content | base64 -d
```

### I-6. DW9(b) 回帰検証の allowlist

**本タスクで変更してよいファイル（NEW）**

```
^\.claude/skills/クロニクルジャパンcj-advance/
^\.claude/skills/personal-session-communication/
^\.claude/skills/skeletal-exercise-selection/
^plan/playbook-cj-advance-skill-expansion\.md$
^state\.md$
^docs/repository-map\.yaml$
```

**本タスク開始前から作業ツリーに存在した先行の未コミット差分（PRE / 15件）**

```
^\.claude/agents/critic\.md$
^\.claude/settings\.json$
^\.claude/skills/instagram-pdca/
^\.claude/skills/video-editing-ffmpeg/
^plan/playbook-setup-instagram-skills\.md$
^tmp/
```

> PRE の実体（`git -c core.quotepath=false status --porcelain` で実測、2026-08-25）:
> `M .claude/agents/critic.md` / `M .claude/settings.json` /
> `M .claude/skills/instagram-pdca/SKILL.md` / `M .../references/format-guide.md` /
> `M .../references/my-posts-log.md` / `M .../references/pattern-library.md` /
> `M .claude/skills/video-editing-ffmpeg/SKILL.md` / `M .../references/ffmpeg-pitfalls.md` /
> `M .../scripts/concat_clips.sh` / `M state.md` / `D tmp/AI×営業.html` /
> `?? .claude/skills/instagram-pdca/references/hook-design.md` /
> `?? .claude/skills/instagram-pdca/references/research-method.md` /
> `?? .claude/skills/video-editing-ffmpeg/references/shooting-basics.md` /
> `?? plan/playbook-setup-instagram-skills.md`
>
> **PRE は本タスクの成果物ではない。allowlist には含めるが、絶対にコミットしない**（ft3）。
> `state.md` は NEW にも PRE にも現れるが、本タスクで playbook 情報を更新するため NEW 扱いでコミットする。

### I-7. 禁止文字列（新規2スキル配下に出現してはならない / 10個）

```
TBD
TODO
FIXME
後で書く
CJ Advance トレーニングシステム
起始・停止
島田
ピリオダイゼーション
ミールプラン
ポージング
```

> **意図**:
> - 前半4個は「見出しと箇条書きの体裁だけ整えて中身を空にする」逃げ道を塞ぐ。
> - `CJ Advance トレーニングシステム` は既存 `クロニクルジャパンcj-advance/SKILL.md` の H1。
>   全文コピーによる二重管理を検出する。
> - `起始・停止` は Part128 の解剖パートの見出し。**本スキルの主目的は解剖知識ではなく
>   判断アルゴリズムの抽出**であるため、解剖ダイジェスト化すると検出される。
> - `島田` は出典に登場する個人名。事例の写経を防ぐ。
> - `ピリオダイゼーション` / `ミールプラン` / `ポージング` は既存 cj-advance スキルが
>   担当する領域。新規スキルが「もう一つの広く浅いダイジェスト」に膨らむのを防ぐ。
>
> 参照したい場合はファイルパスへのポインタで示し、内容を写経しないこと。

### I-8. `## スキル化済みの講義` の内容（索引 ↔ スキルの相互参照）

```
| Part | スキル |
|---|---|
| Part122 | .claude/skills/速筋遅筋-weight-training-theory/ |
| Part123 | .claude/skills/shoulder-pain-rehabilitation/ |
| Part126 | .claude/skills/personal-session-communication/ |
| Part128 | .claude/skills/skeletal-exercise-selection/ |
```

> Part122 → 速筋遅筋 / Part123 → shoulder-pain-rehabilitation の対応は
> 各 SKILL.md の末尾に出典として実在することを実測確認済み。
> **p1 の時点では Part122 / Part123 の2行のみを書き、p2 で Part126 行、p3 で Part128 行を追記する**
> （索引を「毎週の更新ハブ」として機能させるための運用の型を、本タスク自身で1周させる）。
> 各行の2列目のディレクトリは `test -d` で実在検証される（DW8）。

---

## スコープ外（本タスクでは扱わない）

> **以下は「やらない」と明示的に合意済み。着手したら DW9(b) の回帰検証で FAIL する。**

```yaml
統合作業（別 playbook で扱う）:
  - Part111（現場で多い3大トラブル）を shoulder-pain-rehabilitation に統合する作業
  - Part127（パーソナル業界・資格・経営）を おっくん哲学self-coaching に統合する作業
  - Part91 / Part92（下肢・上半身のストレッチ）を クロニクルジャパンcj-advance に統合する作業

内容の扱いを決めない領域:
  - ポージング学（3本）の扱い
  - 1on1 面談ログ（4本）の扱い
  ※ ただし「索引に行として載せる」ことはスコープ内（I-1 の86件に含まれる）。
     載せないのは「その内容をスキル化する判断」。

その他:
  - 既存の未コミット変更15件（I-6 の PRE）の整理・コミット
  - training リポジトリ側の Part100 重複エントリの解消
  - 既存5スキル（cj-advance / 速筋遅筋 / shoulder-pain / hyrox-supplementary / サムSGIR）の本文改訂
    ※ 唯一の例外は cj-advance/SKILL.md の参照指示への「追加3行以内」の追記（DW5）
```

---

## phases

### p1: 講義索引の作成

**goal**: `lecture-index.md` に86本の講義の「Part 番号 / テーマ / 領域 / パス」を実データと一致する形で載せ、cj-advance スキルから最初に参照される導線を作る

#### subtasks

- [ ] **p1.1**: `.claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md` が存在し、`## 講義一覧` / `## スキル化済みの講義` / `## 既知の異常` / `## 更新方法` の H2 が各1本ずつ存在し、`## 講義一覧` 区間の先頭の表ヘッダが I-2 の4列ヘッダと文字列完全一致する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    test -f "$F" || { echo "FAIL nofile"; exit 0; }
    for H in 講義一覧 スキル化済みの講義 既知の異常 更新方法; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    HDR=$(SEC "$F" "^## 講義一覧\$" | grep '^|' | head -1)
    [ "$HDR" = '| Part | テーマ | 領域 | パス |' ] || M="$M header;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "4つの H2 が重複なく各1本ずつ検出でき、ヘッダ行が文字列完全一致で照合される"
    - consistency: "ヘッダの列順（Part / テーマ / 領域 / パス）が I-2 の規約と一致し、p1.2・p1.3 の awk 列位置（$2/$4/$5）の前提が成立する"
    - completeness: "索引・スキル対応・既知の異常・更新運用の4セクションが揃っている"

- [ ] **p1.2**: `## 講義一覧` のパス列の集合が、I-1 の pinned tree から抽出した実ファイル集合（NFC 正規化後86件）と `diff` で完全一致する
  - executor: claudecode
  - test_command: |
    TREE=8164d0d992ed88d275498ccd56779f6eeb719375
    NFC() { python3 -c "import sys,unicodedata;print('\n'.join(sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})))"; }
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    gh api "repos/younghastle3-source/training/git/trees/$TREE?recursive=1" \
      --jq '.tree[]|select(.type=="blob")|select(.size>1)|.path' \
      | grep '^cj advance/' | grep '\.md$' | grep -v '/README\.md$' | NFC > /tmp/cj_expect.txt
    awk -F'|' '/^\|/{gsub(/^ +| +$/,"",$5); print $5}' "$F" | grep '^cj advance/' | NFC > /tmp/cj_actual.txt
    E=$(grep -c . /tmp/cj_expect.txt); N=$(grep -c . /tmp/cj_actual.txt)
    [ "$E" -eq 86 ] || M="$M expect:$E(want86);"
    [ "$N" -eq 86 ] || M="$M rows:$N(want86);"
    diff /tmp/cj_expect.txt /tmp/cj_actual.txt > /dev/null || { M="$M setmismatch;"; diff /tmp/cj_expect.txt /tmp/cj_actual.txt | head -10; }
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "1行削除すると `rows:85(want86); setmismatch;` で FAIL する（デコイ D1 で実測済み）。NFD で書かれた行は NFC 正規化で吸収され偽 FAIL にならない（デコイ D4 で実測済み）"
    - consistency: "期待値をハードコードせず pinned tree の実データから毎回生成しているため、索引と実リポジトリの乖離を直接検出する"
    - completeness: "件数（86）と集合一致（diff）の両方を検証しており、行数だけ合わせた別集合では PASS しない"

- [ ] **p1.3**: 全データ行で 領域列＝パスの第2要素、Part 列＝ファイル名の `Part[0-9]+`（無い場合は `-`）、テーマ列が空でない、の3条件が成立する
  - executor: claudecode
  - test_command: |
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    BAD=$(awk -F'|' '/^\|/{
      for(i=2;i<=5;i++){gsub(/^ +| +$/,"",$i)}
      if($5 ~ /^cj advance\//){
        split($5,a,"/");
        if(a[2]!=$4) print "area:" $5;
        if(match($5,/Part[0-9]+/)) n=substr($5,RSTART,RLENGTH); else n="-";
        if(n!=$2) print "part:" $2 "!=" n;
        if($3=="") print "theme:" $5;
      }}' "$F")
    [ -z "$BAD" ] && echo PASS || { echo "FAIL"; echo "$BAD" | head -10; }
  - validations:
    - technical: "領域列を改竄すると `area:{パス}`、Part 番号を改竄すると `part:Part129!=Part128` を出力して FAIL する（デコイ D2/D3 で実測済み）"
    - consistency: "領域列・Part 列がパス列から機械的に導出可能な値と一致しており、3列の間に矛盾が無い"
    - completeness: "86行すべてを走査し、3条件を同時に検証している"

- [ ] **p1.4**: `## 既知の異常` に Part100 の重複が（`Part100` / `NFD` / `87` / `86` を含む形で）記録され、`## 更新方法` に週次更新の手順が3行以上（`1行` / `gh api` / `lecture-index.md` を含む形で）記載されている
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    B=$(SEC "$F" "^## 既知の異常\$")
    for P in "Part100" "NFD" "87" "86"; do echo "$B" | grep -qF -- "$P" || M="$M anom:$P;"; done
    B2=$(SEC "$F" "^## 更新方法\$")
    [ "$(echo "$B2" | grep -cE '^(- |[0-9]+[.] ).+')" -ge 3 ] || M="$M steps;"
    for P in "1行" "gh api" "lecture-index.md"; do echo "$B2" | grep -qF -- "$P" || M="$M howto:$P;"; done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "区間限定の逐語照合であり、他セクションへの記載では PASS しない"
    - consistency: "記録される件数（87 生エントリ / 86 実体）が I-1・I-3 の実測値と一致している"
    - completeness: "既知の異常の記録と、毎週の更新運用（1行追加）の明文化が両方揃っている"

- [ ] **p1.5**: `クロニクルジャパンcj-advance/SKILL.md` の `## 参照リポジトリ` 区間に `references/lecture-index.md` への参照が追記され、base_commit からの差分が削除0行・追加3行以内である
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=".claude/skills/クロニクルジャパンcj-advance/SKILL.md"; M=""
    SEC "$F" "^## 参照リポジトリ" | grep -qF 'references/lecture-index.md' || M="$M noref;"
    NS=$(git -c core.quotepath=false diff --numstat d407efe -- "$F")
    A=$(echo "$NS" | awk '{print $1}'); D=$(echo "$NS" | awk '{print $2}')
    [ -n "$A" ] || { A=0; D=0; M="$M nodiff;"; }
    [ "$D" -eq 0 ] || M="$M deleted:$D;"
    [ "$A" -le 3 ] || M="$M added:$A(max3);"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "`git diff --numstat` は純粋な追記で `1 0`、1行でも書き換えると `1 1` を返す（scratchpad の複製に対し `git diff --no-index --numstat` で実測済み）。base_commit 起点なので Phase 途中でコミットしても判定が変わらない"
    - consistency: "参照指示の追記先が既存の `## 参照リポジトリ（GitHub・おっくん自身のナレッジ）` 節（既存の1〜3の手順リスト）であり、他の5スキルの参照指示と同じ場所に置かれる"
    - completeness: "『索引へのリンクが入っている』と『既存本文を壊していない』の両方を検証している"

- [ ] **p1.6**: `## スキル化済みの講義` に I-8 の Part122 / Part123 の2行が存在し、参照先のスキルディレクトリが実在する
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    B=$(SEC "$F" "^## スキル化済みの講義\$")
    for T in "Part122 .claude/skills/速筋遅筋-weight-training-theory/" \
             "Part123 .claude/skills/shoulder-pain-rehabilitation/"; do
      ID=${T% *}; DIR=${T#* }
      R=$(echo "$B" | grep -cF "| $ID |"); [ "$R" -eq 1 ] || { M="$M row:$ID($R);"; continue; }
      echo "$B" | grep -F "| $ID |" | grep -qF "$DIR" || M="$M dir:$ID;"
      test -d "$DIR" || M="$M nodir:$DIR;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "行の存在（ちょうど1行）とディレクトリの実在（`test -d`）を同時に検証しており、存在しないスキルへのリンクでは PASS しない"
    - consistency: "Part122 → 速筋遅筋 / Part123 → shoulder-pain の対応が各 SKILL.md 末尾の出典記載（実測確認済み）と一致している"
    - completeness: "p2 / p3 で行を追加していく運用の土台（表の枠と既存2行）が揃っている"

**status**: pending
**max_iterations**: 5
**time_limit**: 45min
**priority**: high

---

### p2: セッション運営コミュニケーションスキルの新規作成（Part126）

**goal**: パーソナルセッション中のトレーナー自身の振る舞い（目線配分・立ち位置・雑談・疲れない接客設計）を扱う `personal-session-communication` スキルを新設する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: `.claude/skills/personal-session-communication/SKILL.md` の frontmatter に `name: personal-session-communication` があり、`description:`（1行）に I-4 の起動フレーズ6個が全て逐語で含まれ、`triggers:` の項目が5個以上ある
  - executor: claudecode
  - prerequisites: "I-4 の取得コマンドで Part126 の全文（115行）を読んでから書くこと"
  - test_command: |
    F=.claude/skills/personal-session-communication/SKILL.md; M=""
    test -f "$F" || { echo "FAIL nofile"; exit 0; }
    head -1 "$F" | grep -qx -- '---' || M="$M nofrontmatter;"
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$F")
    echo "$FM" | grep -qx 'name: personal-session-communication' || M="$M name;"
    D=$(echo "$FM" | grep '^description:'); [ -n "$D" ] || M="$M nodesc;"
    for P in "「セッション中の目線ってどうすればいい」" "「パーソナルで疲れない接客を考えたい」" \
             "「初回セッションの進め方」" "「クライアントとの雑談のネタ」" \
             "「立ち位置ってどこがいい」" "「1日何本もセッションして疲れる」"; do
      echo "$D" | grep -qF -- "$P" || M="$M phrase:$P;"
    done
    [ "$(echo "$FM" | grep -cE '^  - .+')" -ge 5 ] || M="$M triggers;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "frontmatter を1行目の `---` から次の `---` までに限定して抽出しており、本文への記載では PASS しない。`description` を折り返すと6フレーズが全て検出できず FAIL する"
    - consistency: "`name` がディレクトリ名 `personal-session-communication` と一致し、既存スキル（cj-advance 等）の frontmatter 書式（name / description / triggers）と揃っている"
    - completeness: "起動フレーズ6個が description と triggers の両方から起動可能になっている"

- [ ] **p2.2**: I-4 の H2 7本が各1本ずつ存在し、`## 出典` と `## 既存スキルとの役割分担` を除く5区間それぞれに行頭 `- ` の行が3行以上ある
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/personal-session-communication/SKILL.md; M=""
    for H in 出典 目線とアイコンタクトの設計 立ち位置とパーソナルスペース 段階別のセッション設計 \
             雑談の設計 疲れないセッション運営 既存スキルとの役割分担; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    for H in 目線とアイコンタクトの設計 立ち位置とパーソナルスペース 段階別のセッション設計 \
             雑談の設計 疲れないセッション運営; do
      [ "$(SEC "$F" "^## $H\$" | grep -cE '^- .+')" -ge 3 ] || M="$M lines:$H;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "見出しだけ作って中身を空にすると `lines:{見出し}` で FAIL する"
    - consistency: "セクション構成が I-4 と逐語一致しており、p_final.6（DW6）と同じ見出し文字列で照合される"
    - completeness: "出典・実務5領域・役割分担の7セクションが揃い、実務5領域それぞれが3行以上の実体を持つ"

- [ ] **p2.3**: `## 出典` 区間に Part126 のリポジトリ内パスと `github.com/younghastle3-source/training` が逐語で含まれ、I-4 の必須キーワード7個がファイル全体に含まれ、`## 段階別のセッション設計` 区間に `初回` と `2回目以降` が含まれる
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/personal-session-communication/SKILL.md; M=""
    B=$(SEC "$F" "^## 出典\$")
    echo "$B" | grep -qF -- "cj advance/ハイパフォーマンス学/2026-08-21_Part126_パーソナルトレーニングや人間関係で疲れる時の対処法_YouTube.md" || M="$M srcpath;"
    echo "$B" | grep -qF -- "github.com/younghastle3-source/training" || M="$M srcrepo;"
    for P in "パーソナルスペース" "斜め" "笑顔" "8本〜12本" "30分" "8分" "アイスブレイク"; do
      grep -qF -- "$P" "$F" || M="$M kw:$P;"
    done
    B2=$(SEC "$F" "^## 段階別のセッション設計\$")
    for P in "初回" "2回目以降"; do echo "$B2" | grep -qF -- "$P" || M="$M stage:$P;"; done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "`8本〜12本` / `30分` / `8分` は出典を読まなければ書けない値であり、『出典を読まずに一般論で書いた』場合に FAIL する代理指標として機能する"
    - consistency: "出典パスが p1 で作成した索引の `## 講義一覧` のパス列に実在する値と同一（DW8 で相互検証される）"
    - completeness: "出典の明示・実内容の反映・段階別設計の3点が揃っている"

- [ ] **p2.4**: 索引の `## スキル化済みの講義` に Part126 の行が追加され、新規スキル配下に I-7 の禁止文字列10個を含むファイルが0件である
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    IDX=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    B=$(SEC "$IDX" "^## スキル化済みの講義\$")
    R=$(echo "$B" | grep -cF "| Part126 |"); [ "$R" -eq 1 ] || M="$M row:$R;"
    echo "$B" | grep -F "| Part126 |" | grep -qF ".claude/skills/personal-session-communication/" || M="$M dir;"
    test -d .claude/skills/personal-session-communication || M="$M nodir;"
    for P in "TBD" "TODO" "FIXME" "後で書く" "CJ Advance トレーニングシステム" "起始・停止" "島田" \
             "ピリオダイゼーション" "ミールプラン" "ポージング"; do
      N=$(grep -rlF -- "$P" .claude/skills/personal-session-communication 2>/dev/null | wc -l | tr -d ' ')
      [ "$N" -eq 0 ] || M="$M ban:$P;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "禁止文字列を1つでも書くと `ban:{文字列}` で FAIL する。プレースホルダで体裁だけ整える逃げ道も塞がれている"
    - consistency: "索引が『毎週の更新ハブ』として機能する運用（新スキルを作ったら索引に1行追加）が本タスク内で1周している"
    - completeness: "索引への登録・ディレクトリの実在・写経とプレースホルダの不在を同時に検証している"

**status**: pending
**max_iterations**: 5
**time_limit**: 45min
**priority**: high

---

### p3: 骨格個人差ベースの種目選択スキルの新規作成（Part128）

**goal**: 「骨格の個人差 → ストローク幅の設定 → マシン/スミス vs ダンベルの選択」という判断アルゴリズムを抽出した `skeletal-exercise-selection` スキルを新設する

**depends_on**: [p1]

#### subtasks

- [ ] **p3.1**: `.claude/skills/skeletal-exercise-selection/SKILL.md` の frontmatter に `name: skeletal-exercise-selection` があり、`description:`（1行）に I-5 の起動フレーズ6個が全て逐語で含まれ、`triggers:` の項目が5個以上ある
  - executor: claudecode
  - prerequisites: "I-5 の取得コマンドで Part128 の全文（112行）を読んでから書くこと"
  - test_command: |
    F=.claude/skills/skeletal-exercise-selection/SKILL.md; M=""
    test -f "$F" || { echo "FAIL nofile"; exit 0; }
    head -1 "$F" | grep -qx -- '---' || M="$M nofrontmatter;"
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$F")
    echo "$FM" | grep -qx 'name: skeletal-exercise-selection' || M="$M name;"
    D=$(echo "$FM" | grep '^description:'); [ -n "$D" ] || M="$M nodesc;"
    for P in "「この骨格だとどの種目がいい」" "「胸のトレーニングで肩に逃げる」" \
             "「ストローク幅どれくらい取ればいい」" "「腕が長い人の胸トレ」" \
             "「マシンとダンベルどっちがいい」" "「大胸筋上部が入らない」"; do
      echo "$D" | grep -qF -- "$P" || M="$M phrase:$P;"
    done
    [ "$(echo "$FM" | grep -cE '^  - .+')" -ge 5 ] || M="$M triggers;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "frontmatter 限定抽出＋逐語照合。`description` の折り返しでは PASS しない"
    - consistency: "`name` がディレクトリ名と一致し、既存スキルの frontmatter 書式と揃っている"
    - completeness: "6フレーズが description と triggers の両方に入っている"

- [ ] **p3.2**: I-5 の H2 7本が各1本ずつ存在し、`## 骨格の個人差を見る4つの視点` 区間に4視点の語が全て含まれる
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/skeletal-exercise-selection/SKILL.md; M=""
    for H in 出典 骨格の個人差を見る4つの視点 ストローク幅の設定 種目選択の判断 判断アルゴリズム \
             適用範囲と限界 既存スキルとの役割分担; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    B=$(SEC "$F" "^## 骨格の個人差を見る4つの視点\$")
    for P in "腕の長さ" "鎖骨の長さ" "肩幅" "胸椎"; do
      echo "$B" | grep -qF -- "$P" || M="$M view:$P;"
    done
    [ "$(echo "$B" | grep -cE '^(- |\|).+')" -ge 4 ] || M="$M viewlines;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "4視点のいずれかを落とすと `view:{語}` で FAIL する。区間限定なので他セクションへの記載では PASS しない"
    - consistency: "4視点が出典（Part128 の『骨格による個人差』『まとめ』）に実在する要素と一致している"
    - completeness: "7セクションの存在と、4視点それぞれの記載（箇条書き or 表で4行以上）を検証している"

- [ ] **p3.3**: `## 判断アルゴリズム` に4ステップ以上の番号付き手順があり `スミス`/`ダンベル`/`マシン` を全て含み、`## 種目選択の判断` に `|` 始まりの行が5行以上あり、ファイル全体に `モーメントアーム`/`水平内転`/`前突` が含まれる
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/skeletal-exercise-selection/SKILL.md; M=""
    B=$(SEC "$F" "^## 判断アルゴリズム\$")
    [ "$(echo "$B" | grep -cE '^[0-9]+[.] .+')" -ge 4 ] || M="$M steps;"
    for P in "スミス" "ダンベル" "マシン"; do echo "$B" | grep -qF -- "$P" || M="$M algo:$P;"; done
    B2=$(SEC "$F" "^## 種目選択の判断\$")
    [ "$(echo "$B2" | grep -c '^|')" -ge 5 ] || M="$M table;"
    B3=$(SEC "$F" "^## ストローク幅の設定\$")
    [ "$(echo "$B3" | grep -cF 'ストローク')" -ge 2 ] || M="$M stroke;"
    for P in "モーメントアーム" "水平内転" "前突"; do grep -qF -- "$P" "$F" || M="$M term:$P;"; done
    B4=$(SEC "$F" "^## 出典\$")
    echo "$B4" | grep -qF -- "cj advance/ハイパフォーマンス学/2026-08-21_Part128_大胸筋の徹底解説_YouTube.md" || M="$M srcpath;"
    echo "$B4" | grep -qF -- "github.com/younghastle3-source/training" || M="$M srcrepo;"
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "`モーメントアーム` / `水平内転` / `前突` は出典を読まなければ出てこない用語であり、『読まずに一般論で書いた』場合に `term:{語}` で FAIL する"
    - consistency: "判断アルゴリズムが4視点（p3.2）→ ストローク幅 → 種目選択という主目的の流れを踏んでおり、出典パスは索引のパス列と同一値（DW8 で相互検証）"
    - completeness: "アルゴリズム（手順）・種目選択（表）・ストローク幅・出典明示の4点が揃っている"

- [ ] **p3.4**: 索引の `## スキル化済みの講義` に Part128 の行が追加され、新規スキル配下に I-7 の禁止文字列10個を含むファイルが0件である
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    IDX=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    B=$(SEC "$IDX" "^## スキル化済みの講義\$")
    R=$(echo "$B" | grep -cF "| Part128 |"); [ "$R" -eq 1 ] || M="$M row:$R;"
    echo "$B" | grep -F "| Part128 |" | grep -qF ".claude/skills/skeletal-exercise-selection/" || M="$M dir;"
    test -d .claude/skills/skeletal-exercise-selection || M="$M nodir;"
    for P in "TBD" "TODO" "FIXME" "後で書く" "CJ Advance トレーニングシステム" "起始・停止" "島田" \
             "ピリオダイゼーション" "ミールプラン" "ポージング"; do
      N=$(grep -rlF -- "$P" .claude/skills/skeletal-exercise-selection 2>/dev/null | wc -l | tr -d ' ')
      [ "$N" -eq 0 ] || M="$M ban:$P;"
    done
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - validations:
    - technical: "`起始・停止` を書くと FAIL するため、『大胸筋の解剖ダイジェスト』に流れた場合に検出される"
    - consistency: "索引の `## スキル化済みの講義` が I-8 の4行構成に到達する（p1 で2行 → p2 で3行 → p3 で4行）"
    - completeness: "索引登録・ディレクトリ実在・禁止文字列の不在を同時に検証している"

**status**: pending
**max_iterations**: 5
**time_limit**: 45min
**priority**: medium

---

### p_final: 完了検証（必須）

> **playbook の done_when（DW1〜DW9）が実際に満たされているか最終検証する。**
> **DW9(b) は git 状態に依存するため、ft1〜ft3 の実行後に単独で再実行すること。**
> **DW1 / DW8 はネットワーク（`gh api`）を使用する。**

#### subtasks

- [ ] **p_final.1**: DW1 が満たされている（索引が実データと集合一致・86行）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    NFC() { python3 -c "import sys,unicodedata;print('\n'.join(sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})))"; }
    TREE=8164d0d992ed88d275498ccd56779f6eeb719375
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    test -f "$F" || { echo "DW1 FAIL nofile"; exit 0; }
    [ "$(grep -c '^## 講義一覧$' "$F")" -eq 1 ] || M="$M h2;"
    HDR=$(SEC "$F" "^## 講義一覧\$" | grep '^|' | head -1)
    [ "$HDR" = '| Part | テーマ | 領域 | パス |' ] || M="$M header;"
    gh api "repos/younghastle3-source/training/git/trees/$TREE?recursive=1" \
      --jq '.tree[]|select(.type=="blob")|select(.size>1)|.path' \
      | grep '^cj advance/' | grep '\.md$' | grep -v '/README\.md$' | NFC > /tmp/cj_expect.txt
    awk -F'|' '/^\|/{gsub(/^ +| +$/,"",$5); print $5}' "$F" | grep '^cj advance/' | NFC > /tmp/cj_actual.txt
    E=$(grep -c . /tmp/cj_expect.txt); N=$(grep -c . /tmp/cj_actual.txt)
    [ "$E" -eq 86 ] || M="$M expect:$E(want86);"
    [ "$N" -eq 86 ] || M="$M rows:$N(want86);"
    diff /tmp/cj_expect.txt /tmp/cj_actual.txt > /dev/null || M="$M setmismatch;"
    [ -z "$M" ] && echo "DW1 PASS" || echo "DW1 FAIL$M"
  - validations:
    - technical: "p1.2 と同一の抽出・正規化ロジックであり、Phase 判定と完了判定が乖離しない。デコイ D1（1行削除）で FAIL、D4（NFD 表記）で PASS を実測済み"
    - consistency: "期待値は pinned tree の実データから毎回生成され、ハードコードされた86はその件数チェックにのみ使われる"
    - completeness: "ヘッダ・件数・集合一致の3点を検証している"

- [ ] **p_final.2**: DW2 が満たされている（領域列・Part 列・テーマ列の整合）
  - executor: claudecode
  - test_command: |
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"
    BAD=$(awk -F'|' '/^\|/{
      for(i=2;i<=5;i++){gsub(/^ +| +$/,"",$i)}
      if($5 ~ /^cj advance\//){
        split($5,a,"/");
        if(a[2]!=$4) print "area:" $5;
        if(match($5,/Part[0-9]+/)) n=substr($5,RSTART,RLENGTH); else n="-";
        if(n!=$2) print "part:" $2 "!=" n;
        if($3=="") print "theme:" $5;
      }}' "$F")
    [ -z "$BAD" ] && echo "DW2 PASS" || { echo "DW2 FAIL"; echo "$BAD" | head -10; }
  - validations:
    - technical: "デコイ D2（領域列の改竄）/ D3（Part 番号の改竄）で FAIL を実測済み"
    - consistency: "p1.3 と同一ロジック"
    - completeness: "86行 × 3条件を全走査している"

- [ ] **p_final.3**: DW3 が満たされている（Part100 重複の記録）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    [ "$(grep -c '^## 既知の異常$' "$F")" -eq 1 ] || M="$M h2;"
    B=$(SEC "$F" "^## 既知の異常\$")
    for P in "Part100" "NFD" "87" "86"; do echo "$B" | grep -qF -- "$P" || M="$M miss:$P;"; done
    [ -z "$M" ] && echo "DW3 PASS" || echo "DW3 FAIL$M"
  - validations:
    - technical: "区間限定の逐語照合。見出しを消すと `h2;` と全 `miss:` が同時に出る"
    - consistency: "記録内容が I-3 の実測値（87 生エントリ / 86 実体）と一致"
    - completeness: "対象・原因（NFD）・件数の3要素が記録されている"

- [ ] **p_final.4**: DW4 が満たされている（週次更新運用の明文化）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    [ "$(grep -c '^## 更新方法$' "$F")" -eq 1 ] || M="$M h2;"
    B=$(SEC "$F" "^## 更新方法\$")
    [ "$(echo "$B" | grep -cE '^(- |[0-9]+[.] ).+')" -ge 3 ] || M="$M steps;"
    for P in "1行" "gh api" "lecture-index.md"; do echo "$B" | grep -qF -- "$P" || M="$M miss:$P;"; done
    [ -z "$M" ] && echo "DW4 PASS" || echo "DW4 FAIL$M"
  - validations:
    - technical: "手順3行以上と3つの逐語文字列を同時に検証している"
    - consistency: "p1.4 と同一ロジック"
    - completeness: "『毎週の更新が索引への1行追加で済む』運用が読める形で書かれている"

- [ ] **p_final.5**: DW5 が満たされている（cj-advance SKILL.md への最小追記）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=".claude/skills/クロニクルジャパンcj-advance/SKILL.md"; M=""
    SEC "$F" "^## 参照リポジトリ" | grep -qF 'references/lecture-index.md' || M="$M noref;"
    NS=$(git -c core.quotepath=false diff --numstat d407efe -- "$F")
    A=$(echo "$NS" | awk '{print $1}'); D=$(echo "$NS" | awk '{print $2}')
    [ -n "$A" ] || { A=0; D=0; M="$M nodiff;"; }
    [ "$D" -eq 0 ] || M="$M deleted:$D;"
    [ "$A" -le 3 ] || M="$M added:$A(max3);"
    [ -z "$M" ] && echo "DW5 PASS" || echo "DW5 FAIL$M"
  - validations:
    - technical: "純粋な追記は `1 0`、既存行の書き換えは `1 1` を返すことを実測済み。base_commit 起点なのでコミット後も判定が変わらない"
    - consistency: "p1.5 と同一ロジック"
    - completeness: "参照導線の追加と既存本文の非破壊を両方検証している"

- [ ] **p_final.6**: DW6 が満たされている（Part126 由来スキルの完全性）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/personal-session-communication/SKILL.md; M=""
    test -f "$F" || { echo "DW6 FAIL nofile"; exit 0; }
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$F")
    echo "$FM" | grep -qx 'name: personal-session-communication' || M="$M name;"
    D=$(echo "$FM" | grep '^description:')
    for P in "「セッション中の目線ってどうすればいい」" "「パーソナルで疲れない接客を考えたい」" \
             "「初回セッションの進め方」" "「クライアントとの雑談のネタ」" \
             "「立ち位置ってどこがいい」" "「1日何本もセッションして疲れる」"; do
      echo "$D" | grep -qF -- "$P" || M="$M phrase:$P;"
    done
    for H in 出典 目線とアイコンタクトの設計 立ち位置とパーソナルスペース 段階別のセッション設計 \
             雑談の設計 疲れないセッション運営 既存スキルとの役割分担; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    for H in 目線とアイコンタクトの設計 立ち位置とパーソナルスペース 段階別のセッション設計 \
             雑談の設計 疲れないセッション運営; do
      [ "$(SEC "$F" "^## $H\$" | grep -cE '^- .+')" -ge 3 ] || M="$M lines:$H;"
    done
    SEC "$F" "^## 出典\$" | grep -qF -- "cj advance/ハイパフォーマンス学/2026-08-21_Part126_パーソナルトレーニングや人間関係で疲れる時の対処法_YouTube.md" || M="$M srcpath;"
    for P in "パーソナルスペース" "斜め" "笑顔" "8本〜12本" "30分" "8分" "アイスブレイク"; do
      grep -qF -- "$P" "$F" || M="$M kw:$P;"
    done
    B=$(SEC "$F" "^## 段階別のセッション設計\$")
    for P in "初回" "2回目以降"; do echo "$B" | grep -qF -- "$P" || M="$M stage:$P;"; done
    [ -z "$M" ] && echo "DW6 PASS" || echo "DW6 FAIL$M"
  - validations:
    - technical: "p2.1〜p2.3 の判定を統合しており、同一の閾値・同一の逐語文字列を使っている"
    - consistency: "出典パスが索引のパス列と同一値であることは p_final.8（DW8）で相互検証される"
    - completeness: "frontmatter・7セクション・実体3行以上・出典・必須7キーワード・段階別の全項目を検証している"

- [ ] **p_final.7**: DW7 が満たされている（Part128 由来スキルの完全性）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    F=.claude/skills/skeletal-exercise-selection/SKILL.md; M=""
    test -f "$F" || { echo "DW7 FAIL nofile"; exit 0; }
    FM=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$F")
    echo "$FM" | grep -qx 'name: skeletal-exercise-selection' || M="$M name;"
    D=$(echo "$FM" | grep '^description:')
    for P in "「この骨格だとどの種目がいい」" "「胸のトレーニングで肩に逃げる」" \
             "「ストローク幅どれくらい取ればいい」" "「腕が長い人の胸トレ」" \
             "「マシンとダンベルどっちがいい」" "「大胸筋上部が入らない」"; do
      echo "$D" | grep -qF -- "$P" || M="$M phrase:$P;"
    done
    for H in 出典 骨格の個人差を見る4つの視点 ストローク幅の設定 種目選択の判断 判断アルゴリズム \
             適用範囲と限界 既存スキルとの役割分担; do
      [ "$(grep -c "^## $H\$" "$F")" -eq 1 ] || M="$M h2:$H;"
    done
    B=$(SEC "$F" "^## 骨格の個人差を見る4つの視点\$")
    for P in "腕の長さ" "鎖骨の長さ" "肩幅" "胸椎"; do echo "$B" | grep -qF -- "$P" || M="$M view:$P;"; done
    B2=$(SEC "$F" "^## 判断アルゴリズム\$")
    [ "$(echo "$B2" | grep -cE '^[0-9]+[.] .+')" -ge 4 ] || M="$M steps;"
    for P in "スミス" "ダンベル" "マシン"; do echo "$B2" | grep -qF -- "$P" || M="$M algo:$P;"; done
    [ "$(SEC "$F" "^## 種目選択の判断\$" | grep -c '^|')" -ge 5 ] || M="$M table;"
    for P in "モーメントアーム" "水平内転" "前突"; do grep -qF -- "$P" "$F" || M="$M term:$P;"; done
    SEC "$F" "^## 出典\$" | grep -qF -- "cj advance/ハイパフォーマンス学/2026-08-21_Part128_大胸筋の徹底解説_YouTube.md" || M="$M srcpath;"
    [ -z "$M" ] && echo "DW7 PASS" || echo "DW7 FAIL$M"
  - validations:
    - technical: "p3.1〜p3.3 の判定を統合しており、同一の閾値・同一の逐語文字列を使っている"
    - consistency: "判断アルゴリズムの構成要素（4視点・ストローク幅・種目選択）が I-5 の主目的と一致している"
    - completeness: "frontmatter・7セクション・4視点・4ステップ・表5行・専門用語3語・出典の全項目を検証している"

- [ ] **p_final.8**: DW8 が満たされている（索引 ↔ スキルの相互整合）
  - executor: claudecode
  - test_command: |
    SEC() { awk -v h="$2" '$0 ~ h {f=1;next} /^#{1,2} /{f=0} f' "$1"; }
    NFC() { python3 -c "import sys,unicodedata;print('\n'.join(sorted({unicodedata.normalize('NFC',l.rstrip(chr(10))) for l in sys.stdin if l.strip()})))"; }
    IDX=".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md"; M=""
    B=$(SEC "$IDX" "^## スキル化済みの講義\$")
    for T in "Part122 .claude/skills/速筋遅筋-weight-training-theory/" \
             "Part123 .claude/skills/shoulder-pain-rehabilitation/" \
             "Part126 .claude/skills/personal-session-communication/" \
             "Part128 .claude/skills/skeletal-exercise-selection/"; do
      ID=${T% *}; DIR=${T#* }
      R=$(echo "$B" | grep -cF "| $ID |"); [ "$R" -eq 1 ] || { M="$M row:$ID($R);"; continue; }
      echo "$B" | grep -F "| $ID |" | grep -qF "$DIR" || M="$M dir:$ID;"
      test -d "$DIR" || M="$M nodir:$DIR;"
    done
    awk -F'|' '/^\|/{gsub(/^ +| +$/,"",$5); print $5}' "$IDX" | grep '^cj advance/' | NFC > /tmp/cj_idx.txt
    for S in .claude/skills/personal-session-communication/SKILL.md \
             .claude/skills/skeletal-exercise-selection/SKILL.md; do
      P=$(SEC "$S" "^## 出典\$" | grep -o 'cj advance/[^ ]*\.md' | head -1)
      [ -n "$P" ] || { M="$M nosrc:$S;"; continue; }
      echo "$P" | NFC > /tmp/cj_one.txt
      grep -qxF -- "$(cat /tmp/cj_one.txt)" /tmp/cj_idx.txt || M="$M srcnotindexed:$P;"
    done
    [ -z "$M" ] && echo "DW8 PASS" || echo "DW8 FAIL$M"
  - validations:
    - technical: "存在しないスキルへのリンクは `nodir:`、索引に無い出典パスは `srcnotindexed:` で FAIL する。出典パスは NFC 正規化してから索引と照合するため表記ゆれで偽 FAIL しない"
    - consistency: "索引 → スキル（4行）とスキル → 索引（出典パス）の**双方向**で参照整合性を検証している"
    - completeness: "既存2スキル＋新規2スキルの4対応と、新規2スキルの出典2件を全て検証している"

- [ ] **p_final.9**: DW9 が満たされている（禁止文字列0件・回帰: allowlist 外の変更0件）
  - executor: claudecode
  - test_command: |
    M=""
    for S in .claude/skills/personal-session-communication .claude/skills/skeletal-exercise-selection; do
      for P in "TBD" "TODO" "FIXME" "後で書く" "CJ Advance トレーニングシステム" "起始・停止" "島田" \
               "ピリオダイゼーション" "ミールプラン" "ポージング"; do
        N=$(grep -rlF -- "$P" "$S" 2>/dev/null | wc -l | tr -d ' ')
        [ "$N" -eq 0 ] || M="$M ban:$P;"
      done
    done
    BASE=d407efe
    { git -c core.quotepath=false diff --name-only "$BASE" HEAD
      git -c core.quotepath=false diff --name-only HEAD
      git -c core.quotepath=false ls-files --others --exclude-standard; } | sed '/^$/d' | sort -u > /tmp/cj_changeset.txt
    NEW='^\.claude/skills/クロニクルジャパンcj-advance/|^\.claude/skills/personal-session-communication/|^\.claude/skills/skeletal-exercise-selection/'
    PRE='^\.claude/agents/critic\.md$|^\.claude/settings\.json$|^\.claude/skills/instagram-pdca/|^\.claude/skills/video-editing-ffmpeg/|^plan/playbook-setup-instagram-skills\.md$|^tmp/'
    ALLOW="$NEW|$PRE|^plan/playbook-cj-advance-skill-expansion\.md\$|^state\.md\$|^docs/repository-map\.yaml\$"
    A=$(grep '^\.claude/skills/' /tmp/cj_changeset.txt | grep -vcE "$NEW|^\.claude/skills/instagram-pdca/|^\.claude/skills/video-editing-ffmpeg/")
    [ "$A" -eq 0 ] || M="$M otherskills:$A;"
    V=$(grep -vcE "$ALLOW" /tmp/cj_changeset.txt)
    [ "$V" -eq 0 ] || { M="$M outside:$V;"; grep -vE "$ALLOW" /tmp/cj_changeset.txt; }
    [ -z "$M" ] && echo "DW9 PASS" || echo "DW9 FAIL$M"
  - validations:
    - technical: "`core.quotepath=false` を付けないと非 ASCII パス（`.claude/skills/クロニクルジャパンcj-advance/...`, `tmp/AI×営業.html`）が8進エスケープされ allowlist に当たらず偽 FAIL になる。本コマンドは**タスク開始時点の作業ツリー**（先行差分15件のみ）に対して `otherskills=0 / outside=0` を実測済み"
    - consistency: "allowlist が I-6 の NEW / PRE と逐語一致しており、スコープ外作業（Part111 統合等）に着手すると `otherskills:` で検出される"
    - completeness: "追跡済み差分・作業ツリー差分・未追跡ファイルの3経路を全て集計し、禁止文字列は新規2スキルを再帰走査している"

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
    git add ".claude/skills/クロニクルジャパンcj-advance" \
            .claude/skills/personal-session-communication \
            .claude/skills/skeletal-exercise-selection \
            plan/playbook-cj-advance-skill-expansion.md state.md docs/repository-map.yaml
    git commit -m "feat(skills): add cj advance lecture index and two new skills" -- \
            ".claude/skills/クロニクルジャパンcj-advance" \
            .claude/skills/personal-session-communication \
            .claude/skills/skeletal-exercise-selection \
            plan/playbook-cj-advance-skill-expansion.md state.md docs/repository-map.yaml
  - note: |
    I-6 の PRE 15件（`.claude/agents/critic.md` / `.claude/settings.json` /
    `.claude/skills/instagram-pdca/` / `.claude/skills/video-editing-ffmpeg/` /
    `plan/playbook-setup-instagram-skills.md` / `tmp/`）は
    本タスク開始前から存在する先行の未コミット差分。**絶対に add / commit しない。**
    `git add -A` および `git commit -a` は禁止。
  - status: pending

- [ ] **ft4**: コミット結果を検証する（成果物4ファイルが全てコミットされ、許可外のファイルが1件も含まれない）
  - command: |
    git -c core.quotepath=false show --name-only --pretty=format: HEAD | sed '/^$/d' | sort -u > /tmp/cj_commit.txt
    M=""
    for P in '^\.claude/skills/クロニクルジャパンcj-advance/references/lecture-index\.md$' \
             '^\.claude/skills/クロニクルジャパンcj-advance/SKILL\.md$' \
             '^\.claude/skills/personal-session-communication/SKILL\.md$' \
             '^\.claude/skills/skeletal-exercise-selection/SKILL\.md$'; do
      grep -qE "$P" /tmp/cj_commit.txt || M="$M missing:$P;"
    done
    OK='^\.claude/skills/クロニクルジャパンcj-advance/|^\.claude/skills/personal-session-communication/|^\.claude/skills/skeletal-exercise-selection/|^plan/playbook-cj-advance-skill-expansion\.md$|^state\.md$|^docs/repository-map\.yaml$'
    V=$(grep -vcE "$OK" /tmp/cj_commit.txt)
    [ "$V" -eq 0 ] || { M="$M outside:$V;"; grep -vE "$OK" /tmp/cj_commit.txt; }
    [ -z "$M" ] && echo PASS || echo "FAIL$M"
  - note: |
    索引だけを見ると SKILL.md への追記や新規2スキルがコミット漏れしていても PASS するため、
    **成果物4ファイル全てのパス存在**を個別に検証する。
  - status: pending

---

## pm の自己点検記録（2026-08-25 / playbook 作成時に実測）

> **目的**: レビュー往復を減らすため、提出前に「実データに基づく事実」と
> 「test_command が正しい成果物で PASS し、改悪された成果物で FAIL する」ことを実測で確認した。

### 1. 実データの確認（training@8164d0d に対して実行）

| 確認項目 | 実測結果 |
|---|---|
| `cj advance/` 配下の `.md`（README・1バイト除く）生エントリ数 | 87 |
| NFC 正規化・重複排除後の件数 | **86** |
| 重複していたエントリ | `【Part100】ボディメイクvs機能改善.md` が NFC / NFD の2エントリ（同サイズ 67575 バイト） |
| 領域別内訳 | トレーニング学46 / ハイパフォーマンス学24 / 栄養生理学6 / 1on1 4 / ポージング学3 / 特典動画1 / 神経系生理学1 / 訓練学1 |
| Part 番号を持つファイル | 58件（うち `Part109` が トレーニング学・訓練学 に重複） |
| Part 番号を持たないファイル | 28件（`機能解剖学から見る肩トレーニング.md` 等） |
| `cj advance/神経系生理学/README.` | 拡張子なし・1バイト → `.md` フィルタで除外される |
| Part126 / Part128 の実ファイル | それぞれ 115行 / 112行を取得して内容確認済み |

> Part126 の内容確認: 「基本は目を合わせない」「会話30分中アイコンタクトは8分程度」
> 「正面ではなく斜めに立ってパーソナルスペースを外す」「相手が笑顔のときはしっかり見る」
> 「1日8本〜12本」「初回／2回目以降の設計」「雑談の内容自体は重要でない」を実文で確認。
> Part128 の内容確認: 「腕が長い＝モーメントアームが長い」「ストロークを取りすぎて上部に入らない」
> 「ダンベルは効いてる感覚があっても肩関節に逃げる」「スミス・マシンプレスを狭いストロークで」
> 「腕の長さ・鎖骨の長さ・肩幅」「胸椎伸展と肩甲骨の前突」を実文で確認。
> **I-4 / I-5 の必須キーワードは全てこの実文に対応しており、創作ではない。**

### 2. 正常系（期待成果物のモックに対する全 PASS）

本 playbook の Markdown から `- test_command: |` ブロック **23個を機械的に逐語抽出**し
（手で書き写したものではなく、この playbook のテキストそのものを実行している）、
`bash -n` / `zsh -n` の構文チェックを全23本で通過。

続いて期待成果物のモックを作成した:

- 実データ（training@8164d0d）から生成した86行の `lecture-index.md`
  （`## 講義一覧` / `## スキル化済みの講義`4行 / `## 既知の異常` / `## 更新方法`）
- `personal-session-communication/SKILL.md`（I-4 の仕様を満たす最小構成）
- `skeletal-exercise-selection/SKILL.md`（I-5 の仕様を満たす最小構成）

抽出した23ブロックのうち、git 非依存の20本をモックに対して `bash` と `zsh` の両方で実行:

```
p1.1 / p1.2 / p1.3 / p1.4 / p1.6                     -> PASS
p2.1 / p2.2 / p2.3 / p2.4                            -> PASS
p3.1 / p3.2 / p3.3 / p3.4                            -> PASS
p_final.1 -> DW1 PASS   p_final.2 -> DW2 PASS
p_final.3 -> DW3 PASS   p_final.4 -> DW4 PASS
p_final.6 -> DW6 PASS   p_final.7 -> DW7 PASS
p_final.8 -> DW8 PASS
=> 20ブロック × 2シェル = 40実行すべて PASS（ALL GREEN）
```

git 依存の3本は**実リポジトリ**で実行し、実装前の期待どおりの結果を得た:

```
p1.5      -> FAIL noref; nodiff;      （索引参照の追記が未実施なので正しく FAIL）
p_final.5 -> DW5 FAIL noref; nodiff;  （同上）
p_final.9 -> DW9 PASS                 （回帰: 先行差分15件のみの現状で otherskills=0 / outside=0）
```

`git diff --numstat` による DW5 の「追加のみ・削除0」判定は、cj-advance SKILL.md の複製に
参照指示を1行挿入したもので `1  0`、既存行を1行書き換えたもので `1  1` を返すことを実測済み。

### 3. 異常系（11種のデコイに対する FAIL 検出）

> モックに改悪を加えて、**本 playbook から抽出した p_final の test_command** で判定した。
> 「実測結果」列は実際の標準出力の逐語。

| # | 改悪内容 | 期待 | 実測結果 |
|---|---|---|---|
| D1 | 索引から Part128 の行を削除 | DW1 FAIL | `DW1 FAIL rows:85(want86); setmismatch;` |
| D2 | Part128 行の領域列を `ハイパフォーマンス学` → `トレーニング学` に改竄 | DW2 FAIL | `DW2 FAIL area:cj advance/ハイパフォーマンス学/2026-08-21_Part128_...md` |
| D3 | Part128 行の Part 列を `Part129` に改竄 | DW2 FAIL | `DW2 FAIL part:Part129!=Part128` |
| D4 | 1行を NFD 表記で書く（見た目は同一） | **DW1 PASS**（偽 FAIL を出してはいけないケース） | `DW1 PASS`（NFC 正規化で吸収） |
| D5 | description から起動フレーズ「立ち位置ってどこがいい」を1個削除 | DW6 FAIL | `DW6 FAIL phrase:「立ち位置ってどこがいい」;` |
| D6 | 必須キーワード `8分` を曖昧語に置換（＝出典を読まずに書いた状態） | DW6 FAIL | `DW6 FAIL kw:8分;` |
| D7 | 索引のスキル列を実在しないディレクトリに改竄 | DW8 FAIL | `DW8 FAIL dir:Part128;` |
| D8 | スキルの `## 出典` パスを索引に無い架空の Part999 に改竄 | DW8 FAIL | `DW8 FAIL srcnotindexed:cj advance/.../2026-08-21_Part999_架空の講義_YouTube.md;` |
| D9 | `## 判断アルゴリズム` を4手順 → 3手順に削減 | DW7 FAIL | `DW7 FAIL steps; algo:スミス; algo:ダンベル; algo:マシン;` |
| D10 | 解剖パートの見出し `起始・停止` を写経 | DW9 FAIL | `ban:起始・停止;` |
| D11 | 4視点の1行を `TBD` に置換（体裁だけ整えて中身を空にする） | DW9 FAIL | `ban:TBD;` |

**10/10 の改悪で期待どおり FAIL を検出**（D4 は「FAIL してはいけないケース」の確認で PASS）。
なお D4 の正規化ヘルパ `NFC` を外すと同じ入力が `setmismatch` になることも実測しており、
規約（実行前提の「Unicode 正規化が必須」）の必要性を裏付けている。
全デコイの復元後に p_final.1 / .2 / .6 / .7 / .8 が再び PASS することも確認済み（検出力の副作用なし）。

### 4. 残る未検証事項（構造上、機械検証できないもの）

- **スキル本文の質**（Part126 の接客設計が実際に現場で機能するか、Part128 の判断アルゴリズムが
  大胸筋以外の部位にどこまで一般化できるか）は機械検証できない。
  I-4 / I-5 で出典を実ファイルに限定し、出典を読まなければ書けない語
  （`8本〜12本` / `30分` / `8分` / `モーメントアーム` / `水平内転` / `前突`）を必須にすることで
  「読まずに一般論で埋める」ことは検出できるが、**質の判断は critic / ユーザーの目視に委ねる**。
- **テーマ列の可読性**。ファイル名が途中で切れているもの
  （`ジョイント・バイ・ジョイント理論に基づく包括的コンディショニング（後ろ半`）や
  `# CJ-ADVANCE_面談 10月②` のような値は、機械検証では「空でない」ことしか見ていない。
  I-2 で目視確認を指示している。
- **training 側の週次更新**。pinned SHA で固定しているため、タスク実行中に新しい講義が
  push されても判定はぶれないが、**完了直後の索引は pinned 時点のスナップショット**である。
  `## 更新方法` の運用（1行追加＋ `TREE` 更新）でカバーする設計にしている。
- p1〜p3 の subtask test_command は p_final の DW 判定のサブセットであり、
  同一ロジックを2箇所に書いている。閾値は揃えてあるが、片方だけ修正されるリスクは残る。

# playbook-threads-pdca-auto-log.md

> **`.claude/skills/threads-pdca/SKILL.md`（118行）のワークフロー3（Check）とワークフロー4（Act）を、
> 「ユーザーが数値を手入力する」前提から、`marketing` リポジトリに毎週自動蓄積されている
> `Be Co Gym/threads-pdca-log/{YYYY-MM-DD}.json` を `gh api` で読みに行く形に書き換える。**
>
> **自動収集ログに存在しない2項目（狙った型 / コンバージョン）は、記録タイミングが違うので
> `references/type-log.md` と `references/conversion-log.md` の2つの軽量ログに分離して残す。**
>
> **ワークフロー1（型ライブラリの育成）と `references/pattern-library.md` /
> `references/draft-queue.md` は1バイトも変更しない（機械検証する）。**
> **`references/my-posts-log.md` には実データ40行が入っているため削除せず、凍結アーカイブ化する。**

---

## 実行前提と検証規約

> **本セクションの規約は全 test_command に適用される。**

- **CWD**: 全 test_command はリポジトリルート（`/Users/kosei/thanks4claudecode-fresh`）を
  カレントディレクトリとして実行する。相対パスは全てリポジトリルート起点。
- **シェル**: `bash` / `zsh` のどちらでも同じ結果になるよう記述する
  （本 playbook の全 test_command は両方で構文チェック＋実行結果一致を確認済み。「pm の自己点検記録」参照）。
- **base_commit の固定**: 非破壊検証（DW1 / DW2 / DW3）と回帰検証（DW10）は
  **`574b9ad`（新ブランチ `feat/threads-pdca-auto-log` 作成時の HEAD）を起点**にする。
  Phase 途中でコミットしても判定がぶれない。
- **ファイル変数**: 全 test_command は先頭で以下を定義する。

  ```bash
  S=".claude/skills/threads-pdca/SKILL.md"
  L=".claude/skills/threads-pdca/references/my-posts-log.md"
  ```

### 区間抽出ヘルパ（**コードフェンス対応版。旧版は使用禁止**）

```bash
SEC()  { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
BSEC() { git show 574b9ad:"$1" | awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f'; }
H2C()  { awk '/^`{3}/{fence=!fence;next} !fence && /^## /{c++} END{print c+0}' "$1"; }
```

> **なぜフェンス対応が必須か（実測済みの致命的バグ）**
>
> 素朴な終端 `/^#{1,2} /` は、**コードブロック内の bash コメント行にマッチする**。
> I-7 が worker に書かせる取得コマンドには `# 1) ディレクトリ一覧から…` のようなコメントが入り得る。
> 実測では、それだけで `## 自動収集データの読み方` 区間が**冒頭3行で打ち切られ**、
> `gh api` の出現数が 2 → 0、`followers_count` / `views` 等が軒並み検出不能になり、
> **worker が I-7 の指示どおり正しく書いても p1.2〜p1.6 が全滅する**。
>
> - 終端は **`^## ` のみ**でよい（このファイルの H1 は6行目の `# Threads PDCA スキル` 1箇所だけで、
>   区間の直後に現れることはない）。
> - フェンス行のパターンを `` `{3} `` と書いているのは、awk プログラム中に
>   バッククォート3連を literal で置かないため（playbook の可読性と誤解の防止）。
>   awk の ERE が `{3}` の区間指定に対応していることは実測済み。
> - **H2 の本数カウントも必ず `H2C` を使う。** worker が criteria.md の内容を
>   ```` ```markdown ```` ブロックで引用すると、その中の `## 見る数字（3つだけ）` を
>   `grep -c '^## '` が数えてしまい、H2 本数チェックが誤 FAIL する（実測: 10 が 12 に化けた）。
> - `SEC` は `### ` では区間を閉じない。したがってワークフロー2区間には
>   `### 断らせるチェックの手順` が、ワークフロー4区間には `### 低反応の型の原因分析` が含まれる。
>   `---`（水平線）でも閉じない。
> - 前提: SKILL.md 中のコードフェンスは ` ``` ` のみで**開閉が釣り合っている**こと
>   （`~~~` 形式は使わない）。

### その他の規約

- **区間限定が必須な語**: `gh api`（SKILL.md に既に**2件**）/ `Be Co Gym`（既に**1件**）/
  `コピペ`（既に2件、うち1件は**保護対象のワークフロー1内**）/ `手渡`（既に2件、うち1件は
  **保護対象のワークフロー1内**）は既存本文に出現するため、**ファイル全体の grep では
  「書き換えた証拠」にならない**。必ず SEC で区間を切ってから照合する。
  一方 `threads-pdca-log` / `threads-pdca-criteria` / `followers_count` / `エンゲージ率` /
  `倍率` / `views` / `permalink` / `base64` / `fetched_at` / `計測不可` / `中央値` /
  `自動収集` / `okkun_lifestyle` / `type-log` / `conversion-log` は
  **base で0件であることを実測済み**（自己点検記録 3）で、ファイル全体の grep でも
  新規記述の代理指標として有効。
- **変数に入れた複数行テキストの再出力は必ず `printf '%s\n' "$VAR"`**。
  `echo "$VAR"` は zsh でエスケープ・タブの扱いが bash と食い違い得るため使わない。
- **日本語・記号を含む固定文字列の照合は必ず `grep -qF` / `grep -cF` / `grep -qxF`**
  （正規表現メタ誤爆の防止）。
- **`|` を含むパターンを `grep -E` に渡さない**。`|` は ERE の選択演算子であり、
  `grep -E '^| 日付 |'` は「空文字列にマッチ」＝**常に真**になって検査が無効化される（C2 で実際に踏んだ）。
  表の照合は `diff <(...) <(...)` で行う。
- **`grep -vc` を空入力に対して実行しない**（空文字列が1行として数えられ偽 FAIL になる）。
  該当箇所は全て `if [ -z "$X" ]` でガードしている。
- **「〜を含む行が1行以上ある」で済ませない**。凍結・読み取り専用のような
  **性質の宣言は ALL セマンティクス**（対象語を含む行の総数と、条件を満たす行数の一致）で検証する。
  ANY だと「1行だけ正しく書いて他は旧記述のまま」が通る。
- **未追跡パスの抽出は `sed -n 's/^?? //p'`**（`awk '{print $2}'` は空白入りパスで壊れる）。
  git がパスを `"` で囲んだ場合に備えて `sed 's/^"//; s/"$//'` も通す。
- **ネットワークについて**: p1 / p2 / p_final の test_command は**すべてローカルで完結する**。
  外部データの仕様は pm が実測済み（自己点検記録 1・2）。ft5 のみネットワークを使う。
- **python3 は必ず1行で書く**。複数行の heredoc は `test_command: |` のインデントと衝突する。

---

## meta

```yaml
project: thanks4claudecode
branch: feat/threads-pdca-auto-log  # 本タスク用に新規作成済み（574b9ad から分岐）
base_commit: 574b9ad  # 新ブランチ作成時の HEAD。DW1〜DW3（非破壊）と DW10（回帰）の比較元として固定
created: 2026-08-31
issue: null
derives_from: null  # ユーザー資産（スキル）の整備であり project.done_when に対応なし
reviewed: true  # reviewer 1回目 Needs Changes（Critical 2 / Major 5 / Minor 8）→ 全件反映済み
roles:
  worker: claudecode  # toolstack A（state.md config.roles と一致）
source:
  data_repo: github.com/younghastle3-source/marketing
  log_dir: "Be Co Gym/threads-pdca-log/"          # {YYYY-MM-DD}.json（毎週日曜 21:30 JST の Routine が追加）
  criteria: "Be Co Gym/threads-pdca-criteria.md"  # 床・倍率・エンゲージ率の閾値。唯一の正
  producer: Claude Code Routine「Threads週次PDCA分析」＋ okkun-secrets の GitHub Actions
```

> **ブランチに関する判断（実行前に必ず読むこと）**
>
> **`feat/threads-pdca-auto-log` を `574b9ad` から新規に切って使う（作成済み）。**
>
> ```bash
> git branch --show-current   # => feat/threads-pdca-auto-log
> git merge-base --is-ancestor 574b9ad HEAD && echo OK
> ```
>
> `main`（`d407efe`）ではなく直前タスクの HEAD（`574b9ad`）から分岐している。理由は2つ：
> 1. **`.claude/skills/threads-pdca/` の内容は `main` と `574b9ad` で完全に同一**
>    （`git diff main 574b9ad -- .claude/skills/threads-pdca/` が空。実測済み）。
> 2. 作業ツリーに**タスク開始前から浮いている未コミット差分が4件＋未追跡1件**あり、
>    `main` に checkout すると `instagram-pdca` / `video-editing-ffmpeg` の
>    ローカル変更が上書き対象になって checkout 自体が失敗する。
>
> **タスク開始前から浮いている差分（I-8 の PRE）は絶対にコミットしてはならない**
> （`git add -A` / `git commit -a` は禁止。ft3 参照）。

> **並行セッションに関する注意**
>
> `git worktree list` に `claude/great-chatterjee` / `claude/practical-chaum`（ともに `6a4030e`）の
> 2つの worktree が存在する。`.claude/skills/threads-pdca/` を別セッションが触っている可能性がある。
> **p1 着手の直前に必ず `git status --porcelain -- .claude/skills/threads-pdca/` を実行し、
> 出力が空でなければ着手せずユーザーに報告すること**（p1.0）。
> playbook 作成時点（2026-08-31）では**出力は空**であることを実測済み。

---

## goal

```yaml
summary: >
  threads-pdca スキルの「データ側」（実績の記録と集計）を、手入力前提から自動収集ログ参照に切り替える。
  具体的には (1) `## 自動収集データの読み方` という共通手順の H2 を新設し、
  `marketing` リポジトリの `Be Co Gym/threads-pdca-log/` から最新の {YYYY-MM-DD}.json を
  `gh api` で取得して床・倍率・エンゲージ率の3指標に集計する手順を書く、
  (2) ワークフロー3 を「ユーザーから数値を受け取って my-posts-log.md に追記する」から
  「自動ログを読んで実績を要約して見せる」に書き換える、
  (3) ワークフロー4 を自動ログ集計＋型ログ突き合わせ＋凍結アーカイブ参照の形に更新する、
  (4) 自動収集ログに存在しない2項目を、記録タイミングの違いに応じて2ファイルに分離する
      （型は下書き生成時にスキルが `references/type-log.md` へ自動追記、
       コンバージョンは手動・低頻度で `references/conversion-log.md` へ記入）、
  (5) frontmatter の description・「このスキルでできること」・「参照ファイル」・
      「このスキルの使い方」・ワークフロー2の手順6をこの変更に整合させる、
  (6) `references/my-posts-log.md` は実データ40行（2026-07-17〜2026-08-20）が入っているため
      データ行を1行も削らずに凍結アーカイブ化し、移行先2ファイルを明記する。
  「型を育てる側」（ワークフロー1 / pattern-library.md / draft-queue.md）は1バイトも触らない。
decisions:
  - id: D1
    question: 自動収集ログに無い「狙った型」「コンバージョン」をどう扱うか
    answer: >
      2項目を1つの表にまとめず、記録タイミングの違いで2ファイルに分離する。
      型は投稿を作る瞬間にワークフロー2が既に選んでおり、スキル自身が知っているので
      `references/type-log.md` へ自動追記できる（ユーザーの手入力は不要）。
      コンバージョンは投稿後しばらくして外部の数字を見て初めて分かり、Threads API にも存在しないため
      `references/conversion-log.md` への手動・低頻度の記入を前提とする（欠けている週があって当然とする）。
    decided_by: user（2026-08-31 / reviewer 経由で確認）
    supersedes: 「欠測を受け入れて今後は記録しない」案は撤回された
done_when:
  - "DW1: SKILL.md の保護区間3つ（`## 参照リポジトリ…` / `## ワークフロー1…` / `## 断らせるチェックのコツ…`）が base_commit 574b9ad と**バイト単位で完全一致**し、その**H2 見出し行そのもの**も逐語一致し、さらにワークフロー2の手順1〜5の5行と `### 断らせるチェックの手順` ブロックの全非空行、ワークフロー4の `### 低反応の型の原因分析` ブロックの全非空行が `grep -qxF` で逐語残存している"
  - "DW2: `references/pattern-library.md` / `references/draft-queue.md` が base_commit 574b9ad から**無変更**（`git diff --numstat 574b9ad` の出力が空、かつ `cmp -s` でバイト一致）であり、`.claude/skills/threads-pdca/` 配下に増えた新規ファイルが **`references/type-log.md` と `references/conversion-log.md` の2件のみ**である（この2件以外の新規ファイルは0件）"
  - "DW3: `references/my-posts-log.md` の `^| 2026` で始まるデータ行が**ちょうど40行**あり、`^|` で始まる行の並び全体（ヘッダ＋区切り＋データ40行＝42行）が base_commit 574b9ad と `diff` で**完全一致**する（＝内容・順序とも不変）。かつ冒頭12行以内に `凍結` と `2026-08-20` があり、ファイル内に移行先として `threads-pdca-log` / `marketing` / `type-log.md` / `conversion-log.md` の4つが全て書かれており、旧文言 `手入力で記録するテンプレート` と `データ行は投稿の都度この表の下に追記していく` が0件である"
  - "DW4: SKILL.md に `## 自動収集データの読み方` で始まる H2 がちょうど1本あり、その区間（**フェンス対応 SEC で抽出**）に (a) `gh api` を含む行が2行以上、(b) `threads-pdca-log` / `threads-pdca-criteria` / `base64` / `jq` / `%20` / `fetched_at` / `followers_count` / `permalink` の8語、(c) 指標名5つ `views` / `likes` / `replies` / `reposts` / `quotes` の全て、(d) `床` / `倍率` / `エンゲージ率` の3語、(e) `okkun_lifestyle`、(f) データの鮮度警告として `7日` と `古い` の両方が含まれる"
  - "DW5: 同区間に**データの落とし穴3点**が明記されている。(a) `計測不可` を含む行が1行以上ありその行が0扱いを否定する語（`0件として数えない`/`0扱いしない`/`0 として扱わな`/`0として扱わな`/`除外`）を伴う、(b) `中央値` を含む行が1行以上あり、`平均` と `外れ値` の両方を含む行が1行以上ある、(c) `text` または `本文` が `null` になり得ることに言及した行が1行以上ある、(d) `insight.data` に言及があり、jq のクラッシュ回避として **`// []` と `select(` の両方**が書かれている"
  - "DW6: 同区間に**閾値の出どころ**が明記されている。`threads-pdca-criteria.md` を毎回読む指示があり、`閾値` または `基準` を含む行のうち1行以上が『criteria 側が正である』ことを示す語（`唯一`/`正である`/`正とする`/`ハードコード`/`書き写さな`/`埋め込まな`）を伴い、`followers_count` への言及があり、`倍率` を含む行のうち1行以上が欠損時のフォールバック（`計測不可`/`算出できな`/`出せな`）を伴う"
  - "DW7: `## ワークフロー3` の H2 見出しが `記録` を含まず `自動収集` または `自動ログ` を含み、その区間に (a) 新しい発火フレーズとして `スレッズの実績` と `今週のスレッズ` の両方が含まれ、(b) `自動収集データの読み方` への参照があり、(c) 旧手順の痕跡である `いいね◯件だった` / `投稿結果を報告するね` / `の投稿実績ログの表に1行追記` / `ユーザーから日付` / `投稿の実績を記録して` が0件であり、(d) 実体行（`- ` / `{数字}. ` 始まり）が4行以上ある"
  - "DW8: `## ワークフロー4` 区間に (a) `自動収集データの読み方` への参照があり、(b) `my-posts-log.md` を含む行が1行以上あり**その全行が**凍結・過去分を示す語（`凍結`/`アーカイブ`/`2026-08-20`/`過去`）を伴い（ALL セマンティクス）、(c) `type-log.md` への言及があり、(d) `pattern-library.md` と `推定`（または `照合`/`当てはめ`）を含む行が1行以上あり、(e) `pattern-library.md` への言及がある区間に書き込み禁止（`書き込まな`/`更新しな`/`変更しな`/`読み取り専用`）があり、(f) 実体行が5行以上ある"
  - "DW9: 整合が取れている。(a) frontmatter の `description:` 行が `スレッズの実績見せて` と `今週のスレッズどうだった` を含み `投稿の実績を記録して` を含まない、(b) `## このスキルでできること` 区間に `自動` を含む行が1行以上あり `投稿ログに記録` が0件、(c) `## 参照ファイル` 区間に `threads-pdca-log` / `type-log.md` / `conversion-log.md` の3つがあり、`my-posts-log.md` を含む行の**全行が**凍結語（`凍結`/`アーカイブ`）を伴い、`draft-queue.md` の行が旧文言 `実績を記録し` を含まず `自動` または `凍結` を含む、(d) `## ワークフロー2` 区間に base 57行目が逐語では存在せず、`6. ` で始まる行があり、`自動収集`/`自動ログ`/`翌週` のいずれかがあり、`type-log.md` を含む行が `追記`/`残す`/`記録` を伴う、(e) ワークフロー3または4に `conversion-log.md` への言及がある、(f) `## このスキルの使い方` 区間に `実データの自動取得は行わない` が0件で `自動` を含む行が1行以上ある"
  - "DW10: 回帰・安全性。(a) SKILL.md に禁止文字列10個（`TBD` / `TODO` / `FIXME` / `後で書く` / `ghp_` / `github_pat_` / `Bearer ` / `access_token` / `graph.threads.net` / `okkun-secrets`）が0件、(b) SKILL.md が165〜320行・`references/my-posts-log.md` が52〜95行、(c) **`H2C` で数えた** SKILL.md の H2 がちょうど10本（既存9＋新規1）、(d) base_commit 574b9ad からの全変更ファイル集合（tracked の差分＋untracked）において、I-8 の allowlist にも I-8 の PRE 5件にも該当しないファイルが0件"
  - "DW11: 新設2ファイルが要件を満たす。(a) `references/type-log.md` が存在し、`| ` 始まりのヘッダ行に `日付` / `狙った型` と `URL` または `permalink` を持ち、`|-` の区切り行があり、自動追記である旨（`自動` / `手入力は不要` / `聞かない` のいずれか）が書かれ、**ダミーのデータ行（`^\\| {4桁}-` ）が0件**である。(b) `references/conversion-log.md` が存在し、ヘッダ行に `日付` / `コンバージョン` / `メモ` を持ち、`|-` の区切り行があり、`手動` の語と低頻度である旨（`低頻度` / `気が向いた` / `欠けて` のいずれか）が書かれている"
```

---

## inputs（合意済み素材 / worker の唯一の正典）

> **本セクションが worker の参照すべき唯一の正典である。**
> **外部データの仕様は pm が実測したものであり、記憶や推測で書き換えてはならない。**

### I-1. 自動収集ログの実測仕様（2026-08-31 に pm が `gh api` で取得して確認）

```yaml
リポジトリ: younghastle3-source/marketing
ディレクトリ: "Be Co Gym/threads-pdca-log/"      # ファイル名は {YYYY-MM-DD}.json
現存ファイル: 2026-08-31.json の1件のみ（63,108 bytes）← 週次で増えていく
判断基準: "Be Co Gym/threads-pdca-criteria.md"   # 707 bytes。閾値の唯一の正
```

**最新ファイルの取得コマンド（実測で動作確認済み）**

```bash
F=$(gh api "repos/younghastle3-source/marketing/contents/Be%20Co%20Gym/threads-pdca-log" \
      --jq '.[].name' | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.json$' | sort | tail -1)

gh api "repos/younghastle3-source/marketing/contents/Be%20Co%20Gym/threads-pdca-log/$F" \
      --jq '.content' | base64 -d > /tmp/threads-log.json
```

> **`Be Co Gym` にはスペースが入る。`Be%20Co%20Gym` と URL エンコードすること。**
> 実測ではスペースのままでも通ったが、シェルのクォート事故を防ぐため `%20` を正とする。
> ファイル名は `YYYY-MM-DD` の**辞書順＝時系列順**なので `sort | tail -1` で最新が取れる。
>
> **worker への注意**: SKILL.md に上記コマンドを書くとき、
> `# 1)` のような**行頭 `# ` で始まる bash コメントを使ってよい**（フェンス対応の SEC で検証するため
> 区間は切れない）。ただし説明は箇条書きで書くほうが読みやすい。

**JSON スキーマ（2026-08-31.json の実測）**

```jsonc
{
  "fetched_at": "2026-08-31T10:53:07+09:00",
  "profile": {
    "id": "27675838868743091",
    "username": "okkun_lifestyle",
    "threads_profile_picture_url": "...",
    "followers_count": 541          // ← 倍率の分母
  },
  "posts": [                         // 実測25件（対象期間 2026-08-18 〜 2026-08-28）
    {
      "meta": { "id": "...", "text": "...", "timestamp": "2026-08-28T22:00:20+0000",
                "permalink": "https://www.threads.com/@okkun_lifestyle/post/..." },
      "insight": { "data": [ { "name": "views",   "values": [ { "value": 117 } ] },
                             { "name": "likes",   "values": [ { "value": 2 } ] },
                             { "name": "replies", "values": [ { "value": 0 } ] },
                             { "name": "reposts", "values": [ { "value": 0 } ] },
                             { "name": "quotes",  "values": [ { "value": 0 } ] } ] }
    }
  ]
}
```

`insight.data[].name` の実測ユニーク値は **`views` / `likes` / `replies` / `reposts` / `quotes` の5つだけ**。
**`保存`（saves）に相当する指標は存在しない。** 旧ワークフロー3の「いいね/コメント/保存」のうち
「保存」は自動ログでは取れないため、新しい記述で保存数を要求してはならない。
**`狙った型` と `コンバージョン` も当然存在しない**（→ I-10 の2ファイルで補う）。

### I-2. 実データが示した3つの落とし穴（すべて 2026-08-31.json で実際に踏んだもの）

| # | 落とし穴 | 実測 | SKILL.md に書くべき対処 |
|---|---|---|---|
| 1 | `insight.data` が**空配列**の投稿が混ざる | 25件中1件（id `18003754760785852`、2026-08-23）。`meta.text` も `null` | **計測不可として集計から除外**し、「25件中24件で集計、1件は計測不可」と件数を明示する。**0 として数えない**（0で数えると平均が不当に下がる） |
| 2 | 平均が**外れ値1件に支配される** | views 平均 1,226 に対し**中央値 512**。最大 18,220 / 2位 2,035 / 3位 836 | 平均だけで語らず**中央値を併記**する。「平均は1件の突出投稿に引きずられている」と明示 |
| 3 | 素朴な jq が**null 除算でクラッシュする** | `$m.views` が null の要素で `null (null) and number (541) cannot be divided` が発生 | **`.insight.data // []` と `select(length > 0)`** でガードしてから集計する（この2つの文字列は DW5(d) で機械検証する） |

**pm が実測した集計結果（worker がロジックの妥当性を確認するための参照値。SKILL.md に書き写す必要はない）**

```
followers=541  総投稿25件  集計対象24件  計測不可1件
views 合計 29,414 / 平均 1,226 / 中央値 512 / 最大 18,220 / 最小 97
床（views>=1000）を超えた投稿: 24件中 2件
倍率（平均views ÷ followers）: 2.27倍
エンゲージ率（(likes+replies+reposts+quotes) ÷ views 合算）: 0.9%
```

### I-3. 判断基準ファイルの実測内容（`Be Co Gym/threads-pdca-criteria.md`）

```
## 見る数字（3つだけ）
- 床（最低ライン）: 1投稿あたりの再生数 1000
- 倍率: 再生数 ÷ フォロワー数（3倍を超えたら好調）
- エンゲージ率: (いいね+返信+リポスト+引用) ÷ 再生数（1%未満は詰まり、1〜3%は改善、3%超は勝ち）

## 更新履歴
（初回作成のみ。以降は「日付: 何がズレて、何を直したか」を1〜2行ずつここに追記していく）

2026-08-31: フォロワー数がAPIデータ（profile）に含まれておらず「倍率」指標が計算不可だった。
GitHub ActionsのfetchスクリプトにThreads APIのfollowers_count取得を追加すること。
```

> **重要な設計判断**: この閾値（1000 / 3倍 / 1%・3%）は **`threads-pdca-criteria.md` 側が唯一の正**であり、
> 更新履歴を追記しながら育っていくファイルである。
> **SKILL.md に数値をハードコードして「これが基準です」と書いてはならない。**
> SKILL.md には「実行のたびに `threads-pdca-criteria.md` を `gh api` で読んで、
> そこに書かれている閾値を使う」と書くこと（DW6）。
> 説明のために数値を例示すること自体は禁止しないが、**criteria 側が正であると明記する**こと。
>
> **worker への注意**: criteria.md の内容を SKILL.md に引用したい場合、
> ```` ```markdown ```` フェンスで囲めば H2 本数チェック（`H2C`）は誤爆しない（実測確認済み）。
> ただし引用は最小限にし、「毎回読む」ことを主にすること。
>
> なお更新履歴の 2026-08-31 の項目は「その時点の課題」であり、**実際のログには
> `profile.followers_count: 541` が既に入っている**（I-1 の実測）。
> ただし将来の欠損に備え、`followers_count` が無い/0 の場合は
> **倍率を計測不可として報告する**（クラッシュさせない）ようフォールバックを書くこと。

### I-4. 変更対象ファイルの現状（base_commit 574b9ad 時点・実測）

| 項目 | `SKILL.md` | `references/my-posts-log.md` |
|---|---|---|
| 行数 | 118 | 59 |
| H2 本数 | 9 | 2（`## 投稿実績ログ` / `## 記入方法`） |
| H3 本数 | 2 | 0 |
| データ行 | — | `^\| 2026` が**ちょうど40行**（`^\|` は42行＝ヘッダ＋区切り＋40） |

**SKILL.md の H2 一覧（base の行番号つき・実測）**

| 行 | H2 | 本タスクでの扱い |
|---|---|---|
| 10 | `## 参照リポジトリ（GitHub・おっくん自身のナレッジ）` | **保護（見出し行ごとバイト不変）** |
| 18 | `## このスキルでできること` | 項目2・3・4を書き換え |
| 26 | `## 参照ファイル` | my-posts-log の説明を書き換え＋新4行を追記 |
| 34 | `## ワークフロー1: 新規アカウント分析（Research → 型ライブラリ統合）` | **保護（見出し行ごとバイト不変）** |
| 48 | `## ワークフロー2: Plan（型選択 → 投稿の下書き作成）` | **手順6の差し替えと手順7の追加のみ**（手順1〜5と H3 は逐語保護） |
| 68 | `## ワークフロー3: Check（投稿後の実績記録）` | **全面書き換え** |
| 81 | `## ワークフロー4: Act（週次/月次の集計・振り返り）` | 本文書き換え（H3 は逐語保護） |
| 102 | `## 断らせるチェックのコツ（本音を引き出すコツ）` | **保護（見出し行ごとバイト不変）** |
| 113 | `## このスキルの使い方` | 項目2・3・4を書き換え |

新規 H2 は **`## 自動収集データの読み方（ワークフロー3・4の共通手順）` の1本のみ**。
配置は `## ワークフロー2` の直後・`## ワークフロー3` の直前
（ワークフロー3と4の両方から参照される共通手順のため、両者の手前に置く）。
これにより **H2 は 9 → 10 本**になる（DW10(c)）。
新セクション内の小見出しは `### ` で切ること（`## ` を使うと H2 本数が合わなくなる）。

### I-5. 保護対象（1バイトも変えてはならないもの）

**A. ファイル全体（`git diff --numstat 574b9ad` が空 かつ `cmp -s` 一致 / DW2）**

```
.claude/skills/threads-pdca/references/pattern-library.md
.claude/skills/threads-pdca/references/draft-queue.md
```

> ユーザーが「型を育てる側」として明示的に保護を宣言した領域。
> なお `references/hook-design.md` / `references/research-method.md` は
> **threads-pdca には存在しない**（base の `references/` の実体は pattern-library.md /
> my-posts-log.md / draft-queue.md の3件のみ。実測済み）。

**B. SKILL.md 内の区間（見出し行ごとバイト単位で一致 / DW1）**

```
## 参照リポジトリ（GitHub・おっくん自身のナレッジ）   … base 10行目。区間は非空4行
## ワークフロー1: 新規アカウント分析（Research → 型ライブラリ統合）  … base 34行目。区間は非空8行
## 断らせるチェックのコツ（本音を引き出すコツ）        … base 102行目。区間は非空6行
```

> **見出し行そのものも `grep -qxF` で逐語検証する。** 中身を保ったまま見出しだけ
> 短くする改変（例: `## 断らせるチェックのコツ`）は区間比較では検出できないため。
>
> **ワークフロー1区間の本文には
> 「Threads API やスクレイピングは使わず、常にユーザーからの手渡しを前提にする。」という一文がある。**
> これは**参考アカウントの投稿**に関する記述であり、本タスクで自動化するのは
> **自分自身の実績データ**なので、**この一文は書き換え後も真であり続ける。**
> 「矛盾しているように見えるから直そう」としてはならない。直したら DW1 で FAIL する。

**C. SKILL.md 内の逐語保護行（`grep -qxF` で残存 / DW1）**

ワークフロー2 の手順1〜5（base 52〜56行）:

```
1. ユーザーから伝えたい内容・状況（日常/告知/振り返り 等）を受け取る
2. `references/pattern-library.md` を参照し、状況に最も合う型（A〜G）を1つ選ぶ（複数型の組み合わせも可）
3. 下記「断らせるチェックの手順」を実行し、読む側が反応しない理由を洗い出す
4. 選んだ型の「型の構造」に沿って**下書き**を作成する。verbatim CTA がある型（E）はそのまま流用してよい
5. 執筆時の一般注意（絵文字1〜2個・タメ口・地域名は告知系のみ）に沿っているか確認する
```

`### 断らせるチェックの手順（手順3 / 下書き作成前）` ブロック（base 59〜66行）の全非空行、
および `### 低反応の型の原因分析（断らせるチェック / オプション）` ブロック（base 93〜98行）の全非空行。

**ワークフロー2 で変えてよいのは手順6（base 57行）だけ。手順7の追加は可。**

```
6. 下書きと「狙った型」をユーザーに提示し、投稿後に `references/my-posts-log.md` へ記録する旨を伝える
```

→ 手動記録が無くなるため「投稿後の実績は翌週の自動収集ログに入る」旨に差し替え、
**手順7として `references/type-log.md` への1行追記を追加する**（I-10 / DW9(d)）。
`references/draft-queue.md` への言及は残してよい（下書き管理は引き続き手動運用）。

### I-6. `references/my-posts-log.md` の扱い（**削除しない**）

> **pm の調査結果: このファイルは空のテンプレートではない。**
> **2026-07-17 〜 2026-08-20 の実投稿40行が入っている**（`^| 2026` がちょうど40行。実測）。
> ユーザーの当初認識（「Workflow3 を一度も使ったことがない」）は**事実と異なる**。

**この40行には自動ログから復元できない情報が含まれている**：

- `狙った型` 列（A〜J / 型評価対象外 / 新パターン候補 …）— 人間と LLM の判断の産物
- `コンバージョン` 列（オプチャ参加等）— Threads API には存在しない指標
- `気づき` 列（「E・F型は軒並み低い」「引用投稿＋当日夜という文脈効果」等）— 分析の蓄積

**したがって「凍結アーカイブ化」を採用する。削除も、内容の要約も、並べ替えも禁止。**

変更してよいのは以下の2箇所だけ：

1. **冒頭の説明（base 1〜4行）** → 凍結宣言に差し替える。
   必須要素: `凍結` の語 / 最終記録日 `2026-08-20` / 移行先として
   `threads-pdca-log`（自動収集の実績）・`marketing`・**`type-log.md`（型）**・
   **`conversion-log.md`（コンバージョン）** / この期間の型・コンバージョン・気づきはここが唯一の情報源である旨。
   旧文言 `手入力で記録するテンプレート` は消えること（DW3）。
2. **末尾の `## 記入方法`（base 51〜59行）** → 追記手順ではなく
   「読み方 / このファイルには追記しない」という移行メモに差し替える。
   **列の意味の説明は残すこと**（過去行を読むために必要 / DW3 の `nocolumnnote`）。
   「狙った型」の説明行に `type-log.md`、「コンバージョン」の説明行に `conversion-log.md` を書く。

**`## 投稿実績ログ` の表（ヘッダ行・区切り行・データ40行）は1行も変えず、順序も変えない。**
検証は `diff <(git show 574b9ad:"$L" | grep '^|') <(grep '^|' "$L")` で行うため、
**行の入れ替えも検出される**（実測確認済み）。

### I-7. 新設 H2 `## 自動収集データの読み方（ワークフロー3・4の共通手順）` に必ず入れる内容

1. **どこから取るか**: `marketing` リポジトリの `Be Co Gym/threads-pdca-log/`。
   `Be%20Co%20Gym` と URL エンコードすること。最新は `sort | tail -1`。
2. **取得コマンド**: I-1 の2ステップ（一覧 → `--jq '.content' | base64 -d`）をそのまま書く。
   `gh api` を含む行が2行以上になる（DW4(a)）。
3. **鮮度の確認**: 取得したらまず `fetched_at` をユーザーに提示する。
   **`fetched_at` が今日から7日以上前なら「データが古い」旨を先に告げる**（DW4(f)）。
   週次 Routine が止まると `sort | tail -1` は古いファイルを返し続けるため。
4. **誰のデータか**: `profile.username` が `okkun_lifestyle`、`profile.followers_count` が倍率の分母。
5. **JSON の形**: `fetched_at` / `profile` / `posts[].meta{id,text,timestamp,permalink}` /
   `posts[].insight.data[]{name,values[0].value}`。
   指標名は5つだけで、**保存数・型・コンバージョンは無い**。
6. **閾値の出どころ**: 毎回 `Be Co Gym/threads-pdca-criteria.md` を読む。
   **criteria 側が唯一の正であり、SKILL.md に閾値をハードコードしない**（DW6）。
7. **3指標の計算**:
   - 床 = 投稿ごとの `views` が閾値以上か。**「何件中何件が床を超えたか」で報告**する（平均で判定しない）
   - 倍率 = `views ÷ profile.followers_count`。`followers_count` が無い/0 なら**計測不可**と報告
   - エンゲージ率 = `(likes + replies + reposts + quotes) ÷ views`
8. **落とし穴3点**（I-2 の表そのまま。DW5）: 計測不可の除外／中央値の併記／`text` が `null`。
9. **jq の書き方**: **`.insight.data // []` と `select(` を含む例を最低1つ**示す（DW5(d)）。
10. **書き込み禁止**: このワークフローは**読み取り専用**。
    `marketing` リポジトリにも `okkun-secrets` にも**書き込まない**。
    Threads API を直接叩かない（トークンはこのリポジトリに無い。`graph.threads.net` を書かない / DW10(a)）。

### I-8. 禁止事項・allowlist・行数の上下限

**SKILL.md に含めてはならない文字列（各0件 / DW10(a)）**

```
TBD / TODO / FIXME / 後で書く / ghp_ / github_pat_ / "Bearer " / access_token
graph.threads.net / okkun-secrets
```

> 後半5つはセキュリティ要件。**このスキルはトークンを一切扱わない。**
> `gh api` の認証は既存の `gh` CLI のログインに乗るだけであり、
> Threads API のトークンは `okkun-secrets` の GitHub Actions 側で完結している。
> SKILL.md がトークンや秘密リポジトリの取得手順に言及すると、
> スキル本文（＝コンテキストに毎回載る文書）に秘密の在り処が漏れる。

**行数の上下限（DW10(b)）**

| ファイル | base | 下限 | 上限 |
|---|---|---|---|
| `SKILL.md` | 118 | **165** | 320 |
| `references/my-posts-log.md` | 59 | 52 | 95 |

> 下限 165 は、pm が作った**モック実装（183行）の実測**に基づく。
> 当初 185 に置いていたが、I-7 の全要件を満たす簡潔な実装が 177〜183 行に収まったため、
> **正しい実装を誤って FAIL させないよう 165 に下げた**（自己点検記録 5 参照）。

**変更してよいファイル（allowlist / DW10(d)）**

```
.claude/skills/threads-pdca/SKILL.md
.claude/skills/threads-pdca/references/my-posts-log.md
.claude/skills/threads-pdca/references/type-log.md          （新規作成・許可）
.claude/skills/threads-pdca/references/conversion-log.md    （新規作成・許可）
plan/playbook-threads-pdca-auto-log.md
state.md
docs/repository-map.yaml            （ft1 の既知バグで実際には更新されない）
```

> **`.claude/skills/threads-pdca/` 配下に作ってよい新規ファイルは
> `references/type-log.md` と `references/conversion-log.md` の2件のみ。**
> それ以外の新規ファイル（サブディレクトリ、バックアップ、`.bak`、別名のログ等）は
> 1件でも DW2 で FAIL する。

**PRE（タスク開始前から浮いている差分。絶対に add / commit しない）**

```
 M .claude/skills/instagram-pdca/references/my-posts-log.md
 M .claude/skills/instagram-pdca/references/pattern-library.md
 M .claude/skills/video-editing-ffmpeg/SKILL.md
 M .claude/skills/video-editing-ffmpeg/references/shooting-basics.md
?? plan/inputs-ai-tools-articles-20260827.md
```

### I-9. 共通ヘルパ（全 test_command で使う）

```bash
SEC()  { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
BSEC() { git show 574b9ad:"$1" | awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f'; }
H2C()  { awk '/^`{3}/{fence=!fence;next} !fence && /^## /{c++} END{print c+0}' "$1"; }
```

### I-10. 新設する2つの軽量ログ（ユーザー決定 D1）

> **自動収集ログに無い2項目を1つの表にまとめない。記録できるタイミングが違うため。**

**A. `.claude/skills/threads-pdca/references/type-log.md`（型ログ）**

```yaml
列: 日付 / 投稿URL（または permalink） / 狙った型（A〜J）
記入者: スキル自身（自動）
タイミング: ワークフロー2 で下書きを作り型を選んだ**その時点**
理由: 型は生成時点でスキルが既に知っている。ユーザーに聞く必要がない
突き合わせ: 投稿URL / permalink をキーに自動収集ログの投稿と対応づける（ワークフロー4 手順2）
```

必須要素（DW11(a)）:
- `| ` 始まりのヘッダ行に `日付` と `狙った型`、および `URL` または `permalink`
- `|-` 始まりの区切り行
- 自動追記である旨（`自動` / `手入力は不要` / `聞かない` のいずれか）
- **ダミーのデータ行を入れない**（`^\| {4桁}-` で始まる行が0件）

**B. `.claude/skills/threads-pdca/references/conversion-log.md`（コンバージョンログ）**

```yaml
列: 日付（または週） / コンバージョン数（オプチャ参加者数等） / メモ
記入者: ユーザー（手動）
タイミング: 投稿後しばらくして外部の数字を見たとき。**低頻度で構わない**
理由: Threads API に存在しない指標であり、今後も手入力が前提。欠けている週があって当然
言及: ワークフロー3 または 4 に「聞かれたら追記する」程度の軽い言及を置く（催促はしない）
```

必須要素（DW11(b)）:
- `| ` 始まりのヘッダ行に `日付` / `コンバージョン` / `メモ`
- `|-` 始まりの区切り行
- `手動` の語と、低頻度である旨（`低頻度` / `気が向いた` / `欠けて` のいずれか）

---

## スコープ外（本タスクでは扱わない）

```yaml
- ワークフロー1（新規アカウント分析）のロジック変更 … ユーザーが明示的に保護を宣言
- references/pattern-library.md の型 A〜J の追加・修正 … 同上（別セッションで対話的に育てる）
- references/draft-queue.md の内容更新 … 同上
- marketing リポジトリ側への書き込み（criteria.md の更新、ログの追記） … 読み取り専用
- okkun-secrets リポジトリ / GitHub Actions / Routine の設定変更 … 本リポジトリの外
- ダッシュボード Artifact の再生成 … 本リポジトリの外
- type-log.md への過去分（2026-08-20 以前の40件）の移植 … 凍結アーカイブに残っているので不要
- instagram-pdca スキルの同様の自動化 … 別タスク（本タスクでは1バイトも触らない）
- .claude/hooks/generate-repository-map.sh の修正 … 既知バグ（state.md の known_issues 参照）
```

> **既知の非整合（本タスクでは直さない）**
>
> `references/draft-queue.md` の冒頭には
> 「投稿したら `my-posts-log.md` に実績を記録し、このファイルから該当エントリを削除（または「投稿済み」に更新）してください。」
> という記述がある。my-posts-log.md が凍結されると**この一文は古くなる**。
> しかしユーザーが `draft-queue.md` を明示的に保護対象に指定しているため、**本タスクでは直さない**
> （直すと DW2 で FAIL する）。
> SKILL.md 側の `## 参照ファイル` の draft-queue.md の説明行では
> 「実績は翌週の自動収集ログ側に入る」と補うので、そこで整合を取ること（DW9(c)）。
> draft-queue.md 本体の更新が必要になったら、ユーザーに確認のうえ別タスクとする。

---

## リスクとロールバック

| # | リスク | 種別 | 対策 | 検出 |
|---|---|---|---|---|
| R1 | **`my-posts-log.md` の実データ40行を「空テンプレートだと思って」削除する** | 知識 | I-6 で「空テンプレートではない」と明記。ユーザーの当初認識は**事実と異なる**ことを冒頭・I-6・p2.1 の3箇所で警告 | p2.1 / p_final.2（行数40固定＋表42行の `diff` 完全一致） |
| R2 | **保護対象（ワークフロー1 / pattern-library.md / draft-queue.md）を「整合を取るため」に善意で書き換える** | 範囲 | I-5(B) の note で「ワークフロー1内の『Threads API やスクレイピングは使わず』は参考アカウントの話なので真であり続ける」と明示 | p1.1 / p_final.1 / p_final.6（区間バイト一致・見出し逐語・`cmp -s`） |
| R3 | **PRE 5件を `git add -A` で巻き込む** | 範囲 | ft3 で `-A` / `-a` を明示的に禁止し、pathspec を add と commit の両方に付ける | ft4（`outside:`） |
| R4 | **閾値を SKILL.md にハードコードし、criteria.md 更新後にスキルが古びる** | 技術 | DW6 で「毎回 criteria.md を読む」「criteria 側が正」の明記を強制 | p1.4 / p_final.3（`authority`） |
| R5 | **`insight.data` が空の投稿を 0 として集計し、平均が不当に下がる** | 技術 | I-2 の実測（25件中1件）を根拠に DW5(a) で「0として数えない・除外する」の明記を強制 | p1.3 / p_final.3（`measurezero`） |
| R6 | **外れ値1件（18,220 views）で「好調です」と誤報告する** | 技術 | DW5(b) で中央値の併記と「平均は外れ値に引きずられる」の明記を強制 | p1.3 / p_final.3（`outlier`） |
| R7 | **並行セッション（worktree 2つ）が同じスキルを同時に編集して差分が混ざる** | 依存 | p1.0 を着手前ゲートとして必須化。空でなければ着手せずユーザーに報告 | p1.0（`dirty:`） |
| R8 | **SKILL.md にトークンや秘密リポジトリの在り処を書いてしまう** | 技術 | I-8 で `ghp_` / `github_pat_` / `Bearer ` / `access_token` / `graph.threads.net` / `okkun-secrets` を禁止文字列に登録 | p1.7 / p_final.5（`ban:`） |
| R9 | **週次 Routine が止まり、`sort \| tail -1` が古いログを返し続ける** | 依存 | 本タスクでは解決しない（リポジトリ外）。DW4(f) で「`fetched_at` が7日以上前なら『データが古い』旨を先に告げる」を必須化し、ユーザーが気づける設計にする | p1.2 / p_final.3（`stale7` / `staleold`） |
| R10 | **検証コマンド自体が壊れていて、正しい実装を FAIL させる／誤りを見逃す** | 技術 | 全 test_command を**モック実装に対して実行して PASS を確認**（自己点検記録 5）。フェンス対応 SEC（C1）と `diff` による表照合（C2）はこの過程で発見・修正した | 自己点検記録 5・6 |
| R11 | **`type-log.md` にダミー行を入れて「動いているように見せる」** | 技術 | DW11(a) で `^\| {4桁}-` のデータ行が0件であることを要求 | p3.1（`tdummy`） |

**ロールバック手順**

```bash
# コミット前（p1 / p2 / p3 の途中で破綻した場合）: 既存2ファイルだけを base に戻す
git checkout 574b9ad -- .claude/skills/threads-pdca/SKILL.md \
                        .claude/skills/threads-pdca/references/my-posts-log.md
# 新規2ファイルは追跡外なので rm で戻す
rm -f .claude/skills/threads-pdca/references/type-log.md \
      .claude/skills/threads-pdca/references/conversion-log.md

# 保護ファイルを誤って変更した場合（PRE を巻き込まないよう必ずパス限定）
git checkout -- .claude/skills/threads-pdca/references/pattern-library.md \
                .claude/skills/threads-pdca/references/draft-queue.md

# ft3 のコミットに PRE が混入した場合（ft4 が outside: で FAIL したとき）
git reset --soft HEAD~1      # 変更は作業ツリーに残る。pathspec を直して ft3 をやり直す

# ブランチごと破棄する場合（PRE 5件は作業ツリーに残るので消えない）
git checkout feat/kubota-x-articles-skill-integration && git branch -D feat/threads-pdca-auto-log
```

> **`git checkout .` / `git reset --hard` / `git clean` は禁止。**
> PRE 5件（別タスクの未コミット作業）を巻き込んで消す。

**中間成果物について**: 本タスクは中間成果物を生成しない。
test_command が書く `/tmp/tp_*.txt` / `/tmp/tp_smoke.json` はリポジトリ外なのでクリーンアップ対象外。
リポジトリ内に `.tmp` を残し得るのは ft1 の既知バグだけで、ft1 自身が `rm -f` している。

---

## phases

> **p1（SKILL.md）/ p2（my-posts-log.md の凍結）/ p3（新規2ファイル）は編集対象が重ならないため
> 論理的には並行実行可能**である。ただし
> **p1.0（並行セッション・ブランチ・base の確認）は3つより前に必ず1回実行すること。**
> p_final は p1・p2・p3 の全完了後にのみ実行する。
> 直列で進める場合は **p3 → p1 → p2** の順を推奨
> （先に type-log / conversion-log を作っておくと、SKILL.md から参照する際にパスを確認でき、
> 凍結ヘッダの移行先の書き方も揃えやすい）。

### p1: SKILL.md を自動収集ログ参照に書き換える（保護区間は1バイトも触らない）

**goal**: 新規 H2 `## 自動収集データの読み方` を1本追加し、ワークフロー3を全面書き換え・ワークフロー4を更新し、
frontmatter・できること・参照ファイル・使い方・ワークフロー2の手順6/7を整合させる。保護区間3つと逐語保護行は不変のまま。

#### subtasks

- [ ] **p1.0**: 着手直前に `.claude/skills/threads-pdca/` に未コミット差分が1件も無く、正しいブランチに居ることを確認する
  - executor: claudecode
  - prerequisites: "別セッション（worktree `claude/great-chatterjee` / `claude/practical-chaum`）が同領域を触っている可能性があるため、**必ず p1.1 / p2.1 / p3.1 のどれよりも前に**実行する。空でなければ着手せずユーザーに報告する"
  - test_command: |
    N=$(git status --porcelain -- .claude/skills/threads-pdca/ | wc -l | tr -d ' ')
    B=$(git branch --show-current)
    MSG=""
    [ "$N" -eq 0 ] || { MSG="$MSG dirty:$N;"; git status --porcelain -- .claude/skills/threads-pdca/; }
    [ "$B" = "feat/threads-pdca-auto-log" ] || MSG="$MSG branch:$B;"
    git merge-base --is-ancestor 574b9ad HEAD || MSG="$MSG base;"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`git status --porcelain -- <path>` はパス限定なので PRE の4件（instagram-pdca / video-editing-ffmpeg）を拾わない。実測で出力0行を確認済み"
    - consistency: "ブランチ名と base_commit の祖先関係を同時に見るため、誤ったブランチで作業を始めることも防げる"
    - completeness: "並行セッションの衝突・ブランチ違い・base ずれの3リスクを着手前に同時に潰している"

- [ ] **p1.1**: 保護区間3つが base とバイト単位で一致し、見出し行と逐語保護行がすべて残存している
  - executor: claudecode
  - prerequisites: "I-5 を読んでから書くこと。特にワークフロー1内の「Threads API やスクレイピングは使わず、常にユーザーからの手渡しを前提にする。」は**参考アカウントの話なので書き換えない**"
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    test -f "$S" || { echo "FAIL nofile"; exit 0; }
    SEC()  { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    BSEC() { git show 574b9ad:"$1" | awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f'; }
    for H in '^## 参照リポジトリ' '^## ワークフロー1' '^## 断らせるチェックのコツ'; do
      A=$(BSEC "$S" "$H"); B=$(SEC "$S" "$H")
      [ -n "$A" ] || { MSG="$MSG basesec:$H;"; continue; }
      [ "$A" = "$B" ] || MSG="$MSG changed:$H;"
    done
    for R in 10 34 102; do
      HL=$(git show 574b9ad:"$S" | sed -n "${R}p")
      grep -qxF -- "$HL" "$S" || MSG="$MSG head:$R;"
    done
    for R in 52 53 54 55 56 $(seq 59 66) $(seq 93 98); do
      LN=$(git show 574b9ad:"$S" | sed -n "${R}p")
      [ -n "$LN" ] || continue
      grep -qxF -- "$LN" "$S" || MSG="$MSG keep:$R;"
    done
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "フェンス対応 SEC による区間の文字列完全一致なので、空白1つ・句読点1つの変更でも `changed:` で FAIL する。見出し行を短縮する改変は区間比較では検出できないため `head:` で別途 `grep -qxF` している（実測: `## 断らせるチェックのコツ（本音を引き出すコツ）` → `## 断らせるチェックのコツ` の改変を `head:102` で検出）"
    - consistency: "DW1 と1対1対応。p_final.1 と同一ロジック"
    - completeness: "区間バイト一致・見出し行逐語・ワークフロー2手順1〜5・2つの H3 ブロックの4点を同時に見ている"

- [ ] **p1.2**: `## 自動収集データの読み方（ワークフロー3・4の共通手順）` が1本追加され、取得コマンド・JSON スキーマ・5指標・3指標・鮮度警告が書かれている
  - executor: claudecode
  - prerequisites: "I-1 / I-7 を読んでから書くこと。取得コマンドは I-1 の実測済みコマンドを使い、記憶で書き換えない。セクション内の小見出しは `### ` を使う"
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    H=$(grep -c '^## 自動収集データの読み方' "$S")
    [ "$H" -eq 1 ] || { echo "FAIL h2count:$H(want1)"; exit 0; }
    A=$(SEC "$S" '^## 自動収集データの読み方')
    G=$(printf '%s\n' "$A" | grep -cF 'gh api'); [ "$G" -ge 2 ] || MSG="$MSG ghapi:$G(min2);"
    for P in threads-pdca-log threads-pdca-criteria base64 jq %20 fetched_at followers_count permalink \
             views likes replies reposts quotes 床 倍率 エンゲージ率 okkun_lifestyle; do
      printf '%s\n' "$A" | grep -qF -- "$P" || MSG="$MSG p:$P;"
    done
    printf '%s\n' "$A" | grep -qF '7日' || MSG="$MSG stale7;"
    printf '%s\n' "$A" | grep -qF '古い' || MSG="$MSG staleold;"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "**フェンス対応 SEC が必須**。旧版の終端 `/^#{1,2} /` はコードブロック内の `# 1)` にマッチして区間を打ち切り、正しい実装でも `ghapi:0` で FAIL した（実測）。`gh api` は base で2件あるが**いずれも `## 参照リポジトリ` 区間内**なので、区間限定なら既存記述では PASS しない"
    - consistency: "5指標の名前は I-1 の実測（`insight.data[].name` のユニーク値）と一致。`保存` を要求していないのは自動ログに存在しないため"
    - completeness: "見出しの一意性・取得コマンド2行以上・データソース8語・指標5語・判断軸3語・アカウント特定・鮮度警告の7点を同時に検証している"

- [ ] **p1.3**: 同区間にデータの落とし穴3点（計測不可の除外 / 中央値の併記 / text が null）と jq のクラッシュ回避が明記されている
  - executor: claudecode
  - prerequisites: "I-2 の表を読んでから書くこと。実測値（25件中1件が計測不可、平均1226 に対し中央値512）に基づく実在の落とし穴であり、一般論で埋めてはならない"
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    A=$(SEC "$S" '^## 自動収集データの読み方')
    MZ=$(printf '%s\n' "$A" | grep -F '計測不可')
    if [ -z "$MZ" ]; then MSG="$MSG nomeasure;"; else
      printf '%s\n' "$MZ" | grep -qE '0件として数えない|0扱いしない|0 として扱わな|0として扱わな|除外' || MSG="$MSG measurezero;"
    fi
    printf '%s\n' "$A" | grep -qF '中央値' || MSG="$MSG median;"
    printf '%s\n' "$A" | grep -F '平均' | grep -qF '外れ値' || MSG="$MSG outlier;"
    printf '%s\n' "$A" | grep -E 'text|本文' | grep -qF 'null' || MSG="$MSG nulltext;"
    printf '%s\n' "$A" | grep -qF 'insight.data' || MSG="$MSG schemaguard;"
    printf '%s\n' "$A" | grep -qF '// []' || MSG="$MSG jqdefault;"
    printf '%s\n' "$A" | grep -qF 'select(' || MSG="$MSG jqselect;"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`計測不可` / `中央値` は base で0件のため新規記述の代理指標として有効。`measurezero` は『計測不可を0として数えない』という**否定の意味まで**要求しており、語を並べただけでは PASS しない。`jqdefault` / `jqselect` は落とし穴3（null 除算クラッシュ）が**実際に回避されるコードとして**書かれたことを担保する（実測: ガードを削ると両方 FAIL）"
    - consistency: "I-2 の3行の表と1対1対応しており、p_final.3（DW5）と同一ロジック"
    - completeness: "計測不可の扱い・外れ値と中央値・null 本文・スキーマ参照・jq ガード2要素の6点を同時に検証している"

- [ ] **p1.4**: 同区間で閾値の出どころが `threads-pdca-criteria.md` に一本化され、ハードコード禁止とフォールバックが明記されている
  - executor: claudecode
  - prerequisites: "I-3 を読むこと。閾値の数値を例示すること自体は禁止しないが、**criteria 側が正**であると必ず書く。criteria.md を引用するときはコードフェンスで囲む"
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    A=$(SEC "$S" '^## 自動収集データの読み方')
    printf '%s\n' "$A" | grep -qF 'threads-pdca-criteria.md' || MSG="$MSG nocriteria;"
    TZ=$(printf '%s\n' "$A" | grep -E '閾値|基準')
    if [ -z "$TZ" ]; then MSG="$MSG nothreshold;"; else
      printf '%s\n' "$TZ" | grep -qE '唯一|正である|正とする|ハードコード|書き写さな|埋め込まな' || MSG="$MSG authority;"
    fi
    printf '%s\n' "$A" | grep -qF 'followers_count' || MSG="$MSG nofollowers;"
    printf '%s\n' "$A" | grep -F '倍率' | grep -qE '計測不可|算出できな|出せな' || MSG="$MSG fallback;"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`authority` は『criteria が正』という主張の語を要求するため、ファイル名を1回書いただけでは PASS しない。閾値が criteria 側で更新されてもスキルが古びない設計を構造的に強制している"
    - consistency: "I-3 の設計判断（criteria.md が唯一の正）と、フォロワー数欠損時のフォールバック（更新履歴 2026-08-31 の記述に由来）の両方を反映"
    - completeness: "参照先の明記・権威の所在・フォロワー数への言及・欠損時の退避の4点を同時に検証している"

- [ ] **p1.5**: `## ワークフロー3` が自動ログ参照に全面書き換えされ、旧手順の痕跡が0件である
  - executor: claudecode
  - prerequisites: "I-4 / I-7 を読むこと。見出しから `記録` を外し、発火フレーズを「スレッズの実績見せて」「今週のスレッズどうだった」等に差し替える"
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    HL=$(grep -m1 '^## ワークフロー3' "$S")
    [ -n "$HL" ] || { echo "FAIL now3"; exit 0; }
    printf '%s\n' "$HL" | grep -qF '記録' && MSG="$MSG oldhead;"
    printf '%s\n' "$HL" | grep -qE '自動収集|自動ログ' || MSG="$MSG newhead;"
    A=$(SEC "$S" '^## ワークフロー3')
    printf '%s\n' "$A" | grep -qF 'スレッズの実績' || MSG="$MSG trig1;"
    printf '%s\n' "$A" | grep -qF '今週のスレッズ' || MSG="$MSG trig2;"
    printf '%s\n' "$A" | grep -qF '自動収集データの読み方' || MSG="$MSG xref;"
    for P in 'いいね◯件だった' '投稿結果を報告するね' 'の投稿実績ログの表に1行追記' 'ユーザーから日付' '投稿の実績を記録して'; do
      printf '%s\n' "$A" | grep -qF -- "$P" && MSG="$MSG stale:$P;"
    done
    N=$(printf '%s\n' "$A" | grep -cE '^(- |[0-9]+[.] ).+'); [ "$N" -ge 4 ] || MSG="$MSG steps:$N(min4);"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`stale:` の5語は base のワークフロー3にのみ存在する文字列（実測）。禁止語を `1行追記` ではなく **`の投稿実績ログの表に1行追記`** と長く取っているのは、新設の `conversion-log.md に1行追記する` という**正当な記述と衝突したため**（モック検証で発見・修正）"
    - consistency: "発火フレーズはユーザー指定の2つを必須にしており、DW9(a) の frontmatter description と一致する"
    - completeness: "見出しの新旧・発火フレーズ2つ・共通手順への参照・旧痕跡5件の不在・手順の実体行数の5点を同時に検証している"

- [ ] **p1.6**: `## ワークフロー4` が自動ログ集計＋型ログ突き合わせ＋凍結アーカイブ参照に更新され、H3 は逐語のまま残っている
  - executor: claudecode
  - prerequisites: "I-5(C) / I-6 / I-10 を読むこと。`### 低反応の型の原因分析` ブロックは1バイトも変えない。型はまず `type-log.md` と突き合わせ、無いものだけ `pattern-library.md` で**読み取り専用で**推定する"
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    A=$(SEC "$S" '^## ワークフロー4')
    printf '%s\n' "$A" | grep -qF '自動収集データの読み方' || MSG="$MSG xref;"
    T=$(printf '%s\n' "$A" | grep -cF 'my-posts-log.md')
    OK=$(printf '%s\n' "$A" | grep -F 'my-posts-log.md' | grep -cE '凍結|アーカイブ|2026-08-20|過去')
    [ "$T" -ge 1 ] || MSG="$MSG nolog;"
    [ "$T" -eq "$OK" ] || MSG="$MSG frozenctx:$OK/$T;"
    printf '%s\n' "$A" | grep -qF 'type-log.md' || MSG="$MSG notypelog;"
    printf '%s\n' "$A" | grep -F 'pattern-library.md' | grep -qE '推定|照合|当てはめ' || MSG="$MSG infer;"
    printf '%s\n' "$A" | grep -qE '書き込まな|更新しな|変更しな|読み取り専用' || MSG="$MSG readonly;"
    N=$(printf '%s\n' "$A" | grep -cE '^(- |[0-9]+[.] ).+'); [ "$N" -ge 5 ] || MSG="$MSG steps:$N(min5);"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`frozenctx` は **ALL セマンティクス**（my-posts-log.md に言及する行の総数と、凍結語を伴う行数の一致）。ANY 判定だと『1行だけ凍結と書いて、別の行では旧来どおり集計対象として扱う』が通ってしまう（実測: 凍結語を1行から外すと `frozenctx:0/1` で FAIL）"
    - consistency: "SEC は `### ` で区間を閉じないため、この区間には `### 低反応の型の原因分析` が含まれる。その逐語残存は p1.1 の `keep:93〜98` が担保しており、二重に守られている"
    - completeness: "共通手順参照・凍結ログの位置づけ（ALL）・型ログ参照・型の推定手段・書き込み禁止・手順の実体行数の6点を同時に検証している"

- [ ] **p1.7**: frontmatter・できること・参照ファイル・ワークフロー2手順6/7・使い方が新方式に整合し、禁止文字列0件・行数・H2 本数が範囲内である
  - executor: claudecode
  - prerequisites: "I-4 / I-8 / I-10 を読むこと。frontmatter の `description:` はスキルの起動条件そのものなので、新しい発火フレーズを必ず含めること。ワークフロー2 は**手順6の差し替えと手順7の追加のみ**で、手順1〜5には触れない"
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    H2C() { awk '/^`{3}/{fence=!fence;next} !fence && /^## /{c++} END{print c+0}' "$1"; }
    D=$(grep -m1 '^description:' "$S")
    [ -n "$D" ] || MSG="$MSG nodesc;"
    printf '%s\n' "$D" | grep -qF 'スレッズの実績見せて' || MSG="$MSG dtrig1;"
    printf '%s\n' "$D" | grep -qF '今週のスレッズどうだった' || MSG="$MSG dtrig2;"
    printf '%s\n' "$D" | grep -qF '投稿の実績を記録して' && MSG="$MSG dstale;"
    C=$(SEC "$S" '^## このスキルでできること')
    printf '%s\n' "$C" | grep -qF '自動' || MSG="$MSG can_auto;"
    printf '%s\n' "$C" | grep -qF '投稿ログに記録' && MSG="$MSG can_stale;"
    R=$(SEC "$S" '^## 参照ファイル')
    printf '%s\n' "$R" | grep -qF 'threads-pdca-log' || MSG="$MSG ref_auto;"
    for NF in type-log.md conversion-log.md; do
      printf '%s\n' "$R" | grep -qF -- "$NF" || MSG="$MSG ref_new:$NF;"
    done
    RT=$(printf '%s\n' "$R" | grep -cF 'my-posts-log.md')
    RO=$(printf '%s\n' "$R" | grep -F 'my-posts-log.md' | grep -cE '凍結|アーカイブ')
    [ "$RT" -ge 1 ] || MSG="$MSG ref_nolog;"
    [ "$RT" -eq "$RO" ] || MSG="$MSG ref_frozen:$RO/$RT;"
    DQ=$(printf '%s\n' "$R" | grep -F 'draft-queue.md')
    if [ -z "$DQ" ]; then MSG="$MSG ref_nodq;"; else
      printf '%s\n' "$DQ" | grep -qF '実績を記録し' && MSG="$MSG dq_stale;"
      printf '%s\n' "$DQ" | grep -qE '自動|凍結' || MSG="$MSG dq_auto;"
    fi
    W2=$(SEC "$S" '^## ワークフロー2')
    S6=$(git show 574b9ad:"$S" | sed -n '57p')
    printf '%s\n' "$W2" | grep -qxF -- "$S6" && MSG="$MSG w2_stale6;"
    printf '%s\n' "$W2" | grep -qE '^6[.] ' || MSG="$MSG w2_no6;"
    printf '%s\n' "$W2" | grep -qE '自動収集|自動ログ|翌週' || MSG="$MSG w2_auto;"
    printf '%s\n' "$W2" | grep -F 'type-log.md' | grep -qE '追記|残す|記録' || MSG="$MSG w2_typelog;"
    CV=$(SEC "$S" '^## ワークフロー3'; SEC "$S" '^## ワークフロー4')
    printf '%s\n' "$CV" | grep -qF 'conversion-log.md' || MSG="$MSG cvref;"
    U=$(SEC "$S" '^## このスキルの使い方')
    printf '%s\n' "$U" | grep -qF '実データの自動取得は行わない' && MSG="$MSG use_stale;"
    printf '%s\n' "$U" | grep -qF '自動' || MSG="$MSG use_auto;"
    for P in TBD TODO FIXME 後で書く ghp_ github_pat_ 'Bearer ' access_token graph.threads.net okkun-secrets; do
      grep -qF -- "$P" "$S" && MSG="$MSG ban:$P;"
    done
    T=$(wc -l < "$S" | tr -d ' ')
    [ "$T" -ge 165 ] && [ "$T" -le 320 ] || MSG="$MSG lines:$T(165-320);"
    H=$(H2C "$S"); [ "$H" -eq 10 ] || MSG="$MSG h2:$H(want10);"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`dstale` / `can_stale` / `use_stale` / `dq_stale` / `w2_stale6` は base に実在する文字列を**不在で**要求しており、整合作業をサボると必ず FAIL する（実測: 手順6を base のまま残すと `w2_stale6` と `w2_auto` が発火）。`ref_frozen` は ALL セマンティクス。H2 本数は **`H2C`（フェンス対応）** で数えており、criteria.md を ```markdown ブロックで引用しても誤爆しない（実測: 生の `grep -c '^## '` は 12 を返すが `H2C` は 10 を返す）"
    - consistency: "H2 ちょうど10本は I-4（既存9＋新規1）と一致。行数下限 165 はモック実装 183 行の実測に基づき、正しい実装を誤 FAIL させない値に設定している"
    - completeness: "frontmatter・できること・参照ファイル（新2ファイル含む）・draft-queue 説明・ワークフロー2手順6/7・conversion-log 言及・使い方の7整合点と、禁止文字列・行数・H2 本数の3回帰点を同時に検証している"

---

### p2: `references/my-posts-log.md` を凍結アーカイブ化する（データ40行は1行も削らない）

**goal**: 実データ40行と表の骨格を逐語・同順のまま残し、冒頭説明と `## 記入方法` だけを移行メモに差し替える。

#### subtasks

- [ ] **p2.1**: データ行40行と表全体（ヘッダ・区切り・データ）が base から逐語・同順で残存している
  - executor: claudecode
  - prerequisites: "I-6 を読むこと。**このファイルは空テンプレートではない。** 2026-07-17〜2026-08-20 の実投稿40行が入っており、`狙った型` / `コンバージョン` / `気づき` の3列は自動ログから復元できない。並べ替えも要約も禁止"
  - test_command: |
    L=".claude/skills/threads-pdca/references/my-posts-log.md"; MSG=""
    test -f "$L" || { echo "FAIL nofile"; exit 0; }
    N=$(grep -c '^| 2026' "$L"); [ "$N" -eq 40 ] || MSG="$MSG rows:$N(want40);"
    diff <(git show 574b9ad:"$L" | grep '^|') <(grep '^|' "$L") >/dev/null || MSG="$MSG table;"
    grep -q '^## 投稿実績ログ$' "$L" || MSG="$MSG h2log;"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`diff` で `^|` 行の並び全体（ヘッダ＋区切り＋データ40行＝42行）を比較しているため、**1文字の書き換えも、行の削除も、行の入れ替えも**検出する。旧案の `grep -qxF` による行ごと照合は**並べ替えを素通り**した（実測: 2行入れ替えで欠落0件＝素通り、`diff` 版は `table;` で検出）。旧案の `grep -E '^| 日付 |'` は `|` が ERE の選択演算子として解釈され**常に真**になる無効な検査だった"
    - consistency: "行数 `-eq 40` を併記しているのは、`diff` が FAIL したときに『何行になっているか』を即座に示すため"
    - completeness: "行数・表全体の逐語と順序・H2 の3点を同時に検証している"

- [ ] **p2.2**: 冒頭と `## 記入方法` が凍結・移行メモに差し替わり、移行先2ファイルが明記され、旧テンプレート文言が0件である
  - executor: claudecode
  - prerequisites: "I-6 の『変更してよいのは2箇所だけ』を厳守すること。列の意味の説明は過去行を読むために必要なので残し、「狙った型」の説明に `type-log.md`、「コンバージョン」の説明に `conversion-log.md` を書く"
  - test_command: |
    L=".claude/skills/threads-pdca/references/my-posts-log.md"; MSG=""
    H=$(head -12 "$L")
    printf '%s\n' "$H" | grep -qF '凍結' || MSG="$MSG nofrozen;"
    printf '%s\n' "$H" | grep -qF '2026-08-20' || MSG="$MSG nolastdate;"
    grep -qF 'threads-pdca-log' "$L" || MSG="$MSG nomigrate;"
    grep -qF 'marketing' "$L" || MSG="$MSG norepo;"
    grep -qF '手入力で記録するテンプレート' "$L" && MSG="$MSG oldintro;"
    grep -qF 'データ行は投稿の都度この表の下に追記していく' "$L" && MSG="$MSG oldrule;"
    NT=$(grep -v '^|' "$L")
    K=$(printf '%s\n' "$NT" | grep -cE '「狙った型」|「コンバージョン|「気づき」')
    [ "$K" -ge 2 ] || MSG="$MSG nocolumnnote:$K(min2);"
    printf '%s\n' "$NT" | grep -F '狙った型' | grep -qF 'type-log.md' || MSG="$MSG mig_type;"
    printf '%s\n' "$NT" | grep -F 'コンバージョン' | grep -qF 'conversion-log.md' || MSG="$MSG mig_conv;"
    T=$(wc -l < "$L" | tr -d ' ')
    [ "$T" -ge 52 ] && [ "$T" -le 95 ] || MSG="$MSG lines:$T(52-95);"
    for P in TBD TODO FIXME 後で書く; do grep -qF -- "$P" "$L" && MSG="$MSG ban:$P;"; done
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`nocolumnnote` は **`grep -v '^|'` で表を除外してから**数えている。除外しないと表のヘッダ行（`| 日付 | 投稿文（要約） | 狙った型 | …`）自身がマッチして**常に成立し検査が無効化される**（旧案の欠陥。実測で修正を確認: 記入方法を丸ごと削ると `nocolumnnote:1` で FAIL）"
    - consistency: "`mig_type` / `mig_conv` は I-10 の2ファイルと双方向に整合する。SKILL.md 側の `## 参照ファイル`（DW9(c)）からも同じ2ファイルが参照される"
    - completeness: "凍結宣言・最終記録日・移行先4要素・旧文言2件の不在・列説明の残存・移行先の対応づけ・行数・禁止語の9点を同時に検証している"

---

### p3: 型ログとコンバージョンログを新設する

**goal**: 自動収集ログに存在しない2項目を、記録タイミングの違いに応じた2つの軽量ファイルとして作る（ユーザー決定 D1）。

#### subtasks

- [ ] **p3.1**: `references/type-log.md` と `references/conversion-log.md` が I-10 の要件どおりに作られ、それ以外の新規ファイルが0件である
  - executor: claudecode
  - prerequisites: "I-10 を読むこと。**ダミーのデータ行を入れない**（空の表として作る）。`.claude/skills/threads-pdca/` 配下に作ってよい新規ファイルはこの2件のみ"
  - test_command: |
    R=".claude/skills/threads-pdca/references"; MSG=""
    TL="$R/type-log.md"; CL="$R/conversion-log.md"
    test -f "$TL" || MSG="$MSG notypelog;"
    test -f "$CL" || MSG="$MSG noconvlog;"
    [ -z "$MSG" ] || { echo "FAIL$MSG"; exit 0; }
    H=$(grep -m1 '^| ' "$TL")
    for P in 日付 狙った型; do printf '%s\n' "$H" | grep -qF -- "$P" || MSG="$MSG tcol:$P;"; done
    printf '%s\n' "$H" | grep -qE 'URL|permalink' || MSG="$MSG tcol:url;"
    grep -qE '^\|-' "$TL" || MSG="$MSG tsep;"
    grep -qE '自動|手入力は不要|聞かない' "$TL" || MSG="$MSG tauto;"
    grep -cE '^\| [0-9]{4}-' "$TL" | grep -qx 0 || MSG="$MSG tdummy;"
    H2=$(grep -m1 '^| ' "$CL")
    for P in 日付 コンバージョン メモ; do printf '%s\n' "$H2" | grep -qF -- "$P" || MSG="$MSG ccol:$P;"; done
    grep -qE '^\|-' "$CL" || MSG="$MSG csep;"
    grep -qF '手動' "$CL" || MSG="$MSG cmanual;"
    grep -qE '低頻度|気が向いた|欠けて' "$CL" || MSG="$MSG cfreq;"
    NEW=$(git status --porcelain -- .claude/skills/threads-pdca/ | sed -n 's/^?? //p' | sed 's/^"//; s/"$//')
    if [ -n "$NEW" ]; then
      BAD=$(printf '%s\n' "$NEW" | grep -vE '^\.claude/skills/threads-pdca/references/(type-log|conversion-log)\.md$')
      [ -z "$BAD" ] || { MSG="$MSG newfiles;"; printf '%s\n' "$BAD"; }
    fi
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "`tdummy` は `^\\| {4桁}-` で始まる行が0件であることを要求し、動作しているように見せるためのダミー行を弾く。新規ファイルの allowlist は**この2件だけを許可**する正規表現で、`.bak` やサブディレクトリを1件でも作ると `newfiles` で FAIL する（実測: `hack.md` を置いて検出を確認）"
    - consistency: "列の要件は I-10 の A / B と1対1対応し、`type-log.md` はワークフロー2（DW9(d)）から、`conversion-log.md` はワークフロー3/4（DW9(e)）から参照される"
    - completeness: "2ファイルの存在・両者の列構成・区切り行・性格の宣言（自動 / 手動＋低頻度）・ダミー行の不在・新規ファイル allowlist の6点を同時に検証している"

---

### p_final: 完了検証（必須）

**goal**: DW1〜DW11 を独立に再実行し、Phase 途中の PASS が後続の編集で壊れていないことを確認する。

#### subtasks

- [ ] **p_final.1**: DW1 + DW2（保護区間のバイト一致・見出し逐語・逐語保護行・保護2ファイル無変更・新規ファイル2件のみ）
  - executor: claudecode
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC()  { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    BSEC() { git show 574b9ad:"$1" | awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f'; }
    for H in '^## 参照リポジトリ' '^## ワークフロー1' '^## 断らせるチェックのコツ'; do
      A=$(BSEC "$S" "$H"); B=$(SEC "$S" "$H")
      [ -n "$A" ] || { MSG="$MSG basesec:$H;"; continue; }
      [ "$A" = "$B" ] || MSG="$MSG changed:$H;"
    done
    for R in 10 34 102; do
      HL=$(git show 574b9ad:"$S" | sed -n "${R}p"); grep -qxF -- "$HL" "$S" || MSG="$MSG head:$R;"
    done
    for R in 52 53 54 55 56 $(seq 59 66) $(seq 93 98); do
      LN=$(git show 574b9ad:"$S" | sed -n "${R}p"); [ -n "$LN" ] || continue
      grep -qxF -- "$LN" "$S" || MSG="$MSG keep:$R;"
    done
    for F in pattern-library.md draft-queue.md; do
      P=".claude/skills/threads-pdca/references/$F"
      test -f "$P" || { MSG="$MSG gone:$F;"; continue; }
      D=$(git diff --numstat 574b9ad -- "$P"); [ -z "$D" ] || MSG="$MSG protected:$F;"
      cmp -s <(git show 574b9ad:"$P") "$P" || MSG="$MSG bytes:$F;"
    done
    NEW=$(git status --porcelain -- .claude/skills/threads-pdca/ | sed -n 's/^?? //p' | sed 's/^"//; s/"$//')
    if [ -n "$NEW" ]; then
      BAD=$(printf '%s\n' "$NEW" | grep -vE '^\.claude/skills/threads-pdca/references/(type-log|conversion-log)\.md$')
      [ -z "$BAD" ] || { MSG="$MSG newfiles;"; printf '%s\n' "$BAD"; }
    fi
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "p1.1 と p3.1 の保護部分を最終状態に対して再実行する。`cmp -s` は `git diff --numstat` より厳密で改行コードの変更も検出する。プロセス置換 `<(...)` は bash / zsh 両方で動作する（実測）"
    - consistency: "ユーザーが最優先で保護を宣言した『型を育てる側』が無傷であることの最終確認"
    - completeness: "DW1 と DW2 の全要素を網羅"

- [ ] **p_final.2**: DW3（my-posts-log.md の表の完全一致＋凍結化＋移行先2ファイル）
  - executor: claudecode
  - test_command: |
    L=".claude/skills/threads-pdca/references/my-posts-log.md"; MSG=""
    N=$(grep -c '^| 2026' "$L"); [ "$N" -eq 40 ] || MSG="$MSG rows:$N(want40);"
    diff <(git show 574b9ad:"$L" | grep '^|') <(grep '^|' "$L") >/dev/null || MSG="$MSG table;"
    H=$(head -12 "$L")
    printf '%s\n' "$H" | grep -qF '凍結' || MSG="$MSG nofrozen;"
    printf '%s\n' "$H" | grep -qF '2026-08-20' || MSG="$MSG nolastdate;"
    for P in threads-pdca-log marketing type-log.md conversion-log.md; do
      grep -qF -- "$P" "$L" || MSG="$MSG mig:$P;"
    done
    grep -qF '手入力で記録するテンプレート' "$L" && MSG="$MSG oldintro;"
    grep -qF 'データ行は投稿の都度この表の下に追記していく' "$L" && MSG="$MSG oldrule;"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "p2.1 + p2.2 の中核を再実行。40行の実データ喪失は本タスク最大の不可逆リスクなので、Phase とは独立にもう一度確認する"
    - consistency: "DW3 と1対1対応。移行先4語のうち `type-log.md` / `conversion-log.md` は p3 の成果物と対応する"
    - completeness: "行数・表の完全一致・凍結宣言・最終記録日・移行先4件・旧文言2件の不在を網羅"

- [ ] **p_final.3**: DW4 + DW5 + DW6（共通手順セクションの内容・落とし穴・jq ガード・閾値の出どころ）
  - executor: claudecode
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    [ "$(grep -c '^## 自動収集データの読み方' "$S")" -eq 1 ] || { echo "FAIL h2count"; exit 0; }
    A=$(SEC "$S" '^## 自動収集データの読み方')
    [ "$(printf '%s\n' "$A" | grep -cF 'gh api')" -ge 2 ] || MSG="$MSG ghapi;"
    for P in threads-pdca-log threads-pdca-criteria base64 jq %20 fetched_at followers_count permalink \
             views likes replies reposts quotes 床 倍率 エンゲージ率 okkun_lifestyle insight.data 中央値 \
             7日 古い '// []' 'select('; do
      printf '%s\n' "$A" | grep -qF -- "$P" || MSG="$MSG p:$P;"
    done
    MZ=$(printf '%s\n' "$A" | grep -F '計測不可')
    if [ -z "$MZ" ]; then MSG="$MSG nomeasure;"; else
      printf '%s\n' "$MZ" | grep -qE '0件として数えない|0扱いしない|0 として扱わな|0として扱わな|除外' || MSG="$MSG measurezero;"
    fi
    printf '%s\n' "$A" | grep -F '平均' | grep -qF '外れ値' || MSG="$MSG outlier;"
    printf '%s\n' "$A" | grep -E 'text|本文' | grep -qF 'null' || MSG="$MSG nulltext;"
    TZ=$(printf '%s\n' "$A" | grep -E '閾値|基準')
    if [ -z "$TZ" ]; then MSG="$MSG nothreshold;"; else
      printf '%s\n' "$TZ" | grep -qE '唯一|正である|正とする|ハードコード|書き写さな|埋め込まな' || MSG="$MSG authority;"
    fi
    printf '%s\n' "$A" | grep -F '倍率' | grep -qE '計測不可|算出できな|出せな' || MSG="$MSG fallback;"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "p1.2 / p1.3 / p1.4 を1本に統合して再実行。23語の一括ループにしているので、後から段落を削って短くした場合に検出できる。フェンス対応 SEC を使っているため、取得コマンド中の `# 1)` コメントで区間が切れることはない"
    - consistency: "要求語はすべて I-1 / I-2 / I-3 の実測に由来し、pm の推測は1語も含まれていない"
    - completeness: "DW4・DW5・DW6 の全要素を網羅"

- [ ] **p_final.4**: DW7 + DW8（ワークフロー3の全面書き換えとワークフロー4の更新）
  - executor: claudecode
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    HL=$(grep -m1 '^## ワークフロー3' "$S")
    printf '%s\n' "$HL" | grep -qF '記録' && MSG="$MSG w3oldhead;"
    printf '%s\n' "$HL" | grep -qE '自動収集|自動ログ' || MSG="$MSG w3newhead;"
    A3=$(SEC "$S" '^## ワークフロー3')
    printf '%s\n' "$A3" | grep -qF 'スレッズの実績' || MSG="$MSG w3trig1;"
    printf '%s\n' "$A3" | grep -qF '今週のスレッズ' || MSG="$MSG w3trig2;"
    printf '%s\n' "$A3" | grep -qF '自動収集データの読み方' || MSG="$MSG w3xref;"
    for P in 'いいね◯件だった' '投稿結果を報告するね' 'の投稿実績ログの表に1行追記' 'ユーザーから日付' '投稿の実績を記録して'; do
      printf '%s\n' "$A3" | grep -qF -- "$P" && MSG="$MSG w3stale:$P;"
    done
    [ "$(printf '%s\n' "$A3" | grep -cE '^(- |[0-9]+[.] ).+')" -ge 4 ] || MSG="$MSG w3steps;"
    A4=$(SEC "$S" '^## ワークフロー4')
    printf '%s\n' "$A4" | grep -qF '自動収集データの読み方' || MSG="$MSG w4xref;"
    T=$(printf '%s\n' "$A4" | grep -cF 'my-posts-log.md')
    OK=$(printf '%s\n' "$A4" | grep -F 'my-posts-log.md' | grep -cE '凍結|アーカイブ|2026-08-20|過去')
    [ "$T" -ge 1 ] || MSG="$MSG w4nolog;"
    [ "$T" -eq "$OK" ] || MSG="$MSG w4frozenctx:$OK/$T;"
    printf '%s\n' "$A4" | grep -qF 'type-log.md' || MSG="$MSG w4typelog;"
    printf '%s\n' "$A4" | grep -F 'pattern-library.md' | grep -qE '推定|照合|当てはめ' || MSG="$MSG w4infer;"
    printf '%s\n' "$A4" | grep -qE '書き込まな|更新しな|変更しな|読み取り専用' || MSG="$MSG w4readonly;"
    [ "$(printf '%s\n' "$A4" | grep -cE '^(- |[0-9]+[.] ).+')" -ge 5 ] || MSG="$MSG w4steps;"
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "p1.5 / p1.6 を統合して再実行。`w4frozenctx` は ALL セマンティクスで、凍結の位置づけが全言及行で一貫していることを担保する"
    - consistency: "DW7・DW8 と1対1対応"
    - completeness: "両ワークフローの見出し・発火フレーズ・相互参照・旧痕跡・凍結ログの扱い・型ログ・型推定・書き込み禁止・手順数を網羅"

- [ ] **p_final.5**: DW9 + DW10 + DW11（整合・禁止文字列・行数・H2 本数・新設2ファイル・変更ファイル allowlist）
  - executor: claudecode
  - test_command: |
    S=".claude/skills/threads-pdca/SKILL.md"; L=".claude/skills/threads-pdca/references/my-posts-log.md"
    R=".claude/skills/threads-pdca/references"; MSG=""
    SEC() { awk -v h="$2" '/^`{3}/{fence=!fence; if(f)print; next} fence{if(f)print;next} $0 ~ h {f=1;next} /^## /{f=0} f' "$1"; }
    H2C() { awk '/^`{3}/{fence=!fence;next} !fence && /^## /{c++} END{print c+0}' "$1"; }
    D=$(grep -m1 '^description:' "$S")
    printf '%s\n' "$D" | grep -qF 'スレッズの実績見せて' || MSG="$MSG dtrig1;"
    printf '%s\n' "$D" | grep -qF '今週のスレッズどうだった' || MSG="$MSG dtrig2;"
    printf '%s\n' "$D" | grep -qF '投稿の実績を記録して' && MSG="$MSG dstale;"
    C=$(SEC "$S" '^## このスキルでできること')
    printf '%s\n' "$C" | grep -qF '自動' || MSG="$MSG can_auto;"
    printf '%s\n' "$C" | grep -qF '投稿ログに記録' && MSG="$MSG can_stale;"
    RF=$(SEC "$S" '^## 参照ファイル')
    printf '%s\n' "$RF" | grep -qF 'threads-pdca-log' || MSG="$MSG ref_auto;"
    for NF in type-log.md conversion-log.md; do
      printf '%s\n' "$RF" | grep -qF -- "$NF" || MSG="$MSG ref_new:$NF;"
    done
    RT=$(printf '%s\n' "$RF" | grep -cF 'my-posts-log.md')
    RO=$(printf '%s\n' "$RF" | grep -F 'my-posts-log.md' | grep -cE '凍結|アーカイブ')
    [ "$RT" -eq "$RO" ] && [ "$RT" -ge 1 ] || MSG="$MSG ref_frozen:$RO/$RT;"
    DQ=$(printf '%s\n' "$RF" | grep -F 'draft-queue.md')
    if [ -z "$DQ" ]; then MSG="$MSG ref_nodq;"; else
      printf '%s\n' "$DQ" | grep -qF '実績を記録し' && MSG="$MSG dq_stale;"
      printf '%s\n' "$DQ" | grep -qE '自動|凍結' || MSG="$MSG dq_auto;"
    fi
    W2=$(SEC "$S" '^## ワークフロー2')
    S6=$(git show 574b9ad:"$S" | sed -n '57p')
    printf '%s\n' "$W2" | grep -qxF -- "$S6" && MSG="$MSG w2_stale6;"
    printf '%s\n' "$W2" | grep -qE '^6[.] ' || MSG="$MSG w2_no6;"
    printf '%s\n' "$W2" | grep -qE '自動収集|自動ログ|翌週' || MSG="$MSG w2_auto;"
    printf '%s\n' "$W2" | grep -F 'type-log.md' | grep -qE '追記|残す|記録' || MSG="$MSG w2_typelog;"
    CV=$(SEC "$S" '^## ワークフロー3'; SEC "$S" '^## ワークフロー4')
    printf '%s\n' "$CV" | grep -qF 'conversion-log.md' || MSG="$MSG cvref;"
    U=$(SEC "$S" '^## このスキルの使い方')
    printf '%s\n' "$U" | grep -qF '実データの自動取得は行わない' && MSG="$MSG use_stale;"
    printf '%s\n' "$U" | grep -qF '自動' || MSG="$MSG use_auto;"
    for P in TBD TODO FIXME 後で書く ghp_ github_pat_ 'Bearer ' access_token graph.threads.net okkun-secrets; do
      grep -qF -- "$P" "$S" && MSG="$MSG ban:$P;"
    done
    TS=$(wc -l < "$S" | tr -d ' '); [ "$TS" -ge 165 ] && [ "$TS" -le 320 ] || MSG="$MSG slines:$TS;"
    TL2=$(wc -l < "$L" | tr -d ' '); [ "$TL2" -ge 52 ] && [ "$TL2" -le 95 ] || MSG="$MSG llines:$TL2;"
    H=$(H2C "$S"); [ "$H" -eq 10 ] || MSG="$MSG h2:$H(want10);"
    TL="$R/type-log.md"; CL="$R/conversion-log.md"
    test -f "$TL" && test -f "$CL" || MSG="$MSG newlogs_missing;"
    if test -f "$TL" && test -f "$CL"; then
      TH=$(grep -m1 '^| ' "$TL")
      for P in 日付 狙った型; do printf '%s\n' "$TH" | grep -qF -- "$P" || MSG="$MSG tcol:$P;"; done
      printf '%s\n' "$TH" | grep -qE 'URL|permalink' || MSG="$MSG tcol:url;"
      grep -qE '自動|手入力は不要|聞かない' "$TL" || MSG="$MSG tauto;"
      grep -cE '^\| [0-9]{4}-' "$TL" | grep -qx 0 || MSG="$MSG tdummy;"
      CH=$(grep -m1 '^| ' "$CL")
      for P in 日付 コンバージョン メモ; do printf '%s\n' "$CH" | grep -qF -- "$P" || MSG="$MSG ccol:$P;"; done
      grep -qF '手動' "$CL" || MSG="$MSG cmanual;"
      grep -qE '低頻度|気が向いた|欠けて' "$CL" || MSG="$MSG cfreq;"
    fi
    git -c core.quotepath=false diff --name-only 574b9ad > /tmp/tp_ch.txt
    git -c core.quotepath=false status --porcelain | sed -n 's/^?? //p' | sed 's/^"//; s/"$//' >> /tmp/tp_ch.txt
    OK='^\.claude/skills/threads-pdca/SKILL\.md$|^\.claude/skills/threads-pdca/references/(my-posts-log|type-log|conversion-log)\.md$|^plan/playbook-threads-pdca-auto-log\.md$|^state\.md$|^docs/repository-map\.yaml$'
    PRE='^\.claude/skills/instagram-pdca/|^\.claude/skills/video-editing-ffmpeg/|^plan/inputs-ai-tools-articles-20260827\.md$'
    OUT=$(sort -u /tmp/tp_ch.txt | grep -vE "$OK" | grep -vcE "$PRE")
    [ "$OUT" -eq 0 ] || { MSG="$MSG outside:$OUT;"; sort -u /tmp/tp_ch.txt | grep -vE "$OK" | grep -vE "$PRE"; }
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "未追跡パスの抽出を `sed -n 's/^?? //p'` にしている（`awk '{print $2}'` は空白入りパスで壊れる）。git がパスをクォートした場合に備えて前後の `\"` も剥がしている。変更ファイル集合の検証では allowlist と PRE を**別々に**除外しており、PRE を allowlist に混ぜて『PRE を成果物として commit しても PASS する』事故を避けている（実際の commit 混入は ft4 で個別に弾く）"
    - consistency: "DW9 の7整合点・DW10 の4回帰点・DW11 の2ファイル要件を1本で確認しており、p1.7 と p3.1 の再実行にもなっている"
    - completeness: "DW9・DW10・DW11 の全要素を網羅"

- [ ] **p_final.6**: 隣接スキルを巻き込んでいないことを、Phase とは独立にもう一度確認する
  - executor: claudecode
  - test_command: |
    MSG=""
    IG=$(git status --porcelain -- .claude/skills/instagram-pdca/ | sed -n 's/^.\{3\}//p' | sed 's/^"//; s/"$//' | sort | tr '\n' ',')
    EXP=".claude/skills/instagram-pdca/references/my-posts-log.md,.claude/skills/instagram-pdca/references/pattern-library.md,"
    [ "$IG" = "$EXP" ] || { MSG="$MSG instagram:[$IG];"; }
    VE=$(git status --porcelain -- .claude/skills/video-editing-ffmpeg/ | sed -n 's/^.\{3\}//p' | sed 's/^"//; s/"$//' | sort | tr '\n' ',')
    EXPV=".claude/skills/video-editing-ffmpeg/SKILL.md,.claude/skills/video-editing-ffmpeg/references/shooting-basics.md,"
    [ "$VE" = "$EXPV" ] || { MSG="$MSG videoedit:[$VE];"; }
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - validations:
    - technical: "件数ではなく**ファイル名の集合**を比較している。件数だけだと『1件戻して別の1件を壊す』が素通りするうえ、無関係な変更で誤 FAIL する。実測で現状の集合と一致することを確認済み"
    - consistency: "I-8 の PRE 4件（modified）が開始時と同じ顔ぶれのままであることを確認しており、隣のスキルを巻き込んで編集した事故を検出する"
    - completeness: "instagram-pdca と video-editing-ffmpeg の両方を対象にしている"

---

## final_tasks

- [ ] **ft1**: repository-map.yaml を更新し、失敗した場合は残骸を掃除する
  - command: |
    bash .claude/hooks/generate-repository-map.sh || echo "known bug: 生成スクリプトは失敗する（下記 note 参照）"
    rm -f docs/repository-map.yaml.tmp
    test -f docs/repository-map.yaml.tmp && echo "FAIL tmpleft" || echo "OK"
  - note: |
    `.claude/hooks/generate-repository-map.sh` は**既知のバグで動作しない**
    （state.md の known_issues `repository_map_generator_broken` 参照）。
    `docs/repository-map.yaml` が更新されないこと自体は FAIL としない（修正はスコープ外）。
    `.tmp` が残ると未追跡ファイルとして p_final.5 の変更集合に現れ偽 FAIL を起こすため必ず削除する。
  - status: pending

- [ ] **ft2**: state.md を本タスクの内容に更新する
  - command: |
    grep -n 'active:\|branch:\|previous:\|milestone:\|phase:\|reviewed:' state.md
  - note: |
    **以下は pm が playbook 作成時（2026-08-31）に更新済み**なので、ft2 では
    「壊れていないこと」の確認だけでよい:
      - `playbook.active` = `plan/playbook-threads-pdca-auto-log.md`
      - `branch` = `feat/threads-pdca-auto-log`
      - `previous` = `plan/playbook-kubota-x-articles-integration.md`
      - `goal.milestone` / `goal.done_criteria`（DW1〜DW11）、旧 goal は `previous_goal_2` に退避
      - known_issues に `pre_existing_uncommitted`（5件に修正）/
        `threads_pdca_manual_log_has_real_data` / `draft_queue_stale_reference` を追加済み
    **ft2 で worker がやること**:
      - `goal.phase` を `p_final (passed, DW1〜DW11 実測)` に更新する
      - `session.last_start` / `last_end` を更新する
    `repository_map_generator_broken` / `stray_untracked_file_kubota_task` /
    `kubota_*` は引き続き有効なので**残すこと**。
  - status: pending

- [ ] **ft3**: 本タスクの成果物のみを**明示パス指定で** add し、**同じ pathspec を付けて** commit する
  - command: |
    git add .claude/skills/threads-pdca/SKILL.md \
            .claude/skills/threads-pdca/references/my-posts-log.md \
            .claude/skills/threads-pdca/references/type-log.md \
            .claude/skills/threads-pdca/references/conversion-log.md \
            plan/playbook-threads-pdca-auto-log.md state.md
    git commit -m "feat(threads-pdca): 実績記録を自動収集ログ参照に切り替え、型/CVログを分離、手動ログを凍結" -- \
            .claude/skills/threads-pdca/SKILL.md \
            .claude/skills/threads-pdca/references/my-posts-log.md \
            .claude/skills/threads-pdca/references/type-log.md \
            .claude/skills/threads-pdca/references/conversion-log.md \
            plan/playbook-threads-pdca-auto-log.md state.md
  - note: |
    - **`git add -A` および `git commit -a` は禁止。**
    - I-8 の PRE 5件（instagram-pdca 2件 / video-editing-ffmpeg 2件 /
      未追跡 `plan/inputs-ai-tools-articles-20260827.md`）は**絶対に add / commit しない。**
    - `type-log.md` / `conversion-log.md` は**未追跡なので必ず add する**。
      落とすと SKILL.md からの参照が壊れる。
    - `pattern-library.md` / `draft-queue.md` は無変更のはずなので add 対象に含めない。
    - `docs/repository-map.yaml` は ft1 の既知バグで更新されないため add 対象に含めない。
  - status: pending

- [ ] **ft4**: コミット結果を検証する（成果物6ファイルが全てコミットされ、許可外のファイルが1件も含まれない）
  - command: |
    git -c core.quotepath=false show --name-only --pretty=format: HEAD | sed '/^$/d' | sort -u > /tmp/tp_commit.txt
    MSG=""
    for P in '^\.claude/skills/threads-pdca/SKILL\.md$' \
             '^\.claude/skills/threads-pdca/references/my-posts-log\.md$' \
             '^\.claude/skills/threads-pdca/references/type-log\.md$' \
             '^\.claude/skills/threads-pdca/references/conversion-log\.md$' \
             '^plan/playbook-threads-pdca-auto-log\.md$' \
             '^state\.md$'; do
      grep -qE "$P" /tmp/tp_commit.txt || MSG="$MSG missing:$P;"
    done
    OK='^\.claude/skills/threads-pdca/SKILL\.md$|^\.claude/skills/threads-pdca/references/(my-posts-log|type-log|conversion-log)\.md$|^plan/playbook-threads-pdca-auto-log\.md$|^state\.md$'
    V=$(grep -vcE "$OK" /tmp/tp_commit.txt)
    [ "$V" -eq 0 ] || { MSG="$MSG outside:$V;"; grep -vE "$OK" /tmp/tp_commit.txt; }
    [ -z "$MSG" ] && echo PASS || echo "FAIL$MSG"
  - note: |
    `outside:` が出た場合は PRE を巻き込んでいる。`git reset --soft HEAD~1` でやり直すこと。
    `missing:` が出た場合は新規2ファイルか playbook か state.md の add 漏れ。
    ft4 の PASS 後に p_final.5 を**もう一度**実行して allowlist 回帰を確認する。
  - status: pending

- [ ] **ft5**（ネットワーク必要 / 実質必須）: 書いた手順が実際に動くかスモークテストする
  - command: |
    F=$(gh api "repos/younghastle3-source/marketing/contents/Be%20Co%20Gym/threads-pdca-log" \
          --jq '.[].name' | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.json$' | sort | tail -1)
    echo "latest=$F"
    gh api "repos/younghastle3-source/marketing/contents/Be%20Co%20Gym/threads-pdca-log/$F" \
          --jq '.content' | base64 -d > /tmp/tp_smoke.json
    jq -r '{fetched_at, followers:.profile.followers_count, total:(.posts|length),
            measurable:([.posts[]|select((.insight.data//[]|length)>0)]|length)}' /tmp/tp_smoke.json
  - note: |
    **これは SKILL.md の文面の検証ではなく、書いた手順が現実に通ることの確認**である。
    DW5(d) は `// []` と `select(` という**文字列の存在**しか見られないため、
    「ガードの語は書いてあるが実際には動かない」状態を排除するにはこのスモークテストが要る。
    そのため**任意ではなく実質必須**として扱い、ネットワークが使えない場合は
    「未実施」であることを明示して報告すること（黙って飛ばさない）。
    ネットワーク・`gh` の認証状態に依存するため p_final には入れていない。
    playbook 作成時（2026-08-31）の実測値は
    `latest=2026-08-31.json` / `followers=541` / `total=25` / `measurable=24`。
    週次 Routine が走ると値は当然変わる。**値の一致は合格条件ではない**。
    確認すべきは「コマンドがエラーなく通り、4項目が取れること」だけ。
  - status: pending

---

## pm の自己点検記録（2026-08-31 / playbook 作成時に実測）

> **目的**: レビュー往復を減らすため、提出前に「実データに基づく事実」と
> 「検証プリミティブが正常系で PASS し異常系で FAIL すること」を pm 自身が実測した記録。

### 1. 外部データの実在確認（`gh api` で実測）

| 対象 | 結果 |
|---|---|
| `Be Co Gym/threads-pdca-log/` の中身 | `2026-08-31.json`（63,108 bytes）**1件のみ** |
| `Be Co Gym/threads-pdca-criteria.md` | 707 bytes。3指標が記載（I-3 に全文転記） |
| `gh auth status` | `younghastle3-source` でログイン済み（GITHUB_TOKEN） |
| パスのスペース | `Be%20Co%20Gym` で成功。**スペースのままでも成功した**が `%20` を正とする |
| 最新ファイル選択 | `--jq '.[].name' \| grep -E '^[0-9]{4}-...' \| sort \| tail -1` → `2026-08-31.json` |

### 2. JSON スキーマと集計の実測

```
posts 総数            25
insight.data が5指標   24件
insight.data が空配列  1件（id 18003754760785852 / 2026-08-23 / meta.text も null）
name のユニーク値      ["likes","quotes","replies","reposts","views"]  ← 保存(saves)は無い
timestamp 範囲        2026-08-18T22:00:56+0000 〜 2026-08-28T22:00:20+0000
profile.followers_count 541（criteria.md の更新履歴は「欠損」と書いているが実際は存在する）
```

**素朴な jq は実際にクラッシュした**（`null (null) and number (541) cannot be divided`）。
`.insight.data // []` + `select(length>0)` でガードしたら通った。
→ I-2 の落とし穴3・DW5(d) はこの実測に基づく。

**集計結果**: views 合計 29,414 / 平均 1,226 / **中央値 512** / 最大 18,220 / 2位 2,035 / 3位 836。
床超え 24件中2件、倍率 2.27、エンゲージ率 0.9%。
→ **平均(1,226) と中央値(512) が 2.4 倍も乖離している**。これが I-2 の落とし穴2・DW5(b) の根拠。

### 3. 検証プリミティブの実測（base_commit 574b9ad の実ファイルに対して）

| 項目 | 実測 |
|---|---|
| `SKILL.md` 行数 / H2 / H3 | 118 / 9 / 2 |
| `my-posts-log.md` 行数 / `^\| 2026` / `^\|` | 59 / **40** / 42 |
| base で**0件**（新規語として有効） | `threads-pdca-log` `threads-pdca-criteria` `followers_count` `エンゲージ率` `倍率` `床` `views` `permalink` `base64` `fetched_at` `jq` `自動収集` `okkun_lifestyle` `計測不可` `中央値` `手入力` `type-log` `conversion-log` |
| base で**既出**（区間限定が必須） | `gh api` 2件（全て `## 参照リポジトリ` 内）/ `Be Co Gym` 1件 / `コピペ` 2件（うち1件は**保護対象のワークフロー1内**）/ `手渡` 2件（同上） |
| 旧文言の所在 | `投稿の実績を記録して`→3行目(frontmatter)と70行目(WF3) / `投稿ログに記録`→22行目 / `の投稿実績ログの表に1行追記`→76行目 / `実データの自動取得は行わない`→118行目 / `手入力で記録するテンプレート`→my-posts-log 3行目 / `データ行は投稿の都度…`→同59行目 |
| `.claude/skills/threads-pdca/` の未コミット差分 | **0件**（ユーザー申告どおり。p1.0 で再確認する） |
| `references/` の実体 | `pattern-library.md` / `my-posts-log.md` / `draft-queue.md` の**3件のみ**。`hook-design.md` / `research-method.md` は**存在しない** |
| `git diff main 574b9ad -- .claude/skills/threads-pdca/` | **空**（main と HEAD で当該スキルは同一） |

### 4. 構文チェックと全 test_command の実行

本 playbook の `test_command:` / `command:` ブロックを機械抽出し、
**`bash -n` と `zsh -n` の両方で構文エラー0**を確認した。
検証系は**bash と zsh の両方で実行して結果が完全一致**することも確認済み。

### 5. モック実装による正常系検証（reviewer の推奨に基づき追加）

> **これが今回もっとも多くの欠陥を発見した工程である。**

base から**保護区間を逐語でコピーし、I-7 / I-10 の全要件を満たす「正しい実装」のモック**を作成した：

```
mock/SKILL.md          183行（H2 10本。新セクション + WF3/WF4 書き換え + 整合済み）
mock/my-posts-log.md    64行（表42行は base から逐語コピー + 凍結ヘッダ + 移行メモ）
mock/type-log.md         8行
mock/conversion-log.md   7行
```

これに対し検証系10本を実行した結果:

| 対象 | 結果 |
|---|---|
| **モック（正しい実装）** | **10本すべて PASS**（bash / zsh 両方） |
| base（未編集） | 保護系（p1.1 相当 / p2.1 相当）のみ PASS、内容系8本は具体的な不足を名指しして FAIL |

**このモック検証で発見・修正した欠陥（いずれも「正しい実装を FAIL させる」か「誤りを見逃す」もの）:**

| # | 欠陥 | 発見のしかた | 修正 |
|---|---|---|---|
| C1 | 区間抽出の終端 `/^#{1,2} /` が**コードブロック内の `# 1)` にマッチ**し、`## 自動収集データの読み方` 区間が冒頭3行で打ち切られる。`gh api` が 2→0 になり **p1.2〜p1.6 が全滅** | モックにコマンド例を入れた時点で全滅した | **フェンス対応 SEC / BSEC / H2C** に置換。終端は `^## ` のみ |
| m3 | criteria.md を ```` ```markdown ```` で引用すると `grep -c '^## '` が引用内の `## 見る数字` を数え、H2 本数が **10→12** に化ける | 引用を足したモックで再現 | H2 本数を `H2C`（フェンス対応）で数える |
| C2 | 表ヘッダ検証 `grep -E '^\| 日付 \|'` は `\|` が ERE の選択演算子なので**常に真**＝無効な検査。並べ替えも素通り | データ行2行を入れ替えても検出されなかった | `diff <(base の `^\|` 行) <(現在の `^\|` 行)` に置換 |
| M1 | `nocolumnnote` が**表のヘッダ行自身にマッチ**して常に成立 | 記入方法を丸ごと削っても PASS した | `grep -v '^\|'` で表を除外してから数える |
| — | 禁止語 `1行追記` が、新設の**正当な記述**「`conversion-log.md` に1行追記する」と衝突 | モックが `stale:1行追記` で誤 FAIL | 禁止語を `の投稿実績ログの表に1行追記` に長く取り直した |
| — | 行数下限 **185 が厳しすぎた**（要件を全部満たすモックが 177〜183 行） | モックが `lines:183(185-320)` で誤 FAIL | 下限を **165** に緩和 |

### 6. 異常系（ミューテーションによる実測 / 実行後は全て復元済み）

| # | 加えた変更 | 検出した出力 |
|---|---|---|
| NEG-1 | `pattern-library.md` に**空行を1行だけ**追記 | `FAIL protected:pattern-library.md` |
| NEG-2 | `my-posts-log.md` のデータ行1本から2文字削除 | `FAIL table;` |
| NEG-3 | `my-posts-log.md` のデータ行を**1行削除** | `FAIL rows:39(want40); table;` |
| NEG-4 | データ行を**2行入れ替え**（内容は不変） | `FAIL table;`（**旧方式の行ごと照合は欠落0件で素通りした**） |
| NEG-5 | `## 断らせるチェックのコツ（本音を引き出すコツ）` を `## 断らせるチェックのコツ` に短縮 | `FAIL head:102;` |
| NEG-6 | ワークフロー2 手順6 を base のまま残す | `FAIL w2_stale6; w2_auto;` |
| NEG-7 | jq ガード（`// []` と `select(`）を削除 | `FAIL jqdefault; jqselect;` |
| NEG-8 | `fetched_at` の鮮度警告を削除 | `FAIL p:fetched_at; stale7; staleold;` |
| NEG-9 | 参照ファイルの my-posts-log 行から凍結語を外す | `FAIL ref_frozen:0/1;`（ALL セマンティクスが効いた） |
| NEG-10 | `## 記入方法` を丸ごと削除 | `FAIL nocolumnnote:1;` |
| NEG-11 | 新セクションに `# 1)` の bash コメントを追加 | **PASS を維持**（C1 修正の確認） |
| NEG-12 | criteria.md 引用ブロックを追加（`## 見る数字` 入り） | **PASS を維持**（生 grep は 12 を返すが `H2C` は 10） |
| NEG-13 | `references/hack.md` を新規作成 | `newfiles BAD: .claude/skills/threads-pdca/references/hack.md` |

実行後 `git status --porcelain -- .claude/skills/threads-pdca/` が **0行**であることを確認済み。

### 7. 残る未検証事項（構造上、機械検証できないもの）

- **書き換え後のワークフロー3が「実際に実行して有用な結果を返すか」**は自然言語の手順である以上
  grep では担保できない。ft5 のスモークテストと、実運用でユーザーが
  「スレッズの実績見せて」と発話したときの結果で確認するしかない。
- **型の推定精度**（自動ログの `text` から A〜J を当てる）は LLM の判断であり正解データが無い。
  DW8 は「推定する手順が書かれていること」までしか担保しない。
  ただし **`type-log.md` の導入により、今後の投稿については推定ではなく実際に選んだ型が残る**ので、
  この不確実性は時間とともに縮小する。
- **ワークフロー2 が実際に `type-log.md` へ追記するか**は、次にユーザーが下書きを依頼したときに
  初めて分かる。DW9(d) は「追記する手順が書かれていること」までしか担保しない。
- **`threads-pdca-criteria.md` が将来更新されたとき**の追随は DW6（毎回読む・ハードコードしない）で
  構造的に担保しているが、実際の追随は次回以降の実行時にしか確認できない。
- **週次 Routine が今後もログを追加し続けるか**は本リポジトリの外の事情。
  DW4(f) の鮮度警告（`fetched_at` が7日以上前なら先に告げる）で、ユーザーが気づける設計にしてある。

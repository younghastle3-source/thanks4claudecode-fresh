# playbook-gym-business-plan.md

> **2027年ジム開業に向けた事業計画書・開業戦略の作成支援 playbook**

---

## meta

```yaml
project: gym-business-plan
branch: claude/gym-business-plan-nYgyP
created: 2026-04-17
issue: null
derives_from: null  # thanks4claudecode プロジェクトとは独立した外部タスク
reviewed: false
roles:
  orchestrator: claudecode
  worker: claudecode
  reviewer: claudecode
  human: user
```

> このタスクは thanks4claudecode の milestone とは独立した教育・コンサル系タスクである。
> 成果物は `docs/gym-business/` 配下に配置し、ユーザーが実務で使えるドキュメント一式を整える。

---

## goal

```yaml
summary: "2027 年ジム開業に向けた事業計画書テンプレートと開業戦略一式を作成する"
done_when:
  - "docs/gym-business/README.md が存在し、全ドキュメントへのインデックスを提供している"
  - "docs/gym-business/business-plan-template.md が存在し、事業計画書の全セクション（9 項目以上）を含む"
  - "docs/gym-business/market-research.md が存在し、市場規模・顧客像・立地観点のリサーチがまとまっている"
  - "docs/gym-business/competitor-analysis.md が存在し、競合カテゴリ（3 種以上）ごとの比較がまとまっている"
  - "docs/gym-business/revenue-model.md が存在し、料金プラン・収支試算・損益分岐点の計算式が含まれている"
  - "docs/gym-business/opening-strategy.md が存在し、開業までのロードマップ（12〜18 ヶ月）が時系列で整理されている"
  - "docs/gym-business/how-to-write-business-plan.md が存在し、事業計画書の書き方ガイド（教育コンテンツ）が含まれている"
```

---

## phases

### p1: 事業計画書の書き方ガイド（教育コンテンツ）

**goal**: ジム事業計画書の書き方を、初心者でも理解できる教育コンテンツとしてまとめる

#### subtasks

- [ ] **p1.1**: docs/gym-business/ ディレクトリが存在する
  - executor: claudecode
  - test_command: `test -d docs/gym-business && echo PASS || echo FAIL`
  - validations:
    - technical: "ディレクトリ作成コマンドが成功する"
    - consistency: "他の docs/ 配下と同じ階層構造で配置されている"
    - completeness: "後続 phase で作成する全ファイルの配置先として機能する"

- [ ] **p1.2**: docs/gym-business/how-to-write-business-plan.md が存在し、事業計画書の9セクション以上が解説されている
  - executor: claudecode
  - test_command: `test -f docs/gym-business/how-to-write-business-plan.md && grep -cE '^## ' docs/gym-business/how-to-write-business-plan.md | awk '{if($1>=9) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "Markdown として正しく構造化されている（## 見出しで 9 個以上のセクション）"
    - consistency: "business-plan-template.md の各セクションと対応付けがある"
    - completeness: "エグゼクティブサマリー・事業概要・市場分析・競合分析・マーケティング戦略・運営計画・組織体制・財務計画・リスク分析の 9 項目を網羅"

- [ ] **p1.3**: how-to-write-business-plan.md に「ジム業界特有の注意点」セクションがある
  - executor: claudecode
  - test_command: `grep -qE 'ジム業界|フィットネス業界|特有' docs/gym-business/how-to-write-business-plan.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep で該当キーワードが検出できる"
    - consistency: "汎用の事業計画書ガイドではなく、ジム特化の観点が入っている"
    - completeness: "立地・設備投資・会員モデル等、ジム特有の論点が最低 3 点以上含まれる"

**status**: pending
**max_iterations**: 5

---

### p2: 市場調査・リサーチ

**goal**: 日本のフィットネス／ジム市場の基礎データと、2027 年開業に向けたトレンドを整理する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: docs/gym-business/market-research.md が存在する
  - executor: claudecode
  - test_command: `test -f docs/gym-business/market-research.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在する"
    - consistency: "他の gym-business/ ドキュメントから相互リンクされる前提で配置"
    - completeness: "市場規模・顧客像・立地の観点が含まれる"

- [ ] **p2.2**: market-research.md に市場規模・成長率・顧客セグメントの 3 観点以上が含まれている
  - executor: claudecode
  - test_command: `grep -cE '^## ' docs/gym-business/market-research.md | awk '{if($1>=3) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "3 つ以上のセクションが存在"
    - consistency: "revenue-model.md の前提条件として参照できる数値が含まれる"
    - completeness: "市場規模・ターゲット顧客・トレンド（パーソナル/24h/女性専用/総合等）を網羅"

- [ ] **p2.3**: market-research.md に「情報ソースの注意書き」セクションが存在する
  - executor: claudecode
  - test_command: `grep -qE '情報ソース|出典|注意|確認' docs/gym-business/market-research.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep で該当キーワードが検出できる"
    - consistency: "LLM が提供する数値は暫定値であり、実務では一次ソースで再確認が必要である旨を明示"
    - completeness: "総務省・経産省・業界団体など、ユーザーが参照すべき一次ソースが列挙されている"

**status**: pending
**max_iterations**: 5

---

### p3: 競合分析

**goal**: ジム業界の主要競合カテゴリと差別化軸を整理する

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: docs/gym-business/competitor-analysis.md が存在する
  - executor: claudecode
  - test_command: `test -f docs/gym-business/competitor-analysis.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在する"
    - consistency: "market-research.md の顧客セグメントと対応している"
    - completeness: "競合分析の枠組みが揃っている"

- [ ] **p3.2**: competitor-analysis.md に 3 カテゴリ以上の競合タイプが比較されている
  - executor: claudecode
  - test_command: `grep -cE '^### ' docs/gym-business/competitor-analysis.md | awk '{if($1>=3) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "### 見出しで 3 個以上の競合カテゴリが列挙されている"
    - consistency: "総合型・24h 型・パーソナル型・女性専用型など、実在するカテゴリと対応している"
    - completeness: "各カテゴリについて 価格帯・顧客層・強み・弱み の 4 観点が整理されている"

- [ ] **p3.3**: competitor-analysis.md に「差別化戦略の検討フレーム」セクションがある
  - executor: claudecode
  - test_command: `grep -qE '差別化|ポジショニング|strategy' docs/gym-business/competitor-analysis.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep で該当キーワードが検出できる"
    - consistency: "opening-strategy.md の戦略立案パートから参照される"
    - completeness: "SWOT や 4P などユーザーが実際に埋められるフレームが 1 つ以上提示されている"

**status**: pending
**max_iterations**: 5

---

### p4: 収益モデル

**goal**: ジム事業の料金体系と損益構造を明示し、ユーザーが自分の前提値で試算できるテンプレートを提供する

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: docs/gym-business/revenue-model.md が存在する
  - executor: claudecode
  - test_command: `test -f docs/gym-business/revenue-model.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在する"
    - consistency: "market-research.md の顧客数前提と整合"
    - completeness: "収益モデルの説明が含まれる"

- [ ] **p4.2**: revenue-model.md に料金プランの型（月額固定/都度/パーソナル等）が 3 種類以上列挙されている
  - executor: claudecode
  - test_command: `grep -cE '月額|都度|パーソナル|ドロップイン|回数券' docs/gym-business/revenue-model.md | awk '{if($1>=3) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "grep で 3 種類以上のプランキーワードが検出できる"
    - consistency: "競合分析で挙げた価格帯と整合"
    - completeness: "各プランの特徴・想定顧客・粗利感が記載されている"

- [ ] **p4.3**: revenue-model.md に「損益分岐点の計算式」または数式が含まれている
  - executor: claudecode
  - test_command: `grep -qE '損益分岐|BEP|固定費.*変動費|fixed.*variable' docs/gym-business/revenue-model.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep で損益分岐関連のキーワードが検出できる"
    - consistency: "business-plan-template.md の財務計画セクションから参照される"
    - completeness: "固定費・変動費・会員単価・必要会員数の関係が式または表で示されている"

**status**: pending
**max_iterations**: 5

---

### p5: 開業戦略ロードマップ

**goal**: 今（2026-04）から 2027 年開業までの 12〜18 ヶ月ロードマップを時系列で整理する

**depends_on**: [p4]

#### subtasks

- [ ] **p5.1**: docs/gym-business/opening-strategy.md が存在する
  - executor: claudecode
  - test_command: `test -f docs/gym-business/opening-strategy.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在する"
    - consistency: "market-research / competitor-analysis / revenue-model の結論を参照する位置づけ"
    - completeness: "戦略ドキュメントとして独立して読める構造になっている"

- [ ] **p5.2**: opening-strategy.md に時系列ロードマップ（4 フェーズ以上）が含まれている
  - executor: claudecode
  - test_command: `grep -cE '^### |^\- \*\*(Phase|フェーズ|ヶ月|か月|月目)' docs/gym-business/opening-strategy.md | awk '{if($1>=4) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "4 フェーズ相当の時系列区切りが文書内に存在する"
    - consistency: "2027 年開業を逆算した現実的なスケジュールになっている"
    - completeness: "構想 → 事業計画 → 物件 → 資金調達 → 内装 → 集客 → オープンの主要マイルストーンが含まれる"

- [ ] **p5.3**: opening-strategy.md に「資金調達・融資の選択肢」セクションが含まれている
  - executor: claudecode
  - test_command: `grep -qE '融資|資金調達|日本政策金融公庫|補助金|助成金' docs/gym-business/opening-strategy.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep で資金調達関連キーワードが検出できる"
    - consistency: "revenue-model.md の初期投資額と整合する融資額が例示されている"
    - completeness: "自己資金・金融機関融資・公庫・補助金など複数の選択肢が提示されている"

**status**: pending
**max_iterations**: 5

---

### p6: 事業計画書テンプレート（ユーザーがそのまま使える）

**goal**: p1-p5 の知見を統合し、ユーザーが穴埋めで完成させられる事業計画書テンプレートを提供する

**depends_on**: [p1, p2, p3, p4, p5]

#### subtasks

- [ ] **p6.1**: docs/gym-business/business-plan-template.md が存在する
  - executor: claudecode
  - test_command: `test -f docs/gym-business/business-plan-template.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在する"
    - consistency: "how-to-write-business-plan.md の構成と 1:1 対応"
    - completeness: "事業計画書として提出可能な体裁を備える"

- [ ] **p6.2**: business-plan-template.md が 9 セクション以上の完全な事業計画書構造を持つ
  - executor: claudecode
  - test_command: `grep -cE '^## ' docs/gym-business/business-plan-template.md | awk '{if($1>=9) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "## 見出しで 9 セクション以上が存在"
    - consistency: "how-to-write-business-plan.md の解説と同じ順序・同じ項目"
    - completeness: "エグゼクティブサマリー/事業概要/市場分析/競合分析/マーケティング/運営/組織/財務/リスク を網羅"

- [ ] **p6.3**: business-plan-template.md 内に「穴埋め用プレースホルダ」が 10 個以上含まれている
  - executor: claudecode
  - test_command: `grep -cE '\{[^}]+\}|\[.*記入.*\]|\[.*ここに.*\]|TODO|FILL' docs/gym-business/business-plan-template.md | awk '{if($1>=10) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "プレースホルダが 10 個以上検出される"
    - consistency: "ユーザーが埋めるべき箇所と、例示として提供済みの箇所が明確に区別されている"
    - completeness: "全セクションにプレースホルダが行き渡っており、穴埋めで完成する"

**status**: pending
**max_iterations**: 5

---

### p7: ドキュメント索引（README）の整備

**goal**: ユーザーが `docs/gym-business/` をどう読み進めれば良いかを示すインデックスを作成する

**depends_on**: [p6]

#### subtasks

- [ ] **p7.1**: docs/gym-business/README.md が存在する
  - executor: claudecode
  - test_command: `test -f docs/gym-business/README.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在する"
    - consistency: "他の全ドキュメントへのリンクを持つ"
    - completeness: "初見のユーザーがどこから読めばよいか分かる"

- [ ] **p7.2**: README.md から全 6 ドキュメント（how-to / market / competitor / revenue / opening / template）へのリンクが存在する
  - executor: claudecode
  - test_command: `grep -cE '\]\((\./)?(how-to-write-business-plan|market-research|competitor-analysis|revenue-model|opening-strategy|business-plan-template)\.md\)' docs/gym-business/README.md | awk '{if($1>=6) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "Markdown リンク記法で 6 個以上のリンクが検出できる"
    - consistency: "リンク先ファイル名が実在する"
    - completeness: "全ドキュメントへの導線が揃っている"

- [ ] **p7.3**: README.md に「推奨される読む順序」セクションが存在する
  - executor: claudecode
  - test_command: `grep -qE '読む順序|推奨.*順|Recommended.*order|はじめに' docs/gym-business/README.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep で該当キーワードが検出できる"
    - consistency: "依存関係（market → competitor → revenue → strategy → template）と整合"
    - completeness: "初心者でも迷わない順番が明示されている"

**status**: pending
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: goal.done_when が全て満たされていることを自動検証する

**depends_on**: [p1, p2, p3, p4, p5, p6, p7]

#### subtasks

- [ ] **p_final.1**: docs/gym-business/README.md が存在し、インデックスとして機能している
  - executor: claudecode
  - test_command: `test -f docs/gym-business/README.md && grep -cE '\.md\)' docs/gym-business/README.md | awk '{if($1>=6) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "ファイルが存在し、かつ 6 個以上の .md リンクを含む"
    - consistency: "実在するファイルへのリンクのみ"
    - completeness: "インデックスとしての網羅性がある"

- [ ] **p_final.2**: business-plan-template.md が 9 セクション以上を持つ
  - executor: claudecode
  - test_command: `test -f docs/gym-business/business-plan-template.md && grep -cE '^## ' docs/gym-business/business-plan-template.md | awk '{if($1>=9) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "grep で 9 セクション以上が検出される"
    - consistency: "how-to-write-business-plan.md と構成が一致"
    - completeness: "事業計画書として必要な全項目を網羅"

- [ ] **p_final.3**: 市場調査 / 競合分析 / 収益モデルの 3 ドキュメントが全て存在する
  - executor: claudecode
  - test_command: `test -f docs/gym-business/market-research.md && test -f docs/gym-business/competitor-analysis.md && test -f docs/gym-business/revenue-model.md && echo PASS || echo FAIL`
  - validations:
    - technical: "3 ファイルが全て存在"
    - consistency: "各ファイルがそれぞれの Phase の成果物と一致"
    - completeness: "戦略立案に必要な 3 本柱が揃っている"

- [ ] **p_final.4**: opening-strategy.md が存在し、時系列ロードマップを含む
  - executor: claudecode
  - test_command: `test -f docs/gym-business/opening-strategy.md && grep -cE '^### |月目|ヶ月|か月|Phase' docs/gym-business/opening-strategy.md | awk '{if($1>=4) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "ファイルが存在し、4 フェーズ以上が検出される"
    - consistency: "2027 年開業に向けた現実的なスケジュール"
    - completeness: "構想から開業までの主要マイルストーンを網羅"

- [ ] **p_final.5**: how-to-write-business-plan.md が教育コンテンツとして機能する
  - executor: claudecode
  - test_command: `test -f docs/gym-business/how-to-write-business-plan.md && wc -l docs/gym-business/how-to-write-business-plan.md | awk '{if($1>=80) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "ファイルが 80 行以上存在する"
    - consistency: "business-plan-template.md の各セクションに対応した解説がある"
    - completeness: "初心者が読んで事業計画書を書き始められる内容"

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

- [ ] **ft3**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## notes

```yaml
スコープ明示:
  - 本 playbook は「事業計画書の作成を支援する教材・テンプレート」の作成である
  - 実際の開業手続き（法人登記、物件契約、保健所届出など）はスコープ外
  - LLM が提供する市場データ・数値は一次ソースでの再検証が前提

想定ユーザー:
  - 2027 年にジム（形態は未確定）を開業したい個人事業主または起業家
  - 事業計画書を書いたことがない、またはブラッシュアップしたい人

成果物の配置:
  - 全て docs/gym-business/ 配下
  - 7 ファイル構成:
    1. README.md（索引）
    2. how-to-write-business-plan.md（教育コンテンツ）
    3. market-research.md（市場調査）
    4. competitor-analysis.md（競合分析）
    5. revenue-model.md（収益モデル）
    6. opening-strategy.md（開業戦略）
    7. business-plan-template.md（穴埋めテンプレート）
```

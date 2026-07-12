# playbook-human-touch-writing-skill.md

> **「AIっぽい文章を卒業して『この人にお願いしたい』を生む人間味ライティング」をスキル化する。**
> ChatGPTで生成した文章をそのまま使わず、書き手の体験・感情・人柄が伝わる文章に整える方法論を、SNS投稿作成時に参照できるスキルとして体系化する。

---

## meta

```yaml
project: plan-template
branch: feat/human-touch-writing-skill
created: 2026-07-12
issue: null
derives_from: null  # project.done_when 未定義（単発スキル化タスク）
reviewed: true  # reviewer 検証 PASS（criterion 形式・test_command 実行性・done_when↔p_final 1:1 整合・既存スキル frontmatter 一貫性を確認）
```

> **既存スキルとの関係**: `threads-post-checklist`（投稿前後のセルフレビュー診断）や `threads-shukyaku-7days`（集客土台設計）とは別スキルとして作成する。
> - 既存: 「投稿の質を8観点でチェックする」「何を投稿するかの設計」
> - 今回: 「AI生成文を人間味のある文章に整える方法論」= 体験・感情・人柄が伝わる文章の書き方と、ChatGPTを編集パートナーとして使う具体的プロンプト・自己チェック
> slug: `human-touch-writing`

---

## goal

```yaml
summary: AIっぽい文章を卒業し、体験・感情・人柄が伝わる人間味ライティングの方法論をスキルとして体系化する
done_when:
  - ".claude/skills/human-touch-writing/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "人間味ライティングの3つの具体策（体験ストーリー・会話スタイル・PREP法）が全て記載されている"
  - "ChatGPT活用の3つのプロンプト（口語調変換・冗長削除・PREP法再構成）が記載されている"
  - "AI出力チェックの3つの視点（声出し確認・AIっぽい記号の整理・体験と感情の確認）が記載されている"
  - "frontmatter 形式が既存スキル（becofit-gym-startup, threads-post-checklist 等）と一貫している"
```

---

## phases

### p1: SKILL.md 本文作成

**goal**: human-touch-writing/SKILL.md を作成し、frontmatter と3章構成（体験と感情の原則／人間味ライティング3つの具体策／ChatGPTを編集パートナーとして使う方法）を記載する

#### subtasks

- [ ] **p1.1**: `.claude/skills/human-touch-writing/SKILL.md` が存在する
  - executor: claudecode
  - test_command: `test -f .claude/skills/human-touch-writing/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが指定パスに存在する"
    - consistency: "既存スキルと同じ .claude/skills/{slug}/SKILL.md の配置規則に従っている"
    - completeness: "ディレクトリとファイルが両方作成されている"

- [ ] **p1.2**: SKILL.md が frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; grep -q '^name: human-touch-writing' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "name/description/triggers の3キーが frontmatter に存在する"
    - consistency: "name が slug（human-touch-writing）と一致し、既存スキル（becofit-gym-startup, threads-post-checklist）と同じ YAML frontmatter 形式"
    - completeness: "triggers に起動フレーズが1つ以上列挙されている"

- [ ] **p1.3**: 第1章「体験と感情が情報を超える原則」が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; grep -qE '情報過多|情報だけ' "$f" && grep -qE '体験.*感情|感情.*体験' "$f" && grep -qE 'この人|共感' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "情報過多の時代／体験+感情の価値／共感の原則の3要素が検出できる"
    - consistency: "依頼の第1章（情報だけでは動かない・人間だけが書ける価値・共感の原則）と対応している"
    - completeness: "第1章の3論点がすべて含まれている"

- [ ] **p1.4**: 人間味ライティングの3つの具体策（体験ストーリー・会話スタイル・PREP法）が全て記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; grep -qE '体験ストーリー' "$f" && grep -qE '会話スタイル' "$f" && grep -qE 'PREP' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "「体験ストーリー」「会話スタイル」「PREP」の3語がすべて検出できる"
    - consistency: "第2章の3具体策（出来事＋感情＋学び／くだけた表現・問いかけ／結論→理由/共感→具体例→結論再提示）と対応している"
    - completeness: "3つの具体策すべてに説明が付いている"

- [ ] **p1.5**: ChatGPT活用の3つのプロンプト（口語調変換・冗長削除・PREP法再構成）が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; grep -qE '口語調' "$f" && grep -qE '冗長|テンポ' "$f" && grep -qE 'PREP.*再構成|再構成.*PREP' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "「口語調」「冗長/テンポ」「PREP法再構成」の3プロンプト要素が検出できる"
    - consistency: "第3章の役割分担（魂は自分・整形はAI）と3プロンプトが対応している"
    - completeness: "3つのプロンプトすべてに具体的な指示文が記載されている"

- [ ] **p1.6**: AI出力チェックの3つの視点（声出し確認・AIっぽい記号の整理・体験と感情の確認）が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; grep -qE '声に出|音読' "$f" && grep -qE 'AIっぽい|記号' "$f" && grep -qE '経験.*感情|体験.*感情' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "「声に出して読む」「AIっぽい記号」「経験と感情の確認」の3視点が検出できる"
    - consistency: "第3章の自己チェック3項目と対応している"
    - completeness: "3つのチェック視点すべてに確認方法が記載されている"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **playbook の done_when が全て満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; test -f "$f" && grep -q '^name:' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と3キーの存在を1コマンドで確認できる"
    - consistency: "done_when 項目1と対応"
    - completeness: "frontmatter が完全に揃っている"

- [ ] **p_final.2**: 人間味ライティングの3つの具体策（体験ストーリー・会話スタイル・PREP法）が全て記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; grep -qE '体験ストーリー' "$f" && grep -qE '会話スタイル' "$f" && grep -qE 'PREP' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "3具体策の3語がすべて検出できる"
    - consistency: "done_when 項目2と対応"
    - completeness: "3つの具体策すべてが揃っている"

- [ ] **p_final.3**: ChatGPT活用の3つのプロンプト（口語調変換・冗長削除・PREP法再構成）が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; grep -qE '口語調' "$f" && grep -qE '冗長|テンポ' "$f" && grep -qE 'PREP.*再構成|再構成.*PREP' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "3プロンプト要素がすべて検出できる"
    - consistency: "done_when 項目3と対応"
    - completeness: "3つのプロンプトすべてが揃っている"

- [ ] **p_final.4**: AI出力チェックの3つの視点（声出し確認・AIっぽい記号の整理・体験と感情の確認）が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; grep -qE '声に出|音読' "$f" && grep -qE 'AIっぽい|記号' "$f" && grep -qE '経験.*感情|体験.*感情' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "3チェック視点がすべて検出できる"
    - consistency: "done_when 項目4と対応"
    - completeness: "3つのチェック視点すべてが揃っている"

- [ ] **p_final.5**: frontmatter 形式が既存スキルと一貫している
  - executor: claudecode
  - test_command: `f=.claude/skills/human-touch-writing/SKILL.md; head -1 "$f" | grep -q '^---$' && grep -q '^triggers:' "$f" && grep -qE '^  - ' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "1行目が --- で始まり、triggers がリスト形式（  - ）である"
    - consistency: "done_when 項目5と対応。becofit-gym-startup / threads-post-checklist と同じ frontmatter 構造"
    - completeness: "既存スキルの命名・記述規約に完全準拠している"

**status**: done
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

# playbook-trust-building-posts-skill.md

> **「信頼を育てる投稿作り」をスキル化する。**
> フォロワー数やバズといった「数字」よりも、安心感・信頼を育てることを軸に、
> 申し込みにつながる4つの投稿テーマ（悩み寄り添い・解決ヒント・お客様の声・自分の思い）を
> 体系化し、SNS投稿作成時に参照できるスキルとして提供する。

---

## meta

```yaml
project: plan-template
branch: feat/trust-building-posts-skill
created: 2026-07-12
issue: null
derives_from: null  # project.done_when 未定義（単発スキル化タスク）
reviewed: true  # reviewer 検証 PASS（criterion 状態形式・test_command 実行性確認・done_when↔p_final 1:1 整合・既存スキル frontmatter 一貫性を確認）
```

> **既存スキルとの関係**: `human-touch-writing`（AI文章を人間味のある文章に整える方法論）や
> `threads-post-checklist`（投稿前後のセルフレビュー診断）とは別スキルとして作成する。
> - `human-touch-writing`: 「どう書くか」（文章の質・人間味の出し方）
> - `threads-post-checklist`: 「投稿を8観点でチェックする」
> - 今回 `trust-building-posts`: 「何を投稿するか」= 申し込みにつながる4つの投稿テーマの体系化。
>   数字ではなく信頼・安心感を育てる投稿設計の考え方。
> slug: `trust-building-posts`

---

## goal

```yaml
summary: フォロワー数より信頼・安心感を軸に、申し込みにつながる4つの投稿テーマを体系化したスキルを作成する
done_when:
  - ".claude/skills/trust-building-posts/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "核心の気づき（フォロワー数より信頼・安心感が申し込みにつながる）が記載されている"
  - "4つの投稿テーマ（悩み寄り添い・解決ヒント・お客様の声・自分の思い）が全て記載されている"
  - "各テーマに具体例または実践のポイントが記載されている"
  - "frontmatter 形式が既存スキル（human-touch-writing, becofit-gym-startup 等）と一貫している"
```

---

## phases

### p1: SKILL.md 本文作成

**goal**: trust-building-posts/SKILL.md を作成し、frontmatter と本文（核心の気づき／申し込みにつながる4つの投稿テーマ）を記載する

#### subtasks

- [ ] **p1.1**: `.claude/skills/trust-building-posts/SKILL.md` が存在する
  - executor: claudecode
  - test_command: `test -f .claude/skills/trust-building-posts/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが指定パスに存在する"
    - consistency: "既存スキルと同じ .claude/skills/{slug}/SKILL.md の配置規則に従っている"
    - completeness: "ディレクトリとファイルが両方作成されている"

- [ ] **p1.2**: SKILL.md が frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; grep -q '^name: trust-building-posts' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "name/description/triggers の3キーが frontmatter に存在する"
    - consistency: "name が slug（trust-building-posts）と一致し、既存スキル（human-touch-writing, becofit-gym-startup）と同じ YAML frontmatter 形式"
    - completeness: "triggers に起動フレーズが1つ以上列挙されている"

- [ ] **p1.3**: 核心の気づき（フォロワー数より信頼・安心感が申し込みにつながる）が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; grep -qE 'フォロワー|バズ|数字' "$f" && grep -qE '安心|信頼' "$f" && grep -qE '申し込み|相談したい|あなただから' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "数字（フォロワー/バズ）／安心・信頼／申し込みへの接続の3要素が検出できる"
    - consistency: "依頼の核心の気づき（数字より安心感・信頼／この人に相談したい・この人なら安心／あなただからと選ばれる）と対応している"
    - completeness: "核心の3論点がすべて含まれている"

- [ ] **p1.4**: 4つの投稿テーマ（悩み寄り添い・解決ヒント・お客様の声・自分の思い）が全て記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; grep -qE '寄り添|お悩み|悩み' "$f" && grep -qE '解決.*ヒント|ヒントを渡' "$f" && grep -qE 'お客様の声|変化を見せ' "$f" && grep -qE '思い|経験を伝え' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "「悩み寄り添い」「解決ヒント」「お客様の声/変化」「自分の思い/経験」の4テーマがすべて検出できる"
    - consistency: "依頼の4つの投稿テーマと1:1で対応している"
    - completeness: "4つのテーマすべてに見出しと説明が付いている"

- [ ] **p1.5**: 各テーマに具体例または実践のポイントが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; grep -qE 'お問い合わせ|リサーチ|いいねが多い' "$f" && grep -qE 'できそう|小さなノウハウ' "$f" && grep -qE '感想|参加前後|雰囲気|写真' "$f" && grep -qE '温度感|なぜこの仕事|大切にしている' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "4テーマそれぞれの実践ヒント（過去のお問い合わせ/リサーチ・できそうなノウハウ・感想/参加前後の変化/写真・温度感/なぜこの仕事を）が検出できる"
    - consistency: "依頼の各テーマのヒント記述と対応している"
    - completeness: "4テーマすべてに具体例または実践のポイントが付いている"

- [ ] **p1.6**: AI活用時も自分の経験・感情を入れる注意点が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; grep -qE 'AI' "$f" && grep -qE '経験.*感情|感情.*経験|自分の経験' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "AI活用と「自分の経験・感情を入れる」の2要素が検出できる"
    - consistency: "依頼のテーマ4の注記（AI活用時も必ず自分の経験・感情を入れること）と対応している"
    - completeness: "AI活用時の注意点が明記されている"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **playbook の done_when が全て満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; test -f "$f" && grep -q '^name:' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と3キーの存在を1コマンドで確認できる"
    - consistency: "done_when 項目1と対応"
    - completeness: "frontmatter が完全に揃っている"

- [ ] **p_final.2**: 核心の気づき（フォロワー数より信頼・安心感が申し込みにつながる）が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; grep -qE 'フォロワー|バズ|数字' "$f" && grep -qE '安心|信頼' "$f" && grep -qE '申し込み|相談したい|あなただから' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "核心の3要素がすべて検出できる"
    - consistency: "done_when 項目2と対応"
    - completeness: "核心の気づきが揃っている"

- [ ] **p_final.3**: 4つの投稿テーマ（悩み寄り添い・解決ヒント・お客様の声・自分の思い）が全て記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; grep -qE '寄り添|お悩み|悩み' "$f" && grep -qE '解決.*ヒント|ヒントを渡' "$f" && grep -qE 'お客様の声|変化を見せ' "$f" && grep -qE '思い|経験を伝え' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "4テーマの語がすべて検出できる"
    - consistency: "done_when 項目3と対応"
    - completeness: "4つのテーマすべてが揃っている"

- [ ] **p_final.4**: 各テーマに具体例または実践のポイントが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; grep -qE 'お問い合わせ|リサーチ|いいねが多い' "$f" && grep -qE 'できそう|小さなノウハウ' "$f" && grep -qE '感想|参加前後|雰囲気|写真' "$f" && grep -qE '温度感|なぜこの仕事|大切にしている' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "4テーマの実践ヒントがすべて検出できる"
    - consistency: "done_when 項目4と対応"
    - completeness: "4テーマすべてに具体例または実践のポイントが付いている"

- [ ] **p_final.5**: frontmatter 形式が既存スキルと一貫している
  - executor: claudecode
  - test_command: `f=.claude/skills/trust-building-posts/SKILL.md; head -1 "$f" | grep -q '^---$' && grep -q '^triggers:' "$f" && grep -qE '^  - ' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "1行目が --- で始まり、triggers がリスト形式（  - ）である"
    - consistency: "done_when 項目5と対応。human-touch-writing / becofit-gym-startup と同じ frontmatter 構造"
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

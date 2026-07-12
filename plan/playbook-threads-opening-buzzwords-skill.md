# playbook-threads-opening-buzzwords-skill.md

> **Threads 投稿の冒頭1行目に使える「バズワード50選」をスキル化する。**
> 呼びかけ/衝撃・暴露/有益・裏技/重要・念押し/共感・ターゲット/アクション・短文の6カテゴリで体系化する。

---

## meta

```yaml
project: plan-template
branch: feat/threads-opening-buzzwords-skill
created: 2026-07-12
issue: null
derives_from: null  # project.done_when 未定義（単発スキル化タスク）
reviewed: true  # reviewer 検証 PASS（Phase フロー・criterion 形式・test_command 検証性・done_when↔p_final 1:1 対応・既存スキル整合性を確認）
```

> **既存スキルとの関係**: `threads-shukyaku-7days`（集客土台設計）、`threads-7day-post-cycle`（投稿サイクル）とは別スキル。
> - 既存2スキル: 「誰に届けるか」「何を何日目に投稿するか」の設計・運用
> - 今回: 投稿文を書く際の「冒頭1行目のフレーズ集」（コピーライティング部品）
> slug: `threads-opening-buzzwords`

---

## goal

```yaml
summary: Threads 投稿の冒頭1行目に使えるバズワード50選を6カテゴリで体系化したスキルを作成する
done_when:
  - ".claude/skills/threads-opening-buzzwords/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "6カテゴリ（呼びかけ・衝撃暴露・有益裏技・重要念押し・共感ターゲット・アクション短文）が全て記載されている"
  - "50個（またはそれ以上）のバズワードフレーズが収録されている"
  - "各カテゴリに「いつ/どんな投稿で使うか」の使用シーンが記載されている"
  - "frontmatter 形式が既存スキル（becofit-gym-startup, threads-shukyaku-7days 等）と一貫している"
```

---

## phases

### p1: SKILL.md 本文作成

**goal**: threads-opening-buzzwords/SKILL.md を作成し、frontmatter と6カテゴリ・50フレーズ・使用シーンを記載する

#### subtasks

- [ ] **p1.1**: `.claude/skills/threads-opening-buzzwords/SKILL.md` が存在する
  - executor: claudecode
  - test_command: `test -f .claude/skills/threads-opening-buzzwords/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが指定パスに存在する"
    - consistency: "既存スキルと同じ .claude/skills/{slug}/SKILL.md の配置規則に従っている"
    - completeness: "ディレクトリとファイルが両方作成されている"

- [ ] **p1.2**: SKILL.md が frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; grep -q '^name: threads-opening-buzzwords' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "name/description/triggers の3キーが frontmatter に存在する"
    - consistency: "name が slug（threads-opening-buzzwords）と一致し、既存スキルと同じ YAML frontmatter 形式"
    - completeness: "triggers に起動フレーズが1つ以上列挙されている"

- [ ] **p1.3**: 6カテゴリ全ての見出しが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; grep -q '呼びかけ' "$f" && grep -qE '衝撃|暴露' "$f" && grep -qE '有益|裏技' "$f" && grep -qE '重要|念押し' "$f" && grep -qE '共感|ターゲット' "$f" && grep -qE 'アクション|短文' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "6カテゴリを示す全キーワードが grep で検出できる"
    - consistency: "依頼の6カテゴリ（呼びかけ/衝撃・暴露/有益・裏技/重要・念押し/共感・ターゲット/アクション・短文）と対応している"
    - completeness: "6カテゴリすべてが揃っており抜けがない"

- [ ] **p1.4**: 50個以上のバズワードフレーズが収録されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; c=$(grep -cE '^[0-9]+\.' "$f"); [ "$c" -ge 50 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "番号付きリスト（^[0-9]+.）が50個以上検出できる"
    - consistency: "6カテゴリに分散してフレーズが列挙されている"
    - completeness: "合計50フレーズ以上が揃っている"

- [ ] **p1.5**: 各カテゴリに「いつ/どんな投稿で使うか」の使用シーンが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; c=$(grep -cE '使用シーン|いつ使う|どんな投稿' "$f"); [ "$c" -ge 6 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "使用シーンを示すキーワードが6箇所以上検出できる（カテゴリごと）"
    - consistency: "各カテゴリの直下に、そのカテゴリを使う場面が説明されている"
    - completeness: "6カテゴリ全てに使用シーンの記載がある"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **playbook の done_when が全て満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; test -f "$f" && grep -q '^name:' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と3キーの存在を1コマンドで確認できる"
    - consistency: "done_when 項目1と対応"
    - completeness: "frontmatter が完全に揃っている"

- [ ] **p_final.2**: 6カテゴリ全てが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; grep -q '呼びかけ' "$f" && grep -qE '衝撃|暴露' "$f" && grep -qE '有益|裏技' "$f" && grep -qE '重要|念押し' "$f" && grep -qE '共感|ターゲット' "$f" && grep -qE 'アクション|短文' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "6カテゴリのキーワードが全て検出できる"
    - consistency: "done_when 項目2と対応"
    - completeness: "6カテゴリすべてが揃っている"

- [ ] **p_final.3**: 50個以上のバズワードフレーズが収録されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; c=$(grep -cE '^[0-9]+\.' "$f"); [ "$c" -ge 50 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "番号付きフレーズが50個以上検出できる"
    - consistency: "done_when 項目3と対応"
    - completeness: "合計50フレーズ以上が揃っている"

- [ ] **p_final.4**: 各カテゴリに使用シーンが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; c=$(grep -cE '使用シーン|いつ使う|どんな投稿' "$f"); [ "$c" -ge 6 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "使用シーンのキーワードが6箇所以上検出できる"
    - consistency: "done_when 項目4と対応"
    - completeness: "6カテゴリ全てに使用シーンがある"

- [ ] **p_final.5**: frontmatter 形式が既存スキルと一貫している
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-opening-buzzwords/SKILL.md; head -1 "$f" | grep -q '^---$' && grep -q '^triggers:' "$f" && grep -qE '^  - ' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "1行目が --- で始まり、triggers がリスト形式（  - ）である"
    - consistency: "done_when 項目5と対応。becofit-gym-startup / threads-shukyaku-7days と同じ frontmatter 構造"
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

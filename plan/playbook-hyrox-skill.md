# playbook-hyrox-skill.md

> **HYROX（フィットネス競技）の知識を `.claude/skills/` 配下に新規スキルとして体系化する。**

---

## meta

```yaml
project: thanks4claudecode
branch: feat/hyrox-skill
created: 2026-06-27
issue: null
derives_from: null  # ユーザー直接依頼（コンテンツ資産のスキル化）。project.done_when 非該当のため null。
reviewed: true
```

> derives_from は null。本タスクは project.md のマイルストーン群に対応する開発タスクではなく、
> ユーザー提供のフィットネスコンテンツ資産を既存スキル群と同形式でスキル化する単発の整備タスク。

---

## goal

```yaml
summary: HYROX に関するユーザー提供コンテンツを .claude/skills/hyrox-fitness-racing/SKILL.md として体系化する
done_when:
  - ".claude/skills/hyrox-fitness-racing/SKILL.md が存在する"
  - "SKILL.md に frontmatter（name, description, triggers）が含まれる"
  - "ユーザー提供の全12セクション（競技概要/ルール/参加費/トレーニング/当日の流れ/食事栄養/撮影/クラス活用/補強トレーニング/用語/レースペース戦略/サイエンスレポート知見）の見出しが SKILL.md に存在する"
  - "命名・frontmatter 形式が既存フィットネス系スキル（becofit-gym-startup, fitness-community）と一貫している"
```

---

## phases

### p1: 既存スキル形式の確認とコンテンツ整理

**goal**: 既存スキルの命名規則・frontmatter 形式を確認し、ユーザー提供コンテンツをセクション構造にマッピングする

#### subtasks

- [ ] **p1.1**: 参照する既存フィットネス系スキル 3 件（becofit-gym-startup, fitness-community, サムSGIR-fitness-sns）の frontmatter 形式が確認済みで、本 playbook の notes に採用形式が記録されている
  - executor: claudecode
  - test_command: `grep -q 'name:\|description:\|triggers:' .claude/skills/becofit-gym-startup/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "既存 SKILL.md が name/description/triggers 形式を持つことを grep で確認できる"
    - consistency: "新規スキルの frontmatter 設計が既存形式と同一構造"
    - completeness: "命名規則（english-slug ディレクトリ名）の判断材料が揃っている"

- [ ] **p1.2**: ユーザー提供コンテンツの12セクションが本文構成案にマッピングされている
  - executor: claudecode
  - test_command: `手動確認: 12セクション（競技概要/ルール/参加費/トレーニング/当日の流れ/食事栄養/撮影/クラス活用/補強トレーニング/用語/レースペース戦略/サイエンスレポート知見）が章立てに割り当てられていること`
  - validations:
    - technical: "全セクションが構成案に含まれる"
    - consistency: "章立てが既存スキルの見出し粒度と整合"
    - completeness: "12セクション全てがマッピング対象に含まれている"

**status**: done
**max_iterations**: 5

---

### p2: SKILL.md の作成

**goal**: ディレクトリと SKILL.md を作成し、frontmatter と全セクション本文を記述する

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: .claude/skills/hyrox-fitness-racing/ ディレクトリが存在する
  - executor: claudecode
  - test_command: `test -d .claude/skills/hyrox-fitness-racing && echo PASS || echo FAIL`
  - validations:
    - technical: "ディレクトリが存在する"
    - consistency: "ディレクトリ名が english-slug 命名規則（becofit-gym-startup 等）に一致"
    - completeness: "スキル配置先として正しい .claude/skills/ 直下にある"

- [ ] **p2.2**: SKILL.md に frontmatter（name, description, triggers）が含まれる
  - executor: claudecode
  - test_command: `head -20 .claude/skills/hyrox-fitness-racing/SKILL.md | grep -q 'name: hyrox' && grep -q 'description:' .claude/skills/hyrox-fitness-racing/SKILL.md && grep -q 'triggers:' .claude/skills/hyrox-fitness-racing/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "frontmatter の name/description/triggers が grep で検出される"
    - consistency: "frontmatter 形式が既存フィットネス系スキルと同一"
    - completeness: "description に起動条件、triggers に複数の発火フレーズが含まれる"

- [ ] **p2.3**: SKILL.md に12セクション全ての見出しが含まれる
  - executor: claudecode
  - test_command: `F=.claude/skills/hyrox-fitness-racing/SKILL.md; for k in 競技概要 ルール 参加費 トレーニング 当日 食事 撮影 クラス 補強 用語 ペース サイエンス; do grep -q "$k" "$F" || { echo FAIL; exit 0; }; done; echo PASS`
  - validations:
    - technical: "12セクションのキーワードが全て grep で検出される"
    - consistency: "見出し階層が既存スキルの記法（##, ###）と整合"
    - completeness: "ユーザー提供コンテンツの全セクションが欠落なく反映されている"

- [ ] **p2.4**: SKILL.md が本文ボリュームを持つ（80行以上）
  - executor: claudecode
  - test_command: `wc -l .claude/skills/hyrox-fitness-racing/SKILL.md | awk '{if($1>=80) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "行数が 80 以上"
    - consistency: "情報密度が既存フィットネス系スキルと同等"
    - completeness: "各セクションが実用に足る内容を持つ"

**status**: done
**max_iterations**: 5

---

### p3: 一貫性レビューと state 更新

**goal**: 既存スキル群との一貫性を検証し、state.md を本タスク用に切り替える

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: 新規スキルの frontmatter キー構成が既存スキル becofit-gym-startup と一致している
  - executor: claudecode
  - test_command: `diff <(grep -oE '^[a-z]+:' .claude/skills/hyrox-fitness-racing/SKILL.md | sort -u) <(grep -oE '^[a-z]+:' .claude/skills/becofit-gym-startup/SKILL.md | sort -u) && echo PASS || echo FAIL`
  - validations:
    - technical: "frontmatter のトップレベルキー集合が既存スキルと一致"
    - consistency: "命名・トーンが既存フィットネス系スキルと統一"
    - completeness: "frontmatter に必須キーが全て揃っている"

- [ ] **p3.2**: state.md の playbook.active が plan/playbook-hyrox-skill.md、branch が feat/hyrox-skill である
  - executor: claudecode
  - test_command: `grep -q 'active: plan/playbook-hyrox-skill.md' state.md && grep -q 'branch: feat/hyrox-skill' state.md && echo PASS || echo FAIL`
  - validations:
    - technical: "state.md の playbook.active と branch が grep で確認できる"
    - consistency: "git の現在ブランチ feat/hyrox-skill と state.md が一致"
    - completeness: "前タスク（day13-reels-script）からの切り替えが完了している"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **goal.done_when が全て実際に満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `test -f .claude/skills/hyrox-fitness-racing/SKILL.md && grep -q 'name: hyrox' .claude/skills/hyrox-fitness-racing/SKILL.md && grep -q 'description:' .claude/skills/hyrox-fitness-racing/SKILL.md && grep -q 'triggers:' .claude/skills/hyrox-fitness-racing/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と frontmatter 3 キーが同時に確認できる"
    - consistency: "他フィットネス系スキルと frontmatter 形式が一致"
    - completeness: "起動に必要な frontmatter が完備"

- [ ] **p_final.2**: 12セクション全ての見出しキーワードが SKILL.md に存在する
  - executor: claudecode
  - test_command: `F=.claude/skills/hyrox-fitness-racing/SKILL.md; for k in 競技概要 ルール 参加費 トレーニング 当日 食事 撮影 クラス 補強 用語 ペース サイエンス; do grep -q "$k" "$F" || { echo FAIL; exit 0; }; done; echo PASS`
  - validations:
    - technical: "12キーワード全てが grep で検出される"
    - consistency: "セクション構成がユーザー提供コンテンツの全範囲を網羅"
    - completeness: "漏れなく全セクションが反映されている"

- [ ] **p_final.3**: 命名・frontmatter 形式が既存スキル becofit-gym-startup と一貫している
  - executor: claudecode
  - test_command: `diff <(grep -oE '^[a-z]+:' .claude/skills/hyrox-fitness-racing/SKILL.md | sort -u) <(grep -oE '^[a-z]+:' .claude/skills/becofit-gym-startup/SKILL.md | sort -u) && echo PASS || echo FAIL`
  - validations:
    - technical: "frontmatter トップレベルキー集合が完全一致"
    - consistency: "ディレクトリ命名・記法・トーンが統一されている"
    - completeness: "一貫性要件が満たされている"

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

---

## notes

```yaml
採用する frontmatter 形式（既存フィットネス系スキルに準拠）:
  name: hyrox-fitness-racing
  description: "{スキル説明 + 起動条件フレーズ}"
  triggers:
    - "{複数の発火フレーズ}"

命名規則の判断:
  - 直近の新規スキル（becofit-gym-startup, ai-tax-accountant, awesome-gpt-image-2）は
    純粋な english-slug ディレクトリ名を採用
  - HYROX は固有名詞のため english-slug の hyrox-fitness-racing を採用
  - 日本語プレフィックス（例: サムSGIR-）は人名/ブランド由来スキルの慣習のため本件は不採用

中間成果物: なし（SKILL.md に直接記述するため tmp/ 不使用）
```

# playbook-peak-week-skill.md

## meta

```yaml
project: thanks4claudecode
branch: feat/peak-week-skill
created: 2026-06-27
issue: null
derives_from: null  # ユーザー直接依頼（コンテンツ資産のスキル化）。project.done_when 非該当のため null。
reviewed: true  # reviewer 検証 PASS（2026-06-27）
```

---

## goal

```yaml
summary: わたり氏のnote「ピークウィーク（大会1週間前）調整法」を .claude/skills/ 配下に新規スキルとして体系化する
done_when:
  - ".claude/skills/peak-week-water-manipulation/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "「水分の移動」の核心理論が SKILL.md に記載されている"
  - "Day1〜Day7（7日分）の食事・水分プロトコルが全て記載されている"
  - "水抜き（強制脱水）非推奨の注意点が記載されている"
  - "摂取サプリ（脂肪燃焼/マルチビタミン/EAA/クレアチン/グルタミン）が記載されている"
  - "大会選手以外（撮影前等の一般人）への応用範囲が記載されている"
  - "命名・frontmatter 形式が既存スキル hyrox-fitness-racing / becofit-gym-startup と一貫している"
```

---

## phases

### p1: スキル体系化と SKILL.md 作成

**goal**: わたり氏のピークウィーク調整法を 1 つの SKILL.md に体系化して作成する

#### subtasks

- [ ] **p1.1**: ディレクトリ .claude/skills/peak-week-water-manipulation/ が存在する
  - executor: claudecode
  - test_command: `test -d .claude/skills/peak-week-water-manipulation && echo PASS || echo FAIL`
  - validations:
    - technical: "ディレクトリが作成され ls で確認できる"
    - consistency: "english-slug 命名規則（hyrox-fitness-racing 等）に準拠"
    - completeness: "SKILL.md を配置する場所として完成している"

- [ ] **p1.2**: SKILL.md が存在し frontmatter（name, description, triggers）の3キーを含む
  - executor: claudecode
  - test_command: `F=.claude/skills/peak-week-water-manipulation/SKILL.md; test -f "$F" && grep -q '^name:' "$F" && grep -q '^description:' "$F" && grep -q '^triggers:' "$F" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在し3キーが全て grep でヒットする"
    - consistency: "frontmatter 形式が hyrox-fitness-racing / becofit-gym-startup と同形式（--- 区切り）"
    - completeness: "name は english-slug、description と triggers が起動文を含む"

- [ ] **p1.3**: 「水分の移動」核心理論・Day1〜Day7プロトコル・水抜き非推奨・サプリ・応用範囲の全要素が記載されている
  - executor: claudecode
  - test_command: `F=.claude/skills/peak-week-water-manipulation/SKILL.md; for k in 水分の移動 Day1 Day2 Day3 Day4 Day5 Day6 Day7 ウォーターローディング カーボディプリート カーボリフィード 水抜き クレアチン グルタミン EAA 撮影; do grep -q "$k" "$F" || { echo "FAIL: $k"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "全キーワードが grep でヒットする"
    - consistency: "出典（わたり氏 note）の主旨と矛盾しない内容になっている"
    - completeness: "核心理論・7日分プロトコル・注意点・サプリ・応用範囲が漏れなく含まれる"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **goal.done_when が全て実際に満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `F=.claude/skills/peak-week-water-manipulation/SKILL.md; test -f "$F" && grep -q '^name:' "$F" && grep -q '^description:' "$F" && grep -q '^triggers:' "$F" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と3キーを grep で確認できる"
    - consistency: "frontmatter 形式が既存スキルと一致"
    - completeness: "3キー全てに実体的な値が入っている"

- [ ] **p_final.2**: 全コンテンツ要素（核心理論/7日分プロトコル/水抜き非推奨/サプリ/応用）の見出しキーワードが存在する
  - executor: claudecode
  - test_command: `F=.claude/skills/peak-week-water-manipulation/SKILL.md; for k in 水分の移動 Day1 Day2 Day3 Day4 Day5 Day6 Day7 ウォーターローディング カーボディプリート カーボリフィード 水抜き クレアチン グルタミン EAA 撮影; do grep -q "$k" "$F" || { echo "FAIL: $k"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "全キーワードが grep でヒットする"
    - consistency: "Day別プロトコルが note の記述順と整合"
    - completeness: "5つの主要要素が全て網羅されている"

- [ ] **p_final.3**: 命名・frontmatter 形式が既存スキル hyrox-fitness-racing と一貫している
  - executor: claudecode
  - test_command: `D=.claude/skills/peak-week-water-manipulation; H=.claude/skills/hyrox-fitness-racing; head -1 "$D/SKILL.md" | grep -q '^---$' && head -1 "$H/SKILL.md" | grep -q '^---$' && echo PASS || echo FAIL`
  - validations:
    - technical: "両ファイルとも先頭行が --- で始まる"
    - consistency: "ディレクトリ名が english-slug、frontmatter キー構成が同一"
    - completeness: "トーン（わたり氏の一人称実践知見）が一貫している"

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: repository-map.yaml を更新する
  - command: `bash .claude/hooks/generate-repository-map.sh 2>/dev/null || true`
  - status: pending

- [ ] **ft2**: tmp/ 内の一時ファイルを削除する
  - command: `find tmp/ -type f ! -name 'README.md' -delete 2>/dev/null || true`
  - status: pending

- [ ] **ft3**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

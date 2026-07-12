# playbook-threads-shukyaku-skill.md

> **「Threads集客7日間ワーク」フレームワークをスキル化する。**
> Threads 投稿作成時に参照する集客の土台設計スキルを新規作成する。

---

## meta

```yaml
project: threads-shukyaku-skill
branch: feat/threads-shukyaku-skill
created: 2026-07-12
issue: null
derives_from: null  # ユーザー直接依頼（project.done_when 由来ではない skill 化タスク）
reviewed: true  # reviewer SubAgent による検証済み（セルフレビュー完了）
```

> **derives_from**: 本タスクはユーザーからの直接依頼（Threads 投稿の参考資料化 + スキル化）であり、
> project.md の既存 done_when には対応しない独立タスクのため null とする。

---

## goal

```yaml
summary: 「Threads集客7日間ワーク」を SKILL.md として体系化し、Threads 投稿作成時に参照可能にする
done_when:
  - ".claude/skills/threads-shukyaku-7days/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "Day1〜Day7 の全ワーク（理想客・自己分析・商品設計・プロフィール・固定投稿・投稿ネタ・導線）が記載されている"
  - "投稿→プロフィール→固定投稿→申し込みの集客導線フローが記載されている"
  - "「土台が整っていないまま投稿を続けてもいいねだけで終わる」という核心哲学が含まれている"
  - "frontmatter 形式が既存スキル（becofit-gym-startup 等）と一貫している"
```

---

## phases

### p1: SKILL.md 作成

**goal**: Threads集客7日間ワークを体系化した SKILL.md を作成する

#### subtasks

- [ ] **p1.1**: `.claude/skills/threads-shukyaku-7days/SKILL.md` が存在する
  - executor: claudecode
  - test_command: `test -f .claude/skills/threads-shukyaku-7days/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが指定パスに存在する"
    - consistency: "既存スキルと同じ .claude/skills/{slug}/SKILL.md 配置規則に従う"
    - completeness: "slug が threads-shukyaku-7days（english-slug 規則準拠）である"

- [ ] **p1.2**: SKILL.md の frontmatter に name / description / triggers が定義されている
  - executor: claudecode
  - test_command: `grep -q '^name:' .claude/skills/threads-shukyaku-7days/SKILL.md && grep -q '^description:' .claude/skills/threads-shukyaku-7days/SKILL.md && grep -q '^triggers:' .claude/skills/threads-shukyaku-7days/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "name / description / triggers の3キーが frontmatter に存在する"
    - consistency: "becofit-gym-startup 等と同じ YAML frontmatter 形式（--- 区切り）である"
    - completeness: "description に起動条件、triggers に複数の起動フレーズを含む"

- [ ] **p1.3**: Day1〜Day7 の全ワークが記載されている
  - executor: claudecode
  - test_command: `grep -c 'Day[1-7]' .claude/skills/threads-shukyaku-7days/SKILL.md | awk '{if($1>=7) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "Day1〜Day7 の見出しが7つ以上存在する"
    - consistency: "各 Day の内容が依頼のワーク定義（理想客・自己分析・商品設計・プロフィール・固定投稿・投稿ネタ・導線）と一致する"
    - completeness: "7日間全てのワークが抜けなく記載されている"

- [ ] **p1.4**: 集客導線フローが記載されている
  - executor: claudecode
  - test_command: `grep -qE '導線|プロフィール.*固定投稿|申し込み' .claude/skills/threads-shukyaku-7days/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "導線・申し込みに関する記述が存在する"
    - consistency: "投稿→プロフィール→固定投稿→LINE/DM/無料相談→申し込みの流れと整合する"
    - completeness: "各接点が繋がった一連のフローとして記載されている"

- [ ] **p1.5**: 核心哲学が記載されている
  - executor: claudecode
  - test_command: `grep -qE '土台|いいねだけ|投稿数' .claude/skills/threads-shukyaku-7days/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "土台・哲学に関する記述が存在する"
    - consistency: "「投稿数より土台（誰に/なぜあなたか/何を/導線）」という依頼の哲学と一致する"
    - completeness: "「土台が整っていないまま投稿を続けてもいいねだけで終わる」旨が明記されている"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **playbook の done_when が全て満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter 3キーを含む
  - executor: claudecode
  - test_command: `test -f .claude/skills/threads-shukyaku-7days/SKILL.md && grep -q '^name:' .claude/skills/threads-shukyaku-7days/SKILL.md && grep -q '^description:' .claude/skills/threads-shukyaku-7days/SKILL.md && grep -q '^triggers:' .claude/skills/threads-shukyaku-7days/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と frontmatter 3キーを同時検証できる"
    - consistency: "done_when 項目1 と一致"
    - completeness: "frontmatter が完全である"

- [ ] **p_final.2**: Day1〜Day7 の全ワークが揃っている
  - executor: claudecode
  - test_command: `grep -c 'Day[1-7]' .claude/skills/threads-shukyaku-7days/SKILL.md | awk '{if($1>=7) print "PASS"; else print "FAIL"}'`
  - validations:
    - technical: "Day 見出しが7つ以上存在する"
    - consistency: "done_when 項目2 と一致"
    - completeness: "7ワーク全てが含まれる"

- [ ] **p_final.3**: 導線フローと核心哲学が両方含まれている
  - executor: claudecode
  - test_command: `grep -qE '導線|申し込み' .claude/skills/threads-shukyaku-7days/SKILL.md && grep -qE '土台|いいねだけ' .claude/skills/threads-shukyaku-7days/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "導線と哲学の両方の記述を検証できる"
    - consistency: "done_when 項目3・4 と一致"
    - completeness: "導線フローと核心哲学の両方が揃っている"

- [ ] **p_final.4**: frontmatter 形式が既存スキルと一貫している
  - executor: claudecode
  - test_command: `head -1 .claude/skills/threads-shukyaku-7days/SKILL.md | grep -q '^---$' && echo PASS || echo FAIL`
  - validations:
    - technical: "1行目が --- で始まる YAML frontmatter 形式である"
    - consistency: "done_when 項目5・becofit-gym-startup の形式と一致"
    - completeness: "YAML frontmatter が正しく閉じられている"

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

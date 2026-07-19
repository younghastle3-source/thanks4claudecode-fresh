# playbook-mark-brand-identity-skill.md

> おっくん（MARK Running Club）のブランドアイデンティティを SKILL 化する。

---

## meta

```yaml
project: mark-brand-identity-skill
branch: feat/mark-brand-identity-skill
created: 2026-07-19
issue: null
derives_from: null  # プロジェクト外の単発スキル化タスク
reviewed: false
```

---

## goal

```yaml
summary: おっくん（MARK Running Club）のブランドアイデンティティを .claude/skills/mark-brand-identity/SKILL.md としてスキル化する
done_when:
  - ".claude/skills/mark-brand-identity/SKILL.md が存在し、frontmatter（name: mark-brand-identity, description, triggers）を含む"
  - "MISSION / VISION / CONCEPT / PHILOSOPHY の4要素が全て記載されている"
  - "CORE MESSAGE「目的地は、人だ」が含まれている"
  - "おっくんのStrength（泥臭く積み上げられること / 人の気持ちが分かること / 構造化して伝えられること）が全て含まれている"
  - "BRAND PROMISE が含まれている"
```

---

## phases

### p1: SKILL.md 作成

**goal**: おっくんのブランドアイデンティティ8セクション構成を frontmatter 付きの SKILL.md として作成する

#### subtasks

- [ ] **p1.1**: `.claude/skills/mark-brand-identity/SKILL.md` が frontmatter（name: mark-brand-identity, description, triggers）を含んで存在する
  - executor: claudecode
  - test_command: `test -f .claude/skills/mark-brand-identity/SKILL.md && grep -q 'name: mark-brand-identity' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'description:' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'triggers:' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "test -f と grep が全て PASS を返す"
    - consistency: "frontmatter の name が slug（mark-brand-identity）およびディレクトリ名と一致する"
    - completeness: "name / description / triggers の3フィールドが全て揃っている"

- [ ] **p1.2**: SKILL.md に MISSION / VISION / CONCEPT / PHILOSOPHY の4見出しが全て存在する
  - executor: claudecode
  - test_command: `grep -q 'MISSION' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'VISION' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'CONCEPT' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'PHILOSOPHY' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "4つの grep が全て一致する"
    - consistency: "各セクションの内容が素材（MISSION=人と人がつながる場、VISION=目的地は人だ、CONCEPT=今日より少し生きやすくなる場所）と整合する"
    - completeness: "8セクション構成のうち中核4要素が漏れなく記載されている"

- [ ] **p1.3**: SKILL.md に CORE MESSAGE「目的地は、人だ」が含まれている
  - executor: claudecode
  - test_command: `grep -q '目的地は、人だ' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep が「目的地は、人だ」に一致する"
    - consistency: "CORE MESSAGE と VISION の核心表現が一致している"
    - completeness: "CORE MESSAGE セクションとして明示されている"

- [ ] **p1.4**: SKILL.md におっくんのStrength 3項目（泥臭く積み上げられること / 人の気持ちが分かること / 構造化して伝えられること）が全て含まれている
  - executor: claudecode
  - test_command: `grep -q '泥臭く積み上げられる' .claude/skills/mark-brand-identity/SKILL.md && grep -q '人の気持ちが分かる' .claude/skills/mark-brand-identity/SKILL.md && grep -q '構造化して伝えられる' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "3つの grep が全て一致する"
    - consistency: "Strength がバックストーリー（駅伝→高校野球→借金返済→ボディメイク→HYROX→MARK Running Club）と整合する"
    - completeness: "3項目が漏れなく記載されている"

- [ ] **p1.5**: SKILL.md に BRAND PROMISE が含まれている
  - executor: claudecode
  - test_command: `grep -q 'BRAND PROMISE' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep が BRAND PROMISE に一致する"
    - consistency: "BRAND PROMISE が MISSION/CONCEPT と矛盾しない内容である"
    - completeness: "BRAND PROMISE セクションが本文を伴って存在する"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **playbook の done_when が全て満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: `.claude/skills/mark-brand-identity/SKILL.md` が存在し frontmatter 3フィールドを含む
  - executor: claudecode
  - test_command: `test -f .claude/skills/mark-brand-identity/SKILL.md && grep -q 'name: mark-brand-identity' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'description:' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'triggers:' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "test -f と3つの grep が全て PASS"
    - consistency: "frontmatter の name がディレクトリ名 mark-brand-identity と一致"
    - completeness: "name / description / triggers が揃っている"

- [ ] **p_final.2**: MISSION / VISION / CONCEPT / PHILOSOPHY の4要素が全て記載されている
  - executor: claudecode
  - test_command: `grep -q 'MISSION' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'VISION' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'CONCEPT' .claude/skills/mark-brand-identity/SKILL.md && grep -q 'PHILOSOPHY' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "4つの grep が全て一致"
    - consistency: "各要素の内容が素材と整合"
    - completeness: "中核4要素が漏れなく存在"

- [ ] **p_final.3**: CORE MESSAGE「目的地は、人だ」が含まれている
  - executor: claudecode
  - test_command: `grep -q '目的地は、人だ' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep が一致"
    - consistency: "VISION の核心と一致"
    - completeness: "CORE MESSAGE として明示"

- [ ] **p_final.4**: おっくんのStrength 3項目が全て含まれている
  - executor: claudecode
  - test_command: `grep -q '泥臭く積み上げられる' .claude/skills/mark-brand-identity/SKILL.md && grep -q '人の気持ちが分かる' .claude/skills/mark-brand-identity/SKILL.md && grep -q '構造化して伝えられる' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "3つの grep が全て一致"
    - consistency: "バックストーリーと整合"
    - completeness: "3項目が漏れなく存在"

- [ ] **p_final.5**: BRAND PROMISE が含まれている
  - executor: claudecode
  - test_command: `grep -q 'BRAND PROMISE' .claude/skills/mark-brand-identity/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "grep が一致"
    - consistency: "MISSION/CONCEPT と矛盾しない"
    - completeness: "本文を伴って存在"

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

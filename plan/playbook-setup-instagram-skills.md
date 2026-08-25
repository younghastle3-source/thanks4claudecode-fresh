# playbook-setup-instagram-skills.md

## meta

```yaml
project: thanks4claudecode
branch: chore/setup-instagram-skills
created: 2026-03-17
issue: null
derives_from: null  # 外部スキルファイル導入のため project.done_when に対応なし
reviewed: true
status: closed  # 2026-08-04 クローズ
roles:
  worker: claudecode
```

> **closure note (2026-08-04)**
> 成果物は取得・設置済みだが、その後ファイル名が日本語表記にリネームされたため
> 本 playbook の done_when（`instagram-hook.md` / `instagram-bridge.md`）は文字列としては不成立。
> 実体は以下として存在し、commit 6b89e13 で確定済み。
> - `.claude/skills/instagram-フック型ショート台本.md`（旧 instagram-hook.md）
> - `.claude/skills/instagram-日常ブリッジ台本.md`（旧 instagram-bridge.md）
>
> subtask のチェックボックスは未検証のまま残す（報酬詐欺防止のため `[x]` にしない）。
> 後続タスクは `plan/playbook-threads-community-skill.md` を参照。

---

## goal

```yaml
summary: GitHub リポジトリからインスタ/リール台本スキルファイルを取得し .claude/skills/ に設置する
done_when:
  - ".claude/skills/instagram-hook.md が存在し、内容が読み込める"
  - ".claude/skills/instagram-bridge.md が存在し、内容が読み込める"
```

---

## phases

### p1: スキルファイル取得・設置

**goal**: marketing リポジトリからスキルファイルを clone してコピーする

#### subtasks

- [ ] **p1.1**: /tmp/marketing にリポジトリが clone されている
  - executor: claudecode
  - test_command: `test -d /tmp/marketing/.git && echo PASS || echo FAIL`
  - validations:
    - technical: "git clone が正常に完了している"
    - consistency: "younghastle3-source/marketing リポジトリから取得されている"
    - completeness: "sns/insutagram/ ディレクトリが存在する"

- [ ] **p1.2**: .claude/skills/ ディレクトリが存在する
  - executor: claudecode
  - test_command: `test -d .claude/skills/ && echo PASS || echo FAIL`
  - validations:
    - technical: "ディレクトリが作成されている"
    - consistency: "既存の skills ディレクトリ構造と整合している"
    - completeness: "パーミッションが正常である"

- [ ] **p1.3**: .claude/skills/instagram-hook.md が存在し内容が空でない
  - executor: claudecode
  - test_command: `test -s .claude/skills/instagram-hook.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在し、サイズが 0 より大きい"
    - consistency: "元ファイル（SKILL.md）の内容と一致している"
    - completeness: "ファイル全体がコピーされている"

- [ ] **p1.4**: .claude/skills/instagram-bridge.md が存在し内容が空でない
  - executor: claudecode
  - test_command: `test -s .claude/skills/instagram-bridge.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在し、サイズが 0 より大きい"
    - consistency: "元ファイル（SKILL(2).md）の内容と一致している"
    - completeness: "ファイル全体がコピーされている"

**status**: pending
**max_iterations**: 3

---

### p2: クリーンアップ

**goal**: 一時ファイルの削除

#### subtasks

- [ ] **p2.1**: /tmp/marketing ディレクトリが削除されている
  - executor: claudecode
  - test_command: `test ! -d /tmp/marketing && echo PASS || echo FAIL`
  - validations:
    - technical: "一時ディレクトリが削除されている"
    - consistency: "/tmp に不要なファイルが残っていない"
    - completeness: "クリーンアップが完了している"

**status**: pending
**depends_on**: [p1]

---

### p_final: 完了検証（必須）

> **playbook の done_when が全て満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: .claude/skills/instagram-hook.md が存在し内容が読み込める
  - executor: claudecode
  - test_command: `test -s .claude/skills/instagram-hook.md && head -1 .claude/skills/instagram-hook.md > /dev/null 2>&1 && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在し、read 可能である"
    - consistency: "marketing リポジトリの SKILL.md と同一内容である"
    - completeness: "ファイル全体が正常にコピーされている"

- [ ] **p_final.2**: .claude/skills/instagram-bridge.md が存在し内容が読み込める
  - executor: claudecode
  - test_command: `test -s .claude/skills/instagram-bridge.md && head -1 .claude/skills/instagram-bridge.md > /dev/null 2>&1 && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在し、read 可能である"
    - consistency: "marketing リポジトリの SKILL(2).md と同一内容である"
    - completeness: "ファイル全体が正常にコピーされている"

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

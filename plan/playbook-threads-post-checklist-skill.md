# playbook-threads-post-checklist-skill.md

> **「Threads投稿改善ミニ診断」チェックシートをスキル化する。**
> 投稿前・投稿後に3分で見直せる8項目のチェックリストを、投稿レビュー・改善時に参照できるスキルとして体系化する。

---

## meta

```yaml
project: plan-template
branch: feat/threads-post-checklist-skill
created: 2026-07-12
issue: null
derives_from: null  # project.done_when 未定義（単発スキル化タスク）
reviewed: true  # reviewer 検証 PASS（criterion 形式・test_command 実行性・done_when↔p_final 整合を確認）
```

> **既存スキルとの関係**: `threads-shukyaku-7days`（集客土台設計）/ `threads-7day-post-cycle`（週次投稿サイクル）とは別スキルとして作成する。
> - 既存: 「何を投稿するか（土台・ネタ・順番）」の設計
> - 今回: 「投稿の質を投稿前後にセルフレビューする」8項目の診断チェックシート（投稿レビュー・改善時に参照）
> slug: `threads-post-checklist`

---

## goal

```yaml
summary: Threads投稿を投稿前後に3分で見直せる8項目のミニ診断チェックシートをスキルとして体系化する
done_when:
  - ".claude/skills/threads-post-checklist/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "8つのチェック項目（誰に向けて/投稿時間/読者視点/書き出し/長文/専門用語/詰め込み/日記）が全て記載されている"
  - "各チェック項目に「なぜ重要か」のポイント説明が記載されている"
  - "各チェック項目に3つのサブチェックリストが記載されている"
  - "frontmatter 形式が既存スキル（becofit-gym-startup, threads-shukyaku-7days 等）と一貫している"
```

---

## phases

### p1: SKILL.md 本文作成

**goal**: threads-post-checklist/SKILL.md を作成し、frontmatter と8項目のチェック（ポイント説明・各3つのサブチェック付き）を記載する

#### subtasks

- [ ] **p1.1**: `.claude/skills/threads-post-checklist/SKILL.md` が存在する
  - executor: claudecode
  - test_command: `test -f .claude/skills/threads-post-checklist/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが指定パスに存在する"
    - consistency: "既存スキルと同じ .claude/skills/{slug}/SKILL.md の配置規則に従っている"
    - completeness: "ディレクトリとファイルが両方作成されている"

- [ ] **p1.2**: SKILL.md が frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; grep -q '^name: threads-post-checklist' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "name/description/triggers の3キーが frontmatter に存在する"
    - consistency: "name が slug（threads-post-checklist）と一致し、既存スキル（becofit-gym-startup, threads-shukyaku-7days）と同じ YAML frontmatter 形式"
    - completeness: "triggers に起動フレーズが1つ以上列挙されている"

- [ ] **p1.3**: 8つのチェック項目の見出しが全て記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; c=$(grep -cE '^###? .*(誰に向け|投稿時間|読者|書き出し|長文|専門用語|詰め込|日記)' "$f"); [ "$c" -ge 8 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "8項目（誰に向けて/投稿時間/読者視点/書き出し/長文/専門用語/詰め込み/日記）の見出しが grep で8つ以上検出できる"
    - consistency: "各項目が依頼の8チェック項目と1対1で対応している"
    - completeness: "8項目すべてが揃っており抜けがない"

- [ ] **p1.4**: 各チェック項目に「なぜ重要か」のポイント説明が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; c=$(grep -cE 'なぜ重要|ポイント' "$f"); [ "$c" -ge 8 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "「なぜ重要」または「ポイント」の見出しが8つ以上検出できる"
    - consistency: "各項目のポイントが「たった1人／お客様がいつ見てるか／リサーチ／興味づけ／ツリー構造／中学生基準／1投稿1テーマ／読者視点」の趣旨と対応している"
    - completeness: "8項目すべてにポイント説明がある"

- [ ] **p1.5**: 各チェック項目に3つのサブチェックリストが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; c=$(grep -cE '^\s*- \[ \]' "$f"); [ "$c" -ge 24 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "チェックボックス形式のサブチェック（- [ ]）が24個以上（8項目 × 3つ）検出できる"
    - consistency: "各項目の直下に3つのサブチェックが紐づいており、項目の趣旨と整合している"
    - completeness: "8項目すべてにサブチェックが3つずつある"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **playbook の done_when が全て満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; test -f "$f" && grep -q '^name:' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と3キーの存在を1コマンドで確認できる"
    - consistency: "done_when 項目1と対応"
    - completeness: "frontmatter が完全に揃っている"

- [ ] **p_final.2**: 8つのチェック項目が全て記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; c=$(grep -cE '^###? .*(誰に向け|投稿時間|読者|書き出し|長文|専門用語|詰め込|日記)' "$f"); [ "$c" -ge 8 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "8項目の見出しが8つ以上検出できる"
    - consistency: "done_when 項目2と対応。誰に向けて/投稿時間/読者視点/書き出し/長文/専門用語/詰め込み/日記を網羅"
    - completeness: "8項目すべてが揃っている"

- [ ] **p_final.3**: 各チェック項目に「なぜ重要か」のポイント説明が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; c=$(grep -cE 'なぜ重要|ポイント' "$f"); [ "$c" -ge 8 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "ポイント説明が8つ以上検出できる"
    - consistency: "done_when 項目3と対応"
    - completeness: "全8項目にポイント説明がある"

- [ ] **p_final.4**: 各チェック項目に3つのサブチェックリストが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; c=$(grep -cE '^\s*- \[ \]' "$f"); [ "$c" -ge 24 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "サブチェック（- [ ]）が24個以上検出できる"
    - consistency: "done_when 項目4と対応"
    - completeness: "全8項目に3つずつサブチェックがある"

- [ ] **p_final.5**: frontmatter 形式が既存スキルと一貫している
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-post-checklist/SKILL.md; head -1 "$f" | grep -q '^---$' && grep -q '^triggers:' "$f" && grep -qE '^  - ' "$f" && echo PASS || echo FAIL`
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

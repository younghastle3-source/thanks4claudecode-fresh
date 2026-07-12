# playbook-threads-post-cycle-skill.md

> **Threads「7日間投稿サイクル」フレームワークをスキル化する。**
> サービス系個人事業主が週1サイクルで回す投稿ネタの型（コンテンツカレンダー）。

---

## meta

```yaml
project: plan-template
branch: feat/threads-post-cycle-skill
created: 2026-07-12
issue: null
derives_from: null  # project.done_when 未定義（単発スキル化タスク）
reviewed: true  # reviewer 検証 PASS（criterion 形式・test_command 検証性・done_when 整合性を確認）
```

> **既存スキルとの関係**: `threads-shukyaku-7days`（集客土台設計）とは別スキルとして作成する。
> - 既存: 「誰に届けるか・プロフィール・固定投稿・導線」の土台整備（一度きりのワーク）
> - 今回: 毎週繰り返す投稿ネタの7日サイクル（コンテンツカレンダー的な繰り返し運用）
> slug: `threads-7day-post-cycle`

---

## goal

```yaml
summary: Threadsの「7日間投稿サイクル」をサービス系個人事業主向けスキルとして体系化する
done_when:
  - ".claude/skills/threads-7day-post-cycle/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "Day1〜Day7 の全投稿タイプ（共感・必要性・未来・お役立ち・お客様の声・想い・募集）が記載されている"
  - "各Dayに「何を伝えるか」と「なぜその順番か」の意図が記載されている"
  - "Day7の募集投稿に「商品内容＋得られる未来＋申し込み方法」の3点が含まれると明記されている"
  - "frontmatter 形式が既存スキル（becofit-gym-startup, threads-shukyaku-7days 等）と一貫している"
```

---

## phases

### p1: SKILL.md 本文作成

**goal**: threads-7day-post-cycle/SKILL.md を作成し、frontmatter と Day1〜Day7 の全投稿タイプ・意図を記載する

#### subtasks

- [ ] **p1.1**: `.claude/skills/threads-7day-post-cycle/SKILL.md` が存在する
  - executor: claudecode
  - test_command: `test -f .claude/skills/threads-7day-post-cycle/SKILL.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが指定パスに存在する"
    - consistency: "既存スキルと同じ .claude/skills/{slug}/SKILL.md の配置規則に従っている"
    - completeness: "ディレクトリとファイルが両方作成されている"

- [ ] **p1.2**: SKILL.md が frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; grep -q '^name: threads-7day-post-cycle' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "name/description/triggers の3キーが frontmatter に存在する"
    - consistency: "name が slug（threads-7day-post-cycle）と一致し、既存スキル（becofit-gym-startup, threads-shukyaku-7days）と同じ YAML frontmatter 形式"
    - completeness: "triggers に起動フレーズが1つ以上列挙されている"

- [ ] **p1.3**: Day1〜Day7 の全投稿タイプ見出しが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; c=$(grep -cE 'Day[1-7]' "$f"); [ "$c" -ge 7 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "Day1〜Day7 の7つの見出しが grep で検出できる"
    - consistency: "各Dayが依頼のコンテンツ内容（共感・必要性・未来・お役立ち・お客様の声・想い・募集）と対応している"
    - completeness: "7日分すべてが揃っており抜けがない"

- [ ] **p1.4**: 各Dayに「何を伝えるか」と「なぜその順番か」の意図が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; grep -q '順番' "$f" && grep -qE '何を伝え|伝えること|狙い|意図' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "「順番」と意図を示すキーワードが本文に含まれる"
    - consistency: "共感→必要性→未来→信頼→証明→想い→募集 という購買心理の流れが説明されている"
    - completeness: "各Dayに個別の意図説明があり、全体の順番の理由も述べられている"

- [ ] **p1.5**: Day7の募集投稿に「商品内容＋得られる未来＋申し込み方法」の3点が必須と明記されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; grep -q '商品内容' "$f" && grep -q '得られる未来' "$f" && grep -q '申し込み方法' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "「商品内容」「得られる未来」「申し込み方法」の3語が本文に存在する"
    - consistency: "3点が Day7（募集投稿）のセクション内で必須要素として説明されている"
    - completeness: "3点すべてが揃わないと募集投稿が成立しない旨が明記されている"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **playbook の done_when が全て満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; test -f "$f" && grep -q '^name:' "$f" && grep -q '^description:' "$f" && grep -q '^triggers:' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と3キーの存在を1コマンドで確認できる"
    - consistency: "done_when 項目1と対応"
    - completeness: "frontmatter が完全に揃っている"

- [ ] **p_final.2**: Day1〜Day7 の全投稿タイプが記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; c=$(grep -cE 'Day[1-7]' "$f"); [ "$c" -ge 7 ] && echo PASS || echo FAIL`
  - validations:
    - technical: "Day1〜Day7 が7つ以上検出できる"
    - consistency: "done_when 項目2と対応。共感・必要性・未来・お役立ち・お客様の声・想い・募集を網羅"
    - completeness: "7日分すべてが揃っている"

- [ ] **p_final.3**: 各Dayに「何を伝えるか」「なぜその順番か」の意図が記載されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; grep -q '順番' "$f" && grep -qE '何を伝え|伝えること|狙い|意図' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "順番と意図のキーワードが検出できる"
    - consistency: "done_when 項目3と対応"
    - completeness: "全Dayの意図と全体の順番の理由が記述されている"

- [ ] **p_final.4**: Day7募集投稿に「商品内容＋得られる未来＋申し込み方法」の3点が明記されている
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; grep -q '商品内容' "$f" && grep -q '得られる未来' "$f" && grep -q '申し込み方法' "$f" && echo PASS || echo FAIL`
  - validations:
    - technical: "3語が本文に存在する"
    - consistency: "done_when 項目4と対応"
    - completeness: "Day7に3点必須が明記されている"

- [ ] **p_final.5**: frontmatter 形式が既存スキルと一貫している
  - executor: claudecode
  - test_command: `f=.claude/skills/threads-7day-post-cycle/SKILL.md; head -1 "$f" | grep -q '^---$' && grep -q '^triggers:' "$f" && grep -qE '^  - ' "$f" && echo PASS || echo FAIL`
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

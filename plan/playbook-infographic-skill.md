# playbook-infographic-skill.md

## meta

```yaml
project: thanks4claudecode
branch: feat/infographic-skill
created: 2026-06-27
issue: null
derives_from: null  # ユーザー直接依頼（プロンプト資産のスキル化）。project.done_when 非該当のため null。
reviewed: true  # reviewer 検証 PASS（2026-06-27）
```

---

## goal

```yaml
summary: 任意テキストを「日本語グラフィックレコーディング風 HTML インフォグラフィック」に変換する詳細デザイン仕様プロンプト（約7100文字）を .claude/skills/ 配下に新規スキルとして体系化する
done_when:
  - ".claude/skills/html-graphic-recording/SKILL.md が存在し frontmatter（name, description, triggers）を含む"
  - "カラースキーム（palette/primary/accent/mono）の仕様が SKILL.md に記載されている"
  - "タイポグラフィ仕様（フォント名・CSSクラス：title/subtitle/section-heading/body-text/highlight-text/note-text）が記載されている"
  - "レイアウト構造（レスポンシブ・グラスモーフィズム・カード型・黄金比グリッド）が記載されている"
  - "視覚効果・データ可視化技法（シャドウ/テクスチャ/データ可視化/接続線）が記載されている"
  - "技術的仕様の HTML/CSS 実装サンプル（.gr-container 等）が含まれている"
  - "命名・frontmatter 形式が既存スキル becofit-gym-startup / md-converter と一貫している"
```

---

## phases

### p1: スキル体系化と SKILL.md 作成

**goal**: グラフィックレコーディング風 HTML インフォグラフィック生成プロンプトを 1 つの SKILL.md に体系化して作成する

#### subtasks

- [ ] **p1.1**: ディレクトリ .claude/skills/html-graphic-recording/ が存在する
  - executor: claudecode
  - test_command: `test -d .claude/skills/html-graphic-recording && echo PASS || echo FAIL`
  - validations:
    - technical: "ディレクトリが作成され ls で確認できる"
    - consistency: "english-slug 命名規則（becofit-gym-startup / md-converter 等）に準拠"
    - completeness: "SKILL.md を配置する場所として完成している"

- [ ] **p1.2**: SKILL.md が存在し frontmatter（name, description, triggers）の3キーを含む
  - executor: claudecode
  - test_command: `F=.claude/skills/html-graphic-recording/SKILL.md; test -f "$F" && grep -q '^name:' "$F" && grep -q '^description:' "$F" && grep -q '^triggers:' "$F" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在し3キーが全て grep でヒットする"
    - consistency: "frontmatter 形式が becofit-gym-startup / md-converter と同形式（--- 区切り）"
    - completeness: "name は english-slug、description と triggers が起動文を含む"

- [ ] **p1.3**: カラースキーム・タイポグラフィ・レイアウト・視覚効果・データ可視化・HTML/CSS実装サンプルの全要素が記載されている
  - executor: claudecode
  - test_command: `F=.claude/skills/html-graphic-recording/SKILL.md; for k in palette primary accent mono title subtitle section-heading body-text highlight-text note-text グラスモーフィズム カード 黄金比 シャドウ テクスチャ 接続線 gr-container glass-card Yomogi; do grep -q "$k" "$F" || { echo "FAIL: $k"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "全キーワードが grep でヒットする"
    - consistency: "元プロンプト（約7100文字）の主旨・構造と矛盾しない内容になっている"
    - completeness: "カラー/タイポ/レイアウト/視覚効果/データ可視化/実装サンプルが漏れなく含まれる"

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証（必須）

> **goal.done_when が全て実際に満たされているか最終検証**

#### subtasks

- [ ] **p_final.1**: SKILL.md が存在し frontmatter（name, description, triggers）を含む
  - executor: claudecode
  - test_command: `F=.claude/skills/html-graphic-recording/SKILL.md; test -f "$F" && grep -q '^name:' "$F" && grep -q '^description:' "$F" && grep -q '^triggers:' "$F" && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイル存在と3キーを grep で確認できる"
    - consistency: "frontmatter 形式が既存スキルと一致"
    - completeness: "3キー全てに実体的な値が入っている"

- [ ] **p_final.2**: カラースキーム/タイポグラフィ/レイアウト/視覚効果/データ可視化/実装サンプルの全要素キーワードが存在する
  - executor: claudecode
  - test_command: `F=.claude/skills/html-graphic-recording/SKILL.md; for k in palette primary accent mono title subtitle section-heading body-text highlight-text note-text グラスモーフィズム カード 黄金比 シャドウ テクスチャ 接続線 gr-container glass-card Yomogi; do grep -q "$k" "$F" || { echo "FAIL: $k"; exit 0; }; done; echo PASS`
  - validations:
    - technical: "全キーワードが grep でヒットする"
    - consistency: "各セクションが元プロンプトの記述構造と整合"
    - completeness: "6つの主要要素（カラー/タイポ/レイアウト/視覚効果/データ可視化/実装）が全て網羅されている"

- [ ] **p_final.3**: HTML/CSS 実装サンプルがコードブロックとして含まれている
  - executor: claudecode
  - test_command: `F=.claude/skills/html-graphic-recording/SKILL.md; grep -q '```' "$F" && grep -q 'gr-container' "$F" && grep -q 'glass-card' "$F" && echo PASS || echo FAIL`
  - validations:
    - technical: "コードフェンスと .gr-container / .glass-card クラスが grep でヒットする"
    - consistency: "クラス名がレイアウト/視覚効果セクションの説明と一致"
    - completeness: "そのまま貼り付けて HTML 生成に使える実装サンプルになっている"

- [ ] **p_final.4**: 命名・frontmatter 形式が既存スキル md-converter と一貫している
  - executor: claudecode
  - test_command: `D=.claude/skills/html-graphic-recording; H=.claude/skills/md-converter; head -1 "$D/SKILL.md" | grep -q '^---$' && head -1 "$H/SKILL.md" | grep -q '^---$' && echo PASS || echo FAIL`
  - validations:
    - technical: "両ファイルとも先頭行が --- で始まる"
    - consistency: "ディレクトリ名が english-slug、frontmatter キー構成が同一"
    - completeness: "変換・生成系スキルとしてのトーンが一貫している"

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

# state.md

> **現在地を示す Single Source of Truth**
>
> LLM はセッション開始時に必ずこのファイルを読み、focus と playbook を確認すること。

---

## focus

```yaml
current: thanks4claudecode  # 現在作業中のプロジェクト名（本ワークスペース自身のスキル資産を作るタスクのため workspace 層。branch 必須）
project: plan/project.md
```

---

## playbook

```yaml
active: plan/playbook-part111-integration.md
branch: feat/cj-advance-skill-expansion  # 直前タスクが未コミットのため新ブランチを切らず続行（差分の混在を避けるため）
reviewed: false  # reviewer 未レビュー。ユーザーの明示的な進行指示により実装を優先。DW1〜DW10 は bash/zsh で実測 PASS 済み
last_archived: null  # plan/archive/ は本リポジトリに存在しない。完了/クローズした playbook は plan/ に status 付きで残す運用
previous: plan/playbook-cj-advance-skill-expansion.md  # p_final passed（DW1〜DW9）。未コミット
```

---

## goal

```yaml
milestone: CJ Advance ナレッジのスキル基盤整備
phase: p_final (passed)
done_criteria:
  - "DW1: 非破壊。base d407efe の全非空行が逐語で残存し、git diff --numstat が削除0行・追加50行以上（実測 88 0）。既存 H2 7本が残存"
  - "DW2: H2 がちょうど12本（既存7＋新規5）、各新規区間に実体行3行以上、base に0件の必須新規語11個（腰方形筋/小円筋/腸腰筋/内腹斜筋/脊柱起立筋/三角筋後部/肩峰/僧帽筋/対角線/過緊張/内旋）がファイル全体に存在"
  - "DW3: トラブル①区間に 上腕二頭筋長頭腱/肩峰/内旋/インピンジメント/小円筋/三角筋後部/外旋/リリース があり、肩峰の行が「ぶつかる/挟まる」に言及"
  - "DW4: トラブル②の「逆」の理解。腰方形筋/広背筋/引き伸ば/過緊張/アライメント/リリース があり、縮の行が否定を伴い、マッサージを含む全行が否定文脈（肯定形で書くと FAIL）"
  - "DW5: トラブル③の左右交差。腸腰筋/内腹斜筋/脊柱起立筋/代償/仰向け/股関節 があり、`左…腰…右…股関節` を1行で含み、腸腰筋を含む全行が右を含み、`左の股関節`/`左の腸腰筋` が0件"
  - "DW6: 評価の原理区間に 痛い場所に原因があるとは限らない/対角線/拮抗筋 があり、3対応（肩前⇔外旋筋 / 僧帽筋⇔腰方形筋・広背筋 / 左腰⇔右股関節）が各1行以上"
  - "DW7: `## いつ使うか` が 僧帽筋/腰痛/肩 に言及し3行以上、既存段落が逐語残存"
  - "DW8: 出典に Part111 のリポジトリ内パス・repo URL・YouTube URL・既存 Part123 行の逐語残存"
  - "DW9: 索引の `## スキル化済みの講義` が `|` 行ちょうど7行・5対応がディレクトリ実在。回帰として `## 講義一覧` の生の行数86かつ NFC 後も pinned tree と集合一致"
  - "DW10: 禁止10語（TBD/TODO/FIXME/後で書く/Transcript:/以下原文/Getty Images/Shutterstock/こんにちは/image1）が0件、SKILL.md が137〜260行（実測175行）、base からの全変更が allowlist 内"
```

---

## known_issues

```yaml
uncommitted_previous_task:
  playbook: plan/playbook-cj-advance-skill-expansion.md
  files: .claude/skills/クロニクルジャパンcj-advance/（SKILL.md ＋ references/lecture-index.md）/ .claude/skills/personal-session-communication/ / .claude/skills/skeletal-exercise-selection/ / plan/playbook-cj-advance-skill-expansion.md
  note: DW1〜DW9 PASS 済みだが未コミット。本タスクのコミット時に混ざらないよう、先に直前タスク名義でコミットすること（本タスク playbook の ft0）

stale_dw9_previous_playbook:
  note: plan/playbook-cj-advance-skill-expansion.md の DW9 は本タスク着手後に FAIL する。allowlist が当該タスクの成果物のみを許可しているため、本タスクが正当に触った shoulder-pain-rehabilitation/SKILL.md と playbook-part111-integration.md を検出する。回帰ではなく、後続タスクの DW10 側で担保済み

pre_existing_uncommitted:
  count: 15
  files: .claude/agents/critic.md / .claude/settings.json / .claude/skills/instagram-pdca/ / .claude/skills/video-editing-ffmpeg/ / plan/playbook-setup-instagram-skills.md / tmp/
  note: 本タスク開始前から作業ツリーに浮いている先行差分。feat/cj-advance-skill-expansion に持ち越されている。本タスクの成果物とは別に処理が必要

repository_map_generator_broken:
  script: .claude/hooks/generate-repository-map.sh
  symptom: docs/repository-map.yaml が更新されない（skills.count が 11 のまま。新規2スキルが載らない）
  cause: set -euo pipefail 下で `find "$PLAN_DIR/active"` を実行しているが plan/active と plan/archive が本リポジトリに存在せず、pipefail によりスクリプトが中断して出力ファイルを書かずに終了する
  status: 未修正（本タスクのスコープ外）
```

## session

```yaml
last_start: 2026-08-25 21:28:48
last_end: 2026-08-26 06:50:38
last_clear: 2026-08-15 00:00:00
```

---

## config

```yaml
security: admin
toolstack: A  # A: Claude Code only | B: +Codex | C: +Codex+CodeRabbit
roles:
  orchestrator: claudecode  # 監督・調整・設計（常に claudecode）
  worker: claudecode        # 実装担当（A: claudecode, B/C: codex）
  reviewer: claudecode      # レビュー担当（A/B: claudecode, C: coderabbit）
  human: user               # 人間の介入（常に user）
```

---

## 参照

| ファイル | 役割 |
|----------|------|
| CLAUDE.md | LLM の振る舞いルール |
| plan/project.md | プロジェクト計画 |
| docs/repository-map.yaml | 全ファイルマッピング（自動生成） |
| docs/folder-management.md | フォルダ管理ルール |

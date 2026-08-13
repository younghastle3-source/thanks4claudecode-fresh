# state.md

> **現在地を示す Single Source of Truth**
>
> LLM はセッション開始時に必ずこのファイルを読み、focus と playbook を確認すること。

---

## focus

```yaml
current: plan-template  # 現在作業中のプロジェクト名
project: plan/project.md
```

---

## playbook

```yaml
active: plan/playbook-video-editing-ffmpeg-skill.md
branch: feat/video-editing-ffmpeg-skill
reviewed: false  # ★ 4回目レビュー（Critical 0 / Major 2 / Minor 3）を反映済み・再レビュー待ち。LOOP 開始前に Task(subagent_type="reviewer") で PASS を得ること
last_archived: plan/archive/playbook-m082-archive-check.md
previous: plan/playbook-threads-pdca-objection-check.md  # completed（断らせるチェック追加。main にマージ済み / 4ceca51）
```

---

## goal

```yaml
milestone: null
phase: p1 (pending)
done_criteria:
  - "DW1: .claude/skills/video-editing-ffmpeg/SKILL.md が存在し、先頭 frontmatter の name が video-editing-ffmpeg で、description に inputs 起動フレーズ6個が全て逐語で含まれ、本文に `## ワークフロー1` `## ワークフロー2` `## ワークフロー3` の H2 見出しが各1本ずつ存在し、各ワークフロー区間内に `references/` へのパス参照行と `scripts/` へのパス参照行がそれぞれ1行以上存在する"
  - "DW2: references/ffmpeg-pitfalls.md に落とし穴3件の H2 見出し（`## 落とし穴1` `## 落とし穴2` `## 落とし穴3`）が存在し、ファイル全体に inputs 検証済み事実の逐語文字列7個（`drawtext`, `libfreetype`, `tonemap=mobius:param=0.5`, `colorprim=bt709:transfer=bt709:colormatrix=bt709`, `arib-std-b67`, `eq=gamma=1.15:brightness=0.03`, `overlay`）が全て含まれ、落とし穴2 の区間内に NG 例と OK 例の両方が `-i` を含むコードブロック行として存在する"
  - "DW3: scripts/clip_export.sh が実行権限付きで存在し、(a) 合成 HLG フィクスチャ（color_transfer=arib-std-b67）に対し開始1秒・長さ3秒で実行すると出力 mp4 の format.duration が 2.85〜3.15 に収まり ffprobe の color_transfer / color_space / color_primaries が3つとも bt709 を返し pix_fmt が yuv420p である、(b) 同入力の `--dry-run` 出力に `tonemap=mobius:param=0.5` と `eq=gamma=1.15:brightness=0.03` と `-map \"0:a?\"` の3文字列が逐語で含まれ、かつ**その dry-run 文字列をそのまま eval して得た出力の映像 md5 が、--dry-run 無しで実行した出力の映像 md5 と一致する**（＝dry-run 文字列が実処理を正直に反映しており、逐語 grep が有効な証拠になっている）、(c) 音声トラックの無い入力（tmp/fixture_videoonly.mp4）に対しても exit 0 で duration > 0 の mp4 を生成する、(d) **同一ピクセルで色タグだけ SDR に書き換えた双子フィクスチャ（tmp/fixture_hlg_sdrtag.mp4）を入力にした出力と、HLG フィクスチャを入力にした出力の映像 md5 が異なる**（＝tonemap 分岐が実際にピクセルを変えている・文字列非依存）"
  - "DW4: scripts/make_label_png.py が日本語文字列を引数に実行でき、出力 PNG が Pillow で mode=RGBA として読め、透明ピクセル（alpha=0）と不透明ピクセル（alpha>0）の両方を含み、その PNG を clip_export.sh のラベル指定で合成した mp4 が生成され duration が 0 より大きく、かつ**同一入力・同一区間をラベル無しで書き出した mp4 と映像 md5 が異なる**（＝ラベルが実際にピクセルとして焼き込まれている）"
  - "DW5: scripts/scene_scan.sh / scripts/silence_scan.sh / scripts/concat_clips.sh / scripts/transcribe.sh の4本が実行権限付きで存在して bash -n を全て通り、scene_scan.sh がシーン変化2箇所の合成フィクスチャで pts_time 行を2行以上出力し、silence_scan.sh が中央2秒無音の合成フィクスチャで保持区間行を2行以上出力する"
  - "DW6: references/talk-video-trim.md と references/highlight-reel.md が存在し、talk-video-trim.md に `## 段階1` と `## 段階2` の H2 見出しが各1本存在して段階2区間に `mlx_whisper` が含まれ、highlight-reel.md に `## 手順` H2 見出しが存在して区間内に番号付きステップ行が5行以上ある"
  - "DW7: 回帰: 追跡済み差分（base_commit 609cc09 比）と未追跡ファイル（git status --porcelain）を合わせた全変更ファイル集合において、`.claude/skills/video-editing-ffmpeg/` 以外の `.claude/skills/` 配下ファイルが0件であり、かつ I-12 の除外集合（`.claude/skills/video-editing-ffmpeg/` 配下・`plan/playbook-video-editing-ffmpeg-skill.md`・`state.md`・`docs/repository-map.yaml`・`.gitignore`・`.claude/agents/critic.md`・`plan/playbook-setup-instagram-skills.md`・`.claude/worktrees/`・`tmp/` 配下）に該当しないファイルが0件である"
```

---

## session

```yaml
last_start: 2025-12-19 01:48:26
last_clear: 2025-12-13 00:30:00
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

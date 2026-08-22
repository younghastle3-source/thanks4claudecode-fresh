# thanks4claudecode-fresh — AI_CONTEXT

最終更新: 2026-08-22

## このリポジトリは何か

おっくんの Claude Code 運用フレームワーク本体。CLAUDE.md（振る舞いルール）・Hooks（`.claude/hooks/`）・SubAgents（`.claude/agents/`）・playbook（`plan/playbook-*.md`）による計画駆動開発で構成され、「playbook なしで Edit/Write/変更系 Bash を実行させない」ことを構造的に強制する。同時に、パーソナルトレーニング・マーケティング・営業・SNS発信など他の実務領域で得た知見を Skill（`.claude/skills/`）として体系化・蓄積する場所でもある。

## 詳しい仕様はここを見ること

- `CLAUDE.md`（振る舞いルール・Golden Path・Core Contract。FROZEN、無断編集不可）
- `state.md`（現在の focus・playbook 状態。セッション開始時に必ず読む）
- `docs/repository-map.yaml`（全ファイルマッピング・自動生成）
- `.claude/protected-files.txt`（HARD_BLOCK / BLOCK / WARN の保護ファイル一覧）

※ `docs/feature-catalog.yaml` は本リポジトリには存在しない（2026-08-22 時点）。Hooks/SubAgents/Skills の一覧は `docs/repository-map.yaml` および `.claude/agents/` `.claude/skills/` のディレクトリを直接参照すること。

## 他リポジトリとの関係

`.claude/skills/` には、training・marketing・coaching 系の他リポジトリから吸い上げた知見が Skill 化されて蓄積されている（例: `クロニクルジャパンcj-advance`、`shoulder-pain-rehabilitation`、`hyrox-supplementary-training`、`久保田式マーケメソッドmeikara-marketing`、`営業侍伊澤sales-samurai-izawa`、`instagram-pdca`、`threads-pdca` など）。他リポジトリを扱う AI エージェントが具体的なノウハウを再利用したい場合、このリポジトリの `.claude/skills/` を参照するのが基本ルート。

## AIへの指示

- このファイルを編集・変更する場合、CLAUDE.md のルール（pm 経由の playbook 必須、admin でも Golden Path はバイパス不可）に従うこと
- `.claude/protected-files.txt` に載っているファイルは無断で変更しないこと

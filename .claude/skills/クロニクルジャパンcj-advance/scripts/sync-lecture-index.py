#!/usr/bin/env python3
"""CJ Advance 講義索引の同期チェック / 更新。

  確認のみ:  python3 sync-lecture-index.py
  索引を更新: python3 sync-lecture-index.py --apply

リポジトリ側の追加・削除・リネームを検出し、各スキルの出典パスが
まだ実在するかも照合する。--apply で「## 講義一覧」の表を再生成する。
"""
import json, os, re, subprocess, sys, unicodedata

REPO = "younghastle3-source/training"
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "..")
INDEX = os.path.join(ROOT, ".claude/skills/クロニクルジャパンcj-advance/references/lecture-index.md")
SKILLS = os.path.join(ROOT, ".claude/skills")


def nfc(x):
    return unicodedata.normalize("NFC", x)


def sh(args):
    return subprocess.run(args, capture_output=True, text=True, check=True).stdout


def repo_state():
    """現在のツリーから対象ファイルと SHA を取得。"""
    sha = json.loads(sh(["gh", "api", f"repos/{REPO}/commits/HEAD"]))["sha"]
    tree = json.loads(sh(["gh", "api", f"repos/{REPO}/git/trees/{sha}?recursive=1"]))["tree"]
    paths = {
        nfc(e["path"])
        for e in tree
        if e["type"] == "blob"
        and e.get("size", 0) > 1
        and nfc(e["path"]).startswith("cj advance/")
        and e["path"].endswith(".md")
        and not e["path"].endswith("/README.md")
    }
    return sha, paths


def theme(path):
    n = re.sub(r"\.md$", "", os.path.basename(path))
    n = re.sub(r"^\(\d+\)\s*", "", n)
    n = re.sub(r"^#\s*CJ-ADVANCE_", "", n)
    n = re.sub(r"^\d{4}-\d{2}-\d{2}_", "", n)
    n = re.sub(r"^\d{8}_", "", n)
    n = re.sub(r"^【Part\d+】\s*", "", n)
    n = re.sub(r"^Part\d+[】_]\s*", "", n)
    n = re.sub(r"_YouTube$", "", n)
    n = re.sub(r"\s*-\s*YouTube$", "", n)
    n = re.sub(r"^_", "", n)
    n = re.sub(r"\s*\(1\)$", "", n)
    return re.sub(r"\s+", " ", n).strip()


def part_of(path):
    m = re.search(r"Part[0-9]+", path)
    return m.group(0) if m else "-"


def index_paths(text):
    out = []
    inside = False
    for line in text.splitlines():
        if line.startswith("## 講義一覧"):
            inside = True
            continue
        if inside and re.match(r"^#{1,2} ", line):
            break
        if inside and line.startswith("|"):
            f = [c.strip() for c in line.split("|")]
            if len(f) > 5 and f[4].startswith("cj advance/"):
                out.append(nfc(f[4]))
    return out


def build_rows(paths):
    rows = [(part_of(p), theme(p), p.split("/")[1], p) for p in paths]

    def key(r):
        return (r[3].split("/")[1], int(r[0][4:]) if r[0] != "-" else 10 ** 6, r[3])

    return [f"| {a} | {b} | {c} | {d} |" for a, b, c, d in sorted(rows, key=key)]


def main():
    apply = "--apply" in sys.argv
    sha, repo = repo_state()
    text = open(INDEX, encoding="utf-8").read()
    idx = index_paths(text)
    idx_set = set(idx)

    added = sorted(repo - idx_set)
    removed = sorted(idx_set - repo)
    dup = len(idx) - len(idx_set)

    # リネーム候補: 消えたものと増えたもので Part 番号が一致
    renames, add_left, rm_left = [], list(added), list(removed)
    for r in list(rm_left):
        pr = part_of(r)
        if pr == "-":
            continue
        for a in list(add_left):
            if part_of(a) == pr:
                renames.append((r, a))
                rm_left.remove(r)
                add_left.remove(a)
                break

    print(f"tree {sha[:10]}   リポジトリ {len(repo)}本 / 索引 {len(idx)}行")
    if dup:
        print(f"  ⚠ 索引にパスの重複が {dup} 件")
    for old, new in renames:
        print(f"  ~ リネーム: {os.path.basename(old)}\n              → {os.path.basename(new)}")
    for a in add_left:
        print(f"  + 新着: {a}")
    for r in rm_left:
        print(f"  - 消失: {r}")
    if not (renames or add_left or rm_left or dup):
        print("  ✅ 索引は最新")

    # スキルの出典パス照合
    print("\n各スキルの出典パス:")
    bad = 0
    for dirpath, _, files in os.walk(SKILLS):
        for fn in files:
            if not fn.endswith(".md"):
                continue
            fp = os.path.join(dirpath, fn)
            if os.path.abspath(fp) == os.path.abspath(INDEX):
                continue  # 索引自体は上の集合比較で検証済み（説明文の例示を誤検知しない）
            for m in set(re.findall(r"cj advance/[^`)|\s]+\.md", open(fp, encoding="utf-8").read())):
                if nfc(m) not in repo:
                    print(f"  ❌ 不在 {os.path.relpath(fp, ROOT)}\n       {m}")
                    bad += 1
    if not bad:
        print("  ✅ すべて実在")

    if apply and (renames or add_left or rm_left or dup):
        head = text[: text.index("## 講義一覧")]
        rest = text[text.index("## 講義一覧"):]
        tail = rest[re.search(r"\n#{1,2} ", rest).start():]
        head = re.sub(r"(- 件数: )\d+本", rf"\g<1>{len(repo)}本", head)
        head = re.sub(r"(- 索引作成時点のツリー: `)[0-9a-f]+(`)", rf"\g<1>{sha}\g<2>", head)
        body = "\n".join(["## 講義一覧", "", "| Part | テーマ | 領域 | パス |", "|---|---|---|---|"] + build_rows(repo))
        open(INDEX, "w", encoding="utf-8").write(head + body + tail)
        print(f"\n✅ 索引を更新した（{len(repo)}本 / tree {sha[:10]}）")
    elif apply:
        print("\n変更なし。索引は更新しなかった。")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())

---
name: html-graphic-recording
description: 任意のテキスト内容を、一流デザイナーチームが制作したような日本語の完璧なグラフィックレコーディング風HTMLインフォグラフィックに変換するスキル。カラースキーム・手書き風タイポグラフィ・グラスモーフィズム・データ可視化技法まで体系化した詳細デザイン仕様プロンプトに基づく。「この内容をインフォグラフィックにして」「グラフィックレコーディング風のHTMLを作って」「手書き風のまとめページを作りたい」「絵巻物風レイアウトで情報をまとめたい」と伝えると起動します。
triggers:
  - この内容をインフォグラフィックにして
  - グラフィックレコーディング風のHTMLを作って
  - 手書き風のまとめページを作りたい
  - 絵巻物風レイアウトで情報をまとめたい
  - カラースキームを使ったインフォグラフィック
  - データを視覚化したHTMLを作って
  - グラスモーフィズムのデザインで作って
  - 日本語のグラレコ風スライドを作りたい
---

# HTMLグラフィックレコーディング・インフォグラフィック生成スキル

> 目的：あらゆるテキスト内容を、一流デザイナーチームが制作したような、日本語で完璧なグラフィックレコーディング風のHTMLインフォグラフィックに変換する。情報設計とビジュアルデザインの両面で最高水準の表現を実現し、手書き風の図形やアイコン、最新のデザイントレンドを取り入れた視覚表現で、情報を魅力的かつ記憶に残る形で伝える。

---

## 1. カラースキーム

```yaml
palette:
  primary:
    primary-1: { rgb: "593C47", note: "ダークボルドー" }
    primary-2: { rgb: "F2E63D", note: "ビビッドイエロー" }
    primary-3: { rgb: "F2C53D", note: "イエローオレンジ" }
    primary-4: { rgb: "F25C05", note: "オレンジ" }
    primary-5: { rgb: "F24405", note: "レッドオレンジ" }
  accent:
    accent-1: { rgb: "4D7EA8", note: "ブルー（補色）" }
    accent-2: { rgb: "5CDB95", note: "グリーン（補色）" }
    accent-3: { rgb: "9D8DF1", note: "パープル（補色）" }
  mono:
    mono-1: { rgb: "111111", note: "ほぼ黒" }
    mono-2: { rgb: "595959", note: "ダークグレー" }
    mono-3: { rgb: "BBBBBB", note: "ライトグレー" }
    mono-4: { rgb: "F8F8F8", note: "ほぼ白" }
適用方法: |
  CSS カスタムプロパティ（:root）として定義し、--primary-1〜5 / --accent-1〜3 / --mono-1〜4 として
  全コンポーネントから参照する。視認性とインパクトを両立させる配色設計を優先する。
```

---

## 2. グラフィックレコーディング表現技法

```yaml
レイアウト:
  - 日本の伝統的な「絵巻物」のような横長スクロールレイアウト（オプション）
  - 左上から右へ、上から下へと情報が流れるストーリーテリング型配置
タイポグラフィ素材:
  - 日本語の高品質手書き風フォント: Yomogi, Zen Kurenaido, Kaisei Decol, にくまるゴシック, コーポレート明朝
  - 筆圧変化を再現した手描き風の囲み線・矢印・バナー・吹き出し
  - SVGベースの高品質手書き風アイコンとイラスト要素
キーワード強調表現:
  - 色付き下線（波線・直線・点線など多様なスタイル）
  - マーカー効果（グラデーション、ブラシタッチ）
  - 囲み枠（手描き風の様々な形状）
  - テキスト装飾（影付き、縁取り、エンボス）
関連概念の接続:
  - 曲線/直線の矢印（点線・実線・波線）
  - 視線誘導のための装飾的な接続線
  - グループ化を示す囲み領域（雲形・楕円・不規則形状）
アイコン・シンボル:
  - 日本的な和風アイコン選択肢
  - 感情表現豊かな絵文字とピクトグラム
  - 概念を象徴する簡潔なシンプルアイコン
```

---

## 3. タイポグラフィ仕様（CSSクラス）

```css
@import url('https://fonts.googleapis.com/css2?family=Kaisei+Decol:wght@400;500;700&family=Yomogi&family=Zen+Kurenaido&family=Zen+Maru+Gothic:wght@300;400;500;700&family=Zen+Kaku+Gothic+New:wght@300;400;500;700&display=swap');

body { font-feature-settings: "palt"; text-rendering: optimizeLegibility; }

.title {
  font-family: 'Kaisei Decol', serif;
  font-size: 32px; font-weight: 700; line-height: 1.2;
  background: linear-gradient(45deg, var(--primary-1), var(--primary-5));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  text-shadow: 0px 2px 3px rgba(0,0,0,0.1);
}
.subtitle {
  font-family: 'Zen Maru Gothic', sans-serif;
  font-size: 18px; font-weight: 500; color: #475569; letter-spacing: 0.03em;
}
.section-heading {
  font-family: 'Zen Kaku Gothic New', sans-serif;
  font-size: 22px; font-weight: 700; color: #1e40af;
  border-bottom: 2px solid var(--accent-1);
  padding-bottom: 4px; margin-top: 24px; margin-bottom: 16px;
}
.body-text {
  font-family: 'Zen Maru Gothic', sans-serif;
  font-size: 15px; line-height: 1.6; color: #334155; letter-spacing: 0.01em;
}
.highlight-text {
  font-family: 'Yomogi', cursive; font-size: 17px; color: var(--primary-5); position: relative;
}
.note-text {
  font-family: 'Zen Kurenaido', sans-serif; font-size: 14px; color: #64748b; font-style: italic;
}
```

---

## 4. レイアウト構造

```yaml
レスポンシブ設計:
  デスクトップ: フレックスボックスによる3カラム/4カラム構成
  タブレット: 2カラム構成
  モバイル: シングルカラム構成
ヘッダー:
  - 背景にグラスモーフィズム効果
  - 左揃えタイトル＋アイコン、右揃え日付/出典情報
  - 下部に伸びるスクロールガイド要素
コンテンツエリア（カード型コンポーネント）:
  - 白背景（半透明、不透明度0.8-0.95）
  - 角丸（12-16px）
  - 微細シャドウ（複数レイヤー、色付きシャドウオプション）
  - 薄いボーダー（1px、不透明度0.1-0.2）
  - セクション間の適切な余白と階層構造、Z軸の重なり効果
グリッドシステム:
  - 黄金比（1:1.618）に基づく配置オプション
  - 視覚的な流れを促進するグリッドレイアウト
  - コンテンツブロック間の関係性を強調する配置
```

---

## 5. 高度な視覚効果

```yaml
シャドウとライティング:
  - 多層シャドウによる奥行き表現
  - 光源を意識した一貫性のある陰影
  - カラーシャドウによるアクセント
テクスチャとパターン:
  - 和紙風の繊細な背景テクスチャ
  - 幾何学模様によるセクション区分
  - 伝統的な日本の模様をモダンにアレンジした装飾
マイクロインタラクション（CSS animation）:
  - スクロールに連動する要素の出現効果
  - ホバー時の微細な動きと変化
  - 強調したいポイントのための控えめなアニメーション
グラスモーフィズム2.0:
  - 半透明レイヤーの重ね合わせ
  - フロスト効果によるデプス表現
  - 背景ぼかしとコントラスト調整
```

---

## 6. 情報のビジュアル化・データ可視化技法

```yaml
データ可視化:
  - シンプルなチャートとグラフ（棒グラフ、線グラフ、円グラフ）
  - 数値の大きさを表現するプロポーショナル図形
  - 比較を明確にするビジュアルメタファー
  - タイムラインとプロセス図
関係性の表現:
  - マインドマップ形式のノード接続
  - ヒエラルキーを示す入れ子構造
  - 要素間の影響を示す方向性のある接続
  - 分類とグルーピングの視覚的表現
概念の具象化:
  - 抽象概念を表す比喩的なイラスト
  - プロセスを示す段階的な図解
  - ストーリーテリングのためのシーケンス表現
  - キーポイントを強調するビジュアルアンカー
視線誘導とナラティブ構造:
  - 自然な視線の流れを促す配置と接続
  - 重要度による視覚的階層の明確化
  - ストーリーラインに沿った情報の配列
  - 「発見」を促す仕掛けとレイヤー構造
空間活用と余白デザイン:
  - 情報密度と可読性のバランス
  - 「呼吸」のための意図的な余白設計
  - グルーピングを強調する空間の活用
  - 視覚的リズムを生み出す配置パターン
```

---

## 7. 技術的仕様（HTML/CSS実装サンプル）

```html
<div class="gr-container">
  <header class="gr-header glass-effect">
    <h1 class="title">メインタイトル</h1>
    <div class="meta">
      <time datetime="2024-03-06">2024年3月6日</time>
      <cite class="source">出典: 〇〇〇</cite>
    </div>
  </header>

  <main class="gr-content">
    <div class="gr-grid">
      <section class="gr-card glass-card">
        <div class="card-header">
          <i class="card-icon">📌</i>
          <h2 class="section-heading">セクション見出し</h2>
        </div>
        <div class="card-body">
          <p class="body-text">本文テキスト...</p>
          <div class="highlight-box">
            <span class="highlight-text">強調テキスト</span>
          </div>
        </div>
      </section>

      <div class="connector">
        <svg class="arrow" viewBox="0 0 100 20">
          <path d="M0,10 C30,5 70,15 90,10 L90,5 L100,10 L90,15 Z" />
        </svg>
      </div>
    </div>
  </main>

  <footer class="gr-footer">
    <div class="attribution">
      <p>©︎ 2024 作成者名</p>
    </div>
  </footer>
</div>

<style>
  :root {
    --primary-1: #593C47; --primary-2: #F2E63D; --primary-3: #F2C53D;
    --primary-4: #F25C05; --primary-5: #F24405;
    --accent-1: #4D7EA8;  --accent-2: #5CDB95;  --accent-3: #9D8DF1;
    --mono-1: #111111;    --mono-2: #595959;    --mono-3: #BBBBBB;   --mono-4: #F8F8F8;
  }

  .glass-effect {
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  }

  .glass-card {
    background: rgba(255, 255, 255, 0.7);
    backdrop-filter: blur(7px);
    -webkit-backdrop-filter: blur(7px);
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    box-shadow:
      0 4px 12px rgba(0, 0, 0, 0.05),
      0 1px 3px rgba(0, 0, 0, 0.1),
      0 20px 40px -20px rgba(var(--primary-4-rgb), 0.15);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }

  .glass-card:hover {
    transform: translateY(-2px);
    box-shadow:
      0 6px 16px rgba(0, 0, 0, 0.08),
      0 2px 4px rgba(0, 0, 0, 0.12),
      0 25px 50px -20px rgba(var(--primary-4-rgb), 0.2);
  }

  .gr-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 24px;
    padding: 24px;
  }
</style>
```

---

## 8. 全体指針・実装指針

```yaml
全体指針:
  - ユーザーの視線の動きを綿密に設計した情報の流れ
  - 視覚的記憶を強化する一貫した色彩と形状の活用
  - 情報の階層と関連性を直感的に理解できる視覚言語
  - 日本のデザイン美学と現代的なUXデザインの融合
  - 手書き風要素による親しみやすさと人間味の演出
  - 簡潔さと豊かな表現のバランス
  - ユーザーの発見と理解を促す情報設計
  - 最終フッターには出典と制作情報を明記する
実装指針:
  - SVGとCSSによる手書き風要素の実現（実際の手書きをトレースしたような自然さ）
  - CSSカスタムプロパティによる一貫したデザインシステム
  - アニメーションはa11y（アクセシビリティ）に配慮し、prefers-reduced-motion をサポート
  - レスポンシブ性能を維持しつつリッチな表現を実現
  - 必要最小限のJavaScriptで動的要素を実装（CSS優先）
  - SEOとアクセシビリティに配慮したセマンティックマークアップ
```

---

## 9. 相談対応パターン

### パターンA：テキスト内容をそのままインフォグラフィック化したい
```
使う情報: ユーザーが渡した本文テキスト（記事・要約・議事録など）
出力: 上記カラースキーム・タイポグラフィ・gr-container構造を用いた単一HTMLファイル
```

### パターンB：既存のデータ・数値を視覚化したい
```
使う情報: 比較したい数値・時系列データ・分類項目
出力: セクション6のデータ可視化技法（プロポーショナル図形、タイムライン、マインドマップ型ノード）を適用した構成案
```

### パターンC：和風・手書き風のトーンを強めたい
```
使う情報: テーマの雰囲気（フォーマル/カジュアル、対象読者）
出力: 絵巻物風横長レイアウト、和紙テクスチャ、手書き風フォント（Yomogi等）を中心に配置した構成案
```

---

## 判断軸（迷ったときのリトマス試験紙）

| 問い | Yes → | No → |
|---|---|---|
| カラーパレットを :root の CSS カスタムプロパティとして定義しているか？ | そのまま進める | 各色を直書きせず変数化してから進める |
| 情報の視線誘導（左上→右、上→下のストーリーテリング）が設計されているか？ | OK | セクション順序・接続線の配置を見直す |
| アニメーションが prefers-reduced-motion に配慮しているか？ | OK | a11y 対応のフォールバックを追加する |

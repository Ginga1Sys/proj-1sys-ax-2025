# GPT-5 mini — ロゴ案集

以下は上位候補のうち5案についてのロゴ案（コンセプト、配色、タイポ、簡易SVGモックアップ）です。社内共有用ドキュメントとして、説明と併せてSVGコードを載せています。必要ならSVGを元にPNG出力やアイコン化（favicon）も作成します。

---

## 1) AIナレッジハブ
- タグライン: 社内のAI知見を一箇所に
- コンセプト: ハブ（中心）に向け情報が集まるイメージ。円と線の集合体で“つながり”を表現。
- カラー: ダークブルー `#0B5FFF` / ミント `#2DD4BF` / グレー `#6B7280`
- タイポ: やや角のあるゴシック（例: Noto Sans JP Bold）
- 用途: ヘッダー用横長ロゴ、ファビコンは中心の円アイコン

### SVG（簡易）
```svg
<svg width="320" height="80" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="none"/>
  <g transform="translate(20,10)">
    <circle cx="30" cy="30" r="18" fill="#0B5FFF" />
    <circle cx="70" cy="20" r="6" fill="#2DD4BF" />
    <circle cx="90" cy="40" r="6" fill="#2DD4BF" />
    <line x1="30" y1="30" x2="70" y2="20" stroke="#9CA3AF" stroke-width="2"/>
    <line x1="30" y1="30" x2="90" y2="40" stroke="#9CA3AF" stroke-width="2"/>
    <text x="120" y="36" font-family="Noto Sans JP, sans-serif" font-size="20" fill="#111827">AIナレッジハブ</text>
  </g>
</svg>
```

---

## 2) 知恵の森
- タグライン: みんなで育てる知見の森
- コンセプト: 木（樹形）で知識の育成・蓄積を表現。親しみやすく、社内浸透しやすい。
- カラー: 森グリーン `#1E9A6A` / ライトグリーン `#A7F3D0` / ブラウン `#6B4226`
- タイポ: 丸みのある日本語フォント（例: rounded M+ 1c）
- 用途: ポータルのトップやワークショップ資料の表紙向け

### SVG（簡易）
```svg
<svg width="320" height="80" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(10,10)">
    <path d="M30 50 C10 40, 10 20, 30 20 C50 20, 50 40, 30 50 Z" fill="#1E9A6A" />
    <rect x="28" y="50" width="4" height="14" fill="#6B4226" />
    <text x="70" y="44" font-family="rounded M+, sans-serif" font-size="20" fill="#064E3B">知恵の森</text>
  </g>
</svg>
```

---

## 3) AISHARE
- タグライン: Share. Learn. Grow.
- コンセプト: シンプルでグローバルに使える短命名。共有（share）を象徴する矢印や吹き出しで表現。
- カラー: ネイビーブルー `#0F172A` / アクア `#06B6D4`
- タイポ: 英字はモダンなサンセリフ（例: Inter, Montserrat）
- 用途: 社内外でそのまま使えるブランディング、名刺や資料のアクセント

### SVG（簡易）
```svg
<svg width="320" height="80" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(10,20)">
    <rect x="0" y="0" width="40" height="40" rx="8" fill="#06B6D4" />
    <path d="M12 22 L20 14 L28 22" stroke="#0F172A" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
    <text x="60" y="30" font-family="Inter, sans-serif" font-size="24" fill="#0F172A">AISHARE</text>
  </g>
</svg>
```

---

## 4) IntraAI
- タグライン: 社内AIナビゲーター
- コンセプト: 「社内（Intra）」を強調するため、イントラネット的な盾形+AIの文字を組み合わせる。安心感・セキュリティ感を演出。
- カラー: ミッドブルー `#165E83` / ライトグレー `#E6EEF3`
- タイポ: 中太のモダンゴシック
- 用途: 社内ポリシー資料、ログイン画面のシンボル

### SVG（簡易）
```svg
<svg width="320" height="80" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(10,10)">
    <path d="M30 0 L60 15 L60 45 L30 60 L0 45 L0 15 Z" fill="#165E83" />
    <text x="78" y="36" font-family="Noto Sans JP, sans-serif" font-size="20" fill="#062D3A">IntraAI</text>
  </g>
</svg>
```

---

## 5) AIコンパス
- タグライン: 必要な知見へ、確かな方角を
- コンセプト: コンパス（羅針盤）で「探索」「導き」を表現。検索・ナビ機能の象徴に合う。
- カラー: インディゴ `#3B82F6` / ゴールドアクセント `#F59E0B`
- タイポ: スタイリッシュなサンセリフ
- 用途: 検索バー付近のアイコン、オンボーディングガイド

### SVG（簡易）
```svg
<svg width="320" height="80" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(10,10)">
    <circle cx="30" cy="30" r="18" fill="#3B82F6" />
    <polygon points="30,12 36,30 30,48 24,30" fill="#F59E0B"/>
    <text x="70" y="36" font-family="Noto Sans JP, sans-serif" font-size="20" fill="#0F172A">AIコンパス</text>
  </g>
</svg>
```

---

## 運用メモ / 次のステップ（推奨）
- 上記5案について社内投票（5〜10項目）を実施して最終案を決定してください。SlackやGoogleフォームが使いやすいです。
- 選定後、SVGをベースにPNG（1x/2x）・アイコン（32/16px）を生成します。
- ドメインや商標の簡易サーチを実施する場合は、上位案（決定案）での検索を行います。

---

作業が必要なら次のどれを実行しますか？
- 1) 上位案でSVGをブラッシュアップしてPNG出力
- 2) 社内投票用の短いアンケート（文面＋候補画像）を作成
- 3) ドメイン/商標の簡易チェック
- 4) 別の候補5案でロゴ案を追加

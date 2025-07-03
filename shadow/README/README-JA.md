# Aseprite カラーシェーディング v5.0

このスクリプトは [Aseprite](https://www.aseprite.org/) 用で、グラデーションや色相オプションを備えた動的なカラーパレットウィンドウを開き、簡単にパレットやシェーディングバリエーションを作成するのに役立ちます。

## クレジットと起源

この作品は、以下の以前の貢献に基づいています：

- バージョン 1.0–2.0: [Dominick John](https://github.com/dominickjohn/aseprite/tree/master) と [David Capello](https://aseprite.org/)。
- バージョン 3.0: [yashar98](https://github.com/yashar98/aseprite/tree/main)。
- バージョン 3.1: [Daeyangae](https://github.com/Daeyangae/aseprite)。
- バージョン 4.0: [Manuel Hoelzl](https://github.com/hoelzlmanuel/aseprite-color-shading)。

このバージョンはこれまで導入された機能を維持しつつ、追加改善を加えています。

## インストール方法

1. スクリプトファイルをダウンロードします（例: `Color Shading v4.0.lua`）。
2. Aseprite を開き、**File -> Scripts -> Open Scripts Folder** を選んでスクリプトディレクトリを開きます。
3. ダウンロードしたスクリプトファイルをそのフォルダにコピーします。
4. 必要であれば Aseprite を再起動します。

## 使い方

1. Aseprite で **File -> Scripts -> Color Shading v4.0** を選んでスクリプトを実行します。
2. カラーセクションとパレット生成オプションを含むウィンドウが表示されます。

### 機能:

- **Base:** ベースカラーをクリックすると、その色を元に他のシェードやニュアンスが再計算されます。
- **「取得」ボタン:** 現在の前景色（FG）と背景色（BG）を使ってベースカラーを更新し、シェードを再生成します。
- **カラーを左クリック:** その色を前景色（FG）として設定します。
- **カラーを右クリック:** その色を背景色（BG）として設定します。
- **カラーを中クリック:** 最後に変更した色（FG または BG）を切り替え、すべてのシェードを新しい色に基づいて再生成します（「自動取得」有効時）。

### 高度なコントロール:

- **温度（暗/明）:** 暗いシェードや明るいシェードに対する暖色/寒色のシフトを調整します。
- **強度:** シェードスウォッチに彩度のグラデーションを追加します。
- **ピーク:** シェードに明度のグラデーションを追加し、明るいスウォッチの明るさを調整します。
- **スウェイ:** 設定した温度の色への影響度を調整します。
- **スロット:** 生成されるスウォッチの数を変更します。

## 注意

- スクリプト互換性のため、Aseprite の最新版を使用してください。
- このスクリプトは、迅速にパレットやグラデーションを作成したいピクセルアーティストやデザイナー向けです。

<img width="363" alt="Color Shading v4 0" src="shadow/example.png">

## 🌐 他の言語

- 🇬🇧 [English Version](README.md)
- 🇫🇷 [French Version](shadow/README/README-FR.md)
- 🇪🇸 [Spanish Version](shadow/README/README-ES.md)
- 🇯🇵 [Japanese Version](shadow/README/README-JA.md)
- 🇵🇹 [Portuguese Version](shadow/README/README-PT.md)

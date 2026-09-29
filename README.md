# Age of Reforging: The Freelands 日本語再翻訳パッチ

「Age of Reforging: The Freelands」の日本語再翻訳パッチ（差分版）です。

## 収録内容

- `AoR_日本語化パッチ_v5.3/` … v5.3 差分パッチ一式（最新版）
  - `install.bat` / `uninstall.bat` … 導入・解除用バッチ
  - `apply_patch.ps1` … 元の `resources.assets` から日本語化版を生成する PowerShell スクリプト
  - `patch_ops.txt` / `patch_data.bin.gz` … 翻訳の差分データ
  - `はじめにお読みください.txt` … 導入方法・変更点

ゲーム本体のファイル（`resources.assets` 等）は含みません。差分データは利用者のPCにある元ファイルに適用して使います。

## 対応バージョン

ゲームバージョン **1.30b** の無改造の `resources.assets` のみ対応（SHA-256 で照合し、一致しない場合は何も変更せず中断します）。

## 導入方法

1. `AoR_日本語化パッチ_v5.3` フォルダを、ゲーム本体の exe と同じ階層に置く
2. フォルダ内の `install.bat` を実行
3. ゲーム内の言語設定を「日本語」にして起動

詳しくは `はじめにお読みください.txt` を参照してください。

旧版（v5.2 以前）は Git の履歴から取得できます。

#!/usr/bin/env bash
# ============================================================
# ImageLauncher — 在 macOS 上一键生成「未签名 IPA」(XcodeGen 版)
# 用法: 把 ImageLauncher 工程传到 Mac 后执行：
#        bash build-ipa.sh
# 产物: build/ImageLauncher.ipa  (未签名，待你用自己的证书签名)
# 依赖: macOS + Xcode 15 + Homebrew (脚本会自动装 xcodegen)
# ============================================================
set -euo pipefail

SCHEME="ImageLauncher"
CONFIG="Release"
ARCHIVE_PATH="build/ImageLauncher.xcarchive"
IPA_NAME="ImageLauncher.ipa"

rm -rf build
mkdir -p build

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "==> [0/4] 安装 xcodegen (brew install xcodegen)"
  brew install xcodegen
fi

echo "==> [1/4] xcodegen generate (用 project.yml 生成 ImageLauncher.xcodeproj)"
xcodegen generate

echo "==> [2/4] archive (CODE_SIGNING_ALLOWED=NO，不签名)"
xcodebuild -project ImageLauncher.xcodeproj \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  DEVELOPMENT_TEAM="" \
  archive

APP="$ARCHIVE_PATH/Products/Applications/ImageLauncher.app"
if [ ! -d "$APP" ]; then
  echo "ERROR: 未在 archive 产物中找到 ImageLauncher.app" >&2
  exit 1
fi

echo "==> [3/4] 打包为 IPA (Payload/ImageLauncher.app)"
cd build
rm -rf Payload "$IPA_NAME"
mkdir -p Payload
cp -R "$APP" Payload/
zip -r -q "$IPA_NAME" Payload/
cd - >/dev/null

echo ""
echo "==> [4/4] 完成"
echo "未签名 IPA: $(pwd)/build/$IPA_NAME"
echo ""
echo "下一步 —— 用你自己的证书签名（示例）:"
echo "  codesign --force --deep --sign \"Apple Development: YOUR_NAME (TEAMID)\" \\"
echo "      build/$IPA_NAME   # 或直接对 .app 签后再 zip"
echo ""
echo "若需重打包已签名的 .app 为 IPA:"
echo "  cd build && rm -rf Payload && mkdir Payload && cp -R <已签名.app> Payload/ && zip -r ImageLauncher-signed.ipa Payload/ && cd -"

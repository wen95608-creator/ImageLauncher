# ImageLauncher — Mac 端构建 & 签名 & 打包说明

当前会话宿主为 Windows 主机，没有 Xcode 工具链，无法在此环境执行 `xcodebuild` / 生成 `.app` / `.ipa`。
**请将本目录的 `ImageLauncher/`（或下载得到的 `ImageLauncher.zip`）整个复制到一台 macOS（Xcode 15+）机器上**，再按下面命令一行完成 build / archive / 重签 / 出 IPA。

---

## 0. 环境要求

| 项 | 要求 |
|---|---|
| macOS | 13+ (Ventura) 或更新 |
| Xcode | 15.0+（自带 iOS 17 SDK；如需更早 iOS 仍可，IPHONEOS_DEPLOYMENT_TARGET=15.0） |
| Apple ID | 你自己的（用于个人签名 / Ad Hoc / Development） |
| 命令行工具 | `xcode-select --install` 已装 |

---

## 1. 用 Xcode 打开

```bash
cd ImageLauncher
open ImageLauncher.xcodeproj
```

打开后：

1. 左侧选 **ImageLauncher** Target → **Signing & Capabilities** → **Team** 选你自己的 Apple ID Team
2. **Bundle Identifier** 默认 `com.example.ImageLauncher`（可改成你自己的，例如 `com.yourname.imagelauncher`）
3. 把 iPhone 用数据线连上，选为自己的设备
4. **Product → Run (⌘R)** 即可直接装到手机试运行

> 启动后 → 屏幕就是那张 `预设.JPEG`（满屏居中、保持比例、状态栏隐藏、无任何 UI）。

---

## 2. 命令行 build / archive（生成 .app / .xcarchive）

进入工程根目录执行：

```bash
cd ImageLauncher

# 1) 真机 Build（产物 .app 路径见末尾）
xcodebuild \
  -project ImageLauncher.xcodeproj \
  -scheme ImageLauncher \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/ImageLauncher.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  archive

# 2) 导出未签名的 .app（用于自签）
xcodebuild \
  -exportArchive \
  -archivePath build/ImageLauncher.xcarchive \
  -exportPath build/unsigned \
  -exportOptionsPlist build/ExportOptions.plist
```

> 第一次 archive 用 `CODE_SIGNING_ALLOWED=NO` 跳过签名，得到的是未签名 `.app` 与 `.xcarchive`，方便你后面用自己证书重签。

### 关键产物

| 路径 | 说明 |
|---|---|
| `build/ImageLauncher.xcarchive` | Xcode Archive 产物 |
| `build/unsigned/ImageLauncher.app` | 未签名的 `.app` 包 |

---

## 3. 用自己的 Apple Developer 证书重签 → 出 `.ipa`

准备 `ExportOptions.plist`（已在 `build/` 目录放好一份模板，按需修改）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>          <string>ad-hoc</string>            <!-- 改成 development / app-store / enterprise -->
  <key>teamID</key>           <string>YOUR_TEAM_ID</string>
  <key>signingStyle</key>     <string>manual</string>
  <key>stripSwiftSymbols</key><true/>
  <key>compileBitcode</key>   <false/>
</dict>
</plist>
```

执行重签 & 打包：

```bash
# 0) 如果 build/ExportOptions.plist 不存在，先按上面创建
mkdir -p build
cat > build/ExportOptions.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>          <string>ad-hoc</string>
  <key>signingStyle</key>    <string>manual</string>
  <key>stripSwiftSymbols</key><true/>
  <key>compileBitcode</key>  <false/>
</dict>
</plist>
PLIST

# 1) 重签 .app（替换为你自己的 Identity）
codesign --force --sign "Apple Development: YOUR_NAME (YOUR_TEAM_ID)" \
         --entitlements /dev/null \
         build/unsigned/ImageLauncher.app

# 2) 打包成 .ipa
cd build/unsigned
mkdir -p Payload
cp -R ImageLauncher.app Payload/
zip -r ../ImageLauncher.ipa Payload
cd ../..

ls -lh build/ImageLauncher.ipa
```

> 上面 `method=ad-hoc` + `codesign` 重签后得到的 IPA 可用 Xcode → Devices → Install App 安装到自己的 iPhone 试运行。
> 想要真机分发请改 `method=development` 并用 `Apple Development: ...` 证书；想上架改 `method=app-store` 并使用 `Apple Distribution: ...` 证书。

---

## 4. 替换你的图片

| 资源 | 路径 | 命名建议 |
|---|---|---|
| App 启动后显示的图片 | `ImageLauncher/Assets.xcassets/AppDisplayImage.imageset/` | 替换 `预设.JPEG` 为你自己的图，**保持 1x scale**（universal） |
| App Icon 1024x1024 | `ImageLauncher/Assets.xcassets/AppIcon.appiconset/` | 替换 `图标.jpg` 为 1024×1024 PNG/JPG（**必须方形、无透明**） |

> 改完图片后重新 `Product → Clean Build Folder (⌘⇧K)` 再 Run，避免缓存。

---

## 5. 常见问题

- **`xcodebuild archive` 报 "no provisioning profile"** → 当前 .pbxproj 已默认 `CODE_SIGN_STYLE = Automatic`、未写死 Team，第一次在 Xcode 打开时选好 Team 即可；或者在命令行加 `DEVELOPMENT_TEAM=YOUR_TEAM_ID CODE_SIGN_IDENTITY="Apple Development"`。
- **状态栏没隐藏** → 检查 `INFOPLIST_KEY_UIStatusBarHidden = YES` 已在 build settings；本工程已写好。
- **图片变形** → `ContentView` 使用 `.aspectRatio(contentMode: .fit)`，永不裁剪、不变形、空白处为系统默认底（iOS 15+ SwiftUI 根 view 默认为黑底）。
- **App 图标不显示** → 替换为 1024×1024、**无 alpha**、RGB 色彩空间；`AppIcon.appiconset/Contents.json` 已声明单张 1024x1024 universal，iOS 14+ 即可。

---

## 6. Bundle / 项目关键参数

| 项 | 值 |
|---|---|
| Project Name | `ImageLauncher` |
| Scheme | `ImageLauncher` |
| Bundle ID | `com.example.ImageLauncher`（可改） |
| Deployment Target | iOS 15.0 |
| Orientations | Portrait only（iPhone） |
| Status Bar | Hidden |
| Dependencies | 无（无 Pod / SPM / 第三方 SDK） |
| Permissions | 无（不申请任何 iOS 系统权限） |
| Networking | 无 |
| Launch Screen | 由 Xcode 自动生成（系统行为） |

— 工程即开即用，按本文档第 1 节或第 2-3 节即可在 Mac 上出 `.app` 与 `.ipa`。

# 自签侧载到 iPhone（Windows 端，无需 Mac）

未签名 IPA 本身装不到未越狱 iPhone。本指南用 **Sideloadly**（Windows 免费工具，
借用你自己的 Apple ID 做开发签名）把 IPA 侧载到手机。免费 Apple ID 签名为 **7 天有效**，
到期后在 Sideloadly 里点一下重签即可。

## 第一步：用云端 Mac 编译出未签名 IPA

1. 注册/登录 GitHub（免费账号即可）。
2. 新建一个**公开**仓库（如 `ImageLauncher`）。
3. 把 `ImageLauncher.zip` 解压，进入 `ImageLauncher/` 目录，把它作为 git 仓库根推送：
   ```bash
   cd ImageLauncher
   git init
   git add .
   git commit -m "init"
   git branch -M main
   git remote add origin https://github.com/<你的用户名>/ImageLauncher.git
   git push -u origin main
   ```
   > 注意：仓库根必须是 `ImageLauncher/` 这一层（这样 `.github/workflows` 才在正确位置）。
4. 在 GitHub 仓库页面 → **Actions** → 找到 `Build Unsigned IPA` → **Run workflow**。
5. 跑完后，进入该次运行 → **Artifacts** → 下载 `ImageLauncher-unsigned-ipa`
   （即 `ImageLauncher.ipa`，未签名）。

> 没有 GitHub？也可借朋友的 Mac 跑 `bash build-ipa.sh`，效果相同。

## 第二步：Windows 上用 Sideloadly 自签安装

1. 下载安装 Sideloadly：https://sideloadly.io （Windows 版）。
2. iPhone 用数据线连到这台 Windows。
3. 打开 Sideloadly：
   - **IPA：** 选下载到的 `ImageLauncher.ipa`
   - **Apple ID：** 填你自己的 Apple 账号（邮箱）
   - 点 **Start** → 输入 Apple ID 密码（若开启双重认证，按提示填验证码/应用专用密码）
4. 手机上信任开发者：
   **设置 → 通用 → VPN与设备管理 → 信任你的 Apple ID 开发者证书**。
5. 回到桌面，打开 **ImageLauncher** → 直接全屏显示你的图片。

## 重要提醒

- 免费 Apple ID 签名 **每 7 天失效**，App 会打不开；重新插线用 Sideloadly 点一次
  **Start** 即可续期（无需重新下载 IPA）。
- 若想长期稳定（1 年、无 7 天限制），改用 **付费 Apple Developer 账号 ($99/年)** 的
  开发/企业证书，或越狱后直接装未签名包。
- 你的 Bundle Identifier 现在是 `com.example.ImageLauncher`，重签时 Sideloadly 会
  自动用你的账号重签；如需改成你自己的 ID，在 Xcode 工程 `ImageLauncher.xcodeproj`
  的 `PRODUCT_BUNDLE_IDENTIFIER` 修改后重新出 IPA 即可。

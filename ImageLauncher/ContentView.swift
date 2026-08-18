import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            Image("AppDisplayImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 保留顶部 safe area：让系统状态栏（时间/电量）正常显示，
        // 图片从状态栏下方开始，不被状态栏遮挡
        .ignoresSafeArea(.container, edges: [.bottom, .horizontal])
    }
}

#Preview {
    ContentView()
}

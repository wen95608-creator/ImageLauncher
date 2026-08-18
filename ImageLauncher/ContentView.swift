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
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea()
}

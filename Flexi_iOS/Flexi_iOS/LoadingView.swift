import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView("Uploading...")
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                .scaleEffect(2.0)
                .padding()
            Spacer()
        }
        .background(Color.black.opacity(0.7))
        .edgesIgnoringSafeArea(.all)
    }
}

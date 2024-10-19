import SwiftUI

struct HistoryPageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("History Page")
                    .font(.largeTitle)
                    .padding()

                Spacer()

                // Content specific to the History page can be added here
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
        .navigationBarHidden(true)  // Hide the navigation bar if needed
    }
}

struct HistoryPageView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryPageView()
    }
}

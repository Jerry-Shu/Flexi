import SwiftUI

struct ProfilePageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile Page")
                    .font(.largeTitle)
                    .padding()
                    .navigationBarBackButtonHidden(true)

                Spacer()

                // Profile-specific content goes here
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
        .navigationBarHidden(true)  // Hide the entire navigation bar if needed
    }
}

struct ProfilePageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePageView()
    }
}

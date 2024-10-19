import SwiftUI

struct ExercisePageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Exercise Page")
                    .font(.largeTitle)
                    .padding()

                Spacer()

                // Content specific to the Exercise page can be added here
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
        .navigationBarHidden(true)  // Hide the navigation bar if needed
    }
}

struct ExercisePageView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisePageView()
    }
}

import SwiftUI

struct HomeView: View {
    @State private var animationProgress: CGFloat = 0.0
    @State private var selectedTab = "Home" // State to track the selected tab

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Home Content
            VStack(alignment: .leading) {
                Text("Hello There...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.leading, 30)

                ZStack {
                    Image("goal_bg")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
  
                    Circle()
                        .trim(from: 0.0, to: 0.5)
                        .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(180))
                        .offset(y: 90)

                    Circle()
                        .trim(from: 0.0, to: animationProgress)
                        .stroke(AngularGradient(gradient: Gradient(colors: [Color.yellow]), center: .center), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(180))
                        .offset(y: 90)
                        .animation(.easeInOut(duration: 2.0), value: animationProgress)
                }
                .onAppear {
                    withAnimation {
                        animationProgress = 0.4
                    }
                }

                Text("Still couch surfing today — time to log some moves?")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.leading, 20)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                Button(action: {
                    selectedTab = "Exercise"
                }) {
                    Text("Let's Get Moving!")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                Spacer()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag("Home")
            
            // Exercise Content
            ExercisePageView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Exercise")
                }
                .tag("Exercise")

            // History Content
            HistoryPageView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag("History")

            // Profile Content
            ProfilePageView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag("Profile")
        }
        .accentColor(.yellow)  // Change tab accent color
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

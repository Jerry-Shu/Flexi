import SwiftUI

struct HomeView: View {
    @State private var animationProgress: CGFloat = 0.0
    @State private var selectedTab: String = "Home" // State to track the selected tab

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Greeting Text
                Text("Hello There...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.leading, 30)
                
                // Monthly Goal Card
                ZStack {
                    Image("goal_bg") // Replace with your actual image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    
                    // Bottom Gray Arch
                    Circle()
                        .trim(from: 0.0, to: 0.5)
                        .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(180))
                        .offset(y: 90)
                    
                    // Top Gradient Yellow Arch
                    Circle()
                        .trim(from: 0.0, to: animationProgress)
                        .stroke(AngularGradient(gradient: Gradient(colors: [Color.yellow]), center: .center), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(180))
                        .offset(y: 90)
                        .animation(.easeInOut(duration: 2.0), value: animationProgress)
                }
                .onAppear {
                    // Start the animation when the view appears
                    withAnimation {
                        animationProgress = 0.4 // Moves from 0.0 to 0.4 over 2 seconds
                    }
                }
                
                // Motivational Text
                Text("Still couch surfing today — time to log some moves?")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.leading, 20)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Let's Get Moving Button
                Button(action: {
                    // Action for moving to next step
                }) {
                    Text("Let's Get Moving !")
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

                // Bottom Navigation Bar
                HStack {
                    Spacer()
                    // Home Tab
                    NavigationLink(destination: HomePageView()) {
                        VStack {
                            Image(systemName: "house")
                                .foregroundColor(selectedTab == "Home" ? Color.yellow : Color.gray)
                            Text("Home")
                                .font(.caption)
                                .foregroundColor(selectedTab == "Home" ? Color.yellow : Color.gray)
                        }
                    }.simultaneousGesture(TapGesture().onEnded{
                        selectedTab = "Home"
                    })
                    Spacer()
                    // Exercise Tab
                    NavigationLink(destination: ExercisePageView()) {
                        VStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(selectedTab == "Exercise" ? Color.yellow : Color.gray)
                            Text("Exercise")
                                .font(.caption)
                                .foregroundColor(selectedTab == "Exercise" ? Color.yellow : Color.gray)
                        }
                    }.simultaneousGesture(TapGesture().onEnded{
                        selectedTab = "Exercise"
                    })
                    Spacer()
                    // History Tab
                    NavigationLink(destination: HistoryPageView()) {
                        VStack {
                            Image(systemName: "clock")
                                .foregroundColor(selectedTab == "History" ? Color.yellow : Color.gray)
                            Text("History")
                                .font(.caption)
                                .foregroundColor(selectedTab == "History" ? Color.yellow : Color.gray)
                        }
                    }.simultaneousGesture(TapGesture().onEnded{
                        selectedTab = "History"
                    })
                    Spacer()
                    // Profile Tab
                    NavigationLink(destination: ProfilePageView()) {
                        VStack {
                            Image(systemName: "person")
                                .foregroundColor(selectedTab == "Profile" ? Color.yellow : Color.gray)
                            Text("Profile")
                                .font(.caption)
                                .foregroundColor(selectedTab == "Profile" ? Color.yellow : Color.gray)
                        }
                    }.simultaneousGesture(TapGesture().onEnded{
                        selectedTab = "Profile"
                    })
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .shadow(radius: 5)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}

// Dummy Views for Navigation
struct HomePageView: View {
    var body: some View {
        Text("Home Page")
    }
}

struct ExercisePageView: View {
    var body: some View {
        Text("Exercise Page")
    }
}

struct HistoryPageView: View {
    var body: some View {
        Text("History Page")
    }
}

struct ProfilePageView: View {
    var body: some View {
        Text("Profile Page")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

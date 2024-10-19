import SwiftUI

struct HomeView: View {
    var body: some View {
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
                
                // Top Gradient Yellow Arch
                Circle()
                    .trim(from: 0.0, to: 0.4)
                    .stroke(AngularGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), center: .center), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(180))
                    .animation(.easeInOut(duration: 2.0), value: 0.4)
                
                // Knob at the end of the arch
                Circle()
                    .fill(Color.orange)
                    .frame(width: 20, height: 20)
                    .offset(x: 90)
                    .rotationEffect(.degrees(-180)) // Adjust this to match the trim value of the yellow arch
                    .animation(.easeInOut(duration: 2.0), value: 0.4)
                
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
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Image("menu_home")
                        .resizable()
                        .frame(width: 45, height: 50)
                }
                Spacer()
                VStack {
                    Image("menu_exercise")
                        .resizable()
                        .frame(width: 45, height: 50)
                }
                Spacer()
                VStack {
                    Image("menu_his")
                        .resizable()
                        .frame(width: 45, height: 50)
                }
                Spacer()
                VStack {
                    Image("menu_profile")
                        .resizable()
                        .frame(width: 45, height: 50)
                }
                Spacer()
            }
            .padding(.top, 20)
            .background(Color.white)
            .shadow(radius: 5)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

import SwiftUI

struct ProfilePageView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                // Profile Image
                Image("profile")
                    
                    .resizable()
                    .offset(x:3)
                    .scaledToFit()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.yellow, lineWidth: 4))
                    .frame(width: 120, height: 120)
                    .padding(.top, 20)
                    
                
                // Profile options list
                VStack(spacing: 0) {
                    ProfileMenuItem(icon: "clock.fill", title: "History")
                    Divider().padding(.leading, 50)
                    
                    ProfileMenuItem(icon: "ruler.fill", title: "Body Data")
                    Divider().padding(.leading, 50)
                    
                    ProfileMenuItem(icon: "heart.fill", title: "Apple Health")
                    Divider().padding(.leading, 50)
                    
                    ProfileMenuItem(icon: "camera.fill", title: "Photo Wall")
                    Divider().padding(.leading, 50)
                    
                    ProfileMenuItem(icon: "target", title: "My Goal")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
                
                // Log Out Button
                Button(action: {
                    // Add log out functionality here
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 60)
                
                Spacer()
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
        .navigationBarHidden(true)
    }
}

// Custom view for each menu item
struct ProfileMenuItem: View {
    var icon: String
    var title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .frame(width: 30, height: 30)
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
    }
}

struct ProfilePageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePageView()
    }
}

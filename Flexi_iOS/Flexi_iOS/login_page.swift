import SwiftUI

struct LoginView: View {
    @State private var showHomeView = false  // State to show the HomeView

    var body: some View {
        VStack {
            Spacer()

            // Logo Image
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding(.top, 20)
                .padding(.bottom, -50)

            // Email TextField
            TextField("Email", text: .constant(""))
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 40)
                .padding(.bottom, 15)

            // Password TextField
            SecureField("Password", text: .constant(""))
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 40)
                .padding(.bottom, 30)

            // Sign In Button
            Button(action: {
                showHomeView = true  // Set the state to true to present HomeView
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)

            // Use fullScreenCover to present HomeView modally
            .fullScreenCover(isPresented: $showHomeView) {
                HomeView()
            }

            // Sign Up Link
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.black)
                Button(action: {
                    // Action for sign up
                }) {
                    Text("Sign Up now")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Spacer()
        }
        .background(Color.yellow)
        .edgesIgnoringSafeArea(.all)
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

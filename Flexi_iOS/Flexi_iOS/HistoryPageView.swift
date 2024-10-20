import SwiftUI

struct HistoryPageView: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // History title
                    Text("History")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    // Calendar (DatePicker)
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .frame(height: 300)  // Adjust this height as per your needs
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    // History Card
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Legs Day")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // Edit icon
                            Image(systemName: "pencil")
                                .foregroundColor(.yellow)
                        }
                        .padding(.bottom, 4)
                        
                        Text("50 lbs     30 mins")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Exercise List
                        VStack(alignment: .leading, spacing: 10) {
                            ExerciseItemView(exerciseName: "Deficit Deadlift", weightAndReps: "50 lbs x 12", imageName: "deficit_bar")
                            Divider()
                            ExerciseItemView(exerciseName: "Hip Thrust", weightAndReps: "50 lbs x 12", imageName: "hip_bar")
                            Divider()
                            ExerciseItemView(exerciseName: "Front Squat", weightAndReps: "50 lbs x 12", imageName: "front_bar")
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    .offset(y: 25)
                    
                    Spacer()
                }
                .background(Color.white.edgesIgnoringSafeArea(.all))
            }
        }
        .navigationBarHidden(true)  // Hide the navigation bar if needed
    }
}

// Component to display each exercise item
struct ExerciseItemView: View {
    var exerciseName: String
    var weightAndReps: String
    var imageName: String

    var body: some View {
        HStack {
            // Use the image from the Assets folder
            Image(imageName)  // No need to use systemName here
                .resizable()
                .frame(width: 50, height: 50)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(exerciseName)
                    .font(.headline)
                Text(weightAndReps)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct HistoryPageView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryPageView()
    }
}

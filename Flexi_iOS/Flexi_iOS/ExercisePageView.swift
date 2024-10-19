import SwiftUI

struct ExercisePageView: View {
    @State private var selectedCategory: String? = nil  // Track the selected body part
    @State private var selectedExercise: Exercise?  // Track the selected exercise
    @State private var showDescription = false  // State to show the description modal
    
    // Categories by body part
    let categories = ["All", "Core", "Legs", "Arms", "Back", "Shoulder", "Chest", "Full Body", "Cardio", "Olympic", "Other"]
    
    // Example exercises categorized by body part
    let exercises = [
        Exercise(name: "Squat", imageName: "squat_b", category: "Legs", description_image: "detail_squat", instructions: [
            "Standing with feet shoulder-width apart, sit back with the hips while flexing hips and keeping knees pointed slightly outward.",
            "Continue down to the bottom position, while making sure you are maintaining a straight back and keeping weight evenly distributed throughout the foot.",
            "Exhale as you push upward from the bottom position, pushing the knees outward.",
            "Repeat for reps."
        ]),
        Exercise(name: "Standing Calf Raise", imageName: "calf_raise", category: "Legs", description_image: "some_des_image", instructions: [
            "Stand with feet shoulder-width apart.",
            "Raise your heels off the ground as high as possible while keeping your legs straight.",
            "Hold briefly at the top and lower down in a controlled manner.",
            "Repeat for reps."
        ]),
        Exercise(name: "Bicep Curl", imageName: "bicep_curl", category: "Arms",description_image: "some_des_image", instructions: [
            "Hold the weights with your palms facing up.",
            "Curl the weights up to your shoulders while keeping your elbows stationary.",
            "Slowly lower the weights back down to the starting position.",
            "Repeat for reps."
        ]),
        Exercise(name: "Tricep Dips", imageName: "tricep_dip", category: "Arms", description_image: "some_des_image", instructions: [
            "Position your hands shoulder-width apart on a secured bench or chair.",
            "Lower your body by bending your elbows, keeping them close to your body.",
            "Push yourself back up to the starting position.",
            "Repeat for reps."
        ]),
        Exercise(name: "Pull-Ups", imageName: "pullup", category: "Back", description_image: "some_des_image", instructions: [
            "Grab the pull-up bar with your palms facing away from you.",
            "Pull your body up until your chin clears the bar.",
            "Lower yourself back down in a controlled manner.",
            "Repeat for reps."
        ]),
        Exercise(name: "Deadlift", imageName: "deadlift", category: "Back", description_image: "some_des_image", instructions: [
            "Stand with your feet shoulder-width apart and grip the barbell just outside your knees.",
            "Lift the bar by extending your hips and knees until you're standing tall.",
            "Lower the bar back down to the ground by bending your hips and knees.",
            "Repeat for reps."
        ]),
        // Add more exercises as needed...
    ]
    
    // Filter exercises based on the selected category
    var filteredExercises: [Exercise] {
        if let category = selectedCategory, category != "All" {
            return exercises.filter { $0.category == category }
        } else {
            return exercises
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title on top
            Text("Exercises")
                .font(.largeTitle)
                .bold()
                .padding([.top, .leading], 20)
            
            HStack(alignment: .top) {
                // Left Sidebar with Categories
                VStack(alignment: .leading, spacing: 20) {  // Increase vertical spacing between categories
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category == "All" ? nil : category
                        }) {
                            Text(category)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(selectedCategory == category ? Color.yellow.opacity(0.3) : Color.clear)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(width: 120)  // Make the categories wider
                .padding(.top, 10)
                .background(Color(UIColor.systemGroupedBackground))
                
                // Right Side with Exercises
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(selectedCategory ?? "All Exercises")
                            .font(.title)
                            .bold()
                            .padding(.leading, 10)
                        
                        // Display exercises based on the selected category
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(filteredExercises) { exercise in
                                Button(action: {
                                    selectedExercise = exercise
                                    if selectedExercise != nil {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showDescription = true
                                        }
                                    }
                                }) {
                                    VStack {
                                        Image(exercise.imageName)  // Replace with your exercise image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)  // Smaller image size
                                        Text(exercise.name)
                                            .foregroundColor(.black)
                                            .font(.caption)  // Smaller font
                                    }
                                    .frame(width: 100, height: 100)  // Smaller button size
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: {
                showDescription && selectedExercise != nil
            },
            set: { newValue in
                showDescription = newValue
                if !newValue {
                    selectedExercise = nil  // Reset exercise when the sheet is dismissed
                }
            }
        )) {
            if let selectedExercise = selectedExercise {
                ExerciseDescriptionView(exercise: selectedExercise)
            }
        }
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let category: String
    let description_image:String
    let instructions: [String]
}

// Description View for the Exercise
struct ExerciseDescriptionView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(exercise.name) (\(exercise.category))")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: {
                    // Dismiss the modal, potentially using a Binding
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            
            // Exercise Images
            HStack(spacing: 30) {
                Image(exercise.description_image)  // Replace with your exercise images
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
//                Image(systemName: "figure.walk")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 10) {
                Text("Instructions:")
                    .font(.headline)
                    .padding(.top)
                
                ForEach(exercise.instructions, id: \.self) { instruction in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.yellow)
                        Text(instruction)
                            .padding(.leading, 5)
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding(.horizontal)
            
            Spacer()

            // Start Button
            Button(action: {
                // Start the exercise or dismiss
            }) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 30)  // Ensure there's enough padding at the bottom
        }
        .padding()
        .frame(maxHeight: .infinity)  // Ensure the modal takes the full available height
    }
}

struct ExercisePageView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisePageView()
    }
}

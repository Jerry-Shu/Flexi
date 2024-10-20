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
        Exercise(name: "Deadlift", imageName: "deadlift_d", category: "Back", description_image: "deficit", instructions: [
            "Stand with your feet hip-width apart and the barbell on the ground in front of you.",
            "Bend your knees slightly and hinge at the hips, lowering your torso to grasp the bar with both hands.",
            "Keep your back straight as you push through your heels and stand up, pulling the barbell close to your shins.",
            "Inhale as you lower the bar back to the ground, bending at the hips and knees.",
            "Repeat for reps."
        ]),
        Exercise(name: "Deficit Deadlift", imageName: "deficit_bar", category: "Back",description_image: "deficit", instructions: [
            "Stand on a platform or elevated surface (about 1-2 inches) with your feet hip-width apart and the barbell on the ground in front of you.",
            "Bend your knees slightly and hinge at the hips to grip the bar with both hands, ensuring your back remains straight.",
            "Push through your heels to lift the bar off the ground, extending your hips and knees as you stand upright.",
            "Keep the bar close to your body, engaging your core and back throughout the movement.",
            "Inhale as you lower the bar back to the ground, bending at the hips and knees, returning to the starting position.",
            "Repeat for reps."
        ]),
        Exercise(name: "Front Squat", imageName: "front_bar", category: "Arms", description_image: "front_squat", instructions: [
            "Stand with your feet shoulder-width apart, holding a barbell across the front of your shoulders with your elbows high and chest up.",
            "Sit back with your hips while keeping your chest upright, lowering your body until your thighs are parallel to the floor.",
            "Keep your knees tracking over your toes, and maintain a neutral spine throughout the movement.",
            "Push through your heels to return to the starting position, keeping your core tight.",
            "Exhale as you stand, inhale as you lower into the squat.",
            "Repeat for reps."
        ]),
        Exercise(name: "Hip Thrust", imageName: "hip_bar", category: "Back", description_image: "hip", instructions: [
            "Sit on the floor with your upper back resting against a bench and your feet flat on the floor, hip-width apart.",
            "Roll a barbell over your hips, positioning it just above your pelvis, and brace your core.",
            "Drive through your heels to lift your hips up, extending them until your body forms a straight line from shoulders to knees.",
            "Squeeze your glutes at the top, then slowly lower your hips back to the floor.",
            "Exhale as you lift, inhale as you lower down.",
            "Repeat for reps."
        ]),
        Exercise(name: "Kneeling Hip Thrust", imageName: "kneeling_b", category: "Back", description_image: "kneeling", instructions: [
            "Start in a kneeling position on a mat, with your upper body upright and hands on your hips or holding a weight at your chest.",
            "Push your hips back, lowering your glutes towards your heels while keeping your upper body straight.",
            "Drive your hips forward by squeezing your glutes and return to the upright kneeling position.",
            "Inhale as you lower your hips, exhale as you thrust forward.",
            "Repeat for reps."
        ]),
        Exercise(name: "Leg Press", imageName: "press_bar", category: "Back", description_image: "some_des_image", instructions: [
            "Sit on the leg press machine with your back flat against the seat and feet placed shoulder-width apart on the platform.",
            "Push through your heels to extend your legs, without locking your knees at the top of the movement.",
            "Lower the platform slowly by bending your knees, keeping them aligned with your toes.",
            "Inhale as you lower, exhale as you push the platform back up.",
            "Repeat for reps."
        ]),
        Exercise(name: "Lunge", imageName: "lunge_d", category: "Back", description_image: "some_des_image", instructions: [
            "Stand tall with feet hip-width apart and take a step forward with one leg.",
            "Lower your body until both knees are bent at 90 degrees, keeping your front knee above your ankle and your back knee hovering just above the ground.",
            "Push through the heel of your front foot to return to the starting position.",
            "Switch legs and repeat the movement.",
            "Inhale as you lower into the lunge, exhale as you push back up.",
            "Repeat for reps on each leg."
        ]),
        Exercise(name: "Squat(Dumbbell)", imageName: "squat_d", category: "Back", description_image: "some_des_image", instructions: [
            "Stand with feet shoulder-width apart, holding a dumbbell in each hand at your sides or one dumbbell in front of your chest.",
            "Sit back with your hips as you lower your body, keeping your chest upright and your back straight.",
            "Lower until your thighs are parallel to the floor, keeping your knees aligned with your toes.",
            "Push through your heels to return to the starting position.",
            "Inhale as you lower into the squat, exhale as you stand back up.",
            "Repeat for reps."
        ]),
        Exercise(name: "Standing Calf Raise", imageName: "standing_b", category: "Back", description_image: "standing", instructions: [
            "Stand on a flat surface with your feet shoulder-width apart, or on the edge of a step for an extended range of motion.",
            "Push through the balls of your feet to raise your heels as high as possible, squeezing your calves at the top.",
            "Slowly lower your heels back down to the ground.",
            "Exhale as you lift, inhale as you lower.",
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


struct ExerciseDescriptionView: View {
    let exercise: Exercise
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(exercise.name) (\(exercise.category))")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: {
                    // Dismiss the modal
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
                Image(exercise.description_image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }

            ScrollView {
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
            }

            Spacer()

            // Start Button
            Button(action: {
                self.showCamera = true
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
            .padding(.bottom, 30)
            .sheet(isPresented: $showCamera) {
                CameraView { videoURL in
                    uploadVideoToServer(videoURL: videoURL)
                }
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    func uploadVideoToServer(videoURL: URL) {
        // Upload video to server
        let serverURL = URL(string: "https://yourserver.com/upload")! // Replace with your server URL
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Append the video data
        let filename = videoURL.lastPathComponent
        let mimetype = "video/quicktime"
        let videoData = try! Data(contentsOf: videoURL)

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        data.append(videoData)
        data.append("\r\n".data(using: .utf8)!)

        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let session = URLSession.shared
        session.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse {
                print("Status code: \(response.statusCode)")
            }

            if let responseData = responseData {
                let responseString = String(data: responseData, encoding: .utf8)
                print("Response data: \(responseString ?? "No response data")")
            }
        }.resume()
    }
}

struct ExercisePageView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisePageView()
    }
}

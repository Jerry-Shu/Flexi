import SwiftUI
import AVFoundation

struct EvaluationPageView: View {
    let evaluationData: EvaluationData

    @State private var audioPlayer: AVAudioPlayer?
    @State private var isLoading = true
    @State private var dataReceived = false
    @State private var animationProgress: CGFloat = 0.0
    @State private var scoreText = ""
    @State private var totalScoreText = ""
    @State private var overallEvaluationText = ""
    @State private var nextLevelText = ""
    @State private var evaluationTextsArray = [""]
    @State private var nextLevelIssuesArray = [(issue: String, suggestion: String)]()
    @State private var wellDoneText = ""
    @State private var showLoadingBar = false
    @State private var showScore = false
    @State private var showOverallEvaluation = false
    @State private var showEvaluationPoints = false
    @State private var showNextLevel = false
    @State private var evaluationTextIndex = 0
    @State private var nextLevelIssueIndex = 0
    
    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
                    .onAppear {
                        loadData()
                    }
            } else {
                ScrollView {
                                   VStack(alignment: .leading) {
                                       // Play button at the top
                                       HStack {
                                           Spacer()
                                           Button(action: {
                                               playAudio() // Call the playAudio function when the button is clicked
                                           }) {
                                               Image(systemName: "play.circle.fill")
                                                   .resizable()
                                                   .scaledToFit()
                                                   .frame(width: 50, height: 50)
                                                   .foregroundColor(.blue)
                                                   .padding(.top, 20)
                                                   .padding(.trailing, 20)
                                           }
                                       }

                        // Title
                        if !wellDoneText.isEmpty {
                            Text(wellDoneText)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                        }

                        if showLoadingBar {
                            Spacer().frame(height: 20)

                            // Score Circle
                            ZStack {
                                Circle()
                                    .trim(from: 0.0, to: 1.0)
                                    .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                    .frame(width: 180, height: 180)
                                    .rotationEffect(.degrees(270))

                                Circle()
                                    .trim(from: 0.0, to: animationProgress)
                                    .stroke(AngularGradient(gradient: Gradient(colors: [Color.yellow]), center: .center), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                    .frame(width: 180, height: 180)
                                    .rotationEffect(.degrees(270))
                                    .animation(.easeInOut(duration: 2.0), value: animationProgress)

                                VStack {
                                    Image(systemName: "figure.stand")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                }
                            }
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .center)

                            // Display Score below the circle
                            if showScore {
                                HStack {
                                    Text(scoreText)
                                        .font(.system(size: 50))
                                        .fontWeight(.bold)
                                        .padding(.top, 10)

                                    Text(totalScoreText)
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }

                        if showOverallEvaluation {
                            Spacer().frame(height: 30)

                            // Overall Evaluation Section
                            HStack(spacing: 10) {
                                Image(systemName: "trophy.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.yellow)
                                Text(overallEvaluationText)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 20)
                            Divider()
                                .background(Color.yellow)
                                .padding(.horizontal, 20)

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(0..<evaluationTextIndex, id: \.self) { index in
                                    EvaluationPoint(number: index + 1, text: evaluationTextsArray[index])
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        if showNextLevel {
                            Spacer().frame(height: 30)

                            // Next Level Section
                            HStack(spacing: 10) {
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.yellow)
                                Text(nextLevelText)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 20)
                            Divider()
                                .background(Color.yellow)
                                .padding(.horizontal, 20)

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(0..<nextLevelIssueIndex, id: \.self) { index in
                                    IssuePoint(text: nextLevelIssuesArray[index].issue, suggestion: nextLevelIssuesArray[index].suggestion)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer()
                    }
                    .background(Color.white.edgesIgnoringSafeArea(.all))
                    .onAppear {
                        startEvaluationSequence()
                    }
                }
            }
        }
    }
    func playAudio() {
        guard let audioData = Data(base64Encoded: evaluationData.audio) else {
            print("Failed to decode audio string")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    private func startEvaluationSequence() {
        // Start by displaying the loading bar
        showLoadingBar = true

        // Simulate some delay to represent the evaluation process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Show the score after a short delay
            self.showScore = true
            self.animationProgress = CGFloat(self.evaluationData.rating) / 100.0

            // Update the evaluation index to display the evaluation points
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showOverallEvaluation = true
                self.evaluationTextIndex = self.evaluationData.overallEvaluation.count

                // After another delay, show the next level improvements
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showNextLevel = true
                    self.nextLevelIssueIndex = self.evaluationData.potentialImprovement.count
                }
            }
        }
    }

    
    private func loadData() {
        // Simulate loading data here
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataReceived = true
            self.isLoading = false
            self.populateData()
        }
    }

    private func populateData() {
        scoreText = "\(evaluationData.rating)"
        totalScoreText = "/100"
        overallEvaluationText = "Overall Evaluation"
        evaluationTextsArray = evaluationData.overallEvaluation
        nextLevelIssuesArray = evaluationData.potentialImprovement.map { (issue: $0.problem, suggestion: $0.improvement) }
    }

    // Your existing animation functions can stay as they are, adjusted as needed to use the new data
}

// MARK: - Supporting Views

struct EvaluationPoint: View {
    var number: Int
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 20, height: 20)
            Text(text)
                .font(.body)
        }
    }
}

struct IssuePoint: View {
    var text: String
    var suggestion: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                Text(text)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Text(suggestion)
                .font(.body)
                .foregroundColor(.gray)
                .padding(.leading, 30)
        }
    }
}

struct EvaluationPageView_Previews: PreviewProvider {
    static var previews: some View {
        EvaluationPageView(evaluationData: EvaluationData(
            audio: "audio.mp3",
            overallEvaluation: ["The person in the image appears to be slouching and not maintaining a neutral spine.", "There's a lack of engagement in the core muscles."],
            potentialImprovement: [
                EvaluationData.Improvement(problem: "Slouching Posture", improvement: "Sit upright with your shoulders relaxed and back straight. Engage your core muscles to support your spine."),
                EvaluationData.Improvement(problem: "Lack of Core Engagement", improvement: "Actively engage your core by tightening your stomach muscles. This will help you maintain a neutral spine and improve posture.")
            ],
            rating: 50
        ))
    }
}

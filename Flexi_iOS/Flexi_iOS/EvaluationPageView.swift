import SwiftUI
import AVFoundation

// MARK: - Data Models

struct PotentialImprovement: Codable {
    let improvement: String
    let problem: String
}

struct DataModel: Codable {
    let audio: String
    let overallEvaluation: [String]
    let potentialImprovement: [PotentialImprovement]
    let rating: String

    enum CodingKeys: String, CodingKey {
        case audio
        case overallEvaluation = "overall_evaluation"
        case potentialImprovement = "potential_improvement"
        case rating
    }
}

// MARK: - Evaluation Page View

struct EvaluationPageView: View {
    @State private var isLoading = true
    @State private var dataReceived = false
    @State private var animationProgress: CGFloat = 0.0
    @State private var scoreText = ""
    @State private var totalScoreText = ""
    @State private var overallEvaluationText = ""
    @State private var nextLevelText = ""
    @State private var evaluationTextsArray: [String]
    @State private var nextLevelIssuesArray: [(issue: String, suggestion: String)]
    @State private var wellDoneText = ""
    @State private var showLoadingBar = false
    @State private var showScore = false
    @State private var showOverallEvaluation = false
    @State private var showEvaluationPoints = false
    @State private var showNextLevel = false
    @State private var evaluationTextIndex = 0
    @State private var nextLevelIssueIndex = 0
    @State private var dataModel: DataModel?
    @State private var audioPlayer: AVAudioPlayer?
    
    // Variables to store data from JSON
    @State private var evaluationTexts: [String] = []
    @State private var nextLevelIssues: [(String, String)] = []
    
    // New initializer to accept jsonData
    init(jsonData: Data) {
        // Decode the JSON data and initialize the dataModel
        do {
            let decodedData = try JSONDecoder().decode([String: DataModel].self, from: jsonData)
            if let data = decodedData["data"] {
                _dataModel = State(initialValue: data)
                _evaluationTexts = State(initialValue: data.overallEvaluation)
                _nextLevelIssues = State(initialValue: data.potentialImprovement.map { ($0.problem, $0.improvement) })
                
                // Initialize the arrays based on the data sizes
                _evaluationTextsArray = State(initialValue: [String](repeating: "", count: data.overallEvaluation.count))
                _nextLevelIssuesArray = State(initialValue: [(issue: String, suggestion: String)](repeating: ("", ""), count: data.potentialImprovement.count))
            } else {
                _evaluationTextsArray = State(initialValue: [])
                _nextLevelIssuesArray = State(initialValue: [])
            }
        } catch {
            print("Error decoding JSON: \(error)")
            var potentialImprovements: [PotentialImprovement] = []
            potentialImprovements.append(PotentialImprovement(improvement: "Keep knees straight, and engage the quads to keep them that way.", problem: "The lifter's knees are slightly bent."))
            potentialImprovements.append(PotentialImprovement(improvement: "Push your chest out and bring your shoulders directly over the bar. This ensures the proper position and keeps the load off the lower back", problem: "The lifter's shoulders are slightly ahead of the bar."))
            potentialImprovements.append(PotentialImprovement(improvement: "Try to keep the hips low, almost like squatting. This ensures the load is on the hamstrings and glutes, not the lower back.", problem: "The lifter's hip position is slightly too high, causing the load to go on the lower back."))
            let defaultDataModel = DataModel(
                        audio: "",
                        overallEvaluation: ["The lifter is demonstrating a decent deadlift, but there are areas for improvement.",
                                            "Their back is mostly flat but could use more engagement."],
                        potentialImprovement: potentialImprovements,
                        rating: "65" // Default value for rating
                    )
                    
                    _dataModel = State(initialValue: defaultDataModel)
//                    _evaluationTexts = State(initialValue: defaultDataModel.overallEvaluation)
//                    _nextLevelIssues = State(initialValue: defaultDataModel.potentialImprovement.map { ($0.problem, $0.improvement) })
                    
            _evaluationTextsArray = State(initialValue: defaultDataModel.overallEvaluation)
            _nextLevelIssuesArray = State(initialValue: defaultDataModel.potentialImprovement.map { ($0.problem, $0.improvement) })
        }
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                // Loading view while data is being prepared
                LoadingView()
                    .onAppear {
                        // Data is already loaded during initialization
                        dataReceived = true
                        isLoading = false
                        startEvaluationSequence()
                    }
            } else {
                // Main evaluation page view
                ScrollView {
                    VStack(alignment: .leading) {
                        // Play button at the top
                        HStack {
                            Spacer()
                            Button(action: {
                                playAudio()
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
                        
                        // The rest of your UI code goes here...
                        // Use the data from dataModel, evaluationTextsArray, and nextLevelIssuesArray
                        
                        // For example, displaying the score:
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
                        
                        // Continue with the rest of the UI components...
                    }
                    .background(Color.white.edgesIgnoringSafeArea(.all))
                }
            }
        }
    }
    
    // MARK: - Animation Functions

    // Implement your animation and typewriter effect functions here,
    // ensuring they use the data from dataModel, evaluationTexts, and nextLevelIssues.
    
    // Example:
    private func startEvaluationSequence() {
        guard let dataModel = dataModel else { return }
        
        typeWriterEffect(for: "Well Done!", target: $wellDoneText, perCharacterDelay: 0.01) {
            showLoadingBar = true
            withAnimation(.easeInOut(duration: 2.0)) {
                if let ratingInt = Int(dataModel.rating) {
                    // Safely convert String to Int and then to CGFloat
                    let animationProgress = CGFloat(ratingInt) / 100.0
                    // Use animationProgress as needed
                    print("Animation progress: \(animationProgress)")
                } else {
                    // Handle the case where dataModel.rating cannot be converted to Int
                    print("Invalid rating: \(dataModel.rating)")
                }
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showScore = true
                typeWriterEffect(for: "\(dataModel.rating)", target: $scoreText, perCharacterDelay: 0.01) {
                    typeWriterEffect(for: "/100", target: $totalScoreText, perCharacterDelay: 0.01) {
                        showOverallEvaluation = true
                        typeWriterEffect(for: "Overall Evaluation", target: $overallEvaluationText, perCharacterDelay: 0.01) {
                            startEvaluationTextAnimation()
                        }
                    }
                }
            }
        }
    }
    
    private func startEvaluationTextAnimation(at index: Int = 0) {
        if index < evaluationTexts.count {
            typeWriterEffect(for: evaluationTexts[index], target: $evaluationTextsArray[index], perCharacterDelay: 0.02) {
                evaluationTextIndex = index + 1
                startEvaluationTextAnimation(at: index + 1)
            }
        } else {
            showNextLevel = true
            typeWriterEffect(for: "Next Level", target: $nextLevelText, perCharacterDelay: 0.01) {
                startNextLevelIssuesAnimation()
            }
        }
    }
    
    private func startNextLevelIssuesAnimation(at index: Int = 0) {
        if index < nextLevelIssues.count {
            let (problem, improvement) = nextLevelIssues[index]
            typeWriterEffect(for: problem, target: Binding<String>(
                get: { self.nextLevelIssuesArray[index].issue },
                set: { self.nextLevelIssuesArray[index].issue = $0 }
            ), perCharacterDelay: 0.02) {
                typeWriterEffect(for: improvement, target: Binding<String>(
                    get: { self.nextLevelIssuesArray[index].suggestion },
                    set: { self.nextLevelIssuesArray[index].suggestion = $0 }
                ), perCharacterDelay: 0.02) {
                    nextLevelIssueIndex = index + 1
                    startNextLevelIssuesAnimation(at: index + 1)
                }
            }
        }
    }
    
    // MARK: - Typewriter Effect Function
    
    private func typeWriterEffect(for text: String, target: Binding<String>, delayBeforeStart: Double = 0.0, perCharacterDelay: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeStart) {
            target.wrappedValue = ""
            var currentIndex = 0
            let timer = Timer.scheduledTimer(withTimeInterval: perCharacterDelay, repeats: true) { timer in
                if currentIndex < text.count {
                    let index = text.index(text.startIndex, offsetBy: currentIndex)
                    target.wrappedValue.append(text[index])
                    currentIndex += 1
                } else {
                    timer.invalidate()
                    completion()
                }
            }
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    // MARK: - Audio Playback Function
    
    private func playAudio() {
        guard let dataModel = dataModel else {
            print("Data model is not available")
            return
        }
        let audioBase64String = dataModel.audio
        if let audioData = Data(base64Encoded: audioBase64String) {
            do {
                audioPlayer = try AVAudioPlayer(data: audioData)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error initializing audio player: \(error)")
            }
        } else {
            print("Error decoding base64 audio data")
        }
    }
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





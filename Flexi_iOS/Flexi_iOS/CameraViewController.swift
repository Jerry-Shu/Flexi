import UIKit
import AVFoundation
import SwiftUI // Import SwiftUI for LoadingView and EvaluationPageView

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var movieOutput = AVCaptureMovieFileOutput()
    var currentCameraInput: AVCaptureDeviceInput?
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var isUsingFrontCamera = true
    var onRecordingFinished: ((URL) -> Void)?
    var onCancel: (() -> Void)?

    var countdownLabel: UILabel!
    var stopButton: UIButton!
    var flipCameraButton: UIButton!
    var activityIndicator: UIActivityIndicatorView!
    var countdownTimer: Timer?
    var isRecording = false
    var recordingTimer: Timer? // Timer to stop recording after 20 seconds

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameras()
        setupUI()
        startCountdownAndRecording()
    }

    func setupCameras() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        let devices = AVCaptureDevice.devices(for: .video)
        for device in devices {
            if device.position == .front {
                frontCamera = device
            } else if device.position == .back {
                backCamera = device
            }
        }

        // Start with the front camera
        if let frontCamera = frontCamera {
            addCameraInput(camera: frontCamera)
        }

        setupLivePreview()
    }

    func addCameraInput(camera: AVCaptureDevice) {
        do {
            let newInput = try AVCaptureDeviceInput(device: camera)
            
            // Remove current input if available
            if let currentInput = currentCameraInput {
                captureSession.beginConfiguration()
                captureSession.removeInput(currentInput)
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                    currentCameraInput = newInput
                }
                captureSession.commitConfiguration()
            } else {
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                    currentCameraInput = newInput
                }
            }
        } catch {
            print("Error setting up camera input: \(error)")
        }

        // Ensure the movie output is added to the session
        if !captureSession.outputs.contains(movieOutput) {
            if captureSession.canAddOutput(movieOutput) {
                captureSession.addOutput(movieOutput)
            }
        }
    }

    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(videoPreviewLayer, at: 0)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
    }

    func setupUI() {
        // Countdown Label
        countdownLabel = UILabel()
        countdownLabel.textAlignment = .center
        countdownLabel.font = UIFont.systemFont(ofSize: 50)
        countdownLabel.textColor = .white
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countdownLabel)

        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Stop Button (3x larger)
        stopButton = UIButton(type: .system)
        stopButton.setImage(UIImage(systemName: "record.circle"), for: .normal) // Red dot icon
        stopButton.tintColor = .red
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        stopButton.transform = CGAffineTransform(scaleX: 3.0, y: 3.0) // Make the button 3 times larger
        view.addSubview(stopButton)

        NSLayoutConstraint.activate([
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])

        // Flip Camera Button (3x larger)
        flipCameraButton = UIButton(type: .system)
        flipCameraButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal) // Flip camera icon
        flipCameraButton.tintColor = .white
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        flipCameraButton.transform = CGAffineTransform(scaleX: 3.0, y: 3.0) // Make the button 3 times larger
        view.addSubview(flipCameraButton)

        NSLayoutConstraint.activate([
            flipCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flipCameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }

    func startCountdownAndRecording() {
        countdownLabel.isHidden = false
        var countdown = 3
        countdownLabel.text = "\(countdown)"

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            self.countdownLabel.text = "\(countdown)"
            if countdown == 0 {
                timer.invalidate()
                self.countdownLabel.text = "Action!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.countdownLabel.isHidden = true
                    self.startRecording()
                }
            }
        }
    }

    func startRecording() {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mov")
        try? FileManager.default.removeItem(at: outputURL)
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        isRecording = true

        // Set a timer to automatically stop recording after 20 seconds
        recordingTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(stopRecording), userInfo: nil, repeats: false)
    }

    @objc func stopRecording() {
        if isRecording {
            if movieOutput.isRecording {
                movieOutput.stopRecording()
            }
            isRecording = false

            // Invalidate the recording timer if the stop button is pressed manually
            recordingTimer?.invalidate()
            recordingTimer = nil

            // Show loading indicator while navigating to a new loading screen
            let loadingView = LoadingView()
            let hostingController = UIHostingController(rootView: loadingView)
            hostingController.modalPresentationStyle = .fullScreen
            self.present(hostingController, animated: true) {
                self.uploadVideoToServerAfterStop() // Start uploading after presenting the loading screen
            }
        }
    }

    @objc func flipCamera() {
        // Apply fade-out animation for smooth transition
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.videoPreviewLayer.opacity = 0
        }) { _ in
            // Toggle camera
            self.isUsingFrontCamera.toggle()
            let newCamera = self.isUsingFrontCamera ? self.frontCamera : self.backCamera
            if let camera = newCamera {
                self.addCameraInput(camera: camera)

                // Apply fade-in animation after switching
                UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.videoPreviewLayer.opacity = 1
                })
            }
        }
    }

    func uploadVideoToServerAfterStop() {
        if let outputURL = movieOutput.outputFileURL {
            uploadVideoToServer(videoURL: outputURL)
        }
    }

    // MARK: - AVCaptureFileOutputRecordingDelegate

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error)")
        } else {
            // Start uploading after the recording stops
            uploadVideoToServer(videoURL: outputFileURL)
        }
    }

    func uploadVideoToServer(videoURL: URL) {
        // Prepare the URL
        guard let url = URL(string: "http://172.20.10.13:5656/api/upload") else {
            print("Invalid URL")
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Prepare the multipart/form-data body
        let fullData = createBodyWithParameters(filePathKey: "file", paths: [videoURL.path], boundary: boundary)

        request.httpBody = fullData

        // Create the upload task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle the response
            if let error = error {
                print("Upload failed with error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                // Success
                DispatchQueue.main.async {
                    // Navigate to EvaluationPageView when the upload is finished
                    let evaluationView = EvaluationPageView()
                    let hostingController = UIHostingController(rootView: evaluationView)
                    hostingController.modalPresentationStyle = .fullScreen

                    if let presentedVC = UIApplication.shared.windows.first?.rootViewController?.presentedViewController {
                        presentedVC.present(hostingController, animated: true, completion: nil)
                    } else {
                        UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true, completion: nil)
                    }
                }
            } else {
                // Server returned an error
                print("Server returned status code \(httpResponse.statusCode)")
            }
        }

        // Start the upload
        task.resume()
    }

    // Helper function to create the multipart/form-data body
    func createBodyWithParameters(filePathKey: String?, paths: [String], boundary: String) -> Data {
        var body = Data()

        for path in paths {
            let url = URL(fileURLWithPath: path)
            let filename = url.lastPathComponent
            guard let data = try? Data(contentsOf: url) else { continue }
            let mimetype = "video/mp4"

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(filePathKey ?? "file")\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }

}

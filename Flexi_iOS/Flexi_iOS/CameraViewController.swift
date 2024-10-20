import UIKit
import AVFoundation
import SwiftUI

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    // MARK: - Properties
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var movieOutput = AVCaptureMovieFileOutput()
    var currentCameraInput: AVCaptureDeviceInput?
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var isUsingFrontCamera = true
    var onRecordingFinished: ((Data) -> Void)?
    var onCancel: (() -> Void)?
    
    var countdownLabel: UILabel!
    var stopButton: UIButton!
    var flipCameraButton: UIButton!
    var countdownTimer: Timer?
    var isRecording = false
    var recordingTimer: Timer?
    var loadingViewController: UIViewController? // Reference to the loading view controller

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameras()
        setupUI()
        startCountdownAndRecording()
    }

    // MARK: - Camera Setup
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

    // MARK: - UI Setup
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
        stopButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
        stopButton.tintColor = .red
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        stopButton.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        view.addSubview(stopButton)

        NSLayoutConstraint.activate([
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])

        // Flip Camera Button (3x larger)
        flipCameraButton = UIButton(type: .system)
        flipCameraButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        flipCameraButton.tintColor = .white
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        flipCameraButton.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        view.addSubview(flipCameraButton)

        NSLayoutConstraint.activate([
            flipCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flipCameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Recording Functions
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
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mp4")
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

            // Do not present the loading view here
            // The loading view will be presented after recording finishes
        }
    }

    // MARK: - AVCaptureFileOutputRecordingDelegate Method
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }

        // Handle successful recording
        print("Video successfully recorded to: \(outputFileURL)")

        // Convert video to Data
        do {
            let videoData = try Data(contentsOf: outputFileURL)

            // Present loading view and then start uploading
            DispatchQueue.main.async {
                let loadingView = LoadingView()
                let hostingController = UIHostingController(rootView: loadingView)
                hostingController.modalPresentationStyle = .fullScreen
                self.present(hostingController, animated: true)
                self.loadingViewController = hostingController
                // Start uploading after presenting the loading view
                self.uploadVideo(data: videoData)
            }
        } catch {
            print("Error converting video to Data: \(error.localizedDescription)")
        }
    }

    // MARK: - Upload Function
    func uploadVideo(data: Data) {
        let urlString = "http://172.20.10.13:5656/api/upload"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120 // Extended timeout
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Build body
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"video.mp4\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Print body size
        print("Body size: \(body.count) bytes")

        // Use a custom URLSession with extended timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 120
        let session = URLSession(configuration: config)

        let task = session.uploadTask(with: request, from: body) { (responseData, response, error) in
            if let error = error as NSError? {
                print("Error uploading video: \(error.localizedDescription)")
                print("Error code: \(error.code)")
                print("Error domain: \(error.domain)")
                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                    print("Underlying error: \(underlyingError.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.showUploadError()
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    // Upload successful
                    print("Video uploaded successfully.")

                    // Parse the response data to extract 'file_path'
                    if let responseData = responseData {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                               let dataDict = json["data"] as? [String: Any],
                               let filePath = dataDict["file_path"] as? String {
                                print("Extracted file_path: \(filePath)")

                                // Now send a POST request to /api/evaluate with body {url: file_path}
                                self.evaluateVideo(with: filePath)
                            } else {
                                print("Could not parse file_path from response.")
                                DispatchQueue.main.async {
                                    self.showUploadError()
                                }
                            }
                        } catch {
                            print("Error parsing response data: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.showUploadError()
                            }
                        }
                    } else {
                        print("No response data received.")
                        DispatchQueue.main.async {
                            self.showUploadError()
                        }
                    }
                } else {
                    // Handle server error
                    print("Server error: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.showUploadError()
                    }
                }
            } else {
                print("Invalid response received from the server.")
                DispatchQueue.main.async {
                    self.showUploadError()
                }
            }
        }

        task.resume()
    }

    func evaluateVideo(with filePath: String) {
        let urlString = "http://172.20.10.13:5656/api/evaluate"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            DispatchQueue.main.async {
                self.showUploadError()
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120 // Extended timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create JSON body with 'url': filePath
        let bodyDict: [String: String] = ["url": filePath]
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
            request.httpBody = bodyData
        } catch {
            print("Error creating JSON body: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.showUploadError()
            }
            return
        }

        // Use the same URLSession configuration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 120
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error as NSError? {
                print("Error evaluating video: \(error.localizedDescription)")
                print("Error code: \(error.code)")
                print("Error domain: \(error.domain)")
                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                    print("Underlying error: \(underlyingError.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.showUploadError()
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Evaluation response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    // Evaluation successful
                    print("Video evaluated successfully.")
                    // Handle the evaluation response as needed
                    // For example, parse the response data and present the evaluation page
                    DispatchQueue.main.async {
                        self.presentEvaluationPage()
                    }
                } else {
                    // Handle server error
                    print("Server error during evaluation: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.showUploadError()
                    }
                }
            } else {
                print("Invalid response received from the server during evaluation.")
                DispatchQueue.main.async {
                    self.showUploadError()
                }
            }
        }

        task.resume()
    }


    // MARK: - Helper Functions
    func presentEvaluationPage() {
        DispatchQueue.main.async {
            // Dismiss the loading view before presenting the evaluation page
            self.loadingViewController?.dismiss(animated: true, completion: {
                let evaluationPageView = EvaluationPageView()
                let hostingController = UIHostingController(rootView: evaluationPageView)
                hostingController.modalPresentationStyle = .fullScreen
                self.present(hostingController, animated: true, completion: nil)
            })
        }
    }

    func showUploadError() {
        DispatchQueue.main.async {
            // Dismiss the loading view before presenting the alert
            self.loadingViewController?.dismiss(animated: true, completion: {
                let alert = UIAlertController(title: "Upload Failed", message: "Failed to upload the video. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            })
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
}

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var onRecordingFinished: (URL) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onRecordingFinished = { url in
            self.onRecordingFinished(url)
            self.presentationMode.wrappedValue.dismiss()
        }
        controller.onCancel = {
            self.presentationMode.wrappedValue.dismiss()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No updates needed here for now
    }
}

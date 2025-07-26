import SwiftUI
import UIKit

public struct CameraPickerView: UIViewControllerRepresentable {
	@Environment(\.presentationMode) private var presentationMode
	@Binding private var image: UIImage?

	public init(image: Binding<UIImage?>) {
		self._image = image
	}

	public func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.sourceType = .camera
		picker.delegate = context.coordinator
		return picker
	}

	public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		var parent: CameraPickerView

		public init(_ parent: CameraPickerView) {
			self.parent = parent
		}

		public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
			if let selectedImage = info[.originalImage] as? UIImage {
				DispatchQueue.main.async {
					self.parent.image = selectedImage
				}
			}
			parent.presentationMode.wrappedValue.dismiss()
		}

		public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			parent.presentationMode.wrappedValue.dismiss()
		}
	}
}

import SwiftUI

fileprivate class PhotoMenuState: ObservableObject {
	@Published var isPickerPresented = false
	@Published var isCameraPresented = false
	@Published var isFileImporterPresented = false
	@Published var isPhotoClearPresented = false
	@Published var canPasteImage = false
	@Published var importedImage: UIImage? = nil
}

public struct PhotoMenuView: View {
	public struct MenuOptions: OptionSet, Sendable {
		public let rawValue: Int
		
		public static let photos = MenuOptions(rawValue: 1 << 0)
		public static let camera = MenuOptions(rawValue: 1 << 1)
		public static let files = MenuOptions(rawValue: 1 << 2)
		public static let paste = MenuOptions(rawValue: 1 << 3)
		public static let edit = MenuOptions(rawValue: 1 << 4)
		public static let clear = MenuOptions(rawValue: 1 << 5)
		
		public static let all: MenuOptions = [.photos, .camera, .files, .paste, .edit, .clear]
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}

	@Binding private var image: UIImage?
	@StateObject private var state = PhotoMenuState()
	
	private let options: MenuOptions

	public init(image: Binding<UIImage?>, options: MenuOptions = .all) {
		self._image = image
		self.options = options
	}

	public var body: some View {
		Menu("Select Photo") {
			if options.contains(.photos) {
				Button(action: { state.isPickerPresented = true }) {
					Label("Photos", systemImage: "photo.on.rectangle")
				}
			}
			if options.contains(.camera) {
				Button(action: { state.isCameraPresented = true }) {
					Label("Camera", systemImage: "camera")
				}
			}
			if options.contains(.files) {
				Button(action: { state.isFileImporterPresented = true }) {
					Label("Files", systemImage: "folder")
				}
			}
			if options.contains(.paste) {
				Button(action: {
					if let pasted = UIPasteboard.general.image {
						DispatchQueue.main.async {
							state.importedImage = pasted
						}
					}
				}) {
					Label("Paste", systemImage: "doc.on.clipboard")
				}
				.disabled(!state.canPasteImage)
			}
			if options.contains(.edit) {
				Button(action: {
					if let currentImage = image {
						DispatchQueue.main.async {
							state.importedImage = currentImage
						}
					}
				}) {
					Label("Edit", systemImage: "crop")
				}
				.disabled(image == nil)
			}
			if options.contains(.clear) {
				Button(role: .destructive) {
					state.isPhotoClearPresented = true
				} label: {
					Label("Clear", systemImage: "trash")
				}
				.disabled(image == nil)
			}
		}
		.onChange(of: state.importedImage) { newValue in
			if let newValue {
				state.importedImage = nil
				image = newValue
			}
		}
		.sheet(isPresented: $state.isPickerPresented) {
			PhotoPickerView(image: $state.importedImage)
		}
		.fullScreenCover(isPresented: $state.isCameraPresented) {
			CameraPickerView(image: $state.importedImage)
		}
		.fileImporter(
			isPresented: $state.isFileImporterPresented,
			allowedContentTypes: [.image],
			allowsMultipleSelection: false
		) { result in
			switch result {
			case .success(let urls):
				if let url = urls.first {
					if let data = try? Data(contentsOf: url),
					   let uiImage = UIImage(data: data) {
						DispatchQueue.main.async {
							state.importedImage = uiImage
						}
					}
				}
			case .failure:
				break
			}
		}
		.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
			state.canPasteImage = UIPasteboard.general.hasImages
		}
		.alert("Clear Photo", isPresented: $state.isPhotoClearPresented) {
			Button("Clear", role: .destructive) {
				DispatchQueue.main.async {
					self.image = nil
				}
			}
			Button("Cancel", role: .cancel) { }
		}
	}
}

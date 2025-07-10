import SwiftUI

//TODO: refactor so PhotoCropperSheet manages navigationStack/toolbars and created a view called PhotoCropperView that handles gestures and geometry reader.
//TODO: have calcCropRect be a strategy (removes inset init arg)
//TODO: use CroppingGesture
public struct PhotoCropperSheet: View {
	@Environment(\.dismiss) private var dismiss
	let image: UIImage?
	let result: ((UIImage?) -> Void)?
	let inset: Double
	let opacity: Double

	@State private var userGestured: Bool = false
	@State private var transform: CroppingState

	public init(
			image: UIImage?,
			result: ((UIImage?) -> Void)?,
			fill: Bool = true,
			maxScale: Double = 8.0,
			inset: Double = 16,
			opacity: Double = 0.4) {
		self.image = image
		self.result = result
		self.inset = inset
		self.opacity = opacity
		self._transform = State(initialValue: .init(fill: fill, maxScale: maxScale))
	}

	public init(data: Data?) {
		self = .init(
			image: data.flatMap {UIImage(data: $0) },
			result: nil,
			fill: false,
			maxScale: 8.0,
			inset: 0.0,
			opacity: 0.0)
	}

	public var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				let cropRect = calcCropRect(geometry.size)
				CroppedImagePreview(image: image, transform: transform, cropRect: cropRect, opacity: opacity)
				.gesture(zoomAndPanGesture(cropRect: cropRect))
				.onChange(of: geometry.size) { oldSize, newSize in
					if !userGestured {
						reset(cropRect)
					}
				}
				.simultaneousGesture(TapGesture(count: 2)
					.onEnded {
						reset(cropRect)
					})
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItemGroup(placement: .topBarLeading) {
						DismissButton {
							if let result {
								result(transform.render(image, cropRect))
							}
							dismiss()
						}
					}
					ToolbarItemGroup(placement: .principal) {
						Text(result != nil ? "Crop Photo" : "").foregroundStyle(.white)
					}
					ToolbarItemGroup(placement: .topBarTrailing) {
						ActionButton("Reset", systemImage: "inset.filled.square.dashed") {
							reset(cropRect)
						}
						if let result {
							CancelButton {
								result(nil)
								dismiss()
							}
						}
					}
				}
			}
		}
	}

	private func zoomAndPanGesture(cropRect: CGRect) -> some Gesture {
		SimultaneousGesture(
			DragGesture()
				.onChanged { value in
					if let image {
						userGestured = true
						transform.applyOffset(imgSize: image.size, value.translation, cropping: cropRect)
					}
				}
				.onEnded { _ in
					transform.endDrag()
				},
			MagnificationGesture()
				.onChanged { value in
					if let image {
						userGestured = true
						transform.applyScale(imgSize: image.size, value, cropping: cropRect)
					}
				}
				.onEnded { _ in
					transform.endScale()
				}
		)
	}

	func calcCropRect(_ size: CGSize) -> CGRect {
		if result != nil {
			let minLength = min(size.width, size.height)
			return CGRect(
				x: (size.width - minLength) / 2 + inset,
				y: (size.height - minLength) / 2 + inset,
				width: minLength - 2 * inset,
				height: minLength - 2 * inset)
		}
		return CGRect(
			x: inset,
			y: inset,
			width: size.width - (2 * inset),
			height: size.height - (2 * inset))
	}

	private func reset(_ cropRect: CGRect) {
		withAnimation() {
			if let image {
				transform.reset(imgSize: image.size, cropping: cropRect)
			}
		}
	}
}

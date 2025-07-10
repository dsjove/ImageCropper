import SwiftUI

// TODO: use previously set background and foreground colors
public struct CroppedImagePreview: View {
	public let image: UIImage?
	public let transform: CroppingState
	public let cropRect: CGRect?
	public var opacity: Double = 0.4

	public var body: some View {
		ZStack {
			Color.black.ignoresSafeArea()
			if let image {
				if transform.fill {
					if opacity > 0.0 {
						Image(uiImage: image)
							.croppingStyle(transform, cropRect)
							.opacity(opacity)
					}
					Image(uiImage: image)
						.croppingStyle(transform, cropRect)
						.clipped()
						.background(Color.black)
				} else {
					Image(uiImage: image)
						.croppingStyle(transform, cropRect)
				}
			} else {
				Image(systemName: "photo")
					.foregroundStyle(.white)
					.font(.largeTitle)
			}
			if let cropRect, transform.fill {
				Rectangle()
					.path(in: cropRect)
					.stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
					.foregroundColor(.white)
			}
		}
	}
}

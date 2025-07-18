import UIKit

public extension UIColor {
	var brightness: CGFloat {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return (red * 299 + green * 587 + blue * 114) / 1000
	}
	
	var isLight: Bool {
		brightness > 0.5
	}
}

public extension UIImage {
	convenience init?(data: Data?) {
		guard let data = data else {
			return nil
		}
		self.init(data: data)
	}

	func shrinkTo(_ targetSize: CGSize) -> UIImage {
		if self.size.width <= targetSize.width && self.size.height <= targetSize.height {
			return self
		}

		let widthRatio = targetSize.width / size.width
		let heightRatio = targetSize.height / size.height
		let scaleFactor = min(widthRatio, heightRatio)

		// Compute scaled size that fits inside targetSize
		let scaledSize = CGSize(
			width: size.width * scaleFactor,
			height: size.height * scaleFactor
		)

		let renderer = UIGraphicsImageRenderer(size: scaledSize)
		return renderer.image { _ in
			self.draw(in: CGRect(origin: .zero, size: scaledSize))
		}
	}
}

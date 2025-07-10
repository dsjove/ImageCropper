import Foundation

public struct CodableColor: Codable {
	public var red: Double
	public var green: Double
	public var blue: Double
	public var opacity: Double

	public init(_ red: Double, _ green: Double, _ blue: Double, _ opacity: Double = 1.0) {
		self.red = red
		self.green = green
		self.blue = blue
		self.opacity = opacity
	}

	public init() {
		self.red = 1.0
		self.green = 1.0
		self.blue = 1.0
		self.opacity = 1.0
	}
}

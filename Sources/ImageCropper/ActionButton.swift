import SwiftUI

@MainActor
struct ActionButton : View {
	let label: String
	let accessibilityLabel: String
	let systemImage: String
	let labeled: Bool
	let action: () -> Void

	init(
			_ label: String,
			labeled: Bool = false,
			accessibilityLabel: String? = nil,
			systemImage: String = "",
			action: @escaping () -> Void) {
		self.label = label
		self.accessibilityLabel = accessibilityLabel ?? label
		self.labeled = labeled
		self.systemImage = systemImage
		self.action = action
	}

	var body: some View {
		Button {
			action()
		} label: {
			if systemImage.isEmpty {
				Text(label)
					.accessibilityLabel(accessibilityLabel)
			} else if label.isEmpty {
				Label(label, systemImage: systemImage)
					.labelStyle(.iconOnly)
					.accessibilityLabel(accessibilityLabel)
			} else if labeled {
				Label(label, systemImage: systemImage)
					.labelStyle(.titleAndIcon)
					.accessibilityLabel(accessibilityLabel)
			} else {
				Label(label, systemImage: systemImage)
					.labelStyle(.iconOnly)
					.accessibilityLabel(accessibilityLabel)
			}
		}
	}
}

@MainActor
@ViewBuilder
func AddButton(_ noun: String, labeled: Bool = false, add: @escaping () -> Void) -> some View {
	ActionButton(
		labeled ? noun : "Add \(noun)",
		labeled: labeled,
		accessibilityLabel: "Add \(noun)",
		systemImage: "plus.circle",
		action: add)
}

@MainActor
@ViewBuilder
func DismissButton(dismiss: @escaping () -> Void) -> some View {
	ActionButton("Dismiss", systemImage: "checkmark.circle", action: dismiss)
}

@MainActor
@ViewBuilder
func CancelButton(canceling: @escaping () -> Void) -> some View {
	ActionButton("Cancel", systemImage: "x.circle", action: canceling)
}

@MainActor
@ViewBuilder
func EditButton(_ noun: String, edit: @escaping () -> Void) -> some View {
	ActionButton("Edit \(noun)", systemImage: "pencil", action: edit)
}

import Cocoa

@MainActor
final class ColorPanel: NSColorPanel, NSWindowDelegate {
	override var canBecomeMain: Bool { true }
	override var canBecomeKey: Bool { true }

	override func makeKeyAndOrderFront(_ sender: Any?) {
		hideNativePickerButton()

		super.makeKeyAndOrderFront(sender)

		if Defaults[.showColorSamplerOnOpen] {
			ColorWindowState.shared.pickColor()
		}

		// Prevent the first tab from showing focus ring.
		DispatchQueue.main.async {
			DispatchQueue.main.async { [self] in
				makeFirstResponder(nil)
			}
		}
	}

	private func hideNativePickerButton() {
		let selectorString = String(":yfingam_".reversed())
		let selector = NSSelectorFromString(selectorString)

		let pickerButton = contentView?
			.firstSubview(deep: true) { ($0 as? NSButton)?.action == selector } as? NSButton

		assert(pickerButton != nil)

		pickerButton?.isHidden = true
	}
}

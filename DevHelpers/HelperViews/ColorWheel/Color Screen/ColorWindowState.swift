import SwiftUI

@MainActor
final class ColorWindowState: ObservableObject {
	static let shared = ColorWindowState()
    private init() {}

	var cancellables = Set<AnyCancellable>()

	private(set) lazy var colorPanel: ColorPanel = {
        
		let colorPanel = createPanel()

		let view = ColorPickerScreen(colorPanel: colorPanel)
			.environmentObject(self)
		let accessoryView = NSHostingView(rootView: view)
		colorPanel.accessoryView = accessoryView
		accessoryView.constrainEdgesToSuperview()

		// This has to be after adding the accessory view to get correct size.
		colorPanel.setFrameUsingName(SSApp.name)
		colorPanel.setFrameAutosaveName(SSApp.name)

		colorPanel.orderOut(nil)

		return colorPanel
	}()

    private func createPanel() -> ColorPanel {
        let colorPanel = ColorPanel()
        colorPanel.titleVisibility = .hidden
        colorPanel.hidesOnDeactivate = false
        colorPanel.becomesKeyOnlyIfNeeded = false
        colorPanel.isFloatingPanel = false
        colorPanel.isRestorable = false
        colorPanel.styleMask.remove(.utilityWindow)
        colorPanel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        colorPanel.standardWindowButton(.zoomButton)?.isHidden = true
        colorPanel.tabbingMode = .disallowed
        colorPanel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
        colorPanel.makeMain()
        
        return colorPanel
    }

    // Main entry point - brings the color picker to the front and displays it.
	func openColorPicker() {
		DispatchQueue.main.async { [self] in
            setUpEvents()

            colorPanel.makeKeyAndOrderFront(nil)
		}
	}

	private func addToRecentlyPickedColor(_ color: NSColor) {
		Defaults[.recentlyPickedColors] = Defaults[.recentlyPickedColors]
			.removingAll(color)
			.appending(color)
			.truncatingFromStart(toCount: 6)
	}

	func pickColor() {
		Task {
			guard let color = await NSColorSampler().sample() else {
				return
			}

			colorPanel.color = color
			addToRecentlyPickedColor(color)

			if Defaults[.copyColorAfterPicking] {
				color.stringRepresentation.copyToPasteboard()
			}
		}
	}

	func pasteColor() {
		guard let color = NSColor.fromPasteboardGraceful(.general) else {
			return
		}

		colorPanel.color = color.usingColorSpace(.sRGB) ?? color
	}
}

extension ColorWindowState {
    func setUpEvents() {
        Defaults.publisher(.stayOnTop)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.colorPanel.level = $0.newValue ? .floating : .normal
            }
            .store(in: &cancellables)
    }
}

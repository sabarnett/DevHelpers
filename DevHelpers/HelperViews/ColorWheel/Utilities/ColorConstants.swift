import Cocoa

enum ColorFormat: String, CaseIterable, Defaults.Serializable {
	case hex
	case hsl
	case rgb
	case lch

	var title: String {
		switch self {
		case .hex:
			return "Hex"
		case .hsl:
			return "HSL"
		case .rgb:
			return "RGB"
		case .lch:
			return "LCH"
		}
	}
}

extension ColorFormat: Identifiable {
	var id: Self { self }
}

enum MenuBarItemClickAction: String, CaseIterable, Defaults.Serializable {
	case showMenu
	case showColorSampler
	case toggleWindow

	var title: String {
		switch self {
		case .showMenu:
			return "Show menu"
		case .showColorSampler:
			return "Show color sampler"
		case .toggleWindow:
			return "Toggle window"
		}
	}

	var tip: String {
		switch self {
		case .showMenu:
			return "Right-click to show the color sampler"
		case .showColorSampler, .toggleWindow:
			return "Right-click to show the menu"
		}
	}
}

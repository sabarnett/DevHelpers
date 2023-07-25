import SwiftUI
import LaunchAtLogin

struct SettingsScreen: View {
	var body: some View {
		TabView {
			GeneralSettings()
				.settingsTabItem(.general)
            LoremIpsumSettings()
                .settingsTabItem("Lorem", systemImage: "drop.fill")
            ColorSettings()
                .settingsTabItem("Color", systemImage: "drop.fill")
			AdvancedSettings()
				.settingsTabItem(.advanced)
		}
			.formStyle(.grouped)
			.frame(width: 460)
			.frame(maxHeight: 480)
			.fixedSize()
			.windowLevel(.floating + 1) // Ensure it's always above the color picker.
	}
}

private struct GeneralSettings: View {
	var body: some View {
		Form {
			Section {
                LaunchAtLogin.Toggle()
                    .help("There is really no point in launching the app at login if it is not in the menu bar. You can instead just put it in the Dock and launch it when needed.")
                
				Defaults.Toggle("Stay on top", key: .stayOnTop)
					.help("Make the color picker window stay on top of all other windows.")
			}
		}
	}
}

private struct ColorSettings: View {
	var body: some View {
		Form {
			Section {
				PreferredColorFormatSetting()
				ShownColorFormatsSetting()
			}
			Section {
                
                Defaults.Toggle("Copy color in preferred format after picking", key: .copyColorAfterPicking)

				Defaults.Toggle("Uppercase Hex color", key: .uppercaseHexColor)
				Defaults.Toggle("Prefix Hex color with #", key: .hashPrefixInHexColor)
				Defaults.Toggle("Use legacy syntax for HSL and RGB", key: .legacyColorSyntax)
					.help("Use the legacy “hsl(198, 28%, 50%)” syntax instead of the modern “hsl(198deg 28% 50%)” syntax. This setting is meant for users that need to support older browsers. All modern browsers support the modern syntax.")
			}
		}
	}
}

private struct LoremIpsumSettings: View {
    var body: some View {
        Form {
            Defaults.Toggle("Classic first line", key: .useClassicFirstLine)
            Defaults.Toggle("Add Quotes", key: .addQuotes)
                .help("Adding quotes will make it easier to paste the text into code.")
            Defaults.Toggle("Double Space", key: .doubleSpace)
                .help("Adds a newline between each sentence or paragraph for readability.")
        }
    }
}

private struct AdvancedSettings: View {
    var body: some View {
        Form {
            Defaults.Toggle("Show color sampler when opening window", key: .showColorSamplerOnOpen)
                .help("Show the color picker loupe when the color picker window is shown.")
            Defaults.Toggle("Use larger text in text fields", key: .largerText)
            Defaults.Toggle("Show accessibility color name", key: .showAccessibilityColorName)
        }
    }
}

private struct MenuBarItemClickActionSetting: View {
	@Default(.menuBarItemClickAction) private var menuBarItemClickAction

	var body: some View {
		EnumPicker(selection: $menuBarItemClickAction) {
			Text($0.title)
		} label: {
			Text("When clicking menu bar icon")
			Text(menuBarItemClickAction.tip)
		}
	}
}

private struct PreferredColorFormatSetting: View {
	@Default(.preferredColorFormat) private var preferredColorFormat

	var body: some View {
		EnumPicker("Preferred color format", selection: $preferredColorFormat) {
			Text($0.title)
		}
	}
}

private struct ShownColorFormatsSetting: View {
	var body: some View {
		LabeledContent("Shown color formats") {
			Defaults.MultiCheckboxPicker(
				key: .shownColorFormats,
				data: ColorFormat.allCases
			) {
				Text($0.title)
			}
		}
			.help("Choose which color formats to show in the color picker window. Disabled formats will still show up in the “Color” menu.")
	}
}

struct SettingsScreen_Previews: PreviewProvider {
	static var previews: some View {
		SettingsScreen()
	}
}

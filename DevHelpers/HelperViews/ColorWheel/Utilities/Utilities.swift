import SwiftUI
import Combine
import Carbon
import Defaults

typealias Defaults = _Defaults
typealias Default = _Default
typealias AnyCancellable = Combine.AnyCancellable

/*
Non-reusable utilities
*/

@discardableResult
func with<T>(_ value: T, update: (inout T) throws -> Void) rethrows -> T {
	var copy = value
	try update(&copy)
	return copy
}

final class LocalEventMonitor: ObservableObject {
	private let events: NSEvent.EventTypeMask
	private let callback: ((NSEvent) -> NSEvent?)?
	private weak var monitor: AnyObject?

	// swiftlint:disable:next private_subject
	let objectWillChange = PassthroughSubject<NSEvent, Never>()

	init(
		events: NSEvent.EventTypeMask,
		callback: ((NSEvent) -> NSEvent?)? = nil
	) {
		self.events = events
		self.callback = callback
	}

	deinit {
		stop()
	}

	@discardableResult
	func start() -> Self {
		monitor = NSEvent.addLocalMonitorForEvents(matching: events) { [weak self] event in
			guard let self else {
				return event
			}

			objectWillChange.send(event)

			if let callback {
				return callback(event)
			}

			return event
		} as AnyObject

		return self
	}

	func stop() {
		guard let monitor else {
			return
		}

		NSEvent.removeMonitor(monitor)
	}
}

final class GlobalEventMonitor {
	private let events: NSEvent.EventTypeMask
	private let callback: (NSEvent) -> Void
	private weak var monitor: AnyObject?

	init(events: NSEvent.EventTypeMask, callback: @escaping (NSEvent) -> Void) {
		self.events = events
		self.callback = callback
	}

	deinit {
		stop()
	}

	@discardableResult
	func start() -> Self {
		monitor = NSEvent.addGlobalMonitorForEvents(matching: events, handler: callback) as AnyObject
		return self
	}

	func stop() {
		guard let monitor else {
			return
		}

		NSEvent.removeMonitor(monitor)
	}
}

extension NSColorPanel {
	// TODO: Make this an AsyncSequence.
	/**
	Publishes when the color in the color panel changes.
	*/
	var colorDidChangePublisher: AnyPublisher<Void, Never> {
		NotificationCenter.default
			.publisher(for: Self.colorDidChangeNotification, object: self)
			.map { _ in }
			.eraseToAnyPublisher()
	}
}

extension View {
	/**
	Make the view subscribe to the given notification.
	*/
	func onNotification(
		_ name: Notification.Name,
		object: AnyObject? = nil,
		perform action: @escaping (Notification) -> Void
	) -> some View {
		onReceive(NotificationCenter.default.publisher(for: name, object: object)) {
			action($0)
		}
	}
}


private var controlActionClosureProtocolAssociatedObjectKey: UInt8 = 0

protocol ControlActionClosureProtocol: NSObjectProtocol {
	var target: AnyObject? { get set }
	var action: Selector? { get set }
}

private final class ActionTrampoline: NSObject {
	fileprivate let action: (NSEvent) -> Void

	init(action: @escaping (NSEvent) -> Void) {
		self.action = action
	}

	@objc
	fileprivate func handleAction(_ sender: AnyObject) {
		action(NSApp.currentEvent!)
	}
}

extension ControlActionClosureProtocol {
	var onAction: ((NSEvent) -> Void)? {
		get {
			guard
				let trampoline = objc_getAssociatedObject(self, &controlActionClosureProtocolAssociatedObjectKey) as? ActionTrampoline
			else {
				return nil
			}

			return trampoline.action
		}
		set {
			guard let newValue else {
				objc_setAssociatedObject(self, &controlActionClosureProtocolAssociatedObjectKey, nil, .OBJC_ASSOCIATION_RETAIN)
				return
			}

			let trampoline = ActionTrampoline(action: newValue)
			target = trampoline
			action = #selector(ActionTrampoline.handleAction)
			objc_setAssociatedObject(self, &controlActionClosureProtocolAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
		}
	}
}

extension NSControl: ControlActionClosureProtocol {}
extension NSMenuItem: ControlActionClosureProtocol {}

extension NSWindow {
	func toggle() {
		if isVisible, isKeyWindow {
			performClose(nil)
		} else {
			if NSApp.activationPolicy() == .accessory {
				NSApp.activate(ignoringOtherApps: true)
			}

			makeKeyAndOrderFront(nil)
		}
	}
}

final class CallbackMenuItem: NSMenuItem {
	private static var validateCallback: ((NSMenuItem) -> Bool)?

	static func validate(_ callback: @escaping (NSMenuItem) -> Bool) {
		validateCallback = callback
	}

	private let callback: () -> Void

	init(
		_ title: String,
		key: String = "",
		keyModifiers: NSEvent.ModifierFlags? = nil,
		isEnabled: Bool = true,
		isHidden: Bool = false,
		action: @escaping () -> Void
	) {
		self.callback = action
		super.init(title: title, action: #selector(action(_:)), keyEquivalent: key)
		self.target = self
		self.isEnabled = isEnabled
		self.isHidden = isHidden

		if let keyModifiers {
			self.keyEquivalentModifierMask = keyModifiers
		}
	}

	@available(*, unavailable)
	required init(coder decoder: NSCoder) {
		fatalError() // swiftlint:disable:this fatal_error_message
	}

	@objc
	private func action(_ sender: NSMenuItem) {
		callback()
	}
}

extension CallbackMenuItem: NSMenuItemValidation {
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		Self.validateCallback?(menuItem) ?? true
	}
}


extension NSMenu {
	@discardableResult
	func addCallbackItem(
		_ title: String,
		key: String = "",
		keyModifiers: NSEvent.ModifierFlags? = nil,
		isEnabled: Bool = true,
		isChecked: Bool = false,
		isHidden: Bool = false,
		action: @escaping () -> Void
	) -> NSMenuItem {
		let menuItem = CallbackMenuItem(
			title,
			key: key,
			keyModifiers: keyModifiers,
			isEnabled: isEnabled,
			isHidden: isHidden,
			action: action
		)
		addItem(menuItem)
		return menuItem
	}

	/**
	- Note: It preserves the existing `.font` and other attributes, but makes the font smaller.
	*/
	@discardableResult
	func addHeader(_ title: NSAttributedString, hasSeparatorAbove: Bool = true) -> NSMenuItem {
		if hasSeparatorAbove {
			addSeparator()
		}

		let menuItem = NSMenuItem()
		menuItem.isEnabled = false
		menuItem.attributedTitle = title
		addItem(menuItem)
		return menuItem
	}

	@discardableResult
	func addHeader(_ title: String, hasSeparatorAbove: Bool = true) -> NSMenuItem {
		addHeader(title.toNSAttributedString, hasSeparatorAbove: hasSeparatorAbove)
	}

	func addSeparator() {
		addItem(.separator())
	}
}

private struct WindowAccessor: NSViewRepresentable {
	private final class WindowAccessorView: NSView {
		@Binding var windowBinding: NSWindow?

		init(binding: Binding<NSWindow?>) {
			self._windowBinding = binding
			super.init(frame: .zero)
		}

		override func viewDidMoveToWindow() {
			super.viewDidMoveToWindow()
			windowBinding = window
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError() // swiftlint:disable:this fatal_error_message
		}
	}

	@Binding var window: NSWindow?

	init(_ window: Binding<NSWindow?>) {
		self._window = window
	}

	func makeNSView(context: Context) -> NSView {
		WindowAccessorView(binding: $window)
	}

	func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
	/**
	Bind the native backing-window of a SwiftUI window to a property.
	*/
	func bindHostingWindow(_ window: Binding<NSWindow?>) -> some View {
		background(WindowAccessor(window))
	}
}

private struct WindowViewModifier: ViewModifier {
	@State private var window: NSWindow?

	let onWindow: (NSWindow?) -> Void

	func body(content: Content) -> some View {
		onWindow(window)

		return content
			.bindHostingWindow($window)
	}
}

extension View {
	/**
	Access the native backing-window of a SwiftUI window.
	*/
	func accessHostingWindow(_ onWindow: @escaping (NSWindow?) -> Void) -> some View {
		modifier(WindowViewModifier(onWindow: onWindow))
	}

	/**
	Set the window level of a SwiftUI window.
	*/
	func windowLevel(_ level: NSWindow.Level) -> some View {
		accessHostingWindow {
			$0?.level = level
		}
	}
}


extension NSView {
	/**
	Get a subview matching a condition.
	*/
	func firstSubview(deep: Bool = false, where matches: (NSView) -> Bool) -> NSView? {
		for subview in subviews {
			if matches(subview) {
				return subview
			}

			if deep, let match = subview.firstSubview(deep: deep, where: matches) {
				return match
			}
		}

		return nil
	}
}

enum SSPublishers {
	/**
	Publishes when the app becomes active/inactive.
	*/
	static var appIsActive: AnyPublisher<Bool, Never> {
		Publishers.Merge(
			NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
				.map { _ in true },
			NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)
				.map { _ in false }
		)
			.eraseToAnyPublisher()
	}
}


private struct AppearOnScreenView: NSViewControllerRepresentable {
	final class ViewController: NSViewController {
		var onViewDidAppear: (() -> Void)?
		var onViewDidDisappear: (() -> Void)?

		init() {
			super.init(nibName: nil, bundle: nil)
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("Not implemented")
		}

		override func loadView() {
			view = NSView()
		}

		override func viewDidAppear() {
			onViewDidAppear?()
		}

		override func viewDidDisappear() {
			onViewDidDisappear?()
		}
	}

	var onViewDidAppear: (() -> Void)?
	var onViewDidDisappear: (() -> Void)?

	func makeNSViewController(context: Context) -> ViewController {
		let viewController = ViewController()
		viewController.onViewDidAppear = onViewDidAppear
		viewController.onViewDidDisappear = onViewDidDisappear
		return viewController
	}

	func updateNSViewController(_ controller: ViewController, context: Context) {}
}

extension View {
	/**
	Called each time the view appears on screen.

	This is different from `.onAppear` which is only called when the view appears in the SwiftUI view hierarchy.
	*/
	func onAppearOnScreen(_ perform: @escaping () -> Void) -> some View {
		background(AppearOnScreenView(onViewDidAppear: perform))
	}

	/**
	Called each time the view disappears from screen.

	This is different from `.onDisappear` which is only called when the view disappears from the SwiftUI view hierarchy.
	*/
	func onDisappearFromScreen(_ perform: @escaping () -> Void) -> some View {
		background(AppearOnScreenView(onViewDidDisappear: perform))
	}
}



extension Binding where Value: CaseIterable & Equatable {
	/**
	```
	enum Priority: String, CaseIterable {
		case no
		case low
		case medium
		case high
	}

	// …

	Picker("Priority", selection: $priority.caseIndex) {
		ForEach(Priority.allCases.indices) { priorityIndex in
			Text(
				Priority.allCases[priorityIndex].rawValue.capitalized
			)
				.tag(priorityIndex)
		}
	}
	```
	*/
	var caseIndex: Binding<Value.AllCases.Index> {
		.init(
			get: { Value.allCases.firstIndex(of: wrappedValue)! },
			set: {
				wrappedValue = Value.allCases[$0]
			}
		)
	}
}


/**
Useful in SwiftUI:

```
ForEach(persons.indexed(), id: \.1.id) { index, person in
	// …
}
```
*/
struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
	typealias Index = Base.Index
	typealias Element = (index: Index, element: Base.Element)

	let base: Base
	var startIndex: Index { base.startIndex }
	var endIndex: Index { base.endIndex }

	func index(after index: Index) -> Index {
		base.index(after: index)
	}

	func index(before index: Index) -> Index {
		base.index(before: index)
	}

	func index(_ index: Index, offsetBy distance: Int) -> Index {
		base.index(index, offsetBy: distance)
	}

	subscript(position: Index) -> Element {
		(index: position, element: base[position])
	}
}

extension RandomAccessCollection {
	/**
	Returns a sequence with a tuple of both the index and the element.

	- Important: Use this instead of `.enumerated()`. See: https://khanlou.com/2017/03/you-probably-don%27t-want-enumerated/
	*/
	func indexed() -> IndexedCollection<Self> {
		IndexedCollection(base: self)
	}
}

enum SettingsTabType {
	case general
	case advanced
	case shortcuts

	fileprivate var label: some View {
		switch self {
		case .general:
			return Label("General", systemImage: "gearshape")
		case .advanced:
			return Label("Advanced", systemImage: "gearshape.2")
		case .shortcuts:
			return Label("Shortcuts", systemImage: "command")
		}
	}
}

extension View {
	/**
	Make the view a settings tab of the given type.
	*/
	func settingsTabItem(_ type: SettingsTabType) -> some View {
		tabItem { type.label }
	}

	func settingsTabItem(_ title: String, systemImage: String) -> some View {
		tabItem {
			Label(title, systemImage: systemImage)
		}
	}
}


/**
Store a value persistently in a `View` like with `@State`, but without updating the view on mutations.

You can use it for storing both value and reference types.
*/
@propertyWrapper
struct ViewStorage<Value>: DynamicProperty {
	private final class ValueBox: ObservableObject {
		let objectWillChange = Empty<Never, Never>(completeImmediately: false)
		var value: Value

		init(_ value: Value) {
			self.value = value
		}
	}

	@StateObject private var valueBox: ValueBox

	var wrappedValue: Value {
		get { valueBox.value }
		nonmutating set {
			valueBox.value = newValue
		}
	}

	init(wrappedValue value: @autoclosure @escaping () -> Value) {
		self._valueBox = StateObject(wrappedValue: .init(value()))
	}
}


extension Binding where Value: SetAlgebra, Value.Element: Hashable {
	/**
	Creates a `Bool` derived binding that reflects whether the original binding value contains the given element.

	For example, you can use this to create a list of checkboxes, and when a checkbox is unchecked, the element is removed from the `Set` and if checked, it's added back.

	```
	struct ContentView: View {
		@State private var foo = Set<String>(["unicorn", "rainbow"])

		var body: some View {
			Toggle(
				"Contains `unicorn`",
				isOn: $foo.contains("unicorn")
			)
		}
	}
	```
	*/
	func contains(_ element: Value.Element) -> Binding<Bool> {
		.init(
			get: { wrappedValue.contains(element) },
			set: {
				if $0 {
					wrappedValue.insert(element)
				} else {
					wrappedValue.remove(element)
				}
			}
		)
	}
}

/**
A picker that supports multiple selections and renders as multiple checkboxes.

```
struct ContentView: View {
	private var data = [DayOfWeek]()
	@State private var selection = Set<DayOfWeek>()

	var body: some View {
		Defaults.MultiCheckboxPicker(
			data: DayOfWeek.days,
			selection: $selection
		) {
			Text($0.name)
		}
	}
}
```

It intentionally does not support a `label` parameter as we cannot read `.labelsHidden()`, so we cannot respect that.
*/
struct MultiCheckboxPicker<Data: RandomAccessCollection, ElementLabel: View>: View where Data.Element: Hashable & Identifiable {
	let data: Data
	@Binding var selection: Set<Data.Element>
	@ViewBuilder var elementLabel: (Data.Element) -> ElementLabel

	var body: some View {
		ForEach(data) { element in
			Toggle(isOn: $selection.contains(element)) {
				elementLabel(element)
			}
		}
	}
}

typealias _OriginalMultiCheckboxPicker = MultiCheckboxPicker

#if !APP_EXTENSION
extension Defaults {
	/**
	A picker that supports multiple selections and renders as multiple checkboxes.

	```
	struct ContentView: View {
		var body: some View {
			Defaults.MultiCheckboxPicker(
				key: .highlightedDaysInCalendar,
				data: DayOfWeek.days(for: calendar)
			) {
				Text($0.name(for: calendar))
			}
		}
	}
	```
	*/
	struct MultiCheckboxPicker<Data: RandomAccessCollection, ElementLabel: View>: View where Data.Element: Hashable & Identifiable & Defaults.Serializable {
		typealias Element = Data.Element
		typealias Selection = Set<Element>

		@ViewStorage private var onChange: ((Selection) -> Void)?
		private let data: Data
		@Default private var selection: Selection
		private var elementLabel: (Element) -> ElementLabel

		init(
			key: Defaults.Key<Set<Data.Element>>,
			data: Data,
			@ViewBuilder elementLabel: @escaping (Element) -> ElementLabel
		) {
			self.data = data
			self._selection = .init(key)
			self.elementLabel = elementLabel
		}

		var body: some View {
			_OriginalMultiCheckboxPicker(
				data: data,
				selection: $selection
			) {
				elementLabel($0)
			}
				.onChange(of: selection) {
					onChange?($0)
				}
		}
	}
}

extension Defaults.MultiCheckboxPicker {
	/**
	Do something when the value changes to a different value.
	*/
	func onChange(_ action: @escaping (Selection) -> Void) -> Self {
		onChange = action
		return self
	}
}
#endif


extension NSImage {
	/**
	Draw a color as an image.
	*/
	static func color(
		_ color: NSColor,
		size: CGSize,
		borderWidth: Double = 0,
		borderColor: NSColor? = nil,
		cornerRadius: Double? = nil
	) -> Self {
		Self(size: size, flipped: false) { bounds in
			NSGraphicsContext.current?.imageInterpolation = .high

			guard let cornerRadius else {
				color.drawSwatch(in: bounds)
				return true
			}

			let targetRect = bounds.insetBy(
				dx: borderWidth,
				dy: borderWidth
			)

			let bezierPath = NSBezierPath(
				roundedRect: targetRect,
				xRadius: cornerRadius,
				yRadius: cornerRadius
			)

			color.set()
			bezierPath.fill()

			if
				borderWidth > 0,
				let borderColor
			{
				borderColor.setStroke()
				bezierPath.lineWidth = borderWidth
				bezierPath.stroke()
			}

			return true
		}
	}
}

extension Sequence where Element: Equatable {
	/**
	Returns a new sequence without the elements in the sequence that equals the given element.

	```
	[1, 2, 1, 2].removingAll(2)
	//=> [1, 1]
	```
	*/
	func removingAll(_ element: Element) -> [Element] {
		filter { $0 != element }
	}
}


extension Collection {
	func appending(_ newElement: Element) -> [Element] {
		self + [newElement]
	}
}


extension Collection {
	/**
	Truncate a collection to a certain count by removing elements from the end.
	*/
	func truncatingFromStart(toCount newCount: Int) -> [Element] {
		let removeCount = count - newCount

		guard removeCount > 0 else {
			return Array(self)
		}

		return Array(dropFirst(removeCount))
	}
}

extension Collection {
	var nilIfEmpty: Self? { isEmpty ? nil : self }
}

extension Shape where Self == Rectangle {
	static var rectangle: Self { .init() }
}

extension Shape where Self == Circle {
	static var circle: Self { .init() }
}

extension Shape where Self == Capsule {
	static var capsule: Self { .init() }
}

extension Shape where Self == Ellipse {
	static var ellipse: Self { .init() }
}

extension Shape where Self == ContainerRelativeShape {
	static var containerRelative: Self { .init() }
}

extension Shape where Self == RoundedRectangle {
	static func roundedRectangle(cornerRadius: Double, style: RoundedCornerStyle = .circular) -> Self {
		.init(cornerRadius: cornerRadius, style: style)
	}

	static func roundedRectangle(cornerSize: CGSize, style: RoundedCornerStyle = .circular) -> Self {
		.init(cornerSize: cornerSize, style: style)
	}
}


extension NSStatusItem {
	/**
	Show a one-time menu from the status item.
	*/
	func showMenu(_ menu: NSMenu) {
		self.menu = menu
		button!.performClick(nil)
		self.menu = nil
	}
}


extension NSEvent {
	static var modifiers: ModifierFlags {
		modifierFlags
			.intersection(.deviceIndependentFlagsMask)
			// We remove `capsLock` as it shouldn't affect the modifiers.
			// We remove `numericPad`/`function` as arrow keys trigger it, use `event.specialKeys` instead.
			.subtracting([.capsLock, .numericPad, .function])
	}

	/**
	Real modifiers.

	- Note: Prefer this over `.modifierFlags`.

	```
	// Check if Command is one of possible more modifiers keys
	event.modifiers.contains(.command)

	// Check if Command is the only modifier key
	event.modifiers == .command

	// Check if Command and Shift are the only modifiers
	event.modifiers == [.command, .shift]
	```
	*/
	var modifiers: ModifierFlags {
		modifierFlags
			.intersection(.deviceIndependentFlagsMask)
			// We remove `capsLock` as it shouldn't affect the modifiers.
			// We remove `numericPad`/`function` as arrow keys trigger it, use `event.specialKeys` instead.
			.subtracting([.capsLock, .numericPad, .function])
	}
}


extension NSEvent {
	var isAlternativeMouseUp: Bool {
		type == .rightMouseUp
			|| (type == .leftMouseUp && modifiers == .control)
	}

	var isAlternativeClickForStatusItem: Bool {
		isAlternativeMouseUp
			|| (type == .leftMouseUp && modifiers == .option)
	}
}


extension NSError {
	static func appError(
		_ description: String,
		recoverySuggestion: String? = nil,
		userInfo: [String: Any] = [:],
		domainPostfix: String? = nil
	) -> Self {
		var userInfo = userInfo
		userInfo[NSLocalizedDescriptionKey] = description

		if let recoverySuggestion {
			userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
		}

		return .init(
			domain: domainPostfix.map { "\(SSApp.idString) - \($0)" } ?? SSApp.idString,
			code: 1, // This is what Swift errors end up as.
			userInfo: userInfo
		)
	}
}

extension Button<Label<Text, Image>> {
	init(
		_ title: String,
		systemImage: String,
		role: ButtonRole? = nil,
		action: @escaping () -> Void
	) {
		self.init(
			role: role,
			action: action
		) {
			Label(title, systemImage: systemImage)
		}
	}
}

//
//  ViewController.swift
//  Combinable
//
//  Created by Leo on 2026/10/30.
//

import Combine
import UIKit

final class ViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let offsetLabel = ViewController.makeStatusLabel("contentOffset y: 0")
    private let bottomLabel = ViewController.makeStatusLabel("reachedBottomPublisher: waiting")

    private var tapCount = 0
    private var gestureTapCount = 0
    private var panBaseX: CGFloat = 0
    private var panBaseY: CGFloat = 0
    private var panCenterX: NSLayoutConstraint?
    private var panCenterY: NSLayoutConstraint?

    private let transformTarget = UIView()
    private var baseScale: CGFloat = 1
    private var baseRotation: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Combinable"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .always
        setupScrollView()
        stackView.addArrangedSubview(makeIntro())
        stackView.addArrangedSubview(makeButtonCard())
        stackView.addArrangedSubview(makeTextFieldCard())
        stackView.addArrangedSubview(makeTextViewCard())
        stackView.addArrangedSubview(makePropertyCard())
        stackView.addArrangedSubview(makeGestureCard())
        stackView.addArrangedSubview(makeScrollCard())
        bindScroll()
        bindKeyboard()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    private func makeIntro() -> UILabel {
        let label = UILabel()
        label.text = "Each card subscribes with cb and keeps the cancellable alive through store(in:)."
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    private func makeButtonCard() -> UIView {
        let status = Self.makeStatusLabel("controlEventPublisher: 0")
        var config = UIButton.Configuration.filled()
        config.title = "Tap"
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)

        button.cb.controlEventPublisher(for: .touchUpInside)
            .sink { [weak self] in
                guard let self else { return }
                self.tapCount += 1
                status.text = "controlEventPublisher: \(self.tapCount)"
            }
            .cb.store(in: self)

        return makeCard(
            title: "UIControl",
            caption: "controlEventPublisher(for: .touchUpInside)",
            content: [button, status]
        )
    }

    private func makeTextFieldCard() -> UIView {
        let textStatus = Self.makeStatusLabel("text: ∅")
        let attributedStatus = Self.makeStatusLabel("attributedText: ∅")

        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Type, or set text from code"
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.font = .preferredFont(forTextStyle: .body)

        var fillConfig = UIButton.Configuration.tinted()
        fillConfig.title = "Set text"
        fillConfig.cornerStyle = .medium
        let fillButton = UIButton(configuration: fillConfig)

        textField.cb.textPublisher
            .sink { text in
                textStatus.text = "text: \(Self.display(text))"
            }
            .cb.store(in: self)

        textField.cb.attributedTextPublisher
            .sink { attributed in
                attributedStatus.text = "attributedText: \(Self.display(attributed?.string))"
            }
            .cb.store(in: self)

        textField.cb.controlEventPublisher(for: .editingDidEndOnExit)
            .sink { [weak textField] in
                textField?.resignFirstResponder()
            }
            .cb.store(in: self)

        fillButton.cb.controlEventPublisher(for: .touchUpInside)
            .sink { [weak textField] in
                textField?.text = "Set from code"
            }
            .cb.store(in: self)

        return makeCard(
            title: "UITextField",
            caption: "textPublisher and attributedTextPublisher. Editing and programmatic updates both emit.",
            content: [textField, fillButton, textStatus, attributedStatus]
        )
    }

    private func makeTextViewCard() -> UIView {
        let status = Self.makeStatusLabel("textPublisher: 0 characters")
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = .tertiarySystemGroupedBackground
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88).isActive = true

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak textView] _ in
                textView?.resignFirstResponder()
            })
        ]
        textView.inputAccessoryView = toolbar

        textView.cb.textPublisher
            .sink { text in
                let count = text?.count ?? 0
                status.text = "textPublisher: \(count) characters"
            }
            .cb.store(in: self)

        return makeCard(
            title: "UITextView",
            caption: "textPublisher",
            content: [textView, status]
        )
    }

    private func makePropertyCard() -> UIView {
        let sliderStatus = Self.makeStatusLabel("value: —")
        let switchStatus = Self.makeStatusLabel("isOn: —")

        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 40

        let toggle = UISwitch()
        let switchRow = UIStackView(arrangedSubviews: [switchStatus, toggle])
        switchRow.axis = .horizontal
        switchRow.alignment = .center
        switchStatus.setContentHuggingPriority(.defaultLow, for: .horizontal)

        UIControlPropertyPublisher(control: slider, events: .valueChanged, keyPath: \.value)
            .sink { value in
                sliderStatus.text = String(format: "value: %.0f", value)
            }
            .cb.store(in: self)

        UIControlPropertyPublisher(control: toggle, events: .valueChanged, keyPath: \.isOn)
            .sink { isOn in
                switchStatus.text = "isOn: \(isOn)"
            }
            .cb.store(in: self)

        return makeCard(
            title: "UIControlPropertyPublisher",
            caption: "Reads a key path when the control event fires, and sends the current value on subscribe.",
            content: [slider, sliderStatus, switchRow]
        )
    }

    private func makeGestureCard() -> UIView {
        let tapStatus = Self.makeStatusLabel("tapPublisher: 0")
        let longPressStatus = Self.makeStatusLabel("longPressPublisher: —")
        let panStatus = Self.makeStatusLabel("panPublisher: —")
        let transformStatus = Self.makeStatusLabel("pinch / rotation: —")
        let swipeStatus = Self.makeStatusLabel("swipe: —")

        let tapPad = makePad(title: "Tap or long-press", color: .systemBlue)
        tapPad.cb.tapPublisher
            .filter { $0.state == .ended }
            .sink { [weak self] _ in
                guard let self else { return }
                self.gestureTapCount += 1
                tapStatus.text = "tapPublisher: \(self.gestureTapCount)"
            }
            .cb.store(in: self)

        tapPad.cb.longPressPublisher
            .sink { gesture in
                longPressStatus.text = "longPressPublisher: \(Self.stateName(gesture.state))"
            }
            .cb.store(in: self)

        let panPad = makePanPad()
        panPad.chip.cb.panPublisher
            .sink { [weak self] gesture in
                guard let self else { return }
                self.moveChip(with: gesture, in: panPad.container)
                if gesture.state == .changed || gesture.state == .ended {
                    let point = gesture.location(in: panPad.container)
                    panStatus.text = String(format: "panPublisher: (%.0f, %.0f)", point.x, point.y)
                }
            }
            .cb.store(in: self)

        let transformPad = configureTransformTarget()
        transformTarget.cb.pinchPublisher
            .sink { [weak self] gesture in
                self?.applyPinch(gesture)
                transformStatus.text = String(format: "pinchPublisher: %.2f", gesture.scale)
            }
            .cb.store(in: self)

        transformTarget.cb.rotationPublisher
            .sink { [weak self] gesture in
                self?.applyRotation(gesture)
                transformStatus.text = String(format: "rotationPublisher: %.2f rad", gesture.rotation)
            }
            .cb.store(in: self)

        let swipePad = makePad(title: "Swipe left or right", color: .systemTeal)
        swipePad.cb.swipePublisher
            .filter { $0.state == .ended }
            .sink { _ in
                swipeStatus.text = "swipePublisher: right"
            }
            .cb.store(in: self)

        swipePad.cb.gesturePublisher(for: UISwipeGestureRecognizer.self) { gesture in
            gesture.direction = .left
        }
        .filter { $0.state == .ended }
        .sink { _ in
            swipeStatus.text = "gesturePublisher: left"
        }
        .cb.store(in: self)

        return makeCard(
            title: "UIView gestures",
            caption: "tapPublisher, longPressPublisher, panPublisher, pinchPublisher, rotationPublisher, swipePublisher, gesturePublisher(for:configure:).",
            content: [
                tapPad,
                tapStatus,
                longPressStatus,
                panPad.container,
                panStatus,
                transformPad,
                transformStatus,
                swipePad,
                swipeStatus
            ]
        )
    }

    private func makeScrollCard() -> UIView {
        makeCard(
            title: "UIScrollView",
            caption: "contentOffsetPublisher and reachedBottomPublisher follow this page. Scroll to the end.",
            content: [offsetLabel, bottomLabel]
        )
    }

    private func bindScroll() {
        scrollView.cb.contentOffsetPublisher
            .sink { [weak self] offset in
                self?.offsetLabel.text = String(format: "contentOffset y: %.0f", offset.y)
            }
            .cb.store(in: self)

        scrollView.cb.reachedBottomPublisher()
            .sink { [weak self] in
                guard let self else { return }
                self.bottomLabel.text = "reachedBottomPublisher: fired"
                self.bottomLabel.textColor = .systemGreen
            }
            .cb.store(in: self)
    }

    private func bindKeyboard() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .sink { [weak self] note in
                guard
                    let self,
                    let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                else { return }
                let converted = self.view.convert(frame, from: nil)
                let overlap = max(0, self.view.bounds.maxY - converted.minY)
                self.scrollView.contentInset.bottom = overlap
                self.scrollView.verticalScrollIndicatorInsets.bottom = overlap
            }
            .cb.store(in: self)
    }

    private func makePanPad() -> (container: UIView, chip: UIView) {
        let container = UIView()
        container.backgroundColor = .tertiarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 140).isActive = true

        let chip = UIView()
        chip.backgroundColor = .systemOrange
        chip.layer.cornerRadius = 12
        chip.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Drag"
        title.textColor = .white
        title.font = .preferredFont(forTextStyle: .headline)
        title.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(title)
        container.addSubview(chip)

        let centerX = chip.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        let centerY = chip.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        NSLayoutConstraint.activate([
            chip.widthAnchor.constraint(equalToConstant: 72),
            chip.heightAnchor.constraint(equalToConstant: 72),
            centerX,
            centerY,
            title.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: chip.centerYAnchor)
        ])
        panCenterX = centerX
        panCenterY = centerY
        return (container, chip)
    }

    private func moveChip(with gesture: UIPanGestureRecognizer, in container: UIView) {
        guard let centerX = panCenterX, let centerY = panCenterY else { return }
        switch gesture.state {
        case .began:
            panBaseX = centerX.constant
            panBaseY = centerY.constant
        case .changed:
            let translation = gesture.translation(in: container)
            let halfWidth = max(0, (container.bounds.width - 72) / 2)
            let halfHeight = max(0, (container.bounds.height - 72) / 2)
            centerX.constant = min(max(panBaseX + translation.x, -halfWidth), halfWidth)
            centerY.constant = min(max(panBaseY + translation.y, -halfHeight), halfHeight)
        default:
            break
        }
    }

    private func configureTransformTarget() -> UIView {
        let holder = UIView()
        holder.translatesAutoresizingMaskIntoConstraints = false
        holder.heightAnchor.constraint(equalToConstant: 168).isActive = true

        transformTarget.backgroundColor = .systemPurple.withAlphaComponent(0.85)
        transformTarget.layer.cornerRadius = 12
        transformTarget.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Pinch or rotate"
        title.textColor = .white
        title.font = .preferredFont(forTextStyle: .headline)
        title.translatesAutoresizingMaskIntoConstraints = false
        transformTarget.addSubview(title)
        holder.addSubview(transformTarget)
        NSLayoutConstraint.activate([
            transformTarget.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
            transformTarget.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
            transformTarget.widthAnchor.constraint(equalToConstant: 180),
            transformTarget.heightAnchor.constraint(equalToConstant: 120),
            title.centerXAnchor.constraint(equalTo: transformTarget.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: transformTarget.centerYAnchor)
        ])
        return holder
    }

    private func applyPinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let scale = min(max(baseScale * gesture.scale, 0.6), 2.4)
            transformTarget.transform = CGAffineTransform(rotationAngle: baseRotation).scaledBy(x: scale, y: scale)
        case .ended, .cancelled:
            baseScale = min(max(baseScale * gesture.scale, 0.6), 2.4)
        default:
            break
        }
    }

    private func applyRotation(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let rotation = baseRotation + gesture.rotation
            transformTarget.transform = CGAffineTransform(rotationAngle: rotation).scaledBy(x: baseScale, y: baseScale)
        case .ended, .cancelled:
            baseRotation += gesture.rotation
        default:
            break
        }
    }

    private func makePad(title: String, color: UIColor) -> UIView {
        let pad = UIView()
        pad.backgroundColor = color.withAlphaComponent(0.18)
        pad.layer.cornerRadius = 12
        pad.translatesAutoresizingMaskIntoConstraints = false
        pad.heightAnchor.constraint(equalToConstant: 72).isActive = true

        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        pad.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: pad.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: pad.centerYAnchor)
        ])
        return pad
    }

    private func makeCard(title: String, caption: String, content: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .preferredFont(forTextStyle: .footnote)
        captionLabel.textColor = .secondaryLabel
        captionLabel.numberOfLines = 0

        let inner = UIStackView(arrangedSubviews: [titleLabel, captionLabel] + content)
        inner.axis = .vertical
        inner.spacing = 8
        inner.setCustomSpacing(4, after: titleLabel)
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private static func makeStatusLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    private static func display(_ text: String?) -> String {
        guard let text, !text.isEmpty else { return "∅" }
        return text
    }

    private static func stateName(_ state: UIGestureRecognizer.State) -> String {
        switch state {
        case .possible: return "possible"
        case .began: return "began"
        case .changed: return "changed"
        case .ended: return "ended"
        case .cancelled: return "cancelled"
        case .failed: return "failed"
        @unknown default: return "unknown"
        }
    }
}

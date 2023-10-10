//
//  PlaceholderTextView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import UIKit

class PlaceholderTextView: UITextView {
    // MARK: Lifecycle

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setPlaceholder()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Open

    open override var bounds: CGRect {
        didSet {
            resizePlaceholder()
        }
    }

    // MARK: Internal

    enum PlaceholderAlignment {
        case top
        case center
        case bottom
    }

    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        return label
    }()

    var placeholderAlignment: PlaceholderAlignment = .top

    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }

    override var text: String! {
        didSet {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }

    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.sizeToFit()
        }
    }

    // MARK: Private

    private func setPlaceholder() {
        addSubview(placeholderLabel)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }

    private func resizePlaceholder() {
        let labelX = textContainer.lineFragmentPadding
        let labelWidth = frame.width - (labelX * 2)
        let labelHeight = placeholderLabel.frame.height
        var labelY: CGFloat = 0
        switch placeholderAlignment {
        case .top:
            labelY = textContainerInset.top
        case .center:
            labelY = (frame.height - labelHeight) / 2
        case .bottom:
            labelY = frame.height - labelHeight
        }
        placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
    }

    @objc
    private func textDidChange(_ notification: Notification) {
        placeholderLabel.isHidden = !text.isEmpty
    }
}

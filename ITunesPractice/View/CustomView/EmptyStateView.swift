//
//  EmptyStateView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import SnapKit
import UIKit

class EmptyStateView: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }

    // MARK: Private

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .lightText
        label.numberOfLines = 0
        return label
    }()

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension EmptyStateView {
    func updateUI(title: String, message: String, animated: Bool, duration: TimeInterval = 0.5) {
        updateText(titleLabel, text: title, animated: animated, duration: duration)
        updateText(messageLabel, text: message, animated: animated, duration: duration)
    }

    private func updateText(_ label: UILabel, text: String, animated: Bool = true, duration: TimeInterval) {
        if !animated {
            label.text = text
            return
        }
        UIView.transition(with: label, duration: duration, options: [.transitionCrossDissolve], animations: {
            label.text = text // 更新 label 的文字
        }, completion: nil)
    }
}

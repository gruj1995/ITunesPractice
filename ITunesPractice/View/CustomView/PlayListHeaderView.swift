//
//  PlayListHeaderView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/19.
//

import SnapKit
import UIKit

final class PlayListHeaderView: UIView {
    // MARK: Lifecycle

    // initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    // MARK: Internal

    func configure(title: String) {
        titleLabel.text = title
    }

    // MARK: Private

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitle("清除".localizedString(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    private lazy var shuffleButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(AppImages.shuffle, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    private lazy var repeatButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(AppImages.repeat0, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    private lazy var infinityButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(AppImages.infinity, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    func updateButtons() {
//        [shuffleButton, repeatButton, infinityButton].forEach { button in
//
//        }
    }

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [shuffleButton, repeatButton, infinityButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        infinityButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
    }
}

//
//  PlayListHeaderView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/19.
//

import SnapKit
import UIKit

// MARK: - PlayListHeaderView

final class PlayListHeaderView: UITableViewHeaderFooterView {
    // MARK: Lifecycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    // initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    var onShuffleButtonTapped: ((UIButton) -> Void)?
    var onInfinityButtonTapped: ((UIButton) -> Void)?
    var onRepeatButtonTapped: ((UIButton) -> Void)?
    var onClearButtonTapped: ((UIButton) -> Void)?

    lazy var shuffleButton: UIButton = UIButton.createRoundCornerButton(image: AppImages.shuffle, target: self, action: #selector(shuffleButtonTapped))

    lazy var repeatButton: UIButton = UIButton.createRoundCornerButton(image: AppImages.repeat0, target: self, action: #selector(repeatButtonTapped))

    lazy var infinityButton: UIButton = UIButton.createRoundCornerButton(image: AppImages.infinity, target: self, action: #selector(infinityButtonTapped))

    func configure(title: String, subTitle: String?, type: TracksType) {
        titleLabel.text = title

        if let subTitle {
            subTitleLabel.text = subTitle
            UIView.animate(withDuration: 0.3) {
                self.subTitleLabel.isHidden = false
            }
        } else {
            subTitleLabel.isHidden = true
        }

        if type == .history {
            buttonsStackView.arrangedSubviews.forEach { $0.isHidden = ($0 != clearButton)}
        } else if type == .playlist {
            buttonsStackView.arrangedSubviews.forEach { $0.isHidden = ($0 == clearButton)}
        }
    }

    // MARK: Private

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitle("清除".localizedString(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [shuffleButton, repeatButton, infinityButton, clearButton])
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        return stackView
    }()

    private func setupUI() {
        backgroundView = UIView.emptyView() // 避免 highlight 效果
        setupLayout()
    }

    private func setupLayout() {
        addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.centerY.equalToSuperview()
        }

        addSubview(buttonsStackView)
        buttonsStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }

        shuffleButton.snp.makeConstraints { make in
            make.width.equalTo(shuffleButton.snp.height)
        }

        clearButton.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
    }

    @objc
    private func shuffleButtonTapped(_ sender: UIButton) {
        onShuffleButtonTapped?(sender)
    }

    @objc
    private func infinityButtonTapped(_ sender: UIButton) {
        onInfinityButtonTapped?(sender)
    }

    @objc
    private func repeatButtonTapped(_ sender: UIButton) {
        onRepeatButtonTapped?(sender)
    }

    @objc
    private func clearButtonTapped(_ sender: UIButton) {
        onClearButtonTapped?(sender)
    }
}

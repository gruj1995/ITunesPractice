//
//  PlayListHeaderView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/19.
//

import SnapKit
import UIKit

// MARK: - PlayListHeaderTitle

enum PlayListHeaderTitle {
    static let toBePlayed = "待播清單".localizedString()
    static let playRecord = "播放記錄".localizedString()
}

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

    lazy var shuffleButton: UIButton = UIButton.createButton(image: AppImages.shuffle, target: self, action: #selector(shuffleButtonTapped))

    lazy var repeatButton: UIButton = UIButton.createButton(image: AppImages.repeat0, target: self, action: #selector(repeatButtonTapped))

    lazy var infinityButton: UIButton = UIButton.createButton(image: AppImages.infinity, target: self, action: #selector(infinityButtonTapped))

    func configure(title: String, subTitle: String?) {
        titleLabel.text = title
        if let subTitle = subTitle {
            subTitleLabel.text = subTitle
        }

        let shouldHideSubTitle = subTitle == nil
        if !shouldHideSubTitle {
            UIView.animate(withDuration: 0.3) {
                self.subTitleLabel.isHidden = shouldHideSubTitle
            }
        } else {
            subTitleLabel.isHidden = shouldHideSubTitle
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
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [shuffleButton, repeatButton, infinityButton])
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
        backgroundColor = .clear
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
}

extension UIButton {
    func setButtonAppearance(isSelected: Bool, tintColor: UIColor?, image: UIImage? = nil) {
        if let image = image {
            setImage(image, for: .normal)
        }
        self.tintColor = isSelected ? tintColor : .white
        backgroundColor = isSelected ? .white : .clear
    }

    static func createButton(image: UIImage?, target: Any?, action: Selector) -> UIButton {
        let button = UIButton()
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setImage(image, for: .normal)
        return button
    }
}

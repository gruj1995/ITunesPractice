//
//  PlaylistInfoHeaderView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/21.
//

import SnapKit
import UIKit

// MARK: - PlaylistInfoHeaderView

class PlaylistInfoHeaderView: UITableViewHeaderFooterView {
    // MARK: Lifecycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    var onPlayButtonTapped: ((UIButton) -> Void)?

    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()

    func configure(name: String, imageUrl: URL?) {
        nameLabel.text = name
        coverImageView.loadImage(
            with: imageUrl,
            placeholder: AppImages.catMushroom
        )
    }

    // MARK: Private

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPlayButtonTapped), for: .touchUpInside)

        var config = UIButton.Configuration.filled()
        config.imagePadding = 10
        config.buttonSize = .small
        config.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        config.attributedTitle = AttributedString("播放", attributes: AttributeContainer([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .bold)]))
        config.titleAlignment = .center
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular, scale: .small)
        config.image = AppImages.play?.withConfiguration(imageConfig)
        config.baseBackgroundColor = .appColor(.gray6)
        config.baseForegroundColor = .appColor(.red1) // 圖片及文字顏色
        config.cornerStyle = .medium
        button.configuration = config
        return button
    }()

    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, playButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(coverImageView.snp.width)
        }

        addSubview(trackInfoStackView)
        trackInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }

        nameLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        playButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalToSuperview().multipliedBy(0.6)
        }
    }

    @objc
    private func didPlayButtonTapped(_ sender: UIButton) {
        onPlayButtonTapped?(sender)
    }
}

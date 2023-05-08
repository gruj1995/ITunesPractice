//
//  PlaylistCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import SnapKit
import UIKit

class PlaylistCell: UICollectionViewCell {
    // MARK: Lifecycle

    // 用程式 init(frame: )
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    // 用 storybeard 設置 custom class
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    func configure(_ playlist: Playlist) {
        coverImageView.loadImage(
            with: playlist.imageUrl,
            placeholder: AppImages.musicList?
                .withConfiguration(largeConfiguration)
                .withTintColor(.appColor(.red1) ?? .red, renderingMode: .alwaysOriginal)
        )
        nameLabel.text = playlist.name
        descriptionLabel.text = playlist.description
    }

    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor(.gray1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [bgView, nameLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        return stackView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .lightGray
        return label
    }()

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        bgView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        contentView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

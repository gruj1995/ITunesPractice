//
//  PlaylistCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

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
            placeholder: AppImages.catMushroom
        )
        nameLabel.text = playlist.name
        descriptionLabel.text = playlist.description
    }

    // MARK: Private

    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        return label
    }()

    private func setupUI() {
        backgroundColor = .black
        setupLayout()
    }

    private func setupLayout() {
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(coverImageView.snp.width)
        }

        contentView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(3)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
}

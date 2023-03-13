//
//  TrackCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/20.
//

import Kingfisher
import SnapKit
import UIKit

class TrackCell: UITableViewCell {
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        coverImageView.layoutIfNeeded()
    }

    func configure(artworkUrl: String, collectionName: String, artistName: String, trackName: String) {
        coverImageView.kf.setImage(with: URL(string: artworkUrl))
        trackNameLabel.text = trackName
        albumInfoLabel.text = "\(artistName) · \(collectionName)"
    }

    // MARK: Private

    /// 專輯封面圖示
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()

    private lazy var albumInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13)
        label.textColor = .lightText
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackNameLabel, albumInfoLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private func setupUI() {
        // 點擊時 cell highlight的顏色
        let backgroundView = UIView()
        backgroundView.backgroundColor = .appColor(.gray2)
        selectedBackgroundView = backgroundView
        backgroundColor = .black
        setupLayout()
    }

    private func setupLayout() {
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.top.bottom.equalToSuperview().inset(5)
            make.width.equalTo(coverImageView.snp.height)
        }

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView.snp.trailing).offset(15)
            make.trailing.equalTo(contentView.snp.trailingMargin)
            make.centerY.equalToSuperview()
        }
    }
}

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
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    /// 專輯封面圖示
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()

    lazy var albumInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13)
        label.textColor = .lightText
        return label
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackNameLabel, albumInfoLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.distribution = .equalSpacing
        return stackView
    }()

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

    private func setupLayout() {
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.bottom.leading
                .equalToSuperview()
                .inset(UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 0))
            make.width.equalTo(coverImageView.snp.height).multipliedBy(1)
        }

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(coverImageView.snp.right).offset(15)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }

        // 點擊時 cell highlight的顏色
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hex: "#333333")
        selectedBackgroundView = backgroundView

        backgroundColor = .black
    }
}

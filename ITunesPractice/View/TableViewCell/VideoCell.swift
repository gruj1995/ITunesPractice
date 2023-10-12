//
//  VideoCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

import SnapKit
import UIKit

class VideoCell: UITableViewCell {
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    func configure(_ model: VideoInfo) {
        let url = URL(string: model.thumbnails?.first?.url ?? "")
        videoImageView.loadCoverImage(with: url)
        timeLabel.text = model.length ?? ""
        titleLabel.text = model.title ?? ""
        channelLabel.text = model.channelTitle ?? ""
        if let viewCount = model.shortViewConuntText, let time = model.publishedTimeText {
            infoLabel.text = "\(viewCount)・\(time)"
        }
    }

    // MARK: Private

    private lazy var videoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var timeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.backgroundColor = .black.withAlphaComponent(0.9)
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return label
    }()

    lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, channelLabel, infoLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 2
        return label
    }()

    private lazy var channelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColor(.gray3)
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColor(.gray3)
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    private func setupUI() {
        contentView.backgroundColor = .appColor(.background)
        selectionStyle = .none
        contentView.addSubview(videoImageView)
        videoImageView.addSubview(timeLabel)
        contentView.addSubview(vStackView)
        setupLayout()
    }

    func setupLayout() {
        let padding = Constants.padding
        videoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(padding)
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(120)
        }
        timeLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(4)
        }
        vStackView.snp.makeConstraints { make in
            make.leading.equalTo(videoImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(padding)
            make.top.bottom.equalTo(videoImageView)
        }
    }
}

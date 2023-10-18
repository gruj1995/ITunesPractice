//
//  VideoCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

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

    func configure(_ model: VideoInfo, showDownload: Bool = false) {
        let videoUrl = URL(string: model.thumbnails?.first?.url ?? "")
        videoImageView.loadCoverImage(with: videoUrl)
        timeLabel.text = model.length ?? ""
        liveLabel.text = model.isLive ? "直播" : ""
        titleLabel.text = model.title ?? ""
        channelLabel.text = model.channelTitle ?? ""
        if let viewCount = model.viewCount {
            let time = model.publishedTimeText.isEmptyOrNil ? "" : "・\(model.publishedTimeText!)"
            infoLabel.text = "\(viewCount)\(time)"
        }
        downloadButton.isHidden = !showDownload
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

    private lazy var liveLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.backgroundColor = .red
        label.textColor = .white
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return label
    }()

    lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topStackView, channelLabel, infoLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()

    lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, downloadButton])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .top
        return stackView
    }()

    var onDownloadButtonTapped: ((UIButton) -> Void)?

    lazy var downloadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        button.tintColor = .appColor(.text1)
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 2
        return label
    }()

    lazy var channelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColor(.gray3)
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()

    lazy var infoLabel: UILabel = {
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
        videoImageView.addSubview(liveLabel)
        contentView.addSubview(vStackView)
        setupLayout()
    }

    func setupLayout() {
        let padding = Constants.padding
        videoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(padding)
            $0.top.bottom.equalToSuperview().inset(8)
            $0.width.equalTo(120)
        }
        timeLabel.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(4)
        }
        liveLabel.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(4)
        }
        vStackView.snp.makeConstraints {
            $0.leading.equalTo(videoImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(padding)
            $0.top.bottom.equalTo(videoImageView)
        }
        downloadButton.snp.makeConstraints {
            $0.width.equalTo(20)
        }
    }

    @objc
    private func downloadButtonTapped(_ sender: UIButton) {
        onDownloadButtonTapped?(sender)
    }
}

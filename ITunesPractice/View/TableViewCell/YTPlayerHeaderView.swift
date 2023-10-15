//
//  YTPlayerHeaderView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/13.
//

import UIKit

// MARK: - YTPlayerHeaderView

class YTPlayerHeaderView: UITableViewHeaderFooterView {
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

    override func layoutSubviews() {
        super.layoutSubviews()
        channelImageView.layoutIfNeeded()
        channelImageView.layer.cornerRadius = channelImageView.frame.height * 0.5
    }

    var onMoreButtonTapped: ((UIButton) -> Void)?

    func configure(_ model: VideoDetailInfo) {
        titleLabel.text = model.title ?? ""
        if let viewCount = model.viewCount {
            let time = model.publishedTimeText ?? model.liveStartTimeText ?? ""
            infoLabel.text = "\(viewCount)・\(time)"
        }
        let url = URL(string: model.channelThumbnails?.last?.url ?? "")
        channelImageView.loadCoverImage(with: url)
        channelNameLabel.text = model.channelTitle ?? ""
        channelSubscriptionLabel.isHidden = true
        moreButton.setTitle("...顯示更多", for: .normal)
    }

    // MARK: Private

    lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, infoStackView, channelStackView])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        return stackView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .appColor(.text1)
        return label
    }()

    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [infoLabel, moreButton])
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.textColor = .appColor(.gray3)
        return label
    }()

    lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.appColor(.text1), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var channelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [channelImageView, channelNameLabel, channelNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()

    lazy var channelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var channelNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .appColor(.text1)
        return label
    }()

    lazy var channelSubscriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.textColor = .appColor(.gray3)
        return label
    }()

    private func setupUI() {
        backgroundColor = .clear
        addSubview(vStackView)
        setupLayout()
    }

    private func setupLayout() {
        let padding = Constants.padding
        vStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(padding)
        }
        channelImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
    }

    @objc
    private func moreButtonTapped(_ sender: UIButton) {
        onMoreButtonTapped?(sender)
    }
}

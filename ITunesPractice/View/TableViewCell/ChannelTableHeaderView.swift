//
//  ChannelTableHeaderView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/14.
//

import UIKit

// MARK: - ChannelTableHeaderView

class ChannelTableHeaderView: UITableViewHeaderFooterView {
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

    func configure(_ model: VideoDetailInfo) {
        titleLabel.text = model.title ?? ""
        viewCountLabel.text = model.viewCount ?? ""
        timeLabel.text = model.publishedTimeText ?? model.liveStartTimeText ?? ""
        textView.text = model.description ?? ""
        textView.isHidden = textView.text.isEmptyOrNil
    }

    // MARK: Private

    lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, viewCountLabel, timeLabel, infoBgView])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .appColor(.text1)
        return label
    }()

    lazy var viewCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.textColor = .appColor(.gray3)
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.textColor = .appColor(.gray3)
        return label
    }()

    lazy var infoBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor(.gray)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .appColor(.text1)
        textView.font = .systemFont(ofSize: 13, weight: .regular)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        // 偵測url
        textView.linkTextAttributes = [.foregroundColor: UIColor.appColor(.blue)]
        textView.dataDetectorTypes = .all
        return textView
    }()

    private func setupUI() {
        backgroundColor = .clear
        addSubview(vStackView)
        infoBgView.addSubview(textView)
        setupLayout()
    }

    private func setupLayout() {
        let padding = Constants.padding
        vStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(padding)
        }
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
}

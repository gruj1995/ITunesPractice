//
//  AddTrackCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import UIKit

class AddTrackCell: UITableViewCell {
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

    // MARK: Private

    private lazy var coverImageView: UIImageView = .coverImageView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "加入音樂".localizedString()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()

    private func highlightIfNeeded(_ showsHighlight: Bool) {
        selectionStyle = showsHighlight ? .default : .none
        if showsHighlight {
            // 更改預設的 highlight 顏色
            let backgroundView = UIView()
            backgroundView.backgroundColor = .appColor(.gray5)
            selectedBackgroundView = backgroundView
        }
    }

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
    }
}

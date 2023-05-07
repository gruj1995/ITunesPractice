//
//  CloudOptionCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/7.
//

import SnapKit
import UIKit

class CloudOptionCell: UITableViewCell {
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

    func configure(option: CloudOption) {
        iconImageView.image = option.image
        titleLabel.text = option.title
    }

    // MARK: Private

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()

    private func setupUI() {
        backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
            make.width.equalTo(iconImageView.snp.height)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(20)
            make.trailing.equalTo(contentView.snp.trailingMargin)
            make.centerY.equalToSuperview()
        }
    }
}

//
//  VideoDetailBottomAlert.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/13.
//

import UIKit

class VideoDetailBottomAlert: YTBaseBottomAlert<VideoDetailBottomAlertViewModel> {

    var unwrappedVM: VideoDetailBottomAlertViewModel? {
        viewModel as? VideoDetailBottomAlertViewModel
    }

    override func setupUI() {
        super.setupUI()
        tableView.register(ChannelTableHeaderView.self, forHeaderFooterViewReuseIdentifier: ChannelTableHeaderView.reuseIdentifier)
        tableView.reloadData()
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ChannelTableHeaderView.reuseIdentifier) as? ChannelTableHeaderView else {
            return nil
        }
        guard let info = unwrappedVM?.videoDetailInfo else {
            return header
        }
        header.configure(info)
        return header
    }
}

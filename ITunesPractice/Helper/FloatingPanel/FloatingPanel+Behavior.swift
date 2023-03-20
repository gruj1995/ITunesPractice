//
//  FloatingPanel+Behavior.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/19.
//

import FloatingPanel
import UIKit

/// 禁止滑超過邊界(但目前只能做到滑出一點距離後回彈，尚待研究)
class DisableBouncePanelBehavior: FloatingPanelBehavior {
    // 滑超過頂部或底部時是否有回彈效果
    func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        return false
    }

    // scrollView 減速的速率，值越大要越多時間減速。
    // 作者說值不應小於 0.979
    var springDecelerationRate: CGFloat {
        0.979
    }
}

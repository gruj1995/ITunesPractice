# ITunesPractice
這個專案主要是模仿 Apple Music 的 side project，尚在開發中，所以 developer 分支會是最新進度。


## 專案環境
- Bundle Identifier: com.pinyi.ITunesPractice
- Xcode Version: 14.2.0
- minimumVersion: iOS 15.0


## 軟體架構
MVVM


## 重要 Class
| Tab | Class | Name              | Description                
|-----|---|--------|--------------------------
Tab1 |SearchViewController | 「搜尋」
Tab2 |LibraryViewController |「資料庫」

- MainTabBarController  TabBar控制頁
	 - 迷你播放器頁面：MiniPlayerViewController

- SearchViewController  搜尋頁
	 - 搜尋結果頁：SearchResultsViewController
	 - 搜尋結果資訊頁：TrackDetailViewController
	 - 預覽頁：PreviewViewController
	 - 上下文菜單預覽頁：TrackContextMenuViewController

- LibraryViewController  資料庫頁

- PlaylistViewController 播放清單頁
	 - 播放器頁： PlaylistPlayerViewController
	 
- MusicPlayer 音樂播放的 Helper


## 練習使用的技術/套件/框架

- 音樂播放相關原生庫 (AVFoundation、AVKit、MediaPlayer)
- Combine
- ContextMenu
- FloatingPanel（調整viewController高度）
- Navigationbar appearance
- PropertyWrapper
- SnapKit(練習以純code刻畫面)
- SF Symbols
- SwiftLint
- SwiftFormat
- UIViewPropertyAnimator
- 從專輯圖片取得漸層色(ColorKit、UIImageColors、UIImageColors...等第三方庫)

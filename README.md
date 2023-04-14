# ITunesPractice
這個專案主要是模仿 Apple Music 的 side project，尚在開發中，所以 developer 分支會是最新進度。

## 功能展示
- 基本播放功能：
	- 播放、暫停
	- 上一曲、下一曲
	- 調整系統音量
	- 拖曳調整播放進度
	- 重複播放、隨機播放(尚有bug)
其他功能：
	- 專輯封面漸層色<br>
	<img src="https://user-images.githubusercontent.com/70060071/231921683-2fb87a50-1297-487c-ba7a-aacc6a496a6f.png" alt="simulator_screenshot_1CF8119B-0706-4AFE-83F3-80352FDA9559" style="width:360px"><br>
	
	- 支援背景播放(靜音模式、關閉螢幕、將app滑入背景時都可以繼續播放音樂)<br>
	<img src="https://user-images.githubusercontent.com/70060071/231921514-f57f3439-de78-4181-8fcf-060ccc729cbc.jpg" alt="S__23265288" style="width:360px;"><br>
	
	- 長按cell出現快捷選單<br>
	<img src="https://user-images.githubusercontent.com/70060071/231921272-4ef915a5-9ddb-4a03-8080-6b6c22bba338.png" alt="simulator_screenshot_6DE22608-56AE-47DE-8B69-841FFFA74E92" style="width:360px;"><br>

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

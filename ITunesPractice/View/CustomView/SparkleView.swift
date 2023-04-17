//
//  SparkleView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import UIKit

class SparkleView: UIView {
    // MARK: Lifecycle

    init(frame: CGRect, sparkImage: UIImage? = AppImages.sparkle) {
        self.sparkImage = sparkImage
        super.init(frame: frame)
        configureEmitterLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureEmitterLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.frame = bounds
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.height)
        // 粒子發射器大小
        emitterLayer.emitterSize = CGSize(width: bounds.width * 0.5, height: bounds.height)
    }

    // MARK: Internal

    private var sparkImage: UIImage?

    // 粒子產生的係數（一個畫面上會有多少多少個粒子，就是 CAEmitterCell 的 birthRate * CAEmitterLayer 的 birthRate）
    var birthRate: Float {
        get { return emitterLayer.birthRate }
        set { emitterLayer.birthRate = newValue }
    }

    var lifetime: Float {
        get { return emitterLayer.lifetime }
        set { emitterLayer.lifetime = newValue }
    }

    var velocity: Float {
        get { return emitterLayer.velocity }
        set { emitterLayer.velocity = newValue }
    }

    var scale: Float {
        get { return emitterLayer.scale }
        set { emitterLayer.scale = newValue }
    }

    // MARK: Private

    private let emitterLayer = CAEmitterLayer()

    private func configureEmitterLayer() {
        let sparkle = createCAEmitterCell()
        emitterLayer.emitterShape = .line
        emitterLayer.emitterMode = .outline
        emitterLayer.renderMode = .oldestLast
        emitterLayer.emitterCells = [sparkle] // 發射器發射的粒子類型
        layer.addSublayer(emitterLayer)
    }

    private func createCAEmitterCell() -> CAEmitterCell {
        let sparkle = CAEmitterCell()
        let image = createSparkleImage()
        sparkle.contents = image.cgImage  // CAEmitterCell的顯示內容
        sparkle.birthRate = 60            // 每秒發射的粒子數量
        sparkle.lifetime = 6              // 粒子的生命週期(秒)
        sparkle.lifetimeRange = 2.0       // 粒子生命週期容許的容差範圍
        sparkle.velocity = 100            // 粒子的速度
        sparkle.velocityRange = 200.0     // 粒子速度的容差

    //  sparkle.emissionLatitude =        // Z 軸方向的發射角度
        sparkle.emissionLongitude = 0     // XY 平面的粒子發射角度 (0 即向上發射)
        sparkle.emissionRange = .pi / 2   // 粒子發射方向的變化範圍

        sparkle.scale = 0.5               // 粒子的縮放比例
        sparkle.scaleRange = 0.2          // 縮放比例的變化範圍
        sparkle.scaleSpeed = -0.15        // 縮放速度

        sparkle.alphaRange = 0.75
        sparkle.alphaSpeed = -0.1         // 粒子透明度變化速度，這裡指定為-0.1，即每秒透明度減少0.1
        sparkle.spin = 2                  // 旋轉度數

        // 顏色相關
        sparkle.redRange =  1.0
        sparkle.greenRange = 1.0
        sparkle.blueRange =  1.0
        sparkle.redSpeed =  0.0
        sparkle.greenSpeed =  0.0
        sparkle.blueSpeed =  0.0

//        sparkle.xAcceleration = 10.0        // x軸加速度
//        sparkle.yAcceleration = 30.0        // y軸加速度
//        sparkle.zAcceleration = 10.0        // z 軸加速度

        return sparkle
    }

    /// 生成做為火花的小圓點圖片，注意顏色如果設太深會導致變化不多且可能看不見
    private func createSparkleImage() -> UIImage {
        let size = CGSize(width: 2, height: 2)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.yellow.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return image
    }
}

//
//  SparkleView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import UIKit

/// 粒子系統
class SparkleView: UIView {
    // MARK: Lifecycle

    init(frame: CGRect, sparkImage: UIImage?) {
        self.sparkImage = sparkImage
        super.init(frame: frame)
        configureEmitterLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureEmitterLayer()
    }

    // MARK: Internal

    // 定義粒子產生的速率，也就是一個畫面上會有多少多少個粒子
    // 這個速率是由CAEmitterCell的birthRate和CAEmitterLayer的birthRate相乘得出
    var birthRate: Float {
        get { return emitterLayer.birthRate }
        set { emitterLayer.birthRate = newValue }
    }

    // 定義粒子的生命週期，也就是粒子從產生到消失的時間長度
    var lifetime: Float {
        get { return emitterLayer.lifetime }
        set { emitterLayer.lifetime = newValue }
    }

    // 定義粒子的運動速度，速度越快，粒子移動越快
    // 如果將速度調成0，可以暫停粒子系統的動畫效果
    var velocity: Float {
        get { return emitterLayer.velocity }
        set { emitterLayer.velocity = newValue }
    }

    // 定義粒子的縮放比例，也就是粒子的大小
    var scale: Float {
        get { return emitterLayer.scale }
        set { emitterLayer.scale = newValue }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.frame = bounds
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.height)
        // 粒子發射器大小
        emitterLayer.emitterSize = CGSize(width: bounds.width * 0.5, height: bounds.height)
    }

    // MARK: Private

    private var sparkImage: UIImage?

    private let emitterLayer = CAEmitterLayer()

    private func configureEmitterLayer() {
        let sparkle = createCAEmitterCell()
        emitterLayer.emitterShape = .line   // 發射形狀
        emitterLayer.emitterMode = .outline // 發射模式
        emitterLayer.renderMode = .oldestLast  // 渲染模式
        emitterLayer.emitterCells = [sparkle]  // 發射器發射的粒子類型
        layer.addSublayer(emitterLayer)
    }

    private func createCAEmitterCell() -> CAEmitterCell {
        let sparkle = CAEmitterCell()
        sparkle.contents = sparkImage?.cgImage // CAEmitterCell的顯示內容
        sparkle.birthRate = 60 // 每秒發射的粒子數量
        sparkle.lifetime = 6 // 粒子的生命週期(秒)
        sparkle.lifetimeRange = 2.0 // 粒子生命週期容許的容差範圍
        sparkle.velocity = 100 // 粒子的速度
        sparkle.velocityRange = 200.0 // 粒子速度的容差

        //  sparkle.emissionLatitude = 0    // Z 軸方向的發射角度
        sparkle.emissionLongitude = 0 // XY 平面的粒子發射角度 (0 即向上發射)
        sparkle.emissionRange = .pi / 2 // 粒子發射方向的變化範圍

        sparkle.scale = 0.5 // 粒子的縮放比例
        sparkle.scaleRange = 0.2 // 縮放比例的變化範圍
        sparkle.scaleSpeed = -0.15 // 縮放速度

        sparkle.alphaRange = 0.75 // 粒子產生時的透明度變化範圍，會在粒子的原始透明度值上加減 alphaRange，從而創造出透明度不同的粒子
        sparkle.alphaSpeed = -0.1 // 粒子透明度變化速度，這裡指定為-0.1，即每秒透明度減少0.1
        sparkle.spin = 2 // 旋轉度數

        // 顏色相關
        sparkle.redRange = 1.0
        sparkle.greenRange = 1.0
        sparkle.blueRange = 1.0
        sparkle.redSpeed = 0.0
        sparkle.greenSpeed = 0.0
        sparkle.blueSpeed = 0.0

//        sparkle.xAcceleration = 10.0        // x軸加速度
//        sparkle.yAcceleration = 30.0        // y軸加速度
//        sparkle.zAcceleration = 10.0        // z 軸加速度

        return sparkle
    }
}

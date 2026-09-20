// ThrusterEffect.swift
// ShootingGame - エンジン噴射エフェクトの生成

import RealityKit
import UIKit

/// 自機のスラスターエフェクト (エンジン噴射炎) を生成するファクトリ
enum ThrusterEffect {

    /// エンジン噴射パーティクルを生成して parent に追加する
    static func attach(to parent: Entity, offsetZ: Float) {
        let container = Entity()
        container.position = SIMD3<Float>(0, 0, offsetZ)

        var particles = ParticleEmitterComponent()

        // エミッター形状 (点から広がる炎)
        particles.emitterShape     = .point
        particles.birthLocation    = .surface
        particles.birthDirection   = .normal

        // 放出設定
        particles.mainEmitter.birthRate         = 80
        particles.mainEmitter.lifeSpan          = 0.22
        particles.mainEmitter.lifeSpanVariation = 0.08
        particles.mainEmitter.size              = 0.055
        particles.mainEmitter.sizeVariation     = 0.02

        // 色: 青白 (iOS 18 ではシンプルな定数カラー)
        particles.mainEmitter.color = .constant(.single(
            UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        ))

        container.components.set(particles)
        parent.addChild(container)
    }
}

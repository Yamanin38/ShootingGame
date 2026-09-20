// ExplosionEffect.swift
// ShootingGame - 爆発エフェクトの生成と管理

import RealityKit
import UIKit

/// 敵破壊時の爆発エフェクトを生成・管理するクラス
@MainActor
final class EffectManager {

    // MARK: - 爆発エフェクト

    func spawnExplosion(at position: SIMD3<Float>, anchor: AnchorEntity) {
        let container = Entity()
        container.position = position
        anchor.addChild(container)

        // ---- パーティクル ----
        addExplosionParticles(to: container)

        // ---- フラッシュライト ----
        var pl = PointLightComponent()
        pl.color     = UIColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0)
        pl.intensity = 8000
        pl.attenuationRadius = 5.0
        let flashEnt = Entity()
        flashEnt.components.set(pl)
        container.addChild(flashEnt)

        // ---- 残骸の破片 ----
        addDebris(to: container)

        // ---- 一定時間後に自動削除 ----
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(GameConfig.explosionDuration * 1_000_000_000))
            container.removeFromParent()
        }
    }

    // MARK: - パーティクル (iOS 18 API)

    private func addExplosionParticles(to parent: Entity) {
        var particles = ParticleEmitterComponent()

        // エミッター形状
        particles.emitterShape     = .sphere
        particles.emitterShapeSize = SIMD3<Float>(0.15, 0.15, 0.15)
        particles.birthLocation    = .volume
        particles.birthDirection   = .normal

        // 放出レート (高レート × 短命で爆発感を演出)
        particles.mainEmitter.birthRate         = 350
        particles.mainEmitter.lifeSpan          = 0.55
        particles.mainEmitter.lifeSpanVariation = 0.2
        particles.mainEmitter.size              = 0.07
        particles.mainEmitter.sizeVariation     = 0.03

        // 色: オレンジ (iOS 18 では UIColor を直接使用)
        particles.mainEmitter.color = .constant(.single(
            UIColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
        ))

        parent.components.set(particles)
    }

    // MARK: - 破片

    private func addDebris(to parent: Entity) {
        let mat  = UnlitMaterial(color: UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 1.0))
        let mesh = MeshResource.generateBox(size: 0.08)

        for i in 0..<6 {
            let debris = ModelEntity(mesh: mesh, materials: [mat])
            let angle  = Float(i) / 6.0 * 2 * .pi
            let radius = Float.random(in: 0.2...0.6)
            debris.position = SIMD3<Float>(cos(angle) * radius, 0, sin(angle) * radius)
            parent.addChild(debris)
        }
    }
}

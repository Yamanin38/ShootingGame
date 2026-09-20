// EnemyData.swift
// ShootingGame - 敵機の状態を保持するデータ構造体

import Foundation
import RealityKit
import simd

/// 敵機1機分のゲームデータ
struct EnemyData: Identifiable {
    let id: UUID
    let entity: Entity
    var position: SIMD3<Float>
    /// 次に弾を発射するまでの残り秒数
    var fireTimer: TimeInterval
    /// 横揺れ用の位相オフセット (sin 波)
    let swayPhase: Float

    init(entity: Entity, position: SIMD3<Float>) {
        self.id        = UUID()
        self.entity    = entity
        self.position  = position
        self.fireTimer = Double.random(in: 0.8...GameConfig.enemyFireRate)
        self.swayPhase = Float.random(in: 0...(2 * .pi))
    }
}

// EnemyAISystem.swift
// ShootingGame - 敵機の移動 AI と弾発射

import Foundation
import RealityKit
import simd

/// 敵機の移動パターン・弾発射タイミングを管理するシステム
@MainActor
final class EnemyAISystem {

    private let bulletSystem: BulletSystem

    init(bulletSystem: BulletSystem) {
        self.bulletSystem = bulletSystem
    }

    func update(dt: TimeInterval, viewModel: GameViewModel) {
        guard let anchor = viewModel.sceneAnchor else { return }

        var toRemove: [Int] = []
        for i in viewModel.enemies.indices {
            // 下方向へ移動 (Z+方向)
            var pos = viewModel.enemies[i].position
            pos.z += GameConfig.enemyBaseSpeed * Float(dt)

            // 横揺れ (sin 波)
            let phase = viewModel.enemies[i].swayPhase
            let sway  = sin(Float(viewModel.totalTime) * 1.8 + phase) * 0.8
            pos.x += sway * Float(dt)

            // プレイフィールドX内でクランプ
            pos.x = min(max(pos.x, -GameConfig.playfieldHalfWidth), GameConfig.playfieldHalfWidth)

            viewModel.enemies[i].position = pos
            viewModel.enemies[i].entity.position = pos

            // 画面下を通り過ぎたら削除
            if pos.z > GameConfig.playfieldHalfHeight + 2.0 {
                viewModel.enemies[i].entity.removeFromParent()
                toRemove.append(i)
                continue
            }

            // 弾発射タイマー
            viewModel.enemies[i].fireTimer -= dt
            if viewModel.enemies[i].fireTimer <= 0 {
                bulletSystem.fireEnemyBullet(from: viewModel.enemies[i], viewModel: viewModel, anchor: anchor)
                viewModel.enemies[i].fireTimer = GameConfig.enemyFireRate
            }
        }
        for i in toRemove.reversed() { viewModel.enemies.remove(at: i) }
    }
}

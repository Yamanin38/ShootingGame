// EnemySpawnSystem.swift
// ShootingGame - 敵機の出現タイミングと初期配置

import Foundation
import RealityKit
import simd

/// 一定間隔で敵機をスポーンするシステム
@MainActor
final class EnemySpawnSystem {

    func update(dt: TimeInterval, viewModel: GameViewModel) {
        guard let anchor = viewModel.sceneAnchor else { return }
        guard viewModel.enemies.count < GameConfig.maxEnemiesOnScreen else { return }

        viewModel.enemySpawnTimer -= dt
        if viewModel.enemySpawnTimer <= 0 {
            spawnEnemy(viewModel: viewModel, anchor: anchor)
            viewModel.enemySpawnTimer = GameConfig.enemySpawnInterval
        }
    }

    // MARK: - スポーン

    private func spawnEnemy(viewModel: GameViewModel, anchor: AnchorEntity) {
        // ランダムX位置で画面上部に出現
        let x = Float.random(in: -GameConfig.playfieldHalfWidth...GameConfig.playfieldHalfWidth)
        let spawnPos = SIMD3<Float>(x, 0, -(GameConfig.playfieldHalfHeight + 1.0))

        let entity = EnemyEntity.make()
        entity.position = spawnPos
        anchor.addChild(entity)

        viewModel.enemies.append(EnemyData(entity: entity, position: spawnPos))
    }
}

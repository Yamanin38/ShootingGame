// BulletSystem.swift
// ShootingGame - 弾の発射・移動・寿命管理

import Foundation
import RealityKit
import simd

/// 自機弾・敵弾の発射タイミング、移動、画面外削除を管理するシステム
@MainActor
final class BulletSystem {

    // MARK: - 自機弾の更新

    func updatePlayerBullets(dt: TimeInterval, viewModel: GameViewModel) {
        guard let anchor = viewModel.sceneAnchor,
              let player = viewModel.playerEntity else { return }

        // 発射タイマー
        viewModel.playerFireTimer -= dt
        if viewModel.playerFireTimer <= 0 {
            fireBulletsFromPlayer(player: player, viewModel: viewModel, anchor: anchor)
            viewModel.playerFireTimer = GameConfig.playerBulletFireRate
        }

        // 弾の移動と画面外削除 (単一パスで処理)
        var toRemove: [Int] = []
        for i in viewModel.bullets.indices where viewModel.bullets[i].isPlayerBullet {
            let newPos = viewModel.bullets[i].position + viewModel.bullets[i].velocity * Float(dt)
            viewModel.bullets[i].entity.position = newPos
            if newPos.z < -(GameConfig.playfieldHalfHeight + 2.0) {
                viewModel.bullets[i].entity.removeFromParent()
                toRemove.append(i)
            } else {
                viewModel.bullets[i] = BulletData(
                    entity: viewModel.bullets[i].entity,
                    position: newPos,
                    velocity: viewModel.bullets[i].velocity,
                    isPlayerBullet: true
                )
            }
        }
        for i in toRemove.reversed() { viewModel.bullets.remove(at: i) }
    }

    // MARK: - 敵弾の更新

    func updateEnemyBullets(dt: TimeInterval, viewModel: GameViewModel) {
        var toRemove: [Int] = []
        for i in viewModel.bullets.indices where !viewModel.bullets[i].isPlayerBullet {
            let newPos = viewModel.bullets[i].position + viewModel.bullets[i].velocity * Float(dt)
            viewModel.bullets[i].entity.position = newPos
            if newPos.z > (GameConfig.playfieldHalfHeight + 2.0) {
                viewModel.bullets[i].entity.removeFromParent()
                toRemove.append(i)
            } else {
                viewModel.bullets[i] = BulletData(
                    entity: viewModel.bullets[i].entity,
                    position: newPos,
                    velocity: viewModel.bullets[i].velocity,
                    isPlayerBullet: false
                )
            }
        }
        for i in toRemove.reversed() { viewModel.bullets.remove(at: i) }
    }

    // MARK: - 弾の発射

    private func fireBulletsFromPlayer(player: Entity, viewModel: GameViewModel, anchor: AnchorEntity) {
        let basePos = player.position
        let count   = viewModel.bulletCount

        // 弾数に応じたオフセット列
        let offsets: [Float]
        switch count {
        case 1:  offsets = [0]
        case 2:  offsets = [-GameConfig.bulletSpread[0], GameConfig.bulletSpread[0]]
        default: offsets = GameConfig.bulletSpread
        }

        for xOffset in offsets {
            let spawnPos = SIMD3<Float>(basePos.x + xOffset, 0, basePos.z - 0.8)
            let velocity = SIMD3<Float>(0, 0, -GameConfig.playerBulletSpeed)
            let entity   = PlayerBulletEntity.make()
            entity.position = spawnPos
            anchor.addChild(entity)
            viewModel.bullets.append(BulletData(entity: entity, position: spawnPos, velocity: velocity, isPlayerBullet: true))
        }
    }

    // MARK: - 敵弾の発射 (EnemyAISystem から呼ばれる)

    func fireEnemyBullet(from enemy: EnemyData, viewModel: GameViewModel, anchor: AnchorEntity) {
        let spawnPos = SIMD3<Float>(enemy.position.x, 0, enemy.position.z + 0.8)
        let velocity = SIMD3<Float>(0, 0, GameConfig.enemyBulletSpeed)
        let entity   = EnemyBulletEntity.make()
        entity.position = spawnPos
        anchor.addChild(entity)
        viewModel.bullets.append(BulletData(entity: entity, position: spawnPos, velocity: velocity, isPlayerBullet: false))
    }
}

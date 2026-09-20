// CollisionSystem.swift
// ShootingGame - 衝突判定と結果処理

import Foundation
import RealityKit
import simd

/// 全オブジェクト間の衝突判定を担うシステム
@MainActor
final class CollisionSystem {

    private let effectManager: EffectManager

    init(effectManager: EffectManager) {
        self.effectManager = effectManager
    }

    // MARK: - メイン更新

    func update(viewModel: GameViewModel) {
        guard let anchor = viewModel.sceneAnchor else { return }

        checkPlayerBulletsVsEnemies(viewModel: viewModel, anchor: anchor)
        checkEnemyBulletsVsPlayer(viewModel: viewModel)
        checkItemsVsPlayer(viewModel: viewModel, anchor: anchor)
    }

    // MARK: - 自機弾 vs 敵機

    private func checkPlayerBulletsVsEnemies(viewModel: GameViewModel, anchor: AnchorEntity) {
        var hitBulletIDs: Set<UUID> = []
        var hitEnemyIDs:  Set<UUID> = []

        for bullet in viewModel.bullets where bullet.isPlayerBullet {
            for enemy in viewModel.enemies {
                let dist = simd_distance(bullet.position, enemy.position)
                if dist < (GameConfig.playerBulletHitRadius + GameConfig.enemyHitRadius) {
                    hitBulletIDs.insert(bullet.id)
                    hitEnemyIDs.insert(enemy.id)
                }
            }
        }

        // ヒットした弾を除去
        for id in hitBulletIDs {
            if let idx = viewModel.bullets.firstIndex(where: { $0.id == id }) {
                viewModel.bullets[idx].entity.removeFromParent()
                viewModel.bullets.remove(at: idx)
            }
        }

        // ヒットした敵を破壊
        for id in hitEnemyIDs {
            if let idx = viewModel.enemies.firstIndex(where: { $0.id == id }) {
                let enemyPos = viewModel.enemies[idx].position
                effectManager.spawnExplosion(at: enemyPos, anchor: anchor)
                viewModel.enemies[idx].entity.removeFromParent()
                viewModel.enemies.remove(at: idx)
                viewModel.score += GameConfig.enemyScoreValue

                // アップグレードアイテムのドロップ判定
                if viewModel.bulletCount < GameConfig.maxBulletCount {
                    let roll = Float.random(in: 0...1)
                    if roll < GameConfig.itemDropChance {
                        UpgradeSystem.spawnItem(at: enemyPos, viewModel: viewModel, anchor: anchor)
                    }
                }
            }
        }
    }

    // MARK: - 敵弾 vs 自機

    private func checkEnemyBulletsVsPlayer(viewModel: GameViewModel) {
        guard let player = viewModel.playerEntity else { return }
        let playerPos = player.position

        var hitIDs: [UUID] = []
        for bullet in viewModel.bullets where !bullet.isPlayerBullet {
            let dist = simd_distance(bullet.position, playerPos)
            if dist < (GameConfig.enemyBulletHitRadius + GameConfig.playerHitRadius) {
                hitIDs.append(bullet.id)
            }
        }

        if !hitIDs.isEmpty {
            for id in hitIDs {
                if let idx = viewModel.bullets.firstIndex(where: { $0.id == id }) {
                    viewModel.bullets[idx].entity.removeFromParent()
                    viewModel.bullets.remove(at: idx)
                }
            }
            viewModel.endGame()
        }
    }

    // MARK: - アイテム vs 自機

    private func checkItemsVsPlayer(viewModel: GameViewModel, anchor: AnchorEntity) {
        guard let player = viewModel.playerEntity else { return }
        let playerPos = player.position

        var hitIDs: [UUID] = []
        for item in viewModel.items {
            let dist = simd_distance(item.position, playerPos)
            if dist < (GameConfig.itemHitRadius + GameConfig.playerHitRadius) {
                hitIDs.append(item.id)
            }
        }

        for id in hitIDs {
            if let idx = viewModel.items.firstIndex(where: { $0.id == id }) {
                viewModel.items[idx].entity.removeFromParent()
                viewModel.items.remove(at: idx)
                viewModel.bulletCount = min(viewModel.bulletCount + 1, GameConfig.maxBulletCount)
            }
        }
    }
}

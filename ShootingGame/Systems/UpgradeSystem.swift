// UpgradeSystem.swift
// ShootingGame - アップグレードアイテムの生成・移動・回転

import Foundation
import RealityKit
import simd

/// アップグレードアイテムの生成と更新を担うシステム
@MainActor
final class UpgradeSystem {

    // MARK: - アイテムのスポーン (static: CollisionSystem から呼ばれる)

    static func spawnItem(at position: SIMD3<Float>, viewModel: GameViewModel, anchor: AnchorEntity) {
        let entity = UpgradeItemEntity.make()
        entity.position = position
        anchor.addChild(entity)
        viewModel.items.append(ItemData(entity: entity, position: position))
    }

    // MARK: - アイテムの更新

    func updateItems(dt: TimeInterval, viewModel: GameViewModel) {
        var toRemove: [Int] = []

        for i in viewModel.items.indices {
            // 下方向に落下
            var pos = viewModel.items[i].position
            pos.z += GameConfig.itemFallSpeed * Float(dt)
            viewModel.items[i].position = pos
            viewModel.items[i].entity.position = pos

            // Y 軸回転アニメーション
            viewModel.items[i].rotationAngle += Float(dt) * 2.5
            let angle = viewModel.items[i].rotationAngle
            viewModel.items[i].entity.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])

            // 画面外で削除
            if pos.z > GameConfig.playfieldHalfHeight + 2.0 {
                viewModel.items[i].entity.removeFromParent()
                toRemove.append(i)
            }
        }
        for i in toRemove.reversed() { viewModel.items.remove(at: i) }
    }
}

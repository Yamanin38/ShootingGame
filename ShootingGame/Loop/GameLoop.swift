// GameLoop.swift
// ShootingGame - CADisplayLink ベースの 60fps ゲームループ

import Foundation
import QuartzCore

/// CADisplayLink を使ってゲームシステムを 60fps で駆動するクラス
/// @MainActor は付けず、tick 内で MainActor.assumeIsolated を使う
final class GameLoop {

    // MARK: - 依存
    private let viewModel: GameViewModel
    private let bulletSystem: BulletSystem
    private let enemySpawnSystem: EnemySpawnSystem
    private let enemyAISystem: EnemyAISystem
    private let collisionSystem: CollisionSystem
    private let upgradeSystem: UpgradeSystem

    // MARK: - 内部
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    // MARK: - 初期化

    init(
        viewModel: GameViewModel,
        bulletSystem: BulletSystem,
        enemySpawnSystem: EnemySpawnSystem,
        enemyAISystem: EnemyAISystem,
        collisionSystem: CollisionSystem,
        upgradeSystem: UpgradeSystem
    ) {
        self.viewModel        = viewModel
        self.bulletSystem     = bulletSystem
        self.enemySpawnSystem = enemySpawnSystem
        self.enemyAISystem    = enemyAISystem
        self.collisionSystem  = collisionSystem
        self.upgradeSystem    = upgradeSystem
    }

    // MARK: - 制御

    func start() {
        stop()
        lastTimestamp = 0
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - ループ本体
    // CADisplayLink は常にメインスレッドから呼ばれるため
    // MainActor.assumeIsolated で @MainActor 隔離プロパティに安全にアクセスする

    @objc private func tick(_ link: CADisplayLink) {
        MainActor.assumeIsolated { [self] in
            guard viewModel.gameState == .playing else { return }

            // デルタタイム計算
            if lastTimestamp == 0 { lastTimestamp = link.timestamp }
            let dt = min(link.timestamp - lastTimestamp, 1.0 / 30.0)
            lastTimestamp = link.timestamp
            viewModel.totalTime += dt

            // 各システムを順番に更新
            bulletSystem.updatePlayerBullets(dt: dt, viewModel: viewModel)
            bulletSystem.updateEnemyBullets(dt: dt, viewModel: viewModel)
            enemySpawnSystem.update(dt: dt, viewModel: viewModel)
            enemyAISystem.update(dt: dt, viewModel: viewModel)
            upgradeSystem.updateItems(dt: dt, viewModel: viewModel)
            collisionSystem.update(viewModel: viewModel)

            // プレイヤー位置を目標に即時追随
            updatePlayerPosition()
        }
    }

    // MARK: - プレイヤー追随

    @MainActor
    private func updatePlayerPosition() {
        guard let player = viewModel.playerEntity else { return }
        let target = viewModel.playerTargetPosition
        let clampedX = min(max(target.x, -GameConfig.playfieldHalfWidth),  GameConfig.playfieldHalfWidth)
        let clampedZ = min(max(target.z, -GameConfig.playfieldHalfHeight), GameConfig.playfieldHalfHeight)
        player.position = SIMD3<Float>(clampedX, 0, clampedZ)
    }
}

// GameViewModel.swift
// ShootingGame - ゲーム全体の状態とエンティティ参照の管理

import Foundation
import RealityKit
import Combine
import simd

@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Published (HUD / UI 用)
    @Published var score: Int          = 0
    @Published var bulletCount: Int    = 1
    @Published var gameState: GameState = .menu

    // MARK: - Scene ルートアンカー (GameRealityView からセット)
    var sceneAnchor: AnchorEntity?

    // MARK: - ゲームオブジェクトリスト
    var playerEntity: Entity?
    var bullets: [BulletData]  = []
    var enemies: [EnemyData]   = []
    var items:   [ItemData]    = []

    // MARK: - 内部タイマー
    var playerFireTimer: TimeInterval   = 0
    var enemySpawnTimer: TimeInterval   = 0
    var totalTime: TimeInterval         = 0

    // MARK: - プレイヤー目標座標
    var playerTargetPosition: SIMD3<Float> = GameConfig.playerStartPosition

    // MARK: - ゲームループ参照
    private(set) var gameLoop: GameLoop?

    // MARK: - ライフサイクル

    func startGame() {
        score       = 0
        bulletCount = 1
        playerFireTimer  = 0
        enemySpawnTimer  = 0
        totalTime        = 0
        bullets.removeAll()
        enemies.removeAll()
        items.removeAll()
        playerTargetPosition = GameConfig.playerStartPosition
        gameState = .playing
        gameLoop?.start()
    }

    func endGame() {
        gameLoop?.stop()
        gameState = .gameOver
    }

    func bindGameLoop(_ loop: GameLoop) {
        self.gameLoop = loop
    }
}

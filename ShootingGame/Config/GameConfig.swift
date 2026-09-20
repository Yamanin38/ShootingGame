// GameConfig.swift
// ShootingGame - ゲーム全定数の一元管理

import Foundation
import simd

/// ゲーム全体の定数を管理するネームスペース
enum GameConfig {

    // MARK: - カメラ
    /// カメラのY高さ (ゲーム平面から見下ろす距離)
    static let cameraHeight: Float = 22.0
    /// カメラFOV (度)
    static let cameraFOV: Float = 50.0

    // MARK: - プレイフィールド
    /// X幅の半分 (±この値がプレイ領域)
    static let playfieldHalfWidth: Float  = 5.5
    /// Z奥行の半分 (±この値がプレイ領域)
    static let playfieldHalfHeight: Float = 9.0

    // MARK: - 自機
    static let playerStartPosition: SIMD3<Float> = [0, 0, 7.0]
    static let playerHitRadius: Float = 0.45
    /// 指追随のlerp係数 (1.0 = 即追随)
    static let playerLerpFactor: Float = 1.0

    // MARK: - 自機弾
    static let playerBulletSpeed: Float  = 18.0
    static let playerBulletFireRate: TimeInterval = 0.14   // 発射間隔(秒)
    static let playerBulletHitRadius: Float = 0.18
    /// 弾数ごとのX方向オフセット
    static let bulletSpread: [Float] = [-0.30, 0, 0.30]

    // MARK: - 敵機
    static let enemyBaseSpeed: Float  = 2.2
    static let enemyHitRadius: Float  = 0.55
    static let enemyFireRate: TimeInterval  = 2.0
    static let enemyBulletSpeed: Float = 6.5
    static let enemyBulletHitRadius: Float = 0.22
    static let enemyScoreValue: Int = 100
    static let enemySpawnInterval: TimeInterval = 1.8
    static let maxEnemiesOnScreen: Int = 8

    // MARK: - アップグレードアイテム
    static let itemDropChance: Float = 0.40  // 40 %
    static let itemFallSpeed: Float  = 1.8
    static let itemHitRadius: Float  = 0.50
    static let maxBulletCount: Int   = 3

    // MARK: - エフェクト
    static let explosionDuration: TimeInterval = 0.8
}

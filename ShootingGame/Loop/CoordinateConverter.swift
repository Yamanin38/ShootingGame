// CoordinateConverter.swift
// ShootingGame - スクリーン座標 → ワールド座標変換

import Foundation
import simd
import UIKit

/// タッチのスクリーン座標をゲームのワールド座標(XZ平面)へ変換するユーティリティ
enum CoordinateConverter {

    /// スクリーン上のタッチ点をワールドXZ座標へ変換する
    /// - Parameters:
    ///   - touchPoint: UIKit のタッチ座標 (左上原点)
    ///   - screenSize: 画面サイズ
    ///   - cameraHeight: カメラのY高さ
    ///   - fovDegrees: カメラ垂直FOV (度)
    /// - Returns: ゲームプレイ平面上のワールド座標 (Y=0固定)
    static func worldPosition(
        from touchPoint: CGPoint,
        screenSize: CGSize,
        cameraHeight: Float = GameConfig.cameraHeight,
        fovDegrees: Float   = GameConfig.cameraFOV
    ) -> SIMD3<Float> {
        let aspect = Float(screenSize.width / screenSize.height)
        let fovRad = fovDegrees * .pi / 180.0
        // 画面の垂直半分に相当するワールド距離
        let halfVisibleHeight = cameraHeight * tan(fovRad / 2.0)
        let halfVisibleWidth  = halfVisibleHeight * aspect

        // 画面左上原点 → 中心原点の正規化座標 (-1…+1)
        let normalizedX = Float(touchPoint.x / screenSize.width)  * 2.0 - 1.0
        let normalizedY = Float(touchPoint.y / screenSize.height) * 2.0 - 1.0

        // ワールドX: 右方向が正
        let worldX = normalizedX * halfVisibleWidth
        // ワールドZ: 画面下(Y増加)がZ正方向
        let worldZ = normalizedY * halfVisibleHeight

        return SIMD3<Float>(worldX, 0.0, worldZ)
    }
}

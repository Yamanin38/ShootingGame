// GameState.swift
// ShootingGame - ゲーム状態の列挙

import Foundation

/// ゲームのライフサイクル状態
enum GameState: Equatable {
    case menu
    case playing
    case gameOver
}

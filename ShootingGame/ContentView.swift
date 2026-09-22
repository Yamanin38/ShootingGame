// ContentView.swift
// ShootingGame - ルートビュー (状態に応じた画面切り替え)

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            // ---- 常に背景に RealityKit ビューを表示 ----
            GameRealityView(viewModel: viewModel)
          RadialGradient(colors: [.clear, .black.opacity(0.35)],
                         center: .center, startRadius: 180, endRadius: 520)
              .ignoresSafeArea()
              .allowsHitTesting(false)
                .ignoresSafeArea()

            // ---- 状態に応じたオーバーレイ ----
            switch viewModel.gameState {

            case .menu:
                StartView {
                    resetScene()
                    viewModel.startGame()
                }
                .transition(.opacity)

            case .playing:
                HUDView(viewModel: viewModel)
                    .transition(.opacity)

            case .gameOver:
                GameOverView(score: viewModel.score) {
                    resetScene()
                    viewModel.startGame()
                }
                .transition(.opacity)
            }
        }.task {
          await PlayerEntity.preload()
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gameState)
        // ステータスバーを非表示にしてフルスクリーン化
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }

    // MARK: - シーンリセット

    /// 再スタート時に既存エンティティをシーンから除去する
    private func resetScene() {
        guard let anchor = viewModel.sceneAnchor else { return }

        // 全弾を除去
        for bullet in viewModel.bullets { bullet.entity.removeFromParent() }
        // 全敵を除去
        for enemy in viewModel.enemies   { enemy.entity.removeFromParent() }
        // 全アイテムを除去
        for item in viewModel.items      { item.entity.removeFromParent() }

        // 自機を初期位置に戻す
        viewModel.playerEntity?.position = GameConfig.playerStartPosition
        viewModel.playerTargetPosition   = GameConfig.playerStartPosition
    }
}

#Preview {
    ContentView()
}

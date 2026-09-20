// GameOverView.swift
// ShootingGame - ゲームオーバー画面

import SwiftUI

/// ゲームオーバー時のオーバーレイ画面
struct GameOverView: View {

    let score: Int
    let onRestart: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // タイトル
                Text("GAME OVER")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.8), radius: 16)
                    .scaleEffect(appear ? 1.0 : 0.6)

                // スコア表示
                VStack(spacing: 4) {
                    Text("FINAL SCORE")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    Text(String(format: "%06d", score))
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }

                // リトライボタン
                Button(action: onRestart) {
                    Text("RETRY")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 56)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().fill(Color.cyan)
                        )
                }
            }
            .opacity(appear ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appear = true
                }
            }
        }
    }
}

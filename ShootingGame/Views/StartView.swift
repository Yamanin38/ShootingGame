// StartView.swift
// ShootingGame - タイトル / スタート画面

import SwiftUI

/// ゲーム開始前のタイトル画面
struct StartView: View {

    let onStart: () -> Void

    @State private var pulse = false

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.02, blue: 0.12),
                         Color(red: 0.06, green: 0.04, blue: 0.20)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // タイトル
                VStack(spacing: 8) {
                    Text("SPACE")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("SHOOTER")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .shadow(color: .cyan.opacity(0.6), radius: 20)

                // サブタイトル
                Text("Touch anywhere to move your ship")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)

                Spacer()

                // スタートボタン
                Button(action: onStart) {
                    Text("TAP TO START")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.cyan)
                                .shadow(color: .cyan.opacity(0.7), radius: pulse ? 20 : 8)
                        )
                        .scaleEffect(pulse ? 1.04 : 1.0)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }

                Spacer().frame(height: 60)
            }
        }
    }
}

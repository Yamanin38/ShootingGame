// HUDView.swift
// ShootingGame - スコア・弾数などのゲーム内 HUD

import SwiftUI

/// ゲームプレイ中のヘッドアップディスプレイ
struct HUDView: View {

    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack {
            // ---- 上部: スコア ----
            HStack {
                Text("SCORE")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan.opacity(0.8))
                Text(String(format: "%06d", viewModel.score))
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()

            // ---- 下部: 弾数インジケーター ----
            bulletCountIndicator
                .padding(.bottom, 16)
        }
    }

    // MARK: - 弾数インジケーター

    private var bulletCountIndicator: some View {
        HStack(spacing: 8) {
            Text("SHOT")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
            HStack(spacing: 5) {
                ForEach(0..<GameConfig.maxBulletCount, id: \.self) { i in
                    Image(systemName: i < viewModel.bulletCount ? "diamond.fill" : "diamond")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(i < viewModel.bulletCount ? .yellow : .gray.opacity(0.4))
                        .scaleEffect(i < viewModel.bulletCount ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: viewModel.bulletCount)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

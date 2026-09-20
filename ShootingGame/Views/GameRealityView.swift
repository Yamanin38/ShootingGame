// GameRealityView.swift
// ShootingGame - ARView の UIViewRepresentable ラッパーとゲームシーン構築

import SwiftUI
import RealityKit
import UIKit

/// RealityKit の ARView を SwiftUI に統合するビュー
struct GameRealityView: UIViewRepresentable {

    @ObservedObject var viewModel: GameViewModel

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> ARView {
        // ---- ARView 作成 (非AR モード) ----
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.renderOptions = [.disableMotionBlur, .disableFaceOcclusions]
        arView.environment.background = .color(UIColor(red: 0.03, green: 0.03, blue: 0.10, alpha: 1.0))

        // ---- カメラ設定 (真上から見下ろす) ----
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = GameConfig.cameraFOV
        let cameraAnchor = AnchorEntity(world: .zero)
        // Y 軸上に配置して X を -90° 回転 → 真下を向く
        cameraAnchor.position    = SIMD3<Float>(0, GameConfig.cameraHeight, 0)
        cameraAnchor.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)

        // ---- ゲームシーン ルートアンカー ----
        let sceneAnchor = AnchorEntity(world: .zero)
        arView.scene.addAnchor(sceneAnchor)
        viewModel.sceneAnchor = sceneAnchor

        // ---- 環境光 ----
        var dl = DirectionalLightComponent()
        dl.color     = UIColor(white: 1.0, alpha: 1.0)
        dl.intensity = 2000
        let dirLightEnt = Entity()
        dirLightEnt.components.set(dl)
        dirLightEnt.orientation = simd_quatf(angle: -.pi / 3, axis: [1, 0, 0])
        sceneAnchor.addChild(dirLightEnt)

        // ---- 星フィールド ----
        StarfieldEffect.attach(to: sceneAnchor)

        // ---- 自機の生成 ----
        let playerEnt = PlayerEntity.make()
        playerEnt.position = GameConfig.playerStartPosition
        sceneAnchor.addChild(playerEnt)
        viewModel.playerEntity = playerEnt

        // ---- スラスターエフェクト ----
        ThrusterEffect.attach(to: playerEnt, offsetZ: 0.65)

        // ---- タッチジェスチャー登録 ----
        context.coordinator.setup(arView: arView, viewModel: viewModel)

        // ---- ゲームループの構築 ----
        buildGameLoop(viewModel: viewModel)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: - ゲームループ構築

    private func buildGameLoop(viewModel: GameViewModel) {
        let effectManager    = EffectManager()
        let bulletSystem     = BulletSystem()
        let enemySpawnSystem = EnemySpawnSystem()
        let enemyAISystem    = EnemyAISystem(bulletSystem: bulletSystem)
        let collisionSystem  = CollisionSystem(effectManager: effectManager)
        let upgradeSystem    = UpgradeSystem()

        let loop = GameLoop(
            viewModel:        viewModel,
            bulletSystem:     bulletSystem,
            enemySpawnSystem: enemySpawnSystem,
            enemyAISystem:    enemyAISystem,
            collisionSystem:  collisionSystem,
            upgradeSystem:    upgradeSystem
        )
        viewModel.bindGameLoop(loop)
    }

    // MARK: - Coordinator (タッチ処理)

    @MainActor
    final class Coordinator: NSObject {

        private weak var viewModel: GameViewModel?
        private weak var arView: ARView?
        private var screenSize: CGSize = .zero

        func setup(arView: ARView, viewModel: GameViewModel) {
            self.arView    = arView
            self.viewModel = viewModel

            // 移動 (ドラッグ)
            let drag = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            drag.maximumNumberOfTouches = 1
            arView.addGestureRecognizer(drag)

            // 初期タッチ (長押し開始)
            let press = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
            press.minimumPressDuration = 0
            press.require(toFail: drag)
            arView.addGestureRecognizer(press)
        }

        @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
            updatePlayerTarget(from: gr.location(in: gr.view), view: gr.view)
        }

        @objc private func handlePress(_ gr: UILongPressGestureRecognizer) {
            updatePlayerTarget(from: gr.location(in: gr.view), view: gr.view)
        }

        private func updatePlayerTarget(from point: CGPoint, view: UIView?) {
            guard let view = view, let vm = viewModel else { return }
            let size = view.bounds.size
            vm.playerTargetPosition = CoordinateConverter.worldPosition(
                from: point,
                screenSize: size
            )
        }
    }
}

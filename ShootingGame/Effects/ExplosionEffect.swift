// ExplosionEffect.swift
import RealityKit
import UIKit

@MainActor
final class EffectManager {

    private let glowTexture  = EffectManager.makeTexture(stops: [(0, 1.0), (0.35, 0.55), (1, 0)])
    private let sparkTexture = EffectManager.makeTexture(stops: [(0, 1.0), (0.5, 0.9), (1, 0)])
    private let ringTexture  = EffectManager.makeTexture(stops: [(0, 0), (0.7, 0), (0.88, 1.0), (1, 0)])

    /// 爆発全体の寿命 (最長レイヤーの終了より少し長く)
    private let lifetime: TimeInterval = 1.0

    // MARK: - 爆発本体

    func spawnExplosion(at position: SIMD3<Float>, anchor: AnchorEntity, scale: Float = 1.0) {
        let root = Entity()
        root.position = position
        root.scale = SIMD3<Float>(repeating: scale)
        anchor.addChild(root)

        addFlash(to: root)
        addShockwave(to: root)
        addFireball(to: root)
        addSparks(to: root)
        addSmoke(to: root)
        addDebris(to: root)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(lifetime))
            root.removeFromParent()
        }
    }

    // MARK: - レイヤー
    // 各エミッターは「emissionDuration の間に birthRate 個だけ出して終わり」(ループしない)

    /// ① 閃光
    private func addFlash(to parent: Entity) {
        addEmitter(to: parent) { p in
          p.timing = .once(warmUp: 0, emit: .init(duration: 0.04))
            p.emitterShape = .point
            p.speed = 0
            p.mainEmitter.birthRate = 4
            p.mainEmitter.lifeSpan = 0.12
            p.mainEmitter.size = 2.2
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 1.5
            p.mainEmitter.image = self.glowTexture
            p.mainEmitter.blendMode = .additive
            p.mainEmitter.color = .constant(.single(UIColor(red: 1.0, green: 0.95, blue: 0.75, alpha: 1)))
            p.mainEmitter.opacityCurve = .linearFadeOut
        }
    }

    /// ② 衝撃波リング
    private func addShockwave(to parent: Entity) {
        addEmitter(to: parent) { p in
          p.timing = .once(warmUp: 0, emit: .init(duration: 0.03))
            p.emitterShape = .point
            p.speed = 0
            p.mainEmitter.birthRate = 3
            p.mainEmitter.lifeSpan = 0.28
            p.mainEmitter.size = 0.5
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 7.0
            p.mainEmitter.image = self.ringTexture
            p.mainEmitter.blendMode = .additive
            p.mainEmitter.color = .constant(.single(UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1)))
            p.mainEmitter.opacityCurve = .linearFadeOut
        }
    }

    /// ③ 火球
    private func addFireball(to parent: Entity) {
        addEmitter(to: parent) { p in
          p.timing = .once(warmUp: 0, emit: .init(duration: 0.08))
            p.emitterShape = .sphere
            p.emitterShapeSize = SIMD3<Float>(repeating: 0.4)   // 縦横比を揃える
            p.birthLocation = .volume
            p.birthDirection = .normal
            p.speed = 2.2
            p.speedVariation = 0.5
            p.mainEmitter.birthRate = 24
            p.mainEmitter.lifeSpan = 0.38
            p.mainEmitter.lifeSpanVariation = 0.05
            p.mainEmitter.size = 0.9
            p.mainEmitter.sizeVariation = 0.1
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 1.7
            p.mainEmitter.dampingFactor = 4
            p.mainEmitter.image = self.glowTexture
            p.mainEmitter.blendMode = .additive
            p.mainEmitter.color = .evolving(
                start: .single(UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1)),
                end:   .single(UIColor(red: 0.9, green: 0.2, blue: 0.0, alpha: 1)))
            p.mainEmitter.opacityCurve = .linearFadeOut
        }
    }

    /// ④ 火花
    private func addSparks(to parent: Entity) {
        addEmitter(to: parent) { p in
          p.timing = .once(warmUp: 0, emit: .init(duration: 0.05))
            p.emitterShape = .sphere
            p.emitterShapeSize = SIMD3<Float>(repeating: 0.1)
            p.birthDirection = .normal
            p.speed = 7
            p.speedVariation = 1.5
            p.mainEmitter.birthRate = 36
            p.mainEmitter.lifeSpan = 0.35
            p.mainEmitter.lifeSpanVariation = 0.08
            p.mainEmitter.size = 0.14
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 0.2
            p.mainEmitter.dampingFactor = 2.5
            p.mainEmitter.image = self.sparkTexture
            p.mainEmitter.blendMode = .additive
            p.mainEmitter.color = .evolving(
                start: .single(UIColor(red: 1.0, green: 0.95, blue: 0.6, alpha: 1)),
                end:   .single(UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1)))
            p.mainEmitter.opacityCurve = .linearFadeOut
        }
    }

    /// ⑤ 煙
    private func addSmoke(to parent: Entity) {
        addEmitter(to: parent) { p in
          p.timing = .once(warmUp: 0, emit: .init(duration: 0.1))
            p.emitterShape = .sphere
            p.emitterShapeSize = SIMD3<Float>(repeating: 0.4)
            p.birthLocation = .volume
            p.birthDirection = .normal
            p.speed = 0.7
            p.mainEmitter.birthRate = 10
            p.mainEmitter.lifeSpan = 0.7
            p.mainEmitter.lifeSpanVariation = 0.1
            p.mainEmitter.size = 0.9
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 2.0
            p.mainEmitter.dampingFactor = 2
            p.mainEmitter.image = self.glowTexture
            p.mainEmitter.blendMode = .alpha
            p.mainEmitter.color = .constant(.single(UIColor(white: 0.12, alpha: 0.55)))
            p.mainEmitter.opacityCurve = .linearFadeOut
        }
    }

    /// ⑥ 破片 (毎回同じ配置・同じ大きさ。全体の向きだけランダム)
    private func addDebris(to parent: Entity) {
        let mat = UnlitMaterial(color: UIColor(red: 1.0, green: 0.55, blue: 0.15, alpha: 1))
        let mesh = MeshResource.generateBox(size: 0.2)
        let count = 8
        let baseAngle = Float.random(in: 0..<(2 * .pi))

        for i in 0..<count {
            let piece = ModelEntity(mesh: mesh, materials: [mat])
            parent.addChild(piece)

            let angle = baseAngle + Float(i) / Float(count) * 2 * .pi
            var target = piece.transform
            target.translation += SIMD3<Float>(cos(angle), 0, sin(angle)) * 2.4
            target.scale = SIMD3<Float>(repeating: 0.01)
            target.rotation = simd_quatf(angle: .pi * 0.8, axis: simd_normalize(SIMD3<Float>(1, Float(i % 3) + 1, 0.5)))
            piece.move(to: target, relativeTo: parent, duration: 0.5, timingFunction: .easeOut)
        }
    }

    // MARK: - ヘルパー

    /// 共通設定: ループさせない・速度方向に伸ばさない
    private func addEmitter(to parent: Entity, configure: (inout ParticleEmitterComponent) -> Void) {
        var p = ParticleEmitterComponent()
        p.mainEmitter.stretchFactor = 0
        configure(&p)
        let e = Entity()
        e.components.set(p)
        parent.addChild(e)
    }

    private static func makeTexture(stops: [(CGFloat, CGFloat)]) -> TextureResource? {
        let size = 128
        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                                  bytesPerRow: 0, space: cs,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let gradient = CGGradient(
                colorsSpace: cs,
                colors: stops.map { UIColor(white: 1, alpha: $0.1).cgColor } as CFArray,
                locations: stops.map { $0.0 })
        else { return nil }
        let c = CGPoint(x: size / 2, y: size / 2)
        ctx.drawRadialGradient(gradient, startCenter: c, startRadius: 0,
                               endCenter: c, endRadius: CGFloat(size) / 2, options: [])
        guard let image = ctx.makeImage() else { return nil }
        return try? TextureResource(image: image, options: .init(semantic: .color))
    }
}

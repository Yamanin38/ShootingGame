// ExplosionEffect.swift
import RealityKit
import UIKit

@MainActor
final class EffectManager {

    // 起動時に1回だけ生成してキャッシュ
    private let glowTexture  = EffectManager.makeTexture(stops: [(0, 1.0), (0.35, 0.55), (1, 0)])
    private let sparkTexture = EffectManager.makeTexture(stops: [(0, 1.0), (0.5, 0.9), (1, 0)])
    private let ringTexture  = EffectManager.makeTexture(stops: [(0, 0), (0.7, 0), (0.88, 1.0), (1, 0)])

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
            try? await Task.sleep(for: .seconds(1.8))
            root.removeFromParent()
        }
    }

    // MARK: - 各レイヤー

    /// ① 閃光: 一瞬だけ出る大きな白黄色の光 (PointLight の代わり)
    private func addFlash(to parent: Entity) {
        addEmitter(to: parent, duration: 0.03) { p in
            p.emitterShape = .point
            p.speed = 0
            p.mainEmitter.birthRate = 60
            p.mainEmitter.lifeSpan = 0.14
            p.mainEmitter.size = 2.6
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 1.6
            p.mainEmitter.image = self.glowTexture
            p.mainEmitter.blendMode = .additive
            p.mainEmitter.color = .constant(.single(UIColor(red: 1.0, green: 0.95, blue: 0.75, alpha: 1)))
            p.mainEmitter.opacityCurve = .linearFadeOut
        }
    }

    /// ② 衝撃波リング: 1粒だけ出して一気に拡大
    private func addShockwave(to parent: Entity) {
        addEmitter(to: parent, duration: 0.03) { p in
            p.emitterShape = .point
            p.speed = 0
            p.mainEmitter.birthRate = 40
            p.mainEmitter.lifeSpan = 0.35
            p.mainEmitter.size = 0.5
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 7.0
            p.mainEmitter.image = self.ringTexture
            p.mainEmitter.blendMode = .additive
            p.mainEmitter.color = .constant(.single(UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1)))
            p.mainEmitter.opacityCurve = .linearFadeOut
        }
    }

    /// ③ 火球: 黄白 → 橙 → 暗赤へ変化しながら膨らむ
    private func addFireball(to parent: Entity) {
        addEmitter(to: parent, duration: 0.10) { p in
            p.emitterShape = .sphere
            p.emitterShapeSize = SIMD3<Float>(0.5, 0.2, 0.5)
            p.birthLocation = .volume
            p.birthDirection = .normal
            p.speed = 2.5
            p.speedVariation = 1.0
            p.mainEmitter.birthRate = 300
            p.mainEmitter.lifeSpan = 0.55
            p.mainEmitter.lifeSpanVariation = 0.15
            p.mainEmitter.size = 1.0
            p.mainEmitter.sizeVariation = 0.4
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 1.8
            p.mainEmitter.dampingFactor = 4
            p.mainEmitter.image = self.glowTexture
            p.mainEmitter.blendMode = .additive
            p.mainEmitter.color = .evolving(
                start: .single(UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1)),
                end:   .single(UIColor(red: 0.9, green: 0.2, blue: 0.0, alpha: 1)))
            p.mainEmitter.opacityCurve = .linearFadeOut
        }
    }

    /// ④ 火花: 小さく速い粒が四方に飛ぶ
    private func addSparks(to parent: Entity) {
        addEmitter(to: parent, duration: 0.06) { p in
            p.emitterShape = .sphere
            p.emitterShapeSize = SIMD3<Float>(0.2, 0.2, 0.2)
            p.birthDirection = .normal
            p.speed = 8
            p.speedVariation = 4
            p.mainEmitter.birthRate = 400
            p.mainEmitter.lifeSpan = 0.5
            p.mainEmitter.lifeSpanVariation = 0.2
            p.mainEmitter.size = 0.16
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

    /// ⑤ 煙: 通常のアルファ合成で暗く、ゆっくり残る
    private func addSmoke(to parent: Entity) {
        addEmitter(to: parent, duration: 0.2) { p in
            p.emitterShape = .sphere
            p.emitterShapeSize = SIMD3<Float>(0.6, 0.2, 0.6)
            p.birthLocation = .volume
            p.birthDirection = .normal
            p.speed = 0.8
            p.speedVariation = 0.4
            p.mainEmitter.birthRate = 45
            p.mainEmitter.lifeSpan = 1.1
            p.mainEmitter.lifeSpanVariation = 0.3
            p.mainEmitter.size = 0.9
            p.mainEmitter.sizeVariation = 0.3
            p.mainEmitter.sizeMultiplierAtEndOfLifespan = 2.2
            p.mainEmitter.dampingFactor = 2
            p.mainEmitter.image = self.glowTexture
            p.mainEmitter.blendMode = .alpha
            p.mainEmitter.color = .constant(.single(UIColor(white: 0.12, alpha: 0.55)))
          p.mainEmitter.opacityCurve = .gradualFadeInOut
        }
    }

    /// ⑥ 破片: 回転しながら飛んで縮む
    private func addDebris(to parent: Entity) {
        let mat = UnlitMaterial(color: UIColor(red: 1.0, green: 0.55, blue: 0.15, alpha: 1))
        for i in 0..<10 {
            let size = Float.random(in: 0.12...0.3)
            let mesh = MeshResource.generateBox(size: size)
            let piece = ModelEntity(mesh: mesh, materials: [mat])
            parent.addChild(piece)

            let angle = (Float(i) / 10 + Float.random(in: -0.05...0.05)) * 2 * .pi
            let dir = SIMD3<Float>(cos(angle), 0, sin(angle))
            var target = piece.transform
            target.translation += dir * Float.random(in: 1.8...4.0)
            target.scale = SIMD3<Float>(repeating: 0.01)
            target.rotation = simd_quatf(angle: .pi * Float.random(in: 0.6...1.0),
                                         axis: simd_normalize(SIMD3<Float>.random(in: -1...1)))
            piece.move(to: target, relativeTo: parent,
                       duration: Double.random(in: 0.5...0.9), timingFunction: .easeOut)
        }
    }

    // MARK: - ヘルパー

    /// エミッターを1つ作り、duration 秒だけ放出して止める
    private func addEmitter(to parent: Entity, duration: TimeInterval,
                            configure: (inout ParticleEmitterComponent) -> Void) {
        var p = ParticleEmitterComponent()
        configure(&p)
        let e = Entity()
        e.components.set(p)
        parent.addChild(e)
        Task { @MainActor [weak e] in
            try? await Task.sleep(for: .seconds(duration))
            e?.components[ParticleEmitterComponent.self]?.isEmitting = false
        }
    }

    /// 白の放射状グラデーション (alpha だけ変化) をコードで生成
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

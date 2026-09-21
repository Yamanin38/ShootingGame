// PostProcessor.swift
// ShootingGame - RealityKit 描画結果へのポストプロセス (ブルーム / ビネット / 色調整)

import RealityKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// ARView.renderCallbacks.postProcess から毎フレーム呼ばれる
/// (フィルターと CIContext は使い回して負荷を抑える)
final class PostProcessor {

    private let ciContext = CIContext()
    private let bloom = CIFilter.bloom()
    private let vignette = CIFilter.vignette()
    private let colorGrade = CIFilter.colorControls()

    init() {
        bloom.radius = 14        // にじみの広さ
        bloom.intensity = 0.7    // 光の強さ (0〜1)

        vignette.intensity = 0.6 // 周辺減光
        vignette.radius = 1.5

        colorGrade.saturation = 1.12
        colorGrade.contrast = 1.06
        colorGrade.brightness = 0
    }

    func apply(_ context: ARView.PostProcessContext) {
        // Metal テクスチャは上下が逆なので .downMirrored で向きを合わせる
        guard let base = CIImage(mtlTexture: context.sourceColorTexture, options: nil)?
            .oriented(.downMirrored) else { return }
        let extent = base.extent

        bloom.inputImage = base
        guard let bloomed = bloom.outputImage?.cropped(to: extent) else { return }

        vignette.inputImage = bloomed
        guard let vignetted = vignette.outputImage?.cropped(to: extent) else { return }

        colorGrade.inputImage = vignetted
        guard let result = colorGrade.outputImage?.cropped(to: extent) else { return }

        let destination = CIRenderDestination(
            mtlTexture: context.targetColorTexture,
            commandBuffer: context.commandBuffer)
        _ = try? ciContext.startTask(toRender: result, to: destination)
    }
}

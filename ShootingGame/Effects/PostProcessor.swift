// PostProcessor.swift
// 軽量ブルーム: 1/4 解像度で 明部抽出 → ぼかし → 元画像へ加算 (MPS のみ、CPU 負荷ほぼなし)

import RealityKit
import Metal
import MetalPerformanceShaders

final class PostProcessor {

    private var threshold: MPSImageThresholdToZero?
    private var blur: MPSImageGaussianBlur?
    private var scale: MPSImageBilinearScale?
    private var add: MPSImageAdd?

    private var half: MTLTexture?
    private var quarter: MTLTexture?
    private var work: MTLTexture?
    private var full: MTLTexture?
    private var cachedSize = (w: 0, h: 0)

    // 調整パラメータ
    private let brightThreshold: Float = 0.5   // これより明るい部分が光る
    private let blurSigma: Float = 3.0         // 1/4 解像度上でのぼかし量
    private let intensity: Float = 0.6         // 加算の強さ

    func apply(_ context: ARView.PostProcessContext) {
        let src = context.sourceColorTexture
        let dst = context.targetColorTexture
        let cb = context.commandBuffer

        prepareIfNeeded(device: context.device, width: src.width, height: src.height)

        guard let threshold, let blur, let scale, let add,
              let half, let quarter, let work, let full else {
            copy(src, to: dst, cb)   // 失敗時も画面が真っ黒にならないよう素通し
            return
        }

        scale.encode(commandBuffer: cb, sourceTexture: src, destinationTexture: half)      // 1/2
        scale.encode(commandBuffer: cb, sourceTexture: half, destinationTexture: quarter)  // 1/4
        threshold.encode(commandBuffer: cb, sourceTexture: quarter, destinationTexture: work)
        blur.encode(commandBuffer: cb, sourceTexture: work, destinationTexture: quarter)
        scale.encode(commandBuffer: cb, sourceTexture: quarter, destinationTexture: full)  // 拡大
        add.encode(commandBuffer: cb, primaryTexture: src, secondaryTexture: full, destinationTexture: dst)
    }

    // MARK: - 準備

    private func prepareIfNeeded(device: MTLDevice, width: Int, height: Int) {
        if cachedSize == (width, height), threshold != nil { return }
        cachedSize = (width, height)

        threshold = MPSImageThresholdToZero(device: device, thresholdValue: brightThreshold, linearGrayColorTransform: nil)
        blur = MPSImageGaussianBlur(device: device, sigma: blurSigma)
        scale = MPSImageBilinearScale(device: device)
        let a = MPSImageAdd(device: device)
        a.primaryScale = 1.0
        a.secondaryScale = intensity
        add = a

        half    = makeTexture(device, width / 2, height / 2)
        quarter = makeTexture(device, width / 4, height / 4)
        work    = makeTexture(device, width / 4, height / 4)
        full    = makeTexture(device, width, height)
    }

    private func makeTexture(_ device: MTLDevice, _ w: Int, _ h: Int) -> MTLTexture? {
        let d = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba16Float, width: max(w, 1), height: max(h, 1), mipmapped: false)
        d.usage = [.shaderRead, .shaderWrite]
        d.storageMode = .private
        return device.makeTexture(descriptor: d)
    }

    private func copy(_ src: MTLTexture, to dst: MTLTexture, _ cb: MTLCommandBuffer) {
        guard let blit = cb.makeBlitCommandEncoder() else { return }
        blit.copy(from: src, to: dst)
        blit.endEncoding()
    }
}

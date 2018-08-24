//
//  StarfieldBuilder.swift
//  SolarSystem2
//

import Foundation
import CoreGraphics
import SceneKit

final class StarfieldBuilder {

    let moduleName = (#file).components(separatedBy: "/")

    private struct BackgroundTextures {
        // Bit 0: decorative stars; bit 1: Milky Way; bit 2: zodiac figures.
        let images: [Int: CGImage]
    }

    private struct Star {
        let longitude: Double
        let latitude: Double
        let radius: Double
        let brightness: Double
        let warmth: Double
    }

    private struct RandomGenerator {
        private var state: UInt64 = 0x534F4C4152534B59

        mutating func next() -> Double {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Double(state >> 11) / 9007199254740992.0
        }
    }

    private let scene: SCNScene
    private var isActive = false
    private var starsVisible = true
    private var milkyWayVisible = true
    private var zodiacVisible = true
    private var backgroundTextures: BackgroundTextures?

    // Generated once, off the main thread, and reused after scene resets.
    private static let cachedTextures = createTextures()

    init(scene: SCNScene) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        self.scene = scene
    }

    // ============================================================
    // MARK: - BUILD
    // ============================================================

    func build() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        isActive = true

        DispatchQueue.global(qos: .userInitiated).async {
            let textures = Self.cachedTextures

            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.isActive else { return }

                self.backgroundTextures = textures
                self.applyDisplaySettings()

                if textures == nil {
                    printLog("Star field texture creation failed; keeping a black background.")
                }
            }
        }
    }

    // ============================================================
    // MARK: - DISPLAY CONTROLS
    // ============================================================

    func setStarsVisible(_ visible: Bool) {
        starsVisible = visible
        applyDisplaySettings()
    }

    func setMilkyWayVisible(_ visible: Bool) {
        milkyWayVisible = visible
        applyDisplaySettings()
    }

    func setZodiacVisible(_ visible: Bool) {
        zodiacVisible = visible
        applyDisplaySettings()
    }

    private func applyDisplaySettings() {
        guard isActive else { return }

        // SceneKit accepts a 2:1 latitude/longitude image as a sky background.
        // The sky responds to camera rotation without nearby-object parallax.
        // It is not a light source and does not add geometry to hit testing.
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0

        let key = (starsVisible ? 1 : 0)
            | (milkyWayVisible ? 2 : 0)
            | (zodiacVisible ? 4 : 0)

        if let image = backgroundTextures?.images[key] {
            scene.background.contents = image
        } else {
            scene.background.contents = CGColor(gray: 0, alpha: 1)
        }

        SCNTransaction.commit()
    }

    // ============================================================
    // MARK: - PROCEDURAL SKY
    // ============================================================

    private static func createTextures() -> BackgroundTextures? {

        // An illustrative sky, not a star catalogue or an Earth-location sky map.
        let width = 2048
        let height = 1024
        let stars = createStars()

        guard let haze = createMilkyWay(),
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else {
            return nil
        }

        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        var images: [Int: CGImage] = [:]
        context.interpolationQuality = .high

        // Cache all seven non-black combinations. No drawing is done per frame
        // or when a switch changes. The existing three backgrounds stay intact.
        for key in 1...7 {
            context.setFillColor(CGColor(gray: 0, alpha: 1))
            context.fill(bounds)

            if key & 2 != 0 {
                context.draw(haze, in: bounds)
            }

            if key & 1 != 0 {
                drawStars(stars, in: context, width: width, height: height)
            }

            if key & 4 != 0 {
                ZodiacConstellations.draw(in: context, width: width, height: height)
            }

            guard let image = context.makeImage() else { return nil }
            images[key] = image
        }

        return BackgroundTextures(images: images)
    }

    private static func createStars() -> [Star] {

        var random = RandomGenerator()
        var stars: [Star] = []
        stars.reserveCapacity(3500)

        for _ in 0..<3500 {
            let longitude = random.next() * 2.0 * Double.pi
            // Uniform solid-angle distribution avoids crowded polar regions.
            let latitude = asin(2.0 * random.next() - 1.0)
            let brightness = pow(random.next(), 3.0)

            stars.append(
                Star(
                    longitude: longitude,
                    latitude: latitude,
                    radius: 0.35 + brightness * 0.85,
                    brightness: 0.22 + brightness * 0.73,
                    warmth: random.next()
                )
            )
        }

        return stars
    }

    private static func drawStars(
        _ stars: [Star],
        in context: CGContext,
        width: Int,
        height: Int
    ) {

        for star in stars {
            let x = star.longitude / (2.0 * Double.pi) * Double(width)
            let y = (star.latitude / Double.pi + 0.5) * Double(height)
            let radiusY = star.radius
            let radiusX = radiusY / max(0.025, cos(star.latitude))

            let red = star.warmth < 0.3 ? 0.78 : 1.0
            let green = star.warmth > 0.75 ? 0.87 : 0.94
            let blue = star.warmth > 0.75 ? 0.72 : 1.0

            // Wrap stars across the panorama seam, including their soft halos.
            for offset in [-Double(width), 0, Double(width)] {
                let centreX = x + offset
                guard centreX + radiusX * 3 >= 0,
                      centreX - radiusX * 3 <= Double(width)
                else { continue }

                if star.brightness > 0.72 {
                    context.setFillColor(
                        CGColor(red: red, green: green, blue: blue, alpha: 0.06)
                    )
                    context.fillEllipse(in: CGRect(
                        x: centreX - radiusX * 3,
                        y: y - radiusY * 3,
                        width: radiusX * 6,
                        height: radiusY * 6
                    ))
                }

                context.setFillColor(
                    CGColor(red: red, green: green, blue: blue, alpha: star.brightness)
                )
                context.fillEllipse(in: CGRect(
                    x: centreX - radiusX,
                    y: y - radiusY,
                    width: radiusX * 2,
                    height: radiusY * 2
                ))
            }
        }
    }

    private static func createMilkyWay() -> CGImage? {

        let width = 1024
        let height = 512
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for row in 0..<height {
            let latitude = (Double(row) + 0.5) / Double(height) * Double.pi - Double.pi / 2
            let cosLatitude = cos(latitude)
            let y = sin(latitude)

            for column in 0..<width {
                let longitude = (Double(column) + 0.5) / Double(width) * 2 * Double.pi
                let x = cosLatitude * cos(longitude)
                let z = cosLatitude * sin(longitude)

                // A tilted great-circle band, sampled in 3D to avoid a seam.
                let distance = x * 0.48 + y * 0.64 + z * 0.60
                let broadBand = exp(-pow(distance / 0.19, 2))
                let narrowBand = exp(-pow(distance / 0.075, 2))
                let clouds = 0.62
                    + 0.18 * sin(13 * x + 9 * y - 7 * z)
                    + 0.12 * sin(31 * x - 17 * y + 23 * z)
                    + 0.08 * sin(67 * x + 43 * y - 51 * z)
                let laneOffset = 0.022 * sin(11 * x - 8 * z)
                let dustLane = exp(-pow((distance - laneOffset) / 0.018, 2))
                let glow = (0.035 * broadBand + 0.075 * narrowBand)
                    * clouds * (1.0 - 0.70 * dustLane)

                let index = (row * width + column) * 4
                pixels[index] = UInt8(min(255, max(0, glow * 0.85 * 255)))
                pixels[index + 1] = UInt8(min(255, max(0, glow * 0.90 * 255)))
                pixels[index + 2] = UInt8(min(255, max(0, glow * 255)))
                pixels[index + 3] = 255
            }
        }

        let data = Data(pixels)
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }

        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    }

    // ============================================================
    // MARK: - REMOVE
    // ============================================================

    func remove() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        isActive = false
        backgroundTextures = nil
        scene.background.contents = CGColor(gray: 0, alpha: 1)
    }
}

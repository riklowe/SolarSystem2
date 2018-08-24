//
//  EclipseShadowRenderer.swift
//  SolarSystem2
//

import Foundation
import SceneKit
import UIKit
import simd

final class EclipseShadowRenderer {

    let moduleName = (#file).components(separatedBy: "/")

    private weak var earthPlanetNode: SCNNode?
    private let earthRadius: CGFloat

    private let penumbraNode = SCNNode()
    private let penumbraPlane: SCNPlane

    private let umbraNode = SCNNode()
    private let umbraPlane: SCNPlane

    private let physicalEarthRadiusKM: Double = 6378.137

    init(
        earthPlanetNode: SCNNode,
        earthRadius: CGFloat
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        self.earthPlanetNode = earthPlanetNode
        self.earthRadius = earthRadius

        // All stored properties must be initialized
        // before calling instance methods.

        penumbraPlane = SCNPlane(
            width: earthRadius * 0.65,
            height: earthRadius * 0.65
        )

        umbraPlane = SCNPlane(
            width: earthRadius * 0.10,
            height: earthRadius * 0.10
        )

        // ========================================================
        // PENUMBRA
        // ========================================================

        configurePenumbraMaterial()

        penumbraNode.name = "solar_eclipse_penumbra"
        penumbraNode.geometry = penumbraPlane
        penumbraNode.renderingOrder = 150
        penumbraNode.isHidden = true

        earthPlanetNode.addChildNode(
            penumbraNode
        )

        // ========================================================
        // UMBRA
        // ========================================================

        configureUmbraMaterial()

        umbraNode.name = "solar_eclipse_umbra"
        umbraNode.geometry = umbraPlane
        umbraNode.renderingOrder = 151
        umbraNode.isHidden = true

        earthPlanetNode.addChildNode(
            umbraNode
        )
    }

    // ============================================================
    // MARK: - PENUMBRA MATERIAL
    // ============================================================

    private func configurePenumbraMaterial() {
        let material = SCNMaterial()

        material.diffuse.contents =
            createPenumbraTexture()

        material.transparency = 1.0
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.blendMode = .alpha
        material.readsFromDepthBuffer = true
        material.writesToDepthBuffer = false
        material.emission.contents = UIColor.clear
        material.ambient.contents = UIColor.clear

        penumbraPlane.materials = [
            material
        ]
    }

    // ============================================================
    // MARK: - UMBRA MATERIAL
    // ============================================================

    private func configureUmbraMaterial() {
        let material = SCNMaterial()

        material.diffuse.contents =
            createUmbraTexture()

        material.transparency = 1.0
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.blendMode = .alpha
        material.readsFromDepthBuffer = true
        material.writesToDepthBuffer = false
        material.emission.contents = UIColor.clear
        material.ambient.contents = UIColor.clear

        umbraPlane.materials = [
            material
        ]
    }

    // ============================================================
    // MARK: - PENUMBRA TEXTURE
    // ============================================================

    private func createPenumbraTexture() -> UIImage {
        let size = CGSize(
            width: 512,
            height: 512
        )

        let renderer =
            UIGraphicsImageRenderer(
                size: size
            )

        return renderer.image { context in
            let cgContext =
                context.cgContext

            cgContext.clear(
                CGRect(
                    origin: .zero,
                    size: size
                )
            )

            let colorSpace =
                CGColorSpaceCreateDeviceRGB()

            let colors: [CGColor] = [
                UIColor.black
                    .withAlphaComponent(0.68)
                    .cgColor,

                UIColor.black
                    .withAlphaComponent(0.52)
                    .cgColor,

                UIColor.black
                    .withAlphaComponent(0.28)
                    .cgColor,

                UIColor.black
                    .withAlphaComponent(0.10)
                    .cgColor,

                UIColor.black
                    .withAlphaComponent(0.00)
                    .cgColor
            ]

            let locations: [CGFloat] = [
                0.00,
                0.20,
                0.45,
                0.72,
                1.00
            ]

            guard let gradient =
                CGGradient(
                    colorsSpace: colorSpace,
                    colors: colors as CFArray,
                    locations: locations
                )
            else {
                return
            }

            let centre = CGPoint(
                x: size.width / 2.0,
                y: size.height / 2.0
            )

            cgContext.drawRadialGradient(
                gradient,
                startCenter: centre,
                startRadius: 0.0,
                endCenter: centre,
                endRadius: size.width / 2.0,
                options: [.drawsAfterEndLocation]
            )
        }
    }

    // ============================================================
    // MARK: - UMBRA TEXTURE
    // ============================================================

    private func createUmbraTexture() -> UIImage {
        let size = CGSize(
            width: 256,
            height: 256
        )

        let renderer =
            UIGraphicsImageRenderer(
                size: size
            )

        return renderer.image { context in
            let cgContext =
                context.cgContext

            cgContext.clear(
                CGRect(
                    origin: .zero,
                    size: size
                )
            )

            let colorSpace =
                CGColorSpaceCreateDeviceRGB()

            let colors: [CGColor] = [
                UIColor.black
                    .withAlphaComponent(0.98)
                    .cgColor,

                UIColor.black
                    .withAlphaComponent(0.96)
                    .cgColor,

                UIColor.black
                    .withAlphaComponent(0.82)
                    .cgColor,

                UIColor.black
                    .withAlphaComponent(0.38)
                    .cgColor,

                UIColor.black
                    .withAlphaComponent(0.00)
                    .cgColor
            ]

            let locations: [CGFloat] = [
                0.00,
                0.35,
                0.60,
                0.82,
                1.00
            ]

            guard let gradient =
                CGGradient(
                    colorsSpace: colorSpace,
                    colors: colors as CFArray,
                    locations: locations
                )
            else {
                return
            }

            let centre = CGPoint(
                x: size.width / 2.0,
                y: size.height / 2.0
            )

            cgContext.drawRadialGradient(
                gradient,
                startCenter: centre,
                startRadius: 0.0,
                endCenter: centre,
                endRadius: size.width / 2.0,
                options: [.drawsAfterEndLocation]
            )
        }
    }

    // ============================================================
    // MARK: - UPDATE
    // ============================================================

    func update(for date: Date) {
        guard
            earthPlanetNode != nil,
            let geometry =
                EclipseAstronomy.solarGeometry(
                    for: date
                ),
            let geographic =
                EclipseAstronomy.geographicShadowPosition(
                    for: date
                )
        else {
            penumbraNode.isHidden = true
            umbraNode.isHidden = true
            return
        }

        // --------------------------------------------------------
        // EARTH-FIXED SHADOW POSITION
        //
        // Geographic coordinates:
        //
        // latitude  + = north
        // longitude + = east
        //
        // This is the same local coordinate convention already
        // used by addGreenwichMarker() in SolarSystemBuilder.swift.
        // --------------------------------------------------------

        let latitude =
            Astronomy.radians(
                geographic.latitude
            )

        let longitude =
            Astronomy.radians(
                geographic.longitude
            )

        let direction =
            earthLocalDirection(
                latitude: latitude,
                longitude: longitude
            )

        // --------------------------------------------------------
        // PENUMBRA
        // --------------------------------------------------------

        let penumbraRadius =
            Float(
                earthRadius * 1.030
            )

        penumbraNode.simdPosition =
            direction *
            penumbraRadius

        penumbraNode.simdOrientation =
            simd_quatf(
                from: SIMD3<Float>(
                    0,
                    0,
                    1
                ),
                to: direction
            )

        penumbraPlane.width =
            earthRadius * 0.65

        penumbraPlane.height =
            earthRadius * 0.65

        penumbraNode.isHidden = false

        // --------------------------------------------------------
        // UMBRA
        // --------------------------------------------------------

        guard geometry.isTotal else {
            umbraNode.isHidden = true
            return
        }

        let umbraRadius =
            Float(
                earthRadius * 1.035
            )

        umbraNode.simdPosition =
            direction *
            umbraRadius

        umbraNode.simdOrientation =
            simd_quatf(
                from: SIMD3<Float>(
                    0,
                    0,
                    1
                ),
                to: direction
            )

        // Physical umbra diameter expressed relative to Earth.
        let physicalDiameterRatio =
            (
                geometry.umbraRadiusKM
                * 2.0
            )
            / physicalEarthRadiusKM

        // Real umbra would be extremely small at this AR scale.
        let exaggeratedDiameterRatio =
            physicalDiameterRatio
            * 4.0

        let minimumDisplayRatio =
            0.065

        let maximumDisplayRatio =
            0.18

        let displayRatio =
            max(
                minimumDisplayRatio,
                min(
                    maximumDisplayRatio,
                    exaggeratedDiameterRatio
                )
            )

        let displayedUmbraDiameter =
            earthRadius
            * CGFloat(
                displayRatio
            )

        umbraPlane.width =
            displayedUmbraDiameter

        umbraPlane.height =
            displayedUmbraDiameter

        umbraNode.isHidden = false
    }

    // ============================================================
    // MARK: - EARTH LOCAL DIRECTION
    // ============================================================

    private func earthLocalDirection(
        latitude: Double,
        longitude: Double
    ) -> SIMD3<Float> {

        let x =
            cos(latitude)
            * sin(longitude)

        let y =
            sin(latitude)

        let z =
            cos(latitude)
            * cos(longitude)

        return simd_normalize(
            SIMD3<Float>(
                Float(x),
                Float(y),
                Float(z)
            )
        )
    }

    // ============================================================
    // MARK: - REMOVE
    // ============================================================

    func remove() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        penumbraNode.removeFromParentNode()
        umbraNode.removeFromParentNode()
    }
}

//
//  VanAllenBeltBuilder.swift
//  SolarSystem2
//

import Foundation
import SceneKit
import UIKit
import simd

final class VanAllenBeltBuilder {

    let moduleName = (#file).components(separatedBy: "/")

    private weak var earthPlanetNode: SCNNode?
    private let earthRadius: CGFloat

    private let beltRootNode = SCNNode()

    // ============================================================
    // MARK: - SIMPLIFIED GEOMAGNETIC AXIS
    // ============================================================

    private let magneticAxisTiltDegrees: Double = 11.0
    private let magneticAxisLongitudeDegrees: Double = -72.0

    init(
        earthPlanetNode: SCNNode,
        earthRadius: CGFloat
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        self.earthPlanetNode = earthPlanetNode
        self.earthRadius = earthRadius
    }

    // ============================================================
    // MARK: - BUILD
    // ============================================================

    func build() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        guard let earthPlanetNode else {
            return
        }

        beltRootNode.name = "van_allen_belts"

        beltRootNode.simdOrientation = simd_quatf(
            from: SIMD3<Float>(0, 1, 0),
            to: magneticAxisDirection()
        )

        // --------------------------------------------------------
        // INNER BELT
        //
        // Approximate visual extent:
        // 1.5 - 2.5 Earth radii from Earth's centre.
        // --------------------------------------------------------

        // --------------------------------------------------------
        // INNER BELT
        // --------------------------------------------------------

        let innerMain = createPointCloud(
            name: "van_allen_inner_main",
            majorRadius: earthRadius * 2.00,
            pipeRadius: earthRadius * 0.45,
            pointCount: 1200,
            pointSize: 1.8,
            minimumPointSize: 0.9,
            colour: UIColor.systemOrange.withAlphaComponent(0.65),
            seed: 1101
        )

        beltRootNode.addChildNode(innerMain)

        let innerHalo = createPointCloud(
            name: "van_allen_inner_halo",
            majorRadius: earthRadius * 2.00,
            pipeRadius: earthRadius * 0.65,
            pointCount: 450,
            pointSize: 1.2,
            minimumPointSize: 0.6,
            colour: UIColor.systemOrange.withAlphaComponent(0.20),
            seed: 1102
        )

        beltRootNode.addChildNode(innerHalo)


        // --------------------------------------------------------
        // OUTER BELT
        // --------------------------------------------------------

        let outerMain = createPointCloud(
            name: "van_allen_outer_main",
            majorRadius: earthRadius * 4.60,
            pipeRadius: earthRadius * 1.10,
            pointCount: 1600,
            pointSize: 1.8,
            minimumPointSize: 0.9,
            colour: UIColor.systemCyan.withAlphaComponent(0.70),
            seed: 2201
        )

        beltRootNode.addChildNode(outerMain)

        let outerHalo = createPointCloud(
            name: "van_allen_outer_halo",
            majorRadius: earthRadius * 4.60,
            pipeRadius: earthRadius * 1.45,
            pointCount: 600,
            pointSize: 1.2,
            minimumPointSize: 0.6,
            colour: UIColor.systemCyan.withAlphaComponent(0.22),
            seed: 2202
        )

        beltRootNode.addChildNode(outerHalo)

        earthPlanetNode.addChildNode(beltRootNode)
    }

    // ============================================================
    // MARK: - STATIC TOROIDAL POINT CLOUD
    // ============================================================

    private func createPointCloud(
        name: String,
        majorRadius: CGFloat,
        pipeRadius: CGFloat,
        pointCount: Int,
        pointSize: CGFloat,
        minimumPointSize: CGFloat,
        colour: UIColor,
        seed: UInt64
    ) -> SCNNode {

        var generator = VanAllenSeededGenerator(seed: seed)

        var vertices: [SCNVector3] = []
        vertices.reserveCapacity(pointCount)

        for _ in 0..<pointCount {

            // Angle around Earth.
            let majorAngle = randomUnit(&generator) * Double.pi * 2.0

            // Angle around torus cross-section.
            let minorAngle = randomUnit(&generator) * Double.pi * 2.0

            // sqrt() gives a more even distribution through
            // the circular cross-sectional area.
            let radialFraction = sqrt(randomUnit(&generator))

            let localPipeRadius = Double(pipeRadius) * radialFraction

            let radialDistance = Double(majorRadius) + localPipeRadius * cos(minorAngle)

            // SCNTorus convention: Y is the torus axis.
            let x = radialDistance * cos(majorAngle)
            let y = localPipeRadius * sin(minorAngle)
            let z = radialDistance * sin(majorAngle)

            vertices.append(
                SCNVector3(
                    Float(x),
                    Float(y),
                    Float(z)
                )
            )
        }

        let source = SCNGeometrySource(vertices: vertices)

        let indices = Array(
            0..<Int32(pointCount)
        )

        let element = SCNGeometryElement(
            indices: indices,
            primitiveType: .point
        )

        element.pointSize = pointSize
        element.minimumPointScreenSpaceRadius = minimumPointSize
        element.maximumPointScreenSpaceRadius = pointSize

        let geometry = SCNGeometry(
            sources: [source],
            elements: [element]
        )

        let material = SCNMaterial()

        material.diffuse.contents = colour
        material.emission.contents = colour
        material.lightingModel = .constant
        material.blendMode = .alpha
        material.transparency = 1.0

        material.readsFromDepthBuffer = true
        material.writesToDepthBuffer = false

        geometry.materials = [
            material
        ]

        let node = SCNNode(
            geometry: geometry
        )

        node.name = name
        node.renderingOrder = 110

        return node
    }

    // ============================================================
    // MARK: - MAGNETIC AXIS
    // ============================================================

    private func magneticAxisDirection() -> SIMD3<Float> {

        let latitudeDegrees = 90.0 - magneticAxisTiltDegrees

        let latitude = latitudeDegrees * Double.pi / 180.0

        let longitude = magneticAxisLongitudeDegrees * Double.pi / 180.0

        let x = cos(latitude) * sin(longitude)
        let y = sin(latitude)
        let z = cos(latitude) * cos(longitude)

        return simd_normalize(
            SIMD3<Float>(
                Float(x),
                Float(y),
                Float(z)
            )
        )
    }

    // ============================================================
    // MARK: - RANDOM
    // ============================================================

    private func randomUnit(
        _ generator: inout VanAllenSeededGenerator
    ) -> Double {

        return Double(generator.next()) / Double(UInt64.max)
    }

    // ============================================================
    // MARK: - VISIBILITY
    // ============================================================

    func setVisible(
        _ visible: Bool
    ) {
        beltRootNode.isHidden = !visible
    }

    // ============================================================
    // MARK: - REMOVE
    // ============================================================

    func remove() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        beltRootNode.removeFromParentNode()
    }
}

// ============================================================
// MARK: - SEEDED RANDOM GENERATOR
// ============================================================

private struct VanAllenSeededGenerator: RandomNumberGenerator {

    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x123456789ABCDEF : seed
    }

    mutating func next() -> UInt64 {

        state = state
            &* 6364136223846793005
            &+ 1442695040888963407

        return state
    }
}

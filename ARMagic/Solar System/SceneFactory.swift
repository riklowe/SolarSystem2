//
//  SceneFactory.swift
//  SolarSystem2
//

import UIKit
import SceneKit
import simd

enum SceneFactory {

    static let moduleName = (#file).components(separatedBy: "/")

    static func degreesToRadians(_ degrees: CGFloat) -> Float {
        return Float(Double(degrees) * Double.pi / 180.0)
    }

    static func applyOrbitOrientation(to node: SCNNode, inclinationDegrees: CGFloat, ascendingNodeDegrees: CGFloat) {
        node.eulerAngles.y = degreesToRadians(ascendingNodeDegrees)
        node.eulerAngles.x = degreesToRadians(inclinationDegrees)
    }

    // ============================================================
    // MARK: - LABEL
    // ============================================================

    static func createNameLabel(
        text: String,
        objectRadius: CGFloat,
        isMoon: Bool = false,
        displayMode: SolarSystemDisplayMode = .compact
    ) -> SCNNode {

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let fontSize: CGFloat
        let nodeScale: CGFloat
        let labelGap: CGFloat

        switch displayMode {

        case .relativeSizes:

            // True Body Scale:
            // Bodies can become extremely small, so use a much smaller
            // fixed label than the normal AR presentation.

            fontSize = isMoon ? 0.08 : 0.10
            nodeScale = isMoon ? 0.045 : 0.065
            labelGap = isMoon ? 0.0015 : 0.0025

        case .earthMoon:

            // Earth-Moon Scale:
            // Keep labels compact but slightly larger than True Body Scale
            // because only Earth and Moon are displayed.

            fontSize = isMoon ? 0.08 : 0.10
            nodeScale = isMoon ? 0.055 : 0.065
            labelGap = isMoon ? 0.003 : 0.004

        case .compact, .astronomicalDistances:

            // Preserve the existing label appearance exactly.

            fontSize = isMoon ? 0.08 : 0.12
            nodeScale = isMoon ? 0.10 : 0.15
            labelGap = isMoon ? 0.001 : 0.002
        }

        let textGeometry = SCNText(
            string: text.capitalized,
            extrusionDepth: 0.001
        )

        textGeometry.font = UIFont.systemFont(
            ofSize: fontSize,
            weight: .semibold
        )

        textGeometry.flatness = 0.1
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        textGeometry.firstMaterial?.emission.contents = UIColor.white
        textGeometry.firstMaterial?.isDoubleSided = true

        let textNode = SCNNode(
            geometry: textGeometry
        )

        let bounds = textGeometry.boundingBox
        let width = bounds.max.x - bounds.min.x

        textNode.pivot = SCNMatrix4MakeTranslation(
            bounds.min.x + width / 2.0,
            bounds.min.y,
            0
        )

        textNode.scale = SCNVector3(
            Float(nodeScale),
            Float(nodeScale),
            Float(nodeScale)
        )

        textNode.position = SCNVector3(
            0,
            Float(objectRadius + labelGap),
            0
        )

        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = .Y

        textNode.constraints = [
            billboard
        ]

        textNode.name = "label_\(text.lowercased())"

        return textNode
    }

    // ============================================================
    // MARK: - ORBIT LINE
    // ============================================================

    static func createOrbitLine(
        radius: CGFloat,
        colour: UIColor,
        pipeRadius: CGFloat = 0.001
    ) -> SCNNode {

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let node = SCNNode()

        node.geometry = SCNTorus(
            ringRadius: radius,
            pipeRadius: pipeRadius
        )

        node.geometry?.firstMaterial?.diffuse.contents = colour
        node.geometry?.firstMaterial?.emission.contents = colour
        node.geometry?.firstMaterial?.isDoubleSided = true

        return node
    }

    // ============================================================
    // MARK: - PLANET AXIS
    // ============================================================

    static func createPlanetAxisNode(
        for planetName: String,
        date: Date
    ) -> SCNNode {

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let node = SCNNode()

        node.name = planetName + "_axis"

        let localUp = SIMD3<Float>(
            0,
            1,
            0
        )

        let targetUp = PlanetAstronomy.eclipticPoleVector(
            for: planetName,
            date: date
        )

        let dot = max(
            Float(-1.0),
            min(
                Float(1.0),
                simd_dot(
                    localUp,
                    targetUp
                )
            )
        )

        if dot < 0.999999 {

            if dot <= -0.999999 {

                node.simdOrientation = simd_quatf(
                    angle: Float.pi,
                    axis: SIMD3<Float>(
                        1,
                        0,
                        0
                    )
                )

            } else {

                let axis = simd_normalize(
                    simd_cross(
                        localUp,
                        targetUp
                    )
                )

                node.simdOrientation = simd_quatf(
                    angle: acos(dot),
                    axis: axis
                )
            }
        }

        return node
    }

    static func createPoleIndicator(
        planetRadius: CGFloat
    ) -> SCNNode {

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let container = SCNNode()

        container.name = "poleIndicator"

        let poleLength =
            planetRadius * 3.0

        let poleRadius =
            max(
                planetRadius * 0.015,
                0.0005
            )

        let cylinder = SCNCylinder(
            radius: poleRadius,
            height: poleLength
        )

        let poleMaterial = SCNMaterial()

        poleMaterial.diffuse.contents =
            UIColor.systemCyan

        poleMaterial.emission.contents =
            UIColor.systemCyan

        poleMaterial.lightingModel =
            .constant

        cylinder.materials = [
            poleMaterial
        ]

        let poleNode = SCNNode(
            geometry: cylinder
        )

        poleNode.name =
            "poleLine"

        container.addChildNode(
            poleNode
        )

        let markerRadius =
            max(
                planetRadius * 0.06,
                0.0015
            )

        let northSphere = SCNSphere(
            radius: markerRadius
        )

        northSphere.firstMaterial?.diffuse.contents =
            UIColor.systemRed

        northSphere.firstMaterial?.emission.contents =
            UIColor.systemRed

        northSphere.firstMaterial?.lightingModel =
            .constant

        let northNode = SCNNode(
            geometry: northSphere
        )

        northNode.name =
            "northPole"

        northNode.position =
            SCNVector3(
                0,
                Float(poleLength / 2.0),
                0
            )

        container.addChildNode(
            northNode
        )

        let southSphere = SCNSphere(
            radius: markerRadius
        )

        southSphere.firstMaterial?.diffuse.contents =
            UIColor.systemBlue

        southSphere.firstMaterial?.emission.contents =
            UIColor.systemBlue

        southSphere.firstMaterial?.lightingModel =
            .constant

        let southNode = SCNNode(
            geometry: southSphere
        )

        southNode.name =
            "southPole"

        southNode.position =
            SCNVector3(
                0,
                Float(-poleLength / 2.0),
                0
            )

        container.addChildNode(
            southNode
        )

        return container
    }
}

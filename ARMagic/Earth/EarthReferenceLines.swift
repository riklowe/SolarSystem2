//
//  EarthReferenceLines.swift
//  SolarSystem2
//

import Foundation
import SceneKit
import CoreGraphics

enum EarthReferenceLines {

    static let nodeName = "earth_reference_lines"

    // ============================================================
    // MARK: - EARTH GUIDES
    // ============================================================

    static func create(radius: CGFloat) -> SCNNode {

        let root = SCNNode()
        root.name = nodeName

        // Attach to Earth's body so the guides inherit its existing axis tilt.
        // Cyan: equator. Gold: tropics (approximately 23.44 degrees N/S).
        // Constant materials keep the guides legible on the night hemisphere;
        // they do not emit light onto the planet.
        let latitudes: [(String, Double)] = [
            ("earth_equator", 0),
            ("earth_tropic_cancer", 23.4392911),
            ("earth_tropic_capricorn", -23.4392911)
        ]
        let surfaceRadius = radius * 1.008

        for (name, latitude) in latitudes {
            let angle = latitude * Double.pi / 180
            let ring = SCNTorus(
                ringRadius: surfaceRadius * CGFloat(cos(angle)),
                pipeRadius: radius * 0.004
            )
            ring.ringSegmentCount = 180
            ring.pipeSegmentCount = 6
            ring.materials = [material(
                color: latitude == 0
                    ? CGColor(red: 0.2, green: 0.9, blue: 1, alpha: 1)
                    : CGColor(red: 1, green: 0.78, blue: 0.2, alpha: 1)
            )]

            let node = SCNNode(geometry: ring)
            node.name = name
            node.simdPosition.y = Float(surfaceRadius * CGFloat(sin(angle)))
            root.addChildNode(node)
        }

        let axis = SCNCylinder(radius: radius * 0.007, height: radius * 2.8)
        axis.radialSegmentCount = 8
        axis.materials = [material(color: CGColor(gray: 0.9, alpha: 1))]
        let axisNode = SCNNode(geometry: axis)
        axisNode.name = "earth_rotation_axis"
        root.addChildNode(axisNode)

        return root
    }

    private static func material(color: CGColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = color
        material.emission.contents = CGColor(gray: 0, alpha: 1)
        material.readsFromDepthBuffer = true
        material.writesToDepthBuffer = true
        return material
    }
}

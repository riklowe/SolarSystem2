//
//  RingFactory.swift
//  SolarSystem2
//

import UIKit
import SceneKit

enum RingFactory {

    static let  moduleName = (#file).components(separatedBy: "/")

    // ============================================================
    // MARK: - GENERIC RING
    // ============================================================

    static func createFlatRing(innerRadius: CGFloat, outerRadius: CGFloat, colour: UIColor, transparency: CGFloat, segments: Int = 192) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        var vertices = [SCNVector3]()
        var normals = [SCNVector3]()
        var indices = [Int32]()

        for i in 0...segments {
            let angle = CGFloat(i) / CGFloat(segments) * CGFloat.pi * 2.0
            let cosAngle = cos(angle)
            let sinAngle = sin(angle)

            vertices.append(SCNVector3(Float(innerRadius * cosAngle), 0, Float(innerRadius * sinAngle)))
            vertices.append(SCNVector3(Float(outerRadius * cosAngle), 0, Float(outerRadius * sinAngle)))
            normals.append(SCNVector3(0, 1, 0))
            normals.append(SCNVector3(0, 1, 0))
        }

        for i in 0..<segments {
            let inner1 = Int32(i * 2)
            let outer1 = inner1 + 1
            let inner2 = Int32((i + 1) * 2)
            let outer2 = inner2 + 1

            indices.append(inner1)
            indices.append(outer1)
            indices.append(inner2)
            indices.append(outer1)
            indices.append(outer2)
            indices.append(inner2)
        }

        let vertexSource = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: normals)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])

        let material = SCNMaterial()

//        material.diffuse.contents = colour
//        material.emission.contents = colour.withAlphaComponent(0.15)
//        material.transparency = transparency
//        material.isDoubleSided = true
//        material.lightingModel = .physicallyBased
//        material.blendMode = .alpha

        material.diffuse.contents = colour
        material.emission.contents = colour
        material.transparency = transparency
        material.isDoubleSided = true
        material.lightingModel = .constant
        material.blendMode = .alpha
        
        geometry.materials = [material]

        return SCNNode(geometry: geometry)
    }

    // ============================================================
    // MARK: - JUPITER
    // ============================================================

    static func createJupiterRings(planetRadius: CGFloat) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        let ringSystem = SCNNode()
        ringSystem.name = "jupiter_rings"

        ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * 1.20, outerRadius: planetRadius * 1.30, colour: UIColor(red: 0.65, green: 0.57, blue: 0.48, alpha: 1.0), transparency: 0.04, segments: 192))
        ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * 1.30, outerRadius: planetRadius * 1.42, colour: UIColor(red: 0.69, green: 0.61, blue: 0.51, alpha: 1.0), transparency: 0.06, segments: 192))
        ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * 1.43, outerRadius: planetRadius * 1.55, colour: UIColor(red: 0.73, green: 0.66, blue: 0.56, alpha: 1.0), transparency: 0.10, segments: 256))
        ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * 1.55, outerRadius: planetRadius * 1.70, colour: UIColor(red: 0.68, green: 0.61, blue: 0.52, alpha: 1.0), transparency: 0.075, segments: 256))
        ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * 1.72, outerRadius: planetRadius * 2.05, colour: UIColor(red: 0.60, green: 0.55, blue: 0.49, alpha: 1.0), transparency: 0.035, segments: 256))
        ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * 2.07, outerRadius: planetRadius * 2.40, colour: UIColor(red: 0.57, green: 0.53, blue: 0.48, alpha: 1.0), transparency: 0.018, segments: 256))

        return ringSystem
    }
    
    // ============================================================
    // MARK: - SATURN
    // ============================================================

    static func createSaturnRings(planetRadius: CGFloat) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        let ringSystem = SCNNode()
        ringSystem.name = "saturn_rings"

        struct RingBand {
            let inner: CGFloat
            let outer: CGFloat
            let red: CGFloat
            let green: CGFloat
            let blue: CGFloat
            let alpha: CGFloat
        }

        let bands: [RingBand] = [
            RingBand(inner: 1.20, outer: 1.24, red: 0.48, green: 0.46, blue: 0.42, alpha: 0.10),
            RingBand(inner: 1.24, outer: 1.28, red: 0.52, green: 0.50, blue: 0.45, alpha: 0.14),
            RingBand(inner: 1.28, outer: 1.32, red: 0.57, green: 0.54, blue: 0.48, alpha: 0.18),
            RingBand(inner: 1.32, outer: 1.36, red: 0.61, green: 0.58, blue: 0.51, alpha: 0.22),
            RingBand(inner: 1.36, outer: 1.40, red: 0.64, green: 0.60, blue: 0.53, alpha: 0.26),
            RingBand(inner: 1.40, outer: 1.44, red: 0.67, green: 0.63, blue: 0.55, alpha: 0.30),
            RingBand(inner: 1.45, outer: 1.48, red: 0.71, green: 0.67, blue: 0.58, alpha: 0.40),

            RingBand(inner: 1.49, outer: 1.53, red: 0.76, green: 0.72, blue: 0.63, alpha: 0.58),
            RingBand(inner: 1.53, outer: 1.57, red: 0.81, green: 0.77, blue: 0.67, alpha: 0.68),
            RingBand(inner: 1.57, outer: 1.61, red: 0.86, green: 0.82, blue: 0.72, alpha: 0.76),
            RingBand(inner: 1.61, outer: 1.65, red: 0.90, green: 0.86, blue: 0.75, alpha: 0.82),
            RingBand(inner: 1.65, outer: 1.69, red: 0.88, green: 0.84, blue: 0.73, alpha: 0.86),
            RingBand(inner: 1.69, outer: 1.73, red: 0.84, green: 0.80, blue: 0.70, alpha: 0.82),
            RingBand(inner: 1.73, outer: 1.77, red: 0.80, green: 0.76, blue: 0.66, alpha: 0.78),
            RingBand(inner: 1.77, outer: 1.81, red: 0.76, green: 0.72, blue: 0.63, alpha: 0.74),
            RingBand(inner: 1.81, outer: 1.85, red: 0.72, green: 0.68, blue: 0.59, alpha: 0.68),
            RingBand(inner: 1.85, outer: 1.89, red: 0.67, green: 0.64, blue: 0.56, alpha: 0.58),

            // Cassini Division 1.89 - 2.01

            RingBand(inner: 2.01, outer: 2.05, red: 0.68, green: 0.65, blue: 0.58, alpha: 0.50),
            RingBand(inner: 2.05, outer: 2.09, red: 0.73, green: 0.70, blue: 0.62, alpha: 0.58),
            RingBand(inner: 2.09, outer: 2.13, red: 0.78, green: 0.74, blue: 0.65, alpha: 0.64),
            RingBand(inner: 2.13, outer: 2.17, red: 0.82, green: 0.78, blue: 0.68, alpha: 0.68),
            RingBand(inner: 2.17, outer: 2.21, red: 0.79, green: 0.75, blue: 0.66, alpha: 0.64),
            RingBand(inner: 2.21, outer: 2.23, red: 0.58, green: 0.56, blue: 0.51, alpha: 0.38),
            RingBand(inner: 2.23, outer: 2.27, red: 0.76, green: 0.72, blue: 0.64, alpha: 0.58),
            RingBand(inner: 2.27, outer: 2.31, red: 0.72, green: 0.69, blue: 0.61, alpha: 0.52),

            // Encke-like gap 2.31 - 2.335

            RingBand(inner: 2.335, outer: 2.37, red: 0.69, green: 0.66, blue: 0.59, alpha: 0.46),
            RingBand(inner: 2.37, outer: 2.40, red: 0.63, green: 0.61, blue: 0.55, alpha: 0.36),
            RingBand(inner: 2.405, outer: 2.43, red: 0.58, green: 0.57, blue: 0.53, alpha: 0.22),
            RingBand(inner: 2.435, outer: 2.45, red: 0.54, green: 0.53, blue: 0.50, alpha: 0.12)
        ]

        for band in bands {
            let colour = UIColor(red: band.red, green: band.green, blue: band.blue, alpha: 1.0)
            ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * band.inner, outerRadius: planetRadius * band.outer, colour: colour, transparency: band.alpha, segments: 256))
        }

        return ringSystem
    }

    // ============================================================
    // MARK: - URANUS
    // ============================================================

    static func createUranusRings(planetRadius: CGFloat) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        let ringSystem = SCNNode()
        ringSystem.name = "uranus_rings"

        let colour = UIColor(red: 0.24, green: 0.25, blue: 0.24, alpha: 1.0)

        let rings: [(CGFloat, CGFloat, CGFloat)] = [
            (1.48, 1.50, 0.22),
            (1.55, 1.57, 0.26),
            (1.62, 1.64, 0.30),
            (1.70, 1.72, 0.34),
            (1.78, 1.80, 0.38),
            (1.87, 1.90, 0.44),
            (1.98, 2.01, 0.50),
            (2.10, 2.14, 0.58),
            (2.26, 2.31, 0.72)
        ]

        for ring in rings { ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * ring.0, outerRadius: planetRadius * ring.1, colour: colour, transparency: ring.2, segments: 256)) }

        ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * 2.50, outerRadius: planetRadius * 2.65, colour: UIColor(red: 0.32, green: 0.33, blue: 0.31, alpha: 1.0), transparency: 0.10, segments: 256))

        return ringSystem
    }

    // ============================================================
    // MARK: - NEPTUNE
    // ============================================================

    static func createNeptuneRings(planetRadius: CGFloat) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        let ringSystem = SCNNode()
        ringSystem.name = "neptune_rings"

        let colour = UIColor(red: 0.53, green: 0.55, blue: 0.56, alpha: 1.0)

        let rings: [(CGFloat, CGFloat, CGFloat)] = [
            (1.55, 1.58, 0.10),
            (1.72, 1.75, 0.13),
            (1.90, 1.94, 0.17),
            (2.12, 2.16, 0.22),
            (2.38, 2.43, 0.30)
        ]

        for ring in rings { ringSystem.addChildNode(createFlatRing(innerRadius: planetRadius * ring.0, outerRadius: planetRadius * ring.1, colour: colour, transparency: ring.2, segments: 256)) }

        return ringSystem
    }

    // ============================================================
    // MARK: - SELECT RINGS
    // ============================================================

    static func rings(for planetName: String, planetRadius: CGFloat) -> SCNNode? {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        switch planetName.lowercased() {
        case "jupiter": return createJupiterRings(planetRadius: planetRadius)
        case "saturn": return createSaturnRings(planetRadius: planetRadius)
        case "uranus": return createUranusRings(planetRadius: planetRadius)
        case "neptune": return createNeptuneRings(planetRadius: planetRadius)
        default: return nil
        }
    }
}

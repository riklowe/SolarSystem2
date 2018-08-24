//
//  CometBuilder.swift
//  SolarSystem2
//

import Foundation
import SceneKit
import UIKit
import simd

final class CometBuilder {

    let moduleName = (#file).components(separatedBy: "/")

    struct CometNodes {
        let comet: Comet
        let systemNode: SCNNode
        let nucleusNode: SCNNode
        let comaNode: SCNNode
        let tailNode: SCNNode
        let orbitNode: SCNNode
        let labelNode: SCNNode
    }

    private let rootNode: SCNNode
    private let simulationClock: SimulationClock

    private var cometNodes: [CometNodes] = []

    init(rootNode: SCNNode, simulationClock: SimulationClock) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        self.rootNode = rootNode
        self.simulationClock = simulationClock
    }

    // ============================================================
    // MARK: - BUILD
    // ============================================================

    func build() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        cometNodes.removeAll()

        for comet in comets() {
            buildComet(comet)
        }
    }

    // ============================================================
    // MARK: - COMET DATA
    // ============================================================

    private func comets() -> [Comet] {

        let halley = Comet(
            name: "Halley",
            nucleusRadius: 0.025,
            displaySemiMajorAxis: 3.15,
            epochJulianDate: 2439875.5,
            semiMajorAxisAU: 17.928635,
            eccentricity: 0.96793600,
            inclination: 162.190530,
            ascendingNode: 59.098947,
            argumentPeriapsis: 112.241431,
            meanAnomalyAtEpoch: 274.382337,
            meanMotion: 0.012983
        )

        // JPL SBDB orbital elements retrieved 23 September 2026.
        // Angles are degrees; mean motion is degrees per day.
        // Each mean anomaly is paired with its own orbital epoch.
        // Display axes and nucleus sizes are exaggerated for the AR scene.
        // Fixed Keplerian elements approximate motion; perturbations are not modelled.

        // 2P/Encke — JPL orbit K273/17
        // https://ssd-api.jpl.nasa.gov/sbdb.api?sstr=2P&full-prec=true
        let encke = Comet(
            name: "Encke",
            nucleusRadius: 0.018,
            displaySemiMajorAxis: 1.65,
            epochJulianDate: 2460062.5,
            semiMajorAxisAU: 2.219242525702791,
            eccentricity: 0.8470279034259183,
            inclination: 11.342270038,
            ascendingNode: 334.0454694778515,
            argumentPeriapsis: 187.2630430521377,
            meanAnomalyAtEpoch: 307.0802917287554,
            meanMotion: 0.2981239900177668
        )

        // 67P/Churyumov-Gerasimenko — JPL orbit K284/1
        // https://ssd-api.jpl.nasa.gov/sbdb.api?sstr=67P&full-prec=true
        let churyumovGerasimenko = Comet(
            name: "67P/Churyumov-Gerasimenko",
            nucleusRadius: 0.018,
            displaySemiMajorAxis: 2.10,
            epochJulianDate: 2457305.5,
            semiMajorAxisAU: 3.462249490129549,
            eccentricity: 0.6409081308996354,
            inclination: 7.040294937543767,
            ascendingNode: 50.13557377155012,
            argumentPeriapsis: 12.79824970228189,
            meanAnomalyAtEpoch: 8.859927425218402,
            meanMotion: 0.1529912291873851
        )

        // C/1995 O1 (Hale-Bopp) — JPL orbit 226
        // https://ssd-api.jpl.nasa.gov/sbdb.api?sstr=C%2F1995%20O1&full-prec=true
        let haleBopp = Comet(
            name: "Hale-Bopp",
            nucleusRadius: 0.030,
            displaySemiMajorAxis: 4.20,
            epochJulianDate: 2459837.5,
            semiMajorAxisAU: 177.4333839117583,
            eccentricity: 0.9949810027633206,
            inclination: 89.28759424740302,
            ascendingNode: 282.7334213961641,
            argumentPeriapsis: 130.4146670659176,
            meanAnomalyAtEpoch: 3.878386339423241,
            meanMotion: 0.0004170144183266921
        )

        return [
            halley,
            encke,
            churyumovGerasimenko,
            haleBopp
        ]
    }

    // ============================================================
    // MARK: - BUILD COMET
    // ============================================================

    private func buildComet(_ comet: Comet) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let date = simulationClock.currentDate

        let systemNode = SCNNode()
        systemNode.name = "\(comet.name.lowercased())_comet_system"
        systemNode.position = CometAstronomy.orbitalPosition(for: comet, date: date)
        rootNode.addChildNode(systemNode)

        // --------------------------------------------------------
        // Nucleus
        // --------------------------------------------------------

        let nucleusGeometry = SCNSphere(radius: comet.nucleusRadius)
        nucleusGeometry.segmentCount = 32

        let nucleusMaterial = SCNMaterial()
        nucleusMaterial.diffuse.contents = UIColor.darkGray
        nucleusMaterial.ambient.contents = UIColor.black
        nucleusMaterial.emission.contents = UIColor.black
        nucleusMaterial.lightingModel = .lambert

        nucleusGeometry.materials = [nucleusMaterial]

        let nucleusNode = SCNNode(geometry: nucleusGeometry)
        nucleusNode.name = "\(comet.name.lowercased())_nucleus"
        systemNode.addChildNode(nucleusNode)

        // --------------------------------------------------------
        // Coma
        // --------------------------------------------------------

        let comaNode = createComa(radius: comet.nucleusRadius * 3.5)
        comaNode.name = "\(comet.name.lowercased())_coma"
        systemNode.addChildNode(comaNode)

        // --------------------------------------------------------
        // Tail
        // --------------------------------------------------------

        let tailNode = createTail(nucleusRadius: comet.nucleusRadius)
        tailNode.name = "\(comet.name.lowercased())_tail"
        systemNode.addChildNode(tailNode)

        // --------------------------------------------------------
        // Label
        // --------------------------------------------------------

        let labelNode = SceneFactory.createNameLabel(
            text: comet.name,
            objectRadius: comet.nucleusRadius * 3.5,
            isMoon: false
        )

        labelNode.name = "label_comet_\(comet.name.lowercased())"
        systemNode.addChildNode(labelNode)

        // --------------------------------------------------------
        // Orbit
        // --------------------------------------------------------

        let orbitNode = createOrbitVisual(for: comet)
        rootNode.addChildNode(orbitNode)

        updateTailDirection(systemNode: systemNode, tailNode: tailNode)

        cometNodes.append(
            CometNodes(
                comet: comet,
                systemNode: systemNode,
                nucleusNode: nucleusNode,
                comaNode: comaNode,
                tailNode: tailNode,
                orbitNode: orbitNode,
                labelNode: labelNode
            )
        )
    }

    // ============================================================
    // MARK: - COMA
    // ============================================================

    private func createComa(radius: CGFloat) -> SCNNode {

        let geometry = SCNSphere(radius: radius)
        geometry.segmentCount = 32

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.12)
        material.emission.contents = UIColor.white.withAlphaComponent(0.20)
        material.lightingModel = .constant
        material.transparency = 0.30
        material.isDoubleSided = true
        material.writesToDepthBuffer = false

        geometry.materials = [material]

        return SCNNode(geometry: geometry)
    }

    // ============================================================
    // MARK: - TAIL
    // ============================================================

    private func createTail(nucleusRadius: CGFloat) -> SCNNode {

        let tailLength = max(nucleusRadius * 15.0, 0.30)
        let tailRadius = max(nucleusRadius * 2.0, 0.025)

        let cone = SCNCone(
            topRadius: 0.001,
            bottomRadius: tailRadius,
            height: tailLength
        )

        cone.radialSegmentCount = 32

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.18)
        material.emission.contents = UIColor.white.withAlphaComponent(0.25)
        material.lightingModel = .constant
        material.transparency = 0.35
        material.isDoubleSided = true
        material.writesToDepthBuffer = false

        cone.materials = [material]

        // Rotate and scale the tail around the nucleus, not the cone centre.
        let tailNode = SCNNode()

        let coneNode = SCNNode(geometry: cone)

        // The narrow end is at +height / 2 in the cone's local coordinates.
        // This child offset puts that end at the parent origin (the nucleus).
        coneNode.position = SCNVector3(
            0,
            Float(-tailLength / 2.0),
            0
        )

        tailNode.addChildNode(coneNode)

        return tailNode
    }

    // ============================================================
    // MARK: - TAIL DIRECTION
    // ============================================================

    private func updateTailDirection(systemNode: SCNNode, tailNode: SCNNode) {

        let cometPosition = systemNode.simdPosition
        let distance = simd_length(cometPosition)

        guard distance > 0.000001 else { return }

        let awayFromSun = simd_normalize(cometPosition)
        let localTailDirection = SIMD3<Float>(0, -1, 0)

        tailNode.simdOrientation = simd_quatf(
            from: localTailDirection,
            to: awayFromSun
        )
    }

    // ============================================================
    // MARK: - ORBIT VISUAL
    // ============================================================

    private func createOrbitVisual(for comet: Comet) -> SCNNode {

        let orbitNode = SCNNode()
        orbitNode.name = "\(comet.name.lowercased())_comet_orbit"

        let points = 384

        var vertices: [SCNVector3] = []
        vertices.reserveCapacity(points + 1)

        for index in 0...points {

            let eccentricAnomaly =
                Double(index) /
                Double(points) *
                Double.pi *
                2.0

            vertices.append(
                CometAstronomy.orbitPoint(
                    for: comet,
                    eccentricAnomaly: eccentricAnomaly
                )
            )
        }

        let source = SCNGeometrySource(vertices: vertices)

        var indices: [Int32] = []

        for index in 0..<points {
            indices.append(Int32(index))
            indices.append(Int32(index + 1))
        }

        let data = Data(
            bytes: indices,
            count: indices.count * MemoryLayout<Int32>.size
        )

        let element = SCNGeometryElement(
            data: data,
            primitiveType: .line,
            primitiveCount: points,
            bytesPerIndex: MemoryLayout<Int32>.size
        )

        let geometry = SCNGeometry(
            sources: [source],
            elements: [element]
        )

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemYellow
        material.emission.contents = UIColor.systemYellow
        material.lightingModel = .constant
        material.transparency = 0.85
        material.isDoubleSided = true

        geometry.materials = [material]
        orbitNode.geometry = geometry

        return orbitNode
    }

    // ============================================================
    // MARK: - UPDATE
    // ============================================================

    func update(for date: Date) {

        for item in cometNodes {

            item.systemNode.position = CometAstronomy.orbitalPosition(
                for: item.comet,
                date: date
            )

            updateTailDirection(
                systemNode: item.systemNode,
                tailNode: item.tailNode
            )

            updateActivity(
                for: item,
                date: date
            )
        }
    }

    // ============================================================
    // MARK: - COMET ACTIVITY
    // ============================================================

    private func updateActivity(for item: CometNodes, date: Date) {

        let distanceAU = CometAstronomy.heliocentricDistanceAU(
            for: item.comet,
            date: date
        )

        let activity = max(
            0.08,
            min(
                1.0,
                3.0 / distanceAU
            )
        )

        item.comaNode.opacity = CGFloat(
            0.15 + activity * 0.70
        )

        item.tailNode.opacity = CGFloat(
            0.10 + activity * 0.90
        )

        let scale = Float(
            0.40 + activity * 0.90
        )

        item.tailNode.scale = SCNVector3(
            scale,
            scale,
            scale
        )
    }

    // ============================================================
    // MARK: - DISPLAY CONTROLS
    // ============================================================

    func setCometsVisible(_ visible: Bool) {
        for item in cometNodes {
            item.nucleusNode.isHidden = !visible
        }
    }

    func setCometTailsVisible(_ visible: Bool) {
        for item in cometNodes {
            item.comaNode.isHidden = !visible
            item.tailNode.isHidden = !visible
        }
    }

    func setCometOrbitsVisible(_ visible: Bool) {
        for item in cometNodes {
            item.orbitNode.isHidden = !visible
        }
    }

    func setCometLabelsVisible(_ visible: Bool) {
        for item in cometNodes {
            item.labelNode.isHidden = !visible
        }
    }

    // ============================================================
    // MARK: - REMOVE
    // ============================================================

    func remove() {

        for item in cometNodes {
            item.systemNode.removeFromParentNode()
            item.orbitNode.removeFromParentNode()
        }

        cometNodes.removeAll()
    }
}



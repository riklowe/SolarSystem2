//
//  NearEarthAsteroidBuilder.swift
//  ARMagic
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

import Foundation
import SceneKit
import UIKit
import simd

final class NearEarthAsteroidBuilder {

    private let asteroid: NearEarthAsteroid
    private let displayMode: SolarSystemDisplayMode

    let rootNode = SCNNode()

    private let bodyNode = SCNNode()
    private let locatorNode = SCNNode()
    private let labelNode = SCNNode()
    private let trajectoryNode = SCNNode()

    private var isVisible = true
    private var hasValidPosition = false

    init(asteroid: NearEarthAsteroid, displayMode: SolarSystemDisplayMode) {
        self.asteroid = asteroid
        self.displayMode = displayMode

        rootNode.name = "nea-\(asteroid.name.lowercased())"

        buildBody()
        buildLocator()
        buildLabel()
        buildTrajectory()
        applyVisibility()

    }

    // ============================================================
    // MARK: - BUILD
    // ============================================================

    private func buildBody() {

        bodyNode.name = asteroid.name
        bodyNode.scale = SCNVector3(1.0, 1.0, 1.0)

        if hasMeaningfulPhysicalBodyScale {

            let geometry = createPhysicalAsteroidGeometry()

            let material = SCNMaterial()
            material.diffuse.contents = UIColor(white: 0.38, alpha: 1.0)
            material.emission.contents = UIColor(white: 0.08, alpha: 1.0)
            material.roughness.contents = 0.95
            material.metalness.contents = 0.0

            geometry.materials = [material]
            bodyNode.geometry = geometry
            bodyNode.isHidden = false

        } else {

            // This display mode does not use a compatible physical body-size scale.
            // Do not create an artificially enlarged asteroid. The locator identifies
            // the asteroid's calculated position instead.
            bodyNode.geometry = nil
            bodyNode.isHidden = true
        }

        rootNode.addChildNode(bodyNode)

#if DEBUG
        debugBodyScale()
#endif
    }

    private func createPhysicalAsteroidGeometry() -> SCNGeometry {

        let sphere = SCNSphere(radius: physicalDisplayRadius)
        sphere.segmentCount = 12

        bodyNode.scale = SCNVector3(1.0, 1.0, 1.0)

        return sphere
    }

    private func buildLocator() {

        locatorNode.name = "\(asteroid.name)-locator"

        // Enhanced display modes already make the asteroid large enough to see.
        // The locator exists only when the asteroid itself is rendered at physical scale.
        locatorNode.isHidden = false

        let radius = locatorRadius
        let lineLength = radius * 0.70
        let centreGap = radius * 0.22

        // ------------------------------------------------------------
        // Screen-facing reticle
        //
        // This is a UI locator only. It does NOT represent the physical
        // size or shape of the asteroid.
        // ------------------------------------------------------------

        let reticleNode = SCNNode()
        reticleNode.name = "\(asteroid.name)-locator-reticle"

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemYellow
        material.emission.contents = UIColor.systemYellow
        material.lightingModel = .constant
        material.isDoubleSided = true

        // Left
        reticleNode.addChildNode(
            createLocatorLine(
                from: SCNVector3(-Float(radius), 0, 0),
                to: SCNVector3(-Float(centreGap), 0, 0),
                material: material
            )
        )

        // Right
        reticleNode.addChildNode(
            createLocatorLine(
                from: SCNVector3(Float(centreGap), 0, 0),
                to: SCNVector3(Float(radius), 0, 0),
                material: material
            )
        )

        // Top
        reticleNode.addChildNode(
            createLocatorLine(
                from: SCNVector3(0, Float(centreGap), 0),
                to: SCNVector3(0, Float(lineLength), 0),
                material: material
            )
        )

        // Bottom
        reticleNode.addChildNode(
            createLocatorLine(
                from: SCNVector3(0, -Float(centreGap), 0),
                to: SCNVector3(0, -Float(lineLength), 0),
                material: material
            )
        )

        // Small centre point.
        let point = SCNSphere(radius: radius * 0.055)
        point.segmentCount = 12
        point.materials = [material]

        let pointNode = SCNNode(geometry: point)
        pointNode.name = "\(asteroid.name)-locator-centre"

        reticleNode.addChildNode(pointNode)

        // Keep the whole reticle facing the camera.
        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = .all
        reticleNode.constraints = [billboard]

        locatorNode.addChildNode(reticleNode)
        rootNode.addChildNode(locatorNode)
    }

    private func createLocatorLine(from start: SCNVector3, to end: SCNVector3, material: SCNMaterial) -> SCNNode {

        let vertices = [start, end]
        let source = SCNGeometrySource(vertices: vertices)

        var indices: [Int32] = [0, 1]

        let data = Data(bytes: &indices, count: indices.count * MemoryLayout<Int32>.size)

        let element = SCNGeometryElement(
            data: data,
            primitiveType: .line,
            primitiveCount: 1,
            bytesPerIndex: MemoryLayout<Int32>.size
        )

        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.materials = [material]

        return SCNNode(geometry: geometry)
    }

    private func buildLabel() {

        let text = SCNText(string: asteroid.name, extrusionDepth: 0.001)

        text.font = UIFont.systemFont(ofSize: 0.12, weight: .semibold)
        text.flatness = 0.2

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.emission.contents = UIColor.white
        material.isDoubleSided = true

        text.materials = [material]

        labelNode.geometry = text
        labelNode.name = "\(asteroid.name)-label"

        let bounds = text.boundingBox
        let width = bounds.max.x - bounds.min.x

        labelNode.pivot = SCNMatrix4MakeTranslation(bounds.min.x + width / 2.0, bounds.min.y, 0)
        labelNode.scale = SCNVector3(0.10, 0.10, 0.10)

        labelNode.position = SCNVector3(0, Float(locatorRadius + 0.015), 0)

        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = .all

        labelNode.constraints = [billboard]

        rootNode.addChildNode(labelNode)
    }

    // ============================================================
    // MARK: - TRAJECTORY
    // ============================================================

    private func buildTrajectory() {

        trajectoryNode.name = "\(asteroid.name)-trajectory"

        if displayMode == .earthMoon {
            buildEarthRelativeTrajectory()
        } else {
            buildHeliocentricTrajectory()
        }
    }

    private func buildEarthRelativeTrajectory() {

        guard let startDate = makeUTCDate(year: 2029, month: 4, day: 12, hour: 0, minute: 0),
              let endDate = makeUTCDate(year: 2029, month: 4, day: 15, hour: 0, minute: 0) else {
            return
        }

        let sampleInterval: TimeInterval = 5.0 * 60.0

        var vertices: [SCNVector3] = []
        var sampleDate = startDate

        while sampleDate <= endDate {

            if let asteroidPositionAU = NearEarthAsteroidAstronomy.heliocentricPositionAU(for: asteroid, date: sampleDate),
               let earthPositionAU = NearEarthAsteroidAstronomy.earthHeliocentricPositionAU(for: asteroid, date: sampleDate) {

                let geocentricPositionAU = asteroidPositionAU - earthPositionAU
                vertices.append(earthMoonScenePosition(from: geocentricPositionAU))
            }

            sampleDate = sampleDate.addingTimeInterval(sampleInterval)
        }

        createTrajectoryGeometry(
            vertices: vertices,
            colour: UIColor.systemCyan,
            description: "Earth-relative flyby"
        )
    }

    private func buildHeliocentricTrajectory() {

        guard let ephemeris = NearEarthAsteroidAstronomy.longTermEphemeris(for: asteroid) else {
            print("NEA LONG-TERM TRAJECTORY: No long-term ephemeris for \(asteroid.name)")
            return
        }

        let encounterJD = Astronomy.julianDate(for: asteroid.encounterDate)

        guard let encounterPositionAU = NearEarthAsteroidAstronomy.longTermPositionAU(for: asteroid, date: asteroid.encounterDate) else {
            print("NEA LONG-TERM TRAJECTORY: Unable to interpolate encounter position for \(asteroid.name)")
            return
        }

        let encounterVertex = heliocentricScenePosition(from: encounterPositionAU)

        let preEncounterPoints = ephemeris.points.filter { $0.julianDate < encounterJD }
        let postEncounterPoints = ephemeris.points.filter { $0.julianDate > encounterJD }

        var preEncounterVertices = preEncounterPoints.map { heliocentricScenePosition(from: $0.positionAU) }
        var postEncounterVertices = postEncounterPoints.map { heliocentricScenePosition(from: $0.positionAU) }

        preEncounterVertices.append(encounterVertex)
        postEncounterVertices.insert(encounterVertex, at: 0)

        let preEncounterNode = createTrajectoryNode(
            vertices: preEncounterVertices,
            colour: UIColor.systemCyan,
            name: "\(asteroid.name)-pre-encounter-trajectory"
        )

        let postEncounterNode = createTrajectoryNode(
            vertices: postEncounterVertices,
            colour: UIColor.systemOrange,
            name: "\(asteroid.name)-post-encounter-trajectory"
        )

        if let preEncounterNode {
            trajectoryNode.addChildNode(preEncounterNode)
        }

        if let postEncounterNode {
            trajectoryNode.addChildNode(postEncounterNode)
        }

#if DEBUG
        print("")
        print("================ NEA LONG-TERM TRAJECTORY =============")
        print("Object: \(asteroid.name)")
        print("Encounter JD: \(String(format: "%.9f", encounterJD))")
        print("Total ephemeris points: \(ephemeris.points.count)")
        print("Pre-encounter data points: \(preEncounterPoints.count)")
        print("Post-encounter data points: \(postEncounterPoints.count)")
        print("Pre-encounter vertices: \(preEncounterVertices.count)")
        print("Post-encounter vertices: \(postEncounterVertices.count)")
        print("Exact encounter vertex shared: YES")
        print("Display mode: \(displayMode.rawValue)")
        print("Pre-encounter: CYAN")
        print("Post-encounter: ORANGE")
        print("=======================================================")
        print("")
#endif
    }

    private func createTrajectoryNode(vertices: [SCNVector3], colour: UIColor, name: String) -> SCNNode? {

        guard vertices.count >= 2 else { return nil }

        let source = SCNGeometrySource(vertices: vertices)

        var indices: [Int32] = []
        indices.reserveCapacity((vertices.count - 1) * 2)

        for index in 0..<(vertices.count - 1) {
            indices.append(Int32(index))
            indices.append(Int32(index + 1))
        }

        let data = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)

        let element = SCNGeometryElement(
            data: data,
            primitiveType: .line,
            primitiveCount: vertices.count - 1,
            bytesPerIndex: MemoryLayout<Int32>.size
        )

        let geometry = SCNGeometry(sources: [source], elements: [element])

        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.emission.contents = colour
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.transparency = 0.90

        geometry.materials = [material]

        let node = SCNNode(geometry: geometry)
        node.name = name

        return node
    }

    private func createTrajectoryGeometry(vertices: [SCNVector3], colour: UIColor, description: String) {

        guard vertices.count >= 2 else {
            print("NEA TRAJECTORY: Insufficient trajectory points for \(asteroid.name)")
            return
        }

        let source = SCNGeometrySource(vertices: vertices)

        var indices: [Int32] = []
        indices.reserveCapacity((vertices.count - 1) * 2)

        for index in 0..<(vertices.count - 1) {
            indices.append(Int32(index))
            indices.append(Int32(index + 1))
        }

        let data = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)

        let element = SCNGeometryElement(
            data: data,
            primitiveType: .line,
            primitiveCount: vertices.count - 1,
            bytesPerIndex: MemoryLayout<Int32>.size
        )

        let geometry = SCNGeometry(sources: [source], elements: [element])

        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.emission.contents = colour
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.transparency = 0.85

        geometry.materials = [material]

        trajectoryNode.geometry = geometry

#if DEBUG
        print("")
        print("================ NEA TRAJECTORY =======================")
        print("Object: \(asteroid.name)")
        print("Type: \(description)")
        print("Vertices: \(vertices.count)")
        print("Display mode: \(displayMode.rawValue)")
        print("=======================================================")
        print("")
#endif
    }

    var trajectory: SCNNode? {
        guard trajectoryNode.geometry != nil || !trajectoryNode.childNodes.isEmpty else { return nil }
        return trajectoryNode
    }

    // ============================================================
    // MARK: - UPDATE
    // ============================================================

    func setVisible(_ visible: Bool) {
        isVisible = visible
        applyVisibility()
    }

    private func applyVisibility() {
        // The moving body and label share a root; the fixed trajectory is
        // attached separately to SolarSystemBuilder's stationary parent.
        rootNode.isHidden = !isVisible || !hasValidPosition
        trajectoryNode.isHidden = !isVisible
    }

    func update(for date: Date) {
        hasValidPosition = false

        // Resolve visibility on every exit, including missing ephemeris data.
        defer { applyVisibility() }

        guard let heliocentricPositionAU = NearEarthAsteroidAstronomy.heliocentricPositionAU(for: asteroid, date: date) else {
            return
        }

        if displayMode == .earthMoon {
            guard let earthPositionAU = NearEarthAsteroidAstronomy.earthHeliocentricPositionAU(for: asteroid, date: date) else {
                return
            }
            
            let geocentricPositionAU = heliocentricPositionAU - earthPositionAU
            rootNode.position = earthMoonScenePosition(from: geocentricPositionAU)
        } else {
            rootNode.position = heliocentricScenePosition(from: heliocentricPositionAU)
        }

        hasValidPosition = true
    }

    // ============================================================
    // MARK: - POSITION CONVERSION
    // ============================================================

    private func heliocentricScenePosition(from positionAU: SIMD3<Double>) -> SCNVector3 {
        let scale = astronomicalUnitsToSceneUnits

        return SCNVector3(
            Float(positionAU.x * scale),
            Float(positionAU.z * scale),
            Float(positionAU.y * scale)
        )
    }

    private func earthMoonScenePosition(from positionAU: SIMD3<Double>) -> SCNVector3 {
        let astronomicalUnitKM = 149_597_870.7
        let earthRadiusKM = 6_371.0
        let displayedEarthRadius = 0.020
        let sceneUnitsPerKM = displayedEarthRadius / earthRadiusKM

        let xKM = positionAU.x * astronomicalUnitKM
        let yKM = positionAU.y * astronomicalUnitKM
        let zKM = positionAU.z * astronomicalUnitKM

        return SCNVector3(
            Float(xKM * sceneUnitsPerKM),
            Float(zKM * sceneUnitsPerKM),
            Float(yKM * sceneUnitsPerKM)
        )
    }

    // ============================================================
    // MARK: - DATE
    // ============================================================

    private func makeUTCDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date? {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0
        return components.date
    }

    // ============================================================
    // MARK: - DISPLAY SCALE
    // ============================================================

    private var locatorRadius: CGFloat {
        switch displayMode {
        case .compact:
            return 0.015
        case .relativeSizes:
            return 0.015
        case .astronomicalDistances:
            return 0.010
        case .realisticSpacing:
            return 0.020
        case .trueBodiesAstronomicalDistances:
            return 0.015
        case .earthMoon:
            return 0.015
        }
    }

    private var astronomicalUnitsToSceneUnits: Double {
        switch displayMode {
        case .compact:
            return 1.20
        case .relativeSizes:
            return 1.20
        case .astronomicalDistances:
            return 0.25
        case .realisticSpacing:
            return 13.44
        case .trueBodiesAstronomicalDistances:
            return 1.00
        case .earthMoon:
            return 1.20
        }
    }

    // ============================================================
    // MARK: - PHYSICAL BODY SCALE
    // ============================================================

    private var hasMeaningfulPhysicalBodyScale: Bool {
        switch displayMode {
        case .relativeSizes, .trueBodiesAstronomicalDistances, .earthMoon:
            return true

        case .compact, .astronomicalDistances, .realisticSpacing:
            return false
        }
    }

    private var physicalDisplayRadius: CGFloat {

        let asteroidRadiusKM = asteroid.diameterKM / 2.0

        switch displayMode {

        case .relativeSizes, .trueBodiesAstronomicalDistances:
            let sunRadiusKM = 1_391_400.0 / 2.0
            let displayedSunRadius = 0.25
            return displayedSunRadius * CGFloat(asteroidRadiusKM / sunRadiusKM)

        case .earthMoon:
            let earthRadiusKM = 6_371.0
            let displayedEarthRadius = 0.020
            return displayedEarthRadius * CGFloat(asteroidRadiusKM / earthRadiusKM)

        case .compact, .astronomicalDistances, .realisticSpacing:
            return 0.0
        }
    }

#if DEBUG
    private func debugBodyScale() {

        print("")
        print("================ NEA BODY SCALE =======================")
        print("Object: \(asteroid.name)")
        print("Display mode: \(displayMode.rawValue)")
        print(String(format: "Physical diameter: %.6f km", asteroid.diameterKM))

        if hasMeaningfulPhysicalBodyScale {
            print("Body: PHYSICAL")
            print(String(format: "SCNSphere radius: %.12f scene units", Double(physicalDisplayRadius)))
            print(String(format: "SCNSphere diameter: %.12f scene units", Double(physicalDisplayRadius * 2.0)))
        } else {
            print("Body: HIDDEN — no compatible physical body scale")
        }

        print("Locator: YES")
        print(String(format: "Locator radius: %.6f scene units", Double(locatorRadius)))
        print("=======================================================")
        print("")
    }
#endif

}


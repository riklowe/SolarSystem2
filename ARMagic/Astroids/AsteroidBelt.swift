//
//  AsteroidBelt.swift
//  SolarSystem2
//

import SceneKit
import UIKit

enum AsteroidBelt {

    static let moduleName = (#file).components(separatedBy: "/")

    // ============================================================
    // MARK: - CREATE BELT
    // ============================================================

    static func createAsteroidBelt(asteroidCount: Int = 200) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let beltNode = SCNNode()
        beltNode.name = "asteroidBelt"

        var generator = SeededGenerator(seed: 123456789)

        for index in 0..<asteroidCount {

            let orbitalRadius = randomOrbitalRadius(using: &generator)
            let angle = Double.random(in: 0...(Double.pi * 2.0), using: &generator)

            // Small eccentricity gives a less artificial circular appearance.
            let eccentricity = Double.random(in: 0.0...0.10, using: &generator)

            // Give the belt some vertical thickness.
            let inclination = Double.random(in: -0.065...0.065, using: &generator)

            let radiusAtAngle = orbitalRadius * (1.0 - eccentricity * cos(angle))

            let x = radiusAtAngle * cos(angle)
            let z = radiusAtAngle * sin(angle)

            // Inclination produces a 3D belt rather than a flat disc.
            let y = radiusAtAngle * sin(inclination) * sin(angle)

            let asteroidRadius = randomAsteroidSize(using: &generator)

            let geometry = SCNSphere(radius: asteroidRadius)

            // Low segment count gives a slightly rocky/faceted appearance
            // and is cheaper than a smooth sphere.
            geometry.segmentCount = 5

            let material = SCNMaterial()
            let asteroidColor = randomAsteroidColor(using: &generator)

            material.diffuse.contents = asteroidColor

            // Small emission component keeps the asteroid visible with
            // the deliberately low Sun intensity used by the simulation.
            material.emission.contents = asteroidColor
            material.emission.intensity = 0.35

            material.lightingModel = .lambert

            geometry.materials = [material]

            let asteroidNode = SCNNode(geometry: geometry)
            asteroidNode.name = "beltAsteroid_\(index)"
            asteroidNode.position = SCNVector3(Float(x), Float(y), Float(z))

            // Give each asteroid a deterministic random orientation.
            asteroidNode.eulerAngles = SCNVector3(
                Float.random(in: 0...(Float.pi * 2.0), using: &generator),
                Float.random(in: 0...(Float.pi * 2.0), using: &generator),
                Float.random(in: 0...(Float.pi * 2.0), using: &generator)
            )

            // Make the spheres slightly irregular.
            let scaleX = Float.random(in: 0.30...0.70, using: &generator)
            let scaleY = Float.random(in: 0.40...0.80, using: &generator)
            let scaleZ = Float.random(in: 0.50...0.90, using: &generator)

            asteroidNode.scale = SCNVector3(scaleX, scaleY, scaleZ)

            beltNode.addChildNode(asteroidNode)
        }

        printLog("Asteroid belt created: \(beltNode.childNodes.count) asteroids")

        return beltNode
    }

    // ============================================================
    // MARK: - ORBITAL DISTRIBUTION
    // ============================================================

    private static func randomOrbitalRadius(using generator: inout SeededGenerator) -> Double {

        while true {

            // Our compressed visual belt between Mars and Jupiter.
            let radius = Double.random(in: 1.76...2.20, using: &generator)

            // Approximate visual gaps to prevent the belt looking like
            // a completely uniform ring.
            if radius > 1.865 && radius < 1.885 { continue }
            if radius > 1.955 && radius < 1.975 { continue }
            if radius > 2.045 && radius < 2.065 { continue }
            if radius > 2.135 && radius < 2.155 { continue }

            return radius
        }
    }

    // ============================================================
    // MARK: - SIZE DISTRIBUTION
    // ============================================================

    private static func randomAsteroidSize(using generator: inout SeededGenerator) -> CGFloat {

        let chance = Double.random(in: 0...1, using: &generator)

        // Most asteroids are small.
        if chance < 0.85 {
            return CGFloat.random(in: 0.006...0.009, using: &generator)
        }

        // Some medium objects.
        if chance < 0.98 {
            return CGFloat.random(in: 0.009...0.013, using: &generator)
        }

        // Occasional larger background object.
        return CGFloat.random(in: 0.013...0.017, using: &generator)
    }

    // ============================================================
    // MARK: - COLOUR
    // ============================================================

    private static func randomAsteroidColor(using generator: inout SeededGenerator) -> UIColor {

        let choice = Int.random(in: 0...4, using: &generator)

        switch choice {

        case 0:
            return UIColor(red: 0.42, green: 0.40, blue: 0.37, alpha: 1.0)

        case 1:
            return UIColor(red: 0.50, green: 0.46, blue: 0.40, alpha: 1.0)

        case 2:
            return UIColor(red: 0.36, green: 0.35, blue: 0.34, alpha: 1.0)

        case 3:
            return UIColor(red: 0.55, green: 0.50, blue: 0.43, alpha: 1.0)

        default:
            return UIColor(red: 0.44, green: 0.42, blue: 0.39, alpha: 1.0)
        }
    }
}

// ============================================================
// MARK: - SEEDED RANDOM GENERATOR
// ============================================================

struct SeededGenerator: RandomNumberGenerator {

    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

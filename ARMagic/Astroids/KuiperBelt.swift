//
//  KuiperBelt.swift
//  ARMagic
//
//  Created by Richard Lowe on 22/09/2026.
//  Copyright © 2026 Alex Nagy. All rights reserved.
//

//
//  KuiperBelt.swift
//  SolarSystem2
//

import Foundation
import SceneKit
import UIKit

final class KuiperBelt {

    private enum Population {
        case coldClassical
        case hotClassical
        case resonant
        case scattered
    }

    static let moduleName = (#file).components(separatedBy: "/")

    // ============================================================
    // MARK: - DISPLAY SCALE
    // ============================================================

    //
    // Compact / True Body Scale:
    //
    // Keep the belt just beyond Neptune / Pluto in the compressed
    // Solar System layout so it remains visible and useful in AR.
    //
    // AU Orbit Spacing:
    //
    // The builder supplies a larger scale so the belt sits at an
    // appropriate distance relative to Neptune's AU-scaled orbit.
    //

    private static let compactScale: Float = 0.72
    private static let astronomicalScale: Float = 1.00

    private static let objectCount = 700

    private static let minimumRadius: CGFloat = 0.0025
    private static let maximumRadius: CGFloat = 0.0060

    // ============================================================
    // MARK: - CREATE
    // ============================================================

    static func create(displayMode: SolarSystemDisplayMode = .compact) -> SCNNode {

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let beltNode = SCNNode()
        beltNode.name = "kuiper_belt"

        let distanceScale: Float

        switch displayMode {

        case .astronomicalDistances:
            distanceScale = astronomicalScale

        case .compact, .relativeSizes:
            distanceScale = compactScale

        case .earthMoon:
            distanceScale = compactScale
        }

        var generator = KuiperBeltSeededGenerator(
            seed: 0x4B5549504552
        )

        for index in 0..<objectCount {

            let population = population(
                for: index
            )

            let objectNode = createObject(
                index: index,
                population: population,
                distanceScale: distanceScale,
                generator: &generator
            )

            beltNode.addChildNode(
                objectNode
            )
        }

        return beltNode
    }

    // ============================================================
    // MARK: - POPULATION
    // ============================================================

    private static func population(
        for index: Int
    ) -> Population {

        let fraction =
            Float(index)
            / Float(objectCount)

        if fraction < 0.40 {
            return .coldClassical
        }

        if fraction < 0.65 {
            return .hotClassical
        }

        if fraction < 0.85 {
            return .resonant
        }

        return .scattered
    }

    // ============================================================
    // MARK: - OBJECT
    // ============================================================

    private static func createObject(
        index: Int,
        population: Population,
        distanceScale: Float,
        generator: inout KuiperBeltSeededGenerator
    ) -> SCNNode {

        let semiMajorAxis: Float
        let eccentricity: Float
        let inclinationDegrees: Float

        switch population {

        case .coldClassical:

            semiMajorAxis =
                random(
                    in: 6.70...7.80,
                    using: &generator
                )
                * distanceScale

            eccentricity =
                random(
                    in: 0.0...0.08,
                    using: &generator
                )

            inclinationDegrees =
                random(
                    in: -5.0...5.0,
                    using: &generator
                )

        case .hotClassical:

            semiMajorAxis =
                random(
                    in: 6.50...8.00,
                    using: &generator
                )
                * distanceScale

            eccentricity =
                random(
                    in: 0.02...0.20,
                    using: &generator
                )

            inclinationDegrees =
                random(
                    in: -25.0...25.0,
                    using: &generator
                )

        case .resonant:

            semiMajorAxis =
                random(
                    in: 6.00...8.20,
                    using: &generator
                )
                * distanceScale

            eccentricity =
                random(
                    in: 0.08...0.30,
                    using: &generator
                )

            inclinationDegrees =
                random(
                    in: -30.0...30.0,
                    using: &generator
                )

        case .scattered:

            semiMajorAxis =
                random(
                    in: 7.50...11.00,
                    using: &generator
                )
                * distanceScale

            eccentricity =
                random(
                    in: 0.20...0.55,
                    using: &generator
                )

            inclinationDegrees =
                random(
                    in: -35.0...35.0,
                    using: &generator
                )
        }

        let inclination =
            inclinationDegrees
            * Float.pi
            / 180.0

        let ascendingNode =
            random(
                in: 0.0...(Float.pi * 2.0),
                using: &generator
            )

        let argumentPeriapsis =
            random(
                in: 0.0...(Float.pi * 2.0),
                using: &generator
            )

        let eccentricAnomaly =
            random(
                in: 0.0...(Float.pi * 2.0),
                using: &generator
            )

        let xOrbital =
            semiMajorAxis
            * (
                cos(eccentricAnomaly)
                - eccentricity
            )

        let zOrbital =
            semiMajorAxis
            * sqrt(
                1.0
                - eccentricity
                * eccentricity
            )
            * sin(eccentricAnomaly)

        let x1 =
            xOrbital
            * cos(argumentPeriapsis)
            - zOrbital
            * sin(argumentPeriapsis)

        let z1 =
            xOrbital
            * sin(argumentPeriapsis)
            + zOrbital
            * cos(argumentPeriapsis)

        let x2 = x1

        let y2 =
            z1
            * sin(inclination)

        let z2 =
            z1
            * cos(inclination)

        let x3 =
            x2
            * cos(ascendingNode)
            - z2
            * sin(ascendingNode)

        let z3 =
            x2
            * sin(ascendingNode)
            + z2
            * cos(ascendingNode)

        let radius = CGFloat(
            random(
                in: Float(minimumRadius)...Float(maximumRadius),
                using: &generator
            )
        )

        let sphere =
            SCNSphere(
                radius: radius
            )

        sphere.segmentCount = 6

        let material =
            SCNMaterial()

        material.lightingModel =
            .constant

        let brightness =
            CGFloat(
                random(
                    in: 0.40...0.85,
                    using: &generator
                )
            )

        material.diffuse.contents =
            UIColor(
                white: brightness,
                alpha: 1.0
            )

        material.emission.contents =
            UIColor(
                white: brightness * 0.40,
                alpha: 1.0
            )

        sphere.materials = [
            material
        ]

        let node =
            SCNNode(
                geometry: sphere
            )

        node.name =
            "kbo_\(index)"

        node.position =
            SCNVector3(
                x3,
                y2,
                z3
            )

        return node
    }

    // ============================================================
    // MARK: - RANDOM
    // ============================================================

    private static func random(
        in range: ClosedRange<Float>,
        using generator: inout KuiperBeltSeededGenerator
    ) -> Float {

        let value =
            Float(generator.next())
            / Float(UInt64.max)

        return range.lowerBound
            + (
                range.upperBound
                - range.lowerBound
            )
            * value
    }
}

// ============================================================
// MARK: - DETERMINISTIC RANDOM GENERATOR
// ============================================================

private struct KuiperBeltSeededGenerator: RandomNumberGenerator {

    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {

        state &+=
            0x9E3779B97F4A7C15

        var value = state

        value =
            (value ^ (value >> 30))
            &* 0xBF58476D1CE4E5B9

        value =
            (value ^ (value >> 27))
            &* 0x94D049BB133111EB

        return value
            ^ (value >> 31)
    }
}

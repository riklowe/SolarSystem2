//
//  Astronomy.swift
//  SolarSystem2
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

import Foundation

enum Astronomy {

    static let  moduleName = (#file).components(separatedBy: "/")

    static func julianDate(for date: Date) -> Double { return 2440587.5 + date.timeIntervalSince1970 / 86400.0 }

    static func radians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }

    static func degrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }

    static func normaliseDegrees(_ degrees: Double) -> Double {
        var result = degrees.truncatingRemainder(dividingBy: 360.0)
        if result < 0 { result += 360.0 }
        return result
    }

    static func eccentricAnomaly(meanAnomaly: Double, eccentricity: Double) -> Double {
        let M = radians(meanAnomaly)
        var E = M
        for _ in 0..<12 { E -= (E - eccentricity * sin(E) - M) / (1.0 - eccentricity * cos(E)) }
        return E
    }
}

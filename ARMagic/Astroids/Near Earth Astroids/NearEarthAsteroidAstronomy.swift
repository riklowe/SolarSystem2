//
//  NearEarthAsteroidAstronomy.swift
//  SolarSystem2
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

import Foundation
import simd

enum NearEarthAsteroidAstronomy {

    private static var ephemerisCache: [String: NearEarthEphemeris] = [:]

    // ============================================================
    // MARK: - PUBLIC POSITION
    // ============================================================

    static func heliocentricPositionAU(for asteroid: NearEarthAsteroid, date: Date) -> SIMD3<Double>? {

        guard let ephemeris = ephemeris(for: asteroid) else {
            return nil
        }

        return interpolatedPositionAU(in: ephemeris, date: date)
    }

    // ============================================================
    // MARK: - EPHEMERIS
    // ============================================================

    static func ephemeris(for asteroid: NearEarthAsteroid) -> NearEarthEphemeris? {

        if let cached = ephemerisCache[asteroid.ephemerisResourceName] {
            return cached
        }

        guard let url = Bundle.main.url(forResource: asteroid.ephemerisResourceName, withExtension: "json") else {
            print("NEA ephemeris resource not found: \(asteroid.ephemerisResourceName).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let ephemeris = try JSONDecoder().decode(NearEarthEphemeris.self, from: data)

            guard !ephemeris.points.isEmpty else {
                print("NEA ephemeris contains no points: \(asteroid.ephemerisResourceName).json")
                return nil
            }

            let sortedPoints = ephemeris.points.sorted { $0.julianDate < $1.julianDate }

            let sortedEphemeris = NearEarthEphemeris(
                designation: ephemeris.designation,
                source: ephemeris.source,
                referenceFrame: ephemeris.referenceFrame,
                centre: ephemeris.centre,
                points: sortedPoints
            )

            ephemerisCache[asteroid.ephemerisResourceName] = sortedEphemeris

            return sortedEphemeris

        } catch {
            print("Failed to load NEA ephemeris \(asteroid.ephemerisResourceName).json: \(error)")
            return nil
        }
    }

    // ============================================================
    // MARK: - HERMITE INTERPOLATION
    // ============================================================

    private static func interpolatedPositionAU(in ephemeris: NearEarthEphemeris, date: Date) -> SIMD3<Double>? {

        let julianDate = Astronomy.julianDate(for: date)
        let points = ephemeris.points

        guard let first = points.first, let last = points.last else {
            return nil
        }

        guard julianDate >= first.julianDate, julianDate <= last.julianDate else {
            return nil
        }

        if julianDate == first.julianDate {
            return first.positionAU
        }

        if julianDate == last.julianDate {
            return last.positionAU
        }

        guard let interval = surroundingPoints(for: julianDate, in: points) else {
            return nil
        }

        return hermitePositionAU(
            julianDate: julianDate,
            first: interval.0,
            second: interval.1
        )
    }

    // ============================================================
    // MARK: - BINARY SEARCH
    // ============================================================

    private static func surroundingPoints(for julianDate: Double, in points: [NearEarthEphemerisPoint]) -> (NearEarthEphemerisPoint, NearEarthEphemerisPoint)? {

        guard points.count >= 2 else {
            return nil
        }

        var low = 0
        var high = points.count - 1

        while high - low > 1 {
            let middle = (low + high) / 2

            if points[middle].julianDate <= julianDate {
                low = middle
            } else {
                high = middle
            }
        }

        return (points[low], points[high])
    }

    // ============================================================
    // MARK: - GENERIC EPHEMERIS LOADING
    // ============================================================

    private static func loadEphemeris(resourceName: String) -> NearEarthEphemeris? {

        if let cached = ephemerisCache[resourceName] {
            return cached
        }

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            print("Ephemeris resource not found: \(resourceName).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let ephemeris = try JSONDecoder().decode(NearEarthEphemeris.self, from: data)

            let sortedPoints = ephemeris.points.sorted { $0.julianDate < $1.julianDate }

            let sortedEphemeris = NearEarthEphemeris(
                designation: ephemeris.designation,
                source: ephemeris.source,
                referenceFrame: ephemeris.referenceFrame,
                centre: ephemeris.centre,
                points: sortedPoints
            )

            ephemerisCache[resourceName] = sortedEphemeris

            return sortedEphemeris

        } catch {
            print("Failed to load ephemeris \(resourceName).json: \(error)")
            return nil
        }
    }

    // ============================================================
    // MARK: - LONG-TERM TRAJECTORY
    // ============================================================

    static func longTermEphemeris(for asteroid: NearEarthAsteroid) -> NearEarthEphemeris? {

        switch asteroid.designation {

        case "99942 Apophis":
            return loadEphemeris(resourceName: "apophis_longterm")

        default:
            return nil
        }
    }

    static func longTermPositionAU(for asteroid: NearEarthAsteroid, date: Date) -> SIMD3<Double>? {
        guard let ephemeris = longTermEphemeris(for: asteroid) else { return nil }
        return interpolatedPositionAU(in: ephemeris, date: date)
    }

    // ============================================================
    // MARK: - EARTH POSITION
    // ============================================================

    static func earthHeliocentricPositionAU(date: Date) -> SIMD3<Double>? {

        guard let ephemeris = loadEphemeris(resourceName: "earth-2029-encounter") else {
            return nil
        }

        return interpolatedPositionAU(in: ephemeris, date: date)
    }

#if DEBUG
static func debugApophisLongTermOrbitChange() {

    guard let ephemeris = longTermEphemeris(for: NearEarthAsteroidData.apophis) else {
        print("APOPHIS ORBIT CHANGE: Long-term ephemeris not available")
        return
    }

    let encounterJD = Astronomy.julianDate(for: NearEarthAsteroidData.apophis.encounterDate)

    guard let before = ephemeris.points.last(where: { $0.julianDate < encounterJD }),
          let after = ephemeris.points.first(where: { $0.julianDate > encounterJD }) else {
        print("APOPHIS ORBIT CHANGE: Could not locate points around encounter")
        return
    }

    let beforeDistance = simd_length(before.positionAU)
    let afterDistance = simd_length(after.positionAU)

    let beforeSpeed = simd_length(before.velocityAUPerDay)
    let afterSpeed = simd_length(after.velocityAUPerDay)

    let beforeDirection = simd_normalize(before.velocityAUPerDay)
    let afterDirection = simd_normalize(after.velocityAUPerDay)

    let dot = max(-1.0, min(1.0, simd_dot(beforeDirection, afterDirection)))
    let directionChangeDegrees = acos(dot) * 180.0 / Double.pi

    print("")
    print("================ APOPHIS ORBIT CHANGE =================")
    print("Encounter JD: \(String(format: "%.9f", encounterJD))")
    print("")
    print("PRE-ENCOUNTER SAMPLE")
    print("JD: \(String(format: "%.9f", before.julianDate))")
    print("Position: \(String(format: "%.9f", before.xAU))  \(String(format: "%.9f", before.yAU))  \(String(format: "%.9f", before.zAU)) AU")
    print("Sun distance: \(String(format: "%.9f", beforeDistance)) AU")
    print("Speed: \(String(format: "%.9f", beforeSpeed)) AU/day")
    print("")
    print("POST-ENCOUNTER SAMPLE")
    print("JD: \(String(format: "%.9f", after.julianDate))")
    print("Position: \(String(format: "%.9f", after.xAU))  \(String(format: "%.9f", after.yAU))  \(String(format: "%.9f", after.zAU)) AU")
    print("Sun distance: \(String(format: "%.9f", afterDistance)) AU")
    print("Speed: \(String(format: "%.9f", afterSpeed)) AU/day")
    print("")
    print("Velocity direction change between adjacent 6-hour samples:")
    print("\(String(format: "%.6f", directionChangeDegrees)) degrees")
    print("=======================================================")
    print("")
}
#endif
    
    // ============================================================
    // MARK: - APOPHIS 2029 VALIDATION
    // ============================================================

    static func debugApophis2029Encounter() {

        let asteroid = NearEarthAsteroidData.apophis

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = 2029
        components.month = 4
        components.day = 13
        components.hour = 20
        components.minute = 0
        components.second = 0

        guard let startDate = components.date else {
            print("Unable to create Apophis encounter start date")
            return
        }

        let searchDuration: TimeInterval = 4.0 * 60.0 * 60.0
        let searchStep: TimeInterval = 1.0

        var bestDate: Date?
        var bestDistanceKM = Double.greatestFiniteMagnitude
        var bestVectorAU: SIMD3<Double>?

        var elapsed: TimeInterval = 0.0

        while elapsed <= searchDuration {

            let date = startDate.addingTimeInterval(elapsed)

            if let apophisPosition = heliocentricPositionAU(for: asteroid, date: date),
               let earthPosition = earthHeliocentricPositionAU(date: date) {

                let geocentricVectorAU = apophisPosition - earthPosition
                let distanceAU = simd_length(geocentricVectorAU)
                let distanceKM = distanceAU * 149_597_870.7

                if distanceKM < bestDistanceKM {
                    bestDistanceKM = distanceKM
                    bestDate = date
                    bestVectorAU = geocentricVectorAU
                }
            }

            elapsed += searchStep
        }

        guard let bestDate, let bestVectorAU else {
            print("Unable to calculate Apophis 2029 closest approach")
            return
        }

        let earthMeanRadiusKM = 6_371.0
        let altitudeKM = bestDistanceKM - earthMeanRadiusKM

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd MMM yyyy HH:mm:ss 'UTC'"

        print("")
        print("================ APOPHIS 2029 VALIDATION ================")
        print("Closest calculated time: \(formatter.string(from: bestDate))")
        print(String(format: "Earth-centre distance: %.3f km", bestDistanceKM))
        print(String(format: "Approx surface altitude: %.3f km", altitudeKM))
        print("")
        print("Geocentric vector:")
        print(String(format: "X: %.12f AU", bestVectorAU.x))
        print(String(format: "Y: %.12f AU", bestVectorAU.y))
        print(String(format: "Z: %.12f AU", bestVectorAU.z))
        print("==========================================================")
        print("")
    }
    
    // ============================================================
    // MARK: - CUBIC HERMITE
    // ============================================================

    private static func hermitePositionAU(
        julianDate: Double,
        first: NearEarthEphemerisPoint,
        second: NearEarthEphemerisPoint
    ) -> SIMD3<Double> {

        let durationDays = second.julianDate - first.julianDate

        guard durationDays > 0 else {
            return first.positionAU
        }

        let t = (julianDate - first.julianDate) / durationDays
        let t2 = t * t
        let t3 = t2 * t

        let h00 = 2.0 * t3 - 3.0 * t2 + 1.0
        let h10 = t3 - 2.0 * t2 + t
        let h01 = -2.0 * t3 + 3.0 * t2
        let h11 = t3 - t2

        let p0 = first.positionAU
        let p1 = second.positionAU

        let m0 = first.velocityAUPerDay * durationDays
        let m1 = second.velocityAUPerDay * durationDays

        return h00 * p0 + h10 * m0 + h01 * p1 + h11 * m1
    }

    // ============================================================
    // MARK: - DIAGNOSTICS
    // ============================================================

    static func debugEphemeris(for asteroid: NearEarthAsteroid) {

        guard let ephemeris = ephemeris(for: asteroid) else {
            print("Unable to load ephemeris for \(asteroid.name)")
            return
        }

        print("")
        print("================ NEA EPHEMERIS ========================")
        print("Object: \(ephemeris.designation)")
        print("Source: \(ephemeris.source)")
        print("Frame: \(ephemeris.referenceFrame)")
        print("Centre: \(ephemeris.centre)")
        print("Points: \(ephemeris.points.count)")
        print("First JD: \(ephemeris.points.first?.julianDate ?? 0)")
        print("Last JD: \(ephemeris.points.last?.julianDate ?? 0)")
        print("=======================================================")
        print("")
    }

    static func debugPosition(for asteroid: NearEarthAsteroid, date: Date) {

        guard let position = heliocentricPositionAU(for: asteroid, date: date) else {
            print("No NEA position available for \(asteroid.name) at \(date)")
            return
        }

        let distanceFromSunAU = simd_length(position)

        print("")
        print("================ NEA POSITION =========================")
        print("Object: \(asteroid.designation)")
        print("Date: \(date)")
        print(String(format: "X: %.12f AU", position.x))
        print(String(format: "Y: %.12f AU", position.y))
        print(String(format: "Z: %.12f AU", position.z))
        print(String(format: "Sun distance: %.12f AU", distanceFromSunAU))
        print("=======================================================")
        print("")
    }
}

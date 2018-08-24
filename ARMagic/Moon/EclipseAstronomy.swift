//
//  EclipseAstronomy.swift
//  ARMagic
//
//  Created by Richard Lowe on 23/09/2026.
//  Copyright © 2026 Alex Nagy. All rights reserved.
//


//
//  EclipseAstronomy.swift
//  SolarSystem2
//

import Foundation
import simd

enum EclipseAstronomy {

    static let moduleName = (#file).components(separatedBy: "/")

    private static let astronomicalUnitKM = 149_597_870.7
    private static let earthRadiusKM = 6378.137
    private static let moonRadiusKM = 1737.4
    private static let sunRadiusKM = 695_700.0

    struct SolarGeometry {
        let surfaceDirectionEcliptic: SIMD3<Double>
        let sunMoonSeparationDegrees: Double
        let axisOffsetKM: Double
        let umbraRadiusKM: Double
        let penumbraRadiusKM: Double
        let moonDistanceKM: Double
        let sunDistanceKM: Double
        let isTotal: Bool
    }

    // ============================================================
    // MARK: - SOLAR ECLIPSE GEOMETRY
    // ============================================================

    static func solarGeometry(for date: Date) -> SolarGeometry? {

        let moon = EarthMoonAstronomy.geocentricPosition(for: date)

        guard let earth = PlanetAstronomy.heliocentricPosition(
            for: "earth",
            date: date
        ) else {
            return nil
        }

        let sunDistanceKM =
            earth.distance *
            astronomicalUnitKM

        let sceneSunLongitude =
            Astronomy.normaliseDegrees(
                earth.longitude + 180.0
            )

        let accurateSunLongitude =
            EarthMoonAstronomy.apparentSolarLongitude(
                for: date
            )

        var frameCorrection =
            sceneSunLongitude -
            accurateSunLongitude

        while frameCorrection > 180.0 {
            frameCorrection -= 360.0
        }

        while frameCorrection < -180.0 {
            frameCorrection += 360.0
        }

        let moonLongitude =
            Astronomy.normaliseDegrees(
                moon.longitude +
                frameCorrection
            )

        let moonLatitude =
            moon.latitude

        let sunLongitudeRadians =
            Astronomy.radians(
                sceneSunLongitude
            )

        let moonLongitudeRadians =
            Astronomy.radians(
                moonLongitude
            )

        let moonLatitudeRadians =
            Astronomy.radians(
                moonLatitude
            )

        let sunDirection =
            simd_normalize(
                SIMD3<Double>(
                    cos(sunLongitudeRadians),
                    sin(sunLongitudeRadians),
                    0.0
                )
            )

        let moonDirection =
            simd_normalize(
                SIMD3<Double>(
                    cos(moonLatitudeRadians) * cos(moonLongitudeRadians),
                    cos(moonLatitudeRadians) * sin(moonLongitudeRadians),
                    sin(moonLatitudeRadians)
                )
            )

        let sunPosition =
            sunDirection *
            sunDistanceKM

        let moonPosition =
            moonDirection *
            moon.distanceKM

        // Direction travelled by the lunar shadow after passing
        // from the Sun through the Moon.

        let shadowDirection =
            simd_normalize(
                moonPosition -
                sunPosition
            )

        // --------------------------------------------------------
        // Does the shadow axis intersect Earth's physical sphere?
        // --------------------------------------------------------

        let b =
            2.0 *
            simd_dot(
                moonPosition,
                shadowDirection
            )

        let c =
            simd_dot(
                moonPosition,
                moonPosition
            ) -
            earthRadiusKM *
            earthRadiusKM

        let discriminant =
            b * b -
            4.0 * c

        guard discriminant >= 0.0 else {
            return nil
        }

        let sqrtDiscriminant =
            sqrt(
                discriminant
            )

        let t1 =
            (-b - sqrtDiscriminant) /
            2.0

        let t2 =
            (-b + sqrtDiscriminant) /
            2.0

        let validDistances =
            [t1, t2]
                .filter {
                    $0 > 0.0
                }

        guard let shadowTravelDistance =
            validDistances.min()
        else {
            return nil
        }

        let intersection =
            moonPosition +
            shadowDirection *
            shadowTravelDistance

        let surfaceDirection =
            simd_normalize(
                intersection
            )

        // --------------------------------------------------------
        // Shadow-axis distance from centre of Earth.
        // --------------------------------------------------------

        let axisOffsetKM =
            simd_length(
                simd_cross(
                    moonPosition,
                    shadowDirection
                )
            )

        // --------------------------------------------------------
        // Umbra / antumbra cone at Earth's surface.
        // --------------------------------------------------------

        let sunMoonDistance =
            simd_distance(
                sunPosition,
                moonPosition
            )

        let umbraRadius =
            moonRadiusKM -
            shadowTravelDistance *
            (
                sunRadiusKM -
                moonRadiusKM
            ) /
            sunMoonDistance

        let penumbraRadius =
            moonRadiusKM +
            shadowTravelDistance *
            (
                sunRadiusKM +
                moonRadiusKM
            ) /
            sunMoonDistance

        // --------------------------------------------------------
        // Sun / Moon angular separation as seen from Earth's centre.
        // --------------------------------------------------------

        let angularDot =
            max(
                -1.0,
                min(
                    1.0,
                    simd_dot(
                        sunDirection,
                        moonDirection
                    )
                )
            )

        let separationDegrees =
            Astronomy.degrees(
                acos(
                    angularDot
                )
            )

        return SolarGeometry(
            surfaceDirectionEcliptic: surfaceDirection,
            sunMoonSeparationDegrees: separationDegrees,
            axisOffsetKM: axisOffsetKM,
            umbraRadiusKM: abs(umbraRadius),
            penumbraRadiusKM: penumbraRadius,
            moonDistanceKM: moon.distanceKM,
            sunDistanceKM: sunDistanceKM,
            isTotal: umbraRadius >= 0.0
        )
    }

    // ============================================================
    // MARK: - DIAGNOSTIC
    // ============================================================

    static func logSolarGeometry(for date: Date) {

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        guard let geometry = solarGeometry(for: date) else {
            print("ECLIPSE GEOMETRY: Shadow axis does not intersect Earth")
            return
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd MMM yyyy HH:mm:ss"

        print("")
        print("================ ECLIPSE GEOMETRY =================")
        print("UTC: \(formatter.string(from: date))")
        print(String(format: "Sun/Moon separation: %.6f°", geometry.sunMoonSeparationDegrees))
        print(String(format: "Shadow axis offset:  %.1f km", geometry.axisOffsetKM))
        print(String(format: "Umbra radius:        %.1f km", geometry.umbraRadiusKM))
        print(String(format: "Penumbra radius:     %.1f km", geometry.penumbraRadiusKM))
        print("Type: \(geometry.isTotal ? "TOTAL / UMBRA" : "ANNULAR / ANTUMBRA")")
        print("===================================================")
        print("")
    }

    // ============================================================
    // MARK: - GEOGRAPHIC SHADOW POSITION
    // ============================================================

    static func geographicShadowPosition(for date: Date) -> (latitude: Double, longitude: Double)? {

        guard let geometry = solarGeometry(for: date) else {
            return nil
        }

        let direction = simd_normalize(
            geometry.surfaceDirectionEcliptic
        )

        // --------------------------------------------------------
        // Ecliptic -> equatorial
        //
        // surfaceDirectionEcliptic uses conventional astronomy:
        //
        // x = ecliptic X
        // y = ecliptic Y
        // z = north ecliptic pole
        // --------------------------------------------------------

        let obliquity = Astronomy.radians(
            23.4392911
        )

        let xEquatorial =
            direction.x

        let yEquatorial =
            direction.y * cos(obliquity)
            - direction.z * sin(obliquity)

        let zEquatorial =
            direction.y * sin(obliquity)
            + direction.z * cos(obliquity)

        let rightAscension =
            atan2(
                yEquatorial,
                xEquatorial
            )

        let declination =
            asin(
                max(
                    -1.0,
                    min(
                        1.0,
                        zEquatorial
                    )
                )
            )

        // --------------------------------------------------------
        // Greenwich Mean Sidereal Time
        // --------------------------------------------------------

        let julianDate =
            Astronomy.julianDate(
                for: date
            )

        let d =
            julianDate
            - 2451545.0

        let T =
            d / 36525.0

        var gmstDegrees =
            280.46061837
            + 360.98564736629 * d
            + 0.000387933 * T * T
            - T * T * T / 38710000.0

        gmstDegrees =
            Astronomy.normaliseDegrees(
                gmstDegrees
            )

        var rightAscensionDegrees =
            Astronomy.degrees(
                rightAscension
            )

        rightAscensionDegrees =
            Astronomy.normaliseDegrees(
                rightAscensionDegrees
            )

        // Geographic longitude:
        //
        // east positive
        // west negative
        var longitudeDegrees =
            rightAscensionDegrees
            - gmstDegrees

        while longitudeDegrees > 180.0 {
            longitudeDegrees -= 360.0
        }

        while longitudeDegrees < -180.0 {
            longitudeDegrees += 360.0
        }

        let latitudeDegrees =
            Astronomy.degrees(
                declination
            )

        return (
            latitude: latitudeDegrees,
            longitude: longitudeDegrees
        )
    }

    // ============================================================
    // MARK: - GEOGRAPHIC SHADOW DIAGNOSTIC
    // ============================================================

    static func logGeographicShadowPosition(for date: Date) {

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier: "en_GB"
            )

        formatter.timeZone =
            TimeZone(
                secondsFromGMT: 0
            )

        formatter.dateFormat =
            "dd MMM yyyy HH:mm:ss"

        print("")
        print("================ ECLIPSE GEOGRAPHIC TEST ================")
        print("UTC: \(formatter.string(from: date))")

        guard let position =
            geographicShadowPosition(
                for: date
            )
        else {
            print("Shadow axis does not intersect Earth.")
            print("=========================================================")
            print("")
            return
        }

        print(
            String(
                format:
                    "Latitude:  %+.6f°",
                position.latitude
            )
        )

        print(
            String(
                format:
                    "Longitude: %+.6f°",
                position.longitude
            )
        )

        print("=========================================================")
        print("")
    }

    // ============================================================
    // MARK: - ECLIPSE CONTACT DIAGNOSTIC
    // ============================================================

    static func logSolarContactTimes(around date: Date) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let searchStart = date.addingTimeInterval(-3.0 * 3600.0)
        let searchEnd = date.addingTimeInterval(3.0 * 3600.0)

        let coarseStep: TimeInterval = 60.0

        var previousDate = searchStart
        var previousIntersects = solarGeometry(for: previousDate) != nil

        var transitions: [(before: Date, after: Date, entering: Bool)] = []

        var testDate = searchStart.addingTimeInterval(coarseStep)

        while testDate <= searchEnd {
            let intersects = solarGeometry(for: testDate) != nil

            if intersects != previousIntersects {
                transitions.append(
                    (
                        before: previousDate,
                        after: testDate,
                        entering: intersects
                    )
                )
            }

            previousDate = testDate
            previousIntersects = intersects
            testDate = testDate.addingTimeInterval(coarseStep)
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd MMM yyyy HH:mm:ss.SSS"

        print("")
        print("================ ECLIPSE CONTACT TEST ================")

        if transitions.isEmpty {
            print("No Earth-shadow-axis transitions found.")
            print("======================================================")
            print("")
            return
        }

        for transition in transitions {
            var low = transition.before
            var high = transition.after

            // Refine from a 60-second interval down to well below 1 second.
            for _ in 0..<20 {
                let mid = Date(
                    timeIntervalSince1970:
                        (
                            low.timeIntervalSince1970 +
                            high.timeIntervalSince1970
                        ) / 2.0
                )

                let intersects = solarGeometry(for: mid) != nil

                if transition.entering {
                    if intersects {
                        high = mid
                    } else {
                        low = mid
                    }
                } else {
                    if intersects {
                        low = mid
                    } else {
                        high = mid
                    }
                }
            }

            let contactDate = transition.entering ? high : low

            if transition.entering {
                print("MODEL CENTRAL AXIS ENTERS EARTH:")
            } else {
                print("MODEL CENTRAL AXIS LEAVES EARTH:")
            }

            print("UTC: \(formatter.string(from: contactDate))")
        }

        print("======================================================")
        print("")
    }

}

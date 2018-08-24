//
//  EarthMoonAstronomy.swift
//  SolarSystem2
//

import Foundation
import SceneKit

enum EarthMoonAstronomy {

    static let moduleName = (#file).components(separatedBy: "/")

    // ============================================================
    // MARK: - PERIODIC TERMS
    // Meeus Astronomical Algorithms — lunar position series.
    // ============================================================

    private struct LongitudeDistanceTerm {
        let D: Int
        let M: Int
        let Mp: Int
        let F: Int
        let longitude: Double
        let distance: Double
    }

    private struct LatitudeTerm {
        let D: Int
        let M: Int
        let Mp: Int
        let F: Int
        let latitude: Double
    }

    private static let longitudeDistanceTerms: [LongitudeDistanceTerm] = [

        LongitudeDistanceTerm(D: 0, M: 0, Mp: 1, F: 0, longitude: 6288774, distance: -20905355),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: -1, F: 0, longitude: 1274027, distance: -3699111),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: 0, F: 0, longitude: 658314, distance: -2955968),
        LongitudeDistanceTerm(D: 0, M: 0, Mp: 2, F: 0, longitude: 213618, distance: -569925),
        LongitudeDistanceTerm(D: 0, M: 1, Mp: 0, F: 0, longitude: -185116, distance: 48888),
        LongitudeDistanceTerm(D: 0, M: 0, Mp: 0, F: 2, longitude: -114332, distance: -3149),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: -2, F: 0, longitude: 58793, distance: 246158),
        LongitudeDistanceTerm(D: 2, M: -1, Mp: -1, F: 0, longitude: 57066, distance: -152138),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: 1, F: 0, longitude: 53322, distance: -170733),
        LongitudeDistanceTerm(D: 2, M: -1, Mp: 0, F: 0, longitude: 45758, distance: -204586),
        LongitudeDistanceTerm(D: 0, M: 1, Mp: -1, F: 0, longitude: -40923, distance: -129620),
        LongitudeDistanceTerm(D: 1, M: 0, Mp: 0, F: 0, longitude: -34720, distance: 108743),
        LongitudeDistanceTerm(D: 0, M: 1, Mp: 1, F: 0, longitude: -30383, distance: 104755),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: 0, F: -2, longitude: 15327, distance: 10321),
        LongitudeDistanceTerm(D: 0, M: 0, Mp: 1, F: 2, longitude: -12528, distance: 0),
        LongitudeDistanceTerm(D: 0, M: 0, Mp: 1, F: -2, longitude: 10980, distance: 79661),
        LongitudeDistanceTerm(D: 4, M: 0, Mp: -1, F: 0, longitude: 10675, distance: -34782),
        LongitudeDistanceTerm(D: 0, M: 0, Mp: 3, F: 0, longitude: 10034, distance: -23210),
        LongitudeDistanceTerm(D: 4, M: 0, Mp: -2, F: 0, longitude: 8548, distance: -21636),
        LongitudeDistanceTerm(D: 2, M: 1, Mp: -1, F: 0, longitude: -7888, distance: 24208),
        LongitudeDistanceTerm(D: 2, M: 1, Mp: 0, F: 0, longitude: -6766, distance: 30824),
        LongitudeDistanceTerm(D: 1, M: 0, Mp: -1, F: 0, longitude: -5163, distance: -8379),
        LongitudeDistanceTerm(D: 1, M: 1, Mp: 0, F: 0, longitude: 4987, distance: -16675),
        LongitudeDistanceTerm(D: 2, M: -1, Mp: 1, F: 0, longitude: 4036, distance: -12831),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: 2, F: 0, longitude: 3994, distance: -10445),
        LongitudeDistanceTerm(D: 4, M: 0, Mp: 0, F: 0, longitude: 3861, distance: -11650),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: -3, F: 0, longitude: 3665, distance: 14403),
        LongitudeDistanceTerm(D: 0, M: 1, Mp: -2, F: 0, longitude: -2689, distance: -7003),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: -1, F: 2, longitude: -2602, distance: 0),
        LongitudeDistanceTerm(D: 2, M: -1, Mp: -2, F: 0, longitude: 2390, distance: 10056),
        LongitudeDistanceTerm(D: 1, M: 0, Mp: 1, F: 0, longitude: -2348, distance: 6322),
        LongitudeDistanceTerm(D: 2, M: -2, Mp: 0, F: 0, longitude: 2236, distance: -9884),
        LongitudeDistanceTerm(D: 0, M: 1, Mp: 2, F: 0, longitude: -2120, distance: 5751),
        LongitudeDistanceTerm(D: 0, M: 2, Mp: 0, F: 0, longitude: -2069, distance: 0),
        LongitudeDistanceTerm(D: 2, M: -2, Mp: -1, F: 0, longitude: 2048, distance: -4950),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: 1, F: -2, longitude: -1773, distance: 4130),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: 0, F: 2, longitude: -1595, distance: 0),
        LongitudeDistanceTerm(D: 4, M: -1, Mp: -1, F: 0, longitude: 1215, distance: -3958),
        LongitudeDistanceTerm(D: 0, M: 0, Mp: 2, F: 2, longitude: -1110, distance: 0),
        LongitudeDistanceTerm(D: 3, M: 0, Mp: -1, F: 0, longitude: -892, distance: 3258),
        LongitudeDistanceTerm(D: 2, M: 1, Mp: 1, F: 0, longitude: -810, distance: 2616),
        LongitudeDistanceTerm(D: 4, M: -1, Mp: -2, F: 0, longitude: 759, distance: -1897),
        LongitudeDistanceTerm(D: 0, M: 2, Mp: -1, F: 0, longitude: -713, distance: -2117),
        LongitudeDistanceTerm(D: 2, M: 2, Mp: -1, F: 0, longitude: -700, distance: 2354),
        LongitudeDistanceTerm(D: 2, M: 1, Mp: -2, F: 0, longitude: 691, distance: 0),
        LongitudeDistanceTerm(D: 2, M: -1, Mp: 0, F: -2, longitude: 596, distance: 0),
        LongitudeDistanceTerm(D: 4, M: 0, Mp: 1, F: 0, longitude: 549, distance: -1423),
        LongitudeDistanceTerm(D: 0, M: 0, Mp: 4, F: 0, longitude: 537, distance: -1117),
        LongitudeDistanceTerm(D: 4, M: -1, Mp: 0, F: 0, longitude: 520, distance: -1571),
        LongitudeDistanceTerm(D: 1, M: 0, Mp: -2, F: 0, longitude: -487, distance: -1739),
        LongitudeDistanceTerm(D: 2, M: 1, Mp: 0, F: -2, longitude: -399, distance: 0),
        LongitudeDistanceTerm(D: 0, M: 0, Mp: 2, F: -2, longitude: -381, distance: -4421),
        LongitudeDistanceTerm(D: 1, M: 1, Mp: 1, F: 0, longitude: 351, distance: 0),
        LongitudeDistanceTerm(D: 3, M: 0, Mp: -2, F: 0, longitude: -340, distance: 0),
        LongitudeDistanceTerm(D: 4, M: 0, Mp: -3, F: 0, longitude: 330, distance: 0),
        LongitudeDistanceTerm(D: 2, M: -1, Mp: 2, F: 0, longitude: 327, distance: 0),
        LongitudeDistanceTerm(D: 0, M: 2, Mp: 1, F: 0, longitude: -323, distance: 1165),
        LongitudeDistanceTerm(D: 1, M: 1, Mp: -1, F: 0, longitude: 299, distance: 0),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: 3, F: 0, longitude: 294, distance: 0),
        LongitudeDistanceTerm(D: 2, M: 0, Mp: -1, F: -2, longitude: 0, distance: 8752)
    ]

    private static let latitudeTerms: [LatitudeTerm] = [

        LatitudeTerm(D: 0, M: 0, Mp: 0, F: 1, latitude: 5128122),
        LatitudeTerm(D: 0, M: 0, Mp: 1, F: 1, latitude: 280602),
        LatitudeTerm(D: 0, M: 0, Mp: 1, F: -1, latitude: 277693),
        LatitudeTerm(D: 2, M: 0, Mp: 0, F: -1, latitude: 173237),
        LatitudeTerm(D: 2, M: 0, Mp: -1, F: 1, latitude: 55413),
        LatitudeTerm(D: 2, M: 0, Mp: -1, F: -1, latitude: 46271),
        LatitudeTerm(D: 2, M: 0, Mp: 0, F: 1, latitude: 32573),
        LatitudeTerm(D: 0, M: 0, Mp: 2, F: 1, latitude: 17198),
        LatitudeTerm(D: 2, M: 0, Mp: 1, F: -1, latitude: 9266),
        LatitudeTerm(D: 0, M: 0, Mp: 2, F: -1, latitude: 8822),
        LatitudeTerm(D: 2, M: -1, Mp: 0, F: -1, latitude: 8216),
        LatitudeTerm(D: 2, M: 0, Mp: -2, F: -1, latitude: 4324),
        LatitudeTerm(D: 2, M: 0, Mp: 1, F: 1, latitude: 4200),
        LatitudeTerm(D: 2, M: 1, Mp: 0, F: -1, latitude: -3359),
        LatitudeTerm(D: 2, M: -1, Mp: -1, F: 1, latitude: 2463),
        LatitudeTerm(D: 2, M: -1, Mp: 0, F: 1, latitude: 2211),
        LatitudeTerm(D: 2, M: -1, Mp: -1, F: -1, latitude: 2065),
        LatitudeTerm(D: 0, M: 1, Mp: -1, F: -1, latitude: -1870),
        LatitudeTerm(D: 4, M: 0, Mp: -1, F: -1, latitude: 1828),
        LatitudeTerm(D: 0, M: 1, Mp: 0, F: 1, latitude: -1794),
        LatitudeTerm(D: 0, M: 0, Mp: 0, F: 3, latitude: -1749),
        LatitudeTerm(D: 0, M: 1, Mp: -1, F: 1, latitude: -1565),
        LatitudeTerm(D: 1, M: 0, Mp: 0, F: 1, latitude: -1491),
        LatitudeTerm(D: 0, M: 1, Mp: 1, F: 1, latitude: -1475),
        LatitudeTerm(D: 0, M: 1, Mp: 1, F: -1, latitude: -1410),
        LatitudeTerm(D: 0, M: 1, Mp: 0, F: -1, latitude: -1344),
        LatitudeTerm(D: 1, M: 0, Mp: 0, F: -1, latitude: -1335),
        LatitudeTerm(D: 0, M: 0, Mp: 3, F: 1, latitude: 1107),
        LatitudeTerm(D: 4, M: 0, Mp: 0, F: -1, latitude: 1021),
        LatitudeTerm(D: 4, M: 0, Mp: -1, F: 1, latitude: 833),
        LatitudeTerm(D: 0, M: 0, Mp: 1, F: -3, latitude: 777),
        LatitudeTerm(D: 4, M: 0, Mp: -2, F: 1, latitude: 671),
        LatitudeTerm(D: 2, M: 0, Mp: 0, F: -3, latitude: 607),
        LatitudeTerm(D: 2, M: 0, Mp: 2, F: -1, latitude: 596),
        LatitudeTerm(D: 2, M: -1, Mp: 1, F: -1, latitude: 491),
        LatitudeTerm(D: 2, M: 0, Mp: -2, F: 1, latitude: -451),
        LatitudeTerm(D: 0, M: 0, Mp: 3, F: -1, latitude: 439),
        LatitudeTerm(D: 2, M: 0, Mp: 2, F: 1, latitude: 422),
        LatitudeTerm(D: 2, M: 0, Mp: -3, F: -1, latitude: 421),
        LatitudeTerm(D: 2, M: 1, Mp: -1, F: 1, latitude: -366),
        LatitudeTerm(D: 2, M: 1, Mp: 0, F: 1, latitude: -351),
        LatitudeTerm(D: 4, M: 0, Mp: 0, F: 1, latitude: 331),
        LatitudeTerm(D: 2, M: -1, Mp: 1, F: 1, latitude: 315),
        LatitudeTerm(D: 2, M: -2, Mp: 0, F: -1, latitude: 302),
        LatitudeTerm(D: 0, M: 0, Mp: 1, F: 3, latitude: -283),
        LatitudeTerm(D: 2, M: 1, Mp: 1, F: -1, latitude: -229),
        LatitudeTerm(D: 1, M: 1, Mp: 0, F: -1, latitude: 223),
        LatitudeTerm(D: 1, M: 1, Mp: 0, F: 1, latitude: 223),
        LatitudeTerm(D: 0, M: 1, Mp: -2, F: -1, latitude: -220),
        LatitudeTerm(D: 2, M: 1, Mp: -1, F: -1, latitude: -220),
        LatitudeTerm(D: 1, M: 0, Mp: 1, F: 1, latitude: -185),
        LatitudeTerm(D: 2, M: -1, Mp: -2, F: -1, latitude: 181),
        LatitudeTerm(D: 0, M: 1, Mp: 2, F: 1, latitude: -177),
        LatitudeTerm(D: 4, M: 0, Mp: -2, F: -1, latitude: 176),
        LatitudeTerm(D: 4, M: -1, Mp: -1, F: -1, latitude: 166),
        LatitudeTerm(D: 1, M: 0, Mp: 1, F: -1, latitude: -164),
        LatitudeTerm(D: 4, M: 0, Mp: 1, F: -1, latitude: 132),
        LatitudeTerm(D: 1, M: 0, Mp: -1, F: -1, latitude: -119),
        LatitudeTerm(D: 4, M: -1, Mp: 0, F: -1, latitude: 115),
        LatitudeTerm(D: 2, M: -2, Mp: 0, F: 1, latitude: 107)
    ]

    // ============================================================
    // MARK: - GEOCENTRIC POSITION
    // Longitude / latitude are ecliptic degrees.
    // Distance is kilometres.
    // ============================================================

    static func geocentricPosition(for date: Date) -> (longitude: Double, latitude: Double, distanceKM: Double) {

        let julianDate = Astronomy.julianDate(for: date)
        let T = (julianDate - 2451545.0) / 36525.0

        let T2 = T * T
        let T3 = T2 * T
        let T4 = T3 * T

        let meanLongitude = Astronomy.normaliseDegrees(
            218.3164477 +
            481267.88123421 * T -
            0.0015786 * T2 +
            T3 / 538841.0 -
            T4 / 65194000.0
        )

        let D = Astronomy.normaliseDegrees(
            297.8501921 +
            445267.1114034 * T -
            0.0018819 * T2 +
            T3 / 545868.0 -
            T4 / 113065000.0
        )

        let M = Astronomy.normaliseDegrees(
            357.5291092 +
            35999.0502909 * T -
            0.0001535 * T2 +
            T3 / 24490000.0
        )

        let Mp = Astronomy.normaliseDegrees(
            134.9633964 +
            477198.8675055 * T +
            0.0087414 * T2 +
            T3 / 69699.0 -
            T4 / 14712000.0
        )

        let F = Astronomy.normaliseDegrees(
            93.2720950 +
            483202.0175233 * T -
            0.0036539 * T2 -
            T3 / 3526000.0 +
            T4 / 863310000.0
        )

        let A1 = Astronomy.normaliseDegrees(119.75 + 131.849 * T)
        let A2 = Astronomy.normaliseDegrees(53.09 + 479264.29 * T)
        let A3 = Astronomy.normaliseDegrees(313.45 + 481266.484 * T)

        let E = 1.0 - 0.002516 * T - 0.0000074 * T2
        let E2 = E * E

        let meanLongitudeRadians = Astronomy.radians(meanLongitude)
        let DRadians = Astronomy.radians(D)
        let MRadians = Astronomy.radians(M)
        let MpRadians = Astronomy.radians(Mp)
        let FRadians = Astronomy.radians(F)

        var longitudeSum =
            3958.0 * sin(Astronomy.radians(A1)) +
            1962.0 * sin(meanLongitudeRadians - FRadians) +
            318.0 * sin(Astronomy.radians(A2))

        var distanceSum = 0.0

        var latitudeSum =
            -2235.0 * sin(meanLongitudeRadians) +
            382.0 * sin(Astronomy.radians(A3)) +
            175.0 * sin(Astronomy.radians(A1) - FRadians) +
            175.0 * sin(Astronomy.radians(A1) + FRadians) +
            127.0 * sin(meanLongitudeRadians - MpRadians) -
            115.0 * sin(meanLongitudeRadians + MpRadians)

        for term in longitudeDistanceTerms {

            let argument =
                Double(term.D) * DRadians +
                Double(term.M) * MRadians +
                Double(term.Mp) * MpRadians +
                Double(term.F) * FRadians

            let eccentricityFactor: Double

            switch abs(term.M) {
            case 1:
                eccentricityFactor = E
            case 2:
                eccentricityFactor = E2
            default:
                eccentricityFactor = 1.0
            }

            longitudeSum += term.longitude * sin(argument) * eccentricityFactor
            distanceSum += term.distance * cos(argument) * eccentricityFactor
        }

        for term in latitudeTerms {

            let argument =
                Double(term.D) * DRadians +
                Double(term.M) * MRadians +
                Double(term.Mp) * MpRadians +
                Double(term.F) * FRadians

            let eccentricityFactor: Double

            switch abs(term.M) {
            case 1:
                eccentricityFactor = E
            case 2:
                eccentricityFactor = E2
            default:
                eccentricityFactor = 1.0
            }

            latitudeSum += term.latitude * sin(argument) * eccentricityFactor
        }

        let longitude = Astronomy.normaliseDegrees(meanLongitude + longitudeSum * 0.000001)
        let latitude = latitudeSum * 0.000001
        let distanceKM = 385000.56 + distanceSum * 0.001

        return (
            longitude: longitude,
            latitude: latitude,
            distanceKM: distanceKM
        )
    }

    // ============================================================
    // ============================================================
    // MARK: - DISPLAY POSITION
    //
    // The lunar calculation is considerably more accurate than the
    // simplified planetary model currently used by the AR scene.
    //
    // A small longitude-frame adjustment keeps the accurate lunar
    // elongation relative to the Sun while remaining consistent with
    // the Sun direction actually rendered by SolarSystemBuilder.
    //
    // When sceneUnitsPerKilometre is supplied, the Moon is placed
    // using its real instantaneous Earth-Moon distance.
    // ============================================================

    static func displayPosition(
        for moon: Moon,
        date: Date,
        sceneUnitsPerKilometre: Double? = nil
    ) -> SCNVector3 {

        let position =
            geocentricPosition(
                for: date
            )

        let longitude =
            sceneAlignedLongitude(
                lunarLongitude:
                    position.longitude,
                date: date
            )

        let longitudeRadians =
            Astronomy.radians(
                longitude
            )

        let latitudeRadians =
            Astronomy.radians(
                position.latitude
            )

        let distanceScale: Double

        if let sceneUnitsPerKilometre {

            // Physical astronomical scale.
            distanceScale =
                position.distanceKM *
                sceneUnitsPerKilometre

        } else {

            // Existing enhanced AR display scale.
            distanceScale =
                Double(moon.position.x) *
                position.distanceKM /
                moon.semiMajorAxisKM
        }

        let cosLatitude =
            cos(
                latitudeRadians
            )

        let x =
            cosLatitude *
            cos(longitudeRadians) *
            distanceScale

        let y =
            cosLatitude *
            sin(longitudeRadians) *
            distanceScale

        let z =
            sin(latitudeRadians) *
            distanceScale

        // Astronomy:
        //     X, Y, Z
        //
        // SceneKit:
        //     X, Z, Y

        return SCNVector3(
            Float(x),
            Float(z),
            Float(y)
        )
    }

    // ============================================================
    // MARK: - SCENE LONGITUDE ALIGNMENT
    // ============================================================

    private static func sceneAlignedLongitude(
        lunarLongitude: Double,
        date: Date
    ) -> Double {

        guard let earth =
                PlanetAstronomy.heliocentricPosition(
                    for: "earth",
                    date: date
                )
        else {
            return lunarLongitude
        }

        let sceneSunLongitude =
            Astronomy.normaliseDegrees(
                earth.longitude + 180.0
            )

        let accurateSunLongitude =
            apparentSolarLongitude(
                for: date
            )

        var correction =
            sceneSunLongitude -
            accurateSunLongitude

        while correction > 180.0 {
            correction -= 360.0
        }

        while correction < -180.0 {
            correction += 360.0
        }

        return Astronomy.normaliseDegrees(
            lunarLongitude +
            correction
        )
    }

    // ============================================================
    // MARK: - SOLAR LONGITUDE
    //
    // Used only to place the lunar result into the same longitude
    // frame as the simplified solar-system display.
    // ============================================================

    static func apparentSolarLongitude(
        for date: Date
    ) -> Double {

        let julianDate =
            Astronomy.julianDate(
                for: date
            )

        let T =
            (julianDate - 2451545.0) /
            36525.0

        let T2 =
            T * T

        let meanLongitude =
            Astronomy.normaliseDegrees(
                280.46646 +
                36000.76983 * T +
                0.0003032 * T2
            )

        let meanAnomaly =
            Astronomy.normaliseDegrees(
                357.52911 +
                35999.05029 * T -
                0.0001537 * T2
            )

        let M =
            Astronomy.radians(
                meanAnomaly
            )

        let equationOfCentre =
            (1.914602 -
             0.004817 * T -
             0.000014 * T2) * sin(M) +
            (0.019993 -
             0.000101 * T) * sin(2.0 * M) +
            0.000289 * sin(3.0 * M)

        let trueLongitude =
            meanLongitude +
            equationOfCentre

        let omega =
            Astronomy.radians(
                125.04 -
                1934.136 * T
            )

        return Astronomy.normaliseDegrees(
            trueLongitude -
            0.00569 -
            0.00478 * sin(omega)
        )
    }

    // ============================================================
    // MARK: - DIAGNOSTIC
    // ============================================================

    static func logPosition(
        for date: Date
    ) {

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let position =
            geocentricPosition(
                for: date
            )

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
        print("================ EARTH MOON POSITION =================")
        print("UTC: \(formatter.string(from: date))")
        print(String(format: "Longitude: %.6f°", position.longitude))
        print(String(format: "Latitude:  %+.6f°", position.latitude))
        print(String(format: "Distance:  %.3f km", position.distanceKM))
        print(String(format: "Sun lon:   %.6f°", apparentSolarLongitude(for: date)))
        print("======================================================")
        print("")
    }
}

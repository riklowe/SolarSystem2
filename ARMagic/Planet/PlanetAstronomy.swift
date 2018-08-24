//
//  PlanetAstronomy.swift
//  SolarSystem2
//

import Foundation
import CoreGraphics
import SceneKit
import simd

enum PlanetAstronomy {
    static let  moduleName = (#file).components(separatedBy: "/")

    // ============================================================
    // MARK: - ORBITAL ELEMENTS
    // ============================================================

    static func orbitalElements(for planetName: String) -> OrbitalElements? {
//        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        switch planetName.lowercased() {

        case "mercury":
            return OrbitalElements(semiMajorAxis: 0.38709927, semiMajorAxisRate: 0.00000037, eccentricity: 0.20563593, eccentricityRate: 0.00001906, inclination: 7.00497902, inclinationRate: -0.00594749, meanLongitude: 252.25032350, meanLongitudeRate: 149472.67411175, longitudePerihelion: 77.45779628, longitudePerihelionRate: 0.16047689, longitudeAscendingNode: 48.33076593, longitudeAscendingNodeRate: -0.12534081)

        case "venus":
            return OrbitalElements(semiMajorAxis: 0.72333566, semiMajorAxisRate: -0.00000390, eccentricity: 0.00677672, eccentricityRate: -0.00004107, inclination: 3.39467605, inclinationRate: -0.00078890, meanLongitude: 181.97909950, meanLongitudeRate: 58517.81538729, longitudePerihelion: 131.60246718, longitudePerihelionRate: 0.00268329, longitudeAscendingNode: 76.67984255, longitudeAscendingNodeRate: -0.27769418)

        case "earth":
            return OrbitalElements(semiMajorAxis: 1.00000261, semiMajorAxisRate: 0.00000562, eccentricity: 0.01671123, eccentricityRate: -0.00004392, inclination: 0.0, inclinationRate: 0.0, meanLongitude: 100.46457166, meanLongitudeRate: 35999.37244981, longitudePerihelion: 102.93768193, longitudePerihelionRate: 0.32327364, longitudeAscendingNode: 0.0, longitudeAscendingNodeRate: 0.0)

        case "mars":
            return OrbitalElements(semiMajorAxis: 1.52371034, semiMajorAxisRate: 0.00001847, eccentricity: 0.09339410, eccentricityRate: 0.00007882, inclination: 1.84969142, inclinationRate: -0.00813131, meanLongitude: -4.55343205, meanLongitudeRate: 19140.30268499, longitudePerihelion: -23.94362959, longitudePerihelionRate: 0.44441088, longitudeAscendingNode: 49.55953891, longitudeAscendingNodeRate: -0.29257343)

        case "jupiter":
            return OrbitalElements(semiMajorAxis: 5.20288700, semiMajorAxisRate: -0.00011607, eccentricity: 0.04838624, eccentricityRate: -0.00013253, inclination: 1.30439695, inclinationRate: -0.00183714, meanLongitude: 34.39644051, meanLongitudeRate: 3034.74612775, longitudePerihelion: 14.72847983, longitudePerihelionRate: 0.21252668, longitudeAscendingNode: 100.47390909, longitudeAscendingNodeRate: 0.20469106)

        case "saturn":
            return OrbitalElements(semiMajorAxis: 9.53667594, semiMajorAxisRate: -0.00125060, eccentricity: 0.05386179, eccentricityRate: -0.00050991, inclination: 2.48599187, inclinationRate: 0.00193609, meanLongitude: 49.95424423, meanLongitudeRate: 1222.49362201, longitudePerihelion: 92.59887831, longitudePerihelionRate: -0.41897216, longitudeAscendingNode: 113.66242448, longitudeAscendingNodeRate: -0.28867794)

        case "uranus":
            return OrbitalElements(semiMajorAxis: 19.18916464, semiMajorAxisRate: -0.00196176, eccentricity: 0.04725744, eccentricityRate: -0.00004397, inclination: 0.77263783, inclinationRate: -0.00242939, meanLongitude: 313.23810451, meanLongitudeRate: 428.48202785, longitudePerihelion: 170.95427630, longitudePerihelionRate: 0.40805281, longitudeAscendingNode: 74.01692503, longitudeAscendingNodeRate: 0.04240589)

        case "neptune":
            return OrbitalElements(semiMajorAxis: 30.06992276, semiMajorAxisRate: 0.00026291, eccentricity: 0.00859048, eccentricityRate: 0.00005105, inclination: 1.77004347, inclinationRate: 0.00035372, meanLongitude: -55.12002969, meanLongitudeRate: 218.45945325, longitudePerihelion: 44.96476227, longitudePerihelionRate: -0.32241464, longitudeAscendingNode: 131.78422574, longitudeAscendingNodeRate: -0.00508664)

        default:
            return nil
        }
    }

    // ============================================================
    // MARK: - LONG-RANGE ORBITAL ELEMENTS — 3000 BC TO 3000 AD
    // ============================================================

    static func longRangeOrbitalElements(for planetName: String) -> OrbitalElements? {
        switch planetName.lowercased() {

        case "mercury":
            return OrbitalElements(semiMajorAxis: 0.38709843, semiMajorAxisRate: 0.00000000, eccentricity: 0.20563661, eccentricityRate: 0.00002123, inclination: 7.00559432, inclinationRate: -0.00590158, meanLongitude: 252.25166724, meanLongitudeRate: 149472.67486623, longitudePerihelion: 77.45771895, longitudePerihelionRate: 0.15940013, longitudeAscendingNode: 48.33961819, longitudeAscendingNodeRate: -0.12214182)

        case "venus":
            return OrbitalElements(semiMajorAxis: 0.72332102, semiMajorAxisRate: -0.00000026, eccentricity: 0.00676399, eccentricityRate: -0.00005107, inclination: 3.39777545, inclinationRate: 0.00043494, meanLongitude: 181.97970850, meanLongitudeRate: 58517.81560260, longitudePerihelion: 131.76755713, longitudePerihelionRate: 0.05679648, longitudeAscendingNode: 76.67261496, longitudeAscendingNodeRate: -0.27274174)

        case "earth":
            return OrbitalElements(semiMajorAxis: 1.00000018, semiMajorAxisRate: -0.00000003, eccentricity: 0.01673163, eccentricityRate: -0.00003661, inclination: -0.00054346, inclinationRate: -0.01337178, meanLongitude: 100.46691572, meanLongitudeRate: 35999.37306329, longitudePerihelion: 102.93005885, longitudePerihelionRate: 0.31795260, longitudeAscendingNode: -5.11260389, longitudeAscendingNodeRate: -0.24123856)

        case "mars":
            return OrbitalElements(semiMajorAxis: 1.52371243, semiMajorAxisRate: 0.00000097, eccentricity: 0.09336511, eccentricityRate: 0.00009149, inclination: 1.85181869, inclinationRate: -0.00724757, meanLongitude: -4.56813164, meanLongitudeRate: 19140.29934243, longitudePerihelion: -23.91744784, longitudePerihelionRate: 0.45223625, longitudeAscendingNode: 49.71320984, longitudeAscendingNodeRate: -0.26852431)

        case "jupiter":
            return OrbitalElements(semiMajorAxis: 5.20248019, semiMajorAxisRate: -0.00002864, eccentricity: 0.04853590, eccentricityRate: 0.00018026, inclination: 1.29861416, inclinationRate: -0.00322699, meanLongitude: 34.33479152, meanLongitudeRate: 3034.90371757, longitudePerihelion: 14.27495244, longitudePerihelionRate: 0.18199196, longitudeAscendingNode: 100.29282654, longitudeAscendingNodeRate: 0.13024619)

        case "saturn":
            return OrbitalElements(semiMajorAxis: 9.54149883, semiMajorAxisRate: -0.00003065, eccentricity: 0.05550825, eccentricityRate: -0.00032044, inclination: 2.49424102, inclinationRate: 0.00451969, meanLongitude: 50.07571329, meanLongitudeRate: 1222.11494724, longitudePerihelion: 92.86136063, longitudePerihelionRate: 0.54179478, longitudeAscendingNode: 113.63998702, longitudeAscendingNodeRate: -0.25015002)

        case "uranus":
            return OrbitalElements(semiMajorAxis: 19.18797948, semiMajorAxisRate: -0.00020455, eccentricity: 0.04685740, eccentricityRate: -0.00001550, inclination: 0.77298127, inclinationRate: -0.00180155, meanLongitude: 314.20276625, meanLongitudeRate: 428.49512595, longitudePerihelion: 172.43404441, longitudePerihelionRate: 0.09266985, longitudeAscendingNode: 73.96250215, longitudeAscendingNodeRate: 0.05739699)

        case "neptune":
            return OrbitalElements(semiMajorAxis: 30.06952752, semiMajorAxisRate: 0.00006447, eccentricity: 0.00895439, eccentricityRate: 0.00000818, inclination: 1.77005520, inclinationRate: 0.00022400, meanLongitude: 304.22289287, meanLongitudeRate: 218.46515314, longitudePerihelion: 46.68158724, longitudePerihelionRate: 0.01009938, longitudeAscendingNode: 131.78635853, longitudeAscendingNodeRate: -0.00606302)

        case "pluto":
            return OrbitalElements(semiMajorAxis: 39.48686035, semiMajorAxisRate: 0.00449751, eccentricity: 0.24885238, eccentricityRate: 0.00006016, inclination: 17.14104260, inclinationRate: 0.00000501, meanLongitude: 238.96535011, meanLongitudeRate: 145.18042903, longitudePerihelion: 224.09702598, longitudePerihelionRate: -0.00968827, longitudeAscendingNode: 110.30167986, longitudeAscendingNodeRate: -0.00809981)

        default:
            return nil
        }
    }

    static func longRangeMeanAnomalyCorrection(for planetName: String, T: Double) -> Double {
        let b: Double
        let c: Double
        let s: Double
        let f: Double

        switch planetName.lowercased() {

        case "jupiter":
            b = -0.00012452
            c = 0.06064060
            s = -0.35635438
            f = 38.35125000

        case "saturn":
            b = 0.00025899
            c = -0.13434469
            s = 0.87320147
            f = 38.35125000

        case "uranus":
            b = 0.00058331
            c = -0.97731848
            s = 0.17689245
            f = 7.67025000

        case "neptune":
            b = -0.00041348
            c = 0.68346318
            s = -0.10162547
            f = 7.67025000

        case "pluto":
            b = -0.01262724
            c = 0.0
            s = 0.0
            f = 0.0

        default:
            return 0.0
        }

        let angle = Astronomy.radians(f * T)

        return b * T * T + c * cos(angle) + s * sin(angle)
    }

    static func modelComparison(for planetName: String, date: Date) -> (shortLongitude: Double, longLongitude: Double, difference: Double)? {
        let T = (Astronomy.julianDate(for: date) - 2451545.0) / 36525.0

        guard let shortBase = orbitalElements(for: planetName),
              let longBase = longRangeOrbitalElements(for: planetName) else {
            return nil
        }

        func longitude(using base: OrbitalElements, correction: Double) -> Double {
            let a = base.semiMajorAxis + base.semiMajorAxisRate * T
            let e = base.eccentricity + base.eccentricityRate * T
            let i = base.inclination + base.inclinationRate * T
            let L = base.meanLongitude + base.meanLongitudeRate * T
            let perihelion = base.longitudePerihelion + base.longitudePerihelionRate * T
            let node = base.longitudeAscendingNode + base.longitudeAscendingNodeRate * T

            let meanAnomaly = Astronomy.normaliseDegrees(L - perihelion + correction)
            let E = Astronomy.eccentricAnomaly(meanAnomaly: meanAnomaly, eccentricity: e)

            let xOrbital = a * (cos(E) - e)
            let yOrbital = a * sqrt(1.0 - e * e) * sin(E)

            let argumentPerihelion = Astronomy.radians(perihelion - node)
            let inclination = Astronomy.radians(i)
            let ascendingNode = Astronomy.radians(node)

            let x1 = xOrbital * cos(argumentPerihelion) - yOrbital * sin(argumentPerihelion)
            let y1 = xOrbital * sin(argumentPerihelion) + yOrbital * cos(argumentPerihelion)

            let x2 = x1
            let y2 = y1 * cos(inclination)

            let x = x2 * cos(ascendingNode) - y2 * sin(ascendingNode)
            let y = x2 * sin(ascendingNode) + y2 * cos(ascendingNode)

            var longitude = atan2(y, x) * 180.0 / Double.pi

            if longitude < 0.0 {
                longitude += 360.0
            }

            return longitude
        }

        let shortLongitude = longitude(using: shortBase, correction: 0.0)

        let correction = longRangeMeanAnomalyCorrection(
            for: planetName,
            T: T
        )

        let longLongitude = longitude(
            using: longBase,
            correction: correction
        )

        var difference = longLongitude - shortLongitude

        while difference > 180.0 {
            difference -= 360.0
        }

        while difference < -180.0 {
            difference += 360.0
        }

        return (
            shortLongitude: shortLongitude,
            longLongitude: longLongitude,
            difference: difference
        )
    }
    
    // ============================================================
    // MARK: - CURRENT ELEMENTS
    // ============================================================

    static func currentElements(for planetName: String, date: Date) -> (a: Double, e: Double, i: Double, L: Double, perihelion: Double, node: Double, meanAnomalyCorrection: Double)? {

        let T = (Astronomy.julianDate(for: date) - 2451545.0) / 36525.0

        let useShortRangeModel = T >= -2.0 && T <= 0.5

        let base: OrbitalElements?

        if planetName.lowercased() == "pluto" {
            base = longRangeOrbitalElements(for: planetName)
        } else if useShortRangeModel {
            base = orbitalElements(for: planetName)
        } else {
            base = longRangeOrbitalElements(for: planetName)
        }

        guard let base else { return nil }
        
        let correction = planetName.lowercased() == "pluto" || !useShortRangeModel
            ? longRangeMeanAnomalyCorrection(for: planetName, T: T)
            : 0.0
        
        return (
            base.semiMajorAxis + base.semiMajorAxisRate * T,
            base.eccentricity + base.eccentricityRate * T,
            base.inclination + base.inclinationRate * T,
            base.meanLongitude + base.meanLongitudeRate * T,
            base.longitudePerihelion + base.longitudePerihelionRate * T,
            base.longitudeAscendingNode + base.longitudeAscendingNodeRate * T,
            correction
        )
    }

    // ============================================================
    // MARK: - ORBIT POSITION
    // ============================================================

    static func orbitalPosition(for planetName: String, date: Date, displayRadius: CGFloat) -> SCNVector3 {
//        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        guard let elements = currentElements(for: planetName, date: date) else { return SCNVector3Zero }

        let meanAnomaly = Astronomy.normaliseDegrees(
            elements.L - elements.perihelion + elements.meanAnomalyCorrection
        )

        let E = Astronomy.eccentricAnomaly(meanAnomaly: meanAnomaly, eccentricity: elements.e)

        // Elliptical coordinates normalised so that a = 1.
        // This is important: displayRadius supplies our AR scale.
        let xOrbital = cos(E) - elements.e
        let yOrbital = sqrt(1.0 - elements.e * elements.e) * sin(E)

        let argumentPerihelion = Astronomy.radians(elements.perihelion - elements.node)
        let inclination = Astronomy.radians(elements.i)
        let ascendingNode = Astronomy.radians(elements.node)

        // Rotate by argument of perihelion.
        let x1 = xOrbital * cos(argumentPerihelion) - yOrbital * sin(argumentPerihelion)
        let y1 = xOrbital * sin(argumentPerihelion) + yOrbital * cos(argumentPerihelion)

        // Apply inclination.
        let x2 = x1
        let y2 = y1 * cos(inclination)
        let z2 = y1 * sin(inclination)

        // Apply longitude of ascending node.
        let x3 = x2 * cos(ascendingNode) - y2 * sin(ascendingNode)
        let y3 = x2 * sin(ascendingNode) + y2 * cos(ascendingNode)
        let z3 = z2

        // Our AR display radius determines the size of the orbit.
        return SCNVector3(
            Float(x3 * Double(displayRadius)),
            Float(z3 * Double(displayRadius)),
            Float(y3 * Double(displayRadius))
        )
    }

    // ============================================================
    // MARK: - ORBIT POSITION DIAGNOSTIC
    // ============================================================

    static func heliocentricPosition(for planetName: String, date: Date) -> (x: Double, y: Double, z: Double, longitude: Double, latitude: Double, distance: Double)? {
        guard let elements = currentElements(for: planetName, date: date) else { return nil }

        let meanAnomaly = Astronomy.normaliseDegrees(
            elements.L - elements.perihelion + elements.meanAnomalyCorrection
        )

        let E = Astronomy.eccentricAnomaly(meanAnomaly: meanAnomaly, eccentricity: elements.e)

        let xOrbital = elements.a * (cos(E) - elements.e)
        let yOrbital = elements.a * sqrt(1.0 - elements.e * elements.e) * sin(E)

        let argumentPerihelion = Astronomy.radians(elements.perihelion - elements.node)
        let inclination = Astronomy.radians(elements.i)
        let ascendingNode = Astronomy.radians(elements.node)

        let x1 = xOrbital * cos(argumentPerihelion) - yOrbital * sin(argumentPerihelion)
        let y1 = xOrbital * sin(argumentPerihelion) + yOrbital * cos(argumentPerihelion)

        let x2 = x1
        let y2 = y1 * cos(inclination)
        let z2 = y1 * sin(inclination)

        let x = x2 * cos(ascendingNode) - y2 * sin(ascendingNode)
        let y = x2 * sin(ascendingNode) + y2 * cos(ascendingNode)
        let z = z2

        let distance = sqrt(x * x + y * y + z * z)

        var longitude = atan2(y, x) * 180.0 / Double.pi
        if longitude < 0.0 {
            longitude += 360.0
        }

        let latitude = asin(z / distance) * 180.0 / Double.pi

        return (
            x: x,
            y: y,
            z: z,
            longitude: longitude,
            latitude: latitude,
            distance: distance
        )
    }
    
    // ============================================================
    // MARK: - ROTATION
    // ============================================================

    static func rotationAngle(for planet: Planet, date: Date, epoch: Date) -> CGFloat {
//        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        guard planet.dayLength > 0 else { return 0 }

        let elapsedDays = date.timeIntervalSince(epoch) / 86400.0
        let direction = isRetrogradeRotation(planet.name) ? -1.0 : 1.0
        let rotations = elapsedDays / planet.dayLength * direction
        let angle = rotations.truncatingRemainder(dividingBy: 1.0) * Double.pi * 2.0

        return CGFloat(angle)
    }

    // ============================================================
    // MARK: - ABSOLUTE IAU PRIME MERIDIAN ROTATION
    // ============================================================

    static func primeMeridianAngle(for planetName: String, date: Date) -> CGFloat {

        let julianDate = Astronomy.julianDate(for: date)
        let d = julianDate - 2451545.0
        let T = d / 36525.0

        let W: Double

        switch planetName.lowercased() {

        case "sun":
            W = 84.176 + 14.1844000 * d

        case "mercury":
            let M1 = Astronomy.radians(174.791086 + 4.092335 * d)
            let M2 = Astronomy.radians(349.582171 + 8.184670 * d)
            let M3 = Astronomy.radians(164.373257 + 12.277005 * d)
            let M4 = Astronomy.radians(339.164343 + 16.369340 * d)
            let M5 = Astronomy.radians(153.955429 + 20.461675 * d)

            W = 329.5469
                + 6.1385025 * d
                + 0.00993822 * sin(M1)
                - 0.00104581 * sin(M2)
                - 0.00010280 * sin(M3)
                - 0.00002364 * sin(M4)
                - 0.00000532 * sin(M5)

        case "venus":
            W = 160.20 - 1.4813688 * d

        case "earth":
            W = 190.147 + 360.9856235 * d

        case "mars":
            W = 176.630 + 350.89198226 * d

        case "jupiter":
            W = 284.95 + 870.5360000 * d

        case "saturn":
            W = 38.90 + 810.7939024 * d

        case "uranus":
            W = 203.81 - 501.1600928 * d

        case "neptune":
            let N = Astronomy.radians(357.85 + 52.316 * T)
            W = 253.18 + 536.3128492 * d - 0.48 * sin(N)

        case "pluto":
            W = 302.695 + 56.3625225 * d

        default:
            return 0
        }

        let normalisedW = Astronomy.normaliseDegrees(W)

        return CGFloat(Astronomy.radians(normalisedW))
    }

    // ============================================================
    // MARK: - ABSOLUTE BODY ORIENTATION
    // ============================================================

    static func bodyOrientation(for planetName: String, date: Date) -> simd_quatf {

        let pole = planetaryPole(for: planetName, date: date)

        let ra = Astronomy.radians(pole.rightAscension)
        let dec = Astronomy.radians(pole.declination)
        let W = Double(primeMeridianAngle(for: planetName, date: date))

        // --------------------------------------------------------
        // IAU body-fixed -> J2000 equatorial orientation
        //
        // IAU body axes:
        //     +X = longitude 0°, latitude 0°
        //     +Y = longitude 90°E, latitude 0°
        //     +Z = north pole
        // --------------------------------------------------------

        let sinRA = sin(ra)
        let cosRA = cos(ra)
        let sinDec = sin(dec)
        let cosDec = cos(dec)
        let sinW = sin(W)
        let cosW = cos(W)

        // Direction of the body's north pole in J2000.
        let north = SIMD3<Double>(
            cosDec * cosRA,
            cosDec * sinRA,
            sinDec
        )

        // Reference direction in the body's equatorial plane.
        let referenceX = SIMD3<Double>(
            -sinRA,
            cosRA,
            0.0
        )

        let referenceY = simd_normalize(
            simd_cross(north, referenceX)
        )

        // Apply the IAU prime-meridian rotation W.
        let bodyX = simd_normalize(
            referenceX * cosW + referenceY * sinW
        )

        let bodyY = simd_normalize(
            -referenceX * sinW + referenceY * cosW
        )

        let bodyZ = simd_normalize(north)

        // --------------------------------------------------------
        // J2000 equatorial -> ecliptic
        // --------------------------------------------------------

        let obliquity = Astronomy.radians(23.4392911)

        func equatorialToSceneKit(_ vector: SIMD3<Double>) -> SIMD3<Float> {

            let xEcliptic = vector.x

            let yEcliptic =
                vector.y * cos(obliquity)
                + vector.z * sin(obliquity)

            let zEcliptic =
                -vector.y * sin(obliquity)
                + vector.z * cos(obliquity)

            // Astronomy:
            //     X, Y, Z
            //
            // SceneKit:
            //     X, Z, Y

            return SIMD3<Float>(
                Float(xEcliptic),
                Float(zEcliptic),
                Float(yEcliptic)
            )
        }

        let x = equatorialToSceneKit(bodyX)
        let y = equatorialToSceneKit(bodyY)
        let z = equatorialToSceneKit(bodyZ)

        // --------------------------------------------------------
        // SceneKit sphere local axes:
        //
        // local +Y = north pole
        // local +Z = longitude 0°
        // local +X = longitude 90°E
        //
        // Therefore:
        //
        // SceneKit X -> IAU body Y
        // SceneKit Y -> IAU body Z
        // SceneKit Z -> IAU body X
        // --------------------------------------------------------

        let matrix = simd_float3x3(
            columns: (
                y,
                z,
                x
            )
        )

        return simd_quatf(matrix)
    }
    
    // ============================================================
    // MARK: - IAU ROTATIONAL POLES
    // ============================================================

    static func planetaryPole(for planetName: String, date: Date) -> PoleCoordinates {
        //printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        let T = (Astronomy.julianDate(for: date) - 2451545.0) / 36525.0

        switch planetName.lowercased() {
        case "sun": return PoleCoordinates(rightAscension: 286.13, declination: 63.87)
        case "mercury": return PoleCoordinates(rightAscension: 281.0103 - 0.0328 * T, declination: 61.4155 - 0.0049 * T)
        case "venus": return PoleCoordinates(rightAscension: 272.76, declination: 67.16)
        //case "earth": return PoleCoordinates(rightAscension: 0.0, declination: 90.0)
        case "earth": return PoleCoordinates(rightAscension: -0.641 * T, declination: 90.0 - 0.557 * T)

        case "mars":
            let M1 = Astronomy.radians(198.991226 + 19139.4819985 * T)
            let M2 = Astronomy.radians(226.292679 + 38280.8511281 * T)
            let M3 = Astronomy.radians(249.663391 + 57420.7251593 * T)
            let M4 = Astronomy.radians(266.183510 + 76560.6367950 * T)
            let M5 = Astronomy.radians(79.398797 + 0.5042615 * T)
            let D1 = Astronomy.radians(122.433576 + 19139.9407476 * T)
            let D2 = Astronomy.radians(43.058401 + 38280.8753272 * T)
            let D3 = Astronomy.radians(57.663379 + 57420.7517205 * T)
            let D4 = Astronomy.radians(79.476401 + 76560.6495004 * T)
            let D5 = Astronomy.radians(166.325722 + 0.5042615 * T)
            let ra = 317.269202 - 0.10927547 * T + 0.000068 * sin(M1) + 0.000238 * sin(M2) + 0.000052 * sin(M3) + 0.000009 * sin(M4) + 0.419057 * sin(M5)
            let dec = 54.432516 - 0.05827105 * T + 0.000051 * cos(D1) + 0.000141 * cos(D2) + 0.000031 * cos(D3) + 0.000005 * cos(D4) + 1.591274 * cos(D5)
            return PoleCoordinates(rightAscension: ra, declination: dec)

        case "jupiter":
            let Ja = Astronomy.radians(99.360714 + 4850.4046 * T)
            let Jb = Astronomy.radians(175.895369 + 1191.9605 * T)
            let Jc = Astronomy.radians(300.323162 + 262.5475 * T)
            let Jd = Astronomy.radians(114.012305 + 6070.2476 * T)
            let Je = Astronomy.radians(49.511251 + 64.3000 * T)
            let ra = 268.056595 - 0.006499 * T + 0.000117 * sin(Ja) + 0.000938 * sin(Jb) + 0.001432 * sin(Jc) + 0.000030 * sin(Jd) + 0.002150 * sin(Je)
            let dec = 64.495303 + 0.002413 * T + 0.000050 * cos(Ja) + 0.000404 * cos(Jb) + 0.000617 * cos(Jc) - 0.000013 * cos(Jd) + 0.000926 * cos(Je)
            return PoleCoordinates(rightAscension: ra, declination: dec)

        case "saturn":
            return PoleCoordinates(rightAscension: 40.589 - 0.036 * T, declination: 83.537 - 0.004 * T)

        case "uranus":
            return PoleCoordinates(rightAscension: 257.311, declination: -15.175)

        case "neptune":
            let N = Astronomy.radians(357.85 + 52.316 * T)
            return PoleCoordinates(rightAscension: 299.36 + 0.70 * sin(N), declination: 43.46 - 0.51 * cos(N))

        case "pluto":
            return PoleCoordinates(rightAscension: 132.993, declination: -6.163)

        default:
            return PoleCoordinates(rightAscension: 0.0, declination: 90.0)
        }
    }

    static func primeMeridianReferenceOffset(for planetName: String, date: Date) -> Float {
        let pole = planetaryPole(for: planetName, date: date)

        let ra = Astronomy.radians(pole.rightAscension)
        let dec = Astronomy.radians(pole.declination)

        // North pole in J2000 equatorial coordinates.
        let northEquatorial = SIMD3<Double>(
            cos(dec) * cos(ra),
            cos(dec) * sin(ra),
            sin(dec)
        )

        // IAU zero-W prime-meridian reference direction.
        let referenceEquatorial = simd_normalize(
            SIMD3<Double>(
                -sin(ra),
                cos(ra),
                0.0
            )
        )

        let obliquity = Astronomy.radians(23.4392911)

        func equatorialToSceneKit(_ vector: SIMD3<Double>) -> SIMD3<Float> {
            let xEcliptic = vector.x
            let yEcliptic = vector.y * cos(obliquity) + vector.z * sin(obliquity)
            let zEcliptic = -vector.y * sin(obliquity) + vector.z * cos(obliquity)

            return simd_normalize(
                SIMD3<Float>(
                    Float(xEcliptic),
                    Float(zEcliptic),
                    Float(yEcliptic)
                )
            )
        }

        let targetPole = equatorialToSceneKit(northEquatorial)
        let targetReference = equatorialToSceneKit(referenceEquatorial)

        // This is the same shortest-arc pole alignment used by SolarSystemBuilder.
        let poleOrientation = simd_quatf(
            from: SIMD3<Float>(0, 1, 0),
            to: targetPole
        )

        // Where local +Z points after pole alignment but before planetary rotation.
        let currentReference = simd_normalize(
            poleOrientation.act(SIMD3<Float>(0, 0, 1))
        )

        // Both vectors should lie in the plane perpendicular to the pole.
        let currentProjected = simd_normalize(
            currentReference - targetPole * simd_dot(currentReference, targetPole)
        )

        let targetProjected = simd_normalize(
            targetReference - targetPole * simd_dot(targetReference, targetPole)
        )

        // Signed angular difference around the planetary pole.
        let sine = simd_dot(
            targetPole,
            simd_cross(currentProjected, targetProjected)
        )

        let cosine = simd_dot(
            currentProjected,
            targetProjected
        )

        return atan2(sine, cosine)
    }
    
    static func eclipticPoleVector(for planetName: String, date: Date) -> SIMD3<Float> {
 //       printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        let pole = planetaryPole(for: planetName, date: date)
        let ra = Astronomy.radians(pole.rightAscension)
        let dec = Astronomy.radians(pole.declination)

        let xEq = cos(dec) * cos(ra)
        let yEq = cos(dec) * sin(ra)
        let zEq = sin(dec)
        let obliquity = Astronomy.radians(23.4392911)

        let xEcl = xEq
        let yEcl = yEq * cos(obliquity) + zEq * sin(obliquity)
        let zEcl = -yEq * sin(obliquity) + zEq * cos(obliquity)

        return simd_normalize(SIMD3<Float>(Float(xEcl), Float(zEcl), Float(yEcl)))
    }

    static func isRetrogradeRotation(_ planetName: String) -> Bool {
//        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        switch planetName.lowercased() {
//        case "venus", "uranus", "pluto": return true
        case "venus", "uranus": return true
        default: return false
        }
    }
}

//
//  SolarSystemData.swift
//  SolarSystem2
//

import SceneKit

enum SolarSystemData {

    static let moduleName = (#file).components(separatedBy: "/")

    static func planets() -> [Planet] {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        // ========================================================
        // EARTH
        // ========================================================

        let moon = Moon(
            name: "Moon",
            radius: 0.0347,
            image: "moon",
            position: SCNVector3(0.22, 0, 0),
            dayLength: 27.322,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 384400.0,
            eccentricity: 0.0554,
            inclination: 5.16,
            ascendingNode: 125.08,
            argumentPeriapsis: 318.15,
            meanAnomalyAtEpoch: 135.27,
            meanMotion: 360.0 / 27.322,
            referencePlane: .ecliptic,
            referencePlaneRightAscension: 0.0,
            referencePlaneDeclination: 90.0,
            retrograde: false
        )

        // ========================================================
        // MARS
        // ========================================================

        let phobos = Moon(
            name: "Phobos",
            radius: 0.00017,
            image: "moon",
            position: SCNVector3(0.10, 0, 0),
            dayLength: 0.319,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 9375.0,
            eccentricity: 0.015,
            inclination: 1.1,
            ascendingNode: 169.2,
            argumentPeriapsis: 216.3,
            meanAnomalyAtEpoch: 189.7,
            meanMotion: 360.0 / 0.3187,
            referencePlane: .laplace,
            referencePlaneRightAscension: 317.7,
            referencePlaneDeclination: 52.9,
            retrograde: false
        )

        let deimos = Moon(
            name: "Deimos",
            radius: 0.00010,
            image: "moon",
            position: SCNVector3(0.16, 0, 0),
            dayLength: 1.263,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 23457.0,
            eccentricity: 0.000,
            inclination: 1.8,
            ascendingNode: 54.3,
            argumentPeriapsis: 0.0,
            meanAnomalyAtEpoch: 205.0,
            meanMotion: 360.0 / 1.2625,
            referencePlane: .laplace,
            referencePlaneRightAscension: 316.6,
            referencePlaneDeclination: 53.5,
            retrograde: false
        )

        // ========================================================
        // JUPITER
        // ========================================================

        let amalthea = Moon(
            name: "Amalthea",
            radius: 0.0013,
            image: "moon",
            position: SCNVector3(0.15, 0, 0),
            dayLength: 0.498,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 181400.0,
            eccentricity: 0.003,
            inclination: 0.4,
            ascendingNode: 282.9,
            argumentPeriapsis: 180.1,
            meanAnomalyAtEpoch: 310.6,
            meanMotion: 360.0 / 0.499918,
            referencePlane: .laplace,
            referencePlaneRightAscension: 268.1,
            referencePlaneDeclination: 64.5,
            retrograde: false
        )

        let io = Moon(
            name: "Io",
            radius: 0.0286,
            image: "moon",
            position: SCNVector3(0.20, 0, 0),
            dayLength: 1.769,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 421800.0,
            eccentricity: 0.004,
            inclination: 0.0,
            ascendingNode: 0.0,
            argumentPeriapsis: 49.1,
            meanAnomalyAtEpoch: 330.9,
            meanMotion: 360.0 / 1.762732,
            referencePlane: .laplace,
            referencePlaneRightAscension: 268.1,
            referencePlaneDeclination: 64.5,
            retrograde: false
        )

        let europa = Moon(
            name: "Europa",
            radius: 0.0245,
            image: "moon",
            position: SCNVector3(0.27, 0, 0),
            dayLength: 3.551,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 671100.0,
            eccentricity: 0.009,
            inclination: 0.5,
            ascendingNode: 184.0,
            argumentPeriapsis: 45.0,
            meanAnomalyAtEpoch: 345.4,
            meanMotion: 360.0 / 3.525463,
            referencePlane: .laplace,
            referencePlaneRightAscension: 268.1,
            referencePlaneDeclination: 64.5,
            retrograde: false
        )

        let ganymede = Moon(
            name: "Ganymede",
            radius: 0.0413,
            image: "moon",
            position: SCNVector3(0.35, 0, 0),
            dayLength: 7.155,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 1070400.0,
            eccentricity: 0.001,
            inclination: 0.2,
            ascendingNode: 58.5,
            argumentPeriapsis: 198.3,
            meanAnomalyAtEpoch: 324.8,
            meanMotion: 360.0 / 7.155588,
            referencePlane: .laplace,
            referencePlaneRightAscension: 268.2,
            referencePlaneDeclination: 64.6,
            retrograde: false
        )

        let callisto = Moon(
            name: "Callisto",
            radius: 0.0378,
            image: "moon",
            position: SCNVector3(0.45, 0, 0),
            dayLength: 16.689,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 1882700.0,
            eccentricity: 0.007,
            inclination: 0.3,
            ascendingNode: 309.1,
            argumentPeriapsis: 43.8,
            meanAnomalyAtEpoch: 87.4,
            meanMotion: 360.0 / 16.690440,
            referencePlane: .laplace,
            referencePlaneRightAscension: 268.7,
            referencePlaneDeclination: 64.8,
            retrograde: false
        )

        // ========================================================
        // SATURN
        // ========================================================

        let mimas = Moon(name: "Mimas", radius: 0.0031, image: "moon", position: SCNVector3(0.18, 0, 0), dayLength: 0.942, epochJulianDate: 2451545.0, semiMajorAxisKM: 186000.0, eccentricity: 0.020, inclination: 1.6, ascendingNode: 66.2, argumentPeriapsis: 160.4, meanAnomalyAtEpoch: 275.3, meanMotion: 360.0 / 0.942422, referencePlane: .laplace, referencePlaneRightAscension: 40.6, referencePlaneDeclination: 83.5, retrograde: false)

        let enceladus = Moon(name: "Enceladus", radius: 0.0040, image: "moon", position: SCNVector3(0.23, 0, 0), dayLength: 1.370, epochJulianDate: 2451545.0, semiMajorAxisKM: 238400.0, eccentricity: 0.005, inclination: 0.0, ascendingNode: 0.0, argumentPeriapsis: 119.5, meanAnomalyAtEpoch: 57.0, meanMotion: 360.0 / 1.370218, referencePlane: .laplace, referencePlaneRightAscension: 40.6, referencePlaneDeclination: 83.5, retrograde: false)

        let tethys = Moon(name: "Tethys", radius: 0.0083, image: "moon", position: SCNVector3(0.28, 0, 0), dayLength: 1.888, epochJulianDate: 2451545.0, semiMajorAxisKM: 295000.0, eccentricity: 0.001, inclination: 1.1, ascendingNode: 273.0, argumentPeriapsis: 335.3, meanAnomalyAtEpoch: 0.0, meanMotion: 360.0 / 1.887802, referencePlane: .laplace, referencePlaneRightAscension: 40.6, referencePlaneDeclination: 83.5, retrograde: false)

        let dione = Moon(name: "Dione", radius: 0.0088, image: "moon", position: SCNVector3(0.34, 0, 0), dayLength: 2.737, epochJulianDate: 2451545.0, semiMajorAxisKM: 377700.0, eccentricity: 0.002, inclination: 0.0, ascendingNode: 0.0, argumentPeriapsis: 116.0, meanAnomalyAtEpoch: 212.0, meanMotion: 360.0 / 2.736916, referencePlane: .laplace, referencePlaneRightAscension: 40.6, referencePlaneDeclination: 83.5, retrograde: false)

        let rhea = Moon(name: "Rhea", radius: 0.0120, image: "moon", position: SCNVector3(0.41, 0, 0), dayLength: 4.518, epochJulianDate: 2451545.0, semiMajorAxisKM: 527200.0, eccentricity: 0.001, inclination: 0.3, ascendingNode: 133.7, argumentPeriapsis: 44.3, meanAnomalyAtEpoch: 31.5, meanMotion: 360.0 / 4.517503, referencePlane: .laplace, referencePlaneRightAscension: 40.6, referencePlaneDeclination: 83.5, retrograde: false)

        let titan = Moon(name: "Titan", radius: 0.0404, image: "moon", position: SCNVector3(0.50, 0, 0), dayLength: 15.945, epochJulianDate: 2451545.0, semiMajorAxisKM: 1221900.0, eccentricity: 0.029, inclination: 0.3, ascendingNode: 78.6, argumentPeriapsis: 78.3, meanAnomalyAtEpoch: 11.7, meanMotion: 360.0 / 15.945448, referencePlane: .laplace, referencePlaneRightAscension: 36.4, referencePlaneDeclination: 84.0, retrograde: false)

        let hyperion = Moon(name: "Hyperion", radius: 0.0021, image: "moon", position: SCNVector3(0.56, 0, 0), dayLength: 13.0, epochJulianDate: 2451545.0, semiMajorAxisKM: 1481500.0, eccentricity: 0.105, inclination: 0.6, ascendingNode: 87.1, argumentPeriapsis: 214.0, meanAnomalyAtEpoch: 122.9, meanMotion: 360.0 / 21.276658, referencePlane: .laplace, referencePlaneRightAscension: 40.2, referencePlaneDeclination: 83.6, retrograde: false)

        let iapetus = Moon(name: "Iapetus", radius: 0.0115, image: "moon", position: SCNVector3(0.64, 0, 0), dayLength: 79.32, epochJulianDate: 2451545.0, semiMajorAxisKM: 3561700.0, eccentricity: 0.028, inclination: 7.6, ascendingNode: 86.5, argumentPeriapsis: 254.5, meanAnomalyAtEpoch: 74.8, meanMotion: 360.0 / 79.331002, referencePlane: .laplace, referencePlaneRightAscension: 288.7, referencePlaneDeclination: 78.9, retrograde: false)

        let phoebe = Moon(name: "Phoebe", radius: 0.0017, image: "moon", position: SCNVector3(0.75, 0, 0), dayLength: 0.39, epochJulianDate: 2451545.0, semiMajorAxisKM: 12929400.0, eccentricity: 0.164, inclination: 175.2, ascendingNode: 192.7, argumentPeriapsis: 240.3, meanAnomalyAtEpoch: 308.0, meanMotion: 360.0 / 550.303910, referencePlane: .laplace, referencePlaneRightAscension: 276.0, referencePlaneDeclination: 67.5, retrograde: true)

        // ========================================================
        // URANUS
        // ========================================================

        let miranda = Moon(name: "Miranda", radius: 0.0037, image: "moon", position: SCNVector3(0.14, 0, 0), dayLength: 1.413, epochJulianDate: 2451545.0, semiMajorAxisKM: 129846.0, eccentricity: 0.001, inclination: 4.4, ascendingNode: 100.9, argumentPeriapsis: 154.8, meanAnomalyAtEpoch: 73.0, meanMotion: 360.0 / 1.413479, referencePlane: .equatorial, referencePlaneRightAscension: 0.0, referencePlaneDeclination: 90.0, retrograde: false)

        let ariel = Moon(name: "Ariel", radius: 0.0091, image: "moon", position: SCNVector3(0.20, 0, 0), dayLength: 2.520, epochJulianDate: 2451545.0, semiMajorAxisKM: 190929.0, eccentricity: 0.001, inclination: 0.0, ascendingNode: 0.0, argumentPeriapsis: 9.6, meanAnomalyAtEpoch: 193.5, meanMotion: 360.0 / 2.520379, referencePlane: .equatorial, referencePlaneRightAscension: 0.0, referencePlaneDeclination: 90.0, retrograde: false)

        let umbriel = Moon(name: "Umbriel", radius: 0.0092, image: "moon", position: SCNVector3(0.26, 0, 0), dayLength: 4.144, epochJulianDate: 2451545.0, semiMajorAxisKM: 265986.0, eccentricity: 0.004, inclination: 0.1, ascendingNode: 174.8, argumentPeriapsis: 183.4, meanAnomalyAtEpoch: 253.0, meanMotion: 360.0 / 4.144177, referencePlane: .equatorial, referencePlaneRightAscension: 0.0, referencePlaneDeclination: 90.0, retrograde: false)

        let titania = Moon(name: "Titania", radius: 0.0124, image: "moon", position: SCNVector3(0.33, 0, 0), dayLength: 8.706, epochJulianDate: 2451545.0, semiMajorAxisKM: 436298.0, eccentricity: 0.002, inclination: 0.1, ascendingNode: 29.5, argumentPeriapsis: 184.0, meanAnomalyAtEpoch: 68.1, meanMotion: 360.0 / 8.705869, referencePlane: .equatorial, referencePlaneRightAscension: 0.0, referencePlaneDeclination: 90.0, retrograde: false)

        let oberon = Moon(name: "Oberon", radius: 0.0119, image: "moon", position: SCNVector3(0.41, 0, 0), dayLength: 13.463, epochJulianDate: 2451545.0, semiMajorAxisKM: 583511.0, eccentricity: 0.002, inclination: 0.1, ascendingNode: 76.8, argumentPeriapsis: 132.2, meanAnomalyAtEpoch: 143.6, meanMotion: 360.0 / 13.463237, referencePlane: .equatorial, referencePlaneRightAscension: 0.0, referencePlaneDeclination: 90.0, retrograde: false)

        // ========================================================
        // NEPTUNE
        // ========================================================

        let proteus = Moon(name: "Proteus", radius: 0.0033, image: "moon", position: SCNVector3(0.14, 0, 0), dayLength: 1.122, epochJulianDate: 2451545.0, semiMajorAxisKM: 117600.0, eccentricity: 0.000, inclination: 0.0, ascendingNode: 0.0, argumentPeriapsis: 0.0, meanAnomalyAtEpoch: 276.8, meanMotion: 360.0 / 1.122315, referencePlane: .laplace, referencePlaneRightAscension: 299.8, referencePlaneDeclination: 42.6, retrograde: false)

        let triton = Moon(name: "Triton", radius: 0.0212, image: "moon", position: SCNVector3(0.20, 0, 0), dayLength: 5.877, epochJulianDate: 2451545.0, semiMajorAxisKM: 354800.0, eccentricity: 0.000, inclination: 157.3, ascendingNode: 178.1, argumentPeriapsis: 0.0, meanAnomalyAtEpoch: 63.0, meanMotion: 360.0 / 5.876994, referencePlane: .laplace, referencePlaneRightAscension: 299.8, referencePlaneDeclination: 43.1, retrograde: true)

        let nereid = Moon(name: "Nereid", radius: 0.0027, image: "moon", position: SCNVector3(0.32, 0, 0), dayLength: 0.48, epochJulianDate: 2458849.5, semiMajorAxisKM: 5513900.0, eccentricity: 0.751, inclination: 5.1, ascendingNode: 319.5, argumentPeriapsis: 296.8, meanAnomalyAtEpoch: 318.5, meanMotion: 360.0 / 360.133039, referencePlane: .ecliptic, referencePlaneRightAscension: 0.0, referencePlaneDeclination: 90.0, retrograde: false)

        // ========================================================
        // PLUTO
        // ========================================================

        let charon = Moon(
            name: "Charon",
            radius: 0.0606,
            image: "charon",
            position: SCNVector3(0.12, 0, 0),
            dayLength: 6.387222,
            epochJulianDate: 2451545.0,
            semiMajorAxisKM: 19600.0,
            eccentricity: 0.000,
            inclination: 0.0,
            ascendingNode: 0.0,
            argumentPeriapsis: 0.0,
            meanAnomalyAtEpoch: 304.1,
            meanMotion: 360.0 / 6.387222,
            referencePlane: .equatorial,
            referencePlaneRightAscension: 0.0,
            referencePlaneDeclination: 90.0,
            retrograde: false
        )

        // ========================================================
        // PLANETS
        // ========================================================

        return [
            Planet(name: "sun", radius: 1.0, image: "2k_sun", position: SCNVector3(0.00, 0, 0), dayLength: 25.0, orbitDays: 0.0, moons: []),
            Planet(name: "mercury", radius: 0.04, image: "mercury", position: SCNVector3(0.60, 0, 0), dayLength: 58.6462, orbitDays: 88.0, moons: []),
            Planet(name: "venus", radius: 0.12, image: "2k_venus_atmosphere", position: SCNVector3(0.90, 0, 0), dayLength: 243.018, orbitDays: 224.7, moons: []),
            Planet(name: "earth", radius: 0.127, image: "2k_earth_daymap", position: SCNVector3(1.20, 0, 0), dayLength: 0.99726968, orbitDays: 365.25, moons: [moon]),
            Planet(name: "mars", radius: 0.06, image: "mars", position: SCNVector3(1.60, 0, 0), dayLength: 1.02595676, orbitDays: 687.0, moons: [phobos, deimos]),
            Planet(name: "jupiter", radius: 1.4, image: "2k_jupiter", position: SCNVector3(2.70, 0, 0), dayLength: 0.41354, orbitDays: 4332.6, moons: [amalthea, io, europa, ganymede, callisto]),
            Planet(name: "saturn", radius: 1.20, image: "2k_saturn", position: SCNVector3(3.60, 0, 0), dayLength: 0.444, orbitDays: 10759.0, moons: [mimas, enceladus, tethys, dione, rhea, titan, hyperion, iapetus, phoebe]),
            Planet(name: "uranus", radius: 0.51, image: "2k_uranus", position: SCNVector3(4.60, 0, 0), dayLength: 0.718, orbitDays: 30687.0, moons: [miranda, ariel, umbriel, titania, oberon]),
            Planet(name: "neptune", radius: 0.50, image: "2k_neptune", position: SCNVector3(5.60, 0, 0), dayLength: 0.671, orbitDays: 60190.0, moons: [proteus, triton, nereid]),
            Planet(name: "pluto", radius: 0.18, image: "2k_pluto", position: SCNVector3(6.60, 0, 0), dayLength: 6.3872, orbitDays: 90560.0, moons: [charon])
        ]
    }

    // ============================================================
    // DWARF PLANETS / NAMED KUIPER BELT OBJECTS
    // ============================================================

    static func dwarfPlanets() -> [DwarfPlanet] {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        return [

            // ====================================================
            // ERIS
            //
            // Epoch: JD 2461200.5
            // 08 June 2026 00:00
            // ====================================================

            DwarfPlanet(
                name: "Eris",
                radius: 0.18,
                image: nil,
                displaySemiMajorAxis: 10.20,
                epochJulianDate: 2461200.5,
                semiMajorAxisAU: 67.93394688,
                eccentricity: 0.43823853,
                inclination: 43.92582795,
                ascendingNode: 36.00477044,
                argumentPeriapsis: 150.79492358,
                meanAnomalyAtEpoch: 211.77443428,
                meanMotion: 0.00176025
            ),

            // ====================================================
            // MAKEMAKE
            //
            // Epoch: JD 2461200.5
            // 08 June 2026 00:00
            // ====================================================

            DwarfPlanet(
                name: "Makemake",
                radius: 0.11,
                image: nil,
                displaySemiMajorAxis: 7.60,
                epochJulianDate: 2461200.5,
                semiMajorAxisAU: 45.57093317,
                eccentricity: 0.15888900,
                inclination: 29.02785604,
                ascendingNode: 79.29483382,
                argumentPeriapsis: 297.09227334,
                meanAnomalyAtEpoch: 169.93799620,
                meanMotion: 0.00320385
            ),

            // ====================================================
            // HAUMEA
            //
            // Epoch: JD 2461200.5
            // 08 June 2026 00:00
            // ====================================================

            DwarfPlanet(
                name: "Haumea",
                radius: 0.12,
                image: nil,
                displaySemiMajorAxis: 7.20,
                epochJulianDate: 2461200.5,
                semiMajorAxisAU: 43.06029024,
                eccentricity: 0.19444301,
                inclination: 28.20847393,
                ascendingNode: 121.78605613,
                argumentPeriapsis: 240.69054725,
                meanAnomalyAtEpoch: 223.21041188,
                meanMotion: 0.00348810
            )
        ]
    }
}

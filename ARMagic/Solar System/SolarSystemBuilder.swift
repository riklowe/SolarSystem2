//
//  SolarSystemBuilder.swift
//  SolarSystem2
//

import Foundation
import SceneKit
import UIKit
import simd

final class SolarSystemBuilder {

    let moduleName = (#file).components(separatedBy: "/")

    struct PlanetNodes {
        let planet: Planet
        let systemNode: SCNNode
        let axisNode: SCNNode
        let planetNode: SCNNode
    }

    struct MoonNodes {
        let moon: Moon
        let parentPlanetName: String
        let orbitPlaneNode: SCNNode
        let systemNode: SCNNode
        let moonNode: SCNNode
    }

    struct DwarfPlanetNodes {
        let dwarfPlanet: DwarfPlanet
        let systemNode: SCNNode
        let bodyNode: SCNNode
    }

    private let scene: SCNScene
    private let simulationClock: SimulationClock

    private var displayMode: SolarSystemDisplayMode
    private var displayScale: SolarSystemDisplayScale

    private let minimumDwarfPlanetRadius: CGFloat = 0.04

    private let plutoGM: Float = 869.3
    private let charonGM: Float = 106.1

    private(set) var rootNode: SCNNode?

    private var planetNodes: [PlanetNodes] = []
    private var moonNodes: [MoonNodes] = []
    private var dwarfPlanetNodes: [DwarfPlanetNodes] = []

    private var majorAsteroidBuilder: MajorAsteroidBuilder?
    private var cometBuilder: CometBuilder?
    private var starfieldBuilder: StarfieldBuilder?

    private var eclipseShadowRenderer: EclipseShadowRenderer?
    private var vanAllenBeltBuilder: VanAllenBeltBuilder?

    private var plutoVisible = true
    private var planetOrbitsVisible = true

    init(
        scene: SCNScene,
        simulationClock: SimulationClock,
        displayMode: SolarSystemDisplayMode = .compact
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        self.scene = scene
        self.simulationClock = simulationClock
        self.displayMode = displayMode
        self.displayScale = SolarSystemDisplayScale.scale(for: displayMode)
    }

    // ============================================================
    // MARK: - BUILD
    // ============================================================

    func build() -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        planetNodes.removeAll()
        moonNodes.removeAll()
        dwarfPlanetNodes.removeAll()

        let root = SCNNode()
        root.name = "solarSystemRoot"

        rootNode = root

        let date = simulationClock.currentDate

        createSunLight(
            in: root,
            date: date
        )

        let planets = SolarSystemData.planets()
        if displayMode == .earthMoon {

            if let earth = planets.first(where: {
                $0.name.lowercased() == "earth"
            }) {
                buildPlanet(
                    earth,
                    in: root,
                    date: date
                )
            }

        } else {

            for planet in planets {
                buildPlanet(
                    planet,
                    in: root,
                    date: date
                )
            }
        }

        // --------------------------------------------------------
        // Eclipse shadow renderer
        // --------------------------------------------------------

        if let earth = planetNodes.first(where: {
            $0.planet.name.lowercased() == "earth"
        }) {
            let renderer = EclipseShadowRenderer(
                earthPlanetNode: earth.planetNode,

                earthRadius: planetBodyRadius(
                    for: earth.planet
                )
            )

            renderer.update(for: date)
            eclipseShadowRenderer = renderer
        }

        // --------------------------------------------------------
        // Van Allen radiation belts
        // --------------------------------------------------------

        if let earth = planetNodes.first(where: {
            $0.planet.name.lowercased() == "earth"
        }) {
            let beltBuilder = VanAllenBeltBuilder(
                earthPlanetNode: earth.planetNode,

                earthRadius: planetBodyRadius(
                    for: earth.planet
                )
            )

            beltBuilder.build()
            vanAllenBeltBuilder = beltBuilder
        }

        // --------------------------------------------------------
        // Dwarf Planets
        // --------------------------------------------------------

        if displayMode != .earthMoon {

            let dwarfPlanets = SolarSystemData.dwarfPlanets()

            for dwarfPlanet in dwarfPlanets {
                buildDwarfPlanet(
                    dwarfPlanet,
                    in: root,
                    date: date
                )
            }
        }

        // --------------------------------------------------------
        // Background asteroid belt
        // --------------------------------------------------------

        // Currently disabled.
        // let asteroidBelt = AsteroidBelt.createAsteroidBelt(asteroidCount: 1500)
        // root.addChildNode(asteroidBelt)

        // --------------------------------------------------------
        // Kuiper Belt
        // --------------------------------------------------------

        if displayMode != .earthMoon {
            let kuiperBelt = KuiperBelt.create(
                displayMode: displayMode
            )
            kuiperBelt.name = "kuiper_belt"
            root.addChildNode(kuiperBelt)
        }

        // --------------------------------------------------------
        // Comets
        // --------------------------------------------------------

        if displayMode != .earthMoon {

            let newCometBuilder = CometBuilder(
                rootNode: root,
                simulationClock: simulationClock
            )

            newCometBuilder.build()
            cometBuilder = newCometBuilder
        }

        // --------------------------------------------------------
        // Major individually simulated asteroids
        // --------------------------------------------------------

        // Currently disabled.
        // let asteroidBuilder = MajorAsteroidBuilder(rootNode: root, simulationClock: simulationClock)
        // asteroidBuilder.build()
        // majorAsteroidBuilder = asteroidBuilder

        // --------------------------------------------------------
        // Distant star field and Milky Way
        // --------------------------------------------------------

        starfieldBuilder?.remove()

        let newStarfieldBuilder = StarfieldBuilder(scene: scene)
        newStarfieldBuilder.build()
        starfieldBuilder = newStarfieldBuilder

        return root
    }

    // ============================================================
    // MARK: - PLANET DISPLAY SCALE
    // ============================================================

    private func planetDisplayRadius(for planet: Planet, date: Date) -> CGFloat {

        let usesAUOrbitSpacing =
            displayMode == .astronomicalDistances ||
            displayMode == .trueBodiesAstronomicalDistances

        if usesAUOrbitSpacing,
           let elements = PlanetAstronomy.currentElements(
                for: planet.name,
                date: date
           ) {

            return CGFloat(elements.a) * displayScale.astronomicalUnitsToSceneUnits
        }

        return CGFloat(planet.position.x)
    }
    
    // ============================================================
    // MARK: - TRUE BODY SCALE DISPLAY
    // ============================================================

    // True Body Scale preserves the real physical size ratios
    // between the Sun, planets, dwarf planets and moons.
    //
    // The Sun is used as the display anchor at 0.25 scene units.
    // Every other body is scaled from its real physical diameter
    // using exactly the same scale factor.
    //
    // Orbital distances remain in the normal compact layout.

    private let trueSunDiameterKM: Double = 1_391_400.0
    private let trueSunDisplayRadius: CGFloat = 0.25

    private let physicalBodyDiametersKM: [String: Double] = [

        // --------------------------------------------------------
        // Sun / planets
        // --------------------------------------------------------

        "sun": 1_391_400.0,
        "mercury": 4_879.0,
        "venus": 12_104.0,
        "earth": 12_742.0,
        "mars": 6_779.0,
        "jupiter": 139_820.0,
        "saturn": 116_460.0,
        "uranus": 50_724.0,
        "neptune": 49_244.0,
        "pluto": 2_376.6,

        // --------------------------------------------------------
        // Earth
        // --------------------------------------------------------

        "moon": 3_474.8,

        // --------------------------------------------------------
        // Mars
        // --------------------------------------------------------

        "phobos": 22.5,
        "deimos": 12.4,

        // --------------------------------------------------------
        // Jupiter
        // --------------------------------------------------------

        "amalthea": 167.0,
        "io": 3_643.2,
        "europa": 3_121.6,
        "ganymede": 5_268.2,
        "callisto": 4_820.6,

        // --------------------------------------------------------
        // Saturn
        // --------------------------------------------------------

        "mimas": 396.4,
        "enceladus": 504.2,
        "tethys": 1_062.2,
        "dione": 1_122.8,
        "rhea": 1_527.6,
        "titan": 5_149.5,
        "hyperion": 270.0,
        "iapetus": 1_469.0,
        "phoebe": 213.0,

        // --------------------------------------------------------
        // Uranus
        // --------------------------------------------------------

        "miranda": 471.6,
        "ariel": 1_157.8,
        "umbriel": 1_169.4,
        "titania": 1_577.8,
        "oberon": 1_522.8,

        // --------------------------------------------------------
        // Neptune
        // --------------------------------------------------------

        "proteus": 420.0,
        "triton": 2_706.8,
        "nereid": 340.0,

        // --------------------------------------------------------
        // Pluto
        // --------------------------------------------------------

        "charon": 1_212.0,

        // --------------------------------------------------------
        // Dwarf planets
        // --------------------------------------------------------

        "ceres": 939.4,
        "eris": 2_326.0,
        "haumea": 1_595.0,
        "makemake": 1_430.0
    ]

    private func physicalDiameterKM(for bodyName: String, fallbackRawSize: CGFloat) -> Double {
        if let diameter = physicalBodyDiametersKM[bodyName.lowercased()] {
            return diameter
        }

        return Double(fallbackRawSize) * 100_000.0
    }

    private func trueBodyRadius(bodyName: String, fallbackRawSize: CGFloat) -> CGFloat {
        let diameterKM = physicalDiameterKM(for: bodyName, fallbackRawSize: fallbackRawSize)
        let sceneUnitsPerKM = trueSunDisplayRadius / CGFloat(trueSunDiameterKM)

        return CGFloat(diameterKM) * sceneUnitsPerKM
    }

    private func planetBodyRadius(for planet: Planet) -> CGFloat {
        if displayMode == .earthMoon &&
           planet.name.lowercased() == "earth" {

            return earthMoonEarthRadius
        }

        if displayMode == .relativeSizes || displayMode == .trueBodiesAstronomicalDistances {
            return trueBodyRadius(
                bodyName: planet.name,
                fallbackRawSize: planet.radius
            )
        }

        return max(
            planet.radius * displayScale.planetRadiusScale,
            displayScale.minimumPlanetRadius
        )
    }

    private func moonBodyRadius(for moon: Moon) -> CGFloat {

        if displayMode == .earthMoon &&
           moon.name.lowercased() == "moon" {

            return earthMoonMoonRadius
        }

        if displayMode == .relativeSizes || displayMode == .trueBodiesAstronomicalDistances
        {
            return trueBodyRadius(
                bodyName: moon.name,
                fallbackRawSize: moon.radius
            )
        }

        // AU Orbit Spacing needs enlarged moon bodies for visibility.
        //
        // Orbital positions remain adaptively scaled by moonSystemScale(),
        // but the physical moon spheres are deliberately exaggerated so
        // they remain visible alongside the much larger AU planet spacing.
        if displayMode == .astronomicalDistances {

            // Earth's Moon is stored relatively large for the normal
            // compact display. Reduce it separately in AU Orbit Spacing
            // so its visible radius is approximately proportional to Earth.
            if moon.name.lowercased() == "moon" {

                return max(
                    moon.radius * 0.05,
                    0.0015
                )
            }

            return max(
                moon.radius * 0.10,
                0.0015
            )
        }
        
        return max(
            moon.radius * displayScale.moonRadiusScale,
            displayScale.minimumMoonRadius
        )
    }

    private func dwarfPlanetBodyRadius(for dwarfPlanet: DwarfPlanet) -> CGFloat {
        if displayMode == .relativeSizes || displayMode == .trueBodiesAstronomicalDistances {
            return trueBodyRadius(
                bodyName: dwarfPlanet.name,
                fallbackRawSize: dwarfPlanet.radius
            )
        }

        return max(
            dwarfPlanet.radius * displayScale.planetRadiusScale,
            minimumDwarfPlanetRadius
        )
    }

    // ============================================================
    // MARK: - EARTH-MOON SCALE DISPLAY
    // ============================================================

    // Earth is deliberately given a useful AR display radius.
    // All Earth-Moon dimensions are then derived from real
    // physical ratios using this as the reference.

    private let earthMoonEarthRadius: CGFloat = 0.020

    private let earthPhysicalRadiusKM: Double = 6_371.0
    private let moonPhysicalRadiusKM: Double = 1_737.4
    private let moonMeanDistanceKM: Double = 384_400.0

    private var earthMoonMoonRadius: CGFloat {
        return earthMoonEarthRadius * CGFloat(moonPhysicalRadiusKM / earthPhysicalRadiusKM)
    }

    private var earthMoonMeanDisplayDistance: CGFloat {
        return earthMoonEarthRadius * CGFloat(moonMeanDistanceKM / earthPhysicalRadiusKM)
    }

    private func moonPositionScale(for moon: Moon, parentPlanet: Planet, date: Date) -> Float {
        if displayMode == .earthMoon &&
           parentPlanet.name.lowercased() == "earth" &&
           moon.name.lowercased() == "moon" {

            let normalDisplayDistance = CGFloat(abs(moon.position.x))

            guard normalDisplayDistance > 0.000001 else {
                return 1.0
            }

            return Float(
                earthMoonMeanDisplayDistance /
                normalDisplayDistance
            )
        }

        return moonSystemScale(
            for: parentPlanet,
            date: date
        )
    }

    // ============================================================
    // MARK: - AU MOON SYSTEM DISPLAY SCALE
    // ============================================================

    private func nearestPlanetOrbitGap(for parentPlanet: Planet, date: Date) -> CGFloat? {

        guard displayMode == .astronomicalDistances ||
              displayMode == .trueBodiesAstronomicalDistances else {
            return nil
        }

        let parentRadius = planetDisplayRadius(for: parentPlanet, date: date)

        let neighbourRadii = SolarSystemData.planets()
            .filter {
                $0.name.lowercased() != "sun" &&
                $0.name.lowercased() != parentPlanet.name.lowercased()
            }
            .map {
                planetDisplayRadius(for: $0, date: date)
            }

        return neighbourRadii
            .map { abs($0 - parentRadius) }
            .filter { $0 > 0.000001 }
            .min()
    }

    private func moonSystemScale(for parentPlanet: Planet, date: Date) -> Float {

        guard displayMode == .astronomicalDistances ||
              displayMode == .trueBodiesAstronomicalDistances else {

            return 1.0
        }
        
        let largestOriginalOrbit = parentPlanet.moons
            .map { CGFloat(abs($0.position.x)) }
            .max() ?? 0.0

        guard largestOriginalOrbit > 0.0 else {
            return 1.0
        }

        guard let nearestGap = nearestPlanetOrbitGap(
            for: parentPlanet,
            date: date
        ) else {
            return 1.0
        }

        let planetRadius = max(
            parentPlanet.radius * displayScale.planetRadiusScale,
            displayScale.minimumPlanetRadius
        )

        let preferredRadius = nearestGap * 0.30
        let minimumUsefulRadius = planetRadius * 1.80
        let maximumSafeRadius = nearestGap * 0.35

        let targetRadius = min(
            largestOriginalOrbit,
            min(
                maximumSafeRadius,
                max(
                    minimumUsefulRadius,
                    preferredRadius
                )
            )
        )

        let scale = targetRadius / largestOriginalOrbit
        let finalScale = Float(max(0.0, min(1.0, scale)))

//        print(
//            String(
//                format:
//                    "AU MOON SCALE %@ | original %.4f | gap %.4f | planet %.4f | target %.4f | scale %.4f",
//                parentPlanet.name,
//                Double(largestOriginalOrbit),
//                Double(nearestGap),
//                Double(planetRadius),
//                Double(targetRadius),
//                Double(finalScale)
//            )
//        )

        return finalScale
    }

    private func scaledMoonPosition(
        _ position: SCNVector3,
        moon: Moon,
        for parentPlanet: Planet,
        date: Date
    ) -> SCNVector3 {

        let scale = moonPositionScale(
            for: moon,
            parentPlanet: parentPlanet,
            date: date
        )

        return SCNVector3(
            position.x * scale,
            position.y * scale,
            position.z * scale
        )
    }

    // ============================================================
    // MARK: - PLANET
    // ============================================================

    private func buildPlanet(_ planet: Planet, in root: SCNNode, date: Date) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let planetSystemNode = SCNNode()
        planetSystemNode.name = "\(planet.name)_system"

        if displayMode == .earthMoon &&
           planet.name.lowercased() == "earth" {

            // Dedicated Earth-Moon view:
            // Earth becomes the origin of the scene.
            planetSystemNode.position =
                SCNVector3Zero

        } else if planet.name.lowercased() == "sun" {

            planetSystemNode.position =
                SCNVector3Zero

        } else {

            let displayRadius =
                planetDisplayRadius(
                    for: planet,
                    date: date
                )

            planetSystemNode.position =
                PlanetAstronomy.orbitalPosition(
                    for: planet.name,
                    date: date,
                    displayRadius: displayRadius
                )

            if displayMode != .earthMoon {

                let orbitVisual = createPlanetOrbitVisual(
                    for: planet,
                    date: date
                )

                root.addChildNode(orbitVisual)
            }
        }

        root.addChildNode(planetSystemNode)

        // --------------------------------------------------------
        // Planet rotational axis
        // --------------------------------------------------------

        let planetAxisNode = SCNNode()
        planetAxisNode.name = "\(planet.name)_axis"

        if planet.name.lowercased() != "sun" {
            let poleVector = PlanetAstronomy.eclipticPoleVector(
                for: planet.name,
                date: date
            )

            planetAxisNode.simdOrientation = simd_quatf(
                from: SIMD3<Float>(0, 1, 0),
                to: poleVector
            )
        }

        if planet.name.lowercased() == "pluto",
           let charon = planet.moons.first(where: {
               $0.name.lowercased() == "charon"
           }) {

            let charonRelativePosition = MoonAstronomy.orbitalPosition(
                for: charon,
                parentPlanetName: planet.name,
                date: date
            )

            let charonMassFraction = charonGM / (plutoGM + charonGM)

            planetAxisNode.position = SCNVector3(
                -charonRelativePosition.x * charonMassFraction,
                -charonRelativePosition.y * charonMassFraction,
                -charonRelativePosition.z * charonMassFraction
            )
        }

        planetSystemNode.addChildNode(planetAxisNode)

        // --------------------------------------------------------
        // Planet sphere
        // --------------------------------------------------------

        let planetRadius = planetBodyRadius(
            for: planet
        )

        let planetNode = createPlanetSphere(
            for: planet,
            radius: planetRadius
        )

        planetNode.name = planet.name

        let referenceOffset = PlanetAstronomy.primeMeridianReferenceOffset(
            for: planet.name,
            date: date
        )

        let primeMeridianAngle = Float(
            PlanetAstronomy.primeMeridianAngle(
                for: planet.name,
                date: date
            )
        )

        // Earth's texture is mapped 180° from the IAU prime-meridian
        // reference used by the astronomy model.
        let textureLongitudeOffset: Float =
            planet.name.lowercased() == "earth"
            ? Float.pi
            : 0.0

        planetNode.eulerAngles.y =
            referenceOffset
            - primeMeridianAngle
            + textureLongitudeOffset

        planetAxisNode.addChildNode(planetNode)

        if planet.name.lowercased() == "earth" {
            planetNode.addChildNode(
                EarthReferenceLines.create(
                    radius: planetRadius
                )
            )
        }

        // Tidal-lock diagnostic marker — enable when required.
        // if planet.name.lowercased() == "pluto" {
        //     addTidalLockTestMarker(
        //         to: planetNode,
        //         bodyRadius: planetRadius,
        //         name: "pluto_tidal_lock_test_marker"
        //     )
        // }

        // --------------------------------------------------------
        // Greenwich test marker
        // --------------------------------------------------------

        // if planet.name.lowercased() == "earth" {
        //     addGreenwichMarker(
        //         to: planetNode,
        //         planetRadius: planetRadius
        //     )
        // }

        // if planet.name.lowercased() == "mars" {
        //     addPrimeMeridianMarker(
        //         to: planetNode,
        //         planetRadius: planetRadius
        //     )
        // }

        // --------------------------------------------------------
        // Planet label
        // --------------------------------------------------------

        let label = SceneFactory.createNameLabel(
            text: planet.name.capitalized,
            objectRadius: planetRadius,
            isMoon: false,
            displayMode: displayMode
        )

        planetSystemNode.addChildNode(label)

        // --------------------------------------------------------
        // Planet rings
        // --------------------------------------------------------

        addRingsIfRequired(
            to: planetAxisNode,
            planet: planet,
            planetRadius: planetRadius
        )

        // --------------------------------------------------------
        // Store planet nodes
        // --------------------------------------------------------

        planetNodes.append(
            PlanetNodes(
                planet: planet,
                systemNode: planetSystemNode,
                axisNode: planetAxisNode,
                planetNode: planetNode
            )
        )

        // --------------------------------------------------------
        // Moons
        // --------------------------------------------------------

        for moon in planet.moons {
            buildMoon(
                moon,
                parentPlanet: planet,
                planetSystemNode: planetSystemNode,
                planetAxisNode: planetAxisNode,
                date: date
            )
        }
    }

    private var dwarfPlanetDistanceScale: Float {

        if displayMode == .trueBodiesAstronomicalDistances {
            return Float(
                displayScale.astronomicalUnitsToSceneUnits / 0.25
            )
        }

        return 1.0
    }

    private func scaledDwarfPlanetPosition(_ position: SCNVector3) -> SCNVector3 {

        let scale = dwarfPlanetDistanceScale

        return SCNVector3(
            position.x * scale,
            position.y * scale,
            position.z * scale
        )
    }
    
    // ============================================================
    // MARK: - DWARF PLANET
    // ============================================================

    private func buildDwarfPlanet(
        _ dwarfPlanet: DwarfPlanet,
        in root: SCNNode,
        date: Date
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let systemNode = SCNNode()
        systemNode.name = "\(dwarfPlanet.name.lowercased())_system"

        systemNode.position = scaledDwarfPlanetPosition(
            DwarfPlanetAstronomy.orbitalPosition(
                for: dwarfPlanet,
                date: date
            )
        )

        print("")
        print("================ DWARF PLANET POSITION TEST ================")
        print("\(dwarfPlanet.name): X \(String(format: "%.3f", systemNode.position.x))  Y \(String(format: "%.3f", systemNode.position.y))  Z \(String(format: "%.3f", systemNode.position.z))")
        print("Distance: \(String(format: "%.3f", sqrt(systemNode.position.x * systemNode.position.x + systemNode.position.y * systemNode.position.y + systemNode.position.z * systemNode.position.z)))")
        print("============================================================")
        print("")

        root.addChildNode(systemNode)

        let bodyRadius = dwarfPlanetBodyRadius(
            for: dwarfPlanet
        )

        let sphere = SCNSphere(radius: bodyRadius)
        sphere.segmentCount = 64

        let material = SCNMaterial()
        material.lightingModel = .lambert
        material.ambient.contents = UIColor.black
        material.emission.contents = UIColor.black

        if let imageName = dwarfPlanet.image,
           let image = UIImage(named: imageName) {
            material.diffuse.contents = image
        } else {
            material.diffuse.contents = UIColor.lightGray
        }

        sphere.materials = [material]

        let bodyNode = SCNNode(geometry: sphere)
        bodyNode.name = dwarfPlanet.name.lowercased()

        systemNode.addChildNode(bodyNode)

        let label = SceneFactory.createNameLabel(
            text: dwarfPlanet.name,
            objectRadius: bodyRadius,
            isMoon: false,
            displayMode: displayMode
        )

        systemNode.addChildNode(label)

        let orbitVisual = createDwarfPlanetOrbitVisual(
            for: dwarfPlanet
        )

        root.addChildNode(orbitVisual)

        dwarfPlanetNodes.append(
            DwarfPlanetNodes(
                dwarfPlanet: dwarfPlanet,
                systemNode: systemNode,
                bodyNode: bodyNode
            )
        )
    }

    // ============================================================
    // MARK: - MOON
    // ============================================================

    private func buildMoon(
        _ moon: Moon,
        parentPlanet: Planet,
        planetSystemNode: SCNNode,
        planetAxisNode: SCNNode,
        date: Date
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let orbitPlaneNode = SCNNode()
        orbitPlaneNode.name = "\(moon.name)_orbit_plane"

        // MoonAstronomy handles each moon's reference plane
        // (.ecliptic, .equatorial or .laplace), so the orbit plane
        // is attached to the planet system rather than its rotating axis.
        planetSystemNode.addChildNode(orbitPlaneNode)

        // --------------------------------------------------------
        // Moon system
        // --------------------------------------------------------

        let moonSystemNode = SCNNode()
        moonSystemNode.name = "\(moon.name)_system"

        let moonRelativePosition = scaledMoonPosition(
            MoonAstronomy.orbitalPosition(
                for: moon,
                parentPlanetName: parentPlanet.name,
                date: date
            ),
            moon: moon,
            for: parentPlanet,
            date: date
        )

        moonSystemNode.position = moonRelativePosition

        if moon.name.lowercased() == "charon" &&
           parentPlanet.name.lowercased() == "pluto" {

            let plutoMassFraction =
                plutoGM / (plutoGM + charonGM)

            moonSystemNode.position = SCNVector3(
                moonRelativePosition.x * plutoMassFraction,
                moonRelativePosition.y * plutoMassFraction,
                moonRelativePosition.z * plutoMassFraction
            )

        } else {

            moonSystemNode.position =
                moonRelativePosition
        }

        orbitPlaneNode.addChildNode(
            moonSystemNode
        )

        // --------------------------------------------------------
        // Moon sphere
        // --------------------------------------------------------

        let moonRadius = moonBodyRadius(
            for: moon
        )

        let moonNode = createMoonSphere(
            for: moon,
            radius: moonRadius
        )

        moonNode.name = moon.name

        moonSystemNode.addChildNode(
            moonNode
        )

        // Tidal-lock diagnostic marker — enable when required.
        // if moon.name.lowercased() == "charon" &&
        //    parentPlanet.name.lowercased() == "pluto" {
        //     addTidalLockTestMarker(
        //         to: moonNode,
        //         bodyRadius: moonRadius,
        //         name: "charon_tidal_lock_test_marker"
        //     )
        // }

        // --------------------------------------------------------
        // Moon label
        // --------------------------------------------------------

        let label = SceneFactory.createNameLabel(
            text: moon.name,
            objectRadius: moonRadius,
            isMoon: true,
            displayMode: displayMode
        )
        
        moonSystemNode.addChildNode(
            label
        )

        // --------------------------------------------------------
        // Moon orbit line
        // --------------------------------------------------------

        let orbitVisual = createMoonOrbitVisual(
            for: moon,
            parentPlanet: parentPlanet,
            date: date
        )

        orbitPlaneNode.addChildNode(
            orbitVisual
        )

        // --------------------------------------------------------
        // Store moon nodes
        // --------------------------------------------------------

        moonNodes.append(
            MoonNodes(
                moon: moon,
                parentPlanetName: parentPlanet.name,
                orbitPlaneNode: orbitPlaneNode,
                systemNode: moonSystemNode,
                moonNode: moonNode
            )
        )
    }

    // ============================================================
    // MARK: - PLANET GEOMETRY
    // ============================================================

    private func createPlanetSphere(
        for planet: Planet,
        radius: CGFloat
    ) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let sphere = SCNSphere(
            radius: radius
        )

        sphere.segmentCount = 96

        let material = SCNMaterial()

        if let image = UIImage(
            named: planet.image
        ) {
            material.diffuse.contents =
                image
        } else {
            material.diffuse.contents =
                UIColor.systemPink
        }

        if planet.name.lowercased() == "sun" {

            material.lightingModel =
                .constant

            material.emission.contents =
                material.diffuse.contents

        } else {

            material.lightingModel =
                .lambert

            material.ambient.contents =
                UIColor.black

            material.emission.contents =
                UIColor.black
        }

        sphere.materials = [
            material
        ]

        let node = SCNNode(
            geometry: sphere
        )

        node.castsShadow =
            planet.name.lowercased() != "sun"

        return node
    }

    // ============================================================
    // MARK: - EARTH GREENWICH TEST MARKER
    // ============================================================

    private func addGreenwichMarker(
        to planetNode: SCNNode,
        planetRadius: CGFloat
    ) {

        let latitude =
            51.4779
            * Double.pi
            / 180.0

        let longitude =
            0.0

        let radius =
            Double(
                planetRadius * 1.03
            )

        let x =
            radius
            * cos(latitude)
            * sin(longitude)

        let y =
            radius
            * sin(latitude)

        let z =
            radius
            * cos(latitude)
            * cos(longitude)

        let markerGeometry =
            SCNSphere(
                radius: max(
                    planetRadius * 0.01,
                    0.00025
                )
            )

        markerGeometry.segmentCount =
            16

        let material =
            SCNMaterial()

        material.diffuse.contents =
            UIColor.systemPink

        material.emission.contents =
            UIColor.systemPink

        material.lightingModel =
            .constant

        markerGeometry.materials =
            [
                material
            ]

        let markerNode =
            SCNNode(
                geometry: markerGeometry
            )

        markerNode.name =
            "greenwich_test_marker"

        markerNode.position =
            SCNVector3(
                Float(x),
                Float(y),
                Float(z)
            )

        planetNode.addChildNode(
            markerNode
        )
    }

    private func addPrimeMeridianMarker(
        to planetNode: SCNNode,
        planetRadius: CGFloat
    ) {

        let radius =
            planetRadius * 1.03

        let markerGeometry =
            SCNSphere(
                radius: max(
                    planetRadius * 0.015,
                    0.00025
                )
            )

        markerGeometry.segmentCount =
            16

        let material =
            SCNMaterial()

        material.diffuse.contents =
            UIColor.systemPink

        material.emission.contents =
            UIColor.systemPink

        material.lightingModel =
            .constant

        markerGeometry.materials =
            [
                material
            ]

        let markerNode =
            SCNNode(
                geometry: markerGeometry
            )

        markerNode.name =
            "prime_meridian_test_marker"

        markerNode.position =
            SCNVector3(
                0,
                0,
                radius
            )

        planetNode.addChildNode(
            markerNode
        )
    }

    // ============================================================
    // MARK: - EARTH SEASON DIAGNOSTIC
    // ============================================================

    func logEarthSeasonTest(
        for date: Date
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        guard let earth =
                planetNodes.first(
                    where: {
                        $0.planet.name.lowercased()
                        == "earth"
                    }
                )
        else {
            print(
                "EARTH SEASON TEST: Earth node not found"
            )
            return
        }

        guard let sun =
                planetNodes.first(
                    where: {
                        $0.planet.name.lowercased()
                        == "sun"
                    }
                )
        else {
            print(
                "EARTH SEASON TEST: Sun node not found"
            )
            return
        }

        let earthPosition =
            earth.systemNode.simdWorldPosition

        let sunPosition =
            sun.systemNode.simdWorldPosition

        let earthToSun =
            simd_normalize(
                sunPosition
                - earthPosition
            )

        let northPole =
            simd_normalize(
                earth.axisNode.simdConvertVector(
                    SIMD3<Float>(
                        0,
                        1,
                        0
                    ),
                    to: nil
                )
            )

        let dot =
            max(
                -1.0,
                min(
                    1.0,
                    simd_dot(
                        northPole,
                        earthToSun
                    )
                )
            )

        let solarDeclination =
            asin(
                Double(dot)
            )
            * 180.0
            / Double.pi

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
        print("================ EARTH SEASON TEST =================")
        print("UTC: \(formatter.string(from: date))")
        print(String(format: "North pole · Earth→Sun: %+.6f", dot))
        print(String(format: "Solar declination:       %+.3f°", solarDeclination))

        if abs(solarDeclination) < 1.0 {

            print(
                "Geometry: EQUINOX"
            )

        } else if solarDeclination > 20.0 {

            print(
                "Geometry: NORTHERN SUMMER SOLSTICE"
            )

        } else if solarDeclination < -20.0 {

            print(
                "Geometry: NORTHERN WINTER SOLSTICE"
            )

        } else {

            print(
                "Geometry: INTERMEDIATE SEASON"
            )
        }

        print("====================================================")
        print("")
    }

    // ============================================================
    // MARK: - TIDAL LOCK TEST MARKER
    // ============================================================

    private func addTidalLockTestMarker(
        to bodyNode: SCNNode,
        bodyRadius: CGFloat,
        name: String
    ) {

        let markerGeometry =
            SCNSphere(
                radius: max(
                    bodyRadius * 0.08,
                    0.0005
                )
            )

        markerGeometry.segmentCount =
            16

        let material =
            SCNMaterial()

        material.diffuse.contents =
            UIColor.systemPink

        material.emission.contents =
            UIColor.systemPink

        material.lightingModel =
            .constant

        markerGeometry.materials =
            [
                material
            ]

        let markerNode =
            SCNNode(
                geometry: markerGeometry
            )

        markerNode.name =
            name

        markerNode.position =
            SCNVector3(
                0,
                0,
                bodyRadius * 1.05
            )

        bodyNode.addChildNode(
            markerNode
        )
    }

    // ============================================================
    // MARK: - MOON GEOMETRY
    // ============================================================

    private func createMoonSphere(
        for moon: Moon,
        radius: CGFloat
    ) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let sphere =
            SCNSphere(
                radius: radius
            )

        sphere.segmentCount =
            48

        let material =
            SCNMaterial()

        material.lightingModel =
            .lambert

        material.ambient.contents =
            UIColor.black

        material.emission.contents =
            UIColor.black

        if let image =
                UIImage(
                    named: moon.image
                ) {

            material.diffuse.contents =
                image

        } else {

            material.diffuse.contents =
                UIColor.lightGray
        }

        sphere.materials =
            [
                material
            ]

        let node =
            SCNNode(
                geometry: sphere
            )

        node.castsShadow =
            true

        return node
    }

    // ============================================================
    // MARK: - PLANET ORBIT VISUAL
    // ============================================================

    private func createPlanetOrbitVisual(
        for planet: Planet,
        date: Date
    ) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        guard let elements =
                PlanetAstronomy.currentElements(
                    for: planet.name,
                    date: date
                )
        else {
            return SCNNode()
        }

        let orbitNode =
            SCNNode()

        orbitNode.name =
            "\(planet.name)_orbit"

        let displayRadius =
            planetDisplayRadius(
                for: planet,
                date: date
            )

        let distanceScale =
            Double(
                displayRadius
            )

        let eccentricity =
            elements.e

        let points =
            256

        var vertices: [SCNVector3] =
            []

        vertices.reserveCapacity(
            points + 1
        )

        for index in 0...points {

            let eccentricAnomaly =
                Double(index)
                / Double(points)
                * Double.pi
                * 2.0

            let xOrbital =
                cos(
                    eccentricAnomaly
                )
                - eccentricity

            let yOrbital =
                sqrt(
                    1.0
                    - eccentricity
                    * eccentricity
                )
                * sin(
                    eccentricAnomaly
                )

            let argumentPerihelion =
                Astronomy.radians(
                    elements.perihelion
                    - elements.node
                )

            let inclination =
                Astronomy.radians(
                    elements.i
                )

            let ascendingNode =
                Astronomy.radians(
                    elements.node
                )

            let x1 =
                xOrbital
                * cos(argumentPerihelion)
                - yOrbital
                * sin(argumentPerihelion)

            let y1 =
                xOrbital
                * sin(argumentPerihelion)
                + yOrbital
                * cos(argumentPerihelion)

            let x2 =
                x1

            let y2 =
                y1
                * cos(inclination)

            let z2 =
                y1
                * sin(inclination)

            let x3 =
                x2
                * cos(ascendingNode)
                - y2
                * sin(ascendingNode)

            let y3 =
                x2
                * sin(ascendingNode)
                + y2
                * cos(ascendingNode)

            vertices.append(
                SCNVector3(
                    Float(
                        x3
                        * distanceScale
                    ),
                    Float(
                        z2
                        * distanceScale
                    ),
                    Float(
                        y3
                        * distanceScale
                    )
                )
            )
        }

        let source =
            SCNGeometrySource(
                vertices: vertices
            )

        var indices: [Int32] =
            []

        for index in 0..<points {

            indices.append(
                Int32(index)
            )

            indices.append(
                Int32(index + 1)
            )
        }

        let data =
            Data(
                bytes: indices,
                count:
                    indices.count
                    * MemoryLayout<Int32>.size
            )

        let element =
            SCNGeometryElement(
                data: data,
                primitiveType: .line,
                primitiveCount: points,
                bytesPerIndex:
                    MemoryLayout<Int32>.size
            )

        let geometry =
            SCNGeometry(
                sources: [
                    source
                ],
                elements: [
                    element
                ]
            )

        let material =
            SCNMaterial()

        material.diffuse.contents =
            UIColor.green

        material.emission.contents =
            UIColor.green

        material.lightingModel =
            .constant

        material.transparency =
            1.0

        material.isDoubleSided =
            true

        geometry.materials =
            [
                material
            ]

        orbitNode.geometry =
            geometry

        return orbitNode
    }

    // ============================================================
    // MARK: - DWARF PLANET ORBIT VISUAL
    // ============================================================

    private func createDwarfPlanetOrbitVisual(
        for dwarfPlanet: DwarfPlanet
    ) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let orbitNode =
            SCNNode()

        orbitNode.name =
            "\(dwarfPlanet.name.lowercased())_orbit"

        let points =
            256

        var vertices: [SCNVector3] =
            []

        vertices.reserveCapacity(
            points + 1
        )

        for index in 0...points {

            let eccentricAnomaly =
                Double(index)
                / Double(points)
                * Double.pi
                * 2.0

            vertices.append(
                scaledDwarfPlanetPosition(
                    DwarfPlanetAstronomy.orbitPoint(
                        for: dwarfPlanet,
                        eccentricAnomaly: eccentricAnomaly
                    )
                )
            )

        }

        let source =
            SCNGeometrySource(
                vertices: vertices
            )

        var indices: [Int32] =
            []

        for index in 0..<points {

            indices.append(
                Int32(index)
            )

            indices.append(
                Int32(index + 1)
            )
        }

        let data =
            Data(
                bytes: indices,
                count:
                    indices.count
                    * MemoryLayout<Int32>.size
            )

        let element =
            SCNGeometryElement(
                data: data,
                primitiveType: .line,
                primitiveCount: points,
                bytesPerIndex:
                    MemoryLayout<Int32>.size
            )

        let geometry =
            SCNGeometry(
                sources: [
                    source
                ],
                elements: [
                    element
                ]
            )

        let material =
            SCNMaterial()

        material.diffuse.contents =
            UIColor.cyan

        material.emission.contents =
            UIColor.cyan

        material.lightingModel =
            .constant

        material.transparency =
            1.0

        material.isDoubleSided =
            true

        geometry.materials =
            [
                material
            ]

        orbitNode.geometry =
            geometry

        return orbitNode
    }

    // ============================================================
    // MARK: - MOON ORBIT VISUAL
    // ============================================================

    private func createMoonOrbitVisual(
        for moon: Moon,
        parentPlanet: Planet,
        date: Date
    ) -> SCNNode {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let orbitNode =
            SCNNode()

        orbitNode.name =
            "\(moon.name)_orbit"

        let points =
            192

        let localScale = moonPositionScale(
            for: moon,
            parentPlanet: parentPlanet,
            date: date
        )

        var vertices: [SCNVector3] =
            []

        vertices.reserveCapacity(
            points + 1
        )

        // ============================================================
        // EARTH'S MOON
        //
        // Earth's Moon now uses the higher-accuracy EarthMoonAstronomy
        // ephemeris for its displayed position.
        //
        // Therefore its visible orbit must be generated from the same
        // astronomy model rather than the old generic Kepler ellipse.
        // ============================================================

        if parentPlanet.name.lowercased() == "earth" &&
           moon.name.lowercased() == "moon" {

            let siderealPeriodDays =
                27.321661

            for index in 0...points {

                let fraction =
                    Double(index)
                    / Double(points)

                let sampleDate =
                    date.addingTimeInterval(
                        fraction
                        * siderealPeriodDays
                        * 86400.0
                    )

                let point =
                    EarthMoonAstronomy.displayPosition(
                        for: moon,
                        date: sampleDate
                    )

                vertices.append(
                    SCNVector3(
                        point.x * localScale,
                        point.y * localScale,
                        point.z * localScale
                    )
                )
            }

        } else {

            // ========================================================
            // ALL OTHER MOONS
            //
            // Retain the existing generic Kepler/reference-plane model.
            // ========================================================

            for index in 0...points {

                let eccentricAnomaly =
                    Double(index)
                    / Double(points)
                    * Double.pi
                    * 2.0

                let point =
                    MoonAstronomy.orbitPoint(
                        for: moon,
                        parentPlanetName: parentPlanet.name,
                        eccentricAnomaly: eccentricAnomaly,
                        date: date
                    )

                vertices.append(
                    SCNVector3(
                        point.x * localScale,
                        point.y * localScale,
                        point.z * localScale
                    )
                )
            }
        }

        let source =
            SCNGeometrySource(
                vertices: vertices
            )

        var indices: [Int32] =
            []

        for index in 0..<points {

            indices.append(
                Int32(index)
            )

            indices.append(
                Int32(index + 1)
            )
        }

        let data =
            Data(
                bytes: indices,
                count:
                    indices.count
                    * MemoryLayout<Int32>.size
            )

        let element =
            SCNGeometryElement(
                data: data,
                primitiveType: .line,
                primitiveCount: points,
                bytesPerIndex:
                    MemoryLayout<Int32>.size
            )

        let geometry =
            SCNGeometry(
                sources: [
                    source
                ],
                elements: [
                    element
                ]
            )

        let material =
            SCNMaterial()

        material.diffuse.contents =
            UIColor.red

        material.emission.contents =
            UIColor.red

        material.lightingModel =
            .constant

        material.transparency =
            1.0

        material.isDoubleSided =
            true

        geometry.materials =
            [
                material
            ]

        orbitNode.geometry =
            geometry

        return orbitNode
    }

    // ============================================================
    // MARK: - RINGS
    // ============================================================

    private func addRingsIfRequired(
        to axisNode: SCNNode,
        planet: Planet,
        planetRadius: CGFloat
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let ringNode: SCNNode

        switch planet.name.lowercased() {

        case "jupiter":
            ringNode =
                RingFactory.createJupiterRings(
                    planetRadius: planetRadius
                )

        case "saturn":
            ringNode =
                RingFactory.createSaturnRings(
                    planetRadius: planetRadius
                )

        case "uranus":
            ringNode =
                RingFactory.createUranusRings(
                    planetRadius: planetRadius
                )

        case "neptune":
            ringNode =
                RingFactory.createNeptuneRings(
                    planetRadius: planetRadius
                )

        default:
            return
        }

        ringNode.name =
            "\(planet.name.lowercased())_rings"

        axisNode.addChildNode(
            ringNode
        )
    }

    // ============================================================
    // MARK: - EARTH-MOON SUN LIGHT POSITION
    // ============================================================

    private func earthMoonSunLightPosition(for date: Date) -> SCNVector3 {

        // Use the same planetary astronomy model as the main Solar System
        // to determine Earth's heliocentric direction.
        //
        // The Sun as seen from Earth lies in the opposite direction.

        let earthPosition = PlanetAstronomy.orbitalPosition(
            for: "earth",
            date: date,
            displayRadius: 1.0
        )

        let vector = SIMD3<Float>(
            -earthPosition.x,
            -earthPosition.y,
            -earthPosition.z
        )

        let length = simd_length(vector)

        guard length > 0.000001 else {
            return SCNVector3(0, 0, -5.0)
        }

        let direction = vector / length

        let lightDistance: Float = 5.0

        return SCNVector3(
            direction.x * lightDistance,
            direction.y * lightDistance,
            direction.z * lightDistance
        )
    }

    // ============================================================
    // MARK: - SUN LIGHT
    // ============================================================

    private func createSunLight(
        in root: SCNNode,
        date: Date
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let lightNode =
            SCNNode()

        lightNode.name =
            "sunLight"

        let light =
            SCNLight()

        light.type =
            .omni

        light.color =
            UIColor.white

        light.intensity =
            1000

        light.attenuationStartDistance =
            0.0

        light.attenuationEndDistance =
            25.0

        light.attenuationFalloffExponent =
            0.0

        // Stage 10 — proper SceneKit shadow rendering.
        light.castsShadow =
            true

        light.shadowMode =
            .forward

        light.shadowSampleCount =
            16

        light.shadowRadius =
            3.0

        light.shadowColor =
            UIColor.black.withAlphaComponent(
                0.85
            )

        light.shadowMapSize =
            CGSize(
                width: 2048,
                height: 2048
            )

        light.zNear =
            0.001

        light.zFar =
            25.0

        lightNode.light =
            light

        if displayMode == .earthMoon {

            lightNode.position =
                earthMoonSunLightPosition(
                    for: date
                )

        } else {

            lightNode.position =
                SCNVector3Zero
        }

        root.addChildNode(
            lightNode
        )
    }

    // ============================================================
    // MARK: - SOLAR ECLIPSE DIAGNOSTIC
    // ============================================================

    func logSolarEclipseTest(
        for date: Date
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        guard let earth =
                planetNodes.first(
                    where: {
                        $0.planet.name.lowercased()
                        == "earth"
                    }
                )
        else {
            print(
                "SOLAR ECLIPSE TEST: Earth not found"
            )
            return
        }

        guard let sun =
                planetNodes.first(
                    where: {
                        $0.planet.name.lowercased()
                        == "sun"
                    }
                )
        else {
            print(
                "SOLAR ECLIPSE TEST: Sun not found"
            )
            return
        }

        guard let moon =
                moonNodes.first(
                    where: {
                        $0.parentPlanetName.lowercased()
                        == "earth"
                        &&
                        $0.moon.name.lowercased()
                        == "moon"
                    }
                )
        else {
            print(
                "SOLAR ECLIPSE TEST: Moon not found"
            )
            return
        }

        let earthPosition =
            earth.systemNode.simdWorldPosition

        let sunPosition =
            sun.systemNode.simdWorldPosition

        let moonPosition =
            moon.systemNode.simdWorldPosition

        let earthToSun =
            simd_normalize(
                sunPosition
                - earthPosition
            )

        let earthToMoon =
            simd_normalize(
                moonPosition
                - earthPosition
            )

        let dot =
            max(
                -1.0,
                min(
                    1.0,
                    simd_dot(
                        earthToSun,
                        earthToMoon
                    )
                )
            )

        let separationRadians =
            acos(
                Double(dot)
            )

        let separationDegrees =
            separationRadians
            * 180.0
            / Double.pi

        let earthMoonDistance =
            simd_distance(
                earthPosition,
                moonPosition
            )

        let moonVector =
            moonPosition
            - earthPosition

        let projectedDistance =
            simd_dot(
                moonVector,
                earthToSun
            )

        let closestPoint =
            earthPosition
            + earthToSun
            * projectedDistance

        let perpendicularOffset =
            simd_distance(
                moonPosition,
                closestPoint
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
        print("================ SOLAR ECLIPSE TEST ================")
        print("UTC: \(formatter.string(from: date))")
        print(String(format: "Sun/Moon angular separation: %.6f°", separationDegrees))
        print(String(format: "Displayed Earth-Moon distance: %.6f", earthMoonDistance))
        print(String(format: "Moon offset from Earth-Sun line: %.6f", perpendicularOffset))

        if separationDegrees < 1.0 {

            print(
                "Alignment: VERY CLOSE"
            )

        } else if separationDegrees < 5.0 {

            print(
                "Alignment: CLOSE"
            )

        } else {

            print(
                "Alignment: NOT ECLIPSE ALIGNED"
            )
        }

        print("====================================================")
        print("")
    }

    // ============================================================
    // MARK: - DIAGNOSTICS
    // ============================================================

    private func logPlanetOrientationTests(
        for date: Date
    ) {

        let planetNames = [
            "mercury",
            "venus",
            "earth",
            "mars",
            "jupiter",
            "saturn",
            "uranus",
            "neptune",
            "pluto"
        ]

        let julianDate =
            Astronomy.julianDate(
                for: date
            )

        let d =
            julianDate
            - 2451545.0

        let T =
            d
            / 36525.0

        let obliquity =
            Astronomy.radians(
                23.4392911
            )

        _ = T

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
        print("================ PLANET ORIENTATION TESTS ================")
        print("UTC: \(formatter.string(from: date))")
        print("----------------------------------------------------------")

        for planetName in planetNames {

            guard let item =
                    planetNodes.first(
                        where: {
                            $0.planet.name.lowercased()
                            == planetName
                        }
                    )
            else {
                continue
            }

            let pole =
                PlanetAstronomy.planetaryPole(
                    for: planetName,
                    date: date
                )

            let ra =
                Astronomy.radians(
                    pole.rightAscension
                )

            let dec =
                Astronomy.radians(
                    pole.declination
                )

            let north =
                SIMD3<Double>(
                    cos(dec) * cos(ra),
                    cos(dec) * sin(ra),
                    sin(dec)
                )

            let referenceX =
                simd_normalize(
                    SIMD3<Double>(
                        -sin(ra),
                        cos(ra),
                        0.0
                    )
                )

            let referenceY =
                simd_normalize(
                    simd_cross(
                        north,
                        referenceX
                    )
                )

            let W =
                Double(
                    PlanetAstronomy.primeMeridianAngle(
                        for: planetName,
                        date: date
                    )
                )

            let expectedEquatorial =
                simd_normalize(
                    referenceX * cos(W)
                    + referenceY * sin(W)
                )

            let xEcliptic =
                expectedEquatorial.x

            let yEcliptic =
                expectedEquatorial.y
                * cos(obliquity)
                + expectedEquatorial.z
                * sin(obliquity)

            let zEcliptic =
                -expectedEquatorial.y
                * sin(obliquity)
                + expectedEquatorial.z
                * cos(obliquity)

            let expectedDirection =
                simd_normalize(
                    SIMD3<Float>(
                        Float(xEcliptic),
                        Float(zEcliptic),
                        Float(yEcliptic)
                    )
                )

            let actualDirection =
                simd_normalize(
                    item.planetNode.simdConvertVector(
                        SIMD3<Float>(
                            0,
                            0,
                            1
                        ),
                        to: nil
                    )
                )

            let dotProduct =
                max(
                    -1.0,
                    min(
                        1.0,
                        simd_dot(
                            actualDirection,
                            expectedDirection
                        )
                    )
                )

            let angleDegrees =
                Double(
                    acos(dotProduct)
                )
                * 180.0
                / Double.pi

            print(
                "\(planetName.capitalized): \(String(format: "%.6f°", angleDegrees))"
            )
        }

        print("==========================================================")
        print("")
    }

    private func logEarthOrientationTest(
        for date: Date
    ) {

        guard let earth =
                planetNodes.first(
                    where: {
                        $0.planet.name.lowercased()
                        == "earth"
                    }
                )
        else {
            return
        }

        guard let sun =
                planetNodes.first(
                    where: {
                        $0.planet.name.lowercased()
                        == "sun"
                    }
                )
        else {
            return
        }

        let earthPosition =
            earth.systemNode.simdWorldPosition

        let sunPosition =
            sun.systemNode.simdWorldPosition

        let earthToSun =
            simd_normalize(
                sunPosition
                - earthPosition
            )

        let greenwichDirection =
            simd_normalize(
                earth.planetNode.simdConvertVector(
                    SIMD3<Float>(
                        0,
                        0,
                        1
                    ),
                    to: nil
                )
            )

        let dotProduct =
            max(
                -1.0,
                min(
                    1.0,
                    simd_dot(
                        greenwichDirection,
                        earthToSun
                    )
                )
            )

        let angleDegrees =
            Double(
                acos(dotProduct)
            )
            * 180.0
            / Double.pi

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
        print("================ EARTH ORIENTATION TEST ================")
        print("UTC: \(formatter.string(from: date))")
        print(String(format: "Greenwich -> Sun angle: %.3f°", angleDegrees))
        print("========================================================")
        print("")
    }

    private func logPlanetPositionTests(
        for date: Date
    ) {

        let planetNames = [
            "mercury",
            "venus",
            "earth",
            "mars",
            "jupiter",
            "saturn",
            "uranus",
            "neptune",
            "pluto"
        ]

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
        print("================ PLANET POSITION TESTS =================")
        print("UTC: \(formatter.string(from: date))")
        print("--------------------------------------------------------")

        for planetName in planetNames {

            guard let position =
                    PlanetAstronomy.heliocentricPosition(
                        for: planetName,
                        date: date
                    )
            else {
                continue
            }

            print(
                "\(planetName.capitalized): "
                + "Lon \(String(format: "%.6f", position.longitude))°  "
                + "Lat \(String(format: "%+.6f", position.latitude))°  "
                + "R \(String(format: "%.9f", position.distance)) AU"
            )
        }

        print("========================================================")
        print("")
    }

    private func logOrbitalModelComparison(
        for date: Date
    ) {

        let planetNames = [
            "mercury",
            "venus",
            "earth",
            "mars",
            "jupiter",
            "saturn",
            "uranus",
            "neptune"
        ]

        print("")
        print("================ ORBIT MODEL COMPARISON ================")

        for planetName in planetNames {

            guard let result =
                    PlanetAstronomy.modelComparison(
                        for: planetName,
                        date: date
                    )
            else {
                continue
            }

            print(
                "\(planetName.capitalized): "
                + "Short \(String(format: "%.6f", result.shortLongitude))°  "
                + "Long \(String(format: "%.6f", result.longLongitude))°  "
                + "Δ \(String(format: "%+.6f", result.difference))°"
            )
        }

        print("========================================================")
        print("")
    }

    // ============================================================
    // MARK: - DISPLAY CONTROLS
    // ============================================================

    func setPlanetsVisible(
        _ visible: Bool
    ) {

        for item in planetNodes {

            item.planetNode.isHidden =
                !visible
        }
    }

    func setMoonsVisible(
        _ visible: Bool
    ) {

        for item in moonNodes {

            item.moonNode.isHidden =
                !visible
        }
    }

    func setDwarfPlanetsVisible(
        _ visible: Bool
    ) {

        for item in dwarfPlanetNodes {

            item.bodyNode.isHidden =
                !visible
        }
    }

    func setPlutoVisible(
        _ visible: Bool
    ) {

        plutoVisible = visible

        guard let rootNode else {
            return
        }

        // Hide/show the complete Pluto-Charon system.
        if let plutoSystem = planetNodes.first(where: {
            $0.planet.name.lowercased() == "pluto"
        })?.systemNode {

            plutoSystem.isHidden = !visible
        }

        // Hide/show Pluto's heliocentric orbit.
        for node in rootNode.childNodes {

            guard
                let nodeName = node.name?.lowercased(),
                nodeName == "pluto_orbit"
            else {
                continue
            }

            node.isHidden =
                !visible || !planetOrbitsVisible
        }
    }
    
    func setPlanetOrbitsVisible(
        _ visible: Bool
    ) {

        planetOrbitsVisible = visible

        guard let rootNode else {
            return
        }

        let planetNames =
            Set(
                planetNodes.map {
                    $0.planet.name.lowercased()
                }
            )

        for node in rootNode.childNodes
        where node.name?.hasSuffix(
            "_orbit"
        ) == true {

            let objectName =
                node.name?
                    .replacingOccurrences(
                        of: "_orbit",
                        with: ""
                    )
                    .lowercased()
                ?? ""

            if planetNames.contains(
                objectName
            ) {

                if objectName == "pluto" {
                    node.isHidden =
                        !visible || !plutoVisible
                } else {
                    node.isHidden =
                        !visible
                }
            }
        }
    }

    func setMoonOrbitsVisible(
        _ visible: Bool
    ) {

        for item in moonNodes {

            item.orbitPlaneNode
                .childNodes
                .first(
                    where: {
                        $0.name?
                            .hasSuffix(
                                "_orbit"
                            )
                        == true
                    }
                )?
                .isHidden =
                !visible
        }
    }

    func setDwarfPlanetOrbitsVisible(
        _ visible: Bool
    ) {

        guard let rootNode
        else {
            return
        }

        let dwarfNames =
            Set(
                dwarfPlanetNodes.map {
                    $0.dwarfPlanet.name.lowercased()
                }
            )

        for node in rootNode.childNodes
        where node.name?.hasSuffix(
            "_orbit"
        ) == true {

            let objectName =
                node.name?
                    .replacingOccurrences(
                        of: "_orbit",
                        with: ""
                    )
                    .lowercased()
                ?? ""

            if dwarfNames.contains(
                objectName
            ) {

                node.isHidden =
                    !visible
            }
        }
    }

    func setPlanetLabelsVisible(
        _ visible: Bool
    ) {

        for item in planetNodes {

            item.systemNode
                .childNodes
                .first(
                    where: {
                        $0.name?
                            .hasPrefix(
                                "label_"
                            )
                        == true
                    }
                )?
                .isHidden =
                !visible
        }
    }

    func setMoonLabelsVisible(
        _ visible: Bool
    ) {

        for item in moonNodes {

            item.systemNode
                .childNodes
                .first(
                    where: {
                        $0.name?
                            .hasPrefix(
                                "label_"
                            )
                        == true
                    }
                )?
                .isHidden =
                !visible
        }
    }

    func setDwarfPlanetLabelsVisible(
        _ visible: Bool
    ) {

        for item in dwarfPlanetNodes {

            item.systemNode
                .childNodes
                .first(
                    where: {
                        $0.name?
                            .hasPrefix(
                                "label_"
                            )
                        == true
                    }
                )?
                .isHidden =
                !visible
        }
    }

    func setPlanetaryRingsVisible(
        _ visible: Bool
    ) {

        for item in planetNodes {

            item.axisNode
                .childNodes
                .first(
                    where: {
                        $0.name?
                            .hasSuffix(
                                "_rings"
                            )
                        == true
                    }
                )?
                .isHidden =
                !visible
        }
    }

    func setKuiperBeltVisible(
        _ visible: Bool
    ) {

        rootNode?
            .childNode(
                withName: "kuiper_belt",
                recursively: false
            )?
            .isHidden =
            !visible
    }

    // ============================================================
    // MARK: - COMET DISPLAY CONTROLS
    // ============================================================

    func setStarsVisible(
        _ visible: Bool
    ) {

        starfieldBuilder?
            .setStarsVisible(
                visible
            )
    }

    func setEarthReferenceLinesVisible(
        _ visible: Bool
    ) {

        rootNode?
            .childNode(
                withName:
                    EarthReferenceLines.nodeName,
                recursively: true
            )?
            .isHidden =
            !visible
    }

    func setVanAllenBeltsVisible(
        _ visible: Bool
    ) {

        vanAllenBeltBuilder?
            .setVisible(
                visible
            )
    }

    func setZodiacVisible(
        _ visible: Bool
    ) {

        starfieldBuilder?
            .setZodiacVisible(
                visible
            )
    }

    func setMilkyWayVisible(
        _ visible: Bool
    ) {

        starfieldBuilder?
            .setMilkyWayVisible(
                visible
            )
    }

    func setCometsVisible(
        _ visible: Bool
    ) {

        cometBuilder?
            .setCometsVisible(
                visible
            )
    }

    func setCometTailsVisible(
        _ visible: Bool
    ) {

        cometBuilder?
            .setCometTailsVisible(
                visible
            )
    }

    func setCometOrbitsVisible(
        _ visible: Bool
    ) {

        cometBuilder?
            .setCometOrbitsVisible(
                visible
            )
    }

    func setCometLabelsVisible(
        _ visible: Bool
    ) {

        cometBuilder?
            .setCometLabelsVisible(
                visible
            )
    }

    // ============================================================
    // MARK: - UPDATE
    // ============================================================

    func update(
        for date: Date
    ) {

        // --------------------------------------------------------
        // Planets
        // --------------------------------------------------------

        for item in planetNodes {

            let planet =
                item.planet

            if displayMode == .earthMoon &&
               planet.name.lowercased() == "earth" {

                item.systemNode.position =
                    SCNVector3Zero

            } else if planet.name.lowercased() != "sun" {

                let displayRadius =
                    planetDisplayRadius(
                        for: planet,
                        date: date
                    )

                item.systemNode.position =
                    PlanetAstronomy.orbitalPosition(
                        for: planet.name,
                        date: date,
                        displayRadius: displayRadius
                    )
            }

            if planet.name.lowercased() == "pluto",
               let charon =
                planet.moons.first(
                    where: {
                        $0.name.lowercased()
                        == "charon"
                    }
                ) {

                let charonRelativePosition =
                    MoonAstronomy.orbitalPosition(
                        for: charon,
                        parentPlanetName:
                            planet.name,
                        date: date
                    )

                let charonMassFraction =
                    charonGM
                    / (
                        plutoGM
                        + charonGM
                    )

                item.axisNode.position =
                    SCNVector3(
                        -charonRelativePosition.x
                            * charonMassFraction,
                        -charonRelativePosition.y
                            * charonMassFraction,
                        -charonRelativePosition.z
                            * charonMassFraction
                    )
            }

            if planet.name.lowercased()
                != "sun" {

                let poleVector =
                    PlanetAstronomy.eclipticPoleVector(
                        for: planet.name,
                        date: date
                    )

                item.axisNode.simdOrientation =
                    simd_quatf(
                        from:
                            SIMD3<Float>(
                                0,
                                1,
                                0
                            ),
                        to:
                            poleVector
                    )
            }

            let referenceOffset =
                PlanetAstronomy.primeMeridianReferenceOffset(
                    for: planet.name,
                    date: date
                )

            let primeMeridianAngle =
                Float(
                    PlanetAstronomy.primeMeridianAngle(
                        for: planet.name,
                        date: date
                    )
                )

            let textureLongitudeOffset: Float =
                planet.name.lowercased()
                == "earth"
                ? Float.pi
                : 0.0

            item.planetNode.eulerAngles.y =
                referenceOffset
                - primeMeridianAngle
                + textureLongitudeOffset
        }

        // --------------------------------------------------------
        // Earth-Moon Sun light
        // --------------------------------------------------------

        if displayMode == .earthMoon {

            rootNode?
                .childNode(
                    withName: "sunLight",
                    recursively: false
                )?
                .position =
                earthMoonSunLightPosition(
                    for: date
                )
        }
        
        // --------------------------------------------------------
        // Dwarf planets
        // --------------------------------------------------------

        for item in dwarfPlanetNodes {

            item.systemNode.position =
                scaledDwarfPlanetPosition(
                    DwarfPlanetAstronomy.orbitalPosition(
                        for: item.dwarfPlanet,
                        date: date
                    )
                )
        }

        // --------------------------------------------------------
        // Moons
        // --------------------------------------------------------

        for item in moonNodes {

            guard let parentPlanet = planetNodes.first(where: {
                $0.planet.name.lowercased() == item.parentPlanetName.lowercased()
            })?.planet else {
                continue
            }

            let moonRelativePosition = scaledMoonPosition(
                MoonAstronomy.orbitalPosition(
                    for: item.moon,
                    parentPlanetName: item.parentPlanetName,
                    date: date
                ),
                moon: item.moon,
                for: parentPlanet,
                date: date
            )

            item.systemNode.position = moonRelativePosition

            item.moonNode.eulerAngles.y = Float(
                MoonAstronomy.rotationAngle(
                    for: item.moon,
                    date: date,
                    epoch: simulationClock.epochDate
                )
            )
        }
        
        // --------------------------------------------------------
        // Comets
        // --------------------------------------------------------

        cometBuilder?
            .update(
                for: date
            )

        // --------------------------------------------------------
        // Major asteroids
        // --------------------------------------------------------

        majorAsteroidBuilder?
            .update(
                for: date
            )

        // --------------------------------------------------------
        // Eclipse shadow
        // --------------------------------------------------------

        eclipseShadowRenderer?
            .update(
                for: date
            )

        // logEarthOrientationTest(for: date)
        // logPlanetOrientationTests(for: date)
        // logPlanetPositionTests(for: date)
        // logOrbitalModelComparison(for: date)
    }

    // ============================================================
    // MARK: - REMOVE
    // ============================================================

    func remove() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        starfieldBuilder?.remove()
        starfieldBuilder = nil

        majorAsteroidBuilder?.remove()
        majorAsteroidBuilder = nil

        rootNode?.removeFromParentNode()
        rootNode = nil

        planetNodes.removeAll()
        moonNodes.removeAll()
        dwarfPlanetNodes.removeAll()

        cometBuilder?.remove()
        cometBuilder = nil

        eclipseShadowRenderer?.remove()
        eclipseShadowRenderer = nil

        vanAllenBeltBuilder?.remove()
        vanAllenBeltBuilder = nil
    }
}

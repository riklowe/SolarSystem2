//
//  MajorAsteroidBuilder.swift
//  SolarSystem2
//

import UIKit
import SceneKit

final class MajorAsteroidBuilder {

    let moduleName = (#file).components(separatedBy: "/")

    struct AsteroidNodes {
        let asteroid: Asteroid
        let systemNode: SCNNode
        let asteroidNode: SCNNode
    }

    private let rootNode: SCNNode
    private let simulationClock: SimulationClock

    private var asteroidNodes: [AsteroidNodes] = []

    init(rootNode: SCNNode, simulationClock: SimulationClock) {
        self.rootNode = rootNode
        self.simulationClock = simulationClock
    }

    func build() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        for asteroid in AsteroidData.majorAsteroids {
            buildAsteroid(asteroid)
        }
    }

    private func buildAsteroid(_ asteroid: Asteroid) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let systemNode = SCNNode()
        systemNode.name = "\(asteroid.name.lowercased())System"

        rootNode.addChildNode(systemNode)

        let geometry = SCNSphere(radius: asteroid.bodyRadius)
        geometry.segmentCount = 12

        let material = SCNMaterial()

        if let imageName = asteroid.image, let image = UIImage(named: imageName) {
            material.diffuse.contents = image
        } else {
            material.diffuse.contents = UIColor(red: 0.55, green: 0.52, blue: 0.47, alpha: 1.0)
        }

        material.emission.contents = UIColor(white: 0.25, alpha: 1.0)
        material.emission.intensity = 0.25
        material.lightingModel = .lambert

        geometry.materials = [material]

        let asteroidNode = SCNNode(geometry: geometry)
        asteroidNode.name = asteroid.name.lowercased()

        systemNode.addChildNode(asteroidNode)

        // Make the bodies slightly irregular.
        asteroidNode.scale = SCNVector3(1.0, 0.85, 0.92)

        let label = SceneFactory.createNameLabel(text: asteroid.name, objectRadius: asteroid.bodyRadius, isMoon: true)
        //let label = SceneFactory.createNameLabel(name: asteroid.name, radius: asteroid.bodyRadius, isMoon: true)
        systemNode.addChildNode(label)

        //let position = AsteroidAstronomy.orbitalPosition(for: asteroid, date: simulationClock.currentDate, epoch: simulationClock.epochDate)
        let position = AsteroidAstronomy.orbitalPosition(for: asteroid, date: simulationClock.currentDate)

        systemNode.position = position

        asteroidNodes.append(AsteroidNodes(asteroid: asteroid, systemNode: systemNode, asteroidNode: asteroidNode))
    }

    func update(for date: Date) {

        let epoch = simulationClock.epochDate

        
        for item in asteroidNodes {

            //item.systemNode.position = AsteroidAstronomy.orbitalPosition(for: item.asteroid, date: date, epoch: epoch)

            item.systemNode.position = AsteroidAstronomy.orbitalPosition(for: item.asteroid, date: date)

            item.asteroidNode.eulerAngles.y = Float(
                AsteroidAstronomy.rotationAngle(
                    for: item.asteroid,
                    date: date,
                    epoch: epoch
                )
            )
        }
    }

    func remove() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        for item in asteroidNodes {
            item.systemNode.removeFromParentNode()
        }

        asteroidNodes.removeAll()
    }
}

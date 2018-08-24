//
//  Planet.swift
//  SolarSystem2
//

import SceneKit

struct Planet {
    let name: String
    let radius: CGFloat
    let image: String
    let position: SCNVector3
    let dayLength: TimeInterval
    let orbitDays: TimeInterval
    let moons: [Moon]
}

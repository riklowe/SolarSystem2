//
//  Planet.swift
//  SolarSystem2
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.

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

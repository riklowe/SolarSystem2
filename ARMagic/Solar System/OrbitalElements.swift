//
//  AstronomyModels.swift
//  SolarSystem2
//

import Foundation

struct OrbitalElements {
    let semiMajorAxis: Double
    let semiMajorAxisRate: Double
    let eccentricity: Double
    let eccentricityRate: Double
    let inclination: Double
    let inclinationRate: Double
    let meanLongitude: Double
    let meanLongitudeRate: Double
    let longitudePerihelion: Double
    let longitudePerihelionRate: Double
    let longitudeAscendingNode: Double
    let longitudeAscendingNodeRate: Double
}

struct PoleCoordinates {
    let rightAscension: Double
    let declination: Double
}

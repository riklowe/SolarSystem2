//
//  AsteroidData.swift
//  SolarSystem2
//

import Foundation

enum AsteroidData {

    static let moduleName = (#file).components(separatedBy: "/")

    static let majorAsteroids: [Asteroid] = [

        Asteroid(name: "Ceres", displayRadius: 1.96, bodyRadius: 0.025, image: nil, epochJulianDate: 2460000.5, semiMajorAxis: 2.76718174, eccentricity: 0.07881745, inclination: 10.58634327, argumentPerihelion: 73.470461544247, ascendingNode: 80.260148690589, meanAnomalyAtEpoch: 17.215651496148, meanMotion: 0.21411522, rotationPeriodDays: 0.37809042),

        Asteroid(name: "Vesta", displayRadius: 1.90, bodyRadius: 0.018, image: nil, epochJulianDate: 2460000.5, semiMajorAxis: 2.36303821, eccentricity: 0.08875750, inclination: 7.13925798, argumentPerihelion: 151.59916398802, ascendingNode: 103.75730014935, meanAnomalyAtEpoch: 115.13298959749, meanMotion: 0.27133009, rotationPeriodDays: 0.2226),

        Asteroid(name: "Pallas", displayRadius: 1.96, bodyRadius: 0.018, image: nil, epochJulianDate: 2460000.5, semiMajorAxis: 2.76963168, eccentricity: 0.23008437, inclination: 34.92703056, argumentPerihelion: 310.86479846644, ascendingNode: 172.918132705, meanAnomalyAtEpoch: 357.84943175674, meanMotion: 0.21383119, rotationPeriodDays: 0.3256),

        Asteroid(name: "Hygiea", displayRadius: 2.05, bodyRadius: 0.016, image: nil, epochJulianDate: 2460000.5, semiMajorAxis: 3.14018109, eccentricity: 0.11115904, inclination: 3.83172841, argumentPerihelion: 312.4866514797, ascendingNode: 283.17317744373, meanAnomalyAtEpoch: 39.735493038824, meanMotion: 0.17712181, rotationPeriodDays: 0.574)
    ]
}

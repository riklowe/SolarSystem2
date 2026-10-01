//
//  NearEarthAsteroidData.swift
//  ARMagic
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.
//

import Foundation

enum NearEarthAsteroidData {

    static let apophis = NearEarthAsteroid(
        name: "Apophis",
        designation: "99942 Apophis",
        diameterKM: 0.340,
        isPotentiallyHazardous: true,
        isImpactor: false,
        encounterDate: makeUTCDate(year: 2029, month: 4, day: 13, hour: 21, minute: 46),
        encounterDistanceKM: 38_012.0,
        rotationPeriodHours: nil,
        ephemerisResourceName: "apophis",
        longTermEphemerisResourceName: "apophis_longterm",
        earthEphemerisResourceName: "earth-2029-encounter"
    )

    static let an10 = NearEarthAsteroid(
        name: "1999 AN10",
        designation: "137108 1999 AN10",
        diameterKM: 0.800,
        isPotentiallyHazardous: true,
        isImpactor: false,
        encounterDate: makeUTCDate(year: 2027, month: 8, day: 7, hour: 7, minute: 11),
        encounterDistanceKM: 389_855.0,
        rotationPeriodHours: 5.04,
        ephemerisResourceName: "an10",
        longTermEphemerisResourceName: "an10_longterm",
        earthEphemerisResourceName: "earth-2027-an10-encounter"
    )

    static let wn5 = NearEarthAsteroid(
        name: "2001 WN5",
        designation: "153814 2001 WN5",
        diameterKM: 0.932,
        isPotentiallyHazardous: true,
        isImpactor: false,
        encounterDate: makeUTCDate(year: 2028, month: 6, day: 26, hour: 5, minute: 23),
        encounterDistanceKM: 248_712.0,
        rotationPeriodHours: 4.253,
        ephemerisResourceName: "wn5",
        longTermEphemerisResourceName: "wn5_longterm",
        earthEphemerisResourceName: "earth-2028-wn5-encounter"
    )


    static let all: [NearEarthAsteroid] = [
        apophis,
        an10,
        wn5
    ]

    private static func makeUTCDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {

        var components = DateComponents()

        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)

        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0

        return components.date!
    }
}

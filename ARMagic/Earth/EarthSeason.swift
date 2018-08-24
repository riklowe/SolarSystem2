//
//  EarthSeason.swift
//  SolarSystem2
//

import Foundation
import SceneKit
import simd

enum EarthSeason: Int, CaseIterable {

    case marchEquinox
    case juneSolstice
    case septemberEquinox
    case decemberSolstice

    var title: String {
        switch self {
        case .marchEquinox: return "March Equinox"
        case .juneSolstice: return "June Solstice"
        case .septemberEquinox: return "September Equinox"
        case .decemberSolstice: return "December Solstice"
        }
    }

    private var month: Int {
        switch self {
        case .marchEquinox: return 3
        case .juneSolstice: return 6
        case .septemberEquinox: return 9
        case .decemberSolstice: return 12
        }
    }

    // ============================================================
    // MARK: - SEASONAL PRESETS
    // ============================================================

    func date(inYear year: Int) -> Date? {

        // Demonstration dates derived from the same orbital/pole model as the
        // scene, not precision almanac event times. Limit the presets to the
        // existing short-range model's supported interval.
        guard (1800...2050).contains(year) else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        guard let start = calendar.date(from: DateComponents(year: year, month: month, day: 10)),
              let end = calendar.date(from: DateComponents(year: year, month: month, day: 29))
        else { return nil }

        var lower = start.timeIntervalSince1970
        var upper = end.timeIntervalSince1970

        switch self {
        case .marchEquinox, .septemberEquinox:
            var lowerValue = Self.sunNorthComponent(at: start)
            let upperValue = Self.sunNorthComponent(at: end)
            guard lowerValue * upperValue < 0 else { return nil }

            // The Sun crosses the equatorial plane when this dot product is zero.
            while upper - lower > 60 {
                let middle = (lower + upper) / 2
                let value = Self.sunNorthComponent(at: Date(timeIntervalSince1970: middle))
                if lowerValue * value <= 0 {
                    upper = middle
                } else {
                    lower = middle
                    lowerValue = value
                }
            }

        case .juneSolstice, .decemberSolstice:
            // Find the northern/southern extreme of solar declination.
            let sign = self == .juneSolstice ? 1.0 : -1.0
            while upper - lower > 60 {
                let first = lower + (upper - lower) / 3
                let second = upper - (upper - lower) / 3
                let firstValue = sign * Self.sunNorthComponent(at: Date(timeIntervalSince1970: first))
                let secondValue = sign * Self.sunNorthComponent(at: Date(timeIntervalSince1970: second))
                if firstValue < secondValue {
                    lower = first
                } else {
                    upper = second
                }
            }
        }

        return Date(timeIntervalSince1970: (lower + upper) / 2)
    }

    static func sunNorthComponent(at date: Date) -> Double {

        let position = PlanetAstronomy.orbitalPosition(
            for: "earth",
            date: date,
            displayRadius: 1
        )
        let north = PlanetAstronomy.eclipticPoleVector(for: "earth", date: date)
        let toSun = simd_normalize(-SIMD3<Double>(
            Double(position.x), Double(position.y), Double(position.z)
        ))

        return simd_dot(toSun, SIMD3<Double>(Double(north.x), Double(north.y), Double(north.z)))
    }
}

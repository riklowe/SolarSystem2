//
//  HorizonsEphemerisDownloader.swift
//  SolarSystem2
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.
//

import Foundation

enum HorizonsEphemerisDownloader {

    // ============================================================
    // MARK: - APOPHIS ENCOUNTER
    // ============================================================

    static func downloadApophisEncounter(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "99942;",
            designation: "99942 Apophis",
            startTime: "2029-04-12 09:00",
            stopTime: "2029-04-15 10:00",
            stepSize: "1 h",
            completion: completion
        )
    }

    // ============================================================
    // MARK: - APOPHIS LONG-TERM
    // ============================================================

    static func downloadApophisLongTerm(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "99942;",
            designation: "99942 Apophis",
            startTime: "2028-01-01 00:00",
            stopTime: "2030-12-31 00:00",
            stepSize: "6 h",
            completion: completion
        )
    }

    // ============================================================
    // MARK: - APOPHIS EARTH ENCOUNTER
    // ============================================================

    static func downloadEarthEncounter(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "399",
            designation: "Earth",
            startTime: "2029-04-12 09:00",
            stopTime: "2029-04-15 10:00",
            stepSize: "1 h",
            completion: completion
        )
    }

    // ============================================================
    // MARK: - 1999 AN10 ENCOUNTER
    // ============================================================

    static func downloadAN10Encounter(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "137108;",
            designation: "137108 1999 AN10",
            startTime: "2027-08-05 19:00",
            stopTime: "2027-08-08 20:00",
            stepSize: "1 h",
            completion: completion
        )
    }

    // ============================================================
    // MARK: - 1999 AN10 LONG-TERM
    // ============================================================

    static func downloadAN10LongTerm(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "137108;",
            designation: "137108 1999 AN10",
            startTime: "2026-01-01 00:00",
            stopTime: "2028-12-31 00:00",
            stepSize: "6 h",
            completion: completion
        )
    }

    // ============================================================
    // MARK: - 1999 AN10 EARTH ENCOUNTER
    // ============================================================

    static func downloadEarthAN10Encounter(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "399",
            designation: "Earth",
            startTime: "2027-08-05 19:00",
            stopTime: "2027-08-08 20:00",
            stepSize: "1 h",
            completion: completion
        )
    }

    static func downloadWN5Encounter(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "153814;",
            designation: "153814 2001 WN5",
            startTime: "2028-06-24 17:00",
            stopTime: "2028-06-27 18:00",
            stepSize: "1 h",
            completion: completion
        )
    }

    static func downloadWN5LongTerm(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "153814;",
            designation: "153814 2001 WN5",
            startTime: "2027-01-01 00:00",
            stopTime: "2029-12-31 00:00",
            stepSize: "6 h",
            completion: completion
        )
    }

    static func downloadEarthWN5Encounter(completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {
        downloadVectors(
            command: "399",
            designation: "Earth",
            startTime: "2028-06-24 17:00",
            stopTime: "2028-06-27 18:00",
            stepSize: "1 h",
            completion: completion
        )
    }

    // ============================================================
    // MARK: - GENERIC HORIZONS VECTOR DOWNLOAD
    // ============================================================

    private static func downloadVectors(command: String, designation: String, startTime: String, stopTime: String, stepSize: String, completion: @escaping (Result<NearEarthEphemeris, Error>) -> Void) {

        var components = URLComponents(string: "https://ssd.jpl.nasa.gov/api/horizons.api")!

        components.queryItems = [
            URLQueryItem(name: "format", value: "text"),
            URLQueryItem(name: "COMMAND", value: "'\(command)'"),
            URLQueryItem(name: "OBJ_DATA", value: "'NO'"),
            URLQueryItem(name: "MAKE_EPHEM", value: "'YES'"),
            URLQueryItem(name: "EPHEM_TYPE", value: "'VECTORS'"),
            URLQueryItem(name: "CENTER", value: "'500@10'"),
            URLQueryItem(name: "START_TIME", value: "'\(startTime)'"),
            URLQueryItem(name: "STOP_TIME", value: "'\(stopTime)'"),
            URLQueryItem(name: "STEP_SIZE", value: "'\(stepSize)'"),
            URLQueryItem(name: "REF_PLANE", value: "'ECLIPTIC'"),
            URLQueryItem(name: "REF_SYSTEM", value: "'ICRF'"),
            URLQueryItem(name: "OUT_UNITS", value: "'AU-D'"),
            URLQueryItem(name: "VEC_TABLE", value: "'2'"),
            URLQueryItem(name: "VEC_CORR", value: "'NONE'"),
            URLQueryItem(name: "CSV_FORMAT", value: "'YES'"),
            URLQueryItem(name: "VEC_LABELS", value: "'NO'")
        ]

        guard var urlString = components.url?.absoluteString else {
            completion(.failure(HorizonsError.invalidURL))
            return
        }

        // Horizons requires the semicolon in small-body commands to be encoded.
        urlString = urlString.replacingOccurrences(of: ";", with: "%3B")

        guard let url = URL(string: urlString) else {
            completion(.failure(HorizonsError.invalidURL))
            return
        }

        #if DEBUG
        print("")
        print("================ HORIZONS REQUEST =====================")
        print("Object: \(designation)")
        print("Start: \(startTime)")
        print("Stop: \(stopTime)")
        print("Step: \(stepSize)")
        print(url.absoluteString)
        print("=======================================================")
        print("")
        #endif

        URLSession.shared.dataTask(with: url) { data, _, error in

            if let error {
                completion(.failure(error))
                return
            }

            guard let data, let text = String(data: data, encoding: .utf8) else {
                completion(.failure(HorizonsError.invalidResponse))
                return
            }

            do {
                let ephemeris = try parseVectorResponse(text, designation: designation)
                completion(.success(ephemeris))
            } catch {

                #if DEBUG
                print("")
                print("================ HORIZONS RAW RESPONSE ================")
                print(text)
                print("=======================================================")
                print("")
                #endif

                completion(.failure(error))
            }

        }.resume()
    }

    // ============================================================
    // MARK: - PARSER
    // ============================================================

    private static func parseVectorResponse(_ text: String, designation: String) throws -> NearEarthEphemeris {

        guard let startRange = text.range(of: "$$SOE"), let endRange = text.range(of: "$$EOE") else {
            throw HorizonsError.ephemerisMarkersNotFound
        }

        let body = text[startRange.upperBound..<endRange.lowerBound]

        var points: [NearEarthEphemerisPoint] = []

        for rawLine in body.components(separatedBy: .newlines) {

            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !line.isEmpty else { continue }

            let columns = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

            guard columns.count >= 8 else { continue }

            guard let julianDate = Double(columns[0]),
                  let x = Double(columns[2]),
                  let y = Double(columns[3]),
                  let z = Double(columns[4]),
                  let vx = Double(columns[5]),
                  let vy = Double(columns[6]),
                  let vz = Double(columns[7]) else {
                continue
            }

            points.append(
                NearEarthEphemerisPoint(
                    julianDate: julianDate,
                    xAU: x,
                    yAU: y,
                    zAU: z,
                    vxAUPerDay: vx,
                    vyAUPerDay: vy,
                    vzAUPerDay: vz
                )
            )
        }

        guard !points.isEmpty else {
            throw HorizonsError.noEphemerisPoints
        }

        return NearEarthEphemeris(
            designation: designation,
            source: "NASA/JPL Horizons",
            referenceFrame: "ICRF / Ecliptic J2000",
            centre: "Sun",
            points: points
        )
    }

    // ============================================================
    // MARK: - APOPHIS JSON OUTPUT
    // ============================================================

    static func writeJSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "apophis.json")
    }

    static func writeEarthJSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "earth-2029-encounter.json")
    }

    static func writeApophisLongTermJSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "apophis_longterm.json")
    }

    static func writeWN5JSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "wn5.json")
    }

    static func writeEarthWN5JSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "earth-2028-wn5-encounter.json")
    }

    static func writeWN5LongTermJSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "wn5_longterm.json")
    }
    
    // ============================================================
    // MARK: - 1999 AN10 JSON OUTPUT
    // ============================================================

    static func writeAN10JSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "an10.json")
    }

    static func writeEarthAN10JSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "earth-2027-an10-encounter.json")
    }

    static func writeAN10LongTermJSON(_ ephemeris: NearEarthEphemeris) throws -> URL {
        return try writeJSON(ephemeris, filename: "an10_longterm.json")
    }

    // ============================================================
    // MARK: - GENERIC JSON OUTPUT
    // ============================================================

    private static func writeJSON(_ ephemeris: NearEarthEphemeris, filename: String) throws -> URL {

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(ephemeris)

        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(filename)

        try data.write(to: url, options: .atomic)

        return url
    }
}

enum HorizonsError: Error {
    case invalidURL
    case invalidResponse
    case ephemerisMarkersNotFound
    case noEphemerisPoints
}

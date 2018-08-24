//
//  SimulationClock.swift
//  SolarSystem2
//

import Foundation

final class SimulationClock {

    let moduleName = (#file).components(separatedBy: "/")
    let baseSecondsPerDay: TimeInterval

    private(set) var simulationDate = Date()
    private(set) var epochDate = Date()


    private var realReferenceDate = Date()
    private(set) var isRunning = false
    private(set) var speedMultiplier: Double = 1.0

    init(secondsPerDay: TimeInterval) {
        self.baseSecondsPerDay = secondsPerDay
    }

    var secondsPerDay: TimeInterval { return baseSecondsPerDay / abs(speedMultiplier == 0 ? 1 : speedMultiplier) }

    var currentDate: Date {
        //printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        guard isRunning else { return simulationDate }
        let realElapsed = Date().timeIntervalSince(realReferenceDate)
        let simulatedElapsed = realElapsed * (86400.0 / baseSecondsPerDay) * speedMultiplier
        return simulationDate.addingTimeInterval(simulatedElapsed)
    }

    func start(at date: Date = Date()) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        simulationDate = date
        epochDate = date
        realReferenceDate = Date()
        isRunning = true
    }

    func pause() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        guard isRunning else { return }
        simulationDate = currentDate
        isRunning = false
    }

    func resume() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        guard !isRunning else { return }
        realReferenceDate = Date()
        isRunning = true
    }

    func stop() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        if isRunning { simulationDate = currentDate }
        isRunning = false
    }

    func reset(to date: Date = Date()) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        simulationDate = date
        realReferenceDate = Date()
        speedMultiplier = 1.0
        isRunning = false
    }

    func setSpeed(_ multiplier: Double) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        let date = currentDate
        simulationDate = date
        realReferenceDate = Date()
        speedMultiplier = multiplier
    }

    func jump(to date: Date) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")
        simulationDate = date
        realReferenceDate = Date()
    }
}

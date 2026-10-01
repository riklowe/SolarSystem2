//
//  GameViewController.swift
//  SolarSystem2
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.
//

import UIKit
import ARKit
import SceneKit

class GameViewController: UIViewController {

    let moduleName = (#file).components(separatedBy: "/")

    // ============================================================
    // MARK: - SIMULATION
    // ============================================================

    let simulationClock = SimulationClock(secondsPerDay: 2.0)

    var solarSystemBuilder: SolarSystemBuilder?

    private var solarSystemHasBeenAdded = false
    private var simulationPaused = false
    private var selectedSimulationSpeed: Double = 1.0
    private var selectedDisplayMode: SolarSystemDisplayMode = .compact
    private var seasonTestIndex = 0

    private let eclipseTestSpeed: Double = 0.001

    // ============================================================
    // MARK: - AR
    // ============================================================

    let arView: ARSCNView = {

        let view = ARSCNView()
        view.backgroundColor = .black

        return view
    }()

    let configuration = ARWorldTrackingConfiguration()

    @objc private func applicationWillResignActive() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        arView.isPlaying = false
        arView.session.pause()
    }

    @objc private func applicationDidBecomeActive() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        arView.session.run(
            configuration,
            options: []
        )

        arView.isPlaying = true
    }

    // ============================================================
    // MARK: - DATE LABEL
    // ============================================================

    let simulationDateLabel: UILabel = {

        let label = UILabel()

        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(
            ofSize: 17,
            weight: .semibold
        )

        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.70)

        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.layer.zPosition = 20

        label.text = "-- --- ----   --:--:--"

        return label
    }()

    private let simulationDateFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd MMM yyyy   HH:mm:ss"

        return formatter
    }()

    // ============================================================
    // MARK: - TIME CONTROLS
    // ============================================================

    private let simulationSpeedLabel: UILabel = {

        let label = UILabel()

        label.text = "1×"
        label.textColor = .white
        label.font = UIFont.systemFont(
            ofSize: 13,
            weight: .semibold
        )

        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private lazy var reverseFastButton = createTimeButton(
        title: "⏪",
        action: #selector(reverseFastTapped)
    )

    private lazy var reverseButton = createTimeButton(
        title: "◀︎",
        action: #selector(reverseTapped)
    )

    private lazy var pauseButton = createTimeButton(
        title: "⏸",
        action: #selector(pauseTapped)
    )

    private lazy var forwardButton = createTimeButton(
        title: "▶︎",
        action: #selector(forwardTapped)
    )

    private lazy var forwardFastButton = createTimeButton(
        title: "⏩",
        action: #selector(forwardFastTapped)
    )

    private lazy var nowButton = createTimeButton(
        title: "NOW",
        action: #selector(nowTapped)
    )

    // ============================================================
    // MARK: - CENTER IMAGE
    // ============================================================

    let centerImageView: UIImageView = {

        let view = UIImageView()

        view.image = #imageLiteral(resourceName: "Center")
        view.contentMode = .scaleAspectFill

        return view
    }()

    // ============================================================
    // MARK: - DISPLAY SETTINGS
    // ============================================================

    private lazy var settingsButton: UIButton = {

        let button = UIButton(type: .system)

        button.setTitle("⚙︎", for: .normal)
        button.setTitleColor(.white, for: .normal)

        button.titleLabel?.font =
        UIFont.systemFont(
            ofSize: 28,
            weight: .medium
        )

        button.backgroundColor =
        UIColor.black.withAlphaComponent(0.70)

        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true

        button.accessibilityLabel =
        "Display settings"

        button.addTarget(
            self,
            action: #selector(settingsButtonTapped),
            for: .touchUpInside
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let displaySettingsView = DisplaySettingsView()

    // ============================================================
    // MARK: - VIEW LIFECYCLE
    // ============================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        setupViews()
        setupAR()

//#if DEBUG
//downloadWN5Ephemerides()
//#endif

        setupTimeControls()
        setupDisplaySettings()

        let tapGestureRecognizer =
        UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )

        arView.addGestureRecognizer(
            tapGestureRecognizer
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

#if DEBUG
        //downloadApophisEphemeris()
        //downloadAN10Ephemerides()
        //downloadApophisLongTermEphemeris()
        testApophisEphemeris()
        //downloadEarthEncounterEphemeris()

        NearEarthAsteroidAstronomy.debugApophis2029Encounter()
        NearEarthAsteroidAstronomy.debugEncounter(for: NearEarthAsteroidData.an10)
        NearEarthAsteroidAstronomy.debugEncounter(for: NearEarthAsteroidData.wn5)

        NearEarthAsteroidAstronomy.debugApophisLongTermOrbitChange()

        SolarSystemDisplayCoordinates.debugCompactEncounter(asteroid: NearEarthAsteroidData.apophis)
        SolarSystemDisplayCoordinates.debugCompactEncounter(asteroid: NearEarthAsteroidData.an10)
        SolarSystemDisplayCoordinates.debugCompactEncounter(asteroid: NearEarthAsteroidData.wn5)

#endif

    }

#if DEBUG
    private func jumpToApophisEncounter() {

        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = 2029
        components.month = 4
        components.day = 13
        components.hour = 20
        components.minute = 30
        components.second = 0

        guard let date = components.date else {
            return
        }

        simulationClock.jump(to: date)

        // 180x means three simulated minutes pass for every real second.
        // The 90-minute 20:30 -> 22:00 encounter therefore takes ~30 seconds.
        let encounterSpeed = 1.0 / 240.0

        simulationClock.setSpeed(encounterSpeed)
        simulationClock.resume()

        selectedSimulationSpeed = encounterSpeed
        simulationPaused = false

        pauseButton.setTitle("⏸", for: .normal)
        simulationSpeedLabel.text = "APOPHIS FLYBY"

        solarSystemBuilder?.update(for: date)

#if DEBUG
        solarSystemBuilder?.rebuildEarthMoonOrbit(for: date)
        solarSystemBuilder?.debugEarthMoonOrbitAlignment(for: date)
#endif

        updateSimulationDateLabel()

        print("")
        print("================ APOPHIS FLYBY TEST ==================")
        print("Start: 13 Apr 2029 20:30:00 UTC")
        print("Speed: 3 simulated minutes per real second")
        print("Closest approach: approximately 21:46")
        print("======================================================")
        print("")
    }
#endif

//#if DEBUG
//    private func downloadWN5Ephemerides() {
//
//        print("")
//        print("================ WN5 HORIZONS DOWNLOAD =================")
//
//        HorizonsEphemerisDownloader.downloadWN5Encounter { result in
//            switch result {
//            case .success(let ephemeris):
//                do {
//                    let url = try HorizonsEphemerisDownloader.writeWN5JSON(ephemeris)
//                    print("WN5 encounter downloaded")
//                    print("Points: \(ephemeris.points.count)")
//                    print("File: \(url.path)")
//                } catch {
//                    print("WN5 encounter write failed: \(error)")
//                }
//
//            case .failure(let error):
//                print("WN5 encounter download failed: \(error)")
//            }
//        }
//
//        HorizonsEphemerisDownloader.downloadEarthWN5Encounter { result in
//            switch result {
//            case .success(let ephemeris):
//                do {
//                    let url = try HorizonsEphemerisDownloader.writeEarthWN5JSON(ephemeris)
//                    print("WN5 Earth encounter downloaded")
//                    print("Points: \(ephemeris.points.count)")
//                    print("File: \(url.path)")
//                } catch {
//                    print("WN5 Earth encounter write failed: \(error)")
//                }
//
//            case .failure(let error):
//                print("WN5 Earth encounter download failed: \(error)")
//            }
//        }
//
//        HorizonsEphemerisDownloader.downloadWN5LongTerm { result in
//            switch result {
//            case .success(let ephemeris):
//                do {
//                    let url = try HorizonsEphemerisDownloader.writeWN5LongTermJSON(ephemeris)
//                    print("WN5 long-term downloaded")
//                    print("Points: \(ephemeris.points.count)")
//                    print("File: \(url.path)")
//                } catch {
//                    print("WN5 long-term write failed: \(error)")
//                }
//
//            case .failure(let error):
//                print("WN5 long-term download failed: \(error)")
//            }
//        }
//    }
//#endif

#if DEBUG
private func downloadWN5Ephemerides() {

    print("")
    print("================ WN5 HORIZONS DOWNLOAD =================")
    print("")

    HorizonsEphemerisDownloader.downloadWN5Encounter { result in
        switch result {
        case .success(let ephemeris):
            do {
                let url = try HorizonsEphemerisDownloader.writeWN5JSON(ephemeris)
                print("WN5 encounter downloaded")
                print("Points: \(ephemeris.points.count)")
                print("File: \(url.path)")
            } catch {
                print("WN5 encounter write failed: \(error)")
            }

        case .failure(let error):
            print("WN5 encounter download failed: \(error)")
        }
    }

    HorizonsEphemerisDownloader.downloadEarthWN5Encounter { result in
        switch result {
        case .success(let ephemeris):
            do {
                let url = try HorizonsEphemerisDownloader.writeEarthWN5JSON(ephemeris)
                print("WN5 Earth encounter downloaded")
                print("Points: \(ephemeris.points.count)")
                print("File: \(url.path)")
            } catch {
                print("WN5 Earth encounter write failed: \(error)")
            }

        case .failure(let error):
            print("WN5 Earth encounter download failed: \(error)")
        }
    }
}
#endif


#if DEBUG
    private func downloadApophisLongTermEphemeris() {

        HorizonsEphemerisDownloader.downloadApophisLongTerm { result in

            switch result {

            case .success(let ephemeris):

                do {
                    let url = try HorizonsEphemerisDownloader.writeApophisLongTermJSON(ephemeris)

                    print("")
                    print("================ APOPHIS LONG-TERM EPHEMERIS =========")
                    print("Points: \(ephemeris.points.count)")
                    print("First JD: \(ephemeris.points.first?.julianDate ?? 0)")
                    print("Last JD: \(ephemeris.points.last?.julianDate ?? 0)")
                    print("JSON: \(url.path)")
                    print("=======================================================")
                    print("")

                } catch {
                    print("Failed writing Apophis long-term ephemeris: \(error)")
                }

            case .failure(let error):
                print("Apophis long-term Horizons download failed: \(error)")
            }
        }
    }
#endif

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // ============================================================
    // MARK: - AR SETUP
    // ============================================================

    func setupAR() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        configuration.planeDetection = [
            .horizontal,
            .vertical
        ]

        arView.autoenablesDefaultLighting = false
        arView.delegate = self
        arView.session.delegate = self

        arView.scene.background.contents =
        UIColor.black

        arView.backgroundColor = .black

        arView.session.run(
            configuration,
            options: [
                .resetTracking,
                .removeExistingAnchors
            ]
        )
    }

    // ============================================================
    // MARK: - UI SETUP
    // ============================================================

    func setupViews() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        view.backgroundColor = .black

        view.addSubview(arView)

        arView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(simulationDateLabel)

        simulationDateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            simulationDateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            simulationDateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            simulationDateLabel.widthAnchor.constraint(equalToConstant: 300),
            simulationDateLabel.heightAnchor.constraint(equalToConstant: 38)
        ])

        view.addSubview(centerImageView)

        centerImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerImageView.widthAnchor.constraint(equalToConstant: ScreenSize.width * 0.05),
            centerImageView.heightAnchor.constraint(equalToConstant: ScreenSize.width * 0.05)
        ])
    }

    // ============================================================
    // MARK: - TIME CONTROL SETUP
    // ============================================================

    private func createTimeButton(
        title: String,
        action: Selector
    ) -> UIButton {

        let button = UIButton(type: .system)

        button.setTitle(
            title,
            for: .normal
        )

        button.setTitleColor(
            .white,
            for: .normal
        )

        button.titleLabel?.font =
        UIFont.systemFont(
            ofSize: 16,
            weight: .semibold
        )

        button.backgroundColor =
        UIColor.black.withAlphaComponent(0.55)

        button.layer.cornerRadius = 8

        button.addTarget(
            self,
            action: action,
            for: .touchUpInside
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }

    private func setupTimeControls() {

        setTimeControlsEnabled(false)

        let buttonStack =
        UIStackView(
            arrangedSubviews: [
                reverseFastButton,
                reverseButton,
                pauseButton,
                forwardButton,
                forwardFastButton,
                nowButton
            ]
        )

        buttonStack.axis = .horizontal
        buttonStack.spacing = 6
        buttonStack.distribution = .fillEqually

        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let containerStack =
        UIStackView(
            arrangedSubviews: [
                simulationSpeedLabel,
                buttonStack
            ]
        )

        containerStack.axis = .vertical
        containerStack.spacing = 5

        containerStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerStack)

        NSLayoutConstraint.activate([
            containerStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            containerStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            containerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            buttonStack.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    private func setTimeControlsEnabled(_ enabled: Bool) {

        reverseFastButton.isEnabled = enabled
        reverseButton.isEnabled = enabled
        pauseButton.isEnabled = enabled
        forwardButton.isEnabled = enabled
        forwardFastButton.isEnabled = enabled
        nowButton.isEnabled = enabled

        let alpha: CGFloat =
        enabled ? 1.0 : 0.35

        reverseFastButton.alpha = alpha
        reverseButton.alpha = alpha
        pauseButton.alpha = alpha
        forwardButton.alpha = alpha
        forwardFastButton.alpha = alpha
        nowButton.alpha = alpha
    }

    // ============================================================
    // MARK: - DISPLAY SETTINGS SETUP
    // ============================================================

    private func setupDisplaySettings() {

        view.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        view.addSubview(displaySettingsView)

        NSLayoutConstraint.activate([
            displaySettingsView.topAnchor.constraint(equalTo: view.topAnchor),
            displaySettingsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            displaySettingsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            displaySettingsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        displaySettingsView.onSettingChanged = {
            [weak self] setting, visible in

            self?.applyDisplaySetting(
                setting,
                visible: visible
            )
        }

        displaySettingsView.onDisplayModeChanged = {
            [weak self] mode in

            self?.changeDisplayMode(
                to: mode
            )
        }

        selectedDisplayMode =
        displaySettingsView.currentDisplayMode()
    }

    // ============================================================
    // MARK: - DISPLAY SETTINGS ACTIONS
    // ============================================================

    @objc private func settingsButtonTapped() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        displaySettingsView.isHidden = false

        view.bringSubviewToFront(
            displaySettingsView
        )
    }

    private func applyDisplaySetting(
        _ setting: DisplaySettingsView.DisplaySetting,
        visible: Bool
    ) {

        let start = CFAbsoluteTimeGetCurrent()

        printLog(
            "DISPLAY SETTING START: \(setting) = \(visible)"
        )

        switch setting {

        case .planets:
            solarSystemBuilder?
                .setPlanetsVisible(
                    visible
                )

        case .moons:
            solarSystemBuilder?
                .setMoonsVisible(
                    visible
                )

        case .dwarfPlanets:
            solarSystemBuilder?
                .setDwarfPlanetsVisible(
                    visible
                )

        case .pluto:
            solarSystemBuilder?
                .setPlutoVisible(
                    visible
                )

        case .planetOrbits:
            solarSystemBuilder?
                .setPlanetOrbitsVisible(
                    visible
                )

        case .moonOrbits:
            solarSystemBuilder?
                .setMoonOrbitsVisible(
                    visible
                )

        case .dwarfPlanetOrbits:
            solarSystemBuilder?
                .setDwarfPlanetOrbitsVisible(
                    visible
                )

        case .planetLabels:
            solarSystemBuilder?
                .setPlanetLabelsVisible(
                    visible
                )

        case .moonLabels:
            solarSystemBuilder?
                .setMoonLabelsVisible(
                    visible
                )

        case .dwarfPlanetLabels:
            solarSystemBuilder?
                .setDwarfPlanetLabelsVisible(
                    visible
                )

        case .rings:
            solarSystemBuilder?
                .setPlanetaryRingsVisible(
                    visible
                )

        case .kuiperBelt:
            solarSystemBuilder?
                .setKuiperBeltVisible(
                    visible
                )

        case .comets:
            solarSystemBuilder?
                .setCometsVisible(
                    visible
                )

        case .cometTails:
            solarSystemBuilder?
                .setCometTailsVisible(
                    visible
                )

        case .cometOrbits:
            solarSystemBuilder?
                .setCometOrbitsVisible(
                    visible
                )

        case .cometLabels:
            solarSystemBuilder?
                .setCometLabelsVisible(
                    visible
                )

        case .stars:
            solarSystemBuilder?
                .setStarsVisible(
                    visible
                )

        case .milkyWay:
            solarSystemBuilder?
                .setMilkyWayVisible(
                    visible
                )

        case .zodiacConstellations:
            solarSystemBuilder?
                .setZodiacVisible(
                    visible
                )

        case .earthReferenceLines:
            solarSystemBuilder?
                .setEarthReferenceLinesVisible(
                    visible
                )

        case .nearEarthAsteroids:
            solarSystemBuilder?
                .setNearEarthAsteroidsVisible(visible)

        case .vanAllenBelts:
            solarSystemBuilder?
                .setVanAllenBeltsVisible(
                    visible
                )
        }

        let elapsed =
        CFAbsoluteTimeGetCurrent() - start

        printLog(
            "DISPLAY SETTING END: \(setting) elapsed=\(String(format: "%.4f", elapsed))s"
        )
    }

    // ============================================================
    // MARK: - DISPLAY MODE
    // ============================================================

    private func changeDisplayMode(
        to mode: SolarSystemDisplayMode
    ) {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        guard mode != selectedDisplayMode else {
            return
        }

        selectedDisplayMode =
        mode

        rebuildSolarSystemForDisplayMode()
    }

    private func rebuildSolarSystemForDisplayMode() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        guard solarSystemHasBeenAdded else {
            return
        }

        solarSystemBuilder?.remove()

        solarSystemBuilder =
        nil

        let builder =
        SolarSystemBuilder(
            scene: arView.scene,
            simulationClock: simulationClock,
            displayMode: selectedDisplayMode
        )

        solarSystemBuilder =
        builder

        let solarSystemNode =
        builder.build()

        solarSystemNode.position =
        SCNVector3(
            0,
            0,
            -2
        )

        arView.scene.rootNode.addChildNode(
            solarSystemNode
        )

        // Re-apply all of the user's current visibility settings
        // after rebuilding the scene.
        displaySettingsView.notifyCurrentSettings()

        // Keep the current simulation date/time.
        updateSimulationDateLabel()
    }

    // ============================================================
    // MARK: - SOLAR SYSTEM
    // ============================================================

    func addSolarSystem() {

        simulationClock.start(
            at: Date()
        )

        solarSystemBuilder =
        SolarSystemBuilder(
            scene: arView.scene,
            simulationClock: simulationClock,
            displayMode: selectedDisplayMode
        )

        if let solarSystemNode =
            solarSystemBuilder?.build() {

            solarSystemNode.position =
            SCNVector3(
                0,
                0,
                -2
            )

            arView.scene.rootNode.addChildNode(
                solarSystemNode
            )
        }

        displaySettingsView.notifyCurrentSettings()

        solarSystemHasBeenAdded = true
        simulationPaused = false
        selectedSimulationSpeed = 1.0

        pauseButton.setTitle(
            "⏸",
            for: .normal
        )

        simulationSpeedLabel.text =
        "1×"

        updateSimulationDateLabel()

        setTimeControlsEnabled(
            true
        )
    }

    func removeSolarSystem() {

        solarSystemBuilder?.remove()
        solarSystemBuilder = nil

        simulationClock.stop()

        solarSystemHasBeenAdded = false
        simulationPaused = false
        selectedSimulationSpeed = 1.0

        simulationDateLabel.text =
        "-- --- ----   --:--:--"

        simulationSpeedLabel.text =
        "1×"

        pauseButton.setTitle(
            "⏸",
            for: .normal
        )

        setTimeControlsEnabled(
            false
        )
    }

    // ============================================================
    // MARK: - DATE LABEL
    // ============================================================

    func updateSimulationDateLabel() {

        simulationDateLabel.text =
        simulationDateFormatter.string(
            from: simulationClock.currentDate
        )
    }

    // ============================================================
    // MARK: - TIME CONTROL ACTIONS
    // ============================================================

    @objc private func reverseFastTapped() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let newSpeed: Double

        if selectedSimulationSpeed <= -10.0 {
            newSpeed =
            selectedSimulationSpeed - 10.0
        } else {
            newSpeed =
            -10.0
        }

        setSimulationSpeed(
            newSpeed
        )
    }

    @objc private func reverseTapped() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let newSpeed: Double

        if selectedSimulationSpeed < 0.0 {
            newSpeed =
            selectedSimulationSpeed - 1.0
        } else {
            newSpeed =
            -1.0
        }

        setSimulationSpeed(
            newSpeed
        )
    }

    @objc private func forwardTapped() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let newSpeed: Double

        if selectedSimulationSpeed > 0.0 {
            newSpeed =
            selectedSimulationSpeed + 1.0
        } else {
            newSpeed =
            1.0
        }

        setSimulationSpeed(
            newSpeed
        )
    }

    @objc private func forwardFastTapped() {
        printLog("---------- \((moduleName.last)?.components(separatedBy: ".").first ?? "") / \(#function) ----------")

        let newSpeed: Double

        if selectedSimulationSpeed >= 10.0 {
            newSpeed =
            selectedSimulationSpeed + 10.0
        } else {
            newSpeed =
            10.0
        }

        setSimulationSpeed(
            newSpeed
        )
    }

    @objc private func pauseTapped() {

        if simulationPaused {

            simulationClock.resume()

            simulationPaused =
            false

            pauseButton.setTitle(
                "⏸",
                for: .normal
            )

            simulationSpeedLabel.text =
            speedDescription(
                selectedSimulationSpeed
            )

        } else {

            simulationClock.pause()

            simulationPaused =
            true

            pauseButton.setTitle(
                "▶︎",
                for: .normal
            )

            simulationSpeedLabel.text =
            "PAUSED"
        }
    }

    @objc private func nowTapped() {

#if DEBUG
        jumpToApophisEncounter()
        return
#endif

        simulationClock.jump(
            to: Date()
        )

        simulationClock.setSpeed(
            1.0
        )

        simulationClock.pause()

        selectedSimulationSpeed =
        1.0

        simulationPaused =
        true

        pauseButton.setTitle(
            "▶︎",
            for: .normal
        )

        simulationSpeedLabel.text =
        "PAUSED"

        updateSimulationDateLabel()
    }

    private func setSimulationSpeed(
        _ speed: Double
    ) {

        selectedSimulationSpeed =
        speed

        simulationClock.setSpeed(
            speed
        )

        if !simulationClock.isRunning {
            simulationClock.resume()
        }

        simulationPaused =
        false

        pauseButton.setTitle(
            "⏸",
            for: .normal
        )

        simulationSpeedLabel.text =
        speedDescription(
            speed
        )
    }

    private func speedDescription(
        _ speed: Double
    ) -> String {

        if speed < 0 {
            return "\(Int(abs(speed)))× REVERSE"
        }

        return "\(Int(speed))×"
    }

    // ============================================================
    // MARK: - RESET
    // ============================================================

    func resetScene() {

        removeSolarSystem()

        simulationClock.reset()

        arView.session.pause()

        arView.session.run(
            configuration,
            options: [
                .removeExistingAnchors,
                .resetTracking
            ]
        )
    }

    // ============================================================
    // MARK: - AR FLOOR
    // ============================================================

    func createFloor(
        anchor: ARPlaneAnchor
    ) -> SCNNode {

        let floor =
        SCNNode()

        floor.name =
        "floor"

        floor.eulerAngles =
        SCNVector3(
            Float.pi / 2.0,
            0,
            0
        )

        floor.geometry =
        SCNPlane(
            width: CGFloat(
                anchor.planeExtent.width
            ),
            height: CGFloat(
                anchor.planeExtent.height
            )
        )

        floor.position =
        SCNVector3(
            anchor.center.x,
            anchor.center.y,
            anchor.center.z
        )

        floor.geometry?
            .firstMaterial?
            .diffuse
            .contents =
        UIColor.clear

        floor.geometry?
            .firstMaterial?
            .transparency =
        0.0

        return floor
    }

    // ============================================================
    // MARK: - TAP
    // ============================================================

    @objc func handleTap(
        sender: UITapGestureRecognizer
    ) {

        let tappedView =
        sender.view as! SCNView

        let touchLocation =
        sender.location(
            in: tappedView
        )

        let hitTest =
        tappedView.hitTest(
            touchLocation,
            options: nil
        )

        if let result =
            hitTest.first {

            printLog(
                "Tapped: \(result.node.name ?? "Unknown")"
            )
        }
    }

    //#if DEBUG
    //private func downloadAN10Ephemerides() {
    //
    //    print("")
    //    print("================ AN10 DOWNLOAD START ==================")
    //    print("")
    //
    //    HorizonsEphemerisDownloader.downloadAN10Encounter { encounterResult in
    //
    //        switch encounterResult {
    //
    //        case .success(let encounterEphemeris):
    //
    //            do {
    //                let encounterURL = try HorizonsEphemerisDownloader.writeAN10JSON(encounterEphemeris)
    //
    //                print("")
    //                print("================ AN10 ENCOUNTER =======================")
    //                print("Points: \(encounterEphemeris.points.count)")
    //                print("First JD: \(encounterEphemeris.points.first?.julianDate ?? 0)")
    //                print("Last JD: \(encounterEphemeris.points.last?.julianDate ?? 0)")
    //                print("JSON: \(encounterURL.path)")
    //                print("=======================================================")
    //                print("")
    //
    //            } catch {
    //                print("Failed writing AN10 encounter ephemeris: \(error)")
    //                return
    //            }
    //
    //            HorizonsEphemerisDownloader.downloadEarthAN10Encounter { earthResult in
    //
    //                switch earthResult {
    //
    //                case .success(let earthEphemeris):
    //
    //                    do {
    //                        let earthURL = try HorizonsEphemerisDownloader.writeEarthAN10JSON(earthEphemeris)
    //
    //                        print("")
    //                        print("================ AN10 EARTH ===========================")
    //                        print("Points: \(earthEphemeris.points.count)")
    //                        print("First JD: \(earthEphemeris.points.first?.julianDate ?? 0)")
    //                        print("Last JD: \(earthEphemeris.points.last?.julianDate ?? 0)")
    //                        print("JSON: \(earthURL.path)")
    //                        print("=======================================================")
    //                        print("")
    //
    //                    } catch {
    //                        print("Failed writing AN10 Earth ephemeris: \(error)")
    //                        return
    //                    }
    //
    //                    HorizonsEphemerisDownloader.downloadAN10LongTerm { longTermResult in
    //
    //                        switch longTermResult {
    //
    //                        case .success(let longTermEphemeris):
    //
    //                            do {
    //                                let longTermURL = try HorizonsEphemerisDownloader.writeAN10LongTermJSON(longTermEphemeris)
    //
    //                                print("")
    //                                print("================ AN10 LONG-TERM =======================")
    //                                print("Points: \(longTermEphemeris.points.count)")
    //                                print("First JD: \(longTermEphemeris.points.first?.julianDate ?? 0)")
    //                                print("Last JD: \(longTermEphemeris.points.last?.julianDate ?? 0)")
    //                                print("JSON: \(longTermURL.path)")
    //                                print("=======================================================")
    //                                print("")
    //
    //                                print("================ AN10 DOWNLOAD COMPLETE ===============")
    //                                print("All three AN10 ephemeris files created successfully.")
    //                                print("=======================================================")
    //                                print("")
    //
    //                            } catch {
    //                                print("Failed writing AN10 long-term ephemeris: \(error)")
    //                            }
    //
    //                        case .failure(let error):
    //                            print("AN10 long-term Horizons download failed: \(error)")
    //                        }
    //                    }
    //
    //                case .failure(let error):
    //                    print("AN10 Earth Horizons download failed: \(error)")
    //                }
    //            }
    //
    //        case .failure(let error):
    //            print("AN10 encounter Horizons download failed: \(error)")
    //        }
    //    }
    //}
    //#endif

#if DEBUG
    private func testApophisEphemeris() {

        NearEarthAsteroidAstronomy.debugEphemeris(for: NearEarthAsteroidData.apophis)

        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = 2029
        components.month = 4
        components.day = 13
        components.hour = 21
        components.minute = 46
        components.second = 0

        guard let date = components.date else {
            print("Unable to create Apophis test date")
            return
        }

        NearEarthAsteroidAstronomy.debugPosition(
            for: NearEarthAsteroidData.apophis,
            date: date
        )
    }
#endif

#if DEBUG
    private func downloadEarthEncounterEphemeris() {

        HorizonsEphemerisDownloader.downloadEarthEncounter { result in

            switch result {

            case .success(let ephemeris):

                do {
                    let url = try HorizonsEphemerisDownloader.writeEarthJSON(ephemeris)

                    print("")
                    print("================ EARTH EPHEMERIS ====================")
                    print("Points: \(ephemeris.points.count)")
                    print("First JD: \(ephemeris.points.first?.julianDate ?? 0)")
                    print("Last JD: \(ephemeris.points.last?.julianDate ?? 0)")
                    print("JSON: \(url.path)")
                    print("=====================================================")
                    print("")

                } catch {
                    print("Failed writing Earth ephemeris: \(error)")
                }

            case .failure(let error):
                print("Earth Horizons download failed: \(error)")
            }
        }
    }
#endif

    deinit {

        NotificationCenter.default.removeObserver(
            self
        )
    }
}


// ============================================================
// MARK: - ARSCNVIEW DELEGATE
// ============================================================

extension GameViewController: ARSCNViewDelegate {

    func renderer(
        _ renderer: SCNSceneRenderer,
        updateAtTime time: TimeInterval
    ) {

        // No printLog here — this runs every rendered frame.

        guard simulationClock.isRunning
        else {
            return
        }

        let date =
        simulationClock.currentDate

        solarSystemBuilder?
            .update(
                for: date
            )

        DispatchQueue.main.async {
            [weak self] in

            guard let self =
                    self
            else {
                return
            }

            self.updateSimulationDateLabel()
        }
    }

    func renderer(
        _ renderer: SCNSceneRenderer,
        didAdd node: SCNNode,
        for anchor: ARAnchor
    ) {

        guard let plane =
                anchor as? ARPlaneAnchor
        else {
            return
        }

        node.addChildNode(
            createFloor(
                anchor: plane
            )
        )
    }

    func renderer(
        _ renderer: SCNSceneRenderer,
        didUpdate node: SCNNode,
        for anchor: ARAnchor
    ) {

        guard let plane =
                anchor as? ARPlaneAnchor
        else {
            return
        }

        node.childNodes
            .filter {
                $0.name == "floor"
            }
            .forEach {
                $0.removeFromParentNode()
            }

        node.addChildNode(
            createFloor(
                anchor: plane
            )
        )
    }

    func renderer(
        _ renderer: SCNSceneRenderer,
        didRemove node: SCNNode,
        for anchor: ARAnchor
    ) {

        guard anchor is ARPlaneAnchor
        else {
            return
        }
    }
}


// ============================================================
// MARK: - ARSESSION DELEGATE
// ============================================================

extension GameViewController: ARSessionDelegate {

    func session(
        _ session: ARSession,
        cameraDidChangeTrackingState camera: ARCamera
    ) {

        switch camera.trackingState {

        case .normal:

            printLog(
                "AR tracking state: NORMAL"
            )

            DispatchQueue.main.async {
                [weak self] in

                guard let self =
                        self
                else {
                    return
                }

                if !self.solarSystemHasBeenAdded {

                    self.addSolarSystem()
                }
            }

        case .limited(let reason):

            printLog(
                "AR tracking state: LIMITED - \(reason)"
            )

        case .notAvailable:

            printLog(
                "AR tracking state: NOT AVAILABLE"
            )

        @unknown default:

            printLog(
                "AR tracking state: UNKNOWN"
            )
        }
    }
}


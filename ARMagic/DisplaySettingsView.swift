//
//  DisplaySettingsView.swift
//  SolarSystem2
//
//  Created by Richard Lowe
//  Copyright © 2026. All rights reserved
//
//  Based On - ARMagic by Alex Nagy on 09/01/2018.
//

import UIKit

// ============================================================
// MARK: - DISPLAY TOGGLE BUTTON
// ============================================================

private final class DisplayToggleButton: UIButton {

    private(set) var isOn = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)

        layer.cornerRadius = 15
        layer.borderWidth = 1

        contentEdgeInsets = UIEdgeInsets(
            top: 5,
            left: 11,
            bottom: 5,
            right: 11
        )

        refreshAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        refreshAppearance()
    }

    func setOn(_ on: Bool, animated: Bool) {

        isOn = on

        if animated {

            UIView.transition(
                with: self,
                duration: 0.15,
                options: .transitionCrossDissolve,
                animations: {
                    self.refreshAppearance()
                }
            )

        } else {

            refreshAppearance()
        }
    }

    private func refreshAppearance() {

        setTitle(
            isOn ? "ON" : "OFF",
            for: .normal
        )

        if isOn {

            backgroundColor =
                UIColor.systemGreen.withAlphaComponent(0.80)

            layer.borderColor =
                UIColor.systemGreen.cgColor

            setTitleColor(
                .white,
                for: .normal
            )

        } else {

            backgroundColor =
                UIColor.white.withAlphaComponent(0.10)

            layer.borderColor =
                UIColor.white.withAlphaComponent(0.25).cgColor

            setTitleColor(
                UIColor.white.withAlphaComponent(0.70),
                for: .normal
            )
        }
    }
}


// ============================================================
// MARK: - DISPLAY SETTINGS VIEW
// ============================================================

final class DisplaySettingsView: UIView {

    enum DisplaySetting: Int, CaseIterable {

        case planets = 1
        case moons
        case dwarfPlanets

        case planetOrbits
        case moonOrbits
        case dwarfPlanetOrbits

        case planetLabels
        case moonLabels
        case dwarfPlanetLabels

        case rings
        case kuiperBelt

        case comets
        case cometTails
        case cometOrbits
        case cometLabels

        // Append new settings to preserve existing UserDefaults keys.
        case stars = 16
        case milkyWay = 17
        case zodiacConstellations = 18
        case earthReferenceLines = 19
        case vanAllenBelts = 20
    }

    // ============================================================
    // MARK: - DISPLAY MODE PERSISTENCE
    // ============================================================

    private let displayModeDefaultsKey = "solarSystemDisplayMode"

    private var selectedDisplayMode: SolarSystemDisplayMode {

        get {

            guard
                let rawValue = UserDefaults.standard.string(
                    forKey: displayModeDefaultsKey
                ),
                let mode = SolarSystemDisplayMode(
                    rawValue: rawValue
                )
            else {
                return .compact
            }

            return mode
        }

        set {

            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: displayModeDefaultsKey
            )
        }
    }

    // ============================================================
    // MARK: - DISPLAY SETTINGS PERSISTENCE
    // ============================================================

    private func displaySettingKey(
        _ setting: DisplaySetting
    ) -> String {

        return "DisplaySetting_\(setting.rawValue)"
    }

    private func savedDisplaySetting(
        _ setting: DisplaySetting
    ) -> Bool {

        let key = displaySettingKey(
            setting
        )

        if UserDefaults.standard.object(
            forKey: key
        ) == nil {

            // Van Allen belts are an informational overlay,
            // so default OFF.
            if setting == .vanAllenBelts {
                return false
            }

            return true
        }

        return UserDefaults.standard.bool(
            forKey: key
        )
    }

    private func saveDisplaySetting(
        _ setting: DisplaySetting,
        value: Bool
    ) {

        UserDefaults.standard.set(
            value,
            forKey: displaySettingKey(setting)
        )
    }

    private func saveAllDisplaySettings() {

        for setting in DisplaySetting.allCases {

            let displaySwitch =
                displaySwitch(
                    for: setting
                )

            saveDisplaySetting(
                setting,
                value: displaySwitch.isOn
            )
        }
    }

    private func displaySwitch(
        for setting: DisplaySetting
    ) -> DisplayToggleButton {

        switch setting {

        case .planets:
            return planetsSwitch

        case .moons:
            return moonsSwitch

        case .dwarfPlanets:
            return dwarfPlanetsSwitch

        case .planetOrbits:
            return planetOrbitsSwitch

        case .moonOrbits:
            return moonOrbitsSwitch

        case .dwarfPlanetOrbits:
            return dwarfPlanetOrbitsSwitch

        case .planetLabels:
            return planetLabelsSwitch

        case .moonLabels:
            return moonLabelsSwitch

        case .dwarfPlanetLabels:
            return dwarfPlanetLabelsSwitch

        case .rings:
            return ringsSwitch

        case .kuiperBelt:
            return kuiperBeltSwitch

        case .comets:
            return cometsSwitch

        case .cometTails:
            return cometTailsSwitch

        case .cometOrbits:
            return cometOrbitsSwitch

        case .cometLabels:
            return cometLabelsSwitch

        case .stars:
            return starsSwitch

        case .milkyWay:
            return milkyWaySwitch

        case .zodiacConstellations:
            return zodiacConstellationsSwitch

        case .earthReferenceLines:
            return earthReferenceLinesSwitch

        case .vanAllenBelts:
            return vanAllenBeltsSwitch
        }
    }

    // ============================================================
    // MARK: - PANEL
    // ============================================================

    private let settingsPanelView: UIView = {

        let view = UIView()

        view.backgroundColor =
            UIColor.black.withAlphaComponent(0.90)

        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1

        view.layer.borderColor =
            UIColor.white
                .withAlphaComponent(0.20)
                .cgColor

        view.translatesAutoresizingMaskIntoConstraints =
            false

        return view
    }()

    private let settingsScrollView: UIScrollView = {

        let scrollView = UIScrollView()

        scrollView.alwaysBounceVertical =
            false

        scrollView.showsVerticalScrollIndicator =
            true

        scrollView.translatesAutoresizingMaskIntoConstraints =
            false

        return scrollView
    }()

    private let settingsContentView: UIView = {

        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints =
            false

        return view
    }()

    // ============================================================
    // MARK: - DISPLAY CONTROLS
    // ============================================================

    private lazy var planetsSwitch =
        createDisplaySwitch(
            setting: .planets
        )

    private lazy var moonsSwitch =
        createDisplaySwitch(
            setting: .moons
        )

    private lazy var dwarfPlanetsSwitch =
        createDisplaySwitch(
            setting: .dwarfPlanets
        )

    private lazy var planetOrbitsSwitch =
        createDisplaySwitch(
            setting: .planetOrbits
        )

    private lazy var moonOrbitsSwitch =
        createDisplaySwitch(
            setting: .moonOrbits
        )

    private lazy var dwarfPlanetOrbitsSwitch =
        createDisplaySwitch(
            setting: .dwarfPlanetOrbits
        )

    private lazy var planetLabelsSwitch =
        createDisplaySwitch(
            setting: .planetLabels
        )

    private lazy var moonLabelsSwitch =
        createDisplaySwitch(
            setting: .moonLabels
        )

    private lazy var dwarfPlanetLabelsSwitch =
        createDisplaySwitch(
            setting: .dwarfPlanetLabels
        )

    private lazy var ringsSwitch =
        createDisplaySwitch(
            setting: .rings
        )

    private lazy var kuiperBeltSwitch =
        createDisplaySwitch(
            setting: .kuiperBelt
        )

    private lazy var cometsSwitch =
        createDisplaySwitch(
            setting: .comets
        )

    private lazy var cometTailsSwitch =
        createDisplaySwitch(
            setting: .cometTails
        )

    private lazy var cometOrbitsSwitch =
        createDisplaySwitch(
            setting: .cometOrbits
        )

    private lazy var cometLabelsSwitch =
        createDisplaySwitch(
            setting: .cometLabels
        )

    private lazy var starsSwitch =
        createDisplaySwitch(
            setting: .stars
        )

    private lazy var milkyWaySwitch =
        createDisplaySwitch(
            setting: .milkyWay
        )

    private lazy var zodiacConstellationsSwitch =
        createDisplaySwitch(
            setting: .zodiacConstellations
        )

    private lazy var earthReferenceLinesSwitch =
        createDisplaySwitch(
            setting: .earthReferenceLines
        )

    private lazy var vanAllenBeltsSwitch =
        createDisplaySwitch(
            setting: .vanAllenBelts
        )

    // ============================================================
    // MARK: - DISPLAY MODE CONTROLS
    // ============================================================

    private lazy var compactModeButton =
        createDisplayModeButton(
            title: "Compact",
            action: #selector(compactModeTapped)
        )

    private lazy var relativeSizesModeButton =
        createDisplayModeButton(
            title: "True Body Scale",
            action: #selector(relativeSizesModeTapped)
        )

    private lazy var astronomicalDistancesModeButton =
        createDisplayModeButton(
            title: "AU Orbit Spacing",
            action: #selector(astronomicalDistancesModeTapped)
        )

    private lazy var earthMoonModeButton =
        createDisplayModeButton(
            title: "Earth–Moon Scale",
            action: #selector(earthMoonModeTapped)
        )

    // ============================================================
    // MARK: - CALLBACKS
    // ============================================================

    var onSettingChanged:
        ((DisplaySetting, Bool) -> Void)?

    var onDisplayModeChanged:
        ((SolarSystemDisplayMode) -> Void)?

    // ============================================================
    // MARK: - INITIALIZATION
    // ============================================================

    override init(frame: CGRect) {

        super.init(
            frame: frame
        )

        setupDisplaySettings()
    }

    required init?(coder: NSCoder) {

        super.init(
            coder: coder
        )

        setupDisplaySettings()
    }

    // ============================================================
    // MARK: - SETUP
    // ============================================================

    private func setupDisplaySettings() {

        backgroundColor =
            UIColor.black.withAlphaComponent(0.55)

        isHidden = true

        translatesAutoresizingMaskIntoConstraints =
            false

        self.addSubview(
            settingsPanelView
        )

        NSLayoutConstraint.activate([

            settingsPanelView.centerXAnchor.constraint(
                equalTo: self.centerXAnchor
            ),

            settingsPanelView.centerYAnchor.constraint(
                equalTo: self.centerYAnchor
            ),

            settingsPanelView.leadingAnchor.constraint(
                greaterThanOrEqualTo:
                    self.safeAreaLayoutGuide.leadingAnchor,
                constant: 18
            ),

            settingsPanelView.trailingAnchor.constraint(
                lessThanOrEqualTo:
                    self.safeAreaLayoutGuide.trailingAnchor,
                constant: -18
            ),

            settingsPanelView.widthAnchor.constraint(
                lessThanOrEqualToConstant: 420
            ),

            settingsPanelView.widthAnchor.constraint(
                equalTo:
                    self.safeAreaLayoutGuide.widthAnchor,
                constant: -36
            )
            .withPriority(
                UILayoutPriority(750)
            ),

            settingsPanelView.heightAnchor.constraint(
                equalTo:
                    self.safeAreaLayoutGuide.heightAnchor,
                multiplier: 0.82
            ),

            settingsPanelView.heightAnchor.constraint(
                lessThanOrEqualTo:
                    self.safeAreaLayoutGuide.heightAnchor,
                constant: -40
            )
        ])

        settingsPanelView.addSubview(
            settingsScrollView
        )

        NSLayoutConstraint.activate([

            settingsScrollView.topAnchor.constraint(
                equalTo:
                    settingsPanelView.topAnchor
            ),

            settingsScrollView.leadingAnchor.constraint(
                equalTo:
                    settingsPanelView.leadingAnchor
            ),

            settingsScrollView.trailingAnchor.constraint(
                equalTo:
                    settingsPanelView.trailingAnchor
            ),

            settingsScrollView.bottomAnchor.constraint(
                equalTo:
                    settingsPanelView.bottomAnchor
            )
        ])

        settingsScrollView.addSubview(
            settingsContentView
        )

        NSLayoutConstraint.activate([

            settingsContentView.topAnchor.constraint(
                equalTo:
                    settingsScrollView.contentLayoutGuide.topAnchor
            ),

            settingsContentView.leadingAnchor.constraint(
                equalTo:
                    settingsScrollView.contentLayoutGuide.leadingAnchor
            ),

            settingsContentView.trailingAnchor.constraint(
                equalTo:
                    settingsScrollView.contentLayoutGuide.trailingAnchor
            ),

            settingsContentView.bottomAnchor.constraint(
                equalTo:
                    settingsScrollView.contentLayoutGuide.bottomAnchor
            ),

            settingsContentView.widthAnchor.constraint(
                equalTo:
                    settingsScrollView.frameLayoutGuide.widthAnchor
            )
        ])

        // --------------------------------------------------------
        // Title
        // --------------------------------------------------------

        let titleLabel = UILabel()

        titleLabel.text =
            "DISPLAY SETTINGS"

        titleLabel.textColor =
            .white

        titleLabel.font =
            UIFont.systemFont(
                ofSize: 19,
                weight: .bold
            )

        titleLabel.textAlignment =
            .center

        // --------------------------------------------------------
        // Headings
        // --------------------------------------------------------

        let objectsHeading =
            createSettingsHeading(
                "OBJECTS"
            )

        let pathsHeading =
            createSettingsHeading(
                "ORBIT PATHS"
            )

        let labelsHeading =
            createSettingsHeading(
                "LABELS"
            )

        let cometsHeading =
            createSettingsHeading(
                "COMETS"
            )

        let backgroundHeading =
            createSettingsHeading(
                "BACKGROUND"
            )

        let otherHeading =
            createSettingsHeading(
                "OTHER"
            )

        let scaleHeading =
            createSettingsHeading(
                "SCALE / DISPLAY MODE"
            )

        let earthHeading =
            createSettingsHeading(
                "EARTH"
            )

        // --------------------------------------------------------
        // ALL ON / ALL OFF
        // --------------------------------------------------------

        let allOnButton =
            createSettingsActionButton(
                title: "ALL ON",
                action: #selector(allDisplaySettingsOnTapped)
            )

        let allOffButton =
            createSettingsActionButton(
                title: "ALL OFF",
                action: #selector(allDisplaySettingsOffTapped)
            )

        let masterButtonStack =
            UIStackView(
                arrangedSubviews: [
                    allOnButton,
                    allOffButton
                ]
            )

        masterButtonStack.axis =
            .horizontal

        masterButtonStack.spacing =
            10

        masterButtonStack.distribution =
            .fillEqually

        // --------------------------------------------------------
        // Stage 13 display mode controls
        // --------------------------------------------------------

        let displayModeStack =
            UIStackView(
                arrangedSubviews: [
                    compactModeButton,
                    relativeSizesModeButton,
                    astronomicalDistancesModeButton,
                    earthMoonModeButton
                ]
            )

        displayModeStack.axis =
            .vertical

        displayModeStack.spacing =
            8

        displayModeStack.distribution =
            .fillEqually

        // --------------------------------------------------------
        // Done
        // --------------------------------------------------------

        let doneButton =
            createSettingsActionButton(
                title: "DONE",
                action: #selector(closeSettingsTapped)
            )

        doneButton.titleLabel?.font =
            UIFont.systemFont(
                ofSize: 16,
                weight: .bold
            )

        // --------------------------------------------------------
        // Main stack
        // --------------------------------------------------------

        let stack =
            UIStackView(
                arrangedSubviews: [

                    titleLabel,

                    masterButtonStack,

                    objectsHeading,

                    createSettingsRow(
                        title: "Planets",
                        control: planetsSwitch
                    ),

                    createSettingsRow(
                        title: "Moons",
                        control: moonsSwitch
                    ),

                    createSettingsRow(
                        title: "Dwarf Planets",
                        control: dwarfPlanetsSwitch
                    ),

                    pathsHeading,

                    createSettingsRow(
                        title: "Planet Orbits",
                        control: planetOrbitsSwitch
                    ),

                    createSettingsRow(
                        title: "Moon Orbits",
                        control: moonOrbitsSwitch
                    ),

                    createSettingsRow(
                        title: "Dwarf Planet Orbits",
                        control: dwarfPlanetOrbitsSwitch
                    ),

                    labelsHeading,

                    createSettingsRow(
                        title: "Planet Labels",
                        control: planetLabelsSwitch
                    ),

                    createSettingsRow(
                        title: "Moon Labels",
                        control: moonLabelsSwitch
                    ),

                    createSettingsRow(
                        title: "Dwarf Planet Labels",
                        control: dwarfPlanetLabelsSwitch
                    ),

                    cometsHeading,

                    createSettingsRow(
                        title: "Comets",
                        control: cometsSwitch
                    ),

                    createSettingsRow(
                        title: "Comet Tails / Coma",
                        control: cometTailsSwitch
                    ),

                    createSettingsRow(
                        title: "Comet Orbits",
                        control: cometOrbitsSwitch
                    ),

                    createSettingsRow(
                        title: "Comet Labels",
                        control: cometLabelsSwitch
                    ),

                    otherHeading,

                    createSettingsRow(
                        title: "Planetary Rings",
                        control: ringsSwitch
                    ),

                    createSettingsRow(
                        title: "Kuiper Belt",
                        control: kuiperBeltSwitch
                    ),

                    backgroundHeading,

                    createSettingsRow(
                        title: "Stars",
                        control: starsSwitch
                    ),

                    createSettingsRow(
                        title: "Milky Way",
                        control: milkyWaySwitch
                    ),

                    createSettingsRow(
                        title: "Zodiac Constellations",
                        control: zodiacConstellationsSwitch
                    ),

                    scaleHeading,

                    displayModeStack,

                    earthHeading,

                    createSettingsRow(
                        title: "Earth Reference Lines",
                        control: earthReferenceLinesSwitch
                    ),

                    createSettingsRow(
                        title: "Van Allen Belts",
                        control: vanAllenBeltsSwitch
                    ),

                    doneButton
                ]
            )

        stack.axis =
            .vertical

        stack.spacing =
            8

        stack.translatesAutoresizingMaskIntoConstraints =
            false

        settingsContentView.addSubview(
            stack
        )

        NSLayoutConstraint.activate([

            stack.topAnchor.constraint(
                equalTo:
                    settingsContentView.topAnchor,
                constant: 18
            ),

            stack.leadingAnchor.constraint(
                equalTo:
                    settingsContentView.leadingAnchor,
                constant: 20
            ),

            stack.trailingAnchor.constraint(
                equalTo:
                    settingsContentView.trailingAnchor,
                constant: -20
            ),

            stack.bottomAnchor.constraint(
                equalTo:
                    settingsContentView.bottomAnchor,
                constant: -18
            ),

            masterButtonStack.heightAnchor.constraint(
                equalToConstant: 40
            ),

            compactModeButton.heightAnchor.constraint(
                equalToConstant: 42
            ),

            relativeSizesModeButton.heightAnchor.constraint(
                equalToConstant: 42
            ),

            astronomicalDistancesModeButton.heightAnchor.constraint(
                equalToConstant: 42
            ),

            earthMoonModeButton.heightAnchor.constraint(
                equalToConstant: 42
            ),

            doneButton.heightAnchor.constraint(
                equalToConstant: 44
            )
        ])

        updateDisplayModeButtons()
    }

    // ============================================================
    // MARK: - DISPLAY SWITCH CREATION
    // ============================================================

    private func createDisplaySwitch(
        setting: DisplaySetting
    ) -> DisplayToggleButton {

        let displaySwitch =
            DisplayToggleButton(
                frame: .zero
            )

        displaySwitch.setOn(
            savedDisplaySetting(setting),
            animated: false
        )

        displaySwitch.tag =
            setting.rawValue

        displaySwitch.addTarget(
            self,
            action: #selector(displaySettingChanged(_:)),
            for: .touchUpInside
        )

        return displaySwitch
    }

    // ============================================================
    // MARK: - DISPLAY MODE BUTTON CREATION
    // ============================================================

    private func createDisplayModeButton(
        title: String,
        action: Selector
    ) -> UIButton {

        let button =
            UIButton(
                type: .system
            )

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
                ofSize: 15,
                weight: .semibold
            )

        button.backgroundColor =
            UIColor.white.withAlphaComponent(0.10)

        button.layer.cornerRadius =
            8

        button.layer.borderWidth =
            1

        button.layer.borderColor =
            UIColor.white
                .withAlphaComponent(0.20)
                .cgColor

        button.addTarget(
            self,
            action: action,
            for: .touchUpInside
        )

        return button
    }

    // ============================================================
    // MARK: - SETTINGS ROW
    // ============================================================

    private func createSettingsRow(
        title: String,
        control: UIView
    ) -> UIView {

        let label = UILabel()

        label.text =
            title

        label.textColor =
            .white

        label.font =
            UIFont.systemFont(
                ofSize: 16,
                weight: .regular
            )

        let row =
            UIStackView(
                arrangedSubviews: [
                    label,
                    control
                ]
            )

        row.axis =
            .horizontal

        row.alignment =
            .center

        row.distribution =
            .equalSpacing

        row.translatesAutoresizingMaskIntoConstraints =
            false

        let container =
            UIView()

        container.backgroundColor =
            UIColor.white.withAlphaComponent(0.06)

        container.layer.cornerRadius =
            8

        container.translatesAutoresizingMaskIntoConstraints =
            false

        container.addSubview(
            row
        )

        NSLayoutConstraint.activate([

            container.heightAnchor.constraint(
                equalToConstant: 44
            ),

            row.leadingAnchor.constraint(
                equalTo:
                    container.leadingAnchor,
                constant: 12
            ),

            row.trailingAnchor.constraint(
                equalTo:
                    container.trailingAnchor,
                constant: -12
            ),

            row.centerYAnchor.constraint(
                equalTo:
                    container.centerYAnchor
            )
        ])

        return container
    }

    // ============================================================
    // MARK: - SETTINGS HEADING
    // ============================================================

    private func createSettingsHeading(
        _ title: String
    ) -> UILabel {

        let label =
            UILabel()

        label.text =
            title

        label.textColor =
            UIColor.white.withAlphaComponent(0.60)

        label.font =
            UIFont.systemFont(
                ofSize: 12,
                weight: .bold
            )

        label.textAlignment =
            .left

        return label
    }

    // ============================================================
    // MARK: - SETTINGS ACTION BUTTON
    // ============================================================

    private func createSettingsActionButton(
        title: String,
        action: Selector
    ) -> UIButton {

        let button =
            UIButton(
                type: .system
            )

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
                ofSize: 14,
                weight: .semibold
            )

        button.backgroundColor =
            UIColor.white.withAlphaComponent(0.12)

        button.layer.cornerRadius =
            8

        button.addTarget(
            self,
            action: action,
            for: .touchUpInside
        )

        return button
    }

    // ============================================================
    // MARK: - DISPLAY SETTINGS ACTIONS
    // ============================================================

    @objc private func closeSettingsTapped() {

        isHidden =
            true
    }

    @objc private func displaySettingChanged(
        _ sender: DisplayToggleButton
    ) {

        guard let setting =
                DisplaySetting(
                    rawValue: sender.tag
                )
        else {
            return
        }

        sender.setOn(
            !sender.isOn,
            animated: true
        )

        saveDisplaySetting(
            setting,
            value: sender.isOn
        )

        onSettingChanged?(
            setting,
            sender.isOn
        )
    }

    @objc private func allDisplaySettingsOnTapped() {

        setAllDisplaySwitches(
            true
        )

        saveAllDisplaySettings()

        notifyCurrentSettings()
    }

    @objc private func allDisplaySettingsOffTapped() {

        setAllDisplaySwitches(
            false
        )

        saveAllDisplaySettings()

        notifyCurrentSettings()
    }

    private func setAllDisplaySwitches(
        _ enabled: Bool
    ) {

        planetsSwitch.setOn(
            enabled,
            animated: true
        )

        moonsSwitch.setOn(
            enabled,
            animated: true
        )

        dwarfPlanetsSwitch.setOn(
            enabled,
            animated: true
        )

        planetOrbitsSwitch.setOn(
            enabled,
            animated: true
        )

        moonOrbitsSwitch.setOn(
            enabled,
            animated: true
        )

        dwarfPlanetOrbitsSwitch.setOn(
            enabled,
            animated: true
        )

        planetLabelsSwitch.setOn(
            enabled,
            animated: true
        )

        moonLabelsSwitch.setOn(
            enabled,
            animated: true
        )

        dwarfPlanetLabelsSwitch.setOn(
            enabled,
            animated: true
        )

        ringsSwitch.setOn(
            enabled,
            animated: true
        )

        kuiperBeltSwitch.setOn(
            enabled,
            animated: true
        )

        cometsSwitch.setOn(
            enabled,
            animated: true
        )

        cometTailsSwitch.setOn(
            enabled,
            animated: true
        )

        cometOrbitsSwitch.setOn(
            enabled,
            animated: true
        )

        cometLabelsSwitch.setOn(
            enabled,
            animated: true
        )

        starsSwitch.setOn(
            enabled,
            animated: true
        )

        milkyWaySwitch.setOn(
            enabled,
            animated: true
        )

        zodiacConstellationsSwitch.setOn(
            enabled,
            animated: true
        )

        earthReferenceLinesSwitch.setOn(
            enabled,
            animated: true
        )

        vanAllenBeltsSwitch.setOn(
            enabled,
            animated: true
        )
    }

    // ============================================================
    // MARK: - DISPLAY MODE ACTIONS
    // ============================================================

    @objc private func compactModeTapped() {

        selectDisplayMode(
            .compact
        )
    }

    @objc private func relativeSizesModeTapped() {

        selectDisplayMode(
            .relativeSizes
        )
    }

    @objc private func astronomicalDistancesModeTapped() {

        selectDisplayMode(
            .astronomicalDistances
        )
    }

    @objc private func earthMoonModeTapped() {

        selectDisplayMode(
            .earthMoon
        )
    }

    private func selectDisplayMode(
        _ mode: SolarSystemDisplayMode
    ) {

        guard selectedDisplayMode != mode else {
            return
        }

        selectedDisplayMode =
            mode

        updateDisplayModeButtons()

        onDisplayModeChanged?(
            mode
        )
    }

    private func updateDisplayModeButtons() {

        let mode =
            selectedDisplayMode

        updateDisplayModeButton(
            compactModeButton,
            selected: mode == .compact
        )

        updateDisplayModeButton(
            relativeSizesModeButton,
            selected: mode == .relativeSizes
        )

        updateDisplayModeButton(
            astronomicalDistancesModeButton,
            selected: mode == .astronomicalDistances
        )

        updateDisplayModeButton(
            earthMoonModeButton,
            selected: mode == .earthMoon
        )
    }

    private func updateDisplayModeButton(
        _ button: UIButton,
        selected: Bool
    ) {

        if selected {

            button.backgroundColor =
                UIColor.systemBlue.withAlphaComponent(0.75)

            button.layer.borderColor =
                UIColor.systemBlue.cgColor

        } else {

            button.backgroundColor =
                UIColor.white.withAlphaComponent(0.10)

            button.layer.borderColor =
                UIColor.white.withAlphaComponent(0.20).cgColor
        }
    }

    // ============================================================
    // MARK: - CURRENT DISPLAY MODE
    // ============================================================

    func currentDisplayMode() -> SolarSystemDisplayMode {

        return selectedDisplayMode
    }

    // ============================================================
    // MARK: - DISPLAY SETTINGS CALLBACK
    // ============================================================

    func notifyCurrentSettings() {

        for setting in DisplaySetting.allCases {

            let displaySwitch =
                displaySwitch(
                    for: setting
                )

            onSettingChanged?(
                setting,
                displaySwitch.isOn
            )
        }
    }
}


// ============================================================
// MARK: - NSLayoutConstraint PRIORITY
// ============================================================

private extension NSLayoutConstraint {

    func withPriority(
        _ priority: UILayoutPriority
    ) -> NSLayoutConstraint {

        self.priority =
            priority

        return self
    }
}

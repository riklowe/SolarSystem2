//
//  ZodiacConstellations.swift
//  SolarSystem2
//
//  Traditional zodiac line figures adapted from d3-celestial.
//  Coordinates: equatorial right ascension and declination, in degrees.
//  Source: https://github.com/ofrohn/d3-celestial/blob/master/data/constellations.lines.json
//  Fixed sky reference; not aligned to the user's geographic location or compass.
//  The surrounding procedural sky remains illustrative.
//
/*
Copyright (c) 2015, Olaf Frohn
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import CoreGraphics
import CoreText
import simd

enum ZodiacConstellations {

    struct SkyPoint: Hashable {
        let rightAscension: Double
        let declination: Double

        init(_ rightAscension: Double, _ declination: Double) {
            self.rightAscension = rightAscension
            self.declination = declination
        }

        var direction: SIMD3<Double> {
            let ra = rightAscension * Double.pi / 180
            let dec = declination * Double.pi / 180
            return SIMD3<Double>(cos(dec) * cos(ra), sin(dec), cos(dec) * sin(ra))
        }
    }

    struct Constellation {
        let name: String
        let paths: [[SkyPoint]]
        let label: SkyPoint
    }

    // ============================================================
    // MARK: - CONSTELLATION DATA
    // ============================================================

    static let constellations: [Constellation] = [
        Constellation(
            name: "Aries",
            paths: [
                [SkyPoint(42.496, 27.2605), SkyPoint(31.7934, 23.4624), SkyPoint(28.66, 20.808), SkyPoint(28.3826, 19.2939)]
            ],
            label: SkyPoint(32.8236, 15.2939)
        ),
        Constellation(
            name: "Taurus",
            paths: [
                [SkyPoint(84.4112, 21.1425), SkyPoint(68.9802, 16.5093), SkyPoint(67.1656, 15.8709), SkyPoint(64.9483, 15.6276), SkyPoint(65.7337, 17.5425), SkyPoint(67.1542, 19.1804), SkyPoint(81.573, 28.6075)],
                [SkyPoint(64.9483, 15.6276), SkyPoint(60.1701, 12.4903), SkyPoint(51.7923, 9.7327), SkyPoint(60.7891, 5.9893)],
                [SkyPoint(51.7923, 9.7327), SkyPoint(51.2033, 9.0289), SkyPoint(54.2183, 0.4017)]
            ],
            label: SkyPoint(64.8188, -3.5983)
        ),
        Constellation(
            name: "Gemini",
            paths: [
                [SkyPoint(93.7194, 22.5068), SkyPoint(95.7401, 22.5136), SkyPoint(100.983, 25.1311), SkyPoint(107.7849, 30.2452), SkyPoint(113.6494, 31.8883), SkyPoint(116.329, 28.0262), SkyPoint(113.9806, 26.8957), SkyPoint(110.0307, 21.9823), SkyPoint(106.0272, 20.5703), SkyPoint(99.4279, 16.3993), SkyPoint(101.3224, 12.8956)],
                [SkyPoint(110.0307, 21.9823), SkyPoint(109.5232, 16.5404)]
            ],
            label: SkyPoint(105.7130, 8.8956)
        ),
        Constellation(
            name: "Cancer",
            paths: [
                [SkyPoint(134.6218, 11.8577), SkyPoint(131.1712, 18.1543), SkyPoint(130.8214, 21.4685), SkyPoint(131.6666, 28.7651)],
                [SkyPoint(131.1712, 18.1543), SkyPoint(124.1288, 9.1855)]
            ],
            label: SkyPoint(130.4838, 5.1855)
        ),
        Constellation(
            name: "Leo",
            paths: [
                [SkyPoint(152.093, 11.9672), SkyPoint(151.8331, 16.7627), SkyPoint(154.9931, 19.8415), SkyPoint(168.5271, 20.5237), SkyPoint(177.2649, 14.5721), SkyPoint(168.56, 15.4296), SkyPoint(152.093, 11.9672)],
                [SkyPoint(154.9931, 19.8415), SkyPoint(154.1726, 23.4173), SkyPoint(148.1909, 26.007), SkyPoint(146.4628, 23.7743)]
            ],
            label: SkyPoint(157.9740, 7.9672)
        ),
        Constellation(
            name: "Virgo",
            paths: [
                [SkyPoint(176.4648, 6.5294), SkyPoint(177.6738, 1.7647), SkyPoint(-175.0235, -0.6668), SkyPoint(-169.5848, -1.4494), SkyPoint(-162.5125, -5.539), SkyPoint(-158.7018, -11.1613), SkyPoint(-145.9964, -6.0005), SkyPoint(-139.2349, -5.6582)],
                [SkyPoint(-164.4558, 10.9592), SkyPoint(-166.0991, 3.3975), SkyPoint(-169.5848, -1.4494)],
                [SkyPoint(-162.5125, -5.539), SkyPoint(-156.3267, -0.5958), SkyPoint(-149.5884, 1.5445), SkyPoint(-138.4378, 1.8929)]
            ],
            label: SkyPoint(-160.9149, -15.1613)
        ),
        Constellation(
            name: "Libra",
            paths: [
                [SkyPoint(-133.9824, -25.282), SkyPoint(-137.2804, -16.0418), SkyPoint(-130.7483, -9.3829), SkyPoint(-126.1184, -14.7895), SkyPoint(-125.744, -28.1351), SkyPoint(-125.336, -29.7778)],
                [SkyPoint(-137.2804, -16.0418), SkyPoint(-126.1184, -14.7895)]
            ],
            label: SkyPoint(-129.8660, -33.7778)
        ),
        Constellation(
            name: "Scorpius",
            paths: [
                [SkyPoint(-120.287, -26.1141), SkyPoint(-119.9166, -22.6217), SkyPoint(-118.6407, -19.8055)],
                [SkyPoint(-119.9166, -22.6217), SkyPoint(-114.7028, -25.5928), SkyPoint(-112.6481, -26.432), SkyPoint(-111.0294, -28.216), SkyPoint(-107.4591, -34.2932), SkyPoint(-107.0324, -38.0474), SkyPoint(-106.3541, -42.3613), SkyPoint(-101.9617, -43.2392), SkyPoint(-95.6703, -42.9978), SkyPoint(-93.1038, -40.127), SkyPoint(-94.378, -39.03), SkyPoint(-96.5978, -37.1038)]
            ],
            label: SkyPoint(-107.1312, -47.2392)
        ),
        Constellation(
            name: "Sagittarius",
            paths: [
                [SkyPoint(-85.5932, -36.7617), SkyPoint(-83.957, -34.3846), SkyPoint(-84.7515, -29.8281), SkyPoint(-83.0073, -25.4217), SkyPoint(-86.5591, -21.0588)],
                [SkyPoint(-69.3404, -44.459), SkyPoint(-69.0284, -40.6159), SkyPoint(-74.347, -29.8801), SkyPoint(-78.5859, -26.9908), SkyPoint(-83.0073, -25.4217)],
                [SkyPoint(-61.1846, -41.8683), SkyPoint(-60.0659, -35.2763), SkyPoint(-61.0402, -26.2995), SkyPoint(-65.8232, -24.8836), SkyPoint(-68.6813, -24.5086), SkyPoint(-71.1149, -25.2567), SkyPoint(-76.1836, -26.2967), SkyPoint(-78.5859, -26.9908), SkyPoint(-84.7515, -29.8281), SkyPoint(-88.548, -30.4241), SkyPoint(-83.957, -34.3846), SkyPoint(-74.347, -29.8801), SkyPoint(-73.265, -27.6704), SkyPoint(-76.1836, -26.2967), SkyPoint(-73.8292, -21.7415), SkyPoint(-72.559, -21.0236), SkyPoint(-70.5913, -18.9529), SkyPoint(-69.5818, -17.8472), SkyPoint(-69.5682, -15.955)],
                [SkyPoint(-73.8292, -21.7415), SkyPoint(-75.5675, -21.1067), SkyPoint(-76.4576, -22.7448), SkyPoint(-76.1836, -26.2967)]
            ],
            label: SkyPoint(-73.9658, -48.4590)
        ),
        Constellation(
            name: "Capricornus",
            paths: [
                [SkyPoint(-55.588, -12.5082), SkyPoint(-54.7472, -14.7814), SkyPoint(-52.7849, -17.8137), SkyPoint(-48.4761, -25.2709), SkyPoint(-47.0446, -26.9191), SkyPoint(-38.3332, -22.4113), SkyPoint(-33.2398, -16.1273), SkyPoint(-34.9773, -16.6623), SkyPoint(-39.4383, -16.8345), SkyPoint(-43.5132, -17.2329), SkyPoint(-55.588, -12.5082)]
            ],
            label: SkyPoint(-44.8149, -30.9191)
        ),
        Constellation(
            name: "Aquarius",
            paths: [
                [SkyPoint(-48.081, -9.4958), SkyPoint(-46.8365, -8.9833), SkyPoint(-37.1103, -5.5712), SkyPoint(-28.554, -0.3199), SkyPoint(-24.5859, -1.3873), SkyPoint(-22.792, -0.02), SkyPoint(-21.1609, -0.1175), SkyPoint(-16.8464, -7.5796), SkyPoint(-10.5241, -9.1825), SkyPoint(-12.6383, -21.1724)],
                [SkyPoint(-37.1103, -5.5712), SkyPoint(-28.3907, -13.8697)],
                [SkyPoint(-28.554, -0.3199), SkyPoint(-25.7915, -7.7833)],
                [SkyPoint(-22.792, -0.02), SkyPoint(-23.6807, 1.3774)],
                [SkyPoint(-9.2574, -20.1006), SkyPoint(-10.5241, -9.1825), SkyPoint(-4.5591, -17.8165)]
            ],
            label: SkyPoint(-24.0091, -25.1724)
        ),
        Constellation(
            name: "Pisces",
            paths: [
                [SkyPoint(18.4373, 24.5837), SkyPoint(17.9152, 30.0896), SkyPoint(19.8666, 27.2641), SkyPoint(18.4373, 24.5837), SkyPoint(17.8634, 21.0347), SkyPoint(22.8709, 15.3458), SkyPoint(26.3485, 9.1577), SkyPoint(30.5118, 2.7638), SkyPoint(28.389, 3.1875), SkyPoint(25.3579, 5.4876), SkyPoint(22.5463, 6.1438), SkyPoint(18.4329, 7.5754), SkyPoint(15.7359, 7.8901), SkyPoint(12.1706, 7.5851), SkyPoint(-0.1721, 6.8633), SkyPoint(-5.0123, 5.6263), SkyPoint(-8.0079, 6.379), SkyPoint(-9.9142, 5.3813), SkyPoint(-10.7086, 3.2823), SkyPoint(-8.2669, 1.2556), SkyPoint(-4.4883, 1.78), SkyPoint(-3.402, 3.4868), SkyPoint(-5.0123, 5.6263)],
                [SkyPoint(-10.7086, 3.2823), SkyPoint(-14.0308, 3.82)]
            ],
            label: SkyPoint(9.6974, -2.7444)
        )
    ]

    // ============================================================
    // MARK: - PANORAMA DRAWING
    // ============================================================

    static func draw(in context: CGContext, width: Int, height: Int) {

        context.saveGState()
        defer { context.restoreGState() }

        context.setLineWidth(0.8)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setStrokeColor(CGColor(red: 0.42, green: 0.68, blue: 0.90, alpha: 0.62))

        for constellation in constellations {
            for path in constellation.paths {
                for index in 1..<path.count {
                    drawSegment(
                        from: path[index - 1],
                        to: path[index],
                        in: context,
                        width: width,
                        height: height
                    )
                }
            }
        }

        // Draw each real reference star once, even where paths meet.
        let points = Set(constellations.flatMap { $0.paths.flatMap { $0 } })
        for point in points {
            let centre = project(point.direction, width: width, height: height)
            let radiusY = 1.45
            let radiusX = radiusY / max(0.1, cos(point.declination * Double.pi / 180))

            for offset in [-Double(width), 0, Double(width)] {
                context.setFillColor(CGColor(red: 0.82, green: 0.91, blue: 1, alpha: 0.95))
                context.fillEllipse(in: CGRect(
                    x: centre.x + offset - radiusX,
                    y: centre.y - radiusY,
                    width: radiusX * 2,
                    height: radiusY * 2
                ))
            }
        }

        for constellation in constellations {
            drawName(constellation, in: context, width: width, height: height)
        }
    }

    private static func project(
        _ direction: SIMD3<Double>,
        width: Int,
        height: Int
    ) -> CGPoint {

        // RA runs right-to-left in a north-up view of the celestial sphere.
        let ra = atan2(direction.z, direction.x)
        var u = -ra / (2 * Double.pi)
        u -= floor(u)
        let dec = asin(max(-1, min(1, direction.y)))

        return CGPoint(
            x: u * Double(width),
            y: (dec / Double.pi + 0.5) * Double(height)
        )
    }

    private static func drawSegment(
        from start: SkyPoint,
        to end: SkyPoint,
        in context: CGContext,
        width: Int,
        height: Int
    ) {

        let a = start.direction
        let b = end.direction
        var previous = project(a, width: width, height: height)

        // Interpolate the short great-circle arc, then unwrap across RA = 0.
        // Pisces crosses the panorama seam and must not acquire a full-sky line.
        for index in 1...24 {
            let t = Double(index) / 24
            let direction = simd_normalize(a * (1 - t) + b * t)
            var next = project(direction, width: width, height: height)

            while next.x - previous.x > Double(width) / 2 { next.x -= Double(width) }
            while next.x - previous.x < -Double(width) / 2 { next.x += Double(width) }

            for offset in [-Double(width), 0, Double(width)] {
                context.move(to: CGPoint(x: previous.x + offset, y: previous.y))
                context.addLine(to: CGPoint(x: next.x + offset, y: next.y))
                context.strokePath()
            }

            previous = next
        }
    }

    private static func drawName(
        _ constellation: Constellation,
        in context: CGContext,
        width: Int,
        height: Int
    ) {

        let font = CTFontCreateWithName("HelveticaNeue-Medium" as CFString, 12, nil)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String):
                CGColor(red: 0.72, green: 0.84, blue: 1, alpha: 0.95)
        ]
        let text = NSAttributedString(string: constellation.name, attributes: attributes)
        let line = CTLineCreateWithAttributedString(text)
        let textWidth = CTLineGetTypographicBounds(line, nil, nil, nil)
        let centre = project(constellation.label.direction, width: width, height: height)
        let horizontalScale = 1 / max(0.1, cos(constellation.label.declination * Double.pi / 180))

        for offset in [-Double(width), 0, Double(width)] {
            context.saveGState()
            context.translateBy(x: centre.x + offset, y: centre.y)
            context.scaleBy(x: horizontalScale, y: 1)
            context.textMatrix = .identity
            context.textPosition = CGPoint(x: -textWidth / 2, y: -4)
            context.setShadow(offset: .zero, blur: 3, color: CGColor(gray: 0, alpha: 1))
            CTLineDraw(line, context)
            context.restoreGState()
        }
    }
}

//
//  File.swift
//  Utilities
//
//  Created by Никита Арабчик on 23.07.2025.
//

import UIKit
import Foundation

public final class PieChartView: UIView {
    
    private static var colors: [UIColor] = [
        UIColor(ciColor: .green),
        UIColor(ciColor: .yellow),
        UIColor(ciColor: .blue),
        UIColor(ciColor: .cyan),
        UIColor(ciColor: .magenta),
        UIColor(ciColor: .red),
    ]
    
    public var entities: [Entity] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let ringWidth: CGFloat = 5.0
    private let innerRadiusRatio: CGFloat = 0.9
    private let chartSizeRatio: CGFloat = 0.9
    private var currentRotationAngle: CGFloat = 0
    private var isAnimating = false
    private var newEntities: [Entity] = []
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var animationDuration: CFTimeInterval = 1.5
    private var currentAnimationProgress: CGFloat = 0
    private var isFirstHalfCompleted = false
    
    
    public func animateToNewData(_ entities: [Entity], duration: TimeInterval = 1.0) {
        guard !isAnimating else { return }
        isAnimating = true
        newEntities = entities
        animationDuration = duration
        currentAnimationProgress = 0
        isFirstHalfCompleted = false
        
        animationStartTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateAnimation() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        currentAnimationProgress = CGFloat(elapsed / animationDuration)
        
        if currentAnimationProgress >= 1.0 {
            finishAnimation()
            return
        }
        
        if !isFirstHalfCompleted && currentAnimationProgress >= 0.5 {
            isFirstHalfCompleted = true
            entities = newEntities
        }
        
        let rotationProgress = currentAnimationProgress
        currentRotationAngle = (rotationProgress * 2 * .pi)
        
        if rotationProgress <= 0.5 {
            alpha = 1 - (rotationProgress * 2)
        } else {
            alpha = (rotationProgress - 0.5) * 2
        }
        
        setNeedsDisplay()
    }
    
    private func finishAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        currentRotationAngle = 0
        alpha = 1
        isAnimating = false
        setNeedsDisplay()
    }
    
    override public func draw(_ rect: CGRect) {
        guard !entities.isEmpty else { return }
        
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        context.translateBy(x: bounds.midX, y: bounds.midY)
        context.rotate(by: currentRotationAngle)
        context.translateBy(x: -bounds.midX, y: -bounds.midY)
        
        var sortedEntities = entities.sorted { $0.value > $1.value }
        
        if sortedEntities.count > 5 {
            sortedEntities[5] = getOtherEntitites(entities: Array(sortedEntities.dropFirst(5)))
            sortedEntities = Array(sortedEntities[...5])
        }
        
        let totalValue = entities.reduce(Decimal(0)) { $0 + $1.value }
        guard totalValue > 0 else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) * 0.4
        let innerRadius = outerRadius * innerRadiusRatio
        
        let segments = prepareSegments(allEntities: sortedEntities, totalValue: totalValue)
        
        var startAngle: CGFloat = -.pi / 2
        for (index, segment) in segments.enumerated() {
            let color = PieChartView.colors[index % PieChartView.colors.count]
            drawRingSegment(startAngle: startAngle,
                            endAngle: startAngle + segment.angle,
                            color: color,
                            center: center,
                            outerRadius: outerRadius,
                            innerRadius: innerRadius)
            
            startAngle += segment.angle
        }
        
        drawCenterText(entities: sortedEntities, totalValue: totalValue)
        
        context.restoreGState()
    }
    
    private func getOtherEntitites(entities: [Entity]) -> Entity {
        let sum = entities.reduce(Decimal(0)) {$0 + $1.value}
        return Entity(value: sum, label: "Остальные")
    }
    
    private func prepareSegments(allEntities: [Entity], totalValue: Decimal) -> [(angle: CGFloat, label: String, percentage: String)] {
        return allEntities.map { entity in
            let angle = (NSDecimalNumber(decimal: entity.value / totalValue).doubleValue * 2 * .pi)
            let percentage = String(format: "%.1f%%", (NSDecimalNumber(decimal: entity.value / totalValue).doubleValue * 100))
            return (angle: angle, label: entity.label, percentage: percentage)
        }
    }
    
    private func drawRingSegment(startAngle: CGFloat,
                                 endAngle: CGFloat,
                                 color: UIColor,
                                 center: CGPoint,
                                 outerRadius: CGFloat,
                                 innerRadius: CGFloat) {
        let path = UIBezierPath()
        
        path.addArc(withCenter: center,
                    radius: outerRadius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: true)
        
        path.addArc(withCenter: center,
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: false)
        
        path.close()
        
        color.setFill()
        path.fill()
        
        
        UIColor.white.setStroke()
        path.lineWidth = 0.5
        path.stroke()
    }
    
    
    private func drawCenterText(entities: [Entity], totalValue: Decimal) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let text = NSMutableAttributedString()
        
        let categoryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7, weight: .medium),
            .foregroundColor: UIColor.label,
            .paragraphStyle: centeredParagraphStyle()
        ]
        
        for (index, entity) in entities.enumerated() {
            let color = PieChartView.colors[index % PieChartView.colors.count]
            let percentage = (entity.value / totalValue * 100).formatted(.number.precision(.fractionLength(1))) + "%"
            
            let circleSize = CGSize(width: 7, height: 7)
            let circleImage = createCircleImage(color: color, size: circleSize)
            
            let attachment = NSTextAttachment()
            attachment.image = circleImage
            attachment.bounds = CGRect(x: 0, y: -2, width: circleSize.width, height: circleSize.height)
            
            let categoryString = NSMutableAttributedString()
            categoryString.append(NSAttributedString(attachment: attachment))
            categoryString.append(NSAttributedString(string: " \(percentage) \(entity.label)\n", attributes: categoryAttributes))
            
            text.append(categoryString)
        }
        
        let textSize = text.size()
        let textRect = CGRect(
            x: center.x - textSize.width/2,
            y: center.y - textSize.height/2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect)
    }
    
    private func createCircleImage(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
            circlePath.fill()
        }
    }
    
    private func centeredParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        return paragraphStyle
    }
}


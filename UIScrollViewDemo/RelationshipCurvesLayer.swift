//
//  RelationshipCurvesLayer.swift
//  UIScrollViewDemo
//
//  Created by Simon Gladman on 30/09/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit

class RelationshipCurvesLayer: CAShapeLayer
{
    var relationshipCurvesPath = UIBezierPath()
    
    let controlPointVerticalOffset = CGFloat(100)
    

    final func redrawRelationshipCurves()
    {
        strokeColor = NodeConstants.curveColor.CGColor
        lineWidth = 2
        fillColor = nil
        
        shadowOffset = CGSize(width: 0, height: 0)
        shadowColor = UIColor.blackColor().CGColor
        shadowOpacity = 0.5
        shadowRadius = 2
        
        drawsAsynchronously = true

        relationshipCurvesPath.removeAllPoints()
        
        for targetNode in NodesPM.nodes
        {
            let rect = CGRect(x: CGFloat(targetNode.position.x + 1), y: CGFloat(targetNode.position.y + 1), width: NodeConstants.WidgetWidthCGFloat - 2, height: NodeConstants.WidgetHeightCGFloat - 2)
            let rectPath = UIBezierPath(roundedRect: rect, cornerRadius: 10)
            
            relationshipCurvesPath.appendPath(rectPath)
            
            for idx in 0 ..< targetNode.getInputCount()
            {
                let targetX = targetNode.position.x + CGFloat((NodeConstants.WidgetWidthInt / (targetNode.getInputCount() + 1)) * (idx + 1))
                let targetPosition = CGPoint(x: targetX, y: targetNode.position.y)
                drawSemiCircle(relationshipCurvesPath: relationshipCurvesPath, position: targetPosition, clockwise: false)
            }
            
            for (idx : Int, candidateNode: NodeVO?) in enumerate(targetNode.inputNodes)
            {
                if let inputNode = candidateNode
                {
                    let inputPosition = CGPoint(x: inputNode.position.x + NodeConstants.WidgetWidthCGFloat / 2, y: inputNode.position.y + NodeConstants.WidgetHeightCGFloat)
                    let targetX = targetNode.position.x + CGFloat((NodeConstants.WidgetWidthInt / (targetNode.getInputCount() + 1)) * (idx + 1))
                    let targetPosition = CGPoint(x: targetX, y: targetNode.position.y)
                    let controlPointOne = CGPoint(x: targetX, y: targetNode.position.y - controlPointVerticalOffset)
                    let controlPointTwo = CGPoint(x: inputNode.position.x + NodeConstants.WidgetWidthCGFloat / 2, y: inputNode.position.y + NodeConstants.WidgetHeightCGFloat + controlPointVerticalOffset)

                    drawSemiCircle(relationshipCurvesPath: relationshipCurvesPath, position: inputPosition, clockwise: true)
                    
                    relationshipCurvesPath.moveToPoint(targetPosition)
                    relationshipCurvesPath.addCurveToPoint(inputPosition, controlPoint1: controlPointOne, controlPoint2: controlPointTwo)
                }
            }
        }
        
        path = relationshipCurvesPath.CGPath
    }

    func drawSemiCircle(#relationshipCurvesPath: UIBezierPath, position: CGPoint, clockwise: Bool)
    {
        let halfCircle = CGFloat(M_PI)
        
        relationshipCurvesPath.moveToPoint(position)
        
        for i in 1...3
        {
            relationshipCurvesPath.addArcWithCenter(position, radius: CGFloat(i * 2), startAngle: 0, endAngle: halfCircle, clockwise: clockwise)
        }
    }
    
    
}
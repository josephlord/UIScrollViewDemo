//
//  NodesPM.swift
//  UIScrollViewDemo
//
//  Created by Simon Gladman on 29/09/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKIt

struct NodesPM
{
    static var nodes = [NodeVO]()
    static let instance = NodesPM()
    
    static let timerTarget = TimerTarget()
    
    private static let notificationCentre = NSNotificationCenter.defaultCenter()
    
    static var selectedNode: NodeVO? = nil
    {
        willSet
        {
            if relationshipCreationMode
            {
                if let targetNode = newValue
                {
                    if let inputNode = selectedNode
                    {
                        if preferredInputIndex == -1 || preferredInputIndex > targetNode.inputNodes.count - 1 || targetNode.inputNodes.count < 2
                        {
                            targetNode.inputNodes.append(inputNode)
                        }
                        else
                        {
                            targetNode.inputNodes[preferredInputIndex] = inputNode
                        }
        
                        nodeUpdated(targetNode)
                        postNotification(.RelationshipsChanged, payload: nil)
                    }
                }
            }
            preferredInputIndex = -1
        }
        didSet
        {
            postNotification(.NodeSelected, payload: selectedNode)
            
            relationshipCreationMode = false
        }
    }

    static var preferredInputIndex: Int = -1
    
    static func changeSelectedNodeOperator(newOperator: NodeOperators)
    {
        if let node = selectedNode
        {
            node.nodeOperator = newOperator
    
            nodeUpdated(node)
        }
    }
    
    static func changeSelectedNodeType(newType: NodeTypes)
    {
        if let node = selectedNode
        {
            node.nodeType = newType
            
            if node.nodeType == NodeTypes.Operator && node.nodeOperator == NodeOperators.Null
            {
                node.nodeOperator = NodeOperators.Add
            }
            else if node.nodeType == NodeTypes.Number
            {
                node.nodeOperator = NodeOperators.Null
                
                if node.inputNodes.count > 0
                {
                    node.inputNodes = [NodeVO]()
                
                    postNotification(.RelationshipsChanged, payload: nil)
                }
            }
            
            nodeUpdated(node)
        }
    }
    
    static func changeSelectedNodeValue(newValue: Double)
    {
        if let node = selectedNode
        {
            node.value = newValue
            
            nodeUpdated(node)
        }
    }
    
    static func nodeUpdated(node: NodeVO)
    {
        node.updateValue()
        postNotification(.NodeUpdated, payload: node)
        
        // find all operator nodes that are descendants of this node and update their value...
        
        for candidateNode in nodes
        {
            var timeInterval = 0.1
            
            for inputNode in candidateNode.inputNodes
            {
                if inputNode == node && candidateNode.nodeType == NodeTypes.Operator
                {
                    //nodeUpdated(candidateNode)
                    
                    var dictionary = NSMutableDictionary()
                    dictionary.setValue(candidateNode, forKeyPath: "node")
                    
                    var timer = NSTimer(timeInterval: timeInterval, target: NodesPM.timerTarget, selector: "timerComplete:", userInfo: dictionary, repeats: false)
                    
                    timer.tolerance = 0.2
                    timeInterval = timeInterval + 0.1
                    
                    timer.fire()
                    
                    // let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: NodesPM.timerTarget, selector: "timerComplete:", userInfo: dictionary, repeats: false)
                }
            }
        }
    }
 
    static var isDragging: Bool = false
    {
        didSet
        {
            postNotification(.DraggingChanged, payload: isDragging)
        }
    }
    
    static var relationshipCreationMode: Bool = false
    {
        didSet
        {
            if oldValue != relationshipCreationMode
            {
                postNotification(.RelationshipCreationModeChanged, payload: relationshipCreationMode)
            }
        }
    }
    
    static func removeObserver(observer: AnyObject)
    {
        notificationCentre.removeObserver(observer)
    }
    
    static func addObserver(observer: AnyObject, selector: Selector, notificationType: NodeNotificationTypes)
    {
        notificationCentre.addObserver(observer, selector: selector, name: notificationType.toRaw(), object: nil)
    }
    
    static func deleteSelectedNode()
    {
        for node in nodes
        {
            node.inputNodes = node.inputNodes.filter({!($0 == NodesPM.selectedNode!)})
        }

        nodes = nodes.filter({!($0 == NodesPM.selectedNode!)})
      
        postNotification(.NodeDeleted, payload: selectedNode)
        postNotification(.RelationshipsChanged, payload: nil)
        
        selectedNode = nil
    }
    
    static func createNewNode(origin: CGPoint)
    {
        let newNode = NodeVO(name: "\(nodes.count)", position: origin)
        
        nodes.append(newNode)
        
        postNotification(.NodeCreated, payload: newNode)
        
        selectedNode = newNode
    }
    
    static func moveSelectedNode(position: CGPoint)
    {
        selectedNode?.position = position
        
        postNotification(.RelationshipsChanged, payload: nil)
    }
    
    private static func postNotification(notificationType: NodeNotificationTypes, payload: AnyObject?)
    {
        let notification = NSNotification(name: notificationType.toRaw(), object: payload)
        
        notificationCentre.postNotification(notification)
    }
}

class TimerTarget: NSObject
{
    func timerComplete(node: AnyObject)
    {
        let srcTimer: NSTimer = node as NSTimer
        
        let node: NodeVO = srcTimer.userInfo?.valueForKey("node") as NodeVO
        
        NodesPM.nodeUpdated(node)
    }
}

struct NodeConstants
{
    static let WidgetWidthInt: Int = 240
    static let WidgetHeightInt: Int = 80
    
    static let WidgetWidthCGFloat = CGFloat(WidgetWidthInt)
    static let WidgetHeightCGFloat = CGFloat(WidgetHeightInt)
    
    static let backgroundColor = UIColor.lightGrayColor()
    static let curveColor = UIColor.blueColor()
    
    static let selectedNodeColor = UIColor.blueColor()
    static let unselectedNodeColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 0.9)
    
    static let animationDuration = 0.25
}

enum NodeNotificationTypes: String
{
    case NodeSelected = "nodeSelected"
    case NodeCreated = "nodeCreated"
    case NodeDeleted = "nodeDeleted"
    case DraggingChanged = "draggingChanged"
    case RelationshipCreationModeChanged = "relationshipCreationModeChanged"
    case RelationshipsChanged = "relationshipsChanged"
    case NodeUpdated = "nodeUpdated"
}
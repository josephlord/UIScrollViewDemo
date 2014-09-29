//
//  Node.swift
//  UIScrollViewDemo
//
//  Created by Simon Gladman on 28/09/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class NodeWidget: UIControl
{
    var node: NodeVO!
    let label: UILabel = UILabel(frame: CGRectZero)
    
    required init(frame: CGRect, node: NodeVO)
    {
        super.init(frame: frame)
        
        self.node = node
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview()
    {
        backgroundColor = UIColor.blueColor()
        
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 2
        layer.cornerRadius = 10
        
        label.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height - 10)
        label.numberOfLines = 0
        label.text = "Node: \(node.name)\n\nTotal: \(NodesPM.nodes.count)"
        addSubview(label)
        
        let pan = UIPanGestureRecognizer(target: self, action: "panHandler:");
        addGestureRecognizer(pan)
     
        NodesPM.notificationCentre.addObserver(self, selector: "nodeSelected:", name: NodeNotificationTypes.NodeSelected.toRaw(), object: nil)
        NodesPM.notificationCentre.addObserver(self, selector: "nodeCreated:", name: NodeNotificationTypes.NodeCreated.toRaw(), object: nil)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        NodesPM.selectedNode = node
    }
    
    func nodeCreated(value: AnyObject)
    {
       label.text = "Node: \(node.name)\n\nTotal: \(NodesPM.nodes.count)" 
    }
    
    func nodeSelected(value : AnyObject)
    {
        let selectedNode = value.object as NodeVO
        
        backgroundColor = selectedNode == node ? UIColor.yellowColor() : UIColor.blueColor()
        label.textColor = selectedNode == node ? UIColor.blackColor() : UIColor.whiteColor()
    }
    
    func panHandler(recognizer: UIPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            NodesPM.isDragging = true
        }
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            let gestureLocation = recognizer.locationInView(self)
            
            frame.offset(dx: gestureLocation.x - frame.width / 2, dy: gestureLocation.y - frame.height / 2)
            
            NodesPM.moveSelectedNode(CGPoint(x: frame.origin.x, y: frame.origin.y))
        }
        else if recognizer.state == UIGestureRecognizerState.Ended
        {
            NodesPM.isDragging = false
        }
    }
  
}



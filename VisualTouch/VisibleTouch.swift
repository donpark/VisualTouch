//
//  VisibleTouch.swift
//  Docuverse
//
//  Created by Don Park on 11/12/16.
//  License: MIT
//

import UIKit
import QuartzCore

open class VisibleTouch {
    
    private class Event {
        static let enable = Notification.Name("VisibleTouch.enable")
        static let disable = Notification.Name("VisibleTouch.disable")
    }
    
    static open func enable() {
        NotificationCenter.default.post(name: Event.enable, object: UIScreen.main, userInfo: nil)
    }

    static open func disable() {
        NotificationCenter.default.post(name: Event.disable, object: UIScreen.main, userInfo: nil)
    }
    
    open class Window: UIWindow {
        
        private class TouchLayer: CAShapeLayer {
            let radius: CGFloat = UIScreen.main.scale * 16.0
            let popScale: CGFloat = UIScreen.main.scale * 1.5
            
            func apply(touch: UITouch) {
                self.path = UIBezierPath(ovalIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)).cgPath
                self.strokeColor = UIColor.clear.cgColor
                self.fillColor = UIColor.blue.cgColor
                self.opacity = 0.25
            }
        }
        
        private typealias TouchLayers = [Int:TouchLayer]
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            NotificationCenter.default.addObserver(self, selector: #selector(onNotification(_:)), name: nil, object: UIScreen.main)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: nil, object: UIScreen.main)
        }
        
        private var isTouchVisible: Bool = false
        
        private var touchLayers: TouchLayers = TouchLayers()
        
        func showTouches() {
            self.isTouchVisible = true
        }
        
        func hideTouches() {
            self.isTouchVisible = false
            self.removeAllTouchLayers()
        }
        
        func onNotification(_ notification: Notification) {
            if notification.name == Event.enable {
                self.showTouches()
            } else if notification.name == Event.disable {
                self.hideTouches()
            }
        }
        
        // all touch events should pass here
        override open func sendEvent(_ event: UIEvent) {
            super.sendEvent(event)
            
            guard self.isTouchVisible && event.type == .touches else {
                return
            }
            guard let touches = event.allTouches else {
                return
            }
            
            var newTouchLayers = self.touchLayers
            for touch in touches {
                switch touch.phase {
                case .began:
                    self.addTouchLayerFor(touch: touch, touchLayers: &newTouchLayers)
                case .moved:
                    self.moveTouchLayerFor(touch: touch, touchLayers: &newTouchLayers)
                case .stationary:
                    self.keepTouchLayerFor(touch: touch, touchLayers: &newTouchLayers)
                case .cancelled:
                    fallthrough
                case .ended:
                    self.removeTouchLayerFor(touch: touch, touchLayers: &newTouchLayers)
                }
            }
            self.touchLayers = newTouchLayers
        }
        
        private func addTouchLayerFor(touch: UITouch, touchLayers: inout TouchLayers) {
            let layer = TouchLayer()
            layer.apply(touch: touch)
            layer.position = touch.location(in: self)
            // layer.add(self.touchBeganAnimation(), forKey: "add")
            touchLayers[touch.hash] = layer
            self.insertTouchLayer(layer)
        }
        
        private func removeTouchLayerFor(touch: UITouch, touchLayers: inout TouchLayers) {
            guard let layer = touchLayers.removeValue(forKey: touch.hash) else {
                print("\(#function) touch layer not found")
                return
            }
            self.removeTouchLayer(layer)
        }
        
        private func removeAllTouchLayers() {
            for (_, layer) in touchLayers {
                self.removeTouchLayer(layer)
            }
            self.touchLayers.removeAll()
        }
        
        private func moveTouchLayerFor(touch: UITouch, touchLayers: inout TouchLayers) {
            guard let layer = touchLayers[touch.hash] else {
                return
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.position = touch.location(in: self)
            CATransaction.commit()
        }
        
        private func keepTouchLayerFor(touch: UITouch, touchLayers: inout TouchLayers) {
            // do nothing
        }
        
        private func insertTouchLayer(_ touchLayer: TouchLayer) {
            self.layer.addSublayer(touchLayer)
        }
        
        private func removeTouchLayer(_ touchLayer: TouchLayer) {
            touchLayer.removeFromSuperlayer()
        }
        
        private func touchBeganAnimation() -> CAAnimation {
            let anim =  CABasicAnimation(keyPath: #keyPath(CALayer.contentsScale))
            anim.fromValue = 1.5
            anim.toValue = 1.0
            anim.duration = 5
            anim.beginTime = CACurrentMediaTime() + 1.0
            return anim
        }
    }
}

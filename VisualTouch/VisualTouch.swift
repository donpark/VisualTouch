//
//  VisualTouch.swift
//  Docuverse
//
//  Created by Don Park on 11/12/16.
//  License: MIT
//

import UIKit
import QuartzCore

open class VisualTouch {
    
    private class Event {
        static let enable = Notification.Name("VisualTouch.enable")
        static let disable = Notification.Name("VisualTouch.disable")
    }
    
    static open func enable() {
        NotificationCenter.default.post(name: Event.enable, object: UIScreen.main, userInfo: nil)
    }

    static open func disable() {
        NotificationCenter.default.post(name: Event.disable, object: UIScreen.main, userInfo: nil)
    }
    
    static var radius: CGFloat = 24.0

    open class Window: UIWindow {
        
        private class TouchLayer: CAShapeLayer {
            override init() {
                super.init()
                
                self.path = UIBezierPath(ovalIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)).cgPath
                self.fillColor = UIColor(red:0, green: 0.564, blue:0.937, alpha:1).cgColor
                self.strokeColor = UIColor.white.cgColor

                // reset to pre-animation state
                self.reset()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            func reset() {
                self.lineWidth = 0.0
                self.opacity = 0.0
                self.transform = CATransform3DMakeScale(2.0, 2.0, 1)
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
            
            for touch in touches {
                switch touch.phase {
                case .began:
                    self.addTouchLayerFor(touch: touch)
                case .moved:
                    self.moveTouchLayerFor(touch: touch)
                case .stationary:
                    break // nothing to do
                case .cancelled:
                    fallthrough
                case .ended:
                    self.removeTouchLayerFor(touch: touch)
                }
            }
        }
        
        // MARK: TouchLayer management
        
        private func addTouchLayerFor(touch: UITouch) {
            let layer = TouchLayer()
            layer.position = touch.location(in: self)
            
            self.touchLayers[touch.hash] = layer
            self.insertTouchLayer(layer)
        }
        
        private func removeTouchLayerFor(touch: UITouch) {
            guard let layer = self.touchLayers.removeValue(forKey: touch.hash) else {
                print("\(#function) touch layer not found")
                return
            }
            self.removeTouchLayer(layer)
        }
        
        private func removeAllTouchLayers() {
            for (_, layer) in self.touchLayers {
                self.removeTouchLayer(layer)
            }
            self.touchLayers.removeAll()
        }
        
        private func moveTouchLayerFor(touch: UITouch) {
            guard let layer = self.touchLayers[touch.hash] else {
                return
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.position = touch.location(in: self)
            CATransaction.commit()
        }
        
        private func insertTouchLayer(_ touchLayer: TouchLayer) {
            self.layer.addSublayer(touchLayer)
            touchLayer.add(self.touchBeganAnimation, forKey: "touchBegan")
        }
        
        private func removeTouchLayer(_ touchLayer: TouchLayer) {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                touchLayer.removeFromSuperlayer()
            })
            touchLayer.add(self.touchEndedAnimation, forKey: "touchEnded")
            CATransaction.commit()
        }
        
        // MARK: Animation
        
        var touchBeganAnimation = Window.defaultTouchBeganAnimation()
        var touchEndedAnimation = Window.defaultTouchEndedAnimation()
        
        // Following code was generated from "Animation.qc" with minor tweaks
        private static func defaultTouchBeganAnimation() -> CAAnimation {
            ////Touch animation
            let touchTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
            touchTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(2.0, 2.0, 1)),
                                                 NSValue(caTransform3D: CATransform3DMakeScale(0.75, 0.75, 1)),
                                                 NSValue(caTransform3D: CATransform3DIdentity)]
            touchTransformAnim.keyTimes       = [0, 0.5, 1]
            touchTransformAnim.duration       = 0.25
            touchTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            
            let touchOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
            touchOpacityAnim.values         = [0, 0.35, 0.25]
            touchOpacityAnim.keyTimes       = [0, 0.5, 1]
            touchOpacityAnim.duration       = 0.25
            touchOpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            
            return QCMethod.group(animations: [touchTransformAnim, touchOpacityAnim], fillMode:kCAFillModeForwards)
        }
        
        // Uses code was generated from "Animation.qc" with minor tweaks
        private static func defaultTouchEndedAnimation() -> CAAnimation {
            ////Touch animation
            let touchTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
            touchTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                                 NSValue(caTransform3D: CATransform3DMakeScale(1.75, 1.75, 1))]
            touchTransformAnim.keyTimes       = [0, 1]
            touchTransformAnim.duration       = 0.5
            touchTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            
            let touchOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
            touchOpacityAnim.values         = [0.25, 0]
            touchOpacityAnim.keyTimes       = [0, 1]
            touchOpacityAnim.duration       = 0.5
            touchOpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            
            let touchLineWidthAnim            = CAKeyframeAnimation(keyPath:"lineWidth")
            touchLineWidthAnim.values         = [0, 1]
            touchLineWidthAnim.keyTimes       = [0, 1]
            touchLineWidthAnim.duration       = 0.5
            touchLineWidthAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            
            return QCMethod.group(animations: [touchTransformAnim, touchOpacityAnim, touchLineWidthAnim], fillMode:kCAFillModeForwards)
        }
    }
}

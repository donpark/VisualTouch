# VisualTouch

Makes iOS touch events visual.

<img src="demo.gif" width="200">

## Installation

CocoaPods

	pod 'VisualTouch', :git => 'https://github.com/donpark/VisualTouch.git'

## Integration

Add `VisibleTouch.swift` to your project then replace `window` instance variable declaration in `AppDelegate.swift` file:

    var window: UIWindow?
    
with:

    var window: UIWindow? = VisibleTouch.Window(frame: UIScreen.main.bounds)

## Usage

To enable visible touch:

    VisibleTouch.enable()

To disable:

    VisibleTouch.disable()

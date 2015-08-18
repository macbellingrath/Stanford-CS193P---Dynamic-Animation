//
//  DropItViewController.swift
//  Animation
//
//  Created by Mac Bellingrath on 8/18/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import UIKit

class DropItViewController: UIViewController, UIDynamicAnimatorDelegate {

 
    @IBOutlet var gameView: BezierPathsView!
   
    var dropsPerRow = 10
    var dropSize: CGSize {
        
        let size = gameView.bounds.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    //Create an animator
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
        
    }()
    //Create Behaviors
       let dropItBehavior = DropItBehavior()
    
    //Attachment Behavior 
    
    var attachment: UIAttachmentBehavior? {
        
        willSet {
            if attachment != nil{
                animator.removeBehavior(attachment!)
                gameView.setPath(nil, named: PathNames.Attachment)
            }
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment!.action = { [unowned self] in
                    if let attachedView = self.attachment?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(self.attachment!.anchorPoint)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPath(path, named: PathNames.Attachment)
                    }
                }
            }
        }
    }
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(dropItBehavior)
        
    }
    struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX - barrierSize.width/2, y: gameView.bounds.midY - barrierSize.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        dropItBehavior.addBarrier(path, name: PathNames.MiddleBarrier)
        
        gameView.setPath(path, named: PathNames.MiddleBarrier)
      
    }
    
    //When stasis occurs
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }

    @IBAction func grabDrop(sender: UIPanGestureRecognizer) {
       
        let gesturePoint = sender.locationInView(gameView)
      
        switch sender.state {
        case .Began:
            if let viewAttachTo = lastDroppedView {
                attachment = UIAttachmentBehavior(item: viewAttachTo, attachedToAnchor: gesturePoint)
                lastDroppedView = nil
            }
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        case .Ended:
            attachment = nil
        default:
            break
        }
    }
    
    @IBAction func drop(sender: UITapGestureRecognizer) {
        
        drop()
    }
    var lastDroppedView: UIView?
    
    func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let dropView = UIView(frame: frame)
        dropView.backgroundColor = UIColor.random
        
        lastDroppedView = dropView
        
        self.dropItBehavior.addDrop(dropView)
    }
    
    func removeCompletedRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height:dropSize.height)
        
        repeat {
            dropFrame.origin.y -= dropSize.height
            dropFrame.origin.x = 0
            var dropsFound = [UIView]()
            var rowIsComplete = true
            for _ in 0 ..< dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    } else {
                        rowIsComplete = false
                    }
                }
                dropFrame.origin.x += dropSize.width
            }
            if rowIsComplete {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        
        for drop in dropsToRemove {
            dropItBehavior.removeDrop(drop)
        }
    }
}
    



//Extensions
    
 private extension CGFloat {
        static func random(max: Int) ->CGFloat {
        return CGFloat(arc4random() % UInt32(max))
        }
    }
private extension UIColor {
    class var random: UIColor {
        switch arc4random()%5{
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.purpleColor()
        case 3: return UIColor.yellowColor()
        case 4: return UIColor.redColor()
        default: return UIColor.orangeColor()
        }
    }
}

//
//  PullDownMenü.swift
//
//  Created by Heiko Grau on 19.08.15.
//  Copyright © 2015 HeikoG. All rights reserved.
//

import UIKit
import QuartzCore


let kPanGestureEnable   = true
let kBlurHeaderEnable   = true
let kStartIndex         : Int = 0
let kCellidentifier     = "menubutton"
let kHeaderHeight       : CGFloat = 130
let kNumberOfItemsInRow : CGFloat = 3
let kVelocityTreshold   : CGFloat = 1000
let kAutocloseVelocity  : CGFloat = 1200
let kMenu_Item_Default_Fontname : String  = "HelveticaNeue-Light"
let kMenu_Item_Default_Fontsize : CGFloat = 25
let kMenuBounceOffset   : CGFloat = 3
let kBorderColor : UIColor = UIColor.darkGrayColor()
let kSelectedMenuItemColour : UIColor = UIColor.darkGrayColor()




enum PDMenuState : Int {
    case PDMenuShownState = 0
    case PDMenuClosedState
    case PDMenuDisplayingState
}

class PDMenuItem: NSObject {
    private var title   : String?
    private var icon    : UIImage?
    private var completion : () -> Bool
    
    init (title:String, completion:()->Bool) {
        self.title = title;
        self.completion = completion
    }
    
    init(title:String, iconImage:UIImage, completion:()->Bool) {
        self.title = title;
        self.icon = iconImage;
        self.completion = completion
    }
}

class PDCollectionViewLayout : UICollectionViewLayout {
    private var itemOffset : UIOffset!
    
    private var itemAttributes = [UICollectionViewLayoutAttributes]()
    private var contentSize : CGSize!
    
    override init() {
        super.init()
        self.itemOffset = UIOffsetMake(10.0, 6.0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareLayout() {
        self.itemAttributes.removeAll(keepCapacity: false)
        self.itemOffset = UIOffsetMake(0, 0)
        
        var column = 0
        var xOffset : CGFloat = self.itemOffset.horizontal;
        var yOffset : CGFloat = self.itemOffset.vertical;
        var rowHeight : CGFloat = 0.0;
        var contentWidth : CGFloat = 0.0;
        var contentHeight : CGFloat = 0.0;
        let numberOfItems = self.collectionView?.numberOfItemsInSection(0)
        var numberOfColumnsInRow = kNumberOfItemsInRow
        if numberOfColumnsInRow > CGFloat(numberOfItems!) {
            numberOfColumnsInRow = CGFloat(numberOfItems!)
        }
        for var index = 0; index < numberOfItems; index++ {
            var itemSize = CGSizeZero
            itemSize = CGSizeMake(self.collectionView!.bounds.size.width/numberOfColumnsInRow-self.itemOffset.horizontal, self.collectionView!.bounds.size.height)
            rowHeight = itemSize.height
            
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height))
            self.itemAttributes.append(attributes)
            
            xOffset = xOffset+itemSize.width;
            column++;
            
            if xOffset > contentWidth {
                contentWidth = xOffset
            }
            
            if (column == numberOfItems)
            {
                if xOffset > contentWidth {
                    contentWidth = xOffset
                }
                column = 0;
                xOffset = self.itemOffset.horizontal;
                yOffset = yOffset + rowHeight+self.itemOffset.vertical;
            }
        }
        let attributes : UICollectionViewLayoutAttributes = self.itemAttributes.last!
        contentHeight = attributes.frame.origin.y+attributes.frame.size.height
        self.contentSize = CGSizeMake(contentWidth, contentHeight);
    }
    
    override func collectionViewContentSize() -> CGSize {
        return self.contentSize
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.itemAttributes[indexPath.row]
    }
    
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let aArray = self.itemAttributes.filter { (evaluatedObject:UICollectionViewLayoutAttributes) -> Bool in
            return CGRectIntersectsRect(rect, evaluatedObject.frame)
        }
        return aArray
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}

class PDMenuCollectionViewCell : UICollectionViewCell {
    private var imageView : UIImageView!
    private var titleLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageSize = frame.size.width * 0.5
        self.imageView = UIImageView(frame: CGRectMake(0, 0, imageSize, imageSize))
        self.imageView.center = CGPointMake(frame.size.width/2, frame.size.height/2.5)
        self.addSubview(self.imageView)

        let spaceBelowImage = frame.size.height - (self.imageView.frame.origin.y + self.imageView.frame.size.height);
        let imageBottomY = (self.imageView.frame.origin.y + self.imageView.frame.size.height);
        let xOffset : CGFloat = 5.0;
        let yOffset : CGFloat = 2.0;
        self.titleLabel = UILabel(frame: CGRectMake(xOffset, imageBottomY+yOffset, frame.size.width-(xOffset*2), spaceBelowImage*0.5))
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension PDMenu: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let menuCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellidentifier, forIndexPath: indexPath) as! PDMenuCollectionViewCell
        menuCell.backgroundColor = collectionView.backgroundColor
        if !self.hidesBorder {
            menuCell.layer.borderColor = kBorderColor.CGColor
            menuCell.layer.borderWidth = self.borderWidth
        }
        let menuItem = self.menuItems[indexPath.row] as PDMenuItem
        menuCell.titleLabel.text = menuItem.title
        menuCell.titleLabel.textColor = self.textColor
        menuCell.titleLabel.font = UIFont.systemFontOfSize(10.0)
        menuCell.imageView.image = menuItem.icon
        
        if self.highLighedIndex == indexPath.row {
            menuCell.titleLabel.textColor = self.highLightTextColor
            menuCell.titleLabel.font = UIFont.systemFontOfSize(13.0)
            menuCell.backgroundColor = kSelectedMenuItemColour
        }
        
        return menuCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.highLighedIndex = indexPath.row
        self.menuContentCollectionView.reloadData()
        let selectedItem = self.menuItems[indexPath.row]
        self.animateMenuClosingWithCompletion { (finished) -> () in
            selectedItem.completion()
            
        }
    }
}

class PDMenu: UIView {
    private var menuItems : [PDMenuItem]!
    private var menuContentTable = UITableView()
    private var menuContentCollectionView : UICollectionView!
    private weak var contentController: UIViewController!
   
    private var currentMenuState: PDMenuState?
    private var highLighedIndex: Int = 0
    private var collectionHeight: CGFloat = 130
    private var menuHeight: CGFloat!
    private var textColor : UIColor = UIColor.grayColor()
    private var highLightTextColor : UIColor = UIColor.blackColor()
    private var titleFont : UIFont!
    private var topRightUtilityView = UIImageView()
    var topRightUtilityButtonBlock: () -> () = {}
    
    var borderWidth : CGFloat = 1.0
    var headerImage : UIImage?
    private var headerImageView = UIImageView()
    var profileImageView = UIImageView()
    var profileLabel = UILabel()
    var hidesBorder : Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(menuItems:[PDMenuItem], _textColor: UIColor, _highLightTextColor: UIColor, _backgroundColor: UIColor, forViewController _viewController:UIViewController) {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 999))
        
        self.borderWidth = 1.0
        self.menuItems = menuItems
        self.textColor = _textColor
        self.highLightTextColor = _highLightTextColor
        self.backgroundColor = _backgroundColor
        self.contentController = _viewController
        
        if kPanGestureEnable {
            let pan = UIPanGestureRecognizer(target: self, action: "didPan:")
            self.contentController?.view.addGestureRecognizer(pan)
            
        }
        
        self.setShadowProperties()
        self.contentController?.view.autoresizingMask = UIViewAutoresizing.None
        let menuController = UIViewController()
        menuController.view = self
        let window = UIApplication.sharedApplication().delegate!.window
        window??.rootViewController = menuController
        window??.addSubview(self.contentController!.view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupView", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(22, 22), false, 0)
        self.drawMenuButton()
        Cache.imageOfMenuButton = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(22, 22), false, 0)
        self.drawInfoButton()
        Cache.imageOfInfoButton = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.setupView()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
    func setupView() {
        self.topRightUtilityView.removeFromSuperview()
        if let _ = self.menuContentCollectionView {
           self.menuContentCollectionView.removeFromSuperview()
        }

        var numberOfItemsInRow = kNumberOfItemsInRow
        if numberOfItemsInRow > CGFloat(menuItems.count) {
            numberOfItemsInRow = CGFloat(menuItems.count)
        }
        
        self.collectionHeight = (UIScreen.mainScreen().bounds.width / numberOfItemsInRow)
        if self.collectionHeight > 130 { self.collectionHeight = 130 }
        self.menuHeight = kHeaderHeight + collectionHeight
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.menuHeight)
        
        self.highLighedIndex = kStartIndex
        self.currentMenuState = .PDMenuClosedState
        if let _font = UIFont(name: kMenu_Item_Default_Fontname, size: kMenu_Item_Default_Fontsize) {
            self.titleFont = _font
        }

        if let _ = self.contentController?.navigationController {
            self.contentController = self.contentController?.navigationController
        }
        
        //setup HeaderView
        self.headerImageView.removeFromSuperview()
        self.headerImageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, kHeaderHeight))
        self.headerImageView.backgroundColor = self.backgroundColor
        self.headerImageView.layer.masksToBounds = true
        self.headerImageView.image = headerImage
        if kBlurHeaderEnable {
            if let _ = headerImage?.size {
                let effect =  UIBlurEffect(style: UIBlurEffectStyle.Light)
                let effectView  = UIVisualEffectView(effect: effect)
                effectView.frame  = self.headerImageView.frame
                self.headerImageView.addSubview(effectView)
                
            }
        }
        
        self.headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(headerImageView)

        //setup ProfilImage
        var tempImage = self.profileImageView.image
        self.profileImageView.removeFromSuperview()
        self.profileImageView = UIImageView(frame: CGRectMake(0, 0, headerImageView.frame.size.height/2, headerImageView.frame.size.height/2))
        self.profileImageView.center = CGPointMake(headerImageView.center.x, headerImageView.center.y);
        self.profileImageView.image = tempImage
        if let _ = tempImage?.size {
            self.roundImageView(self.profileImageView)
        }
        self.addSubview(self.profileImageView)
        tempImage = nil
        
        //setup ProfilLabel
        var tempTxt = self.profileLabel.text
        self.profileLabel.removeFromSuperview()
        let xOffset : CGFloat = 5.0
        let yOffset : CGFloat = 2.0
        let imageBottomY : CGFloat = (profileImageView.frame.origin.y + profileImageView.frame.size.height) ;
        self.profileLabel = UILabel(frame: CGRectMake(xOffset, imageBottomY+yOffset, UIScreen.mainScreen().bounds.size.width-(xOffset*2), 21))
        self.profileLabel.textColor = UIColor.whiteColor()
        self.profileLabel.text = tempTxt
        self.profileLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(self.profileLabel)
        tempTxt = nil
        
        //setup InfoButton
        let buttonSize : CGFloat = 22;
        self.topRightUtilityView = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width-buttonSize-xOffset, UIApplication.sharedApplication().statusBarFrame.size.height+2, buttonSize, buttonSize))
        topRightUtilityView.image = infoButton()
        let tap = UITapGestureRecognizer(target: self, action: "rightUtilityPressed:")
        topRightUtilityView.addGestureRecognizer(tap)
        self.addSubview(topRightUtilityView)
        topRightUtilityView.image = topRightUtilityView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        topRightUtilityView.tintColor = self.highLightTextColor
        topRightUtilityView.userInteractionEnabled = true
        
        //setup CollectionView
        let layout = PDCollectionViewLayout()
        self.menuContentCollectionView = UICollectionView(frame: CGRectMake(0, kHeaderHeight, CGRectGetWidth(UIScreen.mainScreen().bounds), collectionHeight), collectionViewLayout:layout)
        self.menuContentCollectionView.delegate = self
        self.menuContentCollectionView.dataSource = self
        self.menuContentCollectionView.showsVerticalScrollIndicator = false
        self.menuContentCollectionView.backgroundColor = self.backgroundColor
        self.menuContentCollectionView.allowsMultipleSelection = false
        self.menuContentCollectionView.registerClass(PDMenuCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: kCellidentifier)
        self.addSubview(self.menuContentCollectionView)
    }
    
    // Helper
    func applyBlurEffect(image: UIImage?) -> UIImage {
        if let myImage = image {
            let imageToBlur = CIImage(image: myImage)
            let blurfilter = CIFilter(name: "CIZoomBlur")
            blurfilter!.setValue(imageToBlur, forKey: "inputImage")
            let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
            let blurredImage = UIImage(CIImage: resultImage)
            return blurredImage
        }
        return UIImage()
    }
    
    
    private func roundImageView(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = 2.0;
        imageView.layer.masksToBounds = true;
    }

    private func setShadowProperties() {
        self.contentController.view.layer.shadowOffset = CGSizeMake(0, 1)
        self.contentController.view.layer.shadowRadius = 4.0
        self.contentController.view.layer.shadowColor = UIColor.lightGrayColor().CGColor
        self.contentController.view.layer.shadowOpacity = 0.4
        self.contentController.view.layer.shadowPath = UIBezierPath(rect: self.contentController.view.bounds).CGPath
    }
    
    func rightUtilityPressed(sender:UIView) {
        self.topRightUtilityButtonBlock()
    }
    
    override func layoutSubviews() {
        self.currentMenuState = .PDMenuClosedState
        self.frame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), self.menuHeight);
        self.contentController.view.frame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds));
        self.setShadowProperties()
        self.menuContentTable = UITableView(frame: self.frame)
    }
   
    func showMenu() {
        if(self.currentMenuState == .PDMenuShownState || self.currentMenuState == .PDMenuDisplayingState){
            if(self.currentMenuState == .PDMenuShownState || self.currentMenuState == .PDMenuDisplayingState) {
                    self.animateMenuClosingWithCompletion({ (finished) -> () in
                        
                    })
            }
        }
        else{
            self.currentMenuState = .PDMenuDisplayingState;
            self.animateMenuOpening()
        }
    }
    
    func dismissMenu() {
        if(self.currentMenuState == .PDMenuShownState || self.currentMenuState == .PDMenuDisplayingState){
            
            self.contentController.view.frame = CGRectOffset(self.contentController.view.frame, 0,-self.menuHeight + kMenuBounceOffset);
            self.currentMenuState = .PDMenuClosedState;
            
        }
    }
    
    func didPan(panRecognizer: UIPanGestureRecognizer) {
        var viewCenter : CGPoint = panRecognizer.view!.center;
        
        if(panRecognizer.state == UIGestureRecognizerState.Began || panRecognizer.state ==
            UIGestureRecognizerState.Changed){
                let translation = panRecognizer.translationInView(panRecognizer.view?.superview)
                if(viewCenter.y >= UIScreen.mainScreen().bounds.size.height / 2 &&
                    viewCenter.y <= (UIScreen.mainScreen().bounds.size.height / 2 + self.menuHeight) - kMenuBounceOffset){
                        
                        self.currentMenuState = .PDMenuDisplayingState;
                        viewCenter.y = abs(viewCenter.y + translation.y);
                        
                        if viewCenter.y >= UIScreen.mainScreen().bounds.size.height / 2 &&
                            viewCenter.y < UIScreen.mainScreen().bounds.size.height / 2 + self.menuHeight - kMenuBounceOffset {
                              self.contentController.view.center = viewCenter;
                        }
                        panRecognizer.setTranslation(CGPointZero, inView: self.contentController.view)
                }
        } else if panRecognizer.state == UIGestureRecognizerState.Ended {
            let velocity = panRecognizer.velocityInView(panRecognizer.view?.superview)
            if velocity.y > kVelocityTreshold {
                self.openMenuFromCenterWithVelocity(velocity.y)
            } else if velocity.y < -kVelocityTreshold {
                self.closeMenuFromCenterWithVelocity(abs(velocity.y))
            } else if viewCenter.y <  (UIScreen.mainScreen().bounds.size.height / 2 + (self.menuHeight / 2)) {
                self.closeMenuFromCenterWithVelocity(kAutocloseVelocity)
            } else if viewCenter.y <= (UIScreen.mainScreen().bounds.size.height / 2 + self.menuHeight - kMenuBounceOffset) {
                self.openMenuFromCenterWithVelocity(kAutocloseVelocity)
            }
        }
    }
    
    private func animateMenuOpening() {
        if self.currentMenuState != .PDMenuShownState {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.contentController.view.center = CGPointMake(self.contentController.view.center.x,
                    UIScreen.mainScreen().bounds.size.height / 2 + self.menuHeight)
                }, completion: { (finished) -> Void in
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.contentController.view.center = CGPointMake(self.contentController.view.center.x,
                            UIScreen.mainScreen().bounds.size.height / 2 + self.menuHeight - kMenuBounceOffset)
                        }, completion: { (finished) -> Void in
                            self.currentMenuState = .PDMenuShownState
                    })
            })
        }

    }

    private func animateMenuClosingWithCompletion(completion:(finished:Bool)-> ()) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.contentController.view.center = CGPointMake(self.contentController.view.center.x,
                self.contentController.view.center.y + kMenuBounceOffset)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.contentController.view.center = CGPointMake(self.contentController.view.center.x,
                        UIScreen.mainScreen().bounds.size.height / 2)
                    }, completion: { (finished) -> Void in
                        if finished {
                            self.currentMenuState = .PDMenuClosedState
                            completion(finished: finished)
                        }
                })
        }
        
    }
    
    private func openMenuFromCenterWithVelocity(velocity:CGFloat) {
        let viewCenterY : CGFloat = UIScreen.mainScreen().bounds.size.height / 2 + self.menuHeight - kMenuBounceOffset
        self.currentMenuState = .PDMenuDisplayingState;
        let duration = NSTimeInterval((viewCenterY - self.contentController.view.center.y) / velocity)
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.contentController.view.center = CGPointMake(self.contentController.view.center.x, viewCenterY)
            }, completion: { (finished) -> Void in
                if finished {
                    self.currentMenuState = .PDMenuShownState
                }
        })
    }
    
    private func closeMenuFromCenterWithVelocity(velocity:CGFloat) {
        let viewCenterY : CGFloat = UIScreen.mainScreen().bounds.size.height / 2
        let duration = NSTimeInterval((self.contentController.view.center.y - viewCenterY) / velocity)
        self.currentMenuState = .PDMenuDisplayingState
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.contentController.view.center = CGPointMake(self.contentController.view.center.x,
                UIScreen.mainScreen().bounds.size.height / 2)
            }, completion: { (finished) -> Void in
                if finished {
                    self.currentMenuState = .PDMenuClosedState
                }
        })
    }
    
    private struct Cache {
        static var imageOfMenuButton: UIImage?
        static var imageOfInfoButton: UIImage?
    }
    
    private func drawMenuButton() {
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// menu.svg Group
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRectMake(2, 16, 18, 2), cornerRadius: 2)
        fillColor.setFill()
        rectanglePath.fill()
        
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRectMake(2, 9, 18, 2), cornerRadius: 2)
        fillColor.setFill()
        rectangle2Path.fill()
        
        
        //// Rectangle 3 Drawing
        let rectangle3Path = UIBezierPath(roundedRect: CGRectMake(2, 2, 18, 2), cornerRadius: 2)
        fillColor.setFill()
        rectangle3Path.fill()
    }
    
    private func drawInfoButton() {
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(12.84, 16.53))
        bezierPath.addCurveToPoint(CGPointMake(11.8, 16.71), controlPoint1: CGPointMake(12.83, 16.53), controlPoint2: CGPointMake(12.28, 16.71))
        bezierPath.addCurveToPoint(CGPointMake(11.39, 16.63), controlPoint1: CGPointMake(11.54, 16.71), controlPoint2: CGPointMake(11.43, 16.66))
        bezierPath.addCurveToPoint(CGPointMake(11.45, 15.23), controlPoint1: CGPointMake(11.23, 16.52), controlPoint2: CGPointMake(10.91, 16.3))
        bezierPath.addLineToPoint(CGPointMake(12.45, 13.24))
        bezierPath.addCurveToPoint(CGPointMake(12.69, 10.01), controlPoint1: CGPointMake(13.04, 12.05), controlPoint2: CGPointMake(13.13, 10.91))
        bezierPath.addCurveToPoint(CGPointMake(10.77, 8.6), controlPoint1: CGPointMake(12.34, 9.28), controlPoint2: CGPointMake(11.65, 8.78))
        bezierPath.addCurveToPoint(CGPointMake(9.81, 8.5), controlPoint1: CGPointMake(10.46, 8.53), controlPoint2: CGPointMake(10.13, 8.5))
        bezierPath.addCurveToPoint(CGPointMake(6.67, 9.63), controlPoint1: CGPointMake(7.97, 8.5), controlPoint2: CGPointMake(6.72, 9.58))
        bezierPath.addCurveToPoint(CGPointMake(6.57, 10.25), controlPoint1: CGPointMake(6.49, 9.78), controlPoint2: CGPointMake(6.45, 10.05))
        bezierPath.addCurveToPoint(CGPointMake(7.16, 10.47), controlPoint1: CGPointMake(6.69, 10.46), controlPoint2: CGPointMake(6.93, 10.55))
        bezierPath.addCurveToPoint(CGPointMake(8.2, 10.29), controlPoint1: CGPointMake(7.17, 10.47), controlPoint2: CGPointMake(7.72, 10.29))
        bezierPath.addCurveToPoint(CGPointMake(8.6, 10.36), controlPoint1: CGPointMake(8.46, 10.29), controlPoint2: CGPointMake(8.57, 10.34))
        bezierPath.addCurveToPoint(CGPointMake(8.55, 11.77), controlPoint1: CGPointMake(8.77, 10.48), controlPoint2: CGPointMake(9.08, 10.7))
        bezierPath.addLineToPoint(CGPointMake(7.55, 13.76))
        bezierPath.addCurveToPoint(CGPointMake(7.31, 16.99), controlPoint1: CGPointMake(6.96, 14.95), controlPoint2: CGPointMake(6.87, 16.09))
        bezierPath.addCurveToPoint(CGPointMake(9.23, 18.4), controlPoint1: CGPointMake(7.66, 17.72), controlPoint2: CGPointMake(8.34, 18.22))
        bezierPath.addCurveToPoint(CGPointMake(10.18, 18.5), controlPoint1: CGPointMake(9.54, 18.47), controlPoint2: CGPointMake(9.86, 18.5))
        bezierPath.addCurveToPoint(CGPointMake(13.33, 17.37), controlPoint1: CGPointMake(12.03, 18.5), controlPoint2: CGPointMake(13.28, 17.42))
        bezierPath.addCurveToPoint(CGPointMake(13.43, 16.75), controlPoint1: CGPointMake(13.51, 17.22), controlPoint2: CGPointMake(13.55, 16.95))
        bezierPath.addCurveToPoint(CGPointMake(12.84, 16.53), controlPoint1: CGPointMake(13.31, 16.54), controlPoint2: CGPointMake(13.06, 16.45))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(9.5, 2.5, 5, 5))
        fillColor.setFill()
        ovalPath.fill()
    }

    
    class func menuButton() -> UIImage {
        return Cache.imageOfMenuButton!
    }
    
    private func infoButton() -> UIImage {
        return Cache.imageOfInfoButton!
    }
    
}

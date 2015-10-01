[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

![Screenshot](https://github.com/sspux/PullDownMenu/blob/master/phonescreen.png)

**Please ★ this library if you like it!*

# PullDownMenu
PDMenu is a reimplementation of Edo-Osagie's [DDMenu](https://github.com/oduwa/DropDownMenu) in
Swift. A iOS 8/9 pulldown menu. 

###Requirements

PDMenu requires `Swift 2.0`, `Xcode 7.01` and `iOS 8`.

##Installation##

I haven't setup a pod for this project yet so for now, to install it just drag and drop the *PDMenu.swift* file into your Xcode project. Pretty simple huh!


## Usage ##

PDMenu is built on the DDMenu library so its API is very similar to that.

The PDMenu consists of 3 main things:
* HeaderView
* ProfilePictureView
* PDMenuItem

You can create Menu Items and add them to your menu as follows:

```swift
let item1 = PDMenuItem(title: "First", iconImage: UIImage(named: "itemImage")) { () -> Bool in
            /* Instantiate the View Controller that the menu item should navigate to */
            let first = storyboard.instantiateViewControllerWithIdentifier("viewController")
            
            /* Navigate to it */
            self.setViewControllers([first], animated: false)
            return true
        }
```

Once you have created your menu items, its time create the actual menu and put it all together!

```swift
_menu = PDMenu(menuItems: [item1, item2, item3], _textColor: UIColor.lightGrayColor(), _highLightTextColor: UIColor.whiteColor(), _backgroundColor: UIColor.blackColor(), forViewController: self)
```

Once you have created your menu, its time create the menucall in the viewController!
```swift
self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: PDMenu.menuButton(), style: UIBarButtonItemStyle.Plain, target: self.navigationController, action: "showMenu")
```

## Customization ##

An example of a PDMenu with some customization is shown below:

```swift
_menu.headerImageView.image = [UIImage imageNamed:@"header_picture.jpg"];
_menu.profileImageView.image = [UIImage imageNamed:@"profile_picture.jpg"];
_menu.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
_menu.profileLabel.text = @"username";
_menu.hidesBorder = true;
_menu.topRightUtilityButtonBlock = {
    print("infoButton pressed")
}
```

At the moment, the following features can be customized over constants:

```swift
kPanGestureEnable
kBlurHeaderEnable
kNumberOfItemsInRow
kMenu_Item_Default_Fontname
kMenu_Item_Default_Fontsize
kBorderColor
kSelectedMenuItemColour
```

At the moment, the following features can be customized in runtime:

```swift
headerImageView
profileLabel
profileImageView
hidesBorder
topRightUtilityButtonBlock
```

## Compatability ##

Tested and working on iOS 8.0+ and Xcode 7.01

That's all folks!

#Author

HeikoG

[oduwa/DropDownMenu](https://github.com/oduwa/DropDownMenu) was
authored by Odie Edo-Osagie

## License
This repository is licensed under the MIT license, more under
[LICENSE](LICENSE).

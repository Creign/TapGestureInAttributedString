//
//  ViewController.swift
//  TapInAttributedString
//
//  Created by Excell on 22/10/2019.
//  Copyright © 2019 Excell. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    let labelText = "Note:\nThis is a sample for tap gesture with nsattributestring on label. Click the link to proceed."
    let linkText = "link"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.attributedText = getAttributedText()
        label.lineBreakMode = .byWordWrapping
        setupGestureRecognizer(customView: label)
    }
    
    func getAttributedText() -> NSMutableAttributedString {
        let range = (labelText as NSString).range(of: linkText)
        let font: UIFont = UIFont(name: "Helvetica Neue", size: 18) ?? UIFont()
        let boldFont = UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold)!,
                              size: 18)
        
        let attributes: [NSAttributedString.Key : Any] =
            [NSAttributedString.Key.link : "https://www.link1.com",
             NSAttributedString.Key.foregroundColor : UIColor.blue,
             NSAttributedString.Key.underlineColor : UIColor.clear,
             NSAttributedString.Key.font: boldFont]
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: labelText, attributes: [NSAttributedString.Key.font: font])
        attributedString.addAttributes(attributes, range: range)
        return attributedString
    }
    
    func setupGestureRecognizer(customView: UILabel) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(touch:)))
        customView.isUserInteractionEnabled = true
        customView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapAction(touch: UITapGestureRecognizer) {
        if touch.didTapAttributedTextInLabel(label: label, inRange: (labelText as NSString).range(of: linkText)) {
            let alert = UIAlertController(title: "", message: "TO DO HERE!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let touchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        
        let touchInContainer = CGPoint(
            x: touchInLabel.x - textContainerOffset.x,
            y: touchInLabel.y - textContainerOffset.y
        )
        
        let characterIndex = layoutManager.characterIndex(for: touchInContainer,
                                                          in: textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(characterIndex, targetRange)
    }
}

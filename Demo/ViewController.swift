//
//  ViewController.swift
//  Demo
//
//  Created by Edwin Vermeer on 29/11/2016.
//  Copyright © 2016 evermeer. All rights reserved.
//

import UIKit
import AttributedTextView

class ViewController: UIViewController {

    @IBOutlet weak var attributedTextView: AttributedTextView!

    // These are the samples for this demo
    lazy var samples: [(title: String, show: (()->()))] = [
        ("custom link and attributes", showSample1(self)),
        ("coloring and aditional attributes", showSample2(self)),
        ("single or multiple matches", showSample3(self)),
        ("hashtags and mentions", showSample4(self)),
        ("creating your own composit style", showSample5(self))
    ]

    // For more basic tests about how to use AttributedTextView, see the playground
    
    override func viewDidAppear(_ animated: Bool) {
        showSample1()
    }
    
    // Dynamically build the header and the previous and next links around the content
    func decorate(_ id: Int, _ builder: ((_ content: Attributer) -> Attributer)) -> Attributer {
        var b = "Sample \(id + 1): \(samples[id].title)\n\n".red
        if id > 0  {
            b = b + "<-- previous sample\n\n".underline.makeInteract { _ in
                self.samples[id - 1].show()
            }
        }
        b = builder(b) // Now add the content
        if id < (samples.count - 1) {
            b = b + "\n\nnext sample -->".underline.makeInteract { _ in
                self.samples[id + 1].show()
            }
        }
        return b
    }
    
    // Basic test where we use the .append to paste the attributed string parts together
    func showSample1() {
        attributedTextView.attributer = decorate(0) { content in return content
            .append("This is the first test. ").green
            .append("Tap on ").black
            .append("evict.nl").makeInteract { _ in
                UIApplication.shared.open(URL(string: "http://evict.nl")!, options: [:], completionHandler: { completed in })
            }.underline
            .append(" for testing links. Or tap on the 'next sample' link below ").black
        }
        .all.font(UIFont(name: "SourceSansPro-Regular", size: 16)) // Font not availabel in this demo...
        .setLinkColor(UIColor.purple) // Will be set on the control so we also have to reset it when we show the next sample.
    }

    // Basic test where we use + to paste the attributed string parts together
    func showSample2() {
        attributedTextView.attributer = decorate(1) { content in return content
            + "green, ".green.fontName("Helvetica").size(30)
            + "cyan, ".cyan.size(22)
            + "orange, ".orange.kern(10)
            + "blue, ".blue.strikethrough(3).baselineOffset(8)
            + "black.".shadow(color: UIColor.gray, offset: CGSize(width: 2, height: 3), blurRadius: 3.0)
        }
        .setLinkColor(UIColor.blue) // Reset the link color to the default blue
    }

    // We can select 1 or more ranges in an attributed text and apply a style to that.
    func showSample3() {
        attributedTextView.attributer = decorate(2) { content in return content
            + "It is this or it is that where the word is is selected".size(20)
            .match("is").underline.underline(UIColor.red)
            .matchAll("is").strikethrough(4)
        }
    }
    
    // There are custom matchers for hashtags, metions, links or you can use a regexp with matchPattern
    func showSample4() {
        attributedTextView.attributer = decorate(3) { content in return content
            + "@test: What #hashtags do we have in @evermeer #AtributedTextView library"
            .matchHashtags.underline
            .makeInteract { link in
                UIApplication.shared.open(URL(string: "https://twitter.com/hashtag/\(link.replacingOccurrences(of: "%23", with: ""))")!, options: [:], completionHandler: { completed in })
            }
            .matchMentions
            .makeInteract { link in
                UIApplication.shared.open(URL(string: "https://twitter.com/\(link.replacingOccurrences(of: "%40", with: ""))")!, options: [:], completionHandler: { completed in })
            }
        }
    }

    // Here we simply use our own composit style
    func showSample5() {
        attributedTextView.attributer = decorate(4) { content in return content
            + "This is our custom title".myTitle
        }
    }
}


// Extending the Attributer and String so that it supports a custom composit style. See the showSample5

extension Attributer {
    open var myTitle: Attributer {
        get {
            return self.fontName("Arial").size(28).color(0xffaa66).kern(5)
        }
    }
}

public extension String {
    var myTitle: Attributer {
        get {
            return attributer.myTitle
        }
    }
}

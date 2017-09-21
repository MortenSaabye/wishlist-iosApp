//
//  Wish.swift
//  birthday-wishes
//
//  Created by Morten Saabye Kristensen on 13/09/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import Foundation
import UIKit
import URLEmbeddedView

class Wish {
//    MARK: Properties
    var title = ""
    var url: URL?
    var image: UIImage?
    var category = "Other"
    
//    MARK: Static Properties
    static var categories = ["Other"]
    
//    MARK: Initialization
    init(url: URL) {
        OGDataProvider.shared.fetchOGData(urlString: url.absoluteString) { (data, err) in
            self.title = data.pageTitle
            self.url = URL(fileURLWithPath: data.sourceUrl)
            self.image = UIImage.setImageFromURl(stringImageUrl: data.imageUrl)
        }
    }
    init(title: String) {
        self.title = title
    }
    
    init(title: String, url: URL?, photo: UIImage?) {
        self.title = title
        self.url = url
        self.image = photo
    }
    
    init(title: String, url: URL?, photo: UIImage?, category: String) {
        self.title = title
        self.url = url
        self.image = photo
        self.category = category
        if Wish.categories.contains(category) == false {
            Wish.categories.append(category)
        }
     }
}

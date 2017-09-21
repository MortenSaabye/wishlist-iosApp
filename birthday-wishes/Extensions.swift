//
//  Extensions.swift
//  birthday-wishes
//
//  Created by Morten Saabye Kristensen on 12/09/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit

extension UIImage{
    
    static func setImageFromURl(stringImageUrl url: String) -> UIImage? {
        
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOf: url as URL) {
                guard let image = UIImage(data: data as Data) else { return nil}
                return image
            }
        }
        
        return nil
    }
}

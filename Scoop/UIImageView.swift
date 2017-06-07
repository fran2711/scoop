//
//  UIImageView.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func imageFromServerUrl(urlString: String) {
        let image = UIImage(named: "")
        self.image = image
        
        if urlString != "" {
            DispatchQueue.global().async {
                do {
                    let data = try getFileFrom(urlString: urlString)
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.image = image
                    }
                } catch {
                    
                }
            }
        }
    }
    
    
    public func imageFromServerURLThumb(urlString: String) {
        
        let image = UIImage(named: "")
        self.image = image
        
        if urlString != "" {
            DispatchQueue.global().async {
                do{
                    let data = try getFileFrom(urlString: urlString)
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.image = image
                    }
                }catch{
                    
                }
            }
        }
        
    }

}

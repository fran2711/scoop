//
//  Errors.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import Foundation

enum ScoopsError : Error{
    case wrongUrlFormatForJSONResource
    case resourcePointedByUrlNotReachable
    case wrongJsonFormat
    case NotInLibrary
}

enum PDFError: Error{
    case invalidURL
    case notAPDF
}

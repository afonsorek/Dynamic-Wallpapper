//
//  Extensions.swift
//  dynamic-wallpapper
//
//  Created by Afonso Rekbaim on 11/03/24.
//

import Foundation
import SwiftUI
import CoreImage
import Combine

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
    var tiff: Data? { representation(using: .tiff, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
    var tiff: Data? { tiffRepresentation?.bitmap?.tiff }
}

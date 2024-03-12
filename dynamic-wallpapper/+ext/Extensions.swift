//
//  Extensions.swift
//  dynamic-wallpapper
//
//  Created by Afonso Rekbaim on 11/03/24.
//

import Foundation
import SwiftUI

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}

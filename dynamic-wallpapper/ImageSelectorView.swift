//
//  ImageSelectorView.swift
//  dynamic-wallpapper
//
//  Created by Afonso Rekbaim on 11/03/24.
//
import Foundation
import SwiftUI

struct ImageSelectorView: View {
    @State var lightImage: NSImage?
    @State var darkImage: NSImage?
    
    @State var count = 0

    var body: some View {
        VStack{
            HStack(spacing: 100){
                VStack{
                    if lightImage != nil{
                        Image(nsImage: lightImage!)
                            .resizable()
                            .scaledToFit()
                    }else{
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    }
                    Button("Select File") {
                        selectLightImage()
                    }
                }
                
                VStack{
                    if darkImage != nil{
                        Image(nsImage: darkImage!)
                            .resizable()
                            .scaledToFit()
                    }else{
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    }
                    Button("Select File") {
                        selectDarkImage()
                    }
                }
            }
            .frame(width: 600, height: 300)
            
            Button("Make dynamic wallpapper"){
                //
                xpmInjection(nsImage: darkImage, isLight: false)
                xpmInjection(nsImage: lightImage, isLight: true)
            }
        }
    }

    func selectLightImage() {
      let panel = NSOpenPanel()
      panel.allowsMultipleSelection = false
      panel.canChooseDirectories = false
      panel.canCreateDirectories = false
      panel.canChooseFiles = true
      panel.allowedContentTypes = [.png, .jpeg]

      if panel.runModal() == .OK {
        if let imageURL = panel.url {
          // Load the image using NSImage
            self.lightImage = NSImage(contentsOf: imageURL)!
        }
      }
    }

    func selectDarkImage() {
      let panel = NSOpenPanel()
      panel.allowsMultipleSelection = false
      panel.canChooseDirectories = false
      panel.canCreateDirectories = false
      panel.canChooseFiles = true
      panel.allowedContentTypes = [.png, .jpeg]

      if panel.runModal() == .OK {
        if let imageURL = panel.url {
          // Load the image using NSImage
            self.darkImage = NSImage(contentsOf: imageURL)!
        }
      }
    }

    func xpmInjection(nsImage: NSImage?, isLight: Bool) {
        let xpmWriteData = """
<?xpacket?>
<x:xmpmeta xmlns:x="adobe:ns:meta">
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns">
<rdf:Description xmlns:apple_desktop="http://ns.apple.com/namespace/1.0"
apple_desktop:apr=
"YnBsaXN0MDDSAQMCBFFsEAFRZBAACA0TEQ/REMOVE/8BAQAAAAAAAAAFAAAAAAAAAAAAAAAAAAAAFQ=="/>
</rdf:RDF>
</x:xmpmeta>
"""
        let xpmURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(isLight ? "light_image.xpm" : "dark_image.xpm")
        let imageURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(isLight ? "light_image.png" : "dark_image.png")
        if let png = nsImage!.png {
            do {
                try png.write(to: imageURL)
                print(png)
                print("PNG image saved at \(imageURL)")
            } catch {
                print(error)
            }
            
            do{
                try FileManager.default.currentDirectoryPath.write(to: xpmURL, atomically: true, encoding: xpmWriteData.smallestEncoding)
                print("Dados injetados com sucesso em \(xpmURL)")
                print(try Data(contentsOf: xpmURL).base64EncodedString())
            }catch{
                return
            }
            
            do{
                try FileManager.default.currentDirectoryPath.write(to: imageURL, atomically: true, encoding: try Data(contentsOf: xpmURL).base64EncodedString().smallestEncoding)
                print(try Data(contentsOf: imageURL).base64EncodedString())
            }catch{
                return
            }
        }
        
    }

}


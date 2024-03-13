//
//  ImageSelectorView.swift
//  dynamic-wallpapper
//
//  Created by Afonso Rekbaim on 11/03/24.
//
import Foundation
import SwiftUI
import CoreImage
import CoreGraphics


struct ImageSelectorView: View {
    @State var lightImage: NSImage?
    @State var darkImage: NSImage?
    @State var count = 0
    
    @State var images:[Data] = []
    
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
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    convertToHEIC()
                }
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
    
    func convertToHEIC(){
        let heicURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("dynamic_wallpapper.heic")
        
        let tiff1 = NSImage(data: images[0])
        let tiff2 = NSImage(data: images[1])
        
        let combinedImage: () = encodeToHEIC(image1: tiff1!, image2: tiff2!, outputURL: heicURL)

    }
    
    func encodeToHEIC(image1: NSImage, image2: NSImage, outputURL: URL) {
        guard let imageData1 = image1.tiffRepresentation,
            let imageData2 = image2.tiffRepresentation,
            let bitmap1 = NSBitmapImageRep(data: imageData1),
            let bitmap2 = NSBitmapImageRep(data: imageData2) else {
                print("Error: Couldn't create bitmap representations")
                return
        }

        let context = CIContext()

        guard let inputImage1 = CIImage(bitmapImageRep: bitmap1),
            let inputImage2 = CIImage(bitmapImageRep: bitmap2) else {
                print("Error: Couldn't create CIImage from bitmaps")
                return
        }

        // Composite the two images
        let outputImage = inputImage2.composited(over: inputImage1)

        do {
            // Save the composited image as HEIC
            try context.writeHEIFRepresentation(of: outputImage, to: outputURL, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, options: [:])
            print("HEIC file saved successfully at \(outputURL)")
        } catch {
            print("Error saving HEIC file: \(error.localizedDescription)")
        }
    }


    
    func xpmInjection(nsImage: NSImage?, isLight: Bool) {
        let xpmWriteData : Data = """
<?xpacket?>
<x:xmpmeta xmlns:x="adobe:ns:meta">
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns">
<rdf:Description xmlns:apple_desktop="http://ns.apple.com/namespace/1.0"
apple_desktop:apr=
"YnBsaXN0MDDSAQMCBFFsEAFRZBAACA0TEQ/REMOVE/8BAQAAAAAAAAAFAAAAAAAAAAAAAAAAAAAAFQ=="/>
</rdf:RDF>
</x:xmpmeta>
""".data(using: .ascii)!
        
        let xpmURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(isLight ? "light_image.xpm" : "dark_image.xpm")
        let tiffURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(isLight ? "1.tiff" : "2.tiff")
        let imageURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(isLight ? "light_image.png" : "dark_image.png")
        
        
        if var png = nsImage!.png {
            do {
                try png.write(to: imageURL)
            } catch {
                print(error)
            }
            
            do{
                try xpmWriteData.write(to: xpmURL)
            }catch{
                print(error)
            }
            
            do{
                try png.append(Data(contentsOf: xpmURL))
                try png.write(to: imageURL)
            }catch{
                print(error)
            }
            
            if let tiff = png.bitmap?.tiff{
                do{
                    //Salva o tiff
                    try tiff.write(to: tiffURL)
                    var tiffData = try Data(contentsOf: tiffURL)
                    //ELE SALVA COMO TIFF
//                    var heicData = try Data(contentsOf: heicURL)
//                    heicData.append(try Data(contentsOf: tiffURL))
                    images.append(tiffData)
                }catch{
                    print(error)
                }
            }
        }
        
    }

}


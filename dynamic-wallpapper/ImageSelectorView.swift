//
//  ImageSelectorView.swift
//  dynamic-wallpapper
//
//  Created by Afonso Rekbaim on 11/03/24.
//
import Foundation
import SwiftUI
import libheif

struct ImageSelectorView: View {
    @State var lightImage: NSImage?
    @State var darkImage: NSImage?
    @State var count = 0
    
    @State var images:[Data] = []
    
    let commands: [String] = ["sudo -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"", "cd ..", "cd ..", "cd \(FileManager.default.urls(for: .inputMethodsDirectory, in: .userDomainMask).first!.absoluteString.replacingOccurrences(of: "file://", with: ""))", "heif-enc -L light_image.png dark_image.png -o dynamic_afonsinho.heic"]
    
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
                    for command in commands{
                        _ = shell(command)
                    }
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
    
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        
        try! task.run()

        print(command)
        print(task)

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print(output)
            return output
        }
        return ""
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
        
        let xpmURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("light_image.xpm")
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
                if isLight{
                    try png.append(Data(contentsOf: xpmURL))
                }
                try png.write(to: imageURL)
            }catch{
                print(error)
            }
            
//            if let tiff = png.bitmap?.tiff{
//                do{
//                    //Salva o tiff
//                    try tiff.write(to: tiffURL)
//                    var tiffData = try Data(contentsOf: tiffURL)
//                    //ELE SALVA COMO TIFF
////                    var heicData = try Data(contentsOf: heicURL)
////                    heicData.append(try Data(contentsOf: tiffURL))
                    images.append(png)
//                }catch{
//                    print(error)
//                }
//            }
        }
        
    }

}


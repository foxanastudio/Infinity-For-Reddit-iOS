//
// FontInterfaceView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-05
//

import SwiftUI
import Swinject
import GRDB

struct FontInterfaceView: View {
    @StateObject private var fontInterfaceViewModel = FontInterfaceViewModel()
    
    var body: some View {
        List{
            Section{
                NavigationLink(destination: FontInterfaceView()){
                    Text("Font Preview").padding(.leading, 44.5)
                }
            }
            Section(header: Text("Font")){
                Picker("Font Family", selection: $fontInterfaceViewModel.fontFamily){
                    ForEach(0..<fontInterfaceViewModel.families.count, id: \.self) { index in
                        Text(fontInterfaceViewModel.families[index]).tag(index)
                    }
                }
                .padding(.leading, 44.5)
                
                Picker("Font Size", selection: $fontInterfaceViewModel.fontSize){
                    ForEach(0..<fontInterfaceViewModel.sizes.count, id: \.self) { index in
                        Text(fontInterfaceViewModel.sizes[index]).tag(index)
                    }
                }
                .padding(.leading, 44.5)
            }
            Section(header: Text("Title")){
                Picker("Title Font Family", selection: $fontInterfaceViewModel.titleFontFamily){
                    ForEach(0..<fontInterfaceViewModel.families.count, id: \.self) { index in
                        Text(fontInterfaceViewModel.families[index]).tag(index)
                    }
                }
                .padding(.leading, 44.5)
                
                Picker("Title Font Size", selection: $fontInterfaceViewModel.titleFontSize){
                    ForEach(0..<fontInterfaceViewModel.sizes.count, id: \.self) { index in
                        Text(fontInterfaceViewModel.sizes[index]).tag(index)
                    }
                }
                .padding(.leading, 44.5)
                
            }
            Section(header: Text("Content")){
                Picker("Content Font Family", selection: $fontInterfaceViewModel.contentFontFamily){
                    ForEach(0..<fontInterfaceViewModel.families.count, id: \.self) { index in
                        Text(fontInterfaceViewModel.families[index]).tag(index)
                    }
                }
                .padding(.leading, 44.5)
                
                Picker("Content Font Size", selection: $fontInterfaceViewModel.contentFontSize){
                    ForEach(0..<fontInterfaceViewModel.contentSizes.count, id: \.self) { index in
                        Text(fontInterfaceViewModel.contentSizes[index]).tag(index)
                    }
                }
                .padding(.leading, 44.5)

            }
        }
    }
}

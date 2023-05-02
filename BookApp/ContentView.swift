//
//  ContentView.swift
//  BookApp
//
//  Created by Azmat Ali Akhtar on 17/04/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

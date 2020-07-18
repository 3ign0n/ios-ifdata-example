//
//  ContentView.swift
//  IfDataExample
//
//  Created by 3ign0n on 2020/07/11.
//

import SwiftUI
import Foundation

struct ContentView: View {
    var body: some View {
        VStack {
            Text("\(ProcessInfo().systemUptime)").padding()
        
            Button(action: {
                _ = TrafficStatisticsManager.retrieveStatistics()
            }){
                Text("ネットワークIF統計情報を取得")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by Elliott Yu on 15/04/2025.
//

import SwiftUI

import TerraRTiOS

struct ContentView: View {
    
    @State private var hrValue: Double = 0.0
    @State private var test: Double = 0.0
    
    let t = try? Terra()
    
    var body: some View {
        VStack{
            ScrollView{
                Button("Connect", action: {
                    t!.connect()
                    t!.stopStream()
                    t!.setWorkoutStateListener{x in print(x)}
                }).padding()
                    Button("Stream HR", action: {
                        t!.startStream(forDataTypes: Set([.HEART_RATE])) { _,_  in
                            //
                        }
                    }).padding()
                    Button("Start Run", action: {
                        t!.connect()
                        t!.startExercise(forType: .RUNNING, completion: {s, e in
                            print(s, e)
                        })
                        t!.startStream(forDataTypes: Set([.HEART_RATE])) { _,_  in
                            //
                        }
                    }).padding()
                    Button("Stop Run", action: {
                        t!.stopExercise(completion: {_, e in
                            print(e)
                        })
                    }).padding()
                    Button("Random test", action: {
                        t!.sendMessage(["Hello": "Hi"])
                    }).padding()
                    Text("\(hrValue)").padding()
                    Text("\(test)").padding()
                }
            }.onAppear {
                t?.setUpdateHandler { u in
                    hrValue = u.val ?? 0.0
                }
                t?.setMessageHandler{m in
                    test = m["Hello"] as! Double
                }
                t?.setWatchOSConnectionStateListener { state in
                    print(state)
                }
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


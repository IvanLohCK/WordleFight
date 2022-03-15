//
//  ContentView.swift
//  wordlefight
//
//  Created by Ivan Loh on 1/3/22.
//

import SwiftUI

struct GameView: View {
    let testEnvAD = "ca-app-pub-3940256099942544/4411468910" // interstitial
    let prodEnvAd = "ca-app-pub-8804419651156039/2485031687"
    
    let testEnvRewardAd = "ca-app-pub-3940256099942544/1712485313" // reward
    let prodEnvRewardAd = "ca-app-pub-8804419651156039/2511353357"
    
    @EnvironmentObject var dm: WordleDataModel
    @State private var showSettings = false
    @State private var showHelp = false
    @State var showRewardedAd: Bool = false
    @State var showIntersitialAd: Bool = false
    @State var rewardGranted: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if Global.screenHeight < 600 {
                        Text("")
                    }
                    Spacer()
                    VStack(spacing: 3) {
                        ForEach(0...5, id: \.self) { index in
                            GuessView(guess: $dm.guesses[index])
                                .modifier(Shake(animatableData: CGFloat(dm.incorrectAttempts[index])))
                        }
                    }
                    .frame(width: Global.boardWidth, height: 6 * Global.boardWidth / 5)
                    Spacer()
                    Keyboard()
                        .scaleEffect(Global.keyboardScale)
                        .padding(.top)
                    Spacer()
                }
                .disabled(dm.showStats)
                .navigationBarTitleDisplayMode(.inline)
                .disabled(dm.showStats)
                .overlay(alignment: .top) {
                    if let toastText = dm.toastText {
                        ToastView(toastText: toastText)
                            .offset(y: 20)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            if !dm.inPlay {
                                Button {
                                    dm.newGame()
                                } label: {
                                    Text("New")
                                        .foregroundColor(.primary)
                                }
                                .foregroundColor(.primary)
                            }
                                
                            
                            Button {
                                showHelp.toggle()
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .foregroundColor(.primary)
                            
                            Button {
                                showRewardedAd.toggle()
                            } label: {
                                Image(systemName: "lightbulb")
                            }
                            .foregroundColor(.primary)
                            
                            
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("WORDLE FIGHT")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(dm.hardMode ? Color(.systemRed) : .primary)
                            .minimumScaleFactor(0.5)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                withAnimation {
                                    dm.currentStat = Statistic.loadStat()
                                    dm.showStats.toggle()
                                }
                            } label: {
                                Image(systemName: "chart.bar")
                            }
                            .foregroundColor(.primary)
                            Button {
                                showSettings.toggle()
                            } label: {
                                Image(systemName: "gearshape.fill")
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .presentRewardedAd(isPresented: $showRewardedAd, adUnitId: prodEnvRewardAd) {
                    print("Reward Granted")
                    let currentWord = dm.currentWord
                    let selectedWord = dm.selectedWord
                    var hint = String()
                    
                    if currentWord == "" {
                        hint = "The first character is \(String(selectedWord.prefix(1)))"
                    } else {
                        if currentWord.prefix(1) == selectedWord.prefix(1) {
                            // show 2nd char hint
                            hint = "The first two character is \(String(selectedWord.prefix(2)))"
                        } else {
                            hint = "The first character is \(String(selectedWord.prefix(1)))"
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        dm.showToast(with: hint)
                    }
                    rewardGranted.toggle()
                }
            }
            
            if dm.showStats {
                StatsView()
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(WordleDataModel())
    }
}

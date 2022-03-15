//
//  SettingsView.swift
//  wordlefight
//
//  Created by Ivan Loh on 1/3/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var csManager: ColorSchemeManager
    @EnvironmentObject var dm: WordleDataModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
                    VStack {
                        Toggle("Hard Mode", isOn: $dm.hardMode)
                        Text("Change Theme")
                        Picker("Display Mode", selection: $csManager.colorScheme) {
                            Text("Dark").tag(ColorScheme.dark)
                            Text("Light").tag(ColorScheme.light)
                            Text("System").tag(ColorScheme.unspecified)
                        }
                        .pickerStyle(.segmented)
                        Spacer()
                    }.padding()
                    .navigationTitle("Options")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("**X**")
                            }
                        }
                    }
                }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ColorSchemeManager())
            .environmentObject(WordleDataModel())
    }
}

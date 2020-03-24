//
//  RecordingDetailed.swift
//  Concertino
//
//  Created by Adriano Brandao on 16/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI
import URLImage

struct RecordingWorkPerformers: View {
    var recording: Recording
    @State private var showSheet = false
    @EnvironmentObject var settingStore: SettingStore
    
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Select an action"), message: nil, buttons: [
            .default(Text(self.settingStore.favoriteComposers.contains(composer.id) ? "Remove recording from favorites" : "Add recording to favorites"), action: {
                
                APIpost("\(AppConstants.concBackend)/dyn/user/composer/\(self.settingStore.favoriteComposers.contains(self.composer.id) ? "unfavorite" : "favorite")/", parameters: ["id": self.settingStore.userId, "auth": authGen(userId: self.settingStore.userId, userAuth: self.settingStore.userAuth) ?? "", "cid": self.composer.id]) { results in
                    
                    print(String(decoding: results, as: UTF8.self))
                    
                    DispatchQueue.main.async {
                        let addComposer: AddComposer = parseJSON(results)
                        self.settingStore.favoriteComposers = addComposer.list
                        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.showToast(message: "\(self.settingStore.favoriteComposers.contains(self.composer.id) ? "Added!" : "Removed!")")
                    }
                }
            }),
            .default(Text("Add recording to a playlist"), action: {
                
                APIpost("\(AppConstants.concBackend)/dyn/user/composer/\(self.settingStore.favoriteComposers.contains(self.composer.id) ? "permit" : "forbid")/", parameters: ["id": self.settingStore.userId, "auth": authGen(userId: self.settingStore.userId, userAuth: self.settingStore.userAuth) ?? "", "cid": self.composer.id]) { results in
                    
                    print(String(decoding: results, as: UTF8.self))
                    
                    DispatchQueue.main.async {
                        let addComposer: AddComposer = parseJSON(results)
                        self.settingStore.forbiddenComposers = addComposer.list
                        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.showToast(message: "\(self.settingStore.forbiddenComposers.contains(self.composer.id) ? "Added!" : "Removed!")")
                    }
                }
            }),
            .cancel()
        ])
    }
    
    var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    URLImage(recording.cover ?? URL(fileURLWithPath: AppConstants.concNoCoverImg)) { img in
                        img.image
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                            .cornerRadius(20)
                    }
                    .frame(width: 110, height: 110)
                    .padding(.trailing, 8)
                    
                    VStack(alignment: .leading) {
                        Text(recording.work!.composer!.name.uppercased())
                            .font(.custom("Nunito-ExtraBold", size: 15))
                            .foregroundColor(Color(hex: 0xfe365e))
                        
                        Text(recording.work!.title)
                            .font(.custom("Barlow-SemiBold", size: 16))
                            .padding(.bottom, 4)
                            .lineLimit(20)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Group {
                            if recording.observation != "" && recording.observation != nil {
                                Text(recording.observation ?? "")
                            }
                            else if recording.work!.subtitle != "" && recording.work!.subtitle != nil {
                                Text(recording.work!.subtitle!)
                            }
                        }
                        .font(.custom("Barlow", size: 14))
                        .lineLimit(20)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 18)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        ForEach(self.recording.performers, id: \.name) { performer in
                            Text(performer.name)
                                .font(.custom("Barlow-SemiBold", size: 14))
                            +
                            Text(performer.readableRole)
                                .font(.custom("Barlow", size: 13))
                        }
                        .foregroundColor(.white)
                        
                        Text(recording.label ?? "")
                            .font(.custom("Nunito", size: 11))
                            .padding(.top, 6)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.showSheet = true
                    })
                    {
                        EllipsisButton()
                    }
                }
        }
        .actionSheet(isPresented: $showSheet, content: { self.actionSheet })
    }
}

struct RecordingWorkPerformers_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}

//
//  SettingsView.swift
//  Twitimer
//
//  Created by Brais Moure on 25/8/21.
//

import SwiftUI

struct SettingsView: View {
    
    // Properties
    
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showCloseSessionAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showOnHolidaysAlert = false
    
    // Localization
    
    // Body
    
    var body: some View {
        
        VStack(spacing: Size.none.rawValue) {
            
            VStack(alignment: .leading, spacing: Size.none.rawValue) {
                
                if viewModel.streamer {
                    
                    VStack(alignment: .leading, spacing: Size.small.rawValue) {
                        
                        // Modo vacaciones
                        
                        Text(viewModel.holidayTitleText).font(size: .head).foregroundColor(.textColor).padding(.bottom, Size.medium.rawValue)
                        
                        Toggle(isOn: $viewModel.settings.onHolidays) {
                            Text(viewModel.holidayBodyText).font(size: .subhead).foregroundColor(.textColor).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, Size.mediumBig.rawValue)
                        .toggleStyle(SwitchToggleStyle(tint: Color.primaryColor))
                        .alert(isPresented: $showOnHolidaysAlert) { () -> Alert in
                            Alert(title: Text(viewModel.holidayTitleText), message: Text(viewModel.holidayAlertText), primaryButton: .default(Text(viewModel.okText), action: {
                                
                                viewModel.save()
                                
                            }), secondaryButton: .cancel(Text(viewModel.cancelText), action: {
                                
                                viewModel.settings.onHolidays = false
                                if viewModel.enableSave() {
                                    viewModel.save()
                                }
                            }))
                        }
                        
                        // Social media
                        
                        Text(viewModel.socialMediaText).font(size: .head).foregroundColor(.textColor).padding(.bottom, Size.medium.rawValue)
                        
                        IconTextField(image: "discord", title: $viewModel.settings.discord, placeholder: viewModel.discordPlaceholder)
                        
                        IconTextField(image: "youtube", title: $viewModel.settings.youtube, placeholder: viewModel.youtubePlaceholder)
                        
                        IconTextField(image: "twitter", title: $viewModel.settings.twitter, placeholder: viewModel.twitterPlaceholder)
                        
                        IconTextField(image: "instagram", title: $viewModel.settings.instagram, placeholder: viewModel.instagramPlaceholder)
                        
                        IconTextField(image: "tiktok", title: $viewModel.settings.tiktok, placeholder: viewModel.tiktokPlaceholder)
                    }
                    .padding(EdgeInsets(top: Size.big.rawValue, leading: Size.medium.rawValue, bottom: Size.medium.rawValue, trailing: Size.medium.rawValue))
                    
                } else {
                    
                    // Info
                    
                    viewModel.infoView()
                }
                
                VStack(alignment: .leading, spacing: Size.small.rawValue) {
                    
                    // Delete account
                    
                    Text(viewModel.deleteTitleText).font(size: .head).foregroundColor(.textColor).padding(.top, Size.medium.rawValue).padding(.bottom, Size.medium.rawValue)
                    
                    MainButton(text: viewModel.deleteButtonText, action: {
                        showDeleteAccountAlert.toggle()
                    }, type: .destroy)
                        .alert(isPresented: $showDeleteAccountAlert) { () -> Alert in
                            Alert(title: Text(viewModel.deleteButtonText), message: Text(viewModel.deleteAlertText), primaryButton: .destructive(Text(viewModel.deleteTitleText), action: {
                                
                                viewModel.delete()
                                
                            }), secondaryButton:
                                        .cancel(Text(viewModel.cancelText)))
                        }
                }
                .padding(EdgeInsets(top: Size.none.rawValue, leading: Size.medium.rawValue, bottom: Size.medium.rawValue, trailing: Size.medium.rawValue))
                
                Spacer()
                
            }
            .background(Color.secondaryBackgroundColor)
            .cornerRadius(Size.big.rawValue, corners: [.topRight, .topLeft])
            .shadow(radius: Size.verySmall.rawValue)
            
            // Buttons
            
            HStack(spacing: Size.medium.rawValue) {
                
                MainButton(text: viewModel.closeText, action: {
                    showCloseSessionAlert.toggle()
                }, type: .secondary)
                    .alert(isPresented: $showCloseSessionAlert) { () -> Alert in
                        Alert(title: Text(viewModel.closeText), message: Text(viewModel.closeAlertText), primaryButton: .default(Text(viewModel.okText), action: {
                            
                            viewModel.close()
                            
                        }), secondaryButton: .cancel(Text(viewModel.cancelText)))
                    }
                
                if viewModel.streamer {
                    
                    MainButton(text: viewModel.saveText, action: {

                        if viewModel.saveHolidays() {
                            showOnHolidaysAlert.toggle()
                        } else {
                            viewModel.save()
                        }
                    }, type: .primary).enable(viewModel.enableSave())
                }
                
            }.padding(Size.medium.rawValue)
                .background(Color.backgroundColor)
                .shadow(radius: Size.verySmall.rawValue)
            
        }
        .background(Color.primaryColor)
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarTitle("", displayMode: .inline)
        .ignoresSafeArea(.keyboard, edges: .top)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRouter.view(delegate: nil)
    }
}

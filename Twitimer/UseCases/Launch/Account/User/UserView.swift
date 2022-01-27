//
//  UserView.swift
//  Twitimer
//
//  Created by Brais Moure on 20/4/21.
//

import SwiftUI

struct UserView: View {
    
    // Properties
    
    @ObservedObject var viewModel: UserViewModel
    @State private var isStreamer = false
    @State private var showSaveScheduleAlert = false
    @State private var showSyncScheduleAlert = false
    @State private var showInfoScheduleAlert = false
    
    // Localization
    
    let scheduleText = "schedule".localizedKey
    
    // Body
    
    var body: some View {
        VStack(spacing: Size.none.rawValue) {
            
            if viewModel.hasUser() {
                
                // Header
                
                VStack {
                    viewModel.userView(isStreamer: isStreamer)
                }
                
                // List
                
                VStack(alignment: .leading, spacing: Size.none.rawValue) {
                    
                    HStack {
                        
                        if isStreamer {
                            
                            if !viewModel.onHolidays {
                                Text(viewModel.scheduleText).font(size: .head).foregroundColor(.textColor)
                            }
                            
                            if !viewModel.readOnly && !viewModel.onHolidays {
                                
                                Button(action: {
                                    showSyncScheduleAlert.toggle()
                                }, label: {
                                    Image("calendar-refresh").resizable().renderingMode(.template).foregroundColor(.primaryColor).frame(width: Size.mediumBig.rawValue, height: Size.mediumBig.rawValue)
                                }).alert(isPresented: $showSyncScheduleAlert) { () -> Alert in
                                    Alert(title: Text(viewModel.syncAlertTitleText), message: Text(viewModel.syncAlertBodyText), primaryButton: .default(Text(viewModel.okText), action: {
                                        
                                        viewModel.syncSchedule()
                                        
                                    }), secondaryButton: .cancel(Text(viewModel.cancelText)))
                                }
                            }
                        }
                        
                        if !viewModel.readOnly {
                            
                            Spacer()
                            
                            Toggle(isOn: $isStreamer) {
                                Text(viewModel.streamerText).font(size: .subhead).foregroundColor(.textColor).frame(maxWidth: .infinity, alignment: .trailing)
                            }.toggleStyle(SwitchToggleStyle(tint: Color.primaryColor))
                            .onChange(of: isStreamer) {
                                if viewModel.isStreamer != isStreamer {
                                    let streamer = $0
                                    viewModel.save(streamer: streamer)
                                    if streamer {
                                        showInfoScheduleAlert.toggle()
                                    }
                                }
                            }.alert(isPresented: $showInfoScheduleAlert) { () -> Alert in
                                Alert(title: Text(viewModel.syncInfoAlertTitleText), message: Text(viewModel.syncInfoAlertBodyText), dismissButton: .default(Text(viewModel.okText), action: {
                                    
                                    checkShowScheduleAlert()
                                    
                                }))
                            }
                        }
                        
                    }.padding(Size.medium.rawValue)
                    
                    if !isStreamer {
                        viewModel.infoStreamerView()
                    } else if viewModel.onHolidays {
                        viewModel.infoHolidayView()
                    } else {
                        if viewModel.readOnly && viewModel.schedule.isEmpty {
                            viewModel.emptyView()
                        } else {
                            List {
                                ForEach(Array(viewModel.schedule.enumerated()), id: \.offset) { index, schedule in
                                    ScheduleRowView(type: viewModel.readOnly ? schedule.currentWeekDay : schedule.weekDay,
                                                    enable: $viewModel.schedule[index].enable,
                                                    date: $viewModel.schedule[index].date,
                                                    duration: $viewModel.schedule[index].duration,
                                                    title: $viewModel.schedule[index].title,
                                                    readOnly: viewModel.readOnly)
                                        .hideTableSeparator()
                                }
                            }.listStyle(.plain)
                        }
                    }
                }.background(Color.secondaryBackgroundColor)
                .cornerRadius(Size.big.rawValue, corners: [.topRight, .topLeft])
                .shadow(radius: Size.verySmall.rawValue)
                
                if !viewModel.readOnly {
                    
                    // Buttons
                    
                    HStack(spacing: Size.medium.rawValue) {
                        
                        if isStreamer && !viewModel.onHolidays {
                            
                            MainButton(text: viewModel.saveText, action: {
                                showSaveScheduleAlert.toggle()
                            }, type: .primary)
                            .alert(isPresented: $showSaveScheduleAlert) { () -> Alert in
                                Alert(title: Text(viewModel.saveText), message: Text(viewModel.saveAlertText), primaryButton: .default(Text(viewModel.okText), action: {
                                    
                                    viewModel.save()
                                    
                                }), secondaryButton: .cancel(Text(viewModel.cancelText)))
                            }.enable(viewModel.enableSave())
                            .padding(Size.medium.rawValue)
                        } else {
                            Spacer()
                        }
                    }.if(!isStreamer) { $0.padding(Size.veryExtraSmall.rawValue) }
                    .background(Color.backgroundColor)
                    .shadow(radius: Size.verySmall.rawValue)
                }
            }
        }
        .background(Color.primaryColor).ignoresSafeArea(.container, edges: .top)
        .if(viewModel.readOnly) { $0.edgesIgnoringSafeArea(.bottom) }
        .navigationBarTitle("", displayMode: .inline)
        .ignoresSafeArea(.keyboard, edges: .top)
        .onAppear() {
            isStreamer = viewModel.isStreamer
            checkShowScheduleAlert()
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Image("twitimer_logo").resizable().aspectRatio(contentMode: .fit).frame(height: Size.mediumBig.rawValue)
            }
        }
    }
    
    // MARK: Private
    
    private func checkShowScheduleAlert() {
        
        if isStreamer && !viewModel.readOnly && !viewModel.firstSync() {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.async {
                    showSyncScheduleAlert.toggle()
                    UserDefaultsProvider.set(key: .firstSync, value: true)
                }
            }
        }
    }
    
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserRouter.view(onClose: {
            print("onClose")
        })
    }
}

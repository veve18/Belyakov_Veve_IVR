//
//  UnauthorizedView.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import SwiftUI

enum UnauthorizedStates: String, CaseIterable {
    case title, registration, login, orgLogin, orgReg
}

struct UnauthorizedView: View {
    @State var authState: UnauthorizedStates? = UnauthorizedStates.title
    var body: some View {
        ZStack {
            links
            HewilTopBanner()
            RegisterContent()
            VStack {
                Spacer()
                UnauthorizedButtons(onRegistrationTap: {
                    authState = .registration
                }, onLoginTap: {
                    authState = .login
                })
            }
        }
    }
    
    var links: some View {
        Group {
            NavigationLink("", destination: RegistrationView(authState: $authState).navigationBarBackButtonHidden(true), tag: UnauthorizedStates.registration, selection: $authState)
            NavigationLink("", destination: LoginView(authState: $authState).navigationBarBackButtonHidden(true), tag: UnauthorizedStates.login, selection: $authState)
            NavigationLink("", destination:
                    OrganisationLoginView(authState: $authState)
                    .navigationBarBackButtonHidden(true), tag: UnauthorizedStates.orgLogin, selection: $authState)
            NavigationLink("", destination:
                    OrganisationRegistrationView(authState: $authState)
                    .navigationBarBackButtonHidden(true), tag: UnauthorizedStates.orgReg, selection: $authState)
        }
    }
}

struct UnauthorizedView_Previews: PreviewProvider {
    static var previews: some View {
        UnauthorizedView()
    }
}

fileprivate struct UnauthorizedButtons: View {
    var onRegistrationTap: () -> () = {}
    var onLoginTap: () -> () = {}
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onRegistrationTap) {
                Text("Регистрация")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
                    .padding()
                    .background {
                        Capsule()
                            .fill(Color("ButtonColor"))
                    }
            }.padding(.horizontal)
            HStack(spacing: 4) {
                Text("Уже пользуетесь hewil?")
                Button(action: onLoginTap) {
                    Text("Войдите")
                        .foregroundColor(.blue)
                }
            }.font(.caption)
        }
    }
}

fileprivate struct HewilTopBanner: View {
    var body: some View {
        VStack {
            ZStack {
                Image("paws_cropped")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                Text("hewil")
                    .font(.largeTitle)
                    .bold()
                    .offset(y: -8)
            }
            Spacer()
        }
    }
}

fileprivate struct RegisterContent: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("U・ﻌ・U")
                .font(.largeTitle)
            Text("^｡ᆽ｡^")
                .font(.largeTitle)
            Spacer()
        }
    }
}

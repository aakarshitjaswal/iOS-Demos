//
//  ContentView.swift
//  MaterialSegmentsSwiftUI
//
//  Created by aakarshit on 14/11/23.
//

import SwiftUI

struct ContentView: View {
    @State var segments = ["Profile",
                           "Allergies",
                           "Appointments",
                           "Documents",
                           "Encounters",
                           "Medications",
                           "Notes",
                           "Labs",
                           "Payments",
                           "Prescriptions",
                           "Questionnaires",
                           "Supplements"]
    
    @State var selectedSegment = "Profile"
    @Namespace var animation
    var body: some View {
        ZStack {
            
            VStack {
                
                HStack {
                    Button {
                        
                    } label: {
                        
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 17))
                            .foregroundColor(.green)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    Text("Patient Details")
                        .foregroundColor(.green)
                        .font(.system(size: 17))
                    Spacer()
                    
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding(.trailing)
                    
                }
                .padding(.top)
                
                ScrollViewReader { reader in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            HStack(spacing: 0) {
                                ForEach(segments, id: \.self) { segment in
                                    Button {
                                        withAnimation {
                                            selectedSegment = segment
//                                            reader.scrollTo(segment)
                                            reader.scrollTo(segment, anchor: .center)
                                        }
                                    } label: {
                                            VStack(spacing: 2) {
                                                Text(segment)
                                                    .font(.system(size: 15))
                                                if selectedSegment == segment {
                                                    RoundedRectangle(cornerRadius: 1)
                                                        .frame(height: 2)
                                                        .matchedGeometryEffect(id: "segment", in: animation)
                                                }
                                            }
                                            .foregroundColor(selectedSegment == segment ? .blue : .black)
                                        
                                    }
                                    .accentColor(.primary)
                                 }
                                .padding(.horizontal, 7)
                            }
                        }
                        .scrollIndicators(.hidden)
                        
                    }
                    Spacer()
                }
            }
        }
    }
    
    struct PatientSegment: Hashable {
        let name: String
        var isSelected: Bool = false
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}



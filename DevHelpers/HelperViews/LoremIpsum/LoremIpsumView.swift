//
// File: LoremIpsumView.swift
// Package: DevHelpers
// Created by: Steven Barnett on 09/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct LoremIpsumView: View {
    
    @StateObject var vm: LoremIpsumModel = LoremIpsumModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack {
                    Picker(selection: $vm.generateWhat, label: Text("Generate what?:")) {
                        Text("Word(s)").tag(LoremIpsumOutput.word)
                        Text("Sentence(s)").tag(LoremIpsumOutput.sentence)
                        Text("Paragraph(s)").tag(LoremIpsumOutput.paragraph)
                    }.pickerStyle(RadioGroupPickerStyle())
                }
                VStack {
                    switch vm.generateWhat {
                    case .word:
                        Picker("Word count", selection: $vm.wordCount, content: {
                            ForEach(1..<20) { count in
                                Text("\(count)").tag(count)
                            }
                        }).pickerStyle(.automatic)
                    case .sentence:
                        EmptyView()
                    case .paragraph:
                        EmptyView()
                    }
                }
            }
            
            Button(action: {
                vm.generate()
            }, label: {
                Text("Generate")
            })
            Spacer()
            TextEditor(text: $vm.generatedText)
        }.padding(20)
    }
    
    func testIpsum() {
        
        let generator = LoremIpsumGenerator()
        
        print("------------> Single Word")
        print(generator.word())
        
        print("------------> Five Words")
        print(generator.words(5))
        
        print("------------> Random Count of Words")
        print(generator.words(Int.random(in: 3...9)))

        print("------------> Sentence")
        print(generator.sentence())

        print("------------> Array of Sentences (3)")
        let sents = try? generator.sentences(count: 3)
        for sent in sents! {
            print(sent)
        }

        print("------------> Array of Sentences (random between 2 and 6)")
        let sents2 = try? generator.sentences(count: Int.random(in: 2...6))
        for sent in sents2! {
            print(sent)
        }

        print("------------> Paragraph")
        print(try! generator.paragraph())

        print("------------> Paragraph List (5)")
        let paras = try? generator.paragraphs(5, minSentenceCount: 3, maxSentenceCount: 6)
        for para in paras! {
            print(para)
        }

    }
}

struct LoremIpsumView_Previews: PreviewProvider {
    static var previews: some View {
        LoremIpsumView()
            .frame(width: 400, height: 350)
    }
}

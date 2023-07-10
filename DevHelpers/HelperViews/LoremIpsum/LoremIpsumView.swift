//
// File: LoremIpsumView.swift
// Package: DevHelpers
// Created by: Steven Barnett on 09/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//
        

import SwiftUI

struct LoremIpsumView: View {
    var body: some View {
        Text("Lorem Ipsum Test")
        Button(action: { testIpsum() }, label: { Text("Test it")})
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
    }
}

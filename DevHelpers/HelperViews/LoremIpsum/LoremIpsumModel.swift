//
// File: LoremIpsumModel.swift
// Package: DevHelpers
// Created by: Steven Barnett on 11/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import Foundation

class LoremIpsumModel: ObservableObject {
    
    // MARK: - public, observable properties
    
    // What do we want to generate?
    @Published var generateWhat: LoremIpsumOutput = .word
    
    // Word generation options
    @Published var wordCount: Int = 5
    
    // Sentence generation options
    @Published var sentenceCount: Int = 1
    @Published var sentenceMinWords: Int = 5
    @Published var sentenceMaxWords: Int = 20
    
    // Paragraph generation options
    @Published var paragraphCount: Int = 3
    @Published var paragraphMinSentenceCount: Int = 3
    @Published var paragraphMaxSentenceCount: Int = 7
    
    // Results
    @Published var generatedText: String = ""
    
    // MARK: - private variables
    
    
    // MARK: - public API - generation functions
    public func generate() {
        switch generateWhat {
        case .word:
            generateWords()
        case .sentence:
            generateSentences()
        case .paragraph:
            generateParagraphs()
        }
    }
    
    // MARK: - Private helper functions
    func generateWords() {
        let generator = LoremIpsumGenerator()
        if wordCount == 1 {
            generatedText = generator.word()
            return
        }
        generatedText = generator.words(wordCount).joined(separator: "\n")
    }
    
    func generateSentences() {
        let generator = LoremIpsumGenerator()
        if sentenceCount == 1 {
            generatedText = generator.sentence(minWords: sentenceMinWords, maxWords: sentenceMaxWords)
            return
        }
        generatedText = try! generator.sentences(count: sentenceCount,
                                            minWords: sentenceMinWords,
                                            maxWords: sentenceMaxWords)
                                        .joined(separator: "\n")
    }
    
    func generateParagraphs() {
        let generator = LoremIpsumGenerator()
        if paragraphCount == 1 {
            generatedText = try! generator.paragraph(sentenceCount: sentenceCount,
                                                minWordsInSentence: sentenceMinWords,
                                                maxWordsInSentence: sentenceMaxWords)
            return
        }
        
        generatedText = try! generator.paragraphs(paragraphCount,
                                             minSentenceCount: paragraphMinSentenceCount,
                                             maxSentenceCount: paragraphMaxSentenceCount,
                                             minWordsInSentence: sentenceMinWords,
                                             maxWordsInSentence: sentenceMaxWords)
        .joined(separator: "\n")
    }
}

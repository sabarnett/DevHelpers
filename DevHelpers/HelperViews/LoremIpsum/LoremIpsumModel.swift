//
// File: LoremIpsumModel.swift
// Package: DevHelpers
// Created by: Steven Barnett on 11/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI
import AppKit

class LoremIpsumModel: ObservableObject {
    
    // MARK: - App settings
    @Default(.useClassicFirstLine) private var classicFirstLine
    @Default(.addQuotes) private var addQuotes
    @Default(.doubleSpace) private var doubleSpace

    // MARK: - public, observable properties
    
    // What do we want to generate?
    @Published var generateWhat: LoremIpsumOutput = .word
    
    // Options
    
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
    private var separator: String {
        return doubleSpace ? "\n\n" : "\n"
    }
    
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
    
    public func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(generatedText, forType: .string)
    }
    
    // MARK: - Private helper functions
    func generateWords() {
        let generator = LoremIpsumGenerator()
        if wordCount == 1 {
            generatedText = quotedString(generator.word())
            return
        }
        generatedText = quotedArray(generator.words(wordCount)).joined(separator: separator)
    }
    
    func generateSentences() {
        let generator = LoremIpsumGenerator()
        if sentenceCount == 1 {
            generatedText = quotedString(generator.sentence(minWords: sentenceMinWords, maxWords: sentenceMaxWords, classicFirstLine: classicFirstLine))
            return
        }
        generatedText = quotedArray(try! generator.sentences(count: sentenceCount,
                                            minWords: sentenceMinWords,
                                            maxWords: sentenceMaxWords,
                                            classicFirstLine: classicFirstLine))
                                        .joined(separator: separator)
    }
    
    func generateParagraphs() {
        let generator = LoremIpsumGenerator()
        if paragraphCount == 1 {
            generatedText = quotedString(try! generator.paragraph(sentenceCount: sentenceCount,
                                                minWordsInSentence: sentenceMinWords,
                                                maxWordsInSentence: sentenceMaxWords,
                                                classicFirstLine: classicFirstLine))
            return
        }
        
        generatedText = quotedArray(try! generator.paragraphs(paragraphCount,
                                             minSentenceCount: paragraphMinSentenceCount,
                                             maxSentenceCount: paragraphMaxSentenceCount,
                                             minWordsInSentence: sentenceMinWords,
                                             maxWordsInSentence: sentenceMaxWords,
                                            classicFirstLine: classicFirstLine))
        .joined(separator: separator)
    }
    
    func quotedString(_ str: String) -> String {
        if !addQuotes { return str }
        return "\"\(str)\""
    }
    
    func quotedArray(_ strArray: [String]) -> [String] {
        if !addQuotes { return strArray }
        return strArray.map { quotedString($0) }
    }
}

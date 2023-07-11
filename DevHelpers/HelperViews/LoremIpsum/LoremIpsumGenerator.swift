//
// File: LoremIpsumGenerator.swift
// Package: DevHelpers
// Created by: Steven Barnett on 10/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import Foundation

enum LoremIpsumError: Error {
    case InvalidMinimumWordCount(String)
    case InvalidMaximumWordCount(String)
    case InvalidSentenceCount(String)
    case InvalidParagraphCount(String)
    case InvalidParagraphSentenceCount(String)
}

enum LoremIpsumOutput {
    case word
    case sentence
    case paragraph
}

class LoremIpsumGenerator {
    
    public var wordSeparator: String = " "
    public var sentenceSeparator: String = "  "
    
    private let words = [
         // Lorem ipsum... These are the classic few start words. We need these up front
         "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",

         // and these are a bunch of other random words that we can use
         "a", "ac", "accumsan", "ad", "aenean", "aliquam", "aliquet", "ante",
         "aptent", "arcu", "at", "auctor", "augue", "bibendum", "blandit",
         "class", "commodo", "condimentum", "congue", "consequat", "conubia",
         "convallis", "cras", "cubilia", "curabitur", "curae", "cursus",
         "dapibus", "diam", "dictum", "dictumst", "dignissim", "dis", "donec",
         "dui", "duis", "efficitur", "egestas", "eget", "eleifend", "elementum",
         "enim", "erat", "eros", "est", "et", "etiam", "eu", "euismod", "ex",
         "facilisi", "facilisis", "fames", "faucibus", "felis", "fermentum",
         "feugiat", "finibus", "fringilla", "fusce", "gravida", "habitant",
         "habitasse", "hac", "hendrerit", "himenaeos", "iaculis", "id",
         "imperdiet", "in", "inceptos", "integer", "interdum", "justo",
         "lacinia", "lacus", "laoreet", "lectus", "leo", "libero", "ligula",
         "litora", "lobortis", "luctus", "maecenas", "magna", "magnis",
         "malesuada", "massa", "mattis", "mauris", "maximus", "metus", "mi",
         "molestie", "mollis", "montes", "morbi", "mus", "nam", "nascetur",
         "natoque", "nec", "neque", "netus", "nibh", "nisi", "nisl", "non",
         "nostra", "nulla", "nullam", "nunc", "odio", "orci", "ornare",
         "parturient", "pellentesque", "penatibus", "per", "pharetra",
         "phasellus", "placerat", "platea", "porta", "porttitor", "posuere",
         "potenti", "praesent", "pretium", "primis", "proin", "pulvinar",
         "purus", "quam", "quis", "quisque", "rhoncus", "ridiculus", "risus",
         "rutrum", "sagittis", "sapien", "scelerisque", "sed", "sem", "semper",
         "senectus", "sociosqu", "sodales", "sollicitudin", "suscipit",
         "suspendisse", "taciti", "tellus", "tempor", "tempus", "tincidunt",
         "torquent", "tortor", "tristique", "turpis", "ullamcorper", "ultrices",
         "ultricies", "urna", "ut", "varius", "vehicula", "vel", "velit",
         "venenatis", "vestibulum", "vitae", "vivamus", "viverra", "volutpat",
         "vulputate",
     ]
    
    // MARK: - Words
    
    /// Returns a single random word. The word will be lowercase.
    public func word() -> String {
        words.randomElement() ?? ""
    }
    
    /// Returns an array of words up to the specified word count
    ///
    /// - Parameter count: The number of words to be returned. Defaults to 5.
    ///
    /// - Returns: An array of single words. All words will be lowercase.
    public func words(_ count: Int = 5) -> [String] {
        var wordList: [String] = []
        
        for _ in 0..<count {
            wordList.append(word())
        }
            
        return wordList
    }
    
    // MARK: - Sentences
    
    /// Returns a single sentence. The number of words in the sentence will be some
    /// random number between 5 and 20 words.
    ///
    /// - Parameters:
    ///   - minWords: The minimum number of words in a sentence. The default is 5 words. You must specify a value between 1 and 10
    ///   and the number must be smaller than the maximum number of words.
    ///   - maxWords: The maximum number of words in a sentence. This defaults to 20. If specified, you must provide a value between
    ///   5 and 50 and the number must be larger than the minimum word count.
    ///
    /// - Returns: An string representing the generated sentence. A sentence will have an
    /// initial capital letter, a trailing full stop and may contain one or more commas.
    public func sentence(minWords: Int = 5, maxWords: Int = 20) -> String {
        try! sentences(count: 1, minWords: minWords, maxWords: maxWords).first ?? ""
    }
    
    /// Returns an array of sentences.
    ///
    /// - Parameters:
    ///   - count: Specifies the number of sentences we want. This can be a value between 1 and 15. It defaults to 3.
    ///   - minWords: The minimum number of words in a sentence. The default is 5 words. You must specify a value between 1 and 10
    ///   and the number must be smaller than the maximum number of words.
    ///   - maxWords: The maximum number of words in a sentence. This defaults to 20. If specified, you must provide a value between
    ///   5 and 50 and the number must be larger than the minimum word count.
    ///
    /// - Returns: An array of strings representing the sentences generated. A sentence will have an
    /// initial capital letter, a trailing full stop and may contain one or more commas.
    public func sentences(count: Int = 3, minWords: Int = 5, maxWords: Int = 20) throws -> [String] {
        var sentenceList: [String] = []
        
        guard count >= 1, count <= 15 else {
            throw LoremIpsumError.InvalidSentenceCount("Invalid sentence count. Count must nbe between 3 and 15.")
        }
        guard minWords >= 1, minWords <= 10 else {
            throw LoremIpsumError.InvalidMinimumWordCount("Value must be between 1 and 10.")
        }
        guard maxWords >= 5, maxWords <= 50, maxWords > minWords else {
            throw LoremIpsumError.InvalidMaximumWordCount("Value mjust be between 5 and 50 and greater than the minumun.")
        }
        
        for _ in 0..<count {
            let words = words(Int.random(in: minWords..<maxWords)).joined(separator: wordSeparator)
            sentenceList.append(punctuate(words))
        }
        
        return sentenceList
    }
    
    // MARK: - Paragraphs
    
    /// Returns a paragraph consisting of a number of sentences separated by two spaces.
    ///
    /// - Parameters:
    ///   - sentenceCount: The number of sentences to include in the paragraph. You can specify a number between 2 and
    /// 10. The default number of sentences will be 3.
    ///   - minWordsInSentence: The minimum number of words in a sentence. The default is 5 words. You must specify a value between 1 and 10
    ///   and the number must be smaller than the maximum number of words.
    ///   - maxWordsInSentence: The maximum number of words in a sentence. This defaults to 20. If specified, you must provide a value between
    ///   5 and 50 and the number must be larger than the minimum word count.
    ///
    /// - Returns: A string that consists of the requested number of sentences. Sentences will be separated by two spaces. Each sentence
    /// will have between 5 and 20 words. You can override this.
    public func paragraph(sentenceCount: Int = 3, minWordsInSentence: Int = 5, maxWordsInSentence: Int = 20) throws -> String {
        
        guard sentenceCount >= 2, sentenceCount <= 10 else {
            throw LoremIpsumError.InvalidSentenceCount("Sentence count must be between 1 and 15")
        }
        
        let sentences = try sentences(count: sentenceCount, minWords: minWordsInSentence, maxWords: maxWordsInSentence)
        return sentences.joined(separator: sentenceSeparator)
    }
    
    /// Returns an array of paragraphs.
    ///
    /// - Parameters:
    ///   - count: The number of paragraphs you want. This can be between 1 and 15.
    ///   - minSentenceCount: The minum number of sentences in a paragraph. This defaults to 3 and can be any value
    ///   in the range 1 to 10. It must be less than the maxmun sentence count.
    ///   - maxSentenceCount: The maximm number of sentences in a paragraph. This defaults to 7 and can be any value
    ///   in the range 3 to 15. It must be more than the minimum sentence count.
    ///   - minWordsInSentence: The minimum number of words in a sentence. This defaults to 5.
    ///   - maxWordsInSentence: The maximum number of words in a sentence. This defaults to 20.
    ///
    /// - Returns: An array of paragraphs.
    public func paragraphs(_ count: Int = 3,
                           minSentenceCount: Int = 3, maxSentenceCount: Int = 6,
                           minWordsInSentence: Int = 5, maxWordsInSentence: Int = 20) throws -> [String] {
        var paragraphs: [String] = []
        
        guard count >= 1, count <= 15 else {
            throw LoremIpsumError.InvalidParagraphCount("Paragraph count must be between 1 and 15")
        }
        guard minSentenceCount >= 1, minSentenceCount <= 10 else {
            throw LoremIpsumError.InvalidParagraphSentenceCount("The minimum sentence count must be between 1 and 10")
        }
        guard maxSentenceCount >= 3, maxSentenceCount <= 15, maxSentenceCount >= minSentenceCount else {
            throw LoremIpsumError.InvalidParagraphSentenceCount("The maximum sentence count must be between 3 and 15 and must be greater than the minimum count")
        }
        
        for _ in 0..<count {
            paragraphs.append(try paragraph(sentenceCount: Int.random(in: minSentenceCount..<maxSentenceCount),
                                            minWordsInSentence: minWordsInSentence,
                                            maxWordsInSentence: maxWordsInSentence))
        }
        
        return paragraphs
    }
    
    // MARK: - Private helper functions
    
    private func punctuate(_ startSentence: String) -> String {
        
        // Add trailing full stop
        var sentence = startSentence.trimmingCharacters(in: .whitespacesAndNewlines) + "."

        // Uppercase the first letter
        let firstLetter = sentence.prefix(1).capitalized
        let remainingLetters = sentence.dropFirst()
        sentence = firstLetter + remainingLetters
        
        // Add commas
        var words = sentence.split(separator: wordSeparator, omittingEmptySubsequences: true)
        let wordCount = words.count
        if wordCount < 9 {
            // Short sentences don't get commas added.
            return sentence
        }
        
        // Bit naff, but we'll be adding a comma a quarter of the way in. If the remaining string is
        // long enough (7 or more words), we add a second comma 60% of the way through the remaining
        // words.
        let firstComma = Int(wordCount / 4)
        
        words[firstComma] = words[firstComma] + ","
        if wordCount - firstComma >= 7 {
            let secondComma = Int(Double(wordCount - firstComma) * 0.6)
            words[firstComma + secondComma] = words[firstComma + secondComma] + ","
        }
        
        return words.joined(separator: wordSeparator)
    }
}

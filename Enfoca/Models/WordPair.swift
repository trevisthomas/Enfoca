//
//  WordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class WordPairWrapper {
    init(){
        
    }
    
    init(_ wordPair: WordPair) {
        self.wordPair = wordPair
    }
    var wordPair : WordPair?
}

class WordPair : Hashable {
    static let formatter = Formatter()
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: WordPair, rhs: WordPair) -> Bool {
        return lhs.pairId == rhs.pairId
    }
    
    var hashValue: Int {
        return pairId.hashValue
    }

    
//    private(set) var pairId: AnyHashable
    private(set) var pairId: String
    private(set) var word: String
    private(set) var definition: String
    private(set) var dateCreated: Date
    private(set) var gender: Gender
    private(set) var example: String?
    private(set) var tags : [Tag] = []
    
    
    
//    private String word;
//    private String definition;
//    private Date createDate = new Date();
//    private Date lastUpdate = new Date();
//    private long testedCount;
//    private long correctCount;
//    private long incorrectCount;
//    private double difficulty;
//    private String id;
//    private String user;
//    private long displayOrder;
//    private List<Tag> tags = new ArrayList<>();
//    private boolean active = false;
//    private boolean deleteAllowed;
//    private long averageTime;
//    private String example;
//    
//    private double confidence;
//    private long totalTime;
//    private long timedViewCount;
    
    init (pairId: String, word: String, definition: String, dateCreated: Date = Date(), gender: Gender = .notset, tags : [Tag] = [], example: String? = nil) {
        self.pairId = pairId
        self.word = word
        self.definition = definition
        self.dateCreated = dateCreated
        self.gender = gender
        self.tags = tags
        self.example = example
    }
    
    func addTag(_ tag : Tag) {
        tags.append(tag)
        tags.sort { (t1:Tag, t2:Tag) -> Bool in
            return t1.name < t2.name
        }
    }
    
    func remove(tag: Tag) -> Tag? {
        guard let index = tags.index(of: tag) else {
            return nil
        }
        return tags.remove(at: index)
    }
    
    public init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        
        
        guard let pairId = jsonResult["pairId"] as? String else {fatalError()}
        guard let word = jsonResult["word"] as? String else {fatalError()}
        guard let definition = jsonResult["definition"] as? String else {fatalError()}
        
        guard let dateString = jsonResult["dateCreated"] as? String else {fatalError()}
        guard let genderString = jsonResult["gender"] as? String else { fatalError() }
        
        guard let dateCreated = WordPair.formatter.dateFormatter.date(from: dateString) else {fatalError()}
        let gender = Gender.fromString(genderString)
        
        
        
        self.pairId = pairId
        self.word = word
        self.definition = definition
        self.dateCreated = dateCreated
        self.gender = gender
        self.example = jsonResult["example"] as? String
        
    }
    
    public func toJson() -> String {
        var representation = [String: AnyObject]()
        
        representation["pairId"] = pairId as AnyObject?
        representation["word"] = word as AnyObject?
        representation["definition"] = definition as AnyObject?
        let dateString = WordPair.formatter.dateFormatter.string(from: dateCreated)
        representation["dateCreated"] = dateString as AnyObject?
        representation["gender"] = gender.toString() as AnyObject?
        representation["example"] = example as AnyObject?
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }
}

extension WordPair {
    
    
}

class Formatter {
    let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
}

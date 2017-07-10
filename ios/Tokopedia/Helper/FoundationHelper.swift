//
//  FoundationHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 3/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

extension NSDate {
    static func convertDateString(_ string: String, fromFormat format1: String, toFormat format2: String ) -> String{
        let dtf: DateFormatter = DateFormatter()
        
        //Need to add local and timezone for iOS above 8.1
        let Locale:Foundation.Locale=Foundation.Locale(identifier: "id_ID")
        dtf.locale=Locale
        dtf.timeZone = TimeZone(identifier: "GMT")
        
        dtf.dateFormat = format1
        let date: Date = dtf.date(from: string)!
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = format2
        let result = dateFormat.string(from: date)
        return result
    }
    
    func timeStamp() -> String {
        let myDateString = String(Int64(self.timeIntervalSince1970*1000))
        return "\(myDateString)"
    }
    
    func stringWithFormat(_ dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self as Date)
    }
}

extension String {
    func bolded(last numOfWords:Int) -> NSAttributedString {
        let num = numOfWords > self.characters.count ? self.characters.count : numOfWords
        let attributedString = NSMutableAttributedString(string: self, attributes: [NSFontAttributeName: UIFont.microTheme()])
        
        let boldFontAttribute: [String:Any] = [
            NSFontAttributeName: UIFont.microThemeSemibold(),
            NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()
        ]
        
        let delimiter = " "
        let stringArray = self.components(separatedBy: delimiter)
        let nsString = self as NSString
        for boldString in stringArray.suffix(num) {
            let delCharSet = CharacterSet(charactersIn: "(.)")
            let trimedString = boldString.trimmingCharacters(in: delCharSet)
            attributedString.addAttributes(boldFontAttribute, range: nsString.range(of: trimedString))
        }
        
        return attributedString
    }
}

extension NSString {
    func withNumberFormat() ->  NSString {
        let result = NSMutableString(string: self)
        
        var n = self.length
        while n - 3 > 0 {
            result.insert(".", at: n - 3)
            n -= 3
        }
        return result
    }
    
    public var trimWhitespace: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    public var escape: String {
        let legalURLCharactersToBeEscaped = CharacterSet(charactersIn: ":/?&=;+!@#$()',*")
        return self.addingPercentEncoding(withAllowedCharacters: legalURLCharactersToBeEscaped)!
    }
    
    /// Check whether given email address is valid or not.
    func isValidEmailAddress(strict: Bool = true) -> Bool {
        let stricterFilterString = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let laxString = ".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        let emailRegex = strict ? stricterFilterString : laxString
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: self)
    }
    
    func getTextHeight(_ width: CGFloat, font: UIFont) -> CGFloat {
        var size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let frame = (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil)
        size = CGSize(width: frame.width, height: frame.height)
        
        return round(size.height) + 1
    }
    
    func getNumberOfLines(_ width: CGFloat, font: UIFont) -> Int {
        return Int(self.getTextHeight(width, font: font) / font.lineHeight)
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
}

extension NSDictionary {
    var json: String {
        let invalidJson = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
            return String(data: jsonData,
                          encoding: String.Encoding.ascii) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}

extension Dictionary {
    mutating func update(_ other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}


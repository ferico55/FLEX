//
//  Paging.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//
import Foundation
import Unbox
import RestKit

@objc(Paging)
final class Paging:NSObject, Unboxable {
    public var uri_next = ""
    public var uri_previous = ""
    public var uriNext:URL? {
        get {
            return URL(string: uri_next)
        }
    }
    public var uriPrevious:URL? {
        get {
            return URL(string: uri_previous)
        }
    }
    public var isShowNext : Bool {
        get {
            if uri_next == "0" || uri_next == "" {
                return false
            }
            return true
        }
    }
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: ["header","message_error", "uri_next"])
        return mapping
    }
    
    static func mappingForWishlist() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: self.attributeMappingDictionaryForWishlist())
        return mapping
    }
    
    static func attributeMappingDictionary() -> [AnyHashable: String] {
        return ["uri_next" : "uri_next",
                "uri_previous": "uri_previous"]
    }
    
    static func attributeMappingDictionaryForWishlist() -> [AnyHashable: String] {
        return ["next_url": "uri_next"]
    }
    
    func encodeWithCoder(encoder:NSCoder) {
        encoder.encode(self.uri_next, forKey: "uri_next")
    }
    
    override init() { super.init() }
    
    init(withDecoder: NSCoder) {
        super.init()
        self.uri_next = withDecoder.decodeObject(forKey: "uri_next") as! String
    }
    
    init(uri_previous:String, uri_next:String) {
        self.uri_previous = uri_previous
        self.uri_next = uri_next
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            uri_previous : try unboxer.unbox(keyPath: "uri_previous"),
            uri_next : try unboxer.unbox(keyPath: "uri_next")
        )
    }
}

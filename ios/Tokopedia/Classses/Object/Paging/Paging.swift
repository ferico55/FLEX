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
    private var _uri_next : String?
    public var uri_next : String? {
        get {
            return self._uri_next
        }
        set {
            if newValue == "0" {
                self._uri_next = nil
                return
            }
            self._uri_next = newValue
        }
    }
    public var uri_previous = ""
    public var uriNext:URL? {
        get {
            guard let uri = uri_next else { return nil }
            return URL(string: uri)
        }
    }
    public var uriPrevious:URL? {
        get {
            return URL(string: uri_previous)
        }
    }
    public var isShowNext : Bool {
        get {
            return uri_next != nil
        }
    }
    
    var nextPage: Int? {
        get {
            guard let uri = uri_next else { return nil }
            return Int(TokopediaNetworkManager.getPageFromUri(uri)!)
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
        super.init()
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

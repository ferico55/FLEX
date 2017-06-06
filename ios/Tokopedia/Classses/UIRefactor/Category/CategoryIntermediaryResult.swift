//
//  CategoryIntermediaryChild.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class CategoryIntermediaryResult: NSObject, Unboxable {
    var children: [CategoryIntermediaryChild]!
    var nonHiddenChildren: [CategoryIntermediaryChild]!

    var nonExpandedChildren: [CategoryIntermediaryChild]!
    var maxRowInCategorySubView: Int = 3
    var id: String = ""
    var name: String = ""
    var categoryDescription: String = ""
    var titleTag: String = ""
    var metaDescription: String = ""
    var headerImage:String? = ""
    var hidden: Int = 0
    // views digunakan untuk penanda apakah list produk dari intermediary ditampilkan secara grid, list, atau one
    var views: Int = 0
    var isRevamp: Bool = false
    var isIntermediary: Bool = false
    var curatedProduct: CategoryIntermediaryCuratedProduct?
    var banner: CategoryIntermediaryBanner?
    var video: CategoryIntermediaryVideo?

    // rootCategoryId used for tracking needs
    var rootCategoryId: String = ""
    
    init(children: [CategoryIntermediaryChild],
      curatedProduct: CategoryIntermediaryCuratedProduct?,
      id: String,
      name:String,
      hidden:Int,
      categoryDescription: String,
      titleTag: String,
      metaDescription:String,
      headerImg:String?,
      views:Int,
      isRevamp: Bool,
      isIntermediary :Bool,
    banner: CategoryIntermediaryBanner,
    video: CategoryIntermediaryVideo) {
        self.children = children
        self.curatedProduct = curatedProduct
        self.id = id
        self.name = name
        self.hidden = hidden
        self.categoryDescription = categoryDescription
        self.titleTag = titleTag
        self.metaDescription = metaDescription
        self.headerImage = headerImg ?? ""
        self.views = views
        self.isRevamp = isRevamp
        self.isIntermediary = isIntermediary
        self.banner = banner
        self.video = video
    }
    
    convenience init(unboxer: Unboxer) throws {
        self.init(
            children : try unboxer.unbox(keyPath: "result.child"),
            curatedProduct : try? unboxer.unbox(keyPath: "result.curated_product") as CategoryIntermediaryCuratedProduct,
            id : try unboxer.unbox(keyPath: "result.id"),
            name : try unboxer.unbox(keyPath: "result.name"),
            hidden : try unboxer.unbox(keyPath: "result.hidden") as Int,
            categoryDescription : try unboxer.unbox(keyPath: "result.description"),
            titleTag : try unboxer.unbox(keyPath: "result.title_tag"),
            metaDescription : try unboxer.unbox(keyPath: "result.meta_description"),
            headerImg : try? unboxer.unbox(keyPath: "result.header_image") as String,
            views : try unboxer.unbox(keyPath: "result.view"),
            isRevamp : try unboxer.unbox(keyPath: "result.is_revamp"),
            isIntermediary : try unboxer.unbox(keyPath: "result.is_intermediary"),
            banner : try unboxer.unbox(keyPath: "result.banner") as CategoryIntermediaryBanner,
            video : try unboxer.unbox(keyPath: "result.video") as CategoryIntermediaryVideo

        )
        nonHiddenChildren =  children.filter { (child) in
            return child.hidden == 0
        }
        
        nonExpandedChildren = nonHiddenChildren.enumerated().filter { (index, child) in
                if self.isRevamp {
                    return index < 9
                } else {
                    return index < 6
                }
            }
            .map { (index, child) in
                    return child
            }
        maxRowInCategorySubView = isRevamp ? 3 : 2
        rootCategoryId = try unboxer.unbox(keyPath: "result.root_category_id")
        
    }
}

//
//  DigitalCategoryListViewController.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 7/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RestKit

class DigitalCategoryListViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tpBackground()
        requestCategory()
    }
    
    private func requestCategory() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString.mojitoUrl(), path: "/api/v1/layout/category", method: .GET, parameter: nil, mapping: HomePageCategoryResponse.mapping(), onSuccess: { [weak self] mappingResult, _ in
            guard let `self` = self else { return }
            let result: NSDictionary = (mappingResult as RKMappingResult).dictionary() as NSDictionary
            let homePageCategoryResponse: HomePageCategoryResponse = result[""] as! HomePageCategoryResponse
            let categories = homePageCategoryResponse.data.layout_sections.first {$0.id == "4"}?.layout_rows ?? []
            let grid = DigitalCategoriesComponentView(categories: categories)
            self.view.addSubview(grid)
            grid.render(in: self.view.bounds.size)
            
        }, onFailure: { [weak self] error in
            let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
            stickyAlertView?.show()
        })
    }
}

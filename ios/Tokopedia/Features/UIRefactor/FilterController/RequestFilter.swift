//
//  RequestFilter.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import Moya
import Unbox

class RequestFilter: NSObject {
    
    var source: Source! = .default
    
    func fetchFilter(_ source: Source, departmentID: String, onSuccess: @escaping ((_ response:FilterData) -> Void), onFailure:@escaping (()->Void)) {
        self.source = source
        
        let requestFilter = source == .replacement ? self.fetchFilterReplacement() : self.fetchFilterDynamic(departmentID: departmentID)
        var filterData : FilterData!
        
        requestFilter
        .flatMap({ (data) -> Observable<[ListOption]> in
                
            filterData = data
            if self.isNeedToRequestCategory(for: filterData.filter){
                return self.fetchCategory(departmentID)
            }
            return Observable.just(self.categories(from: filterData.filter))
        }).subscribe(onNext: { (categories) in
            filterData.filter.forEach({ (filter) in
                if (filter.title == "Kategori" && filter.options.count == 0) {
                    filter.options = self.categoryWithAddingAllTypeChildFromCategory(categories)
                }
            })
            onSuccess(filterData)
            
        }, onError: { (error) in
            
            onFailure()
            
        }).disposed(by: rx_disposeBag)

    }
    
    func isNeedToRequestCategory(for filters:[ListFilter]) -> Bool {
        let listTitles = filters.map{$0.title}
        return listTitles.contains("Kategori") && self.categories(from: filters).count == 0
    }
    
    func categories(from filters:[ListFilter]) -> [ListOption] {
        let categories = filters.filter({ (filter) -> Bool in
            filter.title == "Kategori"
        }).first?.options
        
        return self.itemsWithParentId(for: categories ?? [])
    }
    
    func fetchCategory(_ id: String) -> Observable<[ListOption]> {
        let provider = HadesProvider()
        return provider
            .request(.getFilterCategories(categoryId: ""))
            .map {result in
                let response = try? result.map(to: CategoryData.self, fromKey: "result")
                return response?.categories ?? []
            }
            .map({ categories in
                self.itemsWithParentId(for: categories)
            })
            .retry(3)
    }
    
    func fetchFilterDynamic(departmentID: String) -> Observable<FilterData> {
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            networkManager.request(
                withBaseUrl: NSString.aceUrl(),
                path:"/v1/dynamic_attributes",
                method: .GET,
                parameter: ["source": self.source.description(), "sc" : departmentID],
                mapping: FilterResponse.mapping(),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : FilterResponse = result[""] as! FilterResponse

                    observer.onNext(response.data)
                    observer.onCompleted()
                    
            }, onFailure: { (error) in
                observer.onError(RequestError.networkError)
            })
            return Disposables.create()
        })
    }
    
    func itemsWithParentId(for items:[ListOption]) -> [ListOption] {
        for item in items {
            guard let itemChilds = item.child else { break }
            for childItem in itemChilds {
                childItem.parent = item.categoryId;
                guard let lastItemChilds = childItem.child else { break }
                for lastItem in lastItemChilds {
                    lastItem.parent = childItem.categoryId;
                }
            }
        }
        return items
    }
    
    func categoryWithAddingAllTypeChildFromCategory(_ categories:[ListOption]) -> [ListOption]{
        guard source != .replacement else { return categories }
        //add "Semua <kategory>"
        for category in categories {
            for categoryChild in category.child ?? [] {
                if categoryChild.tree != "3" {
                    categoryChild.child?.insert(self.newAllCategory(categoryChild), at: 0)
                }
            }
            if category.tree != "3" {
                category.child?.insert(self.newAllCategory(category), at: 0)
            }
        }
        
        return categories
    }
    
    func newAllCategory(_ category:ListOption) -> ListOption {
        let newCategory : ListOption = ListOption();
        newCategory.categoryId = category.categoryId;
        newCategory.name = "Semua \(category.name)"
        if let categoryTree = category.tree {
            let tree: Int = Int(categoryTree)!
            newCategory.tree = "\(tree+1)"
        }
        newCategory.child = nil
        newCategory.isNewCategory = true
        newCategory.parent = category.categoryId
        return newCategory
    }
    
    func fetchFilterReplacement() -> Observable<FilterData> {
        return Observable.create({ (observer) -> Disposable in
            let auth = UserAuthentificationManager()
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            networkManager.request(
                withBaseUrl: NSString.v4Url(),
                path:"/v4/order/replacement/category",
                method: .GET,
                parameter: ["shop_id" : auth.getShopId()],
                mapping: FilterResponse.mapping(),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : FilterResponse = result[""] as! FilterResponse
                    
                    observer.onNext(response.data)
                    observer.onCompleted()
                    
            }, onFailure: { (error) in
                observer.onError(RequestError.networkError)
            })
            return Disposables.create()
        })
    }
}

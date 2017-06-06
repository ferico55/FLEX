//
//  WishlistTest
//  Tokopedia
//
//  Created by Ferico Samuel on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

@testable import Tokopedia

class WishlistTest: XCTestCase {
    
    var result:ProductWishlistCheckResult = ProductWishlistCheckResult(ids: [])
//    var r2:SearchProductWrapper = SearchProductWrapper(status: "", server_process_time: "", header: EnvelopeHeader(), data: SearchProductResult(search_url: "", share_url: "", st: "", has_catalog: "", products: [], redirect_url: "", department_id: ""))
    
    override func setUp() {
        super.setUp()
        
    }
    
    func testRequest() {
//        MojitoProvider()
//            .request(.getProductWishStatus(userId: "8470985", productIds: ["111663653","111663612","574351"]))
//            .map(to: ProductWishlistCheckResult.self)
//            .do(
//                onNext: { [weak self] id in
//                    print("asdf")
//                    print(id)
//                },
//                onError: { error in
//                    print("error")
//                }
//            )
//            .subscribe(onNext: {[weak self] id in
//                print("asdf")
//                print(id)
//                },
//                onError: { [] error in
//                    print(error)
//                }
//            ).disposed(by: self.rx_disposeBag)
        
        AceProvider()
            .request(.searchProduct(selectedCategoryString: "79", rows: "12", start: "0", q: "", uniqueID: "1b758eb15e3a51eb290dffcdf55062e2", source: "directory", departmentName: "Fashion & Aksesoris"))
            .map(to: SearchProductWrapper.self)
            .do(
                onNext: { [weak self] id in
                    print("asdf")
                    print(id)
                },
                onError: { error in
                    print("error")
            }
            )
            .subscribe(onNext: {[weak self] id in
                print("asdf")
                print(id)
                },
                       onError: { [] error in
                        print(error)
            }
            ).disposed(by: self.rx_disposeBag)
        
        sleep(30)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

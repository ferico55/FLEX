//
//  ProductTabPage.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class ProductTabPage : MyShopPage {
    let myshop = MyShopPage()
    let productSearchBar = app.searchFields["Cari Produk"]
    let productSearchButton = app.buttons["Search"]
    let sortButton = app.buttons["sortButton"]
    let sortByNewest = app.tables.staticTexts["Harga Tertinggi"]
    let sortNavBar = app.navigationBars["Urutkan"]
    let filterButton = app.buttons["filterButton"]
    let filterEtalaseField = app.tables.staticTexts["Etalase"]
    let filterEtalaseChoice = app.tables.staticTexts["Stok Kosong"]
    let filterEtalaseNavBar = app.navigationBars["Etalase"]
    let filterCategoryField = app.tables.staticTexts["Kategori"]
    let filterCategoryChoice = app.tables.staticTexts["Semua Kategori"]
    let filterCategoryNavBar = app.navigationBars["Pilih Kategori"]
    let filterCatalogField = app.tables.staticTexts["Katalog"]
    let filterCatalogChoice = app.tables.staticTexts["Tanpa Katalog"]
    let filterFreeNavBar = app.navigationBars["Filter"]
    let filterGambarField = app.tables.staticTexts["Gambar"]
    let filterGambarChoice = app.tables.staticTexts["Dengan Gambar"]
    let filterKondisiField = app.tables.staticTexts["Kondisi"]
    let filterKondisiChoice = app.tables.staticTexts["Baru"]
    let productList = app.tables.cells.matching(identifier: "productList").element(boundBy: 0)
    //let productList = app.tables["productList"].cells.element(boundBy: 0)
    //let productList = app.tables.cells.element(boundBy: 1)
    let setWareHouseButton = app.cells.buttons["swipeWarehouse"]
    let setWarehouseAlert = app.alerts["Apakah stok produk ini kosong?"]
    let setActiveButton = app.cells.buttons["swipeEtalase"]
    let setActiveAlert = app.alerts["Apakah stok produk ini tersedia?"]
    let etalaseNavBar = app.navigationBars["Etalase"]
    let setDeleteButton = app.cells.buttons["swipeDelete"]
    let setDeleteAlert = app.alerts["Hapus Produk"]
    let setDuplicateButton = app.cells.buttons["swipeDuplicate"]
    let addImageProductButton = app.tables.buttons["icon upload image"]
    let productNameField = app.tables.cells.containing(.staticText, identifier:"Nama Produk").children(matching: .textField).element
    let duplicateNext1 = app.navigationBars["Salin Produk"].buttons["Lanjut"]
    let duplicateNext2 = app.navigationBars["Salin Produk"].buttons["Simpan"]
    let emptyMyProduct = app.tables["Toko Anda belum mempunyai produk, Segera tambahkan produk ke toko Anda!"]
    let produkNavBar = app.navigationBars["Produk"]
    let imagePickerButton = app.collectionViews.children(matching: .cell).element(boundBy: 3).children(matching: .other).element
    let imagePickerNavBar = app.navigationBars.buttons["Selesai(1)"]
    let newProductNameField = app.tables.textFields["Nama Produk"]
    let categoryField = app.tables.staticTexts["Pilih Kategori"]
    let choosenCategory = app.tables.staticTexts["Produk Lainnya"]
    let chooseCategoryNavBar = app.navigationBars["Pilih Kategori"]
    let priceField = app.tables.children(matching: .cell).element(boundBy: 6).textFields["0"]
    let weightField = app.tables.children(matching: .cell).element(boundBy: 8).textFields["0"]
    let addNext1 = app.navigationBars["Tambah Produk"].buttons["Lanjut"]
    let chooseEtalase = app.tables.staticTexts["Pilih Etalase"]
    let choosedEtalase = app.tables.cells.element(boundBy: 0)
    let addProductNavBar = app.navigationBars["Tambah Produk"]
    let addNext2 = app.navigationBars["Tambah Produk"].buttons["Simpan"]
    
    
    
    func searchProductTab(){
        waitFor(element: productSearchBar, status: .Exists)
        productSearchBar.tap()
        productSearchBar.typeText("hgf")
        productSearchButton.tap()
    }
    
    func sortProductTab(){
        waitFor(element: sortButton, status: .Exists)
        sortButton.tap()
        sortByNewest.tap()
        sortNavBar.buttons["Selesai"].tap()
    }
    
    func filterProductTab(){
        waitFor(element: filterButton, status: .Exists)
        filterButton.tap()
        filterEtalaseField.tap()
        filterEtalaseChoice.tap()
        filterEtalaseNavBar.buttons["Selesai"].tap()
        filterCategoryField.tap()
        waitFor(element: filterCategoryChoice, status: .Exists)
        filterCategoryChoice.tap()
        filterCategoryNavBar.buttons["Selesai"].tap()
        filterCatalogField.tap()
        filterCatalogChoice.tap()
        filterFreeNavBar.buttons["Selesai"].tap()
        filterGambarField.tap()
        filterGambarChoice.tap()
        filterFreeNavBar.buttons["Selesai"].tap()
        filterKondisiField.tap()
        filterKondisiChoice.tap()
        filterFreeNavBar.buttons["Selesai"].tap()
        filterFreeNavBar.buttons["Selesai"].tap()
    }
    
    func setEmptyStock(){
        waitFor(element: productList, status: .Exists)
        productList.swipeLeft()
        if (setWareHouseButton.exists){
            setWareHouseButton.tap()
            setWarehouseAlert.buttons["Ya"].tap()
        }else{
            setActiveButton.tap()
            setActiveAlert.buttons["Ya"].tap()
            etalaseNavBar.buttons["Selesai"].tap()
            productList.swipeLeft()
            setWareHouseButton.tap()
            setWarehouseAlert.buttons["Ya"].tap()
        }
    }
    
    func cancelSetEmptyStock(){
        waitFor(element: productList, status: .Exists)
        productList.swipeLeft()
        if (setWareHouseButton.exists){
            setWareHouseButton.tap()
            setWarehouseAlert.buttons["Tidak"].tap()
        }else{
            setActiveButton.tap()
            setActiveAlert.buttons["Ya"].tap()
            etalaseNavBar.buttons["Selesai"].tap()
            productList.swipeLeft()
            setWareHouseButton.tap()
            setWarehouseAlert.buttons["Tidak"].tap()
        }
    }
    
    func setActiveStock(){
        waitFor(element: productList, status: .Exists)
        productList.swipeLeft()
        if (setActiveButton.exists){
            setActiveButton.tap()
            setActiveAlert.buttons["Ya"].tap()
            etalaseNavBar.buttons["Selesai"].tap()
        }else{
            setWareHouseButton.tap()
            setWarehouseAlert.buttons["Ya"].tap()
            productList.swipeLeft()
            setActiveButton.tap()
            setActiveAlert.buttons["Ya"].tap()
            etalaseNavBar.buttons["Selesai"].tap()
        }
    }
    
    func cancelActiveStock(){
        waitFor(element: productList, status: .Exists)
        productList.swipeLeft()
        if (setActiveButton.exists){
            setActiveButton.tap()
            setActiveAlert.buttons["Tidak"].tap()
        }else{
            setWareHouseButton.tap()
            setWarehouseAlert.buttons["Ya"].tap()
            productList.swipeLeft()
            setActiveButton.tap()
            setActiveAlert.buttons["Tidak"].tap()
        }
    }
    
    func deleteProduct(){
        waitFor(element: productList, status: .Exists)
        productList.swipeLeft()
        setDeleteButton.tap()
        setDeleteAlert.buttons["Ya"].tap()
    }
    
    func cancelDeleteProduct(){
        waitFor(element: productList, status: .Exists)
        productList.swipeLeft()
        setDeleteButton.tap()
        setDeleteAlert.buttons["Batal"].tap()
    }
    
    func duplicateProduct(){
        waitFor(element: productList, status: .Exists)
        productList.swipeLeft()
        setDuplicateButton.tap()
        waitFor(element: addImageProductButton, status: .Exists)
        productNameField.tap()
        productNameField.typeText("1")
        waitFor(element: duplicateNext1, status: .Exists)
        duplicateNext1.tap()
        duplicateNext2.tap()
    }
    
    func addProduct(){
        if (emptyMyProduct.exists){
            waitFor(element: emptyMyProduct, status: .Exists)
            emptyMyProduct.tap()
        }else{
            waitFor(element: productList, status: .Exists)
            produkNavBar.buttons["Add"].tap()
        }
        
        waitFor(element: addImageProductButton, status: .Exists)
        addImageProductButton.tap()
        imagePickerButton.tap()
        imagePickerNavBar.tap()
        newProductNameField.tap()
        newProductNameField.typeText("aaaaaa1")
        
        if (categoryField.exists){
            categoryField.tap()
            choosenCategory.tap()
            chooseCategoryNavBar.buttons["Selesai"].tap()
        }
        
        priceField.tap()
        priceField.tap()
        priceField.typeText("100")
        weightField.tap()
        weightField.typeText("100")
        addNext1.tap()
        chooseEtalase.tap()
        choosedEtalase.tap()
        etalaseNavBar.buttons["Selesai"].tap()
        addProductNavBar.buttons["Simpan"].tap()
        sleep(10)
    }
}

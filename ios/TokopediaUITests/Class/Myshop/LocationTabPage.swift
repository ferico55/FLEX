//
//  LocationTabPage.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class LocationTabPage : MyShopPage {
    let myshop = MyShopPage()
    let provinceButton = app.tables.buttons["provinceField"]
    let chooseProvinceNavBar = app.navigationBars["Pilih Provinsi"]
    let provinceChoosed = app.tables.staticTexts["DKI Jakarta"]
    let cityButton = app.tables.buttons["cityField"]
    let chooseCityNavBar = app.navigationBars["Pilih Kota"]
    let cityChoosed = app.tables.staticTexts["Jakarta Barat"]
    let districtButton = app.tables.buttons["districtField"]
    let chooseDistrictNavBar = app.navigationBars["Pilih Kecamatan"]
    let districtChoosed = app.tables.staticTexts["Palmerah"]
    let addLocationButton = app.tables["Tidak ada Lokasi Toko, Segera tambahkan lokasi toko Anda!"].buttons["Tambah Lokasi"]
    let locationNavBar = app.navigationBars["Lokasi Toko"]
    let addressNameField = app.tables.cells.textFields["addressNameField"]
    let detailAddressField = app.tables.textViews["detailAddressField"]
    let postCodeField = app.textFields["postCodeField"]
    let emailField = app.textFields["emailField"]
    let phoneNumberField = app.textFields["phoneNumberField"]
    let faxField = app.textFields["faxField"]
    let addLocationNavBar = app.navigationBars["Tambah Lokasi Toko"]
    let listLocationCell = app.tables.cells.matching(identifier: "listLocationCell").element(boundBy: 0)
    let editLocationNavBar = app.navigationBars["Lokasi 2"]
    let changeLocationNavBar = app.navigationBars["Ubah Lokasi Toko"]
    let deleteBySwipe = app.tables.buttons["Hapus"]
    let checkMaxNumOfLocation = app.tables.cells.matching(identifier: "listLocationCell").element(boundBy: 2)
    let addMoreThenTriAlert = app.alerts["Anda hanya bisa menambah sampai 3 alamat."]
    let deleteFromDetailButton = app.tables.buttons["Hapus Lokasi Ini"]
    
    
    func chooseProvince(){
        provinceButton.tap()
        provinceChoosed.tap()
        chooseProvinceNavBar.buttons["Pilih"].tap()
    }
    
    func chooseCity(){
        cityButton.tap()
        cityChoosed.tap()
        chooseCityNavBar.buttons["Pilih"].tap()
    }
    
    func chooseDistrict(){
        districtButton.tap()
        districtChoosed.tap()
        chooseDistrictNavBar.buttons["Pilih"].tap()
    }
    
    func addLocation(){
        if (addLocationButton.exists) {
            waitFor(element: addLocationButton, status: .Exists)
            addLocationButton.tap()
        }else{
            waitFor(element: locationNavBar.buttons["Add"], status: .Exists)
            locationNavBar.buttons["Add"].tap()
        }
        
        addressNameField.tap()
        addressNameField.typeText("Lokasi 2")
        detailAddressField.tap()
        detailAddressField.typeText("Jika aku menjadi sebuah lokasi yang dekat denganmu")
        postCodeField.tap()
        postCodeField.typeText("11410")
        chooseProvince()
        chooseCity()
        chooseDistrict()
        emailField.tap()
        emailField.typeText("alwanubaidillah@gmail.co")
        phoneNumberField.tap()
        phoneNumberField.typeText("08121111111")
        faxField.tap()
        faxField.typeText("02114045")
        addLocationNavBar.buttons["Simpan"].tap()
    }
    
    func updateLocation(){
        waitFor(element: listLocationCell, status: .Exists)
        listLocationCell.tap()
        editLocationNavBar.buttons["Ubah"].tap()
        addressNameField.tap()
        addressNameField.typeText("1")
        detailAddressField.tap()
        detailAddressField.typeText("Selalu ")
        postCodeField.tap()
        postCodeField.typeText("0")
        chooseProvince()
        chooseCity()
        chooseDistrict()
        emailField.tap()
        emailField.typeText("m")
        phoneNumberField.tap()
        phoneNumberField.typeText("22")
        faxField.tap()
        faxField.typeText("00")
        changeLocationNavBar.buttons["Simpan"].tap()
    }
    
    func deleteLocationBySwipe(){
        waitFor(element: listLocationCell, status: .Exists)
        listLocationCell.swipeLeft()
        deleteBySwipe.tap()
    }
    
    func deleteLocationFromDetail(){
        waitFor(element: listLocationCell, status: .Exists)
        listLocationCell.tap()
        deleteFromDetailButton.tap()
    }

}

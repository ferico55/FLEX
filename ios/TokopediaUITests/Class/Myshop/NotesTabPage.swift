//
//  NotesTabPage.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class NotesTabPage : MyShopPage {
    let myshop = MyShopPage()
    let noteTittleTextField = app.textFields["Judul"]
    let noteTextEditor = app.otherElements["noteTextEditor"]
    let noteTextEditorType = app.otherElements["noteTextEditor"].typeText("Line 1")
    let boldToolBar = app.scrollViews.toolbars.children(matching: .button).element(boundBy: 0)
    let italicToolBar = app.scrollViews.toolbars.children(matching: .button).element(boundBy: 1)
    let underlineToolBar = app.scrollViews.toolbars.children(matching: .button).element(boundBy: 2)
    let bulletToolBar = app.scrollViews.toolbars.children(matching: .button).element(boundBy: 3)
    let numberToolBar = app.scrollViews.toolbars.children(matching: .button).element(boundBy: 4)
    let enterFromKeyboard = app.buttons["Return"]
    let tambahCatatanNavBar = app.navigationBars["Tambah Catatan"]
    let catatanNavBar = app.navigationBars["Catatan"]
    let selectAllPress = app.menuItems["Select All"]
    let deleteFromKeyboard = app.keys["delete"]
    let listOfNote = app.tables.cells.matching(identifier: "listNotesCell").element(boundBy: 0)
    let ubahCatatanButton = app.tables.buttons["Ubah Catatan"]
    let deleteCatatanButton = app.tables.buttons["Hapus"]
    let ubahCatatanNavBar = app.navigationBars["Ubah Catatan"]
    let noteNameNavBar = app.navigationBars["Ini Judul Baru"]
    
    
    
    func typeTittle(){
        waitFor(element: noteTittleTextField, status: .Exists)
        noteTittleTextField.typeText("Ini Namanya Judul")
    }
    
    func typeNormalText(){
        noteTextEditor.tap()
        noteTextEditorType
        noteTextEditor.typeText("Line 1")
        enterFromKeyboard.tap()
    }
    
    func typeBoldText(){
        boldToolBar.tap()
        noteTextEditorType
        noteTextEditor.typeText("Line 2")
        enterFromKeyboard.tap()
    }
    
    func typeItalicText(){
        italicToolBar.tap()
        noteTextEditorType
        noteTextEditor.typeText("Line 3")
        enterFromKeyboard.tap()
    }
    
    func typeUnderlineText(){
        underlineToolBar.tap()
        noteTextEditor.typeText("Line 4")
        enterFromKeyboard.tap()
    }
    
    func typeBulletText(){
        bulletToolBar.tap()
        noteTextEditor.typeText("Line 5")
        enterFromKeyboard.tap()
        noteTextEditor.typeText("Line 6")
        enterFromKeyboard.tap()
    }
    
    func typeNumberText(){
        numberToolBar.tap()
        noteTextEditor.typeText("Line 7")
        enterFromKeyboard.tap()
        noteTextEditor.typeText("Line 8")
    }
    
    func typeDetailNote(){
        waitFor(element: noteTextEditor, status: .Exists)
        noteTextEditor.tap()
        typeNormalText()
        typeBoldText()
        typeItalicText()
    }
    
    func addCatatan(){
        catatanNavBar.buttons["Add"].tap()
        typeTittle()
        typeDetailNote()
        tambahCatatanNavBar.buttons["Simpan"].tap()
        sleep(2)
    }
    
    func updateNoteTittle(){
        waitFor(element: noteTittleTextField, status: .Exists)
        noteTittleTextField.press(forDuration: 2)
        selectAllPress.tap()
        deleteFromKeyboard.tap()
        noteTittleTextField.typeText("Ini Judul Baru")
    }
    
    func clearDetailNote(){
        noteTextEditor.tap()
        noteTextEditor.press(forDuration: 2)
        app.menuItems["Select All"].tap()
        deleteFromKeyboard.tap()
    }
    
    func changeNoteSwipe(){
        listOfNote.swipeLeft()
        ubahCatatanButton.tap()
        updateNoteTittle()
        clearDetailNote()
        typeDetailNote()
        ubahCatatanNavBar.buttons["Simpan"].tap()
    }
    
    func changeNoteFromDetail(){
        listOfNote.tap()
        noteNameNavBar.buttons["Ubah"].tap()
        updateNoteTittle()
        clearDetailNote()
        typeDetailNote()
        ubahCatatanNavBar.buttons["Simpan"].tap()
    }
    
    func deleteNote(){
        waitFor(element: listOfNote, status: .Exists)
        listOfNote.swipeLeft()
        deleteCatatanButton.tap()
    }
}

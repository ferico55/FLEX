//
//  DistrictViewController.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 11/1/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

@objc(DistrictViewController)
class DistrictViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var districts = DistrictRecommendation(nextAvailable: false, districtList: [])
    var query: String = ""
    var currentSelected: IndexPath?
    var keyboardHeight: CGFloat = 0

    var didSelectDistrict: ((DistrictDetail) -> Void)!

    var keroToken: String = ""
    var unixTime: Int = 0
    var currentPage: Int = 1

    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var districtTable: UITableView!
    @IBOutlet weak private var labelView: UILabel!
    var service: DistrictService?

    init(token: String, unixTime: Int) {
        self.keroToken = token
        self.unixTime = unixTime
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        service = DistrictService()
        setupView()
        setupRx()
    }

    func setupView() {
        districtTable.rowHeight = UITableViewAutomaticDimension
        districtTable.estimatedRowHeight = 44
        districtTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        districtTable.delegate = self
        districtTable.dataSource = self
        districtTable.isHidden = true
        labelView.isHidden = false
        title = "Tulis Kota/Kecamatan"

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }

    func setupRx() {

        searchBar
            .rx.text
            .orEmpty
            .filter({ (query) -> Bool in
                query.characters.count >= 3 || query.characters.count == 0
            })
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                guard let `self` = self else {
                    return
                }
                if query.characters.count == 0 {
                    self.districts.districtList = []
                    self.districtTable.reloadData()
                } else {
                    self.fetchDistricts(query: query, page: self.currentPage)
                }
            })
            .addDisposableTo(rx_disposeBag)

        searchBar.rx
            .cancelButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                self.districts.districtList = []
                self.districtTable.reloadData()
            })
            .disposed(by: rx_disposeBag)

        districtTable.rx_reachedBottom
            .subscribe(onNext: { [weak self] _ in
                if let myself = self {
                    if myself.districts.nextAvailable {
                        myself.fetchDistricts(query: myself.searchBar.text!, page: myself.currentPage)
                    }
                }
            })
            .disposed(by: rx_disposeBag)
    }

    func keyboardWillShow(_ notification: Notification) {
        if keyboardHeight == 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardH = keyboardRectangle.height
                keyboardHeight = keyboardH

                let oldFrame = districtTable.frame
                districtTable.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.size.width, height: oldFrame.size.height - keyboardHeight)
            }
        }
    }

    func keyboardWillHide(_: Notification) {
        resignFirstResponder()
        let oldFrame = districtTable.frame
        districtTable.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.size.width, height: oldFrame.size.height + keyboardHeight)
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let district = self.districts.districtList {
            return district.count
        } else { return 0 }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 9.0
        imageView.layer.borderColor = UIColor.tpBorder().cgColor
        imageView.layer.backgroundColor = UIColor.tpBorder().cgColor
        cell.accessoryView = imageView

        if let district = self.districts.districtList?[indexPath.row] {
            cell.textLabel?.text = district.provinceName + ", " + district.cityName + ", " + district.districtName
        }

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let district = self.districts.districtList?[indexPath.row] {
            didSelectDistrict(district as DistrictDetail)

            searchBar.text = district.provinceName + ", " + district.cityName + ", " + district.districtName

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.dismiss(animated: true, completion: nil)
            })

            let img = UIImage(named: "icon_check_green")!
            let imgView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
            imgView.clipsToBounds = true
            imgView.contentMode = UIViewContentMode.scaleAspectFit
            imgView.backgroundColor = UIColor.clear
            imgView.image = img
        }
    }

    func fetchDistricts(query: String, page _: Int) {
        if self.query != query {
            currentPage = 1
        }
        service?.fetchDistricts(token: keroToken,
                                unixTime: unixTime,
                                query: query,
                                page: currentPage,
                                onSuccess: { [weak self] (districts: DistrictRecommendation) in
            guard let `self` = self else {
                return
            }
            self.districtTable.isHidden = false
            self.labelView.isHidden = true
            self.districts.nextAvailable = districts.nextAvailable
            if districts.nextAvailable { self.currentPage += 1 }
            if !districts.nextAvailable { self.currentPage = 1 }
            if self.query == query {
                if let currentDistricts = self.districts.districtList, let nextDistricts = districts.districtList {
                    self.districts.districtList = currentDistricts + nextDistricts
                }
            } else {
                self.districts.districtList = districts.districtList
            }
            if districts.nextAvailable { self.currentPage += 1 }
            self.districtTable.reloadData()
            self.query = query
        }, onFailure: {
            StickyAlertView.showErrorMessage(["Kendala koneksi internet, silakan coba kembali."])
        })
    }
}

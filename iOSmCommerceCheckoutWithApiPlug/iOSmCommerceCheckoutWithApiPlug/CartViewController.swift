//
//  CartViewController.swift
//  M-Commerce_DashBoard_Plug
//
//  Created by MRV Computers on 2/25/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

/// table View Cell For Product
class tableViewCellForProduct: UITableViewCell {
    @IBOutlet weak var imgViewForProduct: UIImageView!
    @IBOutlet weak var lblForProductName: UILabel!
    @IBOutlet weak var lblForProductSize: UILabel!
    @IBOutlet weak var lblForProductCategory: UILabel!
}

class CartViewController: UIViewController {
    
    // MARK:- Outlets declaration
    
    @IBOutlet weak var tableViewForProduct: UITableView!
    @IBOutlet weak var viewForCostDetail: UIView!
    @IBOutlet weak var lblForTotalMRP: UILabel!
    @IBOutlet weak var lblForTotalMRPValue: UILabel!
    @IBOutlet weak var lblForDeliveryCharges: UILabel!
    @IBOutlet weak var lblForDeliveryChargesValue: UILabel!
    @IBOutlet weak var lblForTotal: UILabel!
    @IBOutlet weak var lblForTotalValue: UILabel!
    
    @IBOutlet weak var viewForAddress: UIView!
    @IBOutlet weak var txtForName: UITextField!
    @IBOutlet weak var lblForNameError: UILabel!
    @IBOutlet weak var txtForEmail: UITextField!
    @IBOutlet weak var lblForEmailError: UILabel!
    @IBOutlet weak var txtForMobileNumber: UITextField!
    @IBOutlet weak var lblForMobileNumberError: UILabel!
    @IBOutlet weak var txtForAddressLine1: UITextField!
    @IBOutlet weak var lblForAddressLine1Error: UILabel!
    @IBOutlet weak var txtForAddressLine2: UITextField!
    @IBOutlet weak var lblForAddressLine2Error: UILabel!
    @IBOutlet weak var txtForCity: UITextField!
    @IBOutlet weak var lblForVityError: UILabel!
    @IBOutlet weak var txtForPostalCode: UITextField!
    @IBOutlet weak var lblForPostalCodeError: UILabel!
    @IBOutlet weak var btnForAction: UIButton!
    @IBOutlet weak var viewForConfirmPaymentAndAddress: UIView!
    @IBOutlet weak var viewForConfirmPayment: UIView!
    @IBOutlet weak var btnForCOD: UIButton!
    @IBOutlet weak var viewForConfirmAddress: UIView!
    @IBOutlet weak var lblForAddressName: UILabel!
    @IBOutlet weak var lblForddressMobileNum: UILabel!
    @IBOutlet weak var lblForAddressLine1: UILabel!
    @IBOutlet weak var lblForAddressLine2: UILabel!
    @IBOutlet weak var lblForAddressCityPinCode: UILabel!
    @IBOutlet weak var btnForAddressEdit: UIButton!
    
    @IBOutlet weak var viewForSuccess: UIView!
    @IBOutlet weak var successViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewForSpinner: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK:- Variable declaration
    var productId = 19
    var productName = "Mangoes"
    var productImage = "http://114.143.198.154:7002/Product/ProductDetail/5d5b41f6-98fd-43b2-92d7-9c002118a437.jpg"
    var categoryName =  "Fruits"
    var cost = "1.50"
    var deliveryCost = "0"
    var size = ""
    var sizeId = 0
    var addressDict = Dictionary<String, String>.init()
    
    // MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIProperties()
        lblForTotalMRPValue.text = ThemeClass.currencySymbol + " " + (cost )
        lblForDeliveryChargesValue.text = ThemeClass.currencySymbol + " " + (deliveryCost )
        let totalCostValue = Double(deliveryCost )! + Double(cost )!
        lblForTotalValue.text = "\(ThemeClass.currencySymbol) \(totalCostValue)"
    }
    
    /// Used to set UI properties
    func setUIProperties() {
        setBorderOnView(tableViewForProduct)
        setBorderOnView(viewForCostDetail)
        setBorderOnView(viewForConfirmAddress)
        setBorderOnView(viewForConfirmPayment)
        setBorderOnView(viewForSuccess)
        
        viewForSuccess.isHidden = true
        successViewHeight.constant = 0
        
        btnForAction.backgroundColor = ThemeClass.primaryColor
        btnForAction.setTitleColor(ThemeClass.textColor, for: .normal)
        
        btnForAddressEdit.backgroundColor = ThemeClass.textColor
        btnForAddressEdit.setTitleColor( ThemeClass.primaryColor, for: .normal)
        btnForAddressEdit.layer.borderColor = ThemeClass.primaryColor.cgColor
        btnForAddressEdit.layer.borderWidth = 1
        btnForAddressEdit.layer.cornerRadius = 4
    }
    
    /// Used to border on view
    ///
    /// - Parameter view: view
    func setBorderOnView(_ view : UIView) {
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
    }
    
    // MARK: - Button action methods
    
    @IBAction func editAddressClicked(_ sender: Any) {
        viewForAddress.isHidden = false
        fillAddressToEdit()
        viewForConfirmPaymentAndAddress.isHidden = true
        btnForAction.setTitle("Save Address", for: .normal)
        btnForAction.isEnabled = true
        btnForAction.backgroundColor = ThemeClass.primaryColor
    }
    
    @IBAction func CODBtnClicked(_ sender: Any) {
        if let btn = sender as? UIButton {
            btn.isSelected = !btn.isSelected
            if btn.isSelected {
                btnForAction.isEnabled = true
                btnForAction.backgroundColor = ThemeClass.primaryColor
            } else {
                btnForAction.isEnabled = false
                btnForAction.backgroundColor = UIColor.gray
            }
        }
    }
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        if !viewForAddress.isHidden {
            // save address clicked
            if checkLocalValidation() {
                saveAddress()
                viewForAddress.isHidden = true
                fillAddressInConfirmView()
                viewForConfirmPaymentAndAddress.isHidden = false
                btnForAction.setTitle("Place Order", for: .normal)
                btnForAction.isEnabled = false
                btnForAction.backgroundColor = UIColor.gray
            }
        } else if viewForSuccess.isHidden {
            //Place order clicked
            if btnForCOD.isSelected {
                var requestParamDict = Dictionary<String, Any>.init()
                requestParamDict["ProductId"] = productId
                requestParamDict["SelectedSizeId"] = sizeId
                requestParamDict["PaymentMentod"] = "COD"
                requestParamDict["TotalCost"] = "\(Double(deliveryCost )! + Double(cost )!)"
                requestParamDict.merge(addressDict) { $1 }
                callToPlaceOrderAPI(requestParamDict)
            }
        } else {
            self.showAlert(AlertTitleNMessage.FAILURE_TITLE.rawValue, AlertTitleNMessage.CONT_SHOPING_MESSAGE.rawValue)
        }
    }
    
    /// Used to save address
    func saveAddress()  {
        if let name = txtForName.text { addressDict["Name"] = name }
        if let email = txtForEmail.text { addressDict["Email"] = email }
        if let mobileNo = txtForMobileNumber.text { addressDict["PhoneNumber"] = mobileNo }
        if let addressLine1 = txtForAddressLine1.text { addressDict["AddressLine1"] = addressLine1 }
        if let addressLine2 = txtForAddressLine2.text { addressDict["AddressLine2"] = addressLine2 }
        if let city = txtForCity.text { addressDict["City"] = city }
        if let postalCode = txtForPostalCode.text { addressDict["PostalCode"] = postalCode }
        
    }
    
    /// Used to check all local validation
    ///
    /// - Returns: flag
    func checkLocalValidation() -> Bool {
        var value = true
        if txtForName.text == nil || txtForName.text?.count == 0 {
            value = false
            lblForNameError.isHidden = false
            lblForNameError.text = GeneralMessages.NAME_VALIDATION_MESSAGE.rawValue
        }
        
        if !isValidEmail(emailID: txtForEmail.text!.trim())
        {
            value = false
            lblForEmailError.isHidden = false
            lblForEmailError.text = GeneralMessages.EMAIL_VALIDATION_ALERT.rawValue
            
        }
        
        if !isValidMobileNumber(mobileNumber: txtForMobileNumber.text!) {
            value = false
            lblForMobileNumberError.isHidden = false
            lblForMobileNumberError.text = GeneralMessages.MOMILE_NUMBER_VALIDATION_MESSAGE.rawValue
        }
        
        if txtForAddressLine1.text == nil || txtForAddressLine1.text?.count == 0 {
            value = false
            lblForAddressLine1Error.isHidden = false
            lblForAddressLine1Error.text = GeneralMessages.ADDRESS_VALIDATION_MESSAGE.rawValue
        }
        
        if txtForCity.text == nil || txtForCity.text?.count == 0 {
            value = false
            lblForVityError.isHidden = false
            lblForVityError.text = GeneralMessages.CITY_VALIDATION_MESSAGE.rawValue
        }
        
        if txtForPostalCode.text == nil || txtForPostalCode.text?.count == 0 {
            value = false
            lblForPostalCodeError.isHidden = false
            lblForPostalCodeError.text = GeneralMessages.POSTALCODE_VALIDATION_MESSAGE.rawValue
        } else if (txtForPostalCode.text!.count < 4 || txtForPostalCode.text!.count > 6 ) {
            value = false
            lblForPostalCodeError.isHidden = false
            lblForPostalCodeError.text = GeneralMessages.POSTALCODE_VALIDATION_ALERT.rawValue
        }
        
        return value
    }
    
    /// used to fill address in confirm view
    func fillAddressInConfirmView() {
        lblForAddressName.text = addressDict["Name"]
        lblForddressMobileNum.text = addressDict["PhoneNumber"]
        lblForAddressLine1.text = addressDict["AddressLine1"]
        lblForAddressLine2.text = addressDict["AddressLine2"]
        lblForAddressCityPinCode.text = addressDict["City"]! + " - " + addressDict["PostalCode"]!
    }
    
    /// Used to open edit address view
    func fillAddressToEdit() {
        txtForName.text = addressDict["Name"]
        txtForEmail.text = addressDict["Email"]
        txtForMobileNumber.text = addressDict["PhoneNumber"]
        txtForAddressLine1.text = addressDict["AddressLine1"]
        txtForAddressLine2.text = addressDict["AddressLine2"]
        txtForCity.text = addressDict["City"]
        txtForPostalCode.text = addressDict["PostalCode"]
    }
    
    /// Used to call placed order API
    ///
    /// - Parameter requestParam: order data
    func callToPlaceOrderAPI(_ requestParam:Dictionary<String, Any>) {
        if requestParam.count == 0 { return }
        
        if !GeneralClass.isConnectedToNetwork() {
            self.showAlert(AlertTitleNMessage.NOINTERNET_TITLE.rawValue, AlertTitleNMessage.NOINTERNET_MESSAGE.rawValue)
            return
        }
        viewForSpinner.isHidden = false
        spinner.startAnimating()
        APIs.performPost(requestStr: ConstantStrings.PlaceOrderAPI, jsonData: requestParam) { (data) in
            self.viewForSpinner.isHidden = true
            self.spinner.stopAnimating()
            if let responseData = data as? Dictionary<String,Any> {
                if responseData["statusCode"] as? String == "10" {
                    self.successViewHeight.constant = 150
                    self.viewForSuccess.isHidden = false
                    self.btnForAddressEdit.isHidden = true
                    self.btnForAction.setTitle("Continue shopping", for: .normal)
                    self.viewForConfirmPayment.isHidden = true
                    self.scrollView.setContentOffset(.zero, animated: true)
                } else {
                    self.showAlert(nil, responseData["message"] as? String ?? "Something went wrong")
                }
            } else {
                self.showAlert(nil, AlertTitleNMessage.SOMETHING_WRONG_MESSAGE.rawValue)
            }
        }
    }
    
    /// Used to present alert view
    ///
    /// - Parameters:
    ///   - title: title
    ///   - message: message
    func showAlert(_ title:String?, _ message:String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    //function for checking is email id valid or not
    func isValidEmail(emailID:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    
    //function for checking is mobile number valid or not
    func isValidMobileNumber(mobileNumber:String) -> Bool {
        let mobileNumberRegEx = "^[987]\\d{9}$"
        let mobileNumberTest = NSPredicate(format:"SELF MATCHES %@", mobileNumberRegEx)
        return mobileNumberTest.evaluate(with: mobileNumber)
    }
}

// MARK: - UITableViewDelegate
extension CartViewController : UITableViewDelegate{
    
}

// MARK: - UITableViewDataSource

extension CartViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "product_cell") as? tableViewCellForProduct
        {
            cell.lblForProductName.text = productName
            cell.lblForProductCategory.text = self.categoryName
            
            if let imageurl = URL.init(string: self.productImage) {
                cell.imgViewForProduct.af_setImage(withURL: imageurl)
            } else {
                cell.imgViewForProduct.image = UIImage.init(named: "ic_placeholder_category")
            }
            cell.lblForProductSize.text = size
            return cell
        }
        
        return UITableViewCell.init()
    }
}
// MARK: - UITextFieldDelegate

extension CartViewController : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if txtForMobileNumber == textField
        {
            lblForMobileNumberError.isHidden = true
            let maxLengthForMobileNo = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLengthForMobileNo
        }else if txtForName == textField
        {
            lblForNameError.isHidden = true
            let maxLengthForname = 50
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLengthForname
        }else if txtForAddressLine1 == textField
        {
            lblForAddressLine1Error.isHidden = true
            let maxLengthForAddress = 100
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLengthForAddress
        }else if txtForAddressLine2 == textField
        {
            lblForAddressLine2Error.isHidden = true
            let maxLengthForAddress = 100
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLengthForAddress
        }else if txtForCity == textField
        {
            lblForVityError.isHidden = true
            let maxLengthForcity = 20
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLengthForcity
        }else if txtForPostalCode == textField
        {
            lblForPostalCodeError.isHidden = true
            let maxLengthForPostalCode = 6
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLengthForPostalCode
        }else if textField == txtForEmail{
            lblForEmailError.isHidden = true
        }
        return true
    }
}

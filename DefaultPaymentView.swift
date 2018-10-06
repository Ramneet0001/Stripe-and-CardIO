//
//  DefaultPaymentView.swift
//  Cabscout
//
//  Created by appzorro on 18/08/17.
//  Copyright © 2017 appzorro. All rights reserved.
//



import UIKit
import Stripe

import SVProgressHUD

class DefaultPaymentView: UIViewController, STPPaymentCardTextFieldDelegate, CardIOPaymentViewControllerDelegate {
    /// This method will be called if the user cancels the scan. You MUST dismiss paymentViewController.
    /// @param paymentViewController The active CardIOPaymentViewController.
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismiss(animated: true, completion: nil)

    }

    
    @IBOutlet weak var payButton: UIButton? = nil
    var paymentTextField: STPPaymentCardTextField!
    
    override func viewDidLoad() {
        // add stripe built-in text field to fill card information in the middle of the view
        super.viewDidLoad()
//        let frame1 = CGRect(x: 20, y: 300, width: self.view.frame.size.width - 40, height: 40)
//        paymentTextField = STPPaymentCardTextField(frame: frame1)
//        paymentTextField.center = view.center
//        paymentTextField.delegate = self
//        view.addSubview(paymentTextField)
        //disable payButton if there is no card information
//        payButton = UIButton(type: .system)
//        payButton?.frame = CGRect(x: 15, y: 100, width: 100, height: 44)
//        payButton?.isEnabled = false
//        payButton?.setTitle("Submit", for: [])
//        payButton?.addTarget(self, action: #selector(payButtonTapped(sender:)), for: .touchUpInside)
//        payButton?.isEnabled = false
        
        self.scanCard(sender: AnyObject.self as AnyObject)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        CardIOUtilities.preload()
       
    }
    
    @IBAction func scanCard(sender: AnyObject) {
        //open cardIO controller to scan the card
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        present(cardIOVC!, animated: true, completion: nil)
        
    }
    
    
    @IBAction func payButtonTapped(sender: AnyObject) {
        let card = paymentTextField.cardParams
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        //send card information to stripe to get back a token
        getStripeToken(card: card)
    }
    
    
    func getStripeToken(card:STPCardParams) {
        // get stripe token for current card
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                print(token)
                SVProgressHUD.showSuccess(withStatus: "Stripe token successfully received: \(token)")
                self.postStripeToken(token: token)
            } else {
                print(error ?? "")
                SVProgressHUD.showError(withStatus: "errorrr")
            }
        }
    }
    
    // charge money from backend
    func postStripeToken(token: STPToken) {
        //Set up these params as your backend require
        
       // let params: [String: NSObject] = ["stripeToken": token.tokenId as NSObject, "amount": 10 as NSObject]
//        let URL = ""
//        let params = ["stripeToken": token,
//                      "amount": "10",
//                      "currency": "usd",
//                      "description": ""]
//        
//        let manager = AFHTTPRequestOperationManager()
//        manager.POST(URL, parameters: params, success: { (operation, responseObject) -> Void in
//            
//            if let response = responseObject as? [String: String] {
//                UIAlertView(title: response["status"],
//                            message: response["message"],
//                            delegate: nil,
//                            cancelButtonTitle: "OK").show()
//            }
//            
//        }) { (operation, error) -> Void in
//            
//        }
        //TODO: Send params to your backend to process payment
        
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.valid{
            payButton?.isEnabled = true
        }
    }
    
    //MARK: - CardIO Methods
    
    //Allow user to cancel card scanning
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        print("user canceled")
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    //Callback when card is scanned correctly
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            print(str)
            
            //dismiss scanning controller
            paymentViewController?.dismiss(animated: true, completion: nil)
            
            //create Stripe card
            let card: STPCardParams = STPCardParams()
            card.number = info.cardNumber
            card.expMonth = info.expiryMonth
            card.expYear = info.expiryYear
            card.cvc = info.cvv
            
            //Send to Stripe
            getStripeToken(card: card)
            
  
    }
    
               
      

}
}

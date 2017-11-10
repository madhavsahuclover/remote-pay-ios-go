//
//  CloverGoConnectorListener.swift
//  CloverConnector_Example
//
//  Created by Rajan Veeramani on 10/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import GoConnector

class CloverGoConnectorListener : CloverConnectorListener, ICloverGoConnectorListener, UITextFieldDelegate {
    
    func onSendReceipt() {
        
        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        
        let alertController = UIAlertController(title: "Send Receipt \nTo", message: "email / phone number", preferredStyle: .alert)
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("ra.dummy@xyz.com", comment: "email")
        }
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("555555555", comment: "phone")
        }
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK action"), style: .default, handler: {(action: UIAlertAction) -> Void in
            let email = alertController.textFields?.first!
            let phone = alertController.textFields?.last!
            ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.sendReceipt(email: email?.text, phone: phone?.text)
            self.nextVC()
//            topController.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.sendReceipt(email: nil, phone: nil)
            self.nextVC()
//            topController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        topController.present(alertController, animated:true, completion:nil)
    }
    
    func nextVC() {
        if let vc = self.viewController {
            if vc is SignatureCloverGoViewController {
                var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
                while ((topController.presentedViewController) != nil) {
                    topController = topController.presentedViewController!
                }
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabControllerID") as! TabBarController
                topController.present(nextViewController, animated:true, completion:nil)
            }
        }
    }
    
    func onSignatureRequired() {
        self.viewController?.performSegue(withIdentifier: "signatureCloverGoViewControllerID", sender: nil)
    }
    
    
    func onAidMatch(cardApplicationIdentifiers:[CLVModels.Payments.CardApplicationIdentifier]) -> Void {
        let choiceAlert = UIAlertController(title: "Choose Application Identifier", message: "Please select one of the appId's", preferredStyle: .actionSheet)
        for appId in cardApplicationIdentifiers {
            let action = UIAlertAction(title: appId.applicationLabel, style: .default, handler: {
                (action:UIAlertAction) in
                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.selectCardApplicationIdentifier(cardApplicationIdentier: appId)
                
            })
            choiceAlert.addAction(action)
        }
        choiceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action:UIAlertAction) in
            
        }))
        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        topController.present(choiceAlert, animated:true, completion:nil)
    }
    
    func onDevicesDiscovered(devices:[CLVModels.Device.GoDeviceInfo]) ->Void {
        print("Discovered Readers...")
        let choiceAlert = UIAlertController(title: "Choose your reader", message: "Please select one of the reader", preferredStyle: .actionSheet)
        for device in devices {
            let action = UIAlertAction(title: device.name, style: .default, handler: {
                (action:UIAlertAction) in
                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.connectToBluetoothDevice(deviceInfo: device)
                
            })
            choiceAlert.addAction(action)
        }
        choiceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action:UIAlertAction) in
            
        }))
        
        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        
        if let popoverController = choiceAlert.popoverPresentationController {
            popoverController.sourceView = topController.view
            popoverController.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
        }
        
        topController.present(choiceAlert, animated:true, completion:nil)
        
    }
    
    func onTransactionProgress(event: CLVModels.Payments.GoTransactionEvent) -> Void {
        print("\(event.getDescription())")
        
        switch event
        {
        case .EMV_CARD_INSERTED,.CARD_SWIPED,.CARD_TAPPED:
            showMessage("Processing Transaction", duration: 1)
            break
            
        case .EMV_CARD_REMOVED:
            showMessage("Card removed", duration: 1)
            break
            
        case .EMV_CARD_DIP_FAILED:
            showMessage("Emv card dip failed.\nPlease reinsert card", duration: 1)
            break
            
        case .EMV_CARD_SWIPED_ERROR:
            showMessage("Emv card swiped error", duration: 1)
            break
            
        case .EMV_DIP_FAILED_PROCEED_WITH_SWIPE:
            showMessage("Emv card dip failed.\n\nPlease try swipe.", duration: 1)
            break
            
        case .SWIPE_FAILED:
            showMessage("Swipe failed", duration: 1)
            break
            
        case .CONTACTLESS_FAILED_TRY_AGAIN:
            showMessage("Contactless failed\nTry again", duration: 1)
            break
            
        case .SWIPE_DIP_OR_TAP_CARD:
            showMessage("Please \n\nINSERT / SWIPE / TAP \n\na card", duration: 1)
            break
        case .REMOVE_CARD:
            showMessage("Please Remove Card from Reader", duration: 1)
            
        default:
            break;
        }
    }
    
    @objc private func dismissMessage1(_ view:UIAlertView) {
        view.dismiss( withClickedButtonIndex: -1, animated: true);
    }
    
    private func showMessage(_ message:String, duration:Int = 3) {
        
        DispatchQueue.main.async {
            let alertView:UIAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alertView.show()
            self.perform(#selector(self.dismissMessage1), with: alertView, afterDelay: TimeInterval(duration))
        }
    }
    
    override func onAuthResponse(_ authResponse: AuthResponse) {
        super.onAuthResponse(authResponse)
    }
    
    override func onSaleResponse(_ response: SaleResponse) {
        super.onSaleResponse(response)
    }
    
    override func onDeviceReady(_ merchantInfo: MerchantInfo) {
        super.onDeviceReady(merchantInfo)
        DispatchQueue.main.async {
            SHARED.delegateStartTransaction?.proceedAfterReaderReady(merchantInfo: merchantInfo)
        }
    }
    
    func onMultiplePaymentModesAvailable(paymentModes: [CLVModels.Payments.PaymentMode]) {
        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        for paymentMode in paymentModes {
            let paymentAction = UIAlertAction(title: paymentMode.toString(), style: .default, handler: { (action: UIAlertAction!) in
                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.selectPaymentMode(paymentMode: paymentMode)
            })
            alert.addAction(paymentAction)
        }
        
        topController.present(alert, animated: true, completion: nil)
    }
    
    func onKeyedCardDataRequired() {
//        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
//        while ((topController.presentedViewController) != nil) {
//            topController = topController.presentedViewController!
//        }
        let alertController = UIAlertController(title: "Enter Credit Card Info", message: "", preferredStyle: .alert)
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = NSLocalizedString("Card No", comment: "Card No")
            textField.tag = 1
            textField.delegate = self
        }
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("CVV", comment: "CVV")
            textField.keyboardType = .numberPad
            textField.tag = 2
            textField.delegate = self
        }
        
        alertController.addTextField {(textField:UITextField) -> Void in
            textField.placeholder = NSLocalizedString("MMYY", comment: "Expiry date")
            textField.keyboardType = .numberPad
            textField.tag = 3
            textField.delegate = self
        }
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK action"), style: .default, handler: {(action: UIAlertAction) -> Void in
            let cardNo = alertController.textFields?[0].text ?? ""
            let cvv = alertController.textFields?[1].text ?? ""
            let expiryDate = alertController.textFields?[2].text ?? ""
            let keyedCardData = CLVModels.Payments.KeyedCardData(cardNumber: cardNo, expirationDate: expiryDate, cvv: cvv)
            ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.processKeyedTransaction(keyedCardData: keyedCardData)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.viewController!.present(alertController, animated:true, completion:nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty {
            if textField.tag == 1 {
                if let text = textField.text {
                    if text.characters.count >= 16 {
                        return false
                    }
                } else {
                    return true
                }
            }
            if textField.tag == 2 {
                if let text = textField.text {
                    if text.characters.count >= 3 {
                        return false
                    }
                } else {
                    return true
                }
            }
            if textField.tag == 3 {
                if let text = textField.text {
                    if text.characters.count >= 4 {
                        return false
                    }
                } else {
                    return true
                }
            }
            
        }
        return true
    }

}

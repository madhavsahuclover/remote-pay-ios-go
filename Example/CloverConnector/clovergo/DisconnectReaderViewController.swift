//
//  DisconnectReaderViewController.swift
//  CloverConnector_Example
//
//  Created by Veeramani, Rajan (Non-Employee) on 11/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import GoConnector

class DisconnectReaderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.isHidden = true
            let alertController = UIAlertController(title: "Disconnect Reader", message: "", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.disconnectDevice()
                FLAGS.is350ReaderInitialized = false
                FLAGS.is450ReaderInitialized = false
                strongSelf.showNextVC()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                strongSelf.navigationController?.popViewController(animated: true)
            }))
            strongSelf.present(alertController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showNextVC()
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "readerSetUpViewControllerID") as! ReaderSetUpViewController
        self.present(nextViewController, animated:true, completion:nil)
    }

}

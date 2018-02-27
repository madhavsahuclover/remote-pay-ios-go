//
//  OAuthViewController.swift
//  CloverConnector_Example
//
//  Created by Deshmukh, Harish (Non-Employee) on 11/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class OAuthViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webViewForOAuth: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "https://dev14.dev.clover.com/oauth/authorize?response_type=code&client_id=95JVJC8C8M14C&redirect_uri=clovergooauth://oauthresult"
        webViewForOAuth.loadRequest(URLRequest(url: URL(string: url)!))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (request.url?.host == "oauthresult") {
            extractParametersForRestCall(url: (request.url)!)
        }
        return true
    }
    
    func extractParametersForRestCall(url: URL)
    {
        print("Redirect received from Safari...url recieved: \(url)")
        
        let codeFromRecievedUrl = url.query?.components(separatedBy: "code=").last
        print("codeFromRecievedUrl: \(String(describing: codeFromRecievedUrl))")
        
        var merchant_idFromRecievedUrl = url.query?.components(separatedBy: "merchant_id").last
        merchant_idFromRecievedUrl = extractStringFromURL(url: merchant_idFromRecievedUrl!)
        print("merchant_idFromRecievedUrl: \(String(describing: merchant_idFromRecievedUrl))")
        
        var employee_idFromRecievedUrl = url.query?.components(separatedBy: "employee_id").last
        employee_idFromRecievedUrl = extractStringFromURL(url: employee_idFromRecievedUrl!)
        print("employee_idFromRecievedUrl: \(String(describing: employee_idFromRecievedUrl))")
        
        var client_idFromRecievedUrl = url.query?.components(separatedBy: "client_id").last
        client_idFromRecievedUrl = extractStringFromURL(url: client_idFromRecievedUrl!)
        print("client_idFromRecievedUrl: \(String(describing: client_idFromRecievedUrl))")
        
        restCallToGetToken(merchant_id: merchant_idFromRecievedUrl!, employee_id: employee_idFromRecievedUrl!, client_id: client_idFromRecievedUrl!, code: codeFromRecievedUrl!)
    }
    
    /// Make a rest call to get the access token
    ///
    /// - Parameters:
    ///   - merchant_id: received from redirect Url
    ///   - employee_id: received from redirect Url
    ///   - client_id: received from redirect Url
    ///   - code: received from redirect Url
    func restCallToGetToken(merchant_id: String, employee_id: String, client_id: String, code: String)
    {
        let configuration = URLSessionConfiguration .default
        let session = URLSession(configuration: configuration)
        
        let apikeyForUrlForRestCall = "byJiyq2GZNmS6LgtAhr2xGS6gz4dpBYX"
        let client_idForUrlForRestCall = client_id
        let client_secretForUrlForRestCall = "d725cab0-f8af-69e6-c0ed-809b846e83f8"
        
        var urlString = NSString(format: "https://api-int.payeezy.com/clovergoOAuth/?environment=dev14.dev.clover.com&apikey=")
        urlString = "\(urlString)\(apikeyForUrlForRestCall)" as NSString
        urlString = "\(urlString)&client_id=" as NSString
        urlString = "\(urlString)\(client_idForUrlForRestCall)" as NSString
        urlString = "\(urlString)&client_secret=" as NSString
        urlString = "\(urlString)\(client_secretForUrlForRestCall)" as NSString
        urlString = "\(urlString)&code=" as NSString
        urlString = "\(urlString)\(code)" as NSString
        print("urlString: \(urlString)")
        
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.url = NSURL(string: NSString(format: "%@", urlString) as String) as URL?
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request as URLRequest) {
            ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    print("error: not a valid http response")
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                let response = NSString (data: receivedData, encoding: String.Encoding.utf8.rawValue)
                print("response is \(String(describing: response))")
                do {
                    let getResponse = try JSONSerialization.jsonObject(with: receivedData, options: .allowFragments)  as! [String:Any]
                    print("getResponse is \(getResponse)")
                    
                    if let accessToken = getResponse["access_token"] as? String {
                        self.initSDKWithOAuth(accessTokenReceived: accessToken)
                    } else {
                        
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
                break
                
            case 400:
                break
                
            default:
                print("GET request got response \(httpResponse.statusCode)")
            }
        }
        dataTask.resume()
    }
    
    /// Used to extract a substring from the URL
    ///
    /// - Parameter url: URL from which the string is extracted
    /// - Returns: extracted string
    func extractStringFromURL(url: String) -> String
    {
        if let startRange = url.range(of: "="), let endRange = url.range(of: "&"), startRange.upperBound <= endRange.lowerBound {
            let extractedString = url[startRange.upperBound..<endRange.lowerBound]
            return String(extractedString)
        }
        else {
            print("invalid string")
            return ""
        }
    }
    
    
    /// Initializes the SDK with access token received after entering the credentials for OAuth
    ///
    /// - Parameter accessTokenReceived: access token received from the OAuth request
    func initSDKWithOAuth(accessTokenReceived: String)
    {
        // MARK: Note
        // Reach out to the CloverGo team for getting apiKey: and secret: for Sandbox env and set the values of kApiKey and kSecret constants respectively
        SHARED.workingQueue.async() {
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.async {
                self.showMessage("Received Access Token \n to \n initalize the SDK")
            }
        }
        SHARED.workingQueue.async() {
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.async {
                PARAMETERS.accessToken = accessTokenReceived
                PARAMETERS.apiKey = "Lht4CAQq8XxgRikjxwE71JE20by5dzlY"
                PARAMETERS.secret = "7ebgf6ff8e98d1565ab988f5d770a911e36f0f2347e3ea4eb719478c55e74d9g"
                self.showNextVC(storyboardID: "readerSetUpViewControllerID")
            }
        }
    }
    
    func showNextVC(storyboardID:String)
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: storyboardID)
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    private func showMessage(_ message:String, duration:Int = 3) {
        
        DispatchQueue.main.async {
            let alertView:UIAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alertView.show()
            self.perform(#selector(self.dismissMessage), with: alertView, afterDelay: TimeInterval(duration))
        }
        
    }
    
    @objc private func dismissMessage(_ view:UIAlertView) {
        view.dismiss( withClickedButtonIndex: -1, animated: true);
    }
    
    @IBAction func backButton(_ sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
        
    }
}

//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper
/**
 options for a manual refund
 */
public class ManualRefundRequest:TransactionRequest {

    /// :nodoc:
    public override var type:TransactionType {
        get {
            return TransactionType.CREDIT
        }
        set {
            // do nothing
        }
    }
    
    public override init(amount:Int, externalId:String) {
        super.init(amount:amount, externalId:externalId)
    }
    
    /// :nodoc:
    public required init?(map:Map) {
        super.init(map:map)
    }
    

}


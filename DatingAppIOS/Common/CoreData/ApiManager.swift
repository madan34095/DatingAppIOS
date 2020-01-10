//
//  ApiManager.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/10/08.
//  Copyright © 2019 ADV. All rights reserved.
//

import Foundation
import Alamofire

class ApiManager {
    
    static func getData(_ url:String, param: [String:Any]?, header: HTTPHeaders?, responceHandler:@escaping ((_ isSuccess: Bool, _ responce: DataResponse<Any>) -> Void)){
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            switch response.result {
                
            case .success(_):
                if response.result.value != nil{
                    print(response.result.value!)
                    responceHandler(true, response)
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "UnKnow Error")
                responceHandler(false, response)
                break
                
            }
        }
    }
    
    
    
    static func postData(_ urlString:String, param: [String:Any]?, responceHandler:@escaping ((_ isSuccess: Bool, _ responce: [String: AnyObject]?) -> Void)){
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:param, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        responceHandler(true, jsonDataDict)
                    }
                }
            } catch let err as NSError {
                responceHandler(true, nil)
            }
        }
        task.resume()
    }
    
    static func multipartData(_ url:String, param: [String:Any]?, image: UIImage?, fname: String?, header: HTTPHeaders?, responceHandler:@escaping ((_ isSuccess: Bool, _ responce: DataResponse<String>) -> Void)){
            Alamofire.upload(multipartFormData: { (multiPartData) in
                for (key, value) in param! {
                        multiPartData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                    }
                if image != nil {
                    let imgData = image?.jpegData(compressionQuality: 0.1)
                    multiPartData.append(imgData!, withName: "photo",fileName: fname!, mimeType: "image/jpeg")
                }
                
                
            }, to: url, method: .post) { (result) in
                print(result)
                switch result {
                case .success(let upload, _, _):
                    upload.responseString(completionHandler: { (response) in
                        print(response)
                        responceHandler(true, response)
                    })
    //                upload.responseJSON(completionHandler: { (response) in
    //                    print(response)
    //                    responceHandler(true, response)
    //                })
    //                upload.response { answer in
    //                    print("statusCode: \(answer.response?.statusCode ?? -200)")
    //                }
                    
                    
                case .failure(let encodingError):
                    print("multipart upload encodingError: \(encodingError)")
                    let data = DataResponse(request: nil, response: nil, data: nil, result: encodingError as! Result<String>)
                    responceHandler(false, data)
                }
            }
        }

    func putData(_ url:String, param: [String:Any]?, header: HTTPHeaders?, responceHandler:@escaping ((_ isSuccess: Bool, _ responce: DataResponse<Any>) -> Void)){
        
        Alamofire.request(url, method: .put, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print(response.result.value!)
                    responceHandler(true, response)
                }
                break
            case .failure(_):
                print(response.result.error!)
                responceHandler(false, response)
                break
                
            }
        }
    }
    
    
    
    func getImageData(_ url: String, responceHandler:@escaping ((_ isSuccess: Bool, _ responce: DataResponse<Data>) -> Void) ) {
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData { (response) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print(response.result.value!)
                    responceHandler(true, response)
                }
                break
                
            case .failure(_):
                print(response.result.error!)
                responceHandler(false, response)
                break
                
            }
        }
    }

}

    



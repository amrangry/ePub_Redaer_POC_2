//
//  ViewController+downloadable.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 27/11/2022.
//

import Foundation
import Alamofire

//typealias CallResponse<T> = ((NetworkResult<T>) -> Void)?
typealias ResultResponse<T> = ((Result<T, Error>) -> Void)
extension ViewController {
    
    func download(_ urlString: String, fileName: String, folderDirName: String, completion: @escaping ResultResponse<Any>) {
        var finalFileName = fileName
        let downloadsFolderName = folderDirName + "/"
        if (fileName.starts(with: downloadsFolderName) == false) {
            finalFileName = "\(downloadsFolderName)\(fileName)"
        }
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = FileHelper.shared.getFileURL(for: finalFileName) ?? URL(fileURLWithPath: finalFileName)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let progressQueue = DispatchQueue(label: "com.alamofire.progressQueue", qos: .utility)
        let request = AF.download(urlString,
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: nil,
                                  interceptor: nil,
                                  requestModifier: nil,
                                  to: destination)
            .validate(statusCode: 200 ... 500)
        //            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
        //                print("Progress: \(progress.fractionCompleted)")
        //            }
        //            .downloadProgress { progress in
        //                    print("Download Progress: \(progress.fractionCompleted)")
        //            }
            .downloadProgress(queue: progressQueue) { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData(queue: .main) { response in
                switch response.result {
                case .success:
                    if let destinationURL = response.fileURL?.path {
                        completion(.success(destinationURL))
                    } else {
                        let error = NSError(domain: "Network", code: 200) as Error
                        //"Couldn't get destination url"
                        completion(.failure(error))
                    }
                case .failure(let error):
                    // check if file exists before
                    if let destinationURL = response.fileURL {
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            // File exists, so no need to override it. simply return the path.
                            completion(.success(destinationURL))
                            print()
                        } else {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
                
            }
        request.resume()
    }
    
}

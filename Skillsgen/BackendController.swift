//
//  BackendController.swift
//  Skillsgen
//
//  Created by Sebastian Reinolds on 19/12/2017.
//  Copyright © 2017 Sebastian Reinolds. All rights reserved.
//

import Foundation

class BackendController {
    static let shared = BackendController()
    var enquiries: [Enquiry] = []
    
    func fetchBookings(month: Int, year: Int, completion: @escaping ([Booking]?) -> Void)  {
        let yearString = String(year)
        var monthString = ""
        if month < 10 {
            monthString = "0" + String(month)
        } else {
            monthString = String(month)
        }
        
        var components = URLComponents(url: Config.baseURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "query", value: "booking"),
            URLQueryItem(name: "mm", value: monthString),
            URLQueryItem(name: "yyyy", value: yearString),
            URLQueryItem(name: "pass", value: GeneratePass(KeyString: Config.KeyString))
            
        ]
        let url = components.url!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let bookings = try? jsonDecoder.decode([Booking].self, from: data)
            {
                completion(bookings)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchEnquiries(completion: @escaping (Bool) -> Void) {
        var lastEnquiry = 0
        if self.enquiries.count != 0 {
            lastEnquiry = self.enquiries[0].id
        }
        
        var components = URLComponents(url: Config.baseURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "query", value: "enquiries"),
            URLQueryItem(name: "last", value: String(lastEnquiry)),
            URLQueryItem(name: "pass", value: GeneratePass(KeyString: Config.KeyString))
        ]
        let url = components.url!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
               let enquiries = try? jsonDecoder.decode([Enquiry].self, from: data)
            {
                self.syncEnquiries(enquiries)
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    // Redo This! This is not robust, what if an enquiry is deleted? etc
    
    func syncEnquiries(_ enquiriesFromServer: [Enquiry]) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("enquiries").appendingPathExtension("plist")
        let propertyListDecoder = PropertyListDecoder()
        var newEnquiryList: [Enquiry] = []
        
        if let retrievedEnquiries = try? Data(contentsOf: archiveURL),
           let decodedEnquiries = try? propertyListDecoder.decode(Array<Enquiry>.self, from: retrievedEnquiries)
        {
            newEnquiryList = enquiriesFromServer + decodedEnquiries
        } else {
            newEnquiryList = enquiriesFromServer
        }
        
        self.enquiries = newEnquiryList
        writeEnquiries()
    }
    
    
    func updateEnquiry(enquiry: Enquiry) {
        for (i, _) in enquiries.enumerated() {
            if enquiries[i].id == enquiry.id {
                enquiries[i].viewed = true
                break
            }
        }
        writeEnquiries()
    }
    
    
    func writeEnquiries() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("enquiries").appendingPathExtension("plist")
        let propertyListEncoder = PropertyListEncoder()
        
        let encodedEnquiries = try? propertyListEncoder.encode(self.enquiries)
        try? encodedEnquiries?.write(to: archiveURL, options: .noFileProtection)
    }
    
    
    func resetEnquiries() {
        self.enquiries = []
        writeEnquiries()
        
    }
}

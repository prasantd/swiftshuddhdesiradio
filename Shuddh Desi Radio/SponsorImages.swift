//
//  SponsorImages.swift
//  Shuddh Desi Radio
//
//  Created by AtlantaLoaner2 on 6/12/19.
//  Copyright © 2019 Shuddh Desi Radio. All rights reserved.
//

import Foundation


struct SponsorsList: Decodable{
    struct Items:Codable{
        let companyLogo: String
        
    }
    
    let items: [Items]

}

struct PlayerTitle: Decodable{
    struct current_Track: Codable{
        let title: String
    }
    
    let current_track: current_Track
}


class DataExtractor
{
    var apiURLPath: URL!
    var sponsorImages: [String]! = [""]
    func GetSponsorsList(companyCompletionHandler: @escaping ([String]?, Error?) -> Void){
        #if DEBUG
        let apiURL = "https://shuddhdesiradio.wixsite.com/sdrradio/_functions-dev/getsponsorimages/m"
        #else
        let apiURL = "https://www.shuddhdesiradio.com/_functions/getsponsorimages/m"
        #endif

        guard
            let apiURLPath = URL(string: apiURL)
            else{return}
        
            URLSession.shared.dataTask(with: apiURLPath){(data,response,err) in
                
                guard let data = data else {return}

                do{
                    let sponsorsList = try JSONDecoder().decode(SponsorsList.self, from: data)
                    for i in sponsorsList.items{
                        let firstPart = i.companyLogo.split(separator:"/")
                        let companyCorrectURL = "https://static.wixstatic.com/media/"+firstPart[2]
                        self.sponsorImages.append(companyCorrectURL)
                        
                    }
                    
                    companyCompletionHandler (self.sponsorImages, nil)
                    
                }
                catch let jsonErr {
                   companyCompletionHandler (self.sponsorImages, jsonErr)
                }
            }.resume()
    }//func
    
    func GetPlayingInfoTitle(RadioPlayingInfoCompletionHandler: @escaping (String?, Error?) -> Void) {
      
        let apiURL = "https://public.radio.co/stations/se30891e37/status"

        
        guard
            let apiURLPath = URL(string: apiURL)
            else{return}
        
        URLSession.shared.dataTask(with: apiURLPath){(data,response,err) in
            
            guard let data = data else {return}
            
            do{
                print("Status returns /", data)
                let currentTrackInfo = try JSONDecoder().decode(PlayerTitle.self, from: data)
                
                RadioPlayingInfoCompletionHandler (currentTrackInfo.current_track.title, nil)
                
            }
            catch let jsonErr {
                RadioPlayingInfoCompletionHandler (nil, jsonErr)
            }
            }.resume()
    }
}//class

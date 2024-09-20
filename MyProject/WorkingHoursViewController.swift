//
//  WorkingHoursViewController.swift
//  MyProject
//
//  Created by MELİS on 17.08.2024.
//

import UIKit

class WorkingHoursViewController: UIViewController {
    
    @IBOutlet weak var openHoursLabel: UILabel!
    
    var restaurant: Restaurant!
    
    override func viewDidAppear(_ animated: Bool) {
        guard let restaurant = restaurant else {
            print("Error: restaurant is nil.")
            openHoursLabel.text = "nil"
            return
        }
        
        guard let operatingHours = restaurant.operatingHours, !operatingHours.isEmpty else {
            openHoursLabel.text = "No operating hours available"
            return
        }
        
        var hoursText = ""
        let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        
        for hour in operatingHours {
            let day = daysOfWeek[hour.day]
            let start = formatTime(hour.start)
            let end = formatTime(hour.end)
            let hoursL = "\(day): \(start) - \(end)\n"
            hoursText += hoursL
            hoursText += "\n"
        }
        
        openHoursLabel.text = hoursText
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    func formatTime(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }
        
        return time
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

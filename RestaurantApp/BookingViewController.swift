//
//  BookingViewController.swift
//  MyProject
//
//  Created by MELİS on 14.08.2024.
//

import UIKit
import FirebaseAuth

struct Reservation: Codable{
    var id: String!
    let userUuid: String!
    var restaurantId: String!
    var restaurantName: String
    var date: String
    var time: String
    var name: String
    var surname: String
    var numberOfGuests: Int
    var phone: String
}

class BookingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePickerView: UIPickerView!

    
    var reservations: [Reservation] = []
    var availableTimes: [String] = []
    var filteredTimes: [String] = []
    var restaurantDetail: Restaurant!
    
    var currentReservation: Reservation?

    override func viewWillAppear(_ animated: Bool) {
        fetchReservations(for: restaurantDetail.id) { reservations in
            if let reservations = reservations {
                self.reservations = reservations
            }else{
                print("no reservations found.")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "BOOK A TABLE"
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        backButton.tintColor = .black

        datePicker.minimumDate = Date()
        timePickerView.delegate = self
        timePickerView.dataSource = self
  
        // tarih değişikliklerini dinlemek için
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        filterTimes(for: datePicker.date)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker){
        filterTimes(for: sender.date)
        print(filteredTimes)
        timePickerView.reloadAllComponents()
        timePickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    func filterTimes(for date: Date){
        let day = Calendar.current.component(.weekday, from: date) //pzrtesi:2,salı:3,...,cumartesi:7,pazar:1
        let jsonDay = (day - 1 + 6) % 7 //0,1,2...,6
        print(jsonDay)
        
        if let hours = restaurantDetail.operatingHours?.first(where: { $0.day == jsonDay }){
            availableTimes = generateTimes(start: hours.start, end:hours.end)
            print(availableTimes)
        }else{
            print("days cant found")
            availableTimes = ["09:00", "10:00", "12:00", "14:00", "16:00", "18:00", "20:00"]
        }
        
        if reservations.isEmpty {
            // Eğer rezervasyon yoksa, sadece açık saatleri göster
            filteredTimes = availableTimes
        } else {
            // Rezervasyon varsa, bunları dikkate al
            filteredTimes = availableTimes.filter { !isTimeBooked(date: date, time: $0) }
        }
        timePickerView.reloadAllComponents()
        
    }
    
    func generateTimes(start: String, end: String) -> [String] {
        var slots: [String] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        
        
        guard let startTime = formatter.date(from: start),
              let endTime = formatter.date(from: end) else {
            print("Invalid start or end time format.")
            return slots
        }

        formatter.dateFormat = "HH:mm"
        
        // eğer bitiş saati başlangıç saatinden önce ise bir gün eklenir
        let endTimeAdjusted: Date
        if endTime <= startTime {
            endTimeAdjusted = Calendar.current.date(byAdding: .day, value: 1, to: endTime)!
        } else {
            endTimeAdjusted = endTime
        }
        
        var current = startTime
        while current < endTimeAdjusted {
            slots.append(formatter.string(from: current))
            current = current.addingTimeInterval(2 * 60 * 60) //2 saat ekler
        }
        
        print("Generated times: \(slots)")
        return slots
    }

    
    func isTimeBooked(date: Date, time: String) -> Bool {
        if reservations.isEmpty {
            print("reservations empty")
            return false
        }
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "HH:mm"
        //let formattedTime = dateFormatter.string(from: date)

        let formattedDate = formatDate(date)
        return reservations.contains { $0.date == formattedDate && $0.time == time }
    }


    func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredTimes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filteredTimes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = filteredTimes[row]
        label.textAlignment = .center
        label.textColor = .black
        return label

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPersonalD"{
            let indexTime = timePickerView.selectedRow(inComponent: 0)
            let time = filteredTimes[indexTime]
            let date = datePicker.date
            let formattedDate = formatDate(date)
            print(formattedDate)
            
            if currentReservation == nil {
                currentReservation = Reservation(id: nil, userUuid: Auth.auth().currentUser?.uid, restaurantId: restaurantDetail.id, restaurantName: restaurantDetail.name, date: formattedDate, time: time, name: "", surname: "", numberOfGuests: 0, phone: "")
            }else{
                currentReservation?.date = formattedDate
                currentReservation?.time = time
            }
            
            let destinationVC = segue.destination as! PersonalDetailsVC
            destinationVC.reservation = currentReservation
        }
    }
    
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {

        performSegue(withIdentifier: "toPersonalD", sender: nil)
       
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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

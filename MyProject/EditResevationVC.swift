//
//  EditResevationVC.swift
//  MyProject
//
//  Created by MELİS on 28.08.2024.
//

import UIKit

class EditResevationVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredTimes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filteredTimes[row]
    }
    

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePickerView: UIPickerView!
    
    var reservation: Reservation!
    var restaurantDetail: Restaurant!
    
    var reservations: [Reservation] = []
    var availableTimes: [String] = []
    var filteredTimes: [String] = []
    
    
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

        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(backButtonTapped))
        closeButton.tintColor = .black
        navigationItem.leftBarButtonItem = closeButton
        
        navigationItem.title = "Date and Time"
        
        
        datePicker.minimumDate = Date()
        timePickerView.delegate = self
        timePickerView.dataSource = self
  
        // tarih değişikliklerini dinlemek için
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        filterTimes(for: datePicker.date)
    }
    
    @objc func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker){
        filterTimes(for: sender.date)
        print(filteredTimes)
        timePickerView.reloadAllComponents()
        timePickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        let indexTime = timePickerView.selectedRow(inComponent: 0)
        let time = filteredTimes[indexTime]
        let date = datePicker.date
        let formattedDate = formatDate(date)
        reservation.date = formattedDate
        reservation.time = time
        if let ID = reservation.id {
            updateReservation(reservation, for: ID) { result in
                switch result {
                case .success:
                    print("Reservation updated successfully")
                    DispatchQueue.main.async {
                        self.showAlert2(title: "Update Successful", message: "", error: false)
                    }
                case .failure(let error):
                    print("Error updating reservation: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert2(title: "Update Failed", message: error.localizedDescription, error: true)
                    }
                }
            }
        }

    }
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteReservation(withId: reservation.id) { result in
            switch result {
            case .success:
                print("Reservation deleted successfully")
                self.reservation = nil
                DispatchQueue.main.async {
                    self.showAlert2(title: "Successful", message: "Reservation deleted successfully", error: false)
                }
            case .failure(let error):
                print("Error deleting reservation: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert2(title: "Failed", message: error.localizedDescription, error: true)
                }
            }
        }
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
    
    
    func showAlert2(title: String, message: String, error: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if error {
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okButton)
        }else{
            let okAction = UIAlertAction(title: "OK", style: .default) {_ in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
   

}

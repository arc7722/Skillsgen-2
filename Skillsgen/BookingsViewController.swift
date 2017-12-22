//
//  BookingsViewController.swift
//  Skillsgen
//
//  Created by Sebastian Reinolds on 19/12/2017.
//  Copyright © 2017 Sebastian Reinolds. All rights reserved.
//

import UIKit

class BookingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingDescription: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!
    
    
    let backendController = BackendController()
    var bookings: [Booking] = []
    var month = getCurrentMonthAndYear().month
    var year = getCurrentMonthAndYear().year
    
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        if self.month > 1 {
            self.month -= 1
        } else {
            self.month = 12
            self.year -= 1
        }
        self.updateUI()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if month < 12 {
            month += 1
        } else {
            month = 1
            year += 1
        }
        updateUI()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        retryButton.isHidden = true
        loadingView.backgroundColor = UIColor(displayP3Red: 0.27, green: 0.27, blue: 0.27, alpha: 0.7)
        loadingView.layer.cornerRadius = 10
        
        dateLabel.text = createDateLabelString(month: month, year: year)
        updateUI()
    }

    
    func updateUI() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        tableView.isHidden = true
        loadingView.isHidden = false
        backendController.fetchBookings(month: month, year: year) { (bookings) in
            if let bookings = bookings {
                DispatchQueue.main.async {
                    self.bookings = bookings
                    self.tableView.reloadData()
                    self.dateLabel.text = createDateLabelString(month: self.month, year: self.year)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.tableView.isHidden = false
                    self.loadingView.isHidden = true
                }
                
            } else {
                self.loadingDescription.text = "Something went wrong"
                self.loadingActivityIndicator.isHidden = true
                self.retryButton.isHidden = false
            }
        }
    }
    
    @IBAction func retryButtonTapped(_ sender: Any) {
        retryButton.isHidden = true
        updateUI()
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCellIdentifier", for: indexPath) as! BookingTableViewCell
        
        cell.cellDateFormatter.dateFormat = "d"
        let booking = bookings[indexPath.row]
        
        cell.dayOfMonthLabel?.text = cell.cellDateFormatter.string(from: booking.date)
        cell.courseLabel?.text = booking.course
        cell.trainerLabel?.text = booking.trainer
        cell.noOfDelegatesLabel?.text = String(booking.delCount)
        
        if let customer = booking.customer {
            cell.customerLabel?.text = customer
            cell.customerLabel.textColor = .green
        } else {
            cell.customerLabel?.text = "Public"
            cell.customerLabel.textColor = .blue
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BookingSegue" {
            let destination = segue.destination as! BookingViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            destination.booking = bookings[selectedIndexPath!.row]
        }
        
    }
    

}

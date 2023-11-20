//
//  FormListViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/20/23.
//

import UIKit

class FormListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadForms()
    }
    
    // MARK: PROPERTIES
    var forms: [Form] = []
    
    // MARK: FUNCTIONS
    
    func loadForms() {
        let form1 = Form(day: "Monday", time: "11", date: "11/9", ampm: "pm", firstName: "Jaymond", lastName: "richardson", spouse: "Taylor", address: "132424 23jk", zip: "80003", city: "Draper", state: "Utah", phone: "2087039282`", email: "GMAILS", numberOfWindows: "1", energyBill: "2", retailQuote: "1", financeOptions: "WEFA``", yearsOwned: "SF", reason: "SDFA", rate: "ASF", comments: "SF")
        let form2 = Form(day: "TUESDAY", time: "11", date: "11/9", ampm: "pm", firstName: "TAYLOR", lastName: "richardson", spouse: "Taylor", address: "132424 23jk", zip: "80003", city: "Draper", state: "Utah", phone: "2087039282`", email: "GMAILS", numberOfWindows: "1", energyBill: "2", retailQuote: "1", financeOptions: "WEFA``", yearsOwned: "SF", reason: "SDFA", rate: "ASF", comments: "SF")
        self.forms = [form1, form2]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "formCell", for: indexPath) as? FormTableViewCell else { return UITableViewCell() }
        
        
        let form = forms[indexPath.row]
        cell.setCellData(with: form)
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
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

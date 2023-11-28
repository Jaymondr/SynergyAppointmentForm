//
//  FormListViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/20/23.
//

import UIKit

class FormListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadForms()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .none
        setTitleAttributes()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        loadForms()
    }
    
    
    // MARK: PROPERTIES
    var forms: [Form] = []
    var upcomingAppointmentForms: [Form] = []
    var pastAppointmentForms: [Form] = []
    var sortedAppointmentForms: [Form] = []
    
    // SECTIONS
    let upcoming = 0
    let past = 1
    
    
    // MARK: FUNCTIONS
        
    func loadForms() {
        FirebaseController.shared.getForms { forms, error in
            if let error = error {
                print("Error fetching forms: \(error)")
            }
            for form in forms {
                print("Name: \(form.firstName)")
            }
            self.forms = forms
            self.splitForms(forms: forms)
            self.tableView.reloadData()
        }
    }
    
    func splitForms(forms: [Form]) {
        upcomingAppointmentForms.removeAll()
        pastAppointmentForms.removeAll()
        
        sortedAppointmentForms = forms.sorted {$0.date < $1.date}
        for form in sortedAppointmentForms {
            if form.date > Date() {
                upcomingAppointmentForms.append(form)
            } else {
                pastAppointmentForms.append(form)
            }
        }
        // SORT PAST FORMS NEWEST TO OLDEST
        pastAppointmentForms.sort { $0.date > $1.date}
    }
    
    func setTitleAttributes() {
        if let navigationController = self.navigationController {
            self.navigationItem.title = "FORMS"
            navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.eden]
            navigationController.navigationBar.titleTextAttributes?[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        }
    }
    
    
    // MARK: TABLEVIEW
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == upcoming ? "UPCOMING" : "PAST"
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == upcoming ? upcomingAppointmentForms.count : pastAppointmentForms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "formCell", for: indexPath) as? FormTableViewCell else { return UITableViewCell() }
        
        if indexPath.section == upcoming {
            // UPCOMING
            let form = upcomingAppointmentForms[indexPath.row]
            cell.setCellData(with: form)
           
            return cell

        } else {
            // Past
            let form = pastAppointmentForms[indexPath.row]
            cell.setCellData(with: form)
           
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    @objc private func refreshData(_ sender: Any) {
        loadForms()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            self.refreshControl.endRefreshing()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == upcoming {
            // UPCOMING
            UIAlertController.presentDismissingAlert(title: "Upcoming Appointments CANNOT Be Deleted", dismissAfter: 1.2)
            
        } else {
            // PAST
            let form = self.pastAppointmentForms[indexPath.row]
            UIAlertController.presentMultipleOptionAlert(message: "Are you sure you want to delete \(form.firstName) \(form.lastName)'s past appointment form?", actionOptionTitle: "DELETE", cancelOptionTitle: "CANCEL") {
                FirebaseController.shared.saveDeletedForm(form: form) { error in
                    if let error = error {
                        print("Error Saving Form: \(error)")
                        UIAlertController.presentDismissingAlert(title: "Error Deleting Form: \(form.firstName + " " + form.lastName)", dismissAfter: 1.2)
                        return
                    }
                    FirebaseController.shared.deleteForm(firebaseID: form.firebaseID) { error in
                        if let error = error {
                            print("Error Deleting Form: \(error)")
                            UIAlertController.presentDismissingAlert(title: "Error Deleting Form: \(form.firstName + " " + form.lastName)", dismissAfter: 1.2)
                            return
                        }
                    }
                    self.pastAppointmentForms.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFormDetail",
           let indexPath = tableView.indexPathForSelectedRow,
           let destinationVC = segue.destination as? FormDetailViewController {
            var selectedForm: Form
            if indexPath.section == upcoming {
                selectedForm = upcomingAppointmentForms[indexPath.row]
            } else {
                selectedForm = pastAppointmentForms[indexPath.row]
            }
            
            destinationVC.form = selectedForm
            destinationVC.delegate = self
        }
    }
}

extension FormListViewController: FormDetailViewDelegate {
    func didUpdate(form: Form) {
        if let index = forms.firstIndex(where: { $0.firebaseID == form.firebaseID }) {
            forms[index] = form
            print("Form names after: \(forms[index].firstName) \(form.firstName)")
            for form in forms {
                print("names: \(form.firstName)")
            }
            splitForms(forms: forms)
            tableView.reloadData()
        }
    }
}

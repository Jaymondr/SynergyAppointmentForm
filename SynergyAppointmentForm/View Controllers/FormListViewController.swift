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
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadForms()
    }
    
    
    // MARK: PROPERTIES
    var forms: [Form] = []

    
    // MARK: FUNCTIONS
        
    func loadForms() {
        FirebaseController.shared.getForms { forms, error in
            for form in forms {
                print("Name: \(form.firstName)")
            }
            self.forms = forms
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: TABLEVIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms.count
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
    
    @objc private func refreshData(_ sender: Any) {
        loadForms()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            self.refreshControl.endRefreshing()
        }
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

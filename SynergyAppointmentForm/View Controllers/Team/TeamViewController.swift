//
//  TeamViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 9/5/24.
//

import UIKit

class TeamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

    }
    
    // MARK: - PROPERTIES
    var members: [UserAccount] = []
    
    
    // MARK: - FUNCTIONS
    func setupView() {
        print("Setting up view")
        guard let user = UserAccount.currentUser, let branch = user.branch else { return }
        FirebaseController.shared.getActiveUsers(for: branch) { users, error in
            if let error = error {
                print("Error fetching users: \(error)")
            }
            print("Success fetching team. Member count: \(users.count)")
            self.members = users
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Rows member count: \(members.count)")
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as? TeamMemberTableViewCell else {
            print("No Cell"); return UITableViewCell()
        }

        let member = members[indexPath.row]
            cell.setCellData(with: member)
            cell.member = member
        print("Set cell data: \(member.firstName)")

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
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

//
//  FormListViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/20/23.
//

import UIKit

// MARK: - TODO
/*
 1. Add empty state UI ✅
 2. Add search bar ✅
 3. Add notification to select branch ✅
 4. Remove unused buttons for other branches
 5. Add account types for branch manager, director, owner
 6. Add analytics
 7. Add filters for owner/branch manager
 8. Add confetti when user makes sale
 9. Add goals
 10. Add follow up reminders
 11. Add partial sale feature-> keep track of partially sold homes to go back
 12. Add note screen when user swipes right
 13. Add update label when user swipes right
 */

class FormListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var addFormBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check for user
        if UserAccount.currentUser == nil {
            presentLoginChoiceVC()
        } else if UserAccount.currentUser?.branch == nil {
            showBranchSelectionAlert()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for subview in self.view.subviews {
            if subview is NotesView {
                subview.removeFromSuperview()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadForms()
        setTitleAttributes()
        
        searchBar.delegate = self
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSignInNotification), name: .signInNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSignOutNotification),
                                               name: .signOutNotification,
                                               object: nil)
        
    }
    
    deinit {
        // Remove the observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: PROPERTIES
    var forms: [Form] = []
    var upcomingAppointmentForms: [Form] = []
    var pastAppointmentForms: [Form] = []
    var sortedAppointmentForms: [Form] = []
    
    var formState: FormState {
        if forms.isEmpty {
            return .empty
        } else {
            return .populated
        }
    }
    
    // SECTIONS
    let upcoming = 0
    let past = 1

    // MARK: - BUTTONS
    @IBAction func addFormButtonPressed(_ sender: Any) {
        self.vibrateForButtonPress(.medium)
        
    }
    
    // MARK: FUNCTIONS
    // Loads forms for the current user
    func loadForms() {
        guard let user = UserAccount.currentUser else { return }
        FirebaseController.shared.getForms(for: user.firebaseID) { forms, error in
            if let error = error {
                print("Error fetching forms: \(error)")
            }
            for form in forms {
                print("Name: \(form.firstName)")
            }
            self.forms = forms
            self.splitForms(forms: forms)
        }
    }
    
    @objc func handleSignOutNotification() {
        // Reset the data array or perform any other necessary actions
        forms = []
        upcomingAppointmentForms = []
        pastAppointmentForms = []
        sortedAppointmentForms = []
        tableView.reloadData()
    }
    
    @objc func handleSignInNotification() {
        loadForms()
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Implement search functionality here
        filterForms(for: searchText)
        tableView.reloadData()
    }
    
    // Function to filter forms based on search text
    func filterForms(for searchText: String) {
        if searchText.isEmpty {
            splitForms(forms: forms)
        } else {
            var filteredForms = forms
            filteredForms = forms.filter { form in
                return form.firstName.lowercased().contains(searchText.lowercased()) ||
                form.lastName.lowercased().contains(searchText.lowercased()) || form.spouse.lowercased().contains(searchText.lowercased()) || form.city.contains(searchText.lowercased()) || form.phone.contains(searchText.lowercased()) ||
                form.outcome.rawValue.lowercased().contains(searchText.lowercased())
            }
            splitForms(forms: filteredForms)
        }
    }
    
    // Function to present the sign-in view controller
    func presentLoginChoiceVC() {
        // Replace "SignUpStoryboard" with the name of your storyboard file
        let storyboard = UIStoryboard(name: "SignUpScreen", bundle: nil)
        
        guard let loginChoiceVC = storyboard.instantiateViewController(withIdentifier: "LoginChoiceViewController") as? LoginChoiceViewController else { return }
        navigationController?.pushViewController(loginChoiceVC, animated: false)
    }
    
    // Separates the forms into upcoming and past for table view section
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
        self.tableView.reloadData()
    }
    
    // Sets title for Form list
    func setTitleAttributes() {
        if let navigationController = self.navigationController {
            self.navigationItem.title = "FORMS"
            navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.eden]
            navigationController.navigationBar.titleTextAttributes?[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        }
    }
    
    
    // MARK: TABLEVIEW FUNCTIONS
    func numberOfSections(in tableView: UITableView) -> Int {
        switch formState {
        case .empty:
            return 1
        case .populated:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch formState {
        case .empty:
            return ""
        case .populated:
            return section == upcoming ? "UPCOMING" : "PAST"
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch formState {
        case .empty:
            return 1
        case .populated:
            return section == upcoming ? upcomingAppointmentForms.count : pastAppointmentForms.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.vibrateForButtonPress(.medium)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch formState {
        case .empty:
            return configureEmptyCell(indexPath: indexPath)
        case .populated:
            return configurePopulatedCell(indexPath: indexPath)
        }
    }

    func configureEmptyCell(indexPath: IndexPath) -> UITableViewCell {
        let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyTableViewCell
        return emptyCell
    }

    func configurePopulatedCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "formCell", for: indexPath) as? FormTableViewCell else {
            return UITableViewCell()
        }

        if indexPath.section == upcoming {
            // UPCOMING
            let form = upcomingAppointmentForms[indexPath.row]
            cell.setCellData(with: form)
            cell.delegate = self
            cell.form = form

        } else {
            // Past
            let form = pastAppointmentForms[indexPath.row]
            cell.setCellData(with: form)
            cell.delegate = self
            cell.form = form
        }

        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    @objc private func refreshData(_ sender: Any) {
        loadForms()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let viewNotesAction = UIContextualAction(style: .normal, title: "Notes") { [weak self] (_, _, completion) in
            // Perform action when swiping left (view notes)
            if indexPath.section == self?.upcoming, let form = self?.upcomingAppointmentForms[indexPath.row] {
                self?.viewNotes(for: form)
            } else if indexPath.section == self?.past, let form = self?.pastAppointmentForms[indexPath.row] {
                // Implement the action you want for viewing notes
                self?.viewNotes(for: form)
            }
            completion(true)
        }
        
        /*
        let labelAction = UIContextualAction(style: .normal, title: "Label") { [weak self] (_, _, completion) in
            // Perform action when swiping left (view notes)
            if indexPath.section == self?.upcoming, let form = self?.upcomingAppointmentForms[indexPath.row] {
                self?.viewNotes(for: form)
            } else if indexPath.section == self?.past, let form = self?.pastAppointmentForms[indexPath.row] {
                // Implement the action you want for viewing notes
                self?.viewNotes(for: form)
            }
            completion(true)
        }
         */
        
        // Set appearance and other configurations for the "View Notes" action
        viewNotesAction.backgroundColor = UIColor.noteYellow // Customize the color as needed
        
        let configuration = UISwipeActionsConfiguration(actions: [viewNotesAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    // Implement the functions to handle view notes and delete actions
    private func viewNotes(for form: Form) {
        // Implement the action for viewing notes
        guard let notesViewController = UIStoryboard(name: "Notes", bundle: nil).instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController else {
            return
        }
        
        // Set the form for the NotesViewController
        notesViewController.form = form
        
        // Create a navigation controller to present the NotesViewController modally
        let navigationController = UINavigationController(rootViewController: notesViewController)
        
        // Present the navigation controller modally
        present(navigationController, animated: true, completion: nil)

    }
    

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if formState == .empty {
//            return
//        }
//        if indexPath.section == upcoming {
//            // UPCOMING
//            UIAlertController.presentDismissingAlert(title: "Upcoming Appointments CANNOT Be Deleted", dismissAfter: 1.2)
//            
//        } else {
//            // PAST
//            let form = self.pastAppointmentForms[indexPath.row]
//            UIAlertController.presentMultipleOptionAlert(message: "Are you sure you want to delete \(form.firstName) \(form.lastName)'s past appointment form?", actionOptionTitle: "DELETE", cancelOptionTitle: "CANCEL") {
//                FirebaseController.shared.saveDeletedForm(form: form) { [self] error in
//                    if let error = error {
//                        print("Error Saving Form: \(error)")
//                        self.vibrateForError()
//                        UIAlertController.presentDismissingAlert(title: "Error Deleting Form: \(form.firstName + " " + form.lastName)", dismissAfter: 1.2)
//                        return
//                    }
//                    FirebaseController.shared.deleteForm(firebaseID: form.firebaseID) { error in
//                        if let error = error {
//                            print("Error Deleting Form: \(error)")
//                            self.vibrateForError()
//                            UIAlertController.presentDismissingAlert(title: "Error Deleting Form: \(form.firstName + " " + form.lastName)", dismissAfter: 1.2)
//                            return
//                        }
//                    }
//                    if let index = forms.firstIndex(where: { $0.firebaseID == form.firebaseID }) {
//                        forms.remove(at: index)
//                    }
//                    self.splitForms(forms: forms)
//                }
//            }
//        }
//    }

    
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
        
        if segue.identifier == "toCreateForm",
           let destinationVC = segue.destination as? CreateFormViewController {
                destinationVC.delegate = self
        }
        
        if segue.identifier == "toProfileVC",
           let destinationVC = segue.destination as? ProfileViewController {
            destinationVC.forms = self.forms
        }
        
    }
}


// MARK: - EXTENSIONS
extension FormListViewController {
    enum FormState {
        case empty
        case populated
    }
}
extension FormListViewController: FormDetailViewDelegate {
    func didUpdate(form: Form) {
        if let index = forms.firstIndex(where: { $0.firebaseID == form.firebaseID }) {
            forms[index] = form
            splitForms(forms: forms)
            tableView.reloadData()
        }
    }
}

extension FormListViewController: FormViewDelegate {
    func didAddNewForm(_ form: Form) {
        if !forms.contains(where: { $0.firebaseID == form.firebaseID }) {
            print(forms.count)
            forms.append(form)
            print(forms.count)
            splitForms(forms: forms)
            tableView.reloadData()
        }
    }
    
    func didUpdateNew(_ form: Form) {
        if !forms.contains(where: { $0.firebaseID == form.firebaseID }),
           let index = forms.firstIndex(where: { $0.firebaseID == form.firebaseID }) {
            forms[index] = form
            splitForms(forms: forms)
            tableView.reloadData()
        }
    }
}

extension FormListViewController: NotesViewDelegate {
    func showNotesView(form: Form) {
        // Remove existing notes views
        for subview in self.view.subviews {
                    if subview is NotesView {
                        subview.removeFromSuperview()
                    }
                }
        let notesView = NotesView()
        notesView.form = form
        self.view.addSubview(notesView)
    }
}

extension FormListViewController {
    func showBranchSelectionAlert() {
        let alert = UIAlertController(title: "Please Select a Branch", message: nil, preferredStyle: .actionSheet)
        
        // Add actions for each branch
        for branch in Branch.allCases {
            let action = UIAlertAction(title: branch.rawValue, style: .default) { _ in
                // Handle the selected branch
                UserAccountController.shared.updateBranch(newBranch: branch)
            }
            alert.addAction(action)
        }
        
        // Add cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
}

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
 4. Remove unused buttons for other branches ✅
 5. Add account types for branch manager, director, owner
 6. Add analytics
 7. Add filters for owner/branch manager
 8. Add confetti when user makes sale
 9. Add goals
 10. Add follow up reminders
 11. Add partial sale feature-> keep track of partially sold homes to go back
 12. Add note screen when user swipes right
 13. Add update label when user swipes right
 14. Fix bug where delete form then create new form then form list shows deleted form until reload
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
        filterForms(for: searchText)
        tableView.reloadData()
    }
    
    func filterForms(for searchText: String) {
        if searchText.isEmpty {
            splitForms(forms: forms)
        } else {
            var filteredForms = forms
            filteredForms = forms.filter { form in
                return form.firstName.lowercased().contains(searchText.lowercased()) ||
                form.lastName.lowercased().contains(searchText.lowercased()) || form.spouse.lowercased().contains(searchText.lowercased()) || form.city.lowercased().contains(searchText.lowercased()) || form.phone.contains(searchText.lowercased()) ||
                form.outcome.rawValue.lowercased().contains(searchText.lowercased())
            }
            splitForms(forms: filteredForms)
        }
    }
    
    func presentLoginChoiceVC() {
        let storyboard = UIStoryboard(name: "SignUpScreen", bundle: nil)
        
        guard let loginChoiceVC = storyboard.instantiateViewController(withIdentifier: "LoginChoiceViewController") as? LoginChoiceViewController else { return }
        navigationController?.pushViewController(loginChoiceVC, animated: false)
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
        self.tableView.reloadData()
    }
    
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

        if let form = self.getFormForIndexPath(indexPath) {
            cell.setCellData(with: form)
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
            if let form = self?.getFormForIndexPath(indexPath) {
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
        
        viewNotesAction.backgroundColor = UIColor.noteYellow
        
        let configuration = UISwipeActionsConfiguration(actions: [viewNotesAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
        
    private func viewNotes(for form: Form) {
        guard let notesViewController = UIStoryboard(name: "Notes", bundle: nil).instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController else {
            return
        }
        
        notesViewController.form = form
        notesViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: notesViewController)
        
        present(navigationController, animated: true, completion: nil)

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in

            if let form = self?.getFormForIndexPath(indexPath) {
                if indexPath.section == self?.upcoming {
                    UIAlertController.presentDismissingAlert(title: "Cannot delete upcoming appointments", dismissAfter: 1.7)
                } else {
                    self?.confirmDelete(for: form)
                }
            }
            completion(true)
        }

        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    private func getFormForIndexPath(_ indexPath: IndexPath) -> Form? {
        if indexPath.section == upcoming {
            return upcomingAppointmentForms[indexPath.row]
        } else if indexPath.section == past {
            return pastAppointmentForms[indexPath.row]
        }
        return nil
    }

    private func confirmDelete(for form: Form) {
        UIAlertController.presentMultipleOptionAlert(
            message: "Are you sure you want to delete \(form.firstName) \(form.lastName)'s past appointment form?",
            actionOptionTitle: "DELETE",
            cancelOptionTitle: "CANCEL"
        ) { [weak self] in
            self?.deleteForm(form)
            if var forms = self?.forms, let index = forms.firstIndex(where: { $0.firebaseID == form.firebaseID }) {
                forms.remove(at: index)
                self?.splitForms(forms: forms)
                UIAlertController.presentDismissingAlert(title: "Deleted", dismissAfter: 0.5)
            }
        }
    }

    private func deleteForm(_ form: Form) {
        FirebaseController.shared.saveDeletedForm(form: form) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error Saving Form: \(error)")
                self.vibrateForError()
                UIAlertController.presentDismissingAlert(
                    title: "Error Deleting Form: \(form.firstName + " " + form.lastName)",
                    dismissAfter: 1.2
                )
                return
            }
        }
        
        FirebaseController.shared.deleteForm(firebaseID: form.firebaseID) { error in
            if let error = error {
                print("Error Deleting Form: \(error)")
                self.vibrateForError()
                UIAlertController.presentDismissingAlert(
                    title: "Error Deleting Form: \(form.firstName + " " + form.lastName)",
                    dismissAfter: 1.2
                )
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

extension FormListViewController: NotesViewDelegate {
    func didUpdateForm(with form: Form) {
        if !forms.contains(where: { $0.firebaseID == form.firebaseID }),
           let index = forms.firstIndex(where: { $0.firebaseID == form.firebaseID }) {
            forms[index] = form
            splitForms(forms: forms)
            tableView.reloadData()
        }
    }
}

extension FormListViewController: CreateFormViewDelegate {
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

extension FormListViewController {
    func showBranchSelectionAlert() {
        let alert = UIAlertController(title: "Please Select a Branch", message: nil, preferredStyle: .actionSheet)
        
        // Adds actions for each branch
        for branch in Branch.allCases {
            let action = UIAlertAction(title: branch.rawValue, style: .default) { _ in
                // Handle the selected branch
                UserAccountController.shared.updateBranch(newBranch: branch)
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // Set the position
            popoverController.permittedArrowDirections = []
        }
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
}

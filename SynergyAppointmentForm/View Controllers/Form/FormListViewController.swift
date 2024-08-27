//
//  FormListViewController.swift
//  SynergyAppointmentForm
//
//  Created by Jaymond Richardson on 11/20/23.
//

import UIKit
import MessageUI

// MARK: - TODO
/*
 1. Add empty state UI ✅
 2. Add search bar ✅
 3. Add notification to select branch ✅
 4. Remove unused buttons for other branches ✅
 5. Add account types for branch manager, director, owner ✅
 6. Add analytics ✅
 7. Add filters for owner/branch manager ✅
 8. Add confetti when user makes sale
 9. Add goals
 10. Add follow up reminders
 11. Add partial sale feature-> keep track of partially sold homes to go back
 12. Add note screen when user swipes right ✅
 13. Add update label when user swipes right ✅
 14. Fix bug where delete form then create new form then form list shows deleted form until reload
 15. Fix bug when managers save changes, their userID gets saved and appointment becomes theirs
 16. Add reason to form on Raleigh branch ✅
 17. Add teams
 18. Add team name 
 19. Improve look
 20. Add director view
 21. Only load first 20 appointments till user scrolls down
 22. Fix User Defaults duplicate data. (Check startup functions)
 */

class FormListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var confettiView: UIView!
    @IBOutlet weak var addFormBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            startUpFunctions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadForms()
        setTitleAttributes()
                
        // SEARCHBAR
        searchBar.delegate = self
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .none
        searchBar.setImage(UIImage(systemName: "slider.vertical.3"), for: .bookmark, state: .normal)

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
    var filteredForms: [Form] = []
    var upcomingAppointmentForms: [Form] = []
    var pastAppointmentForms: [Form] = []
    var sortedAppointmentForms: [Form] = []
    var isFiltering: Bool = false
    
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
            self.forms = forms
            self.splitForms(forms: forms)
        }
    }
    
    func loadForms(for firebaseIDs: [String]) {
        let dispatchGroup = DispatchGroup()
        for firebaseID in firebaseIDs {
            dispatchGroup.enter()
            FirebaseController.shared.getForms(for: firebaseID) { forms, error in
                defer {
                    dispatchGroup.leave()
                }
                if let error = error {
                    print("Error fetching forms: \(error)")
                } else {
                    self.filteredForms = forms
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.splitForms(forms: self.filteredForms)
        }
    }
    
    func startUpFunctions() {
        isFiltering = false
        // Check for user
        if UserAccount.currentUser == nil {
            presentLoginChoiceVC()
        } else if UserAccount.currentUser?.branch == nil {
            showBranchSelectionAlert()
        }
        
        // Set account type to default coordinator
        if UserAccount.currentUser?.accountType == nil {
            UserAccountController.shared.updateAccountType(to: .coordinator)
        }
        
        // Fetch User Account from Firebase and check for changes to the ACCOUNT TYPE or TEAM
        guard let currentUser = UserAccount.currentUser else { print("Current User Nil"); return }
        
        FirebaseController.shared.getUser(with: currentUser.firebaseID) { user, error in
            if let error = error {
                print("There was an error getting the user: \(error.localizedDescription)")
                return
            }
            
            guard let user = user, let accountType = user.accountType, let teamID = user.teamID else { print("User, accountType, or teamID is nil"); return }
            
            // Check for Account Type changes
            if currentUser.accountType != accountType {
                // Update the account type locally to match cloud data
                UserAccountController.shared.updateAccountType(to: accountType)
                // Update UserDefaults
                UserDefaults.standard.set(accountType.rawValue, forKey: "accountType")
            } else {
                print("Account type is already up to date.")
            }
            
            // Check for TeamID changes
            if currentUser.teamID != teamID {
                // Update UserDefaults to match firebase
                UserAccountController.shared.updateTeamID(to: teamID)
                UserDefaults.standard.set(teamID, forKey: Team.kTeamID)
                                
                // Fetch team name and update User Defaults
                FirebaseController.shared.getTeamName(teamID: teamID) { teamName, error in
                    UserAccountController.shared.teamName = teamName 
                    let userDefaultsTeamName = UserDefaults.standard.string(forKey: Team.kTeamName)
                    UIAlertController.presentDismissingAlert(title: "\(userDefaultsTeamName ?? "Team/Name")", dismissAfter: 2.0)
                }
            }
        }
        
        // SEARCHBAR
        searchBar.showsBookmarkButton = UserAccount.currentUser?.accountType != .coordinator
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = true
        print("handle search bar button click")
        guard let user = UserAccount.currentUser, let branch = user.branch else { return }
        FirebaseController.shared.getActiveUsers(for: branch) { users, error in
            if let error = error {
                self.isFiltering = false
                print("Error: \(error)")
                return
            }
            
            let alert = UIAlertController(title: "Filter Forms", message: nil, preferredStyle: .alert)
            let allAction = UIAlertAction(title: "All", style: .default) { _ in
                var firebaseIDs: [String] = []
                for user in users {
                    firebaseIDs.append(user.firebaseID)
                }
                self.loadForms(for: firebaseIDs)
                
            }
            alert.addAction(allAction)
            
            let sortedUsers = users.sorted { $0.firstName < $1.firstName }
            
            for user in sortedUsers {
                let userAction = UIAlertAction(title: "\(user.firstName.uppercased()) \(user.lastName.first?.uppercased() ?? "").", style: .default) { _ in
                    print("Selected user: \(user.firstName)")
                    self.loadForms(for: [user.firebaseID])
                }
                alert.addAction(userAction)
            }
        
            let okAction = UIAlertAction(title: "Cancel", style: .cancel)
        
            alert.addAction(okAction)
            self.present(alert, animated: true)
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
        var forms: [Form] {
            if isFiltering {
                return self.filteredForms
            } else {
                return self.forms
            }
        }
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
            navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.steel]
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
            cell.delegate = self
        }

        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    @objc private func refreshData(_ sender: Any) {
        loadForms()
        isFiltering = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let form = self.getFormForIndexPath(indexPath)

        let viewNotesAction = UIContextualAction(style: .normal, title: "Notes") { [weak self] (_, _, completion) in
            if let form = form {
                self?.viewNotes(for: form)
            }
            completion(true)
        }
        
        let updateLabelAction = UIContextualAction(style: .normal, title: "Outcome") { [weak self] (_, _, completion) in
            if let form = self?.getFormForIndexPath(indexPath) {
                let alert = UIAlertController(title: "Select Outcome Label", message: nil, preferredStyle: .alert)
                
                for outcome in Outcome.allCases {
                    let action = UIAlertAction(title: outcome.rawValue.capitalized, style: .default) { _ in
                        form.outcome = outcome
                        if outcome == .sold {
                            UIAlertController.presentDismissingAlert(title: "🎊CONGRATS!🎊", dismissAfter: 3.0)
                            self?.vibrateForSuccess()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self?.confettiView.isVisible = true
                                self?.confettiView.startConfetti()
                            }
                        }
                        FirebaseController.shared.updateForm(firebaseID: form.firebaseID, form: form) { updatedForm, error in
                            if let error = error {
                                UIAlertController.presentDismissingAlert(title: "Failed to Save", dismissAfter: 0.6)
                                print("Error: \(error)")
                                return
                            }
                            self?.tableView.reloadData()
                        }
                    }
                    
                    let color: UIColor
                    switch outcome {
                    case .lead: color = UIColor.outcomeYellow.withAlphaComponent(1.0)
                    case .pending: color = UIColor.steel
                    case .sold: color = UIColor.outcomeGreen
                    case .rescheduled: color = UIColor.outcomePurple
                    case .cancelled: color = UIColor.outcomeRed
                    case .ran: color = UIColor.outcomeBlue
                    case .ranIncomplete: color = UIColor.outcomeRed
                    }
                    
                    action.setValue(color, forKey: "titleTextColor")
                    alert.addAction(action)
                }
                
                alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel))
                self?.present(alert, animated: true)
            }
            completion(true)
        }

        viewNotesAction.backgroundColor = UIColor.noteYellow
        updateLabelAction.backgroundColor = switch form?.outcome {
        case .pending: UIColor.steel
        case .sold: UIColor.outcomeGreen
        case .rescheduled: UIColor.outcomePurple
        case .cancelled: UIColor.outcomeRed
        case .ran: UIColor.outcomeBlue
        case .ranIncomplete: UIColor.outcomeRed
        default: UIColor.steel
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [viewNotesAction, updateLabelAction])
        configuration.performsFirstActionWithFullSwipe = true
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
            destinationVC.hidesBottomBarWhenPushed = true
        }
        
        if segue.identifier == "toCreateForm",
           let destinationVC = segue.destination as? CreateFormViewController {
                destinationVC.delegate = self
            destinationVC.hidesBottomBarWhenPushed = true
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
        if let index = forms.firstIndex(where: { $0.firebaseID == form.firebaseID }) {
            // Update the existing form with the new form
            forms[index] = form
            print("Form updated at index \(index)")
        } else {
            // Add new form
            print(forms.count)
            forms.append(form)
            print(forms.count)
        }

        splitForms(forms: forms)
        tableView.reloadData()
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


    // MARK: - CELL DELEGATE FUNCTIONS
extension FormListViewController: FormTableViewCellDelegate, MFMessageComposeViewControllerDelegate {
    func getDirectionsButtonPressed(form: Form) {
        if form.address.isEmpty {
            UIAlertController.presentDismissingAlert(title: "No Address Found", dismissAfter: 1.0)
        } else {
            showMapOptions(form.address)
        }
    }
    
    func sendMessageButtonPressed(form: Form) {
        print("Send message delegate")
        askToSendTextMessage(form)
    }
    
    func callButtonPressed(form: Form) {
        print("Call button delegate")
        callPhoneNumber(form.phone)
    }
    
    private func showMapOptions(_ address: String) {
        let alertController = UIAlertController(title: "Open in Maps", message: "Choose an app", preferredStyle: .actionSheet)
        
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
            self.openGoogleMaps(for: address)
        }
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { _ in
            self.openAppleMaps(for: address)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addActions([appleMapsAction, googleMapsAction, cancelAction])
        
        self.present(alertController, animated: true)
        
    }
    
    private func openGoogleMaps(for address: String) {
        let urlString = "comgooglemaps://?q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let browserURLString = "https://www.google.com/maps/search/?api=1&query=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            if let browserURL = URL(string: browserURLString) {
                UIApplication.shared.open(browserURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func openAppleMaps(for address: String) {
        let urlString = "http://maps.apple.com/?q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func callPhoneNumber(_ phoneNumber: String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Your device cannot make phone calls", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func askToSendTextMessage(_ form: Form) {
        guard let user = UserAccount.currentUser else { return }
            let alertController = UIAlertController(title: "Send Text Message", message: nil, preferredStyle: .alert)

            let homeownerText = UIAlertAction(title: "Homeowner: Appt. Details", style: .default) { _ in
                let text = FormController.shared.createHomeownerText(from: form)
                self.sendTextMessage(form.phone, message: text)
            }
        
        let seeConversationAction = UIAlertAction(title: "See Conversation", style: .default) { _ in
            self.sendTextMessage(form.phone, message: "")
        }

            
        let directorConfirmationAction = UIAlertAction(title: "Director: Confirmation Text", style: .default) { _ in
            let text = FormController.shared.createDirectorConfirmationText(form: form)
            self.sendTextMessage(form.phone, message: text)
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if user.accountType != .coordinator {
            alertController.addAction(directorConfirmationAction)
        }

            alertController.addActions([homeownerText, seeConversationAction, cancelAction])

            present(alertController, animated: true, completion: nil)
        }

    private func sendTextMessage(_ phoneNumber: String, message: String) {
            if MFMessageComposeViewController.canSendText() {
                let messageVC = MFMessageComposeViewController()
                messageVC.body = message
                messageVC.recipients = [phoneNumber]
                messageVC.messageComposeDelegate = self

                present(messageVC, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Your device cannot send text messages", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }

        // MARK: - MFMessageComposeViewControllerDelegate

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            switch result {
            case .cancelled:
                print("Message cancelled")
            case .sent:
                print("Message sent")
            case .failed:
                print("Message failed")
            @unknown default:
                print("Unknown result")
            }
            controller.dismiss(animated: true, completion: nil)
        }
}




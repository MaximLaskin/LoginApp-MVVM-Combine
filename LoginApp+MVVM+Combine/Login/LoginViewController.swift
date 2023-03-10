//
//  ViewController.swift
//  LoginApp+MVVM+Combine
//
//  Created by Maxim on 09.03.2023.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var loginButton: UIButton!

    var viewModel = LoginViewModel()
    var cancellables = Set<AnyCancellable>()

    func initialState() {
        statusLabel.isHidden = true
        statusLabel.text = ""
        statusLabel.textColor = .systemGray2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        initialState()
    }

    func bindViewModel() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: loginTextField)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .assign(to: \.email, on:  viewModel)
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .assign(to: \.password, on:  viewModel)
            .store(in: &cancellables)

        viewModel.isLoginEnabled
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)

        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.statusLabel.isHidden = true
                    self?.loginButton.isEnabled = false
                    self?.loginButton.setTitle("Loading..", for: .normal)
                case .success:
                    self?.statusLabel.isHidden = false
                    self?.statusLabel.text = "Login success!"
                    self?.statusLabel.textColor = .systemGreen
                    self?.loginButton.setTitle("Login", for: .normal)
                case .failed:
                    self?.statusLabel.isHidden = false
                    self?.statusLabel.text = "Login failed =("
                    self?.statusLabel.textColor = .systemRed
                    self?.loginButton.setTitle("Login", for: .normal)
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        viewModel.submitLogin()
    }

}


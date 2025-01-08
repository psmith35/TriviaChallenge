//
//  QuizViewController.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/22/21.
//

import UIKit

class QuizViewController: UIViewController {
    
    let maxTextfieldCount: Int = 10
    
    func showResetPopUp(confirmAction: @escaping () -> Void) {
        let alertVC = UIAlertController(title: "Reset Game?", message: "Are you sure you want to do this? It can't be undone.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {_ in
            self.finishQuiz(completion: confirmAction)
        }))
        alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func finishQuiz(completion: @escaping () -> Void) {
        TCModel.wipeRandomCategories()
        TCModel.wipeTriviaQuestion()
        logHighScore(completion: completion)
    }
    
    func logHighScore(completion: @escaping () -> Void) {
        guard TCModel.currentScore > 0 else {
            completion()
            return
        }
        
        let completionClosure = {
            TCModel.wipeScore()
            TCModel.isFinishingQuiz = false
            completion()
        }
        
        let alertVC = UIAlertController(title: "Log Your Score", message: "Score: \(TCModel.currentScore)", preferredStyle: .alert)
        alertVC.addTextField() { newTextField in
            newTextField.placeholder = "Name"
            
            let countLabel = UILabel()
            countLabel.textColor = newTextField.textColor
            countLabel.textAlignment = .center
            countLabel.font = newTextField.font
            countLabel.text = self.getCharacterText(charCount: newTextField.text?.count)
            
            newTextField.rightView = countLabel
            newTextField.rightViewMode = .whileEditing
            newTextField.delegate = self
        }
        
        alertVC.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {_ in
            self.addHighScore(name: alertVC.textFields?.first?.text)
            completionClosure()
        }))
        alertVC.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: {_ in
            completionClosure()
        }))
        
        TCModel.isFinishingQuiz = true
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func addHighScore(name: String?) {
        let highScore = HighScore(context: DataController.shared.viewContext)
        highScore.name = name
        highScore.score = Int32(TCModel.currentScore)
        try? DataController.shared.viewContext.save()
    }
    
}

extension QuizViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let shouldChange = updatedText.count <= maxTextfieldCount
        
        if let label : UILabel = textField.rightView as? UILabel, shouldChange {
            label.text = getCharacterText(charCount: updatedText.count)
        }
        
        return shouldChange
    }
    
    func getCharacterText(charCount: Int?) -> String {
        return "\(charCount ?? 0)/\(maxTextfieldCount)"
    }
}

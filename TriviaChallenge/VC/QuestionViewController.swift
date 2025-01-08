//
//  QuizViewController.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/13/21.
//

import UIKit

class QuestionViewController: QuizViewController {

    @IBOutlet weak var scoreView: ScoreView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTableView: UITableView!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var confirmButtonClosure: (() -> Void)?
    var selectedAnswer: String?
    
    static let tintValue: CGFloat = 0.5
    static let greenTintColor = UIColor(red: 0.0, green: tintValue, blue: 0.0, alpha: 1.0)
    static let redTintColor = UIColor(red: tintValue, green: 0.0, blue: 0.0, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerTableView.tableFooterView = UIView(frame: CGRect.zero)
        scoreView.loadView()

        guard let question = TCModel.triviaQuestion else {
            categoryLabel.text = "Category: (blank)"
            questionLabel.text = "What is your question?"
            correctLabel.isHidden = true
            confirmButton.isEnabled = false
            return
        }
        
        categoryLabel.text = "Category: \(question.category)" + "\n" + "Difficulty: \(question.difficulty.rawValue.localizedCapitalized) (\(question.difficulty.pointsString))"
        questionLabel.text = question.question
        
        configureVCState()
        print(question.submittedAnswer ?? "N/A")
    }
    
    // MARK: - Helper
    func configureVCState() {
        answerTableView.reloadData()
        if let submittedAnswer = TCModel.triviaQuestion?.submittedAnswer {
            answerTableView.allowsSelection = false
            correctLabel.isHidden = false
            confirmButton.setTitle("Continue", for: .normal)

            if submittedAnswer == TCModel.triviaQuestion?.correctAnswer {
                correctLabel.text = "Correct!"
                correctLabel.textColor = UIColor.green
                confirmButtonClosure = {
                    self.popQuestionVC()
                }
            }
            else {
                correctLabel.text = "Incorrect"
                correctLabel.textColor = UIColor.red
                confirmButtonClosure = {
                    self.finishQuiz {
                        self.popQuestionVC()
                    }
                }
            }
        }
        else {
            correctLabel.isHidden = true
            confirmButton.isEnabled = false
            confirmButtonClosure = {
                self.confirmAnswer()
            }
        }
    }
    
    func confirmAnswer() {
        let alertVC = UIAlertController(title: "Is that your final answer?", message: selectedAnswer, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            guard let selectedAnswer = self.selectedAnswer else {
                return
            }
            TCModel.triviaQuestion?.submittedAnswer = selectedAnswer
            TCModel.updateTriviaQuestion()
            if selectedAnswer == TCModel.triviaQuestion?.correctAnswer {
                TCModel.updateScore(scoreAddition: TCModel.triviaQuestion?.difficulty.pointsValue ?? 0)
            }
            self.configureVCState()
        }))
        alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func popQuestionVC() {
        TCModel.wipeTriviaQuestion()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBAction
    @IBAction func resetPressed(_ sender: Any) {
        showResetPopUp {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        confirmButtonClosure?()
    }
    
}

extension QuestionViewController: UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TCModel.triviaQuestion?.answers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell")!
        
        guard let answer = TCModel.triviaQuestion?.answers[(indexPath as NSIndexPath).row] else {
            return cell
        }
        
        cell.textLabel?.text = answer
        cell.imageView?.image = nil
        
        if let submittedAnswer = TCModel.triviaQuestion?.submittedAnswer {
            if answer == TCModel.triviaQuestion?.correctAnswer {
                cell.backgroundColor = UIColor.green
                cell.imageView?.image = UIImage(systemName: "checkmark")
                cell.imageView?.tintColor = QuestionViewController.greenTintColor
            }
            else if answer == submittedAnswer && answer != TCModel.triviaQuestion?.correctAnswer {
                cell.backgroundColor = UIColor.red
                cell.imageView?.image = UIImage(systemName: "xmark")
                cell.imageView?.tintColor = QuestionViewController.redTintColor
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let answer = TCModel.triviaQuestion?.answers[(indexPath as NSIndexPath).row] else {
            return
        }
        selectedAnswer = answer
        confirmButton.isEnabled = true
    }
}

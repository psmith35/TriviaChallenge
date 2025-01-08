//
//  CategoryViewController.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/15/21.
//

import UIKit

class CategoryViewController: QuizViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scoreView: ScoreView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var difficultyControl: UISegmentedControl!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
        
    var selectedCategory: TriviaCategory?
    var selectedDifficulty: Difficulty?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryLabel.underline()
        difficultyLabel.underline()
        pointsLabel.text = ""
        categoryTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scoreView.loadView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if TCModel.isFinishingQuiz {
            finishQuiz {
                self.reset()
            }
        }
        else {
            self.setup()
        }
    }
    
    // MARK: - Helper
    func updateCotinueButton() {
        continueButton.isEnabled = selectedCategory != nil && selectedDifficulty != nil
    }
    
    func loadCategoryVC() {
        startOperation()
        TCClient.loadGameData(success: {
            self.stopOperation()
            TCModel.loadTriviaQuestion {
                self.pushQuestionVC()
            }
            self.setupCategoryVC()
        }, failure: {title, description in
            self.showErrorAlert(title: title, description: description, completion: {
                self.setupCategoryVC()
                self.stopOperation()
            })
        })
    }
    
    func setupCategoryVC() {
        if selectedCategory == nil {
            TCModel.loadRandomCategories()
            categoryTableView.reloadData()
        }
        if selectedDifficulty == nil {
            loadDifficultyControl()
        }
    }
    
    func resetCategoryVC() {
        TCModel.setRandomCategories()
        categoryTableView.reloadData()
        selectedCategory = nil
        loadDifficultyControl()
    }
    
    func loadDifficultyControl() {
        difficultyControl.selectedSegmentIndex = 0
        indexChanged(difficultyControl)
    }
    
    func setup() {
        if TCModel.triviaCategories != nil {
            setupCategoryVC()
        }
        else {
            loadCategoryVC()
        }
    }
    
    func reset() {
        if TCModel.triviaCategories != nil {
            resetCategoryVC()
        }
        else {
            loadCategoryVC()
        }
    }
    
    func pushQuestionVC() {
        let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewController")as! QuestionViewController
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
    
    func startOperation() {
        activityIndicatorView.startAnimating()
        self.navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = false
    }
    
    func stopOperation() {
        activityIndicatorView.stopAnimating()
        self.navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    func showErrorAlert(title: String, description: String, completion: (() -> Void)?) {
        let alertVC = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: completion)
    }

    // MARK: - IBAction
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        let titleString = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? ""
        guard let difficulty = Difficulty.init(rawValue: titleString.localizedLowercase) else {
            return
        }
        selectedDifficulty = difficulty
        pointsLabel.text = difficulty.pointsString
        updateCotinueButton()
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        showResetPopUp {
            self.reset()
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        guard let category = selectedCategory, let difficulty = selectedDifficulty else {
            return
        }
        startOperation()
        TCClient.getTriviaQuestions(amount: 1, triviaCategory: category, difficulty: difficulty, shouldTryAgain: true, success: { triviaQuestions in
            TCModel.wipeRandomCategories()
            TCModel.setTriviaQuestion(question: triviaQuestions[0])
            
            self.selectedCategory = nil
            self.selectedDifficulty = nil
            
            self.stopOperation()
            self.pushQuestionVC()
        }, failure: {title, description in
            self.showErrorAlert(title: title, description: description, completion: {self.stopOperation()})
        })
    }
    
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TCModel.selectedTriviaCategories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell")!
        
        guard let triviaCategory = TCModel.selectedTriviaCategories?[(indexPath as NSIndexPath).row] else {
            return cell
        }
        
        cell.textLabel?.text = "\(triviaCategory.name)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let triviaCategory = TCModel.selectedTriviaCategories?[(indexPath as NSIndexPath).row] else {
            return
        }
        selectedCategory = triviaCategory
        updateCotinueButton()
    }
    
}

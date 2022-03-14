//
//  WordleDataModel.swift
//  wordlefight
//
//  Created by Ivan Loh on 1/3/22.
//

import SwiftUI

class WordleDataModel: ObservableObject {
    @Published var guesses: [Guess] = []
    @Published var incorrectAttempts = [Int](repeating: 0, count: 6)
    @Published var toastText: String?
    @Published var showStats = false
    @AppStorage("hardMode") var hardMode = false
    
    var keyColors = [String : Color]()
    var matchedLetters = [String]()
    var misplacedLetters = [String]()
    var correctlyPlacedLetters = [String]()
    var answers = [String]()
    var selectedWord = ""
    var currentWord = ""
    var tryIndex = 0
    var inPlay = false
    var gameOver = false
    var toastWords = ["Genius", "Impressive", "Splendid", "Magnificent", "Great", "Phew"]
    var currentStat: Statistic
    
    var gameStarted: Bool {
        !currentWord.isEmpty || tryIndex > 0
    }
    
    var disabledKeys: Bool {
        !inPlay || currentWord.count == 5
    }
    
    init() {
        currentStat = Statistic.loadStat()
        newGame()
    }
    
    // MARK: - SETUP
    func newGame() {
        populateDefaults()
//        selectedWord = Global.commonWords.randomElement()!
        getSelectedWord()
        selectedWord = answers.randomElement()?.uppercased() ?? "after".uppercased()
        print(selectedWord)
        correctlyPlacedLetters = [String](repeating: "-", count: 5)
        currentWord = ""
        inPlay = true
        tryIndex = 0
        gameOver = false
    }
    
    func populateDefaults() {
        guesses = []
        for index in 0...5 {
            guesses.append(Guess(index: index))
        }
        //reset keyboard colors
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for char in letters {
            keyColors[String(char)] = .unused
        }
        matchedLetters = []
        misplacedLetters = []
    }
    
    func getSelectedWord() {
        
        var arrayOfStrings: [String]?

            do {
                // This solution assumes  you've got the file in your bundle
                if let path = Bundle.main.path(forResource: "wordsEasy", ofType: "txt"){
                    let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                    arrayOfStrings = data.components(separatedBy: "\n")
                    answers = arrayOfStrings!
                }
            } catch let err as NSError {
                // do something with Error
                print(err)
            }
    }
    
    // MARK: - GMAE PLAY
    func addToCurrentWord(_ letter: String) {
        currentWord += letter
        updateRow()
    }
    
    func enterWord() {
        print("currentWord: \(currentWord)")
        print("selectedWord: \(selectedWord)")
        if currentWord == selectedWord {
            gameOver = true
            print("You Win")
            setCurrentGuessColors()
            currentStat.update(win: true, index: tryIndex)
            showToast(with: toastWords[tryIndex])
            inPlay = false
        } else {
            if answers.map({ $0.uppercased() }).contains(currentWord) {
                if hardMode {
                    if let toastString = hardCorrectCheck() {
                        showToast(with: toastString)
                        return
                    }
                    if let toastString = hardMisplacedCheck() {
                        showToast(with: toastString)
                        return
                    }
                }
                setCurrentGuessColors()
                tryIndex += 1
                currentWord = ""
                if tryIndex == 6 {
                    currentStat.update(win: false)
                    gameOver = true
                    inPlay = false
                    showToast(with: selectedWord)
                }
            } else {
                withAnimation {
                    self.incorrectAttempts[tryIndex] += 1
                }
                showToast(with: "Not in Word List")
                incorrectAttempts[tryIndex] = 0
            }
        }
    }
    
    func removeLetterFromCurrentWord() {
        currentWord.removeLast()
        updateRow()
    }
    
    func updateRow() {
        let guessWord = currentWord.padding(toLength: 5, withPad: " ", startingAt: 0)
        guesses[tryIndex].word = guessWord
    }
    
    func verifyWord() -> Bool {
        UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: currentWord)
    }
    
    func hardCorrectCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for i in 0...4 {
            if correctlyPlacedLetters[i] != "-" {
                if guessLetters[i] != correctlyPlacedLetters[i] {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .ordinal
                    return "\(formatter.string(for: i + 1)!) Letter must be `\(correctlyPlacedLetters[i])`."
                }
            }
        }
        return nil
    }
    
    func hardMisplacedCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for letter in misplacedLetters {
            if !guessLetters.contains(letter) {
                return ("Must contain the letter `\(letter)`.")
            }
        }
        return nil
    }
    
    func setCurrentGuessColors() {
        let correctLetters = selectedWord.map { String($0) }
        var frequency = [String : Int]()
        for letter in correctLetters {
            frequency[letter, default: 0] += 1
        }
        for index in 0...4 {
            let correctLetter = correctLetters[index]
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if guessLetter == correctLetter {
                guesses[tryIndex].bgColors[index] = .correct
                if !matchedLetters.contains(guessLetter) {
                    matchedLetters.append(guessLetter)
                    keyColors[guessLetter] = .correct
                }
                if misplacedLetters.contains(guessLetter) {
                    if let index = misplacedLetters.firstIndex(where: {$0 == guessLetter}) {
                        misplacedLetters.remove(at: index)
                    }
                }
                correctlyPlacedLetters[index] = correctLetter
                frequency[guessLetter]! -= 1
            }
        }
        
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if correctLetters.contains(guessLetter)
                && guesses[tryIndex].bgColors[index] != .correct
                && frequency[guessLetter]! > 0 {
                print("zzz") // THIS IS CORRECT
                keyColors[guessLetter] = .misplaced
                guesses[tryIndex].bgColors[index] = .misplaced
                if !misplacedLetters.contains(guessLetter) && matchedLetters.contains(guessLetter) {
                    print("IS THIS CALLED????!?!?!")
                    misplacedLetters.append(guessLetter)
                    keyColors[guessLetter] = .misplaced
                }
                frequency[guessLetter]! -= 1
            }
        }
        
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if keyColors[guessLetter] != .correct && keyColors[guessLetter] != .misplaced {
                keyColors[guessLetter] = .wrong
            }
        }
        
        flipCards(for: tryIndex)
    }
    
    func flipCards(for row: Int) {
        for col in 0...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(col) * 0.2) {
                self.guesses[row].cardFlipped[col].toggle()
            }
        }
    }
    
    func showToast(with text: String?) {
        withAnimation {
            toastText = text
        }
        withAnimation(Animation.linear(duration: 0.2).delay(3)) {
            toastText = nil
            if gameOver {
                withAnimation(Animation.linear(duration: 0.2).delay(3)) {
                    showStats.toggle()
                }
            }
        }
    }
    
    func shareResult() {
            let stat = Statistic.loadStat()
            let results = guesses.enumerated().compactMap { $0 }
            var guessString = ""
            for result in results {
                if result.0 <= tryIndex {
                    guessString += result.1.results + "\n"
                }
            }
            let resultString = """
    Wordle \(stat.games) \(tryIndex < 6 ? "\(tryIndex + 1)/6" : "")
    \(guessString)
    """
            print(resultString)
            let activityController = UIActivityViewController(activityItems: [resultString], applicationActivities: nil)
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                UIWindow.key?.rootViewController!
                    .present(activityController, animated: true)
            case .pad:
                activityController.popoverPresentationController?.sourceView = UIWindow.key
                activityController.popoverPresentationController?.sourceRect = CGRect(x: Global.screenWidth / 2,
                                                                                      y: Global.screenHeight / 2,
                                                                                      width: 200,
                                                                                      height: 200)
                UIWindow.key?.rootViewController!.present(activityController, animated: true)
            default:
                break
            }
        }
}

//
//  ViewController.swift
//  Experiment
//
//  Created by Pulkit Kaushik on 10/12/18.
//  Copyright © 2018 Pulkit Kaushik. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    // MARK:- IBOutlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var imageSwitch: UISwitch!
    @IBOutlet weak var lblForArrayCount: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    
    // MARK:- Local Variables
    let disposeBag = DisposeBag()
    var namesArray: Variable<[String]> = Variable([])
    var filteredArray: Variable<[String]> = Variable([])
    var isImageVisible = true
    var randomInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiBinding()
        // URL Request
//        sendSimpleUrlRequest()
        sendComplexUrlRequest()
        
        // Map vs Flat Map
//        differenceBetweenMapAndFlatMap()
        
        // Call Dispose Manually
//        callDisposeManually()
        
        // Call Custom Observable
//        customObservable()
        
        // Timer Observables
//        timerObservables()
        
        // Single Trait
//        useSingleTrait()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    /// Add Name Button Action
    ///
    /// - Parameter sender: sender
    @IBAction func addNameBtnAction(_ sender: Any) {
        
        randomInt += 1
        let newName = "Random Name \(randomInt)"
        var namesArrayValue = namesArray.value
        namesArrayValue.insert(newName, at: 0)
        namesArray.value = namesArrayValue
    }
    
    /// UI Binding
    func uiBinding() {
        
        Observable.combineLatest(
            namesArray.asObservable(),
            imageSwitch.rx.isOn,
            txtField.rx.text)
            .throttle(0, scheduler: MainScheduler.instance)
            .bind { [weak self] (updatedArray, isSwitchOn, searchText) in
                
                print("Updated Array is \(updatedArray)")
                print("Swich State is \(isSwitchOn)\nSearch Text is \(String(describing: searchText))")
                self?.isImageVisible = isSwitchOn
                self?.filteredArray.value = (self?.namesArray.value.filter({ (name) -> Bool in
                    return name.lowercased().hasPrefix(searchText?.lowercased() ?? "")
                }))!
        }
        .disposed(by: disposeBag)
        
        // Data binding with UI
        let sharedObservable = filteredArray.asObservable().share(replay: 1)
        
        // Data binding with Label for Array Count
        sharedObservable
            .map { new in
                return "Array count is \(new.count)"
            }
            .bind(to: lblForArrayCount.rx.text)
            .disposed(by: disposeBag)
        
        // Data binding with Label for Array First Name
        sharedObservable
            .map { new in
                return new.first
            }
            .bind(to: lblFirstName.rx.text)
            .disposed(by: disposeBag)
        
        // Data binding with table view
        sharedObservable
            .bind(to: tblView.rx.items(cellIdentifier: String(describing: ViewControllerTVC.self))) { [weak self] row, element, cell in

                print("In Table View Binding")
                print("\(row)")

                if let cellToBind = cell as? ViewControllerTVC {
                    cellToBind.setCellUIAndData(with: (self?.imageSwitch.isOn)!, andName: element)
                }
        }
        .disposed(by: disposeBag)
    }
    
    @IBAction func refreshBtnAction(_ sender: Any) {
        imageSwitch.isOn = true
        txtField.text = ""
        
        // Call Subscriptions programmatically
        imageSwitch.sendActions(for: .valueChanged)
        txtField.sendActions(for: .valueChanged)
    }
    
    /// Call Dispose Manually in order to clean up resources
    func callDisposeManually() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
            .subscribe { event in
                print("Calling Dispose Manually \(event)")
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        
        subscription.dispose()
    }
    
    /// Custom Observable
    func customObservable() {
        let stringCounter = myFrom(["first", "second"])
        
        print("Started ----")
        
        // first time
        stringCounter
            .subscribe(onNext: { n in
                print("In first time \(n)")
            })
        
        print("----")
        
        // again
        stringCounter
            .subscribe(onNext: { n in
                print("In Again \(n)")
            })
        
        print("Ended ----")
    }
    
    func myFrom<E>(_ sequence: [E]) -> Observable<E> {
        return Observable.create { observer in
            for element in sequence {
                observer.on(.next(element))
                print("Inside custom method loop")
            }
            print("Inside custom method")
            observer.on(.completed)
            return Disposables.create()
        }
    }
}

// MARK: - Timer Observables
extension ViewController {
    
    func timerObservables() {
        
        let counter = myInterval(0.1)
        
        print("Started ----")
        
        let subscription = counter
            .subscribe(onNext: { n in
                print(n)
                print("///////////////////////////\nResource Count is \(RxSwift.Resources.total)\n///////////////////////////")
            })
        
        print("Before Calling Thread Sleep")
        Thread.sleep(forTimeInterval: 2)
        
        print("After Calling Thread Sleep")
        subscription.dispose()
        
        print("Ended ----")
        
    }
    
    func myInterval(_ interval: TimeInterval) -> Observable<Int> {

        print("My interval function called")
        return Observable.create({ (observer) -> Disposable in
            print("subscribed")

            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer.schedule(deadline: DispatchTime.now() + interval, repeating: interval)
            let cancel = Disposables.create {
                print("Disposed")
                timer.cancel()
            }

            var next = 0
            timer.setEventHandler(handler: {
                if cancel.isDisposed {
                    print("Disposed has been called")
                    return
                }
                observer.on(.next(next))
                next += 1
            })
            timer.resume()
            return cancel
        })
    }
}

// MARK: - Difference between Map and Flat Map
extension ViewController {
    
    func differenceBetweenMapAndFlatMap() {
        
        let arrayOfStudentsName = [
            "Pulkit",
            "Kunal",
            "Mayank",
            "Ved"
        ]
        
        
        let source1 = Observable.from(arrayOfStudentsName)
            .map { new in
                return "Hello \(new)"
        }
        .subscribe(onNext: { newValue in
                print("New Value is \(newValue)")
        })
        
        let source2 = Observable.from(arrayOfStudentsName)
            .flatMap { new in
                return Observable.of("Hello \(new)")
        }
        .debug("In Flat Map")
        .subscribe(onNext: { newValue in
                print("New Value in flat map is \(newValue)")
        })
    }
}

// MARK: - URL requests
extension ViewController {
    
    func sendSimpleUrlRequest() {
        
        let req = URLRequest(url: URL(string: "http://en.wikipedia.org/w/api.php?action=parse&page=Pizza&format=json")!)
        
        let responseJSON = URLSession.shared.rx.json(request: req)
        let cancelRequest = responseJSON
            .subscribe(onNext: { json in
                print("JSON is \(json)")
            })
        
        Thread.sleep(forTimeInterval: 3.0)
        
        cancelRequest.disposed(by: disposeBag)
    }
    
    /// Send complex url request
    func sendComplexUrlRequest() {

        // Show Loader
        showLoader()
        
        // Successful Response Url
        var req = URLRequest(url: URL(string: "https://app.fakejson.com/q")!)
        
        // Error Response Url
//        var req = URLRequest(url: URL(string: "https://fakejson.com/errors/400")!)
        
        let param: Dictionary<String, Any> = [
            "token": "s-Ylg2Xx0M31ROmTLeQmRw",
            "data": [
                "id": "personNickname",
                "email": "internetEmail",
                "gender": "personGender",
                "last_login": [
                    "date_time": "dateTime|UNIX",
                    "ip4": "internetIP4"
                ],
                "_repeat": 20
            ]
        ]
        
        let jsonParam = try! JSONSerialization.data(withJSONObject: param, options: [])
        
        req.httpBody = jsonParam
        req.setValue("application/json;", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"

        // Form Url Session
        URLSession.shared.rx.response(request: req)
            .debug("my request") // this will print out information to console
            .map{ serverResponse -> [String] in
                
                let (response, data): (HTTPURLResponse, Data) = serverResponse
                
                // Check for status code
                if 200..<300 ~= response.statusCode {
                    let serverResponse = try! JSONSerialization.jsonObject(with: data, options: [])
                    
                    // Check for server response type
                    if let serverResponse = serverResponse as? Array<Dictionary<String, Any>> {
                        return self.cacheServerData(from: serverResponse).value
                    }
                }
                throw NSError.init(domain: "", code: response.statusCode, userInfo: ["errorMessage" : "Unknown Error Bro"])
            }
            .subscribe(onNext: { (arrayOfServerNames) in
                self.namesArray.value = arrayOfServerNames
                print("Server Names are \(arrayOfServerNames)")
            }, onError: { (error) in
                let errorFromServer = error as NSError
                print("Error is \(errorFromServer)")
                self.hideLoader()
            }, onCompleted: {
                // Hide Loader
                self.hideLoader()
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    func cacheServerData(from serverResponse: Array<Dictionary<String, Any>>) ->  Variable<[String]> {
        
        // Array of names string
        var arrayofStringNames = Array<String>()
        
        // Iterate over server response array
        for (_, dic) in serverResponse.enumerated() {
            arrayofStringNames.append(dic["email"] as! String)
        }
        return Variable(arrayofStringNames)
    }
}

// MARK: - Show Loader
extension UIViewController {
    
    func showLoader() {
        let alertController = UIAlertController.init(title: "Please Wait...", message: "Fetching Data From Server", preferredStyle: .alert)
        
        // Activity Indicator View
        let activityIndicatorView = UIActivityIndicatorView.init(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50))
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.startAnimating()
        
        alertController.view.addSubview(activityIndicatorView)
        present(alertController, animated: true, completion: nil)
    }
    
    func hideLoader() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Single Trait
extension ViewController {
    
    func useSingleTrait() {
        getRepo("ReactiveX/RxSwift")
            .subscribe { event in
                switch event {
                case .success(let json):
                    print("Successful json is \(json)")
                case .error(let error):
                    print("Error in json is \(error)")
                }
        }
        .disposed(by: disposeBag)
    }
    
    func getRepo(_ repo: String) -> Single<[String: Any]> {
        return Single<[String: Any]>.create(subscribe: { (single) -> Disposable in
            
            let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/\(repo)")!) { data, _, error in
                
                if let error = error {
                    print("Before Error Trait")
                    single(.error(error))
                    print("After Error Trait")
                    return
                }
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                    let result = json as? [String: Any] else {
                        print("Before Error Trait 1")
                        single(.error(NSError.init(domain: "", code: 200, userInfo: ["errorMessage": "Can not parse response"])))
                        print("After Error Trait 1")
                        return
                }
                print("Before Success Trait")
                single(.success(result))
                print("After Success Trait")
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        })
    }
    
}




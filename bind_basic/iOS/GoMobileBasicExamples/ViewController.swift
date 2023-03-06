//
//  ViewController.swift
//  GoMobileBasicExamples
//
//  Created by hideyuki machida on 2023/02/28.
//

import UIKit
import Example

class ViewController: UIViewController {

    /// GO側で定義された Request（iOSではExampleRequestProtocol） を継承
    class Request: NSObject, ExampleRequestProtocol {
        class Item: NSObject, ExampleRequestItemProtocol {
            let _url: String

            init(url: String) {
                self._url = url
            }

            func url() -> String {
                return self._url
            }
        }

        let _id: String
        let _item: Item

        init(id: String, url: String) {
            self._id = id
            self._item = Item(url: url)
        }

        /// プロトコル仕様 : Item -> GO側で定義された RequestItem（iOSではExampleRequestItemProtocol）
        func item() -> ExampleRequestItemProtocol? {
            return self._item
        }

        /// プロトコル仕様 : Id
        func id_() -> String {
            return self._id
        }

        /// プロトコル仕様 : go側からのコールバック
        func callback(_ success: Bool) {
            print("callback success : ", success)
        }
    }

    @IBOutlet weak var textView: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = ExampleGreetings("金木タン") + "\n"
        self.textView.text! += String(ExampleGetBool(true)) + "\n"
        let person: ExamplePerson? = ExampleGetPerson()
        self.textView.text! += person!.name + "\n"
        self.textView.text! += String(data: ExampleGetByte()!, encoding: .utf8)! + "\n"

        ExampleSetByte("金木タン4".data(using: .utf8))
        ExampleSetRequest(Request(id: "1", url: "https://www.google.com"))
    }


}


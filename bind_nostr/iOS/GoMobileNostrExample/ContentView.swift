//
//  ContentView.swift
//  GoMobileNostrExample
//
//  Created by hideyuki machida on 2023/02/28.
//

import SwiftUI
import Example
import Combine

let npub: String = "npub12xyhzwc5suvlm69vwty3467rz55sujgd0ng7zkta8w98crafg6ssv57r3v"
let nsec: String = "nsec1xwzmwuxds2wfcnxvg85qup7gh3chv0ky9xpxwy2krsucv5vs45fq0mpwss"
let relay: String = "ws://localhost:9001"


struct ContentView: View {
    @ObservedObject var vm: ViewModel = ViewModel()
    @State private var showingModal = false
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach($vm.events, id: \.self) { $event in
                    VStack {
                        Text("ID : \(event.id_)").frame(maxWidth: .infinity, alignment: .leading)
                        Text("PubKey : \(event.pubKey)").frame(maxWidth: .infinity, alignment: .leading)
                        Text("CreatedAt : \(event.createdAt)").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Kind : \(event.kind)").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Content : \(event.content)").frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            Button(action: {
                self.showingModal = true
            }) {
                Text("＋")
            }.sheet(isPresented: $showingModal) {
                ModalView()
            }.frame(width: 100, height: 100).foregroundColor(.white).background(.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ModalView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var vm: ModalViewModel = ModalViewModel()
    @State private var content = ""
    var body: some View {
        VStack {
             TextField("メッセージ", text: $content)
                 .padding()
                 .foregroundColor(.red)
            Button(action: {
                Task {
                    let result: Bool = await vm.pub(content: content)
                    print("result : ", result)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("送信")
            }.frame(width: 360, height: 64).foregroundColor(.white).background(.blue)
         }
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView()
    }
}

class ViewModel: ObservableObject {

    @Published var events: [ExampleNostrEvent] = []

    private let request: SubRequest
    private var cancellable: AnyCancellable?

    init() {
        // Requestを作成
        self.request = SubRequest(
            id: UUID().uuidString,
            npub: npub,
            relay: relay)

        // requestのコールバックをメインスレッドで受け取り、eventsにinsert
        self.cancellable = self.request.event
            .compactMap{ $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (event: ExampleNostrEvent) in
                self?.events.insert(event, at: 0)
            }

        // go側で goroutine を使用しているため、別スレッドで実装
        Task {
            Example.ExampleNostrSub(self.request)
        }
    }
}

extension ViewModel {
    /// GO側で定義された SubRequest（iOSではExampleSubRequestProtocol） を継承
    class SubRequest: NSObject, ExampleSubRequestProtocol {
        let event: CurrentValueSubject<ExampleNostrEvent?, Never> = CurrentValueSubject<ExampleNostrEvent?, Never>(nil)

        let _id: String
        let _npub: String
        let _relay: String

        init(id: String, npub: String, relay: String) {
            self._id = id
            self._npub = npub
            self._relay = relay
        }

        /// プロトコル仕様 : Id
        func id_() -> String {
            return self._id
        }
        
        /// プロトコル仕様 : Npub
        func npub() -> String {
            return self._npub
        }
        
        /// プロトコル仕様 : Relay
        func relay() -> String {
            return self._relay
        }

        /// プロトコル仕様 : go側からのコールバック
        func onEvent(_ event: ExampleNostrEvent?) {
            self.event.send(event)
        }
    }
}


class ModalViewModel: ObservableObject {

    private var cancellable: AnyCancellable?

    func pub(content: String) async -> Bool {
        let request = PubRequest(
            id: UUID().uuidString,
            nsec: nsec,
            content: content,
            relay: relay)

        return await withCheckedContinuation { [weak self] continuation in
            guard let self = self else { continuation.resume(returning: false); return }
            self.cancellable?.cancel()
            self.cancellable = request.result
                .compactMap{ $0 }
                .receive(on: DispatchQueue.main)
                .sink { (result: Bool) in
                    continuation.resume(returning: result)
                    self.cancellable?.cancel()
                }

            Example.ExampleNostrPub(request)
        }
    }
}

extension ModalViewModel {
    /// GO側で定義された PubRequest（iOSではExamplePubRequestProtocol） を継承
    class PubRequest: NSObject, ExamplePubRequestProtocol {
        let result: CurrentValueSubject<Bool?, Never> = CurrentValueSubject<Bool?, Never>(nil)
        
        let _id: String
        let _nsec: String
        let _content: String
        let _relay: String

        init(id: String, nsec: String, content: String, relay: String) {
            self._id = id
            self._nsec = nsec
            self._content = content
            self._relay = relay
        }

        /// プロトコル仕様 : Id
        func id_() -> String {
            return self._id
        }

        /// プロトコル仕様 : Nsec
        func nsec() -> String {
            return self._nsec
        }

        /// プロトコル仕様 : Content
        func content() -> String {
            return self._content
        }

        /// プロトコル仕様 : Relay
        func relay() -> String {
            return self._relay
        }

        /// プロトコル仕様 : go側からのコールバック
        func onComplete(_ result: Int) {
            self.result.send(result == 1)
        }

    }
}

# gomobile-Example

gomobileを使用して、iOS&Androidの共通ライブラリを作成するサンプル。

* [https://pkg.go.dev/golang.org/x/mobile](https://pkg.go.dev/golang.org/x/mobile)
* [https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile](https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile)

--

### ■ Gobindの基本的な仕様
* [https://pkg.go.dev/golang.org/x/mobile/cmd/gobind](https://pkg.go.dev/golang.org/x/mobile/cmd/gobind)

##### iOS

下記で XCFramework が作成される。

```
cd bind_basic/go/
gomobile bind -target ios
```

動作確認用のxcodeproj

* bind_basic/iOS/GoMobileBasicExamples.xcodeproj

--

### ■ Goのライブラリを使ってみる
#### Nostr

go-nostrを使って、iOS&Androidで シンプルな Nostr Client を作る

* [Nostr Protocol ](https://github.com/nostr-protocol/nostr)
* [go-nostr](https://github.com/nbd-wtf/go-nostr)

##### relayは、こちらを起動
* [https://hub.docker.com/r/scsibug/nostr-rs-relay](https://hub.docker.com/r/scsibug/nostr-rs-relay)

##### テスト用アカウント作成
go-nostrで秘密鍵を作成して公開鍵やnsec、npubを取得

* [https://github.com/nostr-protocol/nips/blob/master/19.md](https://github.com/nostr-protocol/nips/blob/master/19.md)

```
package main

import (
    "fmt"

    "github.com/nbd-wtf/go-nostr"
    "github.com/nbd-wtf/go-nostr/nip19"
)

func main() {
    sk := nostr.GeneratePrivateKey()
    pk, _ := nostr.GetPublicKey(sk)
    nsec, _ := nip19.EncodePrivateKey(sk)
    npub, _ := nip19.EncodePublicKey(pk)

    fmt.Println("sk:", sk)
    fmt.Println("pk:", pk)
    fmt.Println(nsec)
    fmt.Println(npub)
}
```

##### iOS

下記で XCFramework が作成される。

```
cd bind_nostr/go/
gomobile bind -target ios
```

動作確認用のxcodeproj

* bind_nostr/iOS/GoMobileBasicExamples.xcodeproj

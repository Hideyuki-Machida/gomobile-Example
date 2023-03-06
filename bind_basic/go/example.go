package example

import (
	"fmt"
	"time"
)

// ネイティブコード側に渡すstruct
type Person struct {
	Name string
	Age  int
}

//////////////////////////////////////////////////////
// ネイティブコード側に公開されるfunc

func Greetings(name string) string {
	return fmt.Sprintf("Hello, %s!", name)
}

func GetBool(flg bool) bool {
	return !flg
}

func GetPerson() *Person {
	return &Person{Name: "金木タン2", Age: 24}
}

func GetByte() []byte {
	text := "金木タン3"
	return []byte(text)
}

func SetByte(data []byte) {
	text := fmt.Sprintf("%s", data)
	fmt.Print("go module : " + text + "\n")
}

//////////////////////////////////////////////////////

//////////////////////////////////////////////////////
// GO側で非同期処理を行い、ネイティブコード側にコールバックを反す。

// ネイティブコード側からセットされるsinterface
type RequestItem interface {
	Url() string
}

// ネイティブコード側からセットされるsinterface
type Request interface {
	Id() string
	Item() RequestItem
	Callback(success bool)
}

func SetRequest(req Request) {
	fmt.Print("go module : " + req.Id() + "  " + req.Item().Url() + "\n")
	go (func() {
		time.Sleep(1 * time.Second)
		req.Callback(true)
	})()
}

//////////////////////////////////////////////////////

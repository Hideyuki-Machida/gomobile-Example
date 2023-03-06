package example

import (
	"context"
	"fmt"
	"time"

	"github.com/nbd-wtf/go-nostr"
	"github.com/nbd-wtf/go-nostr/nip19"
)

// ネイティブコード側に渡すstruct
type NostrEvent struct {
	ID        string
	PubKey    string
	CreatedAt int
	Kind      int
	// Tags      Tags
	Content string
	// Sig     string
}

// ネイティブコード側からセットされるsinterface
type SubRequest interface {
	ID() string
	Npub() string
	Relay() string
	OnEvent(evt *NostrEvent)
}

// Nostr Subscription
func NostrSub(req SubRequest) {
	relay, err := nostr.RelayConnect(context.Background(), req.Relay())
	if err != nil {
		panic(err)
	}

	var filters nostr.Filters
	if _, v, err := nip19.Decode(req.Npub()); err == nil {
		pub := v.(string)
		filters = []nostr.Filter{{
			Kinds:   []int{1},
			Authors: []string{pub},
			Limit:   0,
		}}
	} else {
		panic(err)
	}

	ctx, _ := context.WithCancel(context.Background())
	sub := relay.Subscribe(ctx, filters)

	go func() {
		<-sub.EndOfStoredEvents
		// handle end of stored events (EOSE, see NIP-15)
	}()

	for ev := range sub.Events {
		// handle returned event.
		// channel will stay open until the ctx is cancelled (in this case, by calling cancel())

		// Requestのコールバックで、NostrEventをネイティブコード側に渡す。
		req.OnEvent(&NostrEvent{
			ID:        ev.ID,
			PubKey:    ev.PubKey,
			CreatedAt: int(ev.CreatedAt.Unix()),
			Kind:      ev.Kind,
			// Tags
			Content: ev.Content,
			// Sig:       ev.Sig,
		})
	}
}

// ネイティブコード側からセットされるinterface
type PubRequest interface {
	ID() string
	Nsec() string
	Content() string
	Relay() string
	OnComplete(result int)
}

func NostrPub(req PubRequest) {
	var sec string
	if _, v, err := nip19.Decode(req.Nsec()); err == nil {
		sec = v.(string)
	} else {
		panic(err)
	}
	pub, _ := nostr.GetPublicKey(sec)

	fmt.Println(pub)
	fmt.Println(req.Relay())
	ev := nostr.Event{
		PubKey:    pub,
		CreatedAt: time.Now(),
		Kind:      1,
		Tags:      nil,
		Content:   req.Content(),
	}

	// calling Sign sets the event ID field and the event Sig field
	ev.Sign(sec)

	relay, e := nostr.RelayConnect(context.Background(), req.Relay())
	if e != nil {
		fmt.Println("error")
		fmt.Println(e)
		return
	}

	status := relay.Publish(context.Background(), ev)
	req.OnComplete(int(status))
}

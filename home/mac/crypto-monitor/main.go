package main

import (
	"context"
	"encoding/json/v2"
	"errors"
	"flag"
	"fmt"
	"log"
	"math"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"time"

	"nhooyr.io/websocket"
	"nhooyr.io/websocket/wsjson"
)

type tickerMsg struct {
	Event  string `json:"e"`
	Symbol string `json:"s"`
	Close  string `json:"c"`
}

type combinedMsg struct {
	Stream string    `json:"stream"`
	Data   tickerMsg `json:"data"`
}

type monitor struct {
	sketchybarPath string
	pairs          []string
	icons          map[string]string
	prices         map[string]float64
	mu             sync.Mutex
	lastLabel      string
}

func main() {
	var sketchybarPath string
	var pairs multiFlag
	flag.StringVar(&sketchybarPath, "sketchybar", "sketchybar", "Path to sketchybar binary")
	flag.Var(&pairs, "pair", "Trading pair like BTCUSDT (repeatable)")
	flag.Parse()

	if len(pairs) == 0 {
		log.Fatalf("at least one --pair is required")
	}

	m := &monitor{
		sketchybarPath: sketchybarPath,
		pairs:          pairs,
		icons: map[string]string{
			"BTC": "₿",
			"ETH": "",
		},
		prices: map[string]float64{},
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	m.run(ctx)
}

func (m *monitor) run(ctx context.Context) {
	backoff := 2 * time.Second
	maxBackoff := 60 * time.Second

	for {
		if ctx.Err() != nil {
			return
		}

		err := m.connect(ctx)
		if err != nil && ctx.Err() == nil {
			log.Printf("websocket error: %v", err)
		}

		if ctx.Err() != nil {
			return
		}

		log.Printf("reconnecting in %s", backoff)
		select {
		case <-time.After(backoff):
		case <-ctx.Done():
			return
		}

		backoff *= 2
		if backoff > maxBackoff {
			backoff = maxBackoff
		}
	}
}

func (m *monitor) connect(ctx context.Context) error {
	url := buildStreamURL(m.pairs)
	conn, _, err := websocket.Dial(ctx, url, &websocket.DialOptions{
		CompressionMode: websocket.CompressionDisabled,
	})
	if err != nil {
		return err
	}

	defer conn.Close(websocket.StatusNormalClosure, "")

	for {
		var raw RawMessage
		if err := wsjson.Read(ctx, conn, &raw); err != nil {
			return err
		}

		var combined combinedMsg

		if err := json.Unmarshal(raw, &combined); err == nil && combined.Stream != "" {
			msg := combined.Data
			if msg.Event != "24hrMiniTicker" || msg.Symbol == "" || msg.Close == "" {
				continue
			}

			price, err := parseFloat(msg.Close)
			if err != nil {
				continue
			}

			m.updatePrice(msg.Symbol, price)

			continue
		}

		var msg tickerMsg
		if err := json.Unmarshal(raw, &msg); err != nil {
			continue
		}

		if msg.Event != "24hrMiniTicker" || msg.Symbol == "" || msg.Close == "" {
			continue
		}

		price, err := parseFloat(msg.Close)
		if err != nil {
			continue
		}

		m.updatePrice(msg.Symbol, price)
	}
}

func buildStreamURL(pairs []string) string {
	streams := make([]string, 0, len(pairs))
	for _, pair := range pairs {
		streams = append(streams, strings.ToLower(pair)+"@miniTicker")
	}
	return "wss://stream.binance.com/stream?streams=" + strings.Join(streams, "/")
}

func (m *monitor) updatePrice(symbol string, price float64) {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.prices[symbol] = price
	label := m.formatLabel()
	if label == "" || label == m.lastLabel {
		return
	}
	m.lastLabel = label

	cmd := exec.Command(m.sketchybarPath, "--trigger", "crypto_price_change", "VALUE="+label)
	_ = cmd.Run()
}

func (m *monitor) formatLabel() string {
	parts := make([]string, 0, len(m.pairs))
	for _, symbol := range m.pairs {
		price, ok := m.prices[symbol]
		if !ok {
			continue
		}

		base := strings.TrimSuffix(symbol, "USDT")
		icon := m.icons[base]
		if icon == "" {
			icon = base
		}

		parts = append(parts, fmt.Sprintf("%s %.2f", icon, round(price, 2)))
	}

	return strings.Join(parts, " ")
}

func round(val float64, decimals int) float64 {
	pow := math.Pow(10, float64(decimals))
	return math.Round(val*pow) / pow
}

func parseFloat(raw string) (float64, error) {
	return strconv.ParseFloat(strings.TrimSpace(raw), 64)
}

type multiFlag []string

func (m *multiFlag) String() string {
	return strings.Join(*m, ",")
}

func (m *multiFlag) Set(value string) error {
	*m = append(*m, value)
	return nil
}

type RawMessage []byte

// MarshalJSON returns m as the JSON encoding of m.
func (m RawMessage) MarshalJSON() ([]byte, error) {
	if m == nil {
		return []byte("null"), nil
	}
	return m, nil
}

// UnmarshalJSON sets *m to a copy of data.
func (m *RawMessage) UnmarshalJSON(data []byte) error {
	if m == nil {
		return errors.New("json.RawMessage: UnmarshalJSON on nil pointer")
	}
	*m = append((*m)[0:0], data...)
	return nil
}

package main

import (
	"encoding/json"
	"fmt"
	"sync"

	"github.com/sdomino/scribble"

	"net/http"
)

type GameScores struct {
	Game   string  `json:"game"`
	Scores []Score `json:"scores"`
}

type Score struct {
	Game    string `json:"game"`
	Version string `json:"version"`
	Player  string `json:"player"`
	Score   uint64 `json:"score"`
}

type Server struct {
	sync.Mutex
	Db         *scribble.Driver
	InMemory   bool
	gameScores []GameScores
}

func main() {
	server := NewServer()

	http.HandleFunc("/highscore", server.ScoreHandler)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}

func NewServer() *Server {

	s := Server{}
	db, err := scribble.New("db", nil)
	if err != nil {
		fmt.Println("Error creating db, running in-memory")
		s.InMemory = true
	}
	s.Db = db

	return &s
}

func (s *Server) ScoreHandler(res http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case http.MethodGet:
		allScores, err := s.GetAllScores()
		if err != nil {
			s.InternalErrorFromErr(res, err)
			return
		}
		result, err := json.Marshal(allScores)
		if err != nil {
			s.InternalErrorFromErr(res, err)
			return
		}
		_, err = res.Write(result)
		if err != nil {
			s.InternalErrorFromErr(res, err)
			return
		}
		return
	case http.MethodPost:
		decoder := json.NewDecoder(req.Body)

		score := Score{}
		err := decoder.Decode(&score)
		if err != nil {
			s.InternalErrorFromErr(res, err)
			return
		}

		s.AddScore(score)
	}
}

func (s *Server) GetAllScores() (allScores []GameScores, err error) {
	if s.InMemory {
		allScores = s.gameScores
		return
	}
	records, err := s.Db.ReadAll("GameScores")
	if err != nil {
		return
	}
	for _, raw := range records {
		gameScores := GameScores{}
		if err = json.Unmarshal([]byte(raw), &gameScores); err != nil {
			return
		}
		allScores = append(allScores, gameScores)
	}
	return
}

func (s *Server) AddScore(score Score) (err error) {
	s.Lock()
	defer s.Unlock()
	if s.InMemory {
		for i, gameScores := range s.gameScores {
			if gameScores.Game == score.Game {
				s.gameScores[i].Scores = append(s.gameScores[i].Scores, score)
			}
		}
		return
	}

	gameScores := GameScores{}
	err = s.Db.Read("GameScores", score.Game, &gameScores)
	if err != nil {
		fmt.Printf("Error reading score, assuming game '%s' not found: %v", score.Game, err)
		gameScores.Game = score.Game
	}
	gameScores.Scores = append(gameScores.Scores, score)
	err = s.Db.Write("GameScores", gameScores.Game, &gameScores)
	if err != nil {
		return err
	}
	return
}

func (s *Server) InternalErrorFromErr(res http.ResponseWriter, err error) {
	errString := fmt.Sprintf("Error: %v", err)
	s.InternalError(res, errString)
}

func (s *Server) InternalError(res http.ResponseWriter, body string) {
	res.WriteHeader(http.StatusInternalServerError)
	_, _ = res.Write([]byte(body))
}

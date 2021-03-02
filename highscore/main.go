package main

import (
	"encoding/json"
	"fmt"

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
	Db *scribble.Driver
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

	db, err := scribble.New("db", nil)
	if err != nil {
		panic(err)
	}
	s := Server{db}

	return &s
}

func (s *Server) ScoreHandler(res http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case http.MethodGet:
		records, err := s.Db.ReadAll("GameScores")
		if err != nil {
			s.InternalErrorFromErr(res, err)
			return
		}
		allScores := []GameScores{}
		for _, raw := range records {
			gameScores := GameScores{}
			if err := json.Unmarshal([]byte(raw), &gameScores); err != nil {
				s.InternalErrorFromErr(res, err)
				return
			}
			allScores = append(allScores, gameScores)
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

		gameScores := GameScores{}
		err = s.Db.Read("GameScores", score.Game, &gameScores)
		if err != nil {
			s.InternalErrorFromErr(res, err)
			return
		}
		gameScores.Scores = append(gameScores.Scores, score)
		err = s.Db.Write("GameScores", gameScores.Game, &gameScores)
		if err != nil {
			s.InternalErrorFromErr(res, err)
			return
		}
	}
}

func (s *Server) InternalErrorFromErr(res http.ResponseWriter, err error) {
	errString := fmt.Sprintf("Error: %v", err)
	s.InternalError(res, errString)
}

func (s *Server) InternalError(res http.ResponseWriter, body string) {
	res.WriteHeader(http.StatusInternalServerError)
	_, _ = res.Write([]byte(body))
}

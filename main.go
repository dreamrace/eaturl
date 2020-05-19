package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"

	_ "github.com/lib/pq"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func handleSlug(w http.ResponseWriter, r *http.Request) {
	log.Printf("%s %s %s", r.RemoteAddr, r.Method, r.RequestURI)
	slug, found := mux.Vars(r)["slug"]
	if !found {
		w.WriteHeader(http.StatusNotFound)
	}

	// Try to find in cache
	url, err := queryCache(slug)
	if err == nil {
		w.Header().Set("Location", url)
		w.WriteHeader(http.StatusNotModified)
		return
	}

	// Try to find in database
	url, err = queryDatabase(slug)
	if err == nil {
		updateCache(slug, url)
		w.Header().Set("Location", url)
		w.WriteHeader(http.StatusNotModified)
		return
	}

	// Response not found
	log.Println("Query record failed", err)
	w.WriteHeader(http.StatusNotFound)
	fmt.Fprintf(w, "Not found")
}

type urlCreateRequestDTO struct {
	URL string `json:"url"`
}

type urlCreateResponseDTO struct {
	URL  string `json:"url"`
	Slug string `json:"slug"`
}

func handleSubmit(w http.ResponseWriter, r *http.Request) {
	log.Printf("%s %s %s", r.RemoteAddr, r.Method, r.RequestURI)
	var requestDTO urlCreateRequestDTO

	// Decode json
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Print(err)
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "Please enter valid format")
		return
	}
	err = json.Unmarshal(reqBody, &requestDTO)
	if err != nil || requestDTO.URL == "" {
		log.Print(err, requestDTO.URL)
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "Please enter valid format")
		return
	}

	// Insert into database
	id, err := addURL(requestDTO.URL)
	if err == nil {
		slug := shortener.ShortenURL(id)
		responseDTO := urlCreateResponseDTO{requestDTO.URL, slug}
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(responseDTO)
		return
	}

	// Response for bad requests
	log.Println("Insert record failed", err)
	w.WriteHeader(http.StatusBadRequest)
	fmt.Fprintf(w, "Error occured")
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("%s %s %s", r.RemoteAddr, r.Method, r.RequestURI)
	fmt.Fprintf(w, "Welcome Home")
}

func main() {

	err := setUp(
		os.Getenv("POSTGRESQL_CONNECTION_STRING"),
		os.Getenv("RADIS_HOSTNAME"),
		os.Getenv("RADIA_PASSWORD"),
	)
	check(err)

	router := mux.NewRouter()
	router.HandleFunc("/", homeHandler).Methods("GET")
	router.HandleFunc("/{slug}", handleSlug).Methods("GET")
	router.HandleFunc("/", handleSubmit).Methods("POST")
	log.Print("Starting server at 8080")
	log.Fatal(http.ListenAndServe(":8080", router))
}

package main

import (
	"flag"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

// default values
var logPath = "./logs/"
var port = 8080

func main() {

	parseCommandLine()

	// this sets the log file
	if err := setupLogs(logPath); err != nil {
		log.Println("Error opening logfile", logPath, err)
		log.Println("Logging to stdio only")
	}

	// handle log files
	http.Handle("/logs", http.HandlerFunc(logsHandler))

	// handle healthcheck
	http.Handle("/healthcheck", logb(http.HandlerFunc(healthcheckHandler)))

	// handle everything else
	http.Handle("/", logb(http.HandlerFunc(rootHandler)))

	log.Println("Node: ", os.Getenv("MY_NODE_NAME"))
	log.Println("Pod: ", os.Getenv("MY_POD_NAME"))
	log.Println("Listening on", port)
	log.Println("Logging to", logPath)

	// run the web server
	if err := http.ListenAndServe(":"+strconv.Itoa(port), nil); err != nil {
		log.Fatal(err)
	}
}

// parseCommandLine -port and -logpath are supported
func parseCommandLine() {
	// parse flags
	lfp := flag.String("logpath", "", "path to log files")
	p := flag.Int("port", port, "port to listen on")
	flag.Parse()

	// set log path
	if *lfp != "" {
		logPath = *lfp
	}

	// log in current directory if not running in App Services
	if _, err := os.Stat(logPath); err != nil {
		logPath = "./"
	}

	// set port
	if *p <= 0 || *p >= 64*1024 {
		flag.Usage()
		log.Fatal("invalid port")
	}

	port = *p
}

// setupLogs - sets up the multi writer for the log files
func setupLogs(logPath string) error {
	// prepend date and time to log entries
	log.SetFlags(log.Ldate | log.Ltime)

	// make the log directory if it doesn't exist
	if err := os.MkdirAll(logPath, 0666); err != nil {
		return err
	}

	fileName := logPath + "app.log"

	// open the log file

	logFile, err := os.OpenFile(fileName, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)

	if err != nil {
		return err
	}

	// setup a multiwriter to log to file and stdout
	wrt := io.MultiWriter(os.Stdout, logFile)
	log.SetOutput(wrt)

	return nil
}

// handle all requests
func rootHandler(w http.ResponseWriter, r *http.Request) {

	s := strings.ToLower(r.URL.Path)

	// handle default web page
	if s == "/" || strings.HasPrefix(s, "/index.") || strings.HasPrefix(s, "/default.") {
		w.WriteHeader(200)

		html := "<html>\n<head>\n<link rel=\"icon\" type=\"image/ico\" href=\"/favicon.ico\">\n</head>\n<body>\n"

		html += "<p>Pod Name: " + os.Getenv("MY_POD_NAME") + "</p>\n"

		html += "<p>Node Name: " + os.Getenv("MY_NODE_NAME") + "</p>\n"

		html += "</body>\n</html>"

		w.Write([]byte(html))
		w.Header().Add("Cache-Control", "no-cache")
		return
	}

	// don't allow directory browsing (unless you want to)
	if strings.HasSuffix(s, "/") {
		w.WriteHeader(403)
		return
	}

	// don't allow .. in path
	if strings.Contains(s, "..") {
		w.WriteHeader(403)
		return
	}

	// serve the file from the www directory
	http.ServeFile(w, r, "www"+s)
}

// handle /healthcheck
func healthcheckHandler(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(200)
	w.Write([]byte("200\n"))
	w.Header().Add("Cache-Control", "no-cache")
}

// handle /logs requests
func logsHandler(w http.ResponseWriter, r *http.Request) {

	http.ServeFile(w, r, "logs/app.log")
	w.Header().Add("Cache-Control", "no-cache")
}

//logb handler - http handler that writes to log file(s)
func logb(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		wr := &ResponseLogger{
			ResponseWriter: w,
			status:         0,
			start:          time.Now().UTC(),
			duration:       0}

		defer logRequest(r, wr)

		if next != nil {
			next.ServeHTTP(wr, r)
		}

		wr.duration = time.Now().UTC().Sub(wr.start).Nanoseconds() / 100000
	})
}

// write the log entry (this is a deferred call)
func logRequest(r *http.Request, wr *ResponseLogger) {
	log.Println(wr.status, r.Method, r.URL.Path, wr.duration, wr.bytes)
}

// ResponseLogger - wrap http.ResponseWriter to include status and size
type ResponseLogger struct {
	http.ResponseWriter
	status   int
	bytes    int
	start    time.Time
	duration int64
}

// WriteHeader - wraps http.WriteHeader
func (r *ResponseLogger) WriteHeader(status int) {
	// store status for logging
	r.status = status

	r.ResponseWriter.WriteHeader(status)
}

// Write - wraps http.Write
func (r *ResponseLogger) Write(buf []byte) (int, error) {
	n, err := r.ResponseWriter.Write(buf)

	// store bytes written for logging
	if err == nil {
		r.bytes += n
	}

	return n, err
}

# output binary path; matches the /bin/ rule in .gitignore
BIN := bin/server

.PHONY: build run test test-race vet fmt tidy clean check

# compile the server to bin/server
build:
	go build -o $(BIN) ./cmd/server

# compile and run over stdio, no leftover binary
run:
	go run ./cmd/server

# run all tests
test:
	go test ./...


# go-mcp-bootstrap

A minimal skeleton for building MCP servers in Go, on top of the official [`go-sdk`](https://github.com/modelcontextprotocol/go-sdk). Clone it, run the script, start writing tools.

## Bootstrap a new server

```sh
scripts/new-mcp.sh github.com/me/notes-mcp ~/src/notes-mcp
```

This copies the skeleton, rewrites the module path, runs `go mod tidy`, proves it
compiles, writes a starter README, and inits a git repo. Then:

```sh
cd ~/src/notes-mcp
go run ./cmd/server
```

## Run it directly

```sh
go run ./cmd/server          # serve over stdio
go build -o bin/server ./cmd/server
LOG_LEVEL=debug go run ./cmd/server
```

The server speaks JSON-RPC over stdio. Logs go to **stderr** only — stdout is
reserved for the protocol stream.

## Add a tool

A tool is an `mcpkit.Registrar`. Copy `internal/tools/echo.go`, then register it
in `cmd/server/main.go`:

```go
srv := mcpkit.Build(serverName, serverVersion,
    tools.Ping(),
    tools.Echo(),
    tools.YourTool(),   // <- add here
)
```

The SDK builds each tool's input schema from your struct's `jsonschema` tags
(the tag becomes the parameter description shown to the model); validate values
in the handler, as `echo.go` does. Return `mcpkit.Text/Textf/JSON` for success,
`mcpkit.Errorf` for failures the model should see and react to.

## Register with a client

Point your MCP client at the built binary. For Claude Desktop / Claude Code
(`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "notes-mcp": {
      "command": "/abs/path/to/bin/server"
    }
  }
}
```

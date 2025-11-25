# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is agda-mode for VS Code - a Visual Studio Code extension that provides interactive development features for the Agda proof assistant. The extension is written in ReScript (OCaml that compiles to JavaScript) and uses React for its UI components.

## Technology Stack

- **Language**: ReScript (type-safe language that transpiles to JavaScript)
- **Frontend**: React 18 for webview panel UI
- **Build**: ReScript compiler, Webpack (3 bundles: desktop/web/view), Less for CSS
- **Testing**: Mocha with ReScript bindings, property-based testing with rescript-fast-check
- **VSCode Integration**: Custom ReScript bindings via `rescript-vscode` package

## Common Commands

### Development

```bash
# Install dependencies
npm install

# Build for production (creates all bundles)
npm run build

# Development mode with watch (for desktop extension)
npm run dev

# Development mode for web extension
npm run dev-web [folder]

# Clean build artifacts
npm run clean

# Run tests
npm run test
```

### Testing in VS Code

Press `F5` in VS Code to launch the Extension Development Host with agda-mode running.

### Publishing

```bash
# Dry run to check dependencies that will be packaged
npm run dry-run-publish
```

## Architecture

### Dual-Mode Extension (Desktop + Web)

The extension supports both traditional desktop VS Code and browser-based vscode.dev through a platform abstraction layer:

- **Desktop entry**: `src/Main/Desktop.res` → `dist/app.bundle.js`
- **Web entry**: `src/Main/Web.res` → `dist/web.bundle.js`
- **View bundle**: `src/View/Root.res` → `dist/bundled-view.js` (React UI)

Core logic is shared in `src/Main/Main.res`, with platform-specific implementations injected via the `Platform.t` module type (dependency injection pattern).

### Connection Layer

The extension communicates with Agda through two possible backends:

1. **Direct Agda Process** (`Connection__Endpoint__Agda.res`):
   - Spawns Agda as a child process
   - Parses S-expression responses incrementally
   - Uses IOTCM (Interaction, Options, and Type Checking Messages) protocol

2. **Agda Language Server** (`Connection__Endpoint__ALS.res`):
   - Communicates via LSP (Language Server Protocol)
   - Supports stdio pipes and TCP connections
   - Can auto-download and install ALS binaries

Connection discovery follows this fallback chain:
1. Previously selected path (stored in memento)
2. User-configured paths (`agdaMode.connection.paths`)
3. Command search (`agda`, `als` in PATH)
4. Auto-download latest ALS (with user consent)

### State Management

- **Registry Pattern**: `Registry.res` maintains a dictionary mapping file paths to State instances
- **Per-Document State** (`State/State.res`): Each Agda file has its own:
  - Connection to Agda/ALS
  - Editor/Document references
  - Goals manager (tracks proof holes)
  - Semantic tokens (for syntax highlighting)
  - Input method instances
  - View cache

### View Architecture

The extension uses a webview panel with React UI, separated from the main extension logic:

- Extension backend runs in Node.js/browser extension host
- View frontend (React) runs in isolated webview context
- Communication via message passing (postMessage API)
- Singleton pattern: One panel shared across all documents (`View/Singleton.res`)

### Goal Management

Goals are Agda "holes" (proof obligations) tracked via:
- Binary search tree for efficient position lookups
- Concurrent goal scanning with locking
- Automatic position updates on text edits
- Prioritized rendering (pending vs. judged goals)

### Semantic Highlighting

Custom token-based syntax highlighting beyond TextMate grammars:
- Handles Unicode challenges (UTF-16 surrogate pairs, CRLF line endings)
- Incremental updates on document changes
- Offset converter with cached interval lookups
- Integrated with go-to-definition provider

### Input Method

LaTeX-style symbol input system:
- Backslash sequences → Unicode symbols (e.g., `\lambda` → `λ`)
- Dual instances: editor input + prompt input
- Candidate selection with arrow keys
- Key-symbol mapping loaded from `asset/query.js`

## Key Directories

- `src/Connection/` - All Agda/ALS communication logic
- `src/State/` - Per-document state management
- `src/View/` - React UI components and webview bridge
- `src/Main/` - Extension activation and platform entry points
- `src/Parser/` - S-expression and response parsers
- `src/Tokens/` - Semantic highlighting token management
- `src/InputMethod/` - Unicode input system
- `src/Util/` - Shared utilities (channels, AVL trees, promises)
- `test/tests/` - Comprehensive test suite
- `lib/js/` - ReScript compilation output (generated, not committed)
- `dist/` - Webpack bundles (generated)

## Development Workflow

### Making Changes

1. Edit `.res` files in `src/`
2. ReScript compiler watches and compiles to `.bs.js` in `lib/js/`
3. Webpack rebundles the changes
4. Reload the Extension Development Host to test

### Working with Platform-Specific Code

When adding features that differ between desktop and web:
- Define the operation signature in `Platform/Platform.res`
- Implement in `Platform/Desktop.res` and `Platform/Web.res`
- Inject via dependency injection in entry points

### Adding Commands

1. Register command in `package.json` under `contributes.commands`
2. Add keybinding in `contributes.keybindings`
3. Implement command handler in `src/Command.res` or `src/State/State__Command.res`
4. Encode the request in `src/Request.res`
5. Handle the response in `src/Response.res` or `src/Task.res`

### Modifying the View

React components are in `src/View/Panel/`:
- Edit `.res` files for components
- ReScript compiles to `.bs.js`
- Webpack rebundles the view
- Reload webview to see changes

## Important Patterns

- **Channel-based Events**: `Chan.t` for async event propagation (inspired by Go channels)
- **Resource Pattern**: Lazy async resources with caching (`Resource.t`)
- **Incremental Parsing**: Stream-based parser for handling large Agda outputs
- **Memento Pattern**: Persistent state across VS Code sessions
- **Registry Pattern**: Central state management per document
- **Singleton Pattern**: Single panel/debug buffer shared across documents

## Versioning Policy

This extension follows VS Code's recommended versioning:
- **Release versions**: Even minor numbers (e.g., `0.6.x`, `0.8.x`)
- **Prerelease versions**: Odd minor numbers (e.g., `0.7.x`, `0.9.x`)

## Supported File Types

The extension activates for:
- Plain Agda: `.agda`
- Literate Agda variants:
  - Markdown: `.lagda.md`
  - TeX: `.lagda.tex`, `.lagda`
  - reStructuredText: `.lagda.rst`
  - Org: `.lagda.org`
  - Typst: `.lagda.typ`
  - Forester: `.lagda.tree`

## Connection Management

Users can configure multiple Agda/ALS installations:
- Set paths in `agdaMode.connection.paths` (tried from last to first)
- Switch between versions with `Ctrl+X Ctrl+S`
- Extension can auto-download Agda Language Server if none found

## ReScript Tips

- `.res` files are ReScript source code
- `.bs.js` files are generated JavaScript (don't edit)
- `rescript.json` configures the compiler
- ReScript uses OCaml-style syntax with type inference
- Module system: Every file is a module, use `Module.value` syntax

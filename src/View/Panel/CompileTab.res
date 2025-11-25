// Compile tab component - compile options UI and output display
// Uses Common.Backend and Common.CompileOptions for shared types

module BackendSelect = {
  @react.component
  let make = (~value: Common.Backend.t, ~onChange: Common.Backend.t => unit) => {
    let handleChange = (event: ReactEvent.Form.t) => {
      let target = ReactEvent.Form.target(event)
      let value = target["value"]
      onChange(Common.Backend.fromString(value))
    }

    <div className="option-row">
      <label htmlFor="backend-select"> {React.string("Backend:")} </label>
      <select id="backend-select" value={Common.Backend.toString(value)} onChange=handleChange>
        {Common.Backend.all
        ->Array.map(b => {
          let value = Common.Backend.toString(b)
          let label = Common.Backend.description(b)
          <option key=value value> {React.string(label)} </option>
        })
        ->React.array}
      </select>
    </div>
  }
}

module TextInput = {
  @react.component
  let make = (
    ~id: string,
    ~label: string,
    ~value: string,
    ~placeholder: string,
    ~onChange: string => unit,
  ) => {
    let handleChange = (event: ReactEvent.Form.t) => {
      let target = ReactEvent.Form.target(event)
      onChange(target["value"])
    }

    <div className="option-row">
      <label htmlFor=id> {React.string(label)} </label>
      <input type_="text" id placeholder value onChange=handleChange />
    </div>
  }
}

module Checkbox = {
  @react.component
  let make = (~id: string, ~label: string, ~checked: bool, ~onChange: bool => unit) => {
    let handleChange = (event: ReactEvent.Form.t) => {
      let target = ReactEvent.Form.target(event)
      onChange(target["checked"])
    }

    <div className="option-row checkbox">
      <input type_="checkbox" id checked onChange=handleChange />
      <label htmlFor=id> {React.string(label)} </label>
    </div>
  }
}

module CompileButton = {
  @react.component
  let make = (~onClick: unit => unit, ~isCompiling: bool) => {
    <button
      className={"compile-button" ++ (isCompiling ? " compiling" : "")}
      onClick={_ => onClick()}
      disabled=isCompiling>
      {isCompiling
        ? <>
            <span className="codicon codicon-sync spin" />
            {React.string(" Compiling...")}
          </>
        : <>
            <span className="codicon codicon-play" />
            {React.string(" Compile")}
          </>}
    </button>
  }
}

module OutputDisplay = {
  @react.component
  let make = (~output: array<string>, ~isError: bool, ~emptyMessage: string) => {
    let className = "compile-output" ++ (isError ? " error" : "")
    <div className>
      {output->Array.length > 0
        ? <pre>
            {output
            ->Array.mapWithIndex((line, i) =>
              <React.Fragment key={Int.toString(i)}>
                {React.string(line)}
                {React.string("\n")}
              </React.Fragment>
            )
            ->React.array}
          </pre>
        : <div className="compile-output-empty">
            {React.string(emptyMessage)}
          </div>}
    </div>
  }
}

// Command preview display
module CommandPreview = {
  @react.component
  let make = (~command: string) => {
    if command == "" {
      React.null
    } else {
      <div className="command-preview-section">
        <label> {React.string("Command Preview:")} </label>
        <code className="command-preview">
          {React.string(command)}
        </code>
      </div>
    }
  }
}

// Run command input with Run button
module RunCommandInput = {
  @react.component
  let make = (
    ~value: string,
    ~onChange: string => unit,
    ~onRun: unit => unit,
    ~disabled: bool,
  ) => {
    let handleChange = (event: ReactEvent.Form.t) => {
      let target = ReactEvent.Form.target(event)
      onChange(target["value"])
    }

    <div className="option-row run-command-row">
      <label htmlFor="run-command"> {React.string("Run Command:")} </label>
      <div className="run-command-input-group">
        <input
          type_="text"
          id="run-command"
          placeholder="./Main"
          value
          onChange=handleChange
          className="run-command-input"
        />
        <button
          className={"run-button" ++ (disabled ? " disabled" : "")}
          onClick={_ => onRun()}
          disabled
          title="Run the compiled binary in a terminal">
          <span className="codicon codicon-terminal" />
          {React.string(" Run")}
        </button>
      </div>
    </div>
  }
}

// GHC-specific options
module GhcOptionsSection = {
  @react.component
  let make = (
    ~options: Common.CompileOptions.t,
    ~onChange: Common.CompileOptions.t => unit,
    ~onRun: unit => unit,
    ~isCompiling: bool,
  ) => {
    <div className="backend-options">
      <TextInput
        id="main-module"
        label="Main Module:"
        placeholder="(current file)"
        value={options.mainModule}
        onChange={mainModule => onChange({...options, mainModule})}
      />
      <TextInput
        id="ghc-options"
        label="GHC Flags:"
        placeholder="-O2 -Wall"
        value={options.ghcOptions}
        onChange={ghcOptions => onChange({...options, ghcOptions})}
      />
      <RunCommandInput
        value={options.runCommand}
        onChange={runCommand => onChange({...options, runCommand})}
        onRun
        disabled={isCompiling}
      />
    </div>
  }
}

// HTML-specific options
module HtmlOptionsSection = {
  @react.component
  let make = (~options: Common.CompileOptions.t, ~onChange: Common.CompileOptions.t => unit) => {
    let htmlOpts = options.htmlOptions
    <div className="backend-options">
      <TextInput
        id="html-css-dir"
        label="CSS Directory:"
        placeholder="./css"
        value={htmlOpts.cssDir}
        onChange={cssDir =>
          onChange({...options, htmlOptions: {...htmlOpts, cssDir}})}
      />
      <Checkbox
        id="html-only-code"
        label="Only code (no navigation)"
        checked={htmlOpts.onlyCode}
        onChange={onlyCode =>
          onChange({...options, htmlOptions: {...htmlOpts, onlyCode}})}
      />
      <Checkbox
        id="html-highlight"
        label="Highlight occurrences"
        checked={htmlOpts.highlightOccurrences}
        onChange={highlightOccurrences =>
          onChange({...options, htmlOptions: {...htmlOpts, highlightOccurrences}})}
      />
    </div>
  }
}

// LaTeX-specific options
module LatexOptionsSection = {
  @react.component
  let make = (~options: Common.CompileOptions.t, ~onChange: Common.CompileOptions.t => unit) => {
    <div className="backend-options">
      <Checkbox
        id="latex-count-clusters"
        label="Count clusters"
        checked={options.latexOptions.countClusters}
        onChange={countClusters =>
          onChange({...options, latexOptions: {countClusters: countClusters}})}
      />
    </div>
  }
}

@react.component
let make = (
  ~options: Common.CompileOptions.t,
  ~onOptionsChange: Common.CompileOptions.t => unit,
  ~output: array<string>,
  ~isError: bool,
  ~isCompiling: bool,
  ~onCompile: unit => unit,
  ~onRun: (string, string) => unit,
  ~commandPreview: string,
) => {
  // Render backend-specific options
  let backendOptions = switch options.backend {
  | GHC | GHCNoMain =>
    <GhcOptionsSection
      options
      onChange=onOptionsChange
      onRun={() => onRun(options.runCommand, options.outputPath)}
      isCompiling
    />
  | HTML => <HtmlOptionsSection options onChange=onOptionsChange />
  | LaTeX | QuickLaTeX => <LatexOptionsSection options onChange=onOptionsChange />
  | JS => React.null
  }

  <div className="agda-mode-compile-tab">
    <div className="options-section">
      <h3> {React.string("Compile Options")} </h3>
      <CommandPreview command=commandPreview />
      <BackendSelect value={options.backend} onChange={backend => onOptionsChange({...options, backend})} />
      <TextInput
        id="output-path"
        label="Output Path:"
        placeholder="./build"
        value={options.outputPath}
        onChange={outputPath => onOptionsChange({...options, outputPath})}
      />
      {backendOptions}
      <div className="button-row">
        <CompileButton onClick=onCompile isCompiling />
      </div>
    </div>
    <div className="output-section">
      <h3> {React.string("Output")} </h3>
      <OutputDisplay output isError emptyMessage="No compilation output yet. Click Compile to build." />
    </div>
  </div>
}

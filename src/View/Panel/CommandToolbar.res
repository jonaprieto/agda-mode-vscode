// Command toolbar component for quick access to Agda commands
// Provides buttons and dropdowns as alternatives to keyboard shortcuts

// Dropdown for normalization options
module NormalizationSelect = {
  type normalization =
    | AsIs
    | Simplified
    | Instantiated
    | Normalised
    | HeadNormal

  let toString = norm =>
    switch norm {
    | AsIs => "As Is"
    | Simplified => "Simplified"
    | Instantiated => "Instantiated"
    | Normalised => "Normalised"
    | HeadNormal => "Head Normal"
    }

  let fromString = s =>
    switch s {
    | "Simplified" => Simplified
    | "Instantiated" => Instantiated
    | "Normalised" => Normalised
    | "HeadNormal" => HeadNormal
    | _ => AsIs
    }

  let all: array<normalization> = [Simplified, Instantiated, Normalised, HeadNormal]

  @react.component
  let make = (~value: normalization, ~onChange: normalization => unit, ~id: string) => {
    let handleChange = (event: ReactEvent.Form.t) => {
      let target = ReactEvent.Form.target(event)
      let value = target["value"]
      onChange(fromString(value))
    }

    <select id className="normalization-select" value={toString(value)} onChange=handleChange>
      {all
      ->Array.map(norm => {
        let value = toString(norm)
        <option key=value value> {React.string(value)} </option>
      })
      ->React.array}
    </select>
  }
}

// Dropdown for compute mode options
module ComputeModeSelect = {
  type computeMode =
    | DefaultCompute
    | IgnoreAbstract
    | UseShowInstance

  let toString = mode =>
    switch mode {
    | DefaultCompute => "Default"
    | IgnoreAbstract => "Ignore Abstract"
    | UseShowInstance => "Use Show Instance"
    }

  let fromString = s =>
    switch s {
    | "Ignore Abstract" => IgnoreAbstract
    | "Use Show Instance" => UseShowInstance
    | _ => DefaultCompute
    }

  let all: array<computeMode> = [DefaultCompute, IgnoreAbstract, UseShowInstance]

  @react.component
  let make = (~value: computeMode, ~onChange: computeMode => unit, ~id: string) => {
    let handleChange = (event: ReactEvent.Form.t) => {
      let target = ReactEvent.Form.target(event)
      let value = target["value"]
      onChange(fromString(value))
    }

    <select id className="compute-mode-select" value={toString(value)} onChange=handleChange>
      {all
      ->Array.map(mode => {
        let value = toString(mode)
        <option key=value value> {React.string(value)} </option>
      })
      ->React.array}
    </select>
  }
}

// Command button with icon
module CommandButton = {
  @react.component
  let make = (~label: string, ~icon: string, ~onClick: unit => unit, ~title: string) => {
    <button className="command-button" onClick={_ => onClick()} title>
      <span className={"codicon " ++ icon} />
      {React.string(" " ++ label)}
    </button>
  }
}

// Command group with dropdown
module CommandWithDropdown = {
  @react.component
  let make = (
    ~label: string,
    ~icon: string,
    ~normalization: NormalizationSelect.normalization,
    ~onNormalizationChange: NormalizationSelect.normalization => unit,
    ~onExecute: NormalizationSelect.normalization => unit,
    ~dropdownId: string,
    ~title: string,
  ) => {
    <div className="command-with-dropdown">
      <button
        className="command-button with-dropdown"
        onClick={_ => onExecute(normalization)}
        title>
        <span className={"codicon " ++ icon} />
        {React.string(" " ++ label)}
      </button>
      <NormalizationSelect
        id=dropdownId value=normalization onChange=onNormalizationChange
      />
    </div>
  }
}

// Compute normal form command with compute mode dropdown
module ComputeNormalFormCommand = {
  @react.component
  let make = (
    ~computeMode: ComputeModeSelect.computeMode,
    ~onComputeModeChange: ComputeModeSelect.computeMode => unit,
    ~onExecute: ComputeModeSelect.computeMode => unit,
  ) => {
    <div className="command-with-dropdown">
      <button
        className="command-button with-dropdown"
        onClick={_ => onExecute(computeMode)}
        title="Compute normal form">
        <span className="codicon codicon-symbol-numeric" />
        {React.string(" Compute Normal Form")}
      </button>
      <ComputeModeSelect id="compute-mode-select" value=computeMode onChange=onComputeModeChange />
    </div>
  }
}

@react.component
let make = (~onCommand: string => unit) => {
  // State for normalization dropdowns
  let (goalTypeNorm, setGoalTypeNorm) = React.useState(() => NormalizationSelect.Simplified)
  let (goalTypeContextNorm, setGoalTypeContextNorm) = React.useState(() =>
    NormalizationSelect.Simplified
  )
  let (contextNorm, setContextNorm) = React.useState(() => NormalizationSelect.Simplified)
  let (inferTypeNorm, setInferTypeNorm) = React.useState(() => NormalizationSelect.Simplified)
  let (autoNorm, setAutoNorm) = React.useState(() => NormalizationSelect.Simplified)
  let (elaborateGiveNorm, setElaborateGiveNorm) = React.useState(() =>
    NormalizationSelect.Simplified
  )
  let (moduleContentsNorm, setModuleContentsNorm) = React.useState(() =>
    NormalizationSelect.Simplified
  )
  let (showGoalsNorm, setShowGoalsNorm) = React.useState(() => NormalizationSelect.Simplified)
  let (solveConstraintsNorm, setSolveConstraintsNorm) = React.useState(() =>
    NormalizationSelect.Simplified
  )

  // State for compute mode
  let (computeMode, setComputeMode) = React.useState(() => ComputeModeSelect.DefaultCompute)

  // Helper to convert normalization to command string
  let normToString = norm =>
    switch norm {
    | NormalizationSelect.AsIs => "AsIs"
    | Simplified => "Simplified"
    | Instantiated => "Instantiated"
    | Normalised => "Normalised"
    | HeadNormal => "HeadNormal"
    }

  // Helper to convert compute mode to command string
  let computeModeToString = mode =>
    switch mode {
    | ComputeModeSelect.DefaultCompute => "DefaultCompute"
    | IgnoreAbstract => "IgnoreAbstract"
    | UseShowInstance => "UseShowInstance"
    }

  <div className="command-toolbar">
    <div className="toolbar-section">
      <h4> {React.string("Query Goal")} </h4>
      <div className="command-group">
        <CommandWithDropdown
          label="Goal Type"
          icon="codicon-symbol-method"
          normalization=goalTypeNorm
          onNormalizationChange={norm => setGoalTypeNorm(_ => norm)}
          onExecute={norm => onCommand("goal-type[" ++ normToString(norm) ++ "]")}
          dropdownId="goal-type-norm"
          title="Show the type of the goal (Ctrl+C Ctrl+T)"
        />
        <CommandWithDropdown
          label="Goal Type & Context"
          icon="codicon-list-tree"
          normalization=goalTypeContextNorm
          onNormalizationChange={norm => setGoalTypeContextNorm(_ => norm)}
          onExecute={norm => onCommand("goal-type-and-context[" ++ normToString(norm) ++ "]")}
          dropdownId="goal-type-context-norm"
          title="Show goal type and context (Ctrl+C Ctrl+E)"
        />
        <CommandWithDropdown
          label="Context"
          icon="codicon-list-flat"
          normalization=contextNorm
          onNormalizationChange={norm => setContextNorm(_ => norm)}
          onExecute={norm => onCommand("context[" ++ normToString(norm) ++ "]")}
          dropdownId="context-norm"
          title="Show context (Ctrl+C Ctrl+Shift+E)"
        />
      </div>
    </div>

    <div className="toolbar-section">
      <h4> {React.string("Goal Operations")} </h4>
      <div className="command-group">
        <CommandButton
          label="Give"
          icon="codicon-check"
          onClick={() => onCommand("give")}
          title="Fill goal with the given expression (Ctrl+C Ctrl+Space)"
        />
        <CommandButton
          label="Refine"
          icon="codicon-lightbulb"
          onClick={() => onCommand("refine")}
          title="Refine goal (Ctrl+C Ctrl+R)"
        />
        <CommandWithDropdown
          label="Auto"
          icon="codicon-wand"
          normalization=autoNorm
          onNormalizationChange={norm => setAutoNorm(_ => norm)}
          onExecute={norm => onCommand("auto[" ++ normToString(norm) ++ "]")}
          dropdownId="auto-norm"
          title="Search for proof automatically (Ctrl+C Ctrl+A)"
        />
        <CommandButton
          label="Case Split"
          icon="codicon-split-horizontal"
          onClick={() => onCommand("case")}
          title="Case split on variable (Ctrl+C Ctrl+C)"
        />
        <CommandWithDropdown
          label="Elaborate & Give"
          icon="codicon-bracket-dot"
          normalization=elaborateGiveNorm
          onNormalizationChange={norm => setElaborateGiveNorm(_ => norm)}
          onExecute={norm => onCommand("elaborate-and-give[" ++ normToString(norm) ++ "]")}
          dropdownId="elaborate-give-norm"
          title="Elaborate and give (Ctrl+C Ctrl+M)"
        />
      </div>
    </div>

    <div className="toolbar-section">
      <h4> {React.string("Inspect Expression")} </h4>
      <div className="command-group">
        <CommandWithDropdown
          label="Infer Type"
          icon="codicon-symbol-interface"
          normalization=inferTypeNorm
          onNormalizationChange={norm => setInferTypeNorm(_ => norm)}
          onExecute={norm => onCommand("infer-type[" ++ normToString(norm) ++ "]")}
          dropdownId="infer-type-norm"
          title="Infer type of expression (Ctrl+C Ctrl+D)"
        />
        <ComputeNormalFormCommand
          computeMode
          onComputeModeChange={mode => setComputeMode(_ => mode)}
          onExecute={mode => onCommand("compute-normal-form[" ++ computeModeToString(mode) ++ "]")}
        />
        <CommandWithDropdown
          label="Module Contents"
          icon="codicon-symbol-namespace"
          normalization=moduleContentsNorm
          onNormalizationChange={norm => setModuleContentsNorm(_ => norm)}
          onExecute={norm => onCommand("module-contents[" ++ normToString(norm) ++ "]")}
          dropdownId="module-contents-norm"
          title="Show module contents (Ctrl+C Ctrl+O)"
        />
        <CommandButton
          label="Why In Scope"
          icon="codicon-search"
          onClick={() => onCommand("why-in-scope")}
          title="Why is identifier in scope (Ctrl+C Ctrl+W)"
        />
      </div>
    </div>

    <div className="toolbar-section">
      <h4> {React.string("Global Commands")} </h4>
      <div className="command-group">
        <CommandWithDropdown
          label="Show Goals"
          icon="codicon-checklist"
          normalization=showGoalsNorm
          onNormalizationChange={norm => setShowGoalsNorm(_ => norm)}
          onExecute={norm => onCommand("show-goals[" ++ normToString(norm) ++ "]")}
          dropdownId="show-goals-norm"
          title="Show all goals"
        />
        <CommandButton
          label="Show Constraints"
          icon="codicon-warning"
          onClick={() => onCommand("show-constraints")}
          title="Show constraints (Ctrl+C Ctrl+=)"
        />
        <CommandWithDropdown
          label="Solve Constraints"
          icon="codicon-debug-stackframe-dot"
          normalization=solveConstraintsNorm
          onNormalizationChange={norm => setSolveConstraintsNorm(_ => norm)}
          onExecute={norm => onCommand("solve-constraints[" ++ normToString(norm) ++ "]")}
          dropdownId="solve-constraints-norm"
          title="Solve constraints"
        />
        <CommandButton
          label="Next Goal"
          icon="codicon-arrow-down"
          onClick={() => onCommand("next-goal")}
          title="Jump to next goal (Ctrl+C Ctrl+F)"
        />
        <CommandButton
          label="Previous Goal"
          icon="codicon-arrow-up"
          onClick={() => onCommand("previous-goal")}
          title="Jump to previous goal (Ctrl+C Ctrl+B)"
        />
      </div>
    </div>
  </div>
}

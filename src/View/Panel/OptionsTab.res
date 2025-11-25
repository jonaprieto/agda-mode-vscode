// Options tab component for Agda flags and settings

// Checkbox component for boolean flags
module FlagCheckbox = {
  @react.component
  let make = (~id: string, ~flag: string, ~description: string, ~checked: bool, ~onChange: bool => unit) => {
    <div className="flag-row">
      <label htmlFor={id} className="flag-checkbox-label">
        <input
          type_="checkbox"
          id
          checked
          onChange={e => onChange(ReactEvent.Form.target(e)["checked"])}
        />
        <span className="flag-name"> {React.string(flag)} </span>
      </label>
      <span className="flag-description"> {React.string(description)} </span>
    </div>
  }
}

// Text input component for string options
module OptionInput = {
  @react.component
  let make = (~id: string, ~label: string, ~placeholder: string, ~value: string, ~onChange: string => unit) => {
    <div className="option-input-row">
      <label htmlFor={id} className="option-label"> {React.string(label)} </label>
      <input
        type_="text"
        id
        className="option-text-input"
        placeholder
        value
        onChange={e => onChange(ReactEvent.Form.target(e)["value"])}
      />
    </div>
  }
}

@react.component
let make = (~flags: Common.AgdaFlags.t, ~onFlagsChange: Common.AgdaFlags.t => unit) => {
  <div className="agda-mode-options-tab">
    <div className="options-section">
      <h3> {React.string("Type Theory")} </h3>
      <div className="flags-group">
        <FlagCheckbox
          id="flag-safe"
          flag="--safe"
          description="Disable postulates, primTrustMe, etc."
          checked={flags.safe}
          onChange={safe => onFlagsChange({...flags, safe})}
        />
        <FlagCheckbox
          id="flag-without-k"
          flag="--without-K"
          description="Disable K rule (HoTT compatible)"
          checked={flags.withoutK}
          onChange={withoutK => onFlagsChange({...flags, withoutK})}
        />
        <FlagCheckbox
          id="flag-cubical-compatible"
          flag="--cubical-compatible"
          description="Implies --without-K"
          checked={flags.cubicalCompatible}
          onChange={cubicalCompatible => onFlagsChange({...flags, cubicalCompatible})}
        />
        <FlagCheckbox
          id="flag-prop"
          flag="--prop"
          description="Enable Prop universe"
          checked={flags.prop}
          onChange={prop => onFlagsChange({...flags, prop})}
        />
        <FlagCheckbox
          id="flag-two-level"
          flag="--two-level"
          description="Enable SSet* (strict sets)"
          checked={flags.twoLevel}
          onChange={twoLevel => onFlagsChange({...flags, twoLevel})}
        />
        <FlagCheckbox
          id="flag-cumulativity"
          flag="--cumulativity"
          description="Set ≤ Set₁"
          checked={flags.cumulativity}
          onChange={cumulativity => onFlagsChange({...flags, cumulativity})}
        />
      </div>
    </div>

    <div className="options-section">
      <h3> {React.string("Termination & Recursion")} </h3>
      <div className="flags-group">
        <FlagCheckbox
          id="flag-guardedness"
          flag="--guardedness"
          description="Guarded corecursion"
          checked={flags.guardedness}
          onChange={guardedness => onFlagsChange({...flags, guardedness})}
        />
        <FlagCheckbox
          id="flag-sized-types"
          flag="--sized-types"
          description="Sized types"
          checked={flags.sizedTypes}
          onChange={sizedTypes => onFlagsChange({...flags, sizedTypes})}
        />
        <FlagCheckbox
          id="flag-no-termination-check"
          flag="--no-termination-check"
          description="⚠ Unsafe"
          checked={flags.noTerminationCheck}
          onChange={noTerminationCheck => onFlagsChange({...flags, noTerminationCheck})}
        />
        <FlagCheckbox
          id="flag-no-positivity-check"
          flag="--no-positivity-check"
          description="⚠ Unsafe"
          checked={flags.noPositivityCheck}
          onChange={noPositivityCheck => onFlagsChange({...flags, noPositivityCheck})}
        />
      </div>
    </div>

    <div className="options-section">
      <h3> {React.string("Display")} </h3>
      <div className="flags-group">
        <FlagCheckbox
          id="flag-show-implicit"
          flag="--show-implicit"
          description="Show implicit args"
          checked={flags.showImplicit}
          onChange={showImplicit => onFlagsChange({...flags, showImplicit})}
        />
        <FlagCheckbox
          id="flag-show-irrelevant"
          flag="--show-irrelevant"
          description="Show irrelevant args"
          checked={flags.showIrrelevant}
          onChange={showIrrelevant => onFlagsChange({...flags, showIrrelevant})}
        />
      </div>
    </div>

    <div className="options-section">
      <h3> {React.string("Warnings & Errors")} </h3>
      <div className="flags-group">
        <FlagCheckbox
          id="flag-werror"
          flag="-Werror"
          description="Warnings as errors"
          checked={flags.warningError}
          onChange={warningError => onFlagsChange({...flags, warningError})}
        />
        <FlagCheckbox
          id="flag-allow-unsolved-metas"
          flag="--allow-unsolved-metas"
          description="Allow unsolved metas"
          checked={flags.allowUnsolvedMetas}
          onChange={allowUnsolvedMetas => onFlagsChange({...flags, allowUnsolvedMetas})}
        />
        <FlagCheckbox
          id="flag-allow-incomplete-matches"
          flag="--allow-incomplete-matches"
          description="Allow incomplete matches"
          checked={flags.allowIncompleteMatches}
          onChange={allowIncompleteMatches => onFlagsChange({...flags, allowIncompleteMatches})}
        />
      </div>
    </div>

    <div className="options-section">
      <h3> {React.string("Debug & Verbose")} </h3>
      <div className="flags-group">
        <FlagCheckbox
          id="flag-only-scope-checking"
          flag="--only-scope-checking"
          description="Only scope check"
          checked={flags.onlyScopeChecking}
          onChange={onlyScopeChecking => onFlagsChange({...flags, onlyScopeChecking})}
        />
      </div>
      <div className="options-group">
        <OptionInput
          id="opt-verbose"
          label="Verbose (-v):"
          placeholder="e.g., 10 or scope:20"
          value={flags.verboseLevel}
          onChange={verboseLevel => onFlagsChange({...flags, verboseLevel})}
        />
      </div>
    </div>

    <div className="options-section">
      <h3> {React.string("Paths")} </h3>
      <div className="options-group">
        <OptionInput
          id="opt-library"
          label="Library (-l):"
          placeholder="e.g., standard-library"
          value={flags.library}
          onChange={library => onFlagsChange({...flags, library})}
        />
        <OptionInput
          id="opt-include-path"
          label="Include (-i):"
          placeholder="e.g., ./src"
          value={flags.includePath}
          onChange={includePath => onFlagsChange({...flags, includePath})}
        />
      </div>
    </div>

    <div className="options-section active-flags-section">
      <h3> {React.string("Typecheck Command Preview")} </h3>
      <div className="active-flags">
        {
          let args = Common.AgdaFlags.toArgs(flags)
          let flagsStr = if Array.length(args) > 0 {
            " " ++ Array.join(args, " ")
          } else {
            ""
          }
          <code className="flags-preview"> 
            {React.string("agda --interaction" ++ flagsStr ++ " <file>")} 
          </code>
        }
      </div>
      <div className="restart-note">
        <span className="codicon codicon-info" />
        {React.string(" Changes require restarting the Agda connection (C-c C-x C-r)")}
      </div>
    </div>
  </div>
}

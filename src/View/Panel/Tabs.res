// Tab navigation component for the Agda panel
// Uses Common.Tab.t for shared type across modules

// Get codicon class name for each tab
let tabIconClass = (tab: Common.Tab.t): string =>
  switch tab {
  | Goals => "codicon-checklist"
  | Compile => "codicon-package"
  | AgdaFlags => "codicon-settings-gear"
  }

module TabButton = {
  @react.component
  let make = (~tab: Common.Tab.t, ~isActive: bool, ~onClick: unit => unit) => {
    let className = "tab" ++ (isActive ? " active" : "")
    let iconClass = "codicon " ++ tabIconClass(tab)
    <div className onClick={_ => onClick()}>
      <span className={iconClass} />
      {React.string(" " ++ Common.Tab.toString(tab))}
    </div>
  }
}

@react.component
let make = (~activeTab: Common.Tab.t, ~onTabChange: Common.Tab.t => unit) => {
  <div className="agda-mode-tabs">
    {Common.Tab.all
    ->Array.map(tab =>
      <TabButton
        key={Common.Tab.toString(tab)}
        tab
        isActive={tab == activeTab}
        onClick={() => onTabChange(tab)}
      />
    )
    ->React.array}
  </div>
}

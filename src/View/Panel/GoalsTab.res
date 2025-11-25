// Goals tab component - displays goals, context, and errors from Agda
// This wraps the existing Body display logic

@react.component
let make = (~header: View.Header.t, ~items: View.Body.t, ~connectionStatus: string) => {
  let headerClassName = switch header {
  | Plain(_) => "agda-mode-goals-header"
  | Success(_) => "agda-mode-goals-header success"
  | Warning(_) => "agda-mode-goals-header warning"
  | Error(_) => "agda-mode-goals-header error"
  }

  let headerText = View.Header.toString(header)

  <div className="agda-mode-goals-tab">
    <div className={headerClassName}>
      <span className="header-text"> {React.string(headerText)} </span>
      {connectionStatus != ""
        ? <span className="connection-status"> {React.string(connectionStatus)} </span>
        : React.null}
    </div>
    <div className="agda-mode-goals-body">
      <Body items />
    </div>
  </div>
}


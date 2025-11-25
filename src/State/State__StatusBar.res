// State management for the status bar typecheck indicator

// Global status bar instance (singleton pattern like WebviewPanel)
let statusBar: ref<option<StatusBar.t>> = ref(None)

let getOrCreate = (context: VSCode.ExtensionContext.t): StatusBar.t => {
  switch statusBar.contents {
  | Some(sb) => sb
  | None =>
    let sb = StatusBar.create(context)
    StatusBar.registerVisibilityListeners(sb, context)
    statusBar := Some(sb)
    sb
  }
}

let get = (): option<StatusBar.t> => statusBar.contents

// Update status bar when Load command starts
let onLoadStart = (): unit => {
  statusBar.contents->Option.forEach(sb => {
    StatusBar.update(sb, Checking)
  })
}

// Update status bar when Load command succeeds
let onLoadSuccess = (): unit => {
  statusBar.contents->Option.forEach(sb => {
    StatusBar.update(sb, Success)
  })
}

// Update status bar when Load command fails with errors
let onLoadError = (errors: array<string>): unit => {
  statusBar.contents->Option.forEach(sb => {
    StatusBar.update(sb, Error(errors))
  })
}

// Reset status bar to unchecked state
let reset = (): unit => {
  statusBar.contents->Option.forEach(sb => {
    StatusBar.update(sb, Unchecked)
  })
}

// Set the Agda version in status bar
let setVersion = (version: string): unit => {
  statusBar.contents->Option.forEach(sb => {
    StatusBar.setVersion(sb, version)
  })
}

// Helper to extract error messages from Response.DisplayInfo
let extractErrorMessages = (info: Response.DisplayInfo.t): option<array<string>> => {
  switch info {
  | Error(body) => Some([body])
  | AllGoalsWarnings(_, body) if String.includes(body, "Error") => Some([body])
  | _ => None
  }
}

// Handle response to update status bar
let handleResponse = (response: Response.t): unit => {
  switch response {
  | DisplayInfo(Error(body)) =>
    // Single error
    onLoadError([body])
  | DisplayInfo(AllGoalsWarnings(header, _body)) =>
    // Check if it's a success or has errors based on header
    if String.includes(header, "Error") {
      onLoadError([header])
    } else if String.includes(header, "All") && String.includes(header, "checked") {
      onLoadSuccess()
    }
  | DisplayInfo(AllGoalsWarningsALS(header, _goals, _metas, warnings, errors)) =>
    if Array.length(errors) > 0 {
      onLoadError(errors)
    } else if Array.length(warnings) > 0 {
      // Warnings but no errors - still success
      onLoadSuccess()
    } else if String.includes(header, "checked") {
      onLoadSuccess()
    }
  | DisplayInfo(CompilationOk(_)) => onLoadSuccess()
  | DisplayInfo(CompilationOkALS(_, errors)) =>
    if Array.length(errors) > 0 {
      onLoadError(errors)
    } else {
      onLoadSuccess()
    }
  | InteractionPoints(_) =>
    // Goals received means typecheck succeeded
    onLoadSuccess()
  | _ => ()
  }
}

// Cleanup
let destroy = (): unit => {
  statusBar.contents->Option.forEach(sb => {
    StatusBar.hide(sb)
  })
  statusBar := None
}


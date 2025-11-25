// Manages VS Code diagnostics (problems panel) for Agda errors

// Global diagnostics collection
let diagnosticsCollection: ref<option<VSCode.DiagnosticCollection.t>> = ref(None)

// Initialize the diagnostics collection
let init = (): VSCode.DiagnosticCollection.t => {
  let collection = VSCode.Languages.createDiagnosticCollection(Some("agda"))
  diagnosticsCollection := Some(collection)
  collection
}

// Get or create the diagnostics collection
let getOrCreate = (): VSCode.DiagnosticCollection.t => {
  switch diagnosticsCollection.contents {
  | Some(collection) => collection
  | None => init()
  }
}

// Clear all diagnostics
let clear = (): unit => {
  diagnosticsCollection.contents->Option.forEach(collection => {
    collection->VSCode.DiagnosticCollection.clear
  })
}

// Clear diagnostics for a specific file
let clearForUri = (uri: VSCode.Uri.t): unit => {
  diagnosticsCollection.contents->Option.forEach(collection => {
    collection->VSCode.DiagnosticCollection.delete(uri)
  })
}

// Parse an Agda error message to extract range information
// Error messages typically look like:
// "/path/to/file.agda:10,5-10,20: error message here"
// or "/path/to/file.agda:10.5-20\nerror message here"
let parseErrorRange = (errorText: string): option<Common.AgdaRange.t> => {
  // First try the full text
  switch Common.AgdaRange.parse(errorText) {
  | Some(range) => Some(range)
  | None =>
    // Try extracting just the first line or the part before ":"
    let firstLine = errorText->String.split("\n")->Array.get(0)->Option.getOr("")
    // Remove trailing colon and anything after if present (for "file:line.col-col: message")
    let rangeOnly = switch firstLine->String.indexOf(": ") {
    | position if position > 0 => String.slice(firstLine, ~start=0, ~end=position)
    | _ => firstLine
    }
    Common.AgdaRange.parse(rangeOnly)
  }
}

// Create a VS Code diagnostic from an error message
let createDiagnostic = (
  message: string,
  range: VSCode.Range.t,
  severity: VSCode.DiagnosticSeverity.t,
): VSCode.Diagnostic.t => {
  VSCode.Diagnostic.make(range, message, Some(severity))
}

// Set diagnostics for a document
let setDiagnostics = (uri: VSCode.Uri.t, diagnostics: array<VSCode.Diagnostic.t>): unit => {
  diagnosticsCollection.contents->Option.forEach(collection => {
    collection->VSCode.DiagnosticCollection.setDiagnostics(uri, diagnostics)
  })
}

// Add an error diagnostic for a document
let addError = (document: VSCode.TextDocument.t, message: string, rawRange: option<string>): unit => {
  let uri = document->VSCode.TextDocument.uri
  
  // Try to parse range from the raw range string, or use beginning of file
  let range = switch rawRange {
  | Some(raw) =>
    switch parseErrorRange(raw) {
    | Some(Common.AgdaRange.Range(_, intervals)) =>
      // Use first interval to create range
      switch intervals[0] {
      | Some(interval) => Common.AgdaInterval.toVSCodeRange(interval)
      | None => VSCode.Range.make(VSCode.Position.make(0, 0), VSCode.Position.make(0, 1))
      }
    | _ => VSCode.Range.make(VSCode.Position.make(0, 0), VSCode.Position.make(0, 1))
    }
  | None => VSCode.Range.make(VSCode.Position.make(0, 0), VSCode.Position.make(0, 1))
  }
  
  let diagnostic = createDiagnostic(message, range, VSCode.DiagnosticSeverity.Error)
  
  // Get existing diagnostics and append
  let collection = getOrCreate()
  let existing = collection->VSCode.DiagnosticCollection.get(uri)->Option.getOr([])
  let newDiagnostics = Array.concat(existing, [diagnostic])
  setDiagnostics(uri, newDiagnostics)
}

// Add a warning diagnostic for a document
let addWarning = (document: VSCode.TextDocument.t, message: string, rawRange: option<string>): unit => {
  let uri = document->VSCode.TextDocument.uri
  
  // Try to parse range from the raw range string, or use beginning of file
  let range = switch rawRange {
  | Some(raw) =>
    switch parseErrorRange(raw) {
    | Some(Common.AgdaRange.Range(_, intervals)) =>
      switch intervals[0] {
      | Some(interval) => Common.AgdaInterval.toVSCodeRange(interval)
      | None => VSCode.Range.make(VSCode.Position.make(0, 0), VSCode.Position.make(0, 1))
      }
    | _ => VSCode.Range.make(VSCode.Position.make(0, 0), VSCode.Position.make(0, 1))
    }
  | None => VSCode.Range.make(VSCode.Position.make(0, 0), VSCode.Position.make(0, 1))
  }
  
  let diagnostic = createDiagnostic(message, range, VSCode.DiagnosticSeverity.Warning)
  
  // Get existing diagnostics and append
  let collection = getOrCreate()
  let existing = collection->VSCode.DiagnosticCollection.get(uri)->Option.getOr([])
  let newDiagnostics = Array.concat(existing, [diagnostic])
  setDiagnostics(uri, newDiagnostics)
}

// Dispose of the diagnostics collection
let dispose = (): unit => {
  diagnosticsCollection.contents->Option.forEach(collection => {
    collection->VSCode.DiagnosticCollection.dispose
  })
  diagnosticsCollection := None
}


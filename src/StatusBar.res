// Status bar item for displaying typecheck status
// Following the pattern from vscode-juvix

type status =
  | Unchecked
  | Checking
  | Success
  | Error(array<string>)

let statusToString = status =>
  switch status {
  | Unchecked => "Unchecked"
  | Checking => "Checking"
  | Success => "Success"
  | Error(messages) => "Error(" ++ Array.length(messages)->Int.toString ++ " issues)"
  }

type t = {
  item: VSCode.StatusBarItem.t,
  mutable status: status,
  mutable errors: array<string>,
  mutable agdaVersion: option<string>,
}

// Priority for status bar item (higher = more to the left)
let priority = 100

// Raw binding to clear background color (set to undefined)
@set external clearBackgroundColor: (VSCode.StatusBarItem.t, Nullable.t<VSCode.ThemeColor.t>) => unit = "backgroundColor"

let create = (context: VSCode.ExtensionContext.t): t => {
  let item = VSCode.Window.createStatusBarItem(
    Some(VSCode.StatusBarAlignment.Right),
    Some(priority),
  )

  item->VSCode.StatusBarItem.setCommandWithString("agda-mode.show-goals[AsIs]")
  item->VSCode.StatusBarItem.setTooltip("Click to show Agda goals and errors")

  // Add to subscriptions for cleanup
  context->VSCode.ExtensionContext.subscriptions->Array.push(
    VSCode.Disposable.make(() => item->VSCode.StatusBarItem.dispose),
  )

  {
    item,
    status: Unchecked,
    errors: [],
    agdaVersion: None,
  }
}

// Helper to format the label with optional version
let formatLabel = (icon: string, version: option<string>): string => {
  switch version {
  | Some(v) => icon ++ " Agda " ++ v
  | None => icon ++ " Agda"
  }
}

let update = (self: t, status: status): unit => {
  self.status = status

  switch status {
  | Unchecked =>
    self.item->VSCode.StatusBarItem.setText(formatLabel("$(circle-outline)", self.agdaVersion))
    self.item->clearBackgroundColor(Nullable.null)
    self.item->VSCode.StatusBarItem.setTooltip("Agda: Not loaded")
    self.errors = []
  | Checking =>
    self.item->VSCode.StatusBarItem.setText(formatLabel("$(sync~spin)", self.agdaVersion))
    self.item->clearBackgroundColor(Nullable.null)
    self.item->VSCode.StatusBarItem.setTooltip("Agda: Type checking...")
    self.errors = []
  | Success =>
    self.item->VSCode.StatusBarItem.setText(formatLabel("$(check)", self.agdaVersion))
    self.item->VSCode.StatusBarItem.setBackgroundColor(
      VSCode.ThemeColor.make("statusBarItem.successBackground"),
    )
    self.item->VSCode.StatusBarItem.setTooltip("Agda: Type check passed")
    self.errors = []
  | Error(messages) =>
    self.item->VSCode.StatusBarItem.setText(formatLabel("$(error)", self.agdaVersion))
    self.item->VSCode.StatusBarItem.setBackgroundColor(
      VSCode.ThemeColor.make("statusBarItem.errorBackground"),
    )
    let errorCount = Array.length(messages)
    let tooltip =
      "Agda: " ++
      Int.toString(errorCount) ++
      (errorCount == 1 ? " error" : " errors") ++
      " - Click to show"
    self.item->VSCode.StatusBarItem.setTooltip(tooltip)
    self.errors = messages
  }
}

// Set the Agda version and update the display
let setVersion = (self: t, version: string): unit => {
  self.agdaVersion = Some(version)
  // Re-render with new version
  update(self, self.status)
}

let show = (self: t): unit => {
  self.item->VSCode.StatusBarItem.show
}

let hide = (self: t): unit => {
  self.item->VSCode.StatusBarItem.hide
}

let getStatus = (self: t): status => self.status

let getErrors = (self: t): array<string> => self.errors

// Check if the document is an Agda file
let isAgdaFile = (document: VSCode.TextDocument.t): bool => {
  let languageId = document->VSCode.TextDocument.languageId
  languageId == "agda" ||
  languageId == "lagda-markdown" ||
  languageId == "lagda-tex" ||
  languageId == "lagda-rst" ||
  languageId == "lagda-org" ||
  languageId == "lagda-typst" ||
  languageId == "lagda-forester"
}

// Update visibility based on active editor
let updateVisibility = (self: t, editor: option<VSCode.TextEditor.t>): unit => {
  switch editor {
  | Some(editor) =>
    let document = editor->VSCode.TextEditor.document
    if isAgdaFile(document) {
      show(self)
    } else {
      hide(self)
    }
  | None => hide(self)
  }
}

// Register event listeners for visibility updates
let registerVisibilityListeners = (self: t, context: VSCode.ExtensionContext.t): unit => {
  // Update on active editor change
  let disposable = VSCode.Window.onDidChangeActiveTextEditor(editor => {
    updateVisibility(self, editor)
  })
  context->VSCode.ExtensionContext.subscriptions->Array.push(disposable)

  // Initial update
  updateVisibility(self, VSCode.Window.activeTextEditor)
}

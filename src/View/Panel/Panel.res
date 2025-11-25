@react.component
let make = (
  ~onRequest: Chan.t<View.Request.t>,
  ~onEventToView: Chan.t<View.EventToView.t>,
  ~onResponse: Chan.t<View.Response.t>,
  ~onEventFromView: Chan.t<View.EventFromView.t>,
) => {
  let (header, setHeader) = React.useState(() => View.Header.Plain("Loading ..."))
  let (connectionStatus, setConnectionStatus) = React.useState(() => "")
  let (body, setBody) = React.useState(() => [])
  // save Header & Body up
  // so that we can restore them if the prompt is interrupted
  let savedHeaderAndBody = React.useRef(None)
  let saveHeaderAndBody = (header, body) => savedHeaderAndBody.current = Some((header, body))
  let restoreHeaderAndBody = () =>
    savedHeaderAndBody.current->Option.forEach(((header, body)) => {
      setHeader(_ => header)
      setBody(_ => body)
    })

  let (prompt, setPrompt) = React.useState(() => None)
  let prompting = prompt->Option.isSome

  let (inputMethodState, runInputMethodAction) = React.useReducer(Keyboard.reducer, None)

  // Tab and compile state
  let (activeTab, setActiveTab) = React.useState(() => Common.Tab.Goals)
  let (compileOptions, setCompileOptions) = React.useState(() => Common.CompileOptions.default)
  let (compileOutput, setCompileOutput) = React.useState(() => [])
  let (compileIsError, setCompileIsError) = React.useState(() => false)
  let (isCompiling, setIsCompiling) = React.useState(() => false)
  let (agdaFlags, setAgdaFlags) = React.useState(() => Common.AgdaFlags.default)
  let (commandPreview, setCommandPreview) = React.useState(() => "")

  let setFontSize = %raw(` function (n) { document.documentElement.style.setProperty("--agdaMode-buffer-font-size", n + "px"); } `)

  // emit event Initialized on mount
  React.useEffect1(() => {
    onEventFromView->Chan.emit(Initialized)
    None
  }, [])

  let promptResponseResolver = React.useRef(None)
  let onSubmit = result =>
    promptResponseResolver.current->Option.forEach(resolve => {
      setPrompt(_ => None)
      resolve(result)
      promptResponseResolver.current = None
    })
  let onUpdatePromptIM = action => onEventFromView->Chan.emit(PromptIMUpdate(action))

  // on receiving View Requests
  Hook.recv(onRequest, onResponse, async msg =>
    switch msg {
    | Prompt(header', {body, placeholder, value}) =>
      // set the view
      setHeader(_ => header')
      setBody(_ => [])
      // don't erase the value in <input>
      setPrompt(previous =>
        switch previous {
        | None => Some((body, placeholder, value))
        | Some((_, _, None)) => Some((body, placeholder, value))
        | Some((_, _, Some(oldValue))) => Some((body, placeholder, Some(oldValue)))
        }
      )

      let promise = Promise.make((resolve, _) => promptResponseResolver.current = Some(resolve))
      switch await promise {
      | None => View.Response.PromptInterrupted
      | Some(result) => View.Response.PromptSuccess(result)
      }
    }
  )

  // on receiving Events to View
  Hook.on(onEventToView, event =>
    switch event {
    | InputMethod(action) => runInputMethodAction(action)
    | PromptIMUpdate(text) =>
      setPrompt(x =>
        switch x {
        | Some((body, placeholder, _)) => Some((body, placeholder, Some(text)))
        | None => None
        }
      )
    | PromptInterrupt =>
      onSubmit(None)
      setPrompt(_ => None)
      restoreHeaderAndBody()
    | Display(header, body) =>
      onSubmit(None)
      saveHeaderAndBody(header, body)
      setHeader(_ => header)
      setBody(_ => body)
    | Append(header, body) =>
      onSubmit(None)
      saveHeaderAndBody(header, body)
      setHeader(_ => header)
      setBody(old => Array.concat(old, body)) // append instead of flush
    | SetConnectionStatus(text) => setConnectionStatus(_ => text)
    | ConfigurationChange(n) =>
      onSubmit(None)
      setFontSize(n)
    | SetCompileOutput(output, isError) =>
      setCompileOutput(_ => output)
      setCompileIsError(_ => isError)
    | SetCompileStatus(compiling) => setIsCompiling(_ => compiling)
    | SetActiveTab(tab) => setActiveTab(_ => tab)
    | SetCommandPreview(preview) => setCommandPreview(_ => preview)
    }
  )

  // relay events from <Link.Event.Provider> to `onEventFromView`
  let onLinkEvent: Chan.t<Link.Event.t> = Chan.make()
  let _ = onLinkEvent->Chan.on(event =>
    switch event {
    | JumpToTarget(link) => onEventFromView->Chan.emit(JumpToTarget(link))
    | _ => ()
    }
  )

  // Tab change handler
  let handleTabChange = (tab: Common.Tab.t) => {
    setActiveTab(_ => tab)
    onEventFromView->Chan.emit(TabChanged(tab))
  }

  // Compile handler
  let handleCompile = () => {
    onEventFromView->Chan.emit(CompileRequested(compileOptions))
  }

  // Run binary handler
  let handleRun = (command: string, outputPath: string) => {
    onEventFromView->Chan.emit(RunBinaryRequested(command, outputPath))
  }

  <Link.Event.Provider value=onLinkEvent>
    <View.EventFromView.Provider value=onEventFromView>
      <section className="agda-mode native-key-bindings" tabIndex={-1}>
        <div className="agda-mode-header-container">
          <Header header connectionStatus onConnectionStatusClick={() => onEventFromView->Chan.emit(ConnectionStatusClicked)} />
          <Prompt
            inputMethodActivated={Option.isSome(inputMethodState)} prompt onUpdatePromptIM onSubmit
          />
          <Keyboard
            state=inputMethodState
            onInsertChar={char => onEventFromView->Chan.emit(InputMethod(InsertChar(char)))}
            onChooseSymbol={symbol => onEventFromView->Chan.emit(InputMethod(ChooseSymbol(symbol)))}
            prompting
          />
        </div>
        <div className="agda-mode-content">
          <Tabs activeTab onTabChange=handleTabChange />
          {switch activeTab {
          | Goals =>
            <>
              <CommandToolbar
                onCommand={cmd => onEventFromView->Chan.emit(CommandRequested(cmd))}
              />
              <Body items=body />
            </>
          | Compile =>
            <CompileTab
              options=compileOptions
              onOptionsChange={opts => setCompileOptions(_ => opts)}
              output=compileOutput
              isError=compileIsError
              isCompiling
              onCompile=handleCompile
              onRun=handleRun
              commandPreview
            />
          | AgdaFlags =>
            <OptionsTab
              flags=agdaFlags
              onFlagsChange={flags => {
                setAgdaFlags(_ => flags)
                onEventFromView->Chan.emit(AgdaFlagsChanged(flags))
              }}
            />
          }}
        </div>
      </section>
    </View.EventFromView.Provider>
  </Link.Event.Provider>
}

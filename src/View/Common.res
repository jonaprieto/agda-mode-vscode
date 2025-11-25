// NOTE:
//
//  VSCode imports should not be allowed in this module, otherwise it would contaminate the view
//

// Tab type for panel navigation
module Tab = {
  type t =
    | Goals
    | Compile
    | AgdaFlags

  let toString = tab =>
    switch tab {
    | Goals => "Goals"
    | Compile => "Compile"
    | AgdaFlags => "Agda Flags"
    }

  let fromString = s =>
    switch s {
    | "Compile" => Compile
    | "AgdaFlags" | "Agda Flags" => AgdaFlags
    | _ => Goals
    }

  let all: array<t> = [Goals, Compile, AgdaFlags]

  let encode = tab => {
    open JsonCombinators.Json.Encode
    string(toString(tab))
  }

  let decode = {
    open JsonCombinators.Json.Decode
    string->map(fromString)
  }
}

// Agda flags/options for the Options tab
module AgdaFlags = {
  type t = {
    // Type theory flags (from agda --help)
    safe: bool,              // --safe: disable unsafe features
    withoutK: bool,          // --without-K: compatible with HoTT
    cubicalCompatible: bool, // --cubical-compatible: generate cubical-compatible code
    prop: bool,              // --prop: enable Prop universe
    twoLevel: bool,          // --two-level: enable SSet* universes
    cumulativity: bool,      // --cumulativity: universe subtyping
    // Termination/Recursion flags
    guardedness: bool,       // --guardedness: enable guarded corecursion
    sizedTypes: bool,        // --sized-types: enable sized types
    noTerminationCheck: bool, // --no-termination-check
    noPositivityCheck: bool,  // --no-positivity-check
    // Display flags
    showImplicit: bool,      // --show-implicit
    showIrrelevant: bool,    // --show-irrelevant
    // Warning flags
    warningError: bool,      // -Werror: treat warnings as errors
    allowUnsolvedMetas: bool, // --allow-unsolved-metas
    allowIncompleteMatches: bool, // --allow-incomplete-matches
    // Verbose/Debug
    verboseLevel: string,    // -v N: verbosity level
    onlyScopeChecking: bool, // --only-scope-checking
    // Paths
    library: string,         // -l LIB
    includePath: string,     // -i DIR
  }

  let default: t = {
    safe: false,
    withoutK: false,
    cubicalCompatible: false,
    prop: false,
    twoLevel: false,
    cumulativity: false,
    guardedness: false,
    sizedTypes: false,
    noTerminationCheck: false,
    noPositivityCheck: false,
    showImplicit: false,
    showIrrelevant: false,
    warningError: false,
    allowUnsolvedMetas: false,
    allowIncompleteMatches: false,
    verboseLevel: "",
    onlyScopeChecking: false,
    library: "",
    includePath: "",
  }

  let encode = (flags: t) => {
    open JsonCombinators.Json.Encode
    Unsafe.object({
      "safe": bool(flags.safe),
      "withoutK": bool(flags.withoutK),
      "cubicalCompatible": bool(flags.cubicalCompatible),
      "prop": bool(flags.prop),
      "twoLevel": bool(flags.twoLevel),
      "cumulativity": bool(flags.cumulativity),
      "guardedness": bool(flags.guardedness),
      "sizedTypes": bool(flags.sizedTypes),
      "noTerminationCheck": bool(flags.noTerminationCheck),
      "noPositivityCheck": bool(flags.noPositivityCheck),
      "showImplicit": bool(flags.showImplicit),
      "showIrrelevant": bool(flags.showIrrelevant),
      "warningError": bool(flags.warningError),
      "allowUnsolvedMetas": bool(flags.allowUnsolvedMetas),
      "allowIncompleteMatches": bool(flags.allowIncompleteMatches),
      "verboseLevel": string(flags.verboseLevel),
      "onlyScopeChecking": bool(flags.onlyScopeChecking),
      "library": string(flags.library),
      "includePath": string(flags.includePath),
    })
  }

  let decode = {
    open JsonCombinators.Json.Decode
    object(field => {
      safe: field.required("safe", bool),
      withoutK: field.required("withoutK", bool),
      cubicalCompatible: field.required("cubicalCompatible", bool),
      prop: field.required("prop", bool),
      twoLevel: field.required("twoLevel", bool),
      cumulativity: field.required("cumulativity", bool),
      guardedness: field.required("guardedness", bool),
      sizedTypes: field.required("sizedTypes", bool),
      noTerminationCheck: field.required("noTerminationCheck", bool),
      noPositivityCheck: field.required("noPositivityCheck", bool),
      showImplicit: field.required("showImplicit", bool),
      showIrrelevant: field.required("showIrrelevant", bool),
      warningError: field.required("warningError", bool),
      allowUnsolvedMetas: field.required("allowUnsolvedMetas", bool),
      allowIncompleteMatches: field.required("allowIncompleteMatches", bool),
      verboseLevel: field.required("verboseLevel", string),
      onlyScopeChecking: field.required("onlyScopeChecking", bool),
      library: field.required("library", string),
      includePath: field.required("includePath", string),
    })
  }

  // Convert flags to command line arguments
  let toArgs = (flags: t): array<string> => {
    let args = []
    if flags.safe { args->Array.push("--safe")->ignore }
    if flags.withoutK { args->Array.push("--without-K")->ignore }
    if flags.cubicalCompatible { args->Array.push("--cubical-compatible")->ignore }
    if flags.prop { args->Array.push("--prop")->ignore }
    if flags.twoLevel { args->Array.push("--two-level")->ignore }
    if flags.cumulativity { args->Array.push("--cumulativity")->ignore }
    if flags.guardedness { args->Array.push("--guardedness")->ignore }
    if flags.sizedTypes { args->Array.push("--sized-types")->ignore }
    if flags.noTerminationCheck { args->Array.push("--no-termination-check")->ignore }
    if flags.noPositivityCheck { args->Array.push("--no-positivity-check")->ignore }
    if flags.showImplicit { args->Array.push("--show-implicit")->ignore }
    if flags.showIrrelevant { args->Array.push("--show-irrelevant")->ignore }
    if flags.warningError { args->Array.push("-Werror")->ignore }
    if flags.allowUnsolvedMetas { args->Array.push("--allow-unsolved-metas")->ignore }
    if flags.allowIncompleteMatches { args->Array.push("--allow-incomplete-matches")->ignore }
    if flags.verboseLevel != "" { args->Array.push("-v")->ignore; args->Array.push(flags.verboseLevel)->ignore }
    if flags.onlyScopeChecking { args->Array.push("--only-scope-checking")->ignore }
    if flags.library != "" { args->Array.push("-l")->ignore; args->Array.push(flags.library)->ignore }
    if flags.includePath != "" { args->Array.push("-i")->ignore; args->Array.push(flags.includePath)->ignore }
    args
  }
}

// Backend type for compile options
module Backend = {
  type t =
    | GHC
    | GHCNoMain
    | LaTeX
    | QuickLaTeX
    | HTML
    | JS

  let toString = backend =>
    switch backend {
    | GHC => "GHC"
    | GHCNoMain => "GHCNoMain"
    | LaTeX => "LaTeX"
    | QuickLaTeX => "QuickLaTeX"
    | HTML => "HTML"
    | JS => "JS"
    }

  let description = backend =>
    switch backend {
    | GHC => "GHC (with main)"
    | GHCNoMain => "GHC (library)"
    | LaTeX => "LaTeX"
    | QuickLaTeX => "QuickLaTeX"
    | HTML => "HTML"
    | JS => "JavaScript"
    }

  let fromString = s =>
    switch s {
    | "GHCNoMain" => GHCNoMain
    | "LaTeX" => LaTeX
    | "QuickLaTeX" => QuickLaTeX
    | "HTML" => HTML
    | "JS" => JS
    | _ => GHC
    }

  let all: array<t> = [GHC, GHCNoMain, LaTeX, QuickLaTeX, HTML, JS]

  let encode = backend => {
    open JsonCombinators.Json.Encode
    string(toString(backend))
  }

  let decode = {
    open JsonCombinators.Json.Decode
    string->map(fromString)
  }
}

// HTML-specific options
module HtmlOptions = {
  type t = {
    cssDir: string,
    highlightOccurrences: bool,
    onlyCode: bool,
  }

  let default: t = {
    cssDir: "",
    highlightOccurrences: false,
    onlyCode: false,
  }
}

// LaTeX-specific options  
module LatexOptions = {
  type t = {
    countClusters: bool,
  }

  let default: t = {
    countClusters: false,
  }
}

// Compile options type
module CompileOptions = {
  type t = {
    backend: Backend.t,
    // GHC options
    ghcOptions: string,
    // Main module path (for GHC compilation, leave empty to use current file)
    mainModule: string,
    // Run command for compiled binary
    runCommand: string,
    // Common options
    outputPath: string,
    // HTML options
    htmlOptions: HtmlOptions.t,
    // LaTeX options
    latexOptions: LatexOptions.t,
  }

  let default: t = {
    backend: GHC,
    ghcOptions: "",
    mainModule: "", // empty means use current file
    runCommand: "./Main",
    outputPath: "./build",
    htmlOptions: HtmlOptions.default,
    latexOptions: LatexOptions.default,
  }

  let encode = options => {
    open JsonCombinators.Json.Encode
    Unsafe.object({
      "backend": Backend.encode(options.backend),
      "ghcOptions": string(options.ghcOptions),
      "mainModule": string(options.mainModule),
      "runCommand": string(options.runCommand),
      "outputPath": string(options.outputPath),
      "htmlCssDir": string(options.htmlOptions.cssDir),
      "htmlHighlightOccurrences": bool(options.htmlOptions.highlightOccurrences),
      "htmlOnlyCode": bool(options.htmlOptions.onlyCode),
      "latexCountClusters": bool(options.latexOptions.countClusters),
    })
  }

  let decode = {
    open JsonCombinators.Json.Decode
    object(field => {
      backend: field.required("backend", Backend.decode),
      ghcOptions: field.required("ghcOptions", string),
      mainModule: field.optional("mainModule", string)->Option.getOr(""),
      runCommand: field.optional("runCommand", string)->Option.getOr("./Main"),
      outputPath: field.required("outputPath", string),
      htmlOptions: {
        cssDir: field.optional("htmlCssDir", string)->Option.getOr(""),
        highlightOccurrences: field.optional("htmlHighlightOccurrences", bool)->Option.getOr(false),
        onlyCode: field.optional("htmlOnlyCode", bool)->Option.getOr(false),
      },
      latexOptions: {
        countClusters: field.optional("latexCountClusters", bool)->Option.getOr(false),
      },
    })
  }
}

module AgdaPosition = {
  type t = {
    line: int,
    col: int,
    pos: int,
  }

  let toVSCodePosition = (position: t) => VSCode.Position.make(position.line - 1, position.col - 1)

  let decode = {
    open JsonCombinators.Json.Decode
    tuple3(int, int, int)->map(((line, col, pos)) => {
      line,
      col,
      pos,
    })
  }

  let encode = ({line, col, pos}) => {
    open JsonCombinators.Json.Encode
    tuple3(int, int, int)((line, col, pos))
  }
}

module AgdaInterval = {
  type t = {
    start: AgdaPosition.t,
    end_: AgdaPosition.t,
  }

  let make = (start, end_) => {start, end_}

  let toVSCodeRange = (range: t) =>
    VSCode.Range.make(
      AgdaPosition.toVSCodePosition(range.start),
      AgdaPosition.toVSCodePosition(range.end_),
    )

  let fuse = (a, b) => {
    let start = if a.start.pos > b.start.pos {
      b.start
    } else {
      a.start
    }
    let end_ = if a.end_.pos > b.end_.pos {
      a.end_
    } else {
      b.end_
    }
    {start, end_}
  }

  let toString = (self): string =>
    if self.start.line === self.end_.line {
      string_of_int(self.start.line) ++
      ("," ++
      (string_of_int(self.start.col) ++ ("-" ++ string_of_int(self.end_.col))))
    } else {
      string_of_int(self.start.line) ++
      ("," ++
      (string_of_int(self.start.col) ++
      ("-" ++
      (string_of_int(self.end_.line) ++ ("," ++ string_of_int(self.end_.col))))))
    }

  let decode = {
    open JsonCombinators.Json.Decode
    tuple2(AgdaPosition.decode, AgdaPosition.decode)->map(((start, end_)) => {
      start,
      end_,
    })
  }

  let encode = ({start, end_}) => {
    open JsonCombinators.Json.Encode
    tuple2(AgdaPosition.encode, AgdaPosition.encode)((start, end_))
  }
}

module AgdaRange = {
  type t =
    | NoRange
    | Range(option<string>, array<AgdaInterval.t>)

  let parse = %re(
    // Regex updated for Agda 2.8.0 compatibility
    // There are 3 types of range, each supporting both comma and dot separators:
    //  type 1: filepath:line,col-line,col OR filepath:line.col-line.col
    //  type 2: filepath:line,col-col OR filepath:line.col-col
    //  type 3: filepath:line,col OR filepath:line.col

    /* filepath  | line[,.]col-line[,.]col       |    line[,.]col-col   |   line[,.]col | */
    "/^(\S+)\:(?:(\d+)[,\.](\d+)\-(\d+)[,\.](\d+)|(\d+)[,\.](\d+)\-(\d+)|(\d+)[,\.](\d+))$/"
  )->(Emacs__Parser.captures(captured => {
      open Option
      let flatten = xs => xs->flatMap(x => x)
      // filepath: captured[1]
      // type 1: captured[2] ~ captured[5]
      // type 2: captured[6] ~ captured[8]
      // type 3: captured[9] ~ captured[10]
      let srcFile = captured[1]->flatten
      let isType1 = captured[2]->flatten->isSome
      let isType2 = captured[6]->flatten->isSome
      if isType1 {
        captured[2]
        ->flatten
        ->flatMap(int_of_string_opt)
        ->flatMap(rowStart =>
          captured[3]
          ->flatten
          ->flatMap(int_of_string_opt)
          ->flatMap(
            colStart =>
              captured[4]
              ->flatten
              ->flatMap(int_of_string_opt)
              ->flatMap(
                rowEnd =>
                  captured[5]
                  ->flatten
                  ->flatMap(int_of_string_opt)
                  ->flatMap(
                    colEnd => Some(
                      Range(
                        srcFile,
                        [
                          {
                            start: {
                              pos: 0,
                              line: rowStart,
                              col: colStart,
                            },
                            end_: {
                              pos: 0,
                              line: rowEnd,
                              col: colEnd,
                            },
                          },
                        ],
                      ),
                    ),
                  ),
              ),
          )
        )
      } else if isType2 {
        captured[6]
        ->flatten
        ->flatMap(int_of_string_opt)
        ->flatMap(row =>
          captured[7]
          ->flatten
          ->flatMap(int_of_string_opt)
          ->flatMap(
            colStart =>
              captured[8]
              ->flatten
              ->flatMap(int_of_string_opt)
              ->flatMap(
                colEnd => Some(
                  Range(
                    srcFile,
                    [
                      {
                        start: {
                          pos: 0,
                          line: row,
                          col: colStart,
                        },
                        end_: {
                          pos: 0,
                          line: row,
                          col: colEnd,
                        },
                      },
                    ],
                  ),
                ),
              ),
          )
        )
      } else {
        captured[9]
        ->flatten
        ->flatMap(int_of_string_opt)
        ->flatMap(row =>
          captured[10]
          ->flatten
          ->flatMap(int_of_string_opt)
          ->flatMap(
            col => Some(
              Range(
                srcFile,
                [
                  {
                    start: {
                      pos: 0,
                      line: row,
                      col,
                    },
                    end_: {
                      pos: 0,
                      line: row,
                      col,
                    },
                  },
                ],
              ),
            ),
          )
        )
      }
    }, ...))

  let fuse = (a: t, b: t): t => {
    open AgdaInterval

    let mergeTouching = (l, e, s, r) =>
      Belt.List.concat(Belt.List.concat(l, list{{start: e.start, end_: s.end_}}), r)

    let rec fuseSome = (s1, r1, s2, r2) => {
      let r1' = Util.List.dropWhile(x => x.end_.pos <= s2.end_.pos, r1)
      helpFuse(r1', list{AgdaInterval.fuse(s1, s2), ...r2})
    }
    and outputLeftPrefix = (s1, r1, s2, is2) => {
      let (r1', r1'') = Util.List.span(s => s.end_.pos < s2.start.pos, r1)
      Belt.List.concat(Belt.List.concat(list{s1}, r1'), helpFuse(r1'', is2))
    }
    and helpFuse = (a: Belt.List.t<AgdaInterval.t>, b: Belt.List.t<AgdaInterval.t>) =>
      switch (a, Belt.List.reverse(a), b, Belt.List.reverse(b)) {
      | (list{}, _, _, _) => a
      | (_, _, list{}, _) => b
      | (list{s1, ...r1}, list{e1, ...l1}, list{s2, ...r2}, list{e2, ...l2}) =>
        if e1.end_.pos < s2.start.pos {
          Belt.List.concat(a, b)
        } else if e2.end_.pos < s1.start.pos {
          Belt.List.concat(b, a)
        } else if e1.end_.pos === s2.start.pos {
          mergeTouching(l1, e1, s2, r2)
        } else if e2.end_.pos === s1.start.pos {
          mergeTouching(l2, e2, s1, r1)
        } else if s1.end_.pos < s2.start.pos {
          outputLeftPrefix(s1, r1, s2, b)
        } else if s2.end_.pos < s1.start.pos {
          outputLeftPrefix(s2, r2, s1, a)
        } else if s1.end_.pos < s2.end_.pos {
          fuseSome(s1, r1, s2, r2)
        } else {
          fuseSome(s2, r2, s1, r1)
        }
      | _ => failwith("something wrong with Range::fuse")
      }
    switch (a, b) {
    | (NoRange, r2) => r2
    | (r1, NoRange) => r1
    | (Range(f, r1), Range(_, r2)) =>
      Range(f, helpFuse(Belt.List.fromArray(r1), Belt.List.fromArray(r2))->Belt.List.toArray)
    }
  }

  let toString = (self: t): string =>
    switch self {
    | NoRange => ""
    | Range(Some(filepath), []) => filepath
    | Range(None, xs) =>
      switch (xs[0], xs[Array.length(xs) - 1]) {
      | (Some(first), Some(last)) => AgdaInterval.toString({start: first.start, end_: last.end_})
      | _ => ""
      }
    | Range(Some(filepath), xs) =>
      switch (xs[0], xs[Array.length(xs) - 1]) {
      | (Some(first), Some(last)) =>
        filepath ++ ":" ++ AgdaInterval.toString({start: first.start, end_: last.end_})
      | _ => ""
      }
    }

  let decode = {
    open JsonCombinators.Json.Decode
    Util.Decode.sum(x => {
      switch x {
      | "Range" =>
        Payload(
          pair(option(string), array(AgdaInterval.decode))->map(((source, intervals)) => Range(
            source,
            intervals,
          )),
        )
      | "NoRange" => TagOnly(NoRange)
      | tag => raise(DecodeError("[AgdaRange] Unknown constructor: " ++ tag))
      }
    })
  }

  let encode = {
    open JsonCombinators.Json.Encode
    Util.Encode.sum(x =>
      switch x {
      | NoRange => TagOnly("NoRange")
      | Range(source, intervals) =>
        Payload("Range", pair(option(string), array(AgdaInterval.encode))((source, intervals)))
      }
    , ...)
  }
}

// NOTE: This is not related to VSCode or Agda
// NOTE: eliminate this
module Interval = {
  type t = (int, int)

  let contains = (interval, offset) => {
    let (start, end_) = interval
    start <= offset && offset <= end_
  }

  let decode = {
    open JsonCombinators.Json.Decode
    pair(int, int)
  }

  let encode = {
    open JsonCombinators.Json.Encode
    pair(int, int)
  }

  let toVSCodeRange = (document, interval) =>
    VSCode.Range.make(
      VSCode.TextDocument.positionAt(document, fst(interval)),
      VSCode.TextDocument.positionAt(document, snd(interval)),
    )

  let fromVSCodeRange = (document, range) => (
    VSCode.TextDocument.offsetAt(document, VSCode.Range.start(range)),
    VSCode.TextDocument.offsetAt(document, VSCode.Range.end_(range)),
  )
}

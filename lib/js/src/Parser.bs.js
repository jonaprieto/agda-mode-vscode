// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Path = require("path");
var Curry = require("bs-platform/lib/js/curry.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Belt_Option = require("bs-platform/lib/js/belt_Option.js");
var Caml_format = require("bs-platform/lib/js/caml_format.js");
var Caml_option = require("bs-platform/lib/js/caml_option.js");
var Caml_chrome_debugger = require("bs-platform/lib/js/caml_chrome_debugger.js");

function split(s) {
  return Belt_Array.keepMap(Belt_Array.map(s.split(/\r\n|\n/), (function (chunk) {
                    if (chunk !== undefined && chunk !== "") {
                      return chunk;
                    }
                    
                  })), (function (x) {
                return x;
              }));
}

function map(f, x) {
  if (x) {
    return /* Yield */Caml_chrome_debugger.simpleVariant("Yield", [Curry._1(f, x[0])]);
  } else {
    return /* Stop */0;
  }
}

function tap(f, x) {
  if (!x) {
    return /* Stop */0;
  }
  var x$1 = x[0];
  Curry._1(f, x$1);
  return /* Yield */Caml_chrome_debugger.simpleVariant("Yield", [x$1]);
}

function flatMap(f, x) {
  if (x) {
    return Curry._1(f, x[0]);
  } else {
    return /* Stop */0;
  }
}

var $$Event = {
  map: map,
  tap: tap,
  flatMap: flatMap
};

function make(initialContinuation, callback) {
  return {
          initialContinuation: initialContinuation,
          continuation: {
            contents: undefined
          },
          callback: callback
        };
}

function feed(self, input) {
  var $$continue = Belt_Option.getWithDefault(self.continuation.contents, self.initialContinuation);
  var err = Curry._1($$continue, input);
  switch (err.tag | 0) {
    case /* Error */0 :
        return Curry._1(self.callback, /* Yield */Caml_chrome_debugger.simpleVariant("Yield", [/* Error */Caml_chrome_debugger.variant("Error", 1, [err[0]])]));
    case /* Continue */1 :
        self.continuation.contents = err[0];
        return ;
    case /* Done */2 :
        Curry._1(self.callback, /* Yield */Caml_chrome_debugger.simpleVariant("Yield", [/* Ok */Caml_chrome_debugger.variant("Ok", 0, [err[0]])]));
        self.continuation.contents = undefined;
        return ;
    
  }
}

function stop(self) {
  return Curry._1(self.callback, /* Stop */0);
}

var Incr = {
  $$Event: $$Event,
  make: make,
  feed: feed,
  stop: stop
};

function toString(s) {
  if (s.tag) {
    return "[" + (Belt_Array.map(s[0], toString).join(", ") + "]");
  } else {
    return "\"" + (s[0] + "\"");
  }
}

function preprocess(string) {
  if (string.substring(0, 13) === "cannot read: ") {
    return /* Error */Caml_chrome_debugger.variant("Error", 1, [string.slice(12)]);
  } else {
    return /* Ok */Caml_chrome_debugger.variant("Ok", 0, [string]);
  }
}

function flatten(s) {
  if (s.tag) {
    return Belt_Array.concatMany(Belt_Array.map(s[0], flatten));
  } else {
    return [s[0]];
  }
}

function parseWithContinuation(string) {
  var parseSExpression = function (state, string) {
    var in_str = state.in_str;
    var escaped = state.escaped;
    var word = state.word;
    var stack = state.stack;
    var pushToTheTop = function (elem) {
      var index = stack.length - 1 | 0;
      var expr = Belt_Array.get(stack, index);
      if (expr === undefined) {
        return ;
      }
      var xs = expr.contents;
      if (!xs.tag) {
        expr.contents = /* L */Caml_chrome_debugger.variant("L", 1, [[
              expr.contents,
              elem
            ]]);
        return ;
      }
      xs[0].push(elem);
      
    };
    var totalLength = string.length;
    for(var i = 0; i < totalLength; ++i){
      var $$char = string.charAt(i);
      if (escaped.contents) {
        if ($$char === "n") {
          word.contents = word.contents + "\\";
        }
        word.contents = word.contents + $$char;
        escaped.contents = false;
      } else if (!($$char === "'" && !in_str.contents)) {
        if ($$char === "(" && !in_str.contents) {
          stack.push({
                contents: /* L */Caml_chrome_debugger.variant("L", 1, [[]])
              });
        } else if ($$char === ")" && !in_str.contents) {
          if (word.contents !== "") {
            pushToTheTop(/* A */Caml_chrome_debugger.variant("A", 0, [word.contents]));
            word.contents = "";
          }
          var expr = stack.pop();
          if (expr !== undefined) {
            pushToTheTop(expr.contents);
          }
          
        } else if ($$char === " " && !in_str.contents) {
          if (word.contents !== "") {
            pushToTheTop(/* A */Caml_chrome_debugger.variant("A", 0, [word.contents]));
            word.contents = "";
          }
          
        } else if ($$char === "\"") {
          in_str.contents = !in_str.contents;
        } else if ($$char === "\\" && in_str.contents) {
          escaped.contents = true;
        } else {
          word.contents = word.contents + $$char;
        }
      }
      
    }
    var match = stack.length;
    if (match === 0) {
      return /* Error */Caml_chrome_debugger.variant("Error", 0, [/* tuple */[
                  0,
                  string
                ]]);
    }
    if (match !== 1) {
      return /* Continue */Caml_chrome_debugger.variant("Continue", 1, [(function (param) {
                    return parseSExpression(state, param);
                  })]);
    }
    var v = Belt_Array.get(stack, 0);
    if (v === undefined) {
      return /* Error */Caml_chrome_debugger.variant("Error", 0, [/* tuple */[
                  1,
                  string
                ]]);
    }
    var xs = v.contents;
    if (!xs.tag) {
      return /* Error */Caml_chrome_debugger.variant("Error", 0, [/* tuple */[
                  3,
                  string
                ]]);
    }
    var w = Belt_Array.get(xs[0], 0);
    if (w !== undefined) {
      return /* Done */Caml_chrome_debugger.variant("Done", 2, [w]);
    } else {
      return /* Continue */Caml_chrome_debugger.variant("Continue", 1, [(function (param) {
                    return parseSExpression(state, param);
                  })]);
    }
  };
  var initialState = function (param) {
    return {
            stack: [{
                contents: /* L */Caml_chrome_debugger.variant("L", 1, [[]])
              }],
            word: {
              contents: ""
            },
            escaped: {
              contents: false
            },
            in_str: {
              contents: false
            }
          };
  };
  var processed = preprocess(string);
  if (processed.tag) {
    return /* Error */Caml_chrome_debugger.variant("Error", 0, [/* tuple */[
                4,
                string
              ]]);
  } else {
    return parseSExpression(initialState(undefined), processed[0]);
  }
}

function parse(input) {
  var resultAccum = {
    contents: []
  };
  var continuation = {
    contents: undefined
  };
  Belt_Array.forEach(split(input), (function (line) {
          var $$continue = Belt_Option.getWithDefault(continuation.contents, parseWithContinuation);
          var err = Curry._1($$continue, line);
          switch (err.tag | 0) {
            case /* Error */0 :
                resultAccum.contents.push(/* Error */Caml_chrome_debugger.variant("Error", 1, [err[0]]));
                return ;
            case /* Continue */1 :
                continuation.contents = err[0];
                return ;
            case /* Done */2 :
                resultAccum.contents.push(/* Ok */Caml_chrome_debugger.variant("Ok", 0, [err[0]]));
                continuation.contents = undefined;
                return ;
            
          }
        }));
  return resultAccum.contents;
}

function makeIncr(callback) {
  return make(parseWithContinuation, callback);
}

var SExpression = {
  toString: toString,
  preprocess: preprocess,
  flatten: flatten,
  parseWithContinuation: parseWithContinuation,
  parse: parse,
  makeIncr: makeIncr
};

function toString$1(param) {
  if (param.tag) {
    return "Parse error code: R" + (String(param[0]) + (" \"" + (toString(param[1]) + "\"")));
  } else {
    return "Parse error code: S" + (String(param[0]) + (" \"" + (param[1] + "\"")));
  }
}

var $$Error = {
  toString: toString$1
};

function captures(handler, regex, raw) {
  return Belt_Option.flatMap(Belt_Option.map(Caml_option.null_to_opt(regex.exec(raw)), (function (result) {
                    return Belt_Array.map(result, (function (prim) {
                                  if (prim == null) {
                                    return ;
                                  } else {
                                    return Caml_option.some(prim);
                                  }
                                }));
                  })), handler);
}

function at(captured, i, parser) {
  if (i >= captured.length) {
    return ;
  } else {
    return Belt_Option.flatMap(Belt_Option.flatMap(Belt_Array.get(captured, i), (function (x) {
                      return x;
                    })), parser);
  }
}

function choice(res, raw) {
  return res.reduce((function (result, parse) {
                if (result !== undefined) {
                  return Caml_option.some(Caml_option.valFromOption(result));
                } else {
                  return Curry._1(parse, raw);
                }
              }), undefined);
}

function $$int(s) {
  var i;
  try {
    i = Caml_format.caml_int_of_string(s);
  }
  catch (exn){
    return ;
  }
  return i;
}

function userInput(s) {
  return s.replace(/\\/g, "\\\\").replace(/\"/g, "\\\"").replace(/\n/g, "\\n").trim();
}

function filepath(s) {
  var removedBidi = s.charCodeAt(0) === 8234.0 ? s.slice(1) : s;
  var normalized = Path.normalize(removedBidi);
  return normalized.replace(/\\/g, "/");
}

var partial_arg = /\\n/g;

function agdaOutput(param) {
  return param.replace(partial_arg, "\n");
}

function commandLineArgs(s) {
  return s.replace(/\s+/g, " ").split(" ");
}

exports.split = split;
exports.Incr = Incr;
exports.SExpression = SExpression;
exports.$$Error = $$Error;
exports.captures = captures;
exports.at = at;
exports.choice = choice;
exports.$$int = $$int;
exports.userInput = userInput;
exports.filepath = filepath;
exports.agdaOutput = agdaOutput;
exports.commandLineArgs = commandLineArgs;
/* path Not a pure module */

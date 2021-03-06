// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Curry = require("bs-platform/lib/js/curry.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Task$AgdaModeVscode = require("./Task.bs.js");
var Caml_chrome_debugger = require("bs-platform/lib/js/caml_chrome_debugger.js");
var Decoration$AgdaModeVscode = require("../Decoration.bs.js");

function Impl(Editor) {
  var Task = Task$AgdaModeVscode.Impl(Editor);
  var Decoration = Decoration$AgdaModeVscode.Impl(Editor);
  var handle = function (highlightings) {
    if (typeof highlightings === "number") {
      if (highlightings !== 0) {
        return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                  /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                          Belt_Array.forEach(state.decorations, (function (param) {
                                  return Curry._3(Editor.Decoration.decorate, state.editor, param[0], [param[1]]);
                                }));
                          return Belt_Array.forEach(state.goals, (function (goal) {
                                        return Curry._2(Task.Goal.refreshDecoration, goal, state.editor);
                                      }));
                        })]),
                  /* [] */0
                ]);
      } else {
        return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                  /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                          Belt_Array.forEach(Belt_Array.map(state.decorations, (function (prim) {
                                      return prim[0];
                                    })), Editor.Decoration.destroy);
                          state.decorations = [];
                          
                        })]),
                  /* [] */0
                ]);
      }
    }
    var highlightings$1 = highlightings[0];
    return /* :: */Caml_chrome_debugger.simpleVariant("::", [
              /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                      var decorations = Belt_Array.concatMany(Belt_Array.map(highlightings$1, (function (highlighting) {
                                  return Curry._2(Task.Decoration.decorateHighlighting, state.editor, highlighting);
                                })));
                      state.decorations = Belt_Array.concat(state.decorations, decorations);
                      
                    })]),
              /* [] */0
            ]);
  };
  return {
          Task: Task,
          Decoration: Decoration,
          handle: handle
        };
}

exports.Impl = Impl;
/* Task-AgdaModeVscode Not a pure module */

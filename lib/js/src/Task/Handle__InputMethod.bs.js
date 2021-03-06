// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Curry = require("bs-platform/lib/js/curry.js");
var $$Promise = require("reason-promise/lib/js/src/js/promise.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Task$AgdaModeVscode = require("./Task.bs.js");
var Caml_chrome_debugger = require("bs-platform/lib/js/caml_chrome_debugger.js");
var InputMethod$AgdaModeVscode = require("../InputMethod/InputMethod.bs.js");

function Impl(Editor) {
  var Task = Task$AgdaModeVscode.Impl(Editor);
  var InputMethod = InputMethod$AgdaModeVscode.Impl(Editor);
  var handle = function ($$char) {
    if (typeof $$char === "number") {
      switch ($$char) {
        case /* Activate */0 :
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* WithStateP */Caml_chrome_debugger.variant("WithStateP", 8, [(function (state) {
                              if (state.inputMethod.activated) {
                                Curry._1(InputMethod.insertBackslash, state.editor);
                                Curry._1(InputMethod.deactivate, state.inputMethod);
                                return $$Promise.resolved(/* :: */Caml_chrome_debugger.simpleVariant("::", [
                                              /* ViewEvent */Caml_chrome_debugger.variant("ViewEvent", 2, [/* InputMethod */Caml_chrome_debugger.variant("InputMethod", 1, [/* Deactivate */1])]),
                                              /* [] */0
                                            ]));
                              }
                              state.inputMethod.activated = true;
                              var startingRanges = Belt_Array.map(Curry._1(Editor.getSelectionRanges, state.editor), (function (range) {
                                      return /* tuple */[
                                              Curry._2(Editor.offsetAtPoint, state.editor, Curry._1(Editor.$$Range.start, range)),
                                              Curry._2(Editor.offsetAtPoint, state.editor, Curry._1(Editor.$$Range.end_, range))
                                            ];
                                    }));
                              Curry._3(InputMethod.activate, state.inputMethod, state.editor, startingRanges);
                              return $$Promise.resolved(/* :: */Caml_chrome_debugger.simpleVariant("::", [
                                            /* ViewEvent */Caml_chrome_debugger.variant("ViewEvent", 2, [/* InputMethod */Caml_chrome_debugger.variant("InputMethod", 1, [/* Activate */0])]),
                                            /* [] */0
                                          ]));
                            })]),
                      /* [] */0
                    ]);
        case /* Deactivate */1 :
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                              state.inputMethod.activated = false;
                              return Curry._1(InputMethod.deactivate, state.inputMethod);
                            })]),
                      /* :: */Caml_chrome_debugger.simpleVariant("::", [
                          /* ViewEvent */Caml_chrome_debugger.variant("ViewEvent", 2, [/* InputMethod */Caml_chrome_debugger.variant("InputMethod", 1, [/* Deactivate */1])]),
                          /* [] */0
                        ])
                    ]);
        case /* MoveUp */2 :
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                              return Curry._2(InputMethod.moveUp, state.inputMethod, state.editor);
                            })]),
                      /* [] */0
                    ]);
        case /* MoveRight */3 :
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                              return Curry._2(InputMethod.moveRight, state.inputMethod, state.editor);
                            })]),
                      /* [] */0
                    ]);
        case /* MoveDown */4 :
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                              return Curry._2(InputMethod.moveDown, state.inputMethod, state.editor);
                            })]),
                      /* [] */0
                    ]);
        case /* MoveLeft */5 :
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                              return Curry._2(InputMethod.moveLeft, state.inputMethod, state.editor);
                            })]),
                      /* [] */0
                    ]);
        
      }
    } else {
      switch ($$char.tag | 0) {
        case /* Update */0 :
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* ViewEvent */Caml_chrome_debugger.variant("ViewEvent", 2, [/* InputMethod */Caml_chrome_debugger.variant("InputMethod", 1, [/* Update */Caml_chrome_debugger.simpleVariant("Update", [
                                  $$char[0],
                                  $$char[1],
                                  $$char[2]
                                ])])]),
                      /* [] */0
                    ]);
        case /* InsertChar */1 :
            var $$char$1 = $$char[0];
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                              return Curry._2(InputMethod.insertChar, state.editor, $$char$1);
                            })]),
                      /* [] */0
                    ]);
        case /* ChooseSymbol */2 :
            var symbol = $$char[0];
            return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                      /* WithState */Caml_chrome_debugger.variant("WithState", 7, [(function (state) {
                              return Curry._3(InputMethod.chooseSymbol, state.inputMethod, state.editor, symbol);
                            })]),
                      /* [] */0
                    ]);
        
      }
    }
  };
  return {
          Task: Task,
          InputMethod: InputMethod,
          handle: handle
        };
}

exports.Impl = Impl;
/* Promise Not a pure module */

open Command;

module Impl = (Editor: Sig.Editor) => {
  module Task = Task.Impl(Editor);
  module InputMethodHandler = Handle__InputMethod.Impl(Editor);

  open! Task;
  // from Editor Command to Tasks
  let handle = command => {
    let header = Command.toString(command);
    switch (command) {
    | Load => [
        Task.WithStateP(
          state => Editor.save(state.editor)->Promise.map(_ => []),
        ),
        Goal(SaveCursor),
        Decoration(RemoveAll),
        AgdaRequest(Load),
      ]
    | Quit => []
    | Restart => [DispatchCommand(Load)]
    | Refresh => [Goal(UpdateRange), Decoration(Refresh)]
    | Compile => [AgdaRequest(Compile)]
    | ToggleDisplayOfImplicitArguments => [
        AgdaRequest(ToggleDisplayOfImplicitArguments),
      ]
    | ShowConstraints => [AgdaRequest(ShowConstraints)]
    | SolveConstraints(normalization) => [
        Goal(
          LocalOrGlobal(
            goal => [AgdaRequest(SolveConstraints(normalization, goal))],
            [AgdaRequest(SolveConstraintsGlobal(normalization))],
          ),
        ),
      ]
    | ShowGoals => [AgdaRequest(ShowGoals)]
    | NextGoal => [Goal(Next)]
    | PreviousGoal => [Goal(Previous)]
    | SearchAbout(normalization) =>
      query(header, Some("name:"), None, expr =>
        [AgdaRequest(SearchAbout(normalization, expr))]
      )
    | Give => [
        Goal(
          LocalOrGlobal2(
            (goal, _) => [AgdaRequest(Give(goal))],
            goal =>
              query(header, Some("expression to give:"), None, expr =>
                [Goal(Modify(goal, _ => expr)), AgdaRequest(Give(goal))]
              ),
            [Error(OutOfGoal)],
          ),
        ),
      ]
    | Refine => [
        Goal(
          LocalOrGlobal(
            goal => [Goal(SaveCursor), AgdaRequest(Refine(goal))],
            [Error(OutOfGoal)],
          ),
        ),
      ]
    | ElaborateAndGive(normalization) =>
      let placeholder = Some("expression to elaborate and give:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, expr) =>
              [AgdaRequest(ElaborateAndGive(normalization, expr, goal))],
            goal =>
              query(header, placeholder, None, expr =>
                [AgdaRequest(ElaborateAndGive(normalization, expr, goal))]
              ),
            [Error(OutOfGoal)],
          ),
        ),
      ];
    | Auto => [
        Goal(
          LocalOrGlobal(
            goal => {[AgdaRequest(Auto(goal))]},
            [Error(OutOfGoal)],
          ),
        ),
      ]
    | Case =>
      let placeholder = Some("expression to case:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, _) => [Goal(SaveCursor), AgdaRequest(Case(goal))],
            goal =>
              query(header, placeholder, None, expr =>
                [
                  Goal(Modify(goal, _ => expr)), // place the queried expression in the goal
                  Goal(SaveCursor),
                  AgdaRequest(Case(goal)),
                ]
              ),
            [Error(OutOfGoal)],
          ),
        ),
      ];
    | HelperFunctionType(normalization) =>
      let placeholder = Some("expression:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, expr) =>
              [AgdaRequest(HelperFunctionType(normalization, expr, goal))],
            goal =>
              query(header, placeholder, None, expr =>
                [AgdaRequest(HelperFunctionType(normalization, expr, goal))]
              ),
            [Error(OutOfGoal)],
          ),
        ),
      ];
    | InferType(normalization) =>
      let placeholder = Some("expression to infer:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, expr) =>
              [AgdaRequest(InferType(normalization, expr, goal))],
            goal =>
              query(header, placeholder, None, expr =>
                [AgdaRequest(InferType(normalization, expr, goal))]
              ),
            query(header, placeholder, None, expr =>
              [AgdaRequest(InferTypeGlobal(normalization, expr))]
            ),
          ),
        ),
      ];
    | Context(normalization) => [
        Goal(
          LocalOrGlobal(
            goal => [AgdaRequest(Context(normalization, goal))],
            [Error(OutOfGoal)],
          ),
        ),
      ]
    | GoalType(normalization) => [
        Goal(
          LocalOrGlobal(
            goal => [AgdaRequest(GoalType(normalization, goal))],
            [Error(OutOfGoal)],
          ),
        ),
      ]
    | GoalTypeAndContext(normalization) => [
        Goal(
          LocalOrGlobal(
            goal => [AgdaRequest(GoalTypeAndContext(normalization, goal))],
            [Error(OutOfGoal)],
          ),
        ),
      ]
    | GoalTypeContextAndInferredType(normalization) =>
      let placeholder = Some("expression to type:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, expr) =>
              [
                AgdaRequest(
                  GoalTypeContextAndInferredType(normalization, expr, goal),
                ),
              ],
            goal =>
              query(header, placeholder, None, expr =>
                [
                  AgdaRequest(
                    GoalTypeContextAndInferredType(normalization, expr, goal),
                  ),
                ]
              ),
            [Error(OutOfGoal)],
          ),
        ),
      ];
    | GoalTypeContextAndCheckedType(normalization) =>
      let placeholder = Some("expression to type:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, expr) =>
              [
                AgdaRequest(
                  GoalTypeContextAndCheckedType(normalization, expr, goal),
                ),
              ],
            goal =>
              query(header, placeholder, None, expr =>
                [
                  AgdaRequest(
                    GoalTypeContextAndCheckedType(normalization, expr, goal),
                  ),
                ]
              ),
            [Error(OutOfGoal)],
          ),
        ),
      ];
    | ModuleContents(normalization) =>
      let placeholder = Some("module name:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, expr) =>
              [AgdaRequest(ModuleContents(normalization, expr, goal))],
            goal =>
              query(header, placeholder, None, expr =>
                [AgdaRequest(ModuleContents(normalization, expr, goal))]
              ),
            query(header, placeholder, None, expr =>
              [AgdaRequest(ModuleContentsGlobal(normalization, expr))]
            ),
          ),
        ),
      ];
    | ComputeNormalForm(computeMode) =>
      let placeholder = Some("expression to normalize:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, expr) =>
              [AgdaRequest(ComputeNormalForm(computeMode, expr, goal))],
            goal =>
              query(header, placeholder, None, expr =>
                [AgdaRequest(ComputeNormalForm(computeMode, expr, goal))]
              ),
            query(header, placeholder, None, expr =>
              [AgdaRequest(ComputeNormalFormGlobal(computeMode, expr))]
            ),
          ),
        ),
      ];
    | WhyInScope =>
      let placeholder = Some("name:");
      [
        Goal(
          LocalOrGlobal2(
            (goal, expr) => [AgdaRequest(WhyInScope(expr, goal))],
            goal =>
              query(header, placeholder, None, expr =>
                [AgdaRequest(WhyInScope(expr, goal))]
              ),
            query(header, placeholder, None, expr =>
              [AgdaRequest(WhyInScopeGlobal(expr))]
            ),
          ),
        ),
      ];
    | EventFromView(event) =>
      switch (event) {
      | Initialized => []
      | Destroyed => [Destroy]
      | InputMethod(InsertChar(char)) => [
          Goal(SaveCursor),
          DispatchCommand(InputMethod(InsertChar(char))),
          Goal(RestoreCursor),
        ]
      | InputMethod(ChooseSymbol(symbol)) => [
          Goal(SaveCursor),
          DispatchCommand(InputMethod(ChooseSymbol(symbol))),
          Goal(RestoreCursor),
        ]
      }
    | Escape => [ViewEvent(InterruptQuery)]
    | InputMethod(action) => InputMethodHandler.handle(action)
    };
  };
};

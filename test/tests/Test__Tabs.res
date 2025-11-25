open Mocha

describe("Common.Tab", () => {
  describe("toString", () => {
    it("should convert Goals to string", () => {
      Assert.strictEqual(Common.Tab.toString(Goals), "Goals")
    })

    it("should convert Compile to string", () => {
      Assert.strictEqual(Common.Tab.toString(Compile), "Compile")
    })

    it("should convert AgdaFlags to string", () => {
      Assert.strictEqual(Common.Tab.toString(AgdaFlags), "Agda Flags")
    })
  })

  describe("all", () => {
    it("should contain Goals, Compile, and AgdaFlags", () => {
      Assert.deepStrictEqual(Common.Tab.all, [Common.Tab.Goals, Common.Tab.Compile, Common.Tab.AgdaFlags])
    })

    it("should have 3 tabs", () => {
      Assert.strictEqual(Array.length(Common.Tab.all), 3)
    })
  })

  describe("fromString", () => {
    it("should convert 'Goals' to Goals", () => {
      Assert.deepStrictEqual(Common.Tab.fromString("Goals"), Common.Tab.Goals)
    })

    it("should convert 'Compile' to Compile", () => {
      Assert.deepStrictEqual(Common.Tab.fromString("Compile"), Common.Tab.Compile)
    })

    it("should convert 'AgdaFlags' to AgdaFlags", () => {
      Assert.deepStrictEqual(Common.Tab.fromString("AgdaFlags"), Common.Tab.AgdaFlags)
    })

    it("should default to Goals for unknown strings", () => {
      Assert.deepStrictEqual(Common.Tab.fromString("Unknown"), Common.Tab.Goals)
    })
  })
})

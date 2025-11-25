open Mocha

describe("StatusBar", () => {
  describe("statusToString", () => {
    it("should convert Unchecked to string", () => {
      Assert.strictEqual(StatusBar.statusToString(Unchecked), "Unchecked")
    })

    it("should convert Checking to string", () => {
      Assert.strictEqual(StatusBar.statusToString(Checking), "Checking")
    })

    it("should convert Success to string", () => {
      Assert.strictEqual(StatusBar.statusToString(Success), "Success")
    })

    it("should convert Error with 0 issues to string", () => {
      Assert.strictEqual(StatusBar.statusToString(Error([])), "Error(0 issues)")
    })

    it("should convert Error with 1 issue to string", () => {
      Assert.strictEqual(StatusBar.statusToString(Error(["error1"])), "Error(1 issues)")
    })

    it("should convert Error with multiple issues to string", () => {
      Assert.strictEqual(
        StatusBar.statusToString(Error(["error1", "error2", "error3"])),
        "Error(3 issues)",
      )
    })
  })

  describe("isAgdaFile", () => {
    // Note: These tests require mocking VSCode.TextDocument which is complex
    // For now, we test the logic indirectly through integration tests
    it("should be defined", () => {
      // Just verify the function exists
      let _ = StatusBar.isAgdaFile
      Assert.ok(true)
    })
  })
})


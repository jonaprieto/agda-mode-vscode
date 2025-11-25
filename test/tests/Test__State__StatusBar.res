open Mocha

describe("State__StatusBar", () => {
  describe("extractErrorMessages", () => {
    it("should extract error from Error response", () => {
      let result = State__StatusBar.extractErrorMessages(Response.DisplayInfo.Error("Test error"))
      Assert.deepStrictEqual(result, Some(["Test error"]))
    })

    it("should return None for non-error responses", () => {
      let result = State__StatusBar.extractErrorMessages(
        Response.DisplayInfo.CompilationOk("Success"),
      )
      Assert.deepStrictEqual(result, None)
    })
  })

  describe("status updates", () => {
    it("get should return None initially", () => {
      // Reset for clean state
      State__StatusBar.destroy()
      let result = State__StatusBar.get()
      Assert.deepStrictEqual(result, None)
    })
  })

  describe("handleResponse", () => {
    // Note: These tests verify the function exists and doesn't crash
    // Full integration testing requires VSCode context
    it("should handle DisplayInfo Error without crashing", () => {
      State__StatusBar.destroy()
      State__StatusBar.handleResponse(Response.DisplayInfo(Error("test error")))
      Assert.ok(true)
    })

    it("should handle InteractionPoints without crashing", () => {
      State__StatusBar.destroy()
      State__StatusBar.handleResponse(Response.InteractionPoints([1, 2, 3]))
      Assert.ok(true)
    })

    it("should handle DisplayInfo CompilationOk without crashing", () => {
      State__StatusBar.destroy()
      State__StatusBar.handleResponse(Response.DisplayInfo(CompilationOk("success")))
      Assert.ok(true)
    })
  })
})


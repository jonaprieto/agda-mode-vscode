open Mocha

describe("Common.Backend", () => {
  describe("toString", () => {
    it("should convert GHC to string", () => {
      Assert.strictEqual(Common.Backend.toString(GHC), "GHC")
    })

    it("should convert GHCNoMain to string", () => {
      Assert.strictEqual(Common.Backend.toString(GHCNoMain), "GHCNoMain")
    })

    it("should convert LaTeX to string", () => {
      Assert.strictEqual(Common.Backend.toString(LaTeX), "LaTeX")
    })

    it("should convert QuickLaTeX to string", () => {
      Assert.strictEqual(Common.Backend.toString(QuickLaTeX), "QuickLaTeX")
    })

    it("should convert HTML to string", () => {
      Assert.strictEqual(Common.Backend.toString(HTML), "HTML")
    })

    it("should convert JS to string", () => {
      Assert.strictEqual(Common.Backend.toString(JS), "JS")
    })
  })

  describe("description", () => {
    it("should return user-friendly description for GHC", () => {
      Assert.strictEqual(Common.Backend.description(GHC), "GHC (with main)")
    })

    it("should return user-friendly description for GHCNoMain", () => {
      Assert.strictEqual(Common.Backend.description(GHCNoMain), "GHC (library)")
    })

    it("should return user-friendly description for JS", () => {
      Assert.strictEqual(Common.Backend.description(JS), "JavaScript")
    })
  })

  describe("fromString", () => {
    it("should convert GHC string to backend", () => {
      Assert.deepStrictEqual(Common.Backend.fromString("GHC"), Common.Backend.GHC)
    })

    it("should convert GHCNoMain string to backend", () => {
      Assert.deepStrictEqual(Common.Backend.fromString("GHCNoMain"), Common.Backend.GHCNoMain)
    })

    it("should convert LaTeX string to backend", () => {
      Assert.deepStrictEqual(Common.Backend.fromString("LaTeX"), Common.Backend.LaTeX)
    })

    it("should convert QuickLaTeX string to backend", () => {
      Assert.deepStrictEqual(Common.Backend.fromString("QuickLaTeX"), Common.Backend.QuickLaTeX)
    })

    it("should convert HTML string to backend", () => {
      Assert.deepStrictEqual(Common.Backend.fromString("HTML"), Common.Backend.HTML)
    })

    it("should convert JS string to backend", () => {
      Assert.deepStrictEqual(Common.Backend.fromString("JS"), Common.Backend.JS)
    })

    it("should default to GHC for unknown strings", () => {
      Assert.deepStrictEqual(Common.Backend.fromString("Unknown"), Common.Backend.GHC)
    })
  })

  describe("all", () => {
    it("should contain all 6 backends", () => {
      Assert.strictEqual(Array.length(Common.Backend.all), 6)
    })

    it("should include all backends in order", () => {
      Assert.deepStrictEqual(
        Common.Backend.all,
        [
          Common.Backend.GHC,
          Common.Backend.GHCNoMain,
          Common.Backend.LaTeX,
          Common.Backend.QuickLaTeX,
          Common.Backend.HTML,
          Common.Backend.JS,
        ],
      )
    })
  })
})

describe("Common.CompileOptions", () => {
  describe("default", () => {
    it("should have GHC as default backend", () => {
      Assert.deepStrictEqual(Common.CompileOptions.default.backend, Common.Backend.GHC)
    })

    it("should have empty ghcOptions", () => {
      Assert.strictEqual(Common.CompileOptions.default.ghcOptions, "")
    })

    it("should have default outputPath", () => {
      Assert.strictEqual(Common.CompileOptions.default.outputPath, "./build")
    })
  })
})

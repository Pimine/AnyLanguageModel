import AnyLanguageModel

// Kept apart from the conversion tests: a file importing FoundationModels too
// cannot expand the AnyLanguageModel macros unambiguously.

@Generable
struct ConversionAddress {
    let city: String
}

@Generable
enum ConversionUnit: String {
    case g
    case ml
}

@Generable
struct ConversionPerson {
    let name: String
    @Guide(description: "Age in years", .minimum(0), .maximum(150))
    let age: Int
    let nickname: String?
    let unit: ConversionUnit
    let address: ConversionAddress
    let tags: [String]
}

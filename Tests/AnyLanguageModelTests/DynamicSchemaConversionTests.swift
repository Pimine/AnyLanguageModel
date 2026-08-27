import Foundation
import Testing

@testable import AnyLanguageModel

#if canImport(FoundationModels)
    import FoundationModels

    private let isFoundationModelsAvailable: Bool = {
        if #available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            return true
        }
        return false
    }()

    @Suite("Dynamic Schema Conversion", .enabled(if: isFoundationModelsAvailable))
    struct DynamicSchemaConversionTests {

        @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
        private func convertedPerson() throws -> [String: Any] {
            let schema = FoundationModels.GenerationSchema(ConversionPerson.generationSchema)
            let data = Data(String(describing: schema).utf8)
            return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        }

        private func properties(of json: [String: Any]) throws -> [String: [String: Any]] {
            try #require(json["properties"] as? [String: [String: Any]])
        }

        @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
        @Test func propertiesKeepDeclarationOrder() throws {
            let json = try convertedPerson()
            #expect(json["x-order"] as? [String] == ["name", "age", "nickname", "unit", "address", "tags"])
        }

        @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
        @Test func rootIsNamedWithoutModulePrefixAndNotDuplicated() throws {
            let json = try convertedPerson()
            let defs = try #require(json["$defs"] as? [String: Any])
            #expect(json["title"] as? String == "ConversionPerson")
            #expect(Set(defs.keys) == ["ConversionAddress", "ConversionUnit"])
        }

        @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
        @Test func optionalPropertiesAreNotRequired() throws {
            let json = try convertedPerson()
            let required = try #require(json["required"] as? [String])
            #expect(Set(required) == ["name", "age", "unit", "address", "tags"])
        }

        @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
        @Test func guidesAndDescriptionsSurvive() throws {
            let age = try #require(properties(of: convertedPerson())["age"])
            #expect(age["description"] as? String == "Age in years")
            #expect(age["minimum"] as? Int == 0)
            #expect(age["maximum"] as? Int == 150)
        }

        @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
        @Test func nestedTypesAreReferencedAndArraysInlined() throws {
            let json = try convertedPerson()
            let properties = try properties(of: json)
            #expect(properties["unit"]?["$ref"] as? String == "#/$defs/ConversionUnit")
            #expect(properties["address"]?["$ref"] as? String == "#/$defs/ConversionAddress")
            #expect(properties["tags"]?["type"] as? String == "array")
            #expect((properties["tags"]?["items"] as? [String: Any])?["type"] as? String == "string")
        }

        @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *)
        @Test func enumDefinitionListsItsCases() throws {
            let json = try convertedPerson()
            let defs = try #require(json["$defs"] as? [String: Any])
            let unit = try #require(defs["ConversionUnit"] as? [String: Any])
            let choices = try #require(unit["anyOf"] as? [[String: Any]])
            #expect(choices.compactMap { ($0["enum"] as? [String])?.first } == ["g", "ml"])
        }
    }
#endif

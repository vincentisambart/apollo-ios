// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MySwiftPackage

public class Cat: MockObject {
  public static let objectType: Object = MyGraphQLSchema.Objects.Cat
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Cat>>

  public struct MockFields {
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<Height>("height") public var height
    @Field<String>("humanName") public var humanName
    @Field<MyGraphQLSchema.ID>("id") public var id
    @Field<Bool>("isJellicle") public var isJellicle
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<Human>("owner") public var owner
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<MyGraphQLSchema.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Cat {
  convenience init(
    bodyTemperature: Int? = nil,
    favoriteToy: String? = nil,
    height: Mock<Height>? = nil,
    humanName: String? = nil,
    id: MyGraphQLSchema.ID? = nil,
    isJellicle: Bool? = nil,
    laysEggs: Bool? = nil,
    owner: Mock<Human>? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<MyGraphQLSchema.SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    _set(bodyTemperature, for: \.bodyTemperature)
    _set(favoriteToy, for: \.favoriteToy)
    _set(height, for: \.height)
    _set(humanName, for: \.humanName)
    _set(id, for: \.id)
    _set(isJellicle, for: \.isJellicle)
    _set(laysEggs, for: \.laysEggs)
    _set(owner, for: \.owner)
    _set(predators, for: \.predators)
    _set(skinCovering, for: \.skinCovering)
    _set(species, for: \.species)
  }
}

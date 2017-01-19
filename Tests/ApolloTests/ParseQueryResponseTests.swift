import XCTest
@testable import Apollo

class ParseQueryResponseTests: XCTestCase {
  static var allTests : [(String, (ParseQueryResponseTests) -> () throws -> Void)] {
    return [
      ("testHeroNameQuery", testHeroNameQuery),
      ("testHeroNameQueryWithMissingValue", testHeroNameQueryWithMissingValue),
      ("testHeroNameQueryWithWrongType", testHeroNameQueryWithWrongType),
      ("testHeroAppearsInQuery", testHeroAppearsInQuery),
      ("testHeroAndFriendsNamesQuery", testHeroAndFriendsNamesQuery),
      ("testTwoHeroesQuery", testTwoHeroesQuery),
      ("testHeroDetailsQueryDroid", testHeroDetailsQueryDroid),
      ("testHeroDetailsQueryHuman", testHeroDetailsQueryHuman),
      ("testHeroDetailsQueryUnknownTypename", testHeroDetailsQueryUnknownTypename),
      ("testHeroDetailsQueryMissingTypename", testHeroDetailsQueryMissingTypename),
      ("testHeroDetailsWithFragmentQueryDroid", testHeroDetailsWithFragmentQueryDroid),
      ("testHeroDetailsWithFragmentQueryHuman", testHeroDetailsWithFragmentQueryHuman),
      ("testErrorResponseWithoutLocation", testErrorResponseWithoutLocation),
      ("testErrorResponseWithLocation", testErrorResponseWithLocation),
    ]
  }
  
  func testHeroNameQuery() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2"]
      ]
    ])
    
    let result = try response.parseResult()

    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
  }

  func testHeroNameQueryWithMissingValue() {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid"]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult()) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func testHeroNameQueryWithWrongType() {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": 10]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult()) { error in
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["hero", "name"])
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testHeroAppearsInQuery() throws {
    let query = HeroAppearsInQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]]
      ]
      ])
    
    let result = try response.parseResult()
    
    XCTAssertEqual(result.data?.hero?.appearsIn, [.newhope, .empire, .jedi])
  }

  func testHeroAndFriendsNamesQuery() throws {
    let query = HeroAndFriendsNamesQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": [
          "name": "R2-D2",
          "__typename": "Droid",
           "friends": [
            ["__typename": "Human", "name": "Luke Skywalker"],
            ["__typename": "Human", "name": "Han Solo"],
            ["__typename": "Human", "name": "Leia Organa"]
          ]
        ]
      ]
    ])
    
    let result = try response.parseResult()

    XCTAssertEqual(result.data?.hero?.name, "R2-D2")
    let friendsNames = result.data?.hero?.friends?.flatMap { $0?.name }
    XCTAssertEqual(friendsNames, ["Luke Skywalker", "Han Solo", "Leia Organa"])
  }

  func testTwoHeroesQuery() throws {
    let query = TwoHeroesQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "r2": ["__typename": "Droid", "name": "R2-D2"],
        "luke": ["__typename": "Human", "name": "Luke Skywalker"]
      ]
    ])

    let result = try response.parseResult()

    XCTAssertEqual(result.data?.r2?.name, "R2-D2")
    XCTAssertEqual(result.data?.luke?.name, "Luke Skywalker")
  }
  
  func testHeroDetailsQueryDroid() throws {
    let query = HeroDetailsQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Astromech"]
      ]
    ])
    
    let result = try response.parseResult()
    
    guard let droid = result.data?.hero?.asDroid else {
      XCTFail("Wrong type")
      return
    }
    
    XCTAssertEqual(droid.primaryFunction, "Astromech")
  }

  func testHeroDetailsQueryHuman() throws {
    let query = HeroDetailsQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    let result = try response.parseResult()

    guard let human = result.data?.hero?.asHuman else {
      XCTFail("Wrong type")
      return
    }
    
    XCTAssertEqual(human.height, 1.72)
  }

  func testHeroDetailsQueryUnknownTypename() throws {
    let query = HeroDetailsQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Pokemon", "name": "Charmander"]
      ]
    ])

    let result = try response.parseResult()

    XCTAssertEqual(result.data?.hero?.name, "Charmander")
  }

  func testHeroDetailsQueryMissingTypename() throws {
    let query = HeroDetailsQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    XCTAssertThrowsError(try response.parseResult()) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["hero", "__typename"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testHeroDetailsWithFragmentQueryDroid() throws {
    let query = HeroDetailsWithFragmentQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Astromech"]
      ]
    ])
    
    let result = try response.parseResult()
    
    guard let droid = result.data?.hero?.fragments.heroDetails.asDroid else {
      XCTFail("Wrong type")
      return
    }
    
    XCTAssertEqual(droid.primaryFunction, "Astromech")
  }

  func testHeroDetailsWithFragmentQueryHuman() throws {
    let query = HeroDetailsWithFragmentQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "data": [
        "hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]
      ]
    ])

    let result = try response.parseResult()

    guard let human = result.data?.hero?.fragments.heroDetails.asHuman else {
      XCTFail("Wrong type")
      return
    }
    
    XCTAssertEqual(human.height, 1.72)
  }
  
  // MARK: Mutations
  
  func testCreateReviewForEpisode() throws {
    let mutation = CreateReviewForEpisodeMutation(episode: .jedi, review: ReviewInput(stars: 5, commentary: "This is a great movie!"))
    
    let response = GraphQLResponse(operation: mutation, body: [
      "data": [
        "createReview": [
          "stars": 5,
          "commentary": "This is a great movie!"
        ]
      ]
    ])
    
    let result = try response.parseResult()
    
    XCTAssertEqual(result.data?.createReview?.stars, 5)
    XCTAssertEqual(result.data?.createReview?.commentary, "This is a great movie!")
  }
  
  // MARK: - Error responses
  
  func testErrorResponseWithoutLocation() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
        ]
      ]
      ])
    
    let result = try response.parseResult()
    
    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertNil(result.errors?.first?.locations)
  }
  
  func testErrorResponseWithLocation() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
          "locations": [
            ["line": 1, "column": 2]
          ]
        ]
      ]
    ])
    
    let result = try response.parseResult()
    
    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertEqual(result.errors?.first?.locations?.first?.line, 1)
    XCTAssertEqual(result.errors?.first?.locations?.first?.column, 2)
  }
  
  func testErrorResponseWithCustomError() throws {
    let query = HeroNameQuery()
    
    let response = GraphQLResponse(operation: query, body: [
      "errors": [
        [
          "message": "Some error",
          "userMessage": "Some message"
        ]
      ]
    ])
    
    let result = try response.parseResult()
    
    XCTAssertNil(result.data)
    XCTAssertEqual(result.errors?.first?.message, "Some error")
    XCTAssertEqual(result.errors?.first?["userMessage"] as? String, "Some message")
  }
}

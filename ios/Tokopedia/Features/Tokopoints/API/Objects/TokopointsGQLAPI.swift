//  This file was automatically generated and should not be edited.

import Apollo

public final class TokopointsTokenQuery: GraphQLQuery {
  public static let operationString =
    "query TokopointsToken {" +
    "  tokopointsToken {" +
    "    __typename" +
    "    resultStatus {" +
    "      __typename" +
    "      code" +
    "      message" +
    "      status" +
    "    }" +
    "    offFlag" +
    "    sumToken" +
    "    floating {" +
    "      __typename" +
    "      tokenId" +
    "    }" +
    "    home {" +
    "      __typename" +
    "      emptyState {" +
    "        __typename" +
    "        title" +
    "        buttonText" +
    "        buttonApplink" +
    "      }" +
    "      countingMessage" +
    "      tokensUser {" +
    "        __typename" +
    "        tokenUserID" +
    "        campaignID" +
    "        title" +
    "        unixTimestampFetch" +
    "        timeRemainingSeconds" +
    "        isShowTime" +
    "        backgroundAsset {" +
    "          __typename" +
    "          name" +
    "          version" +
    "          backgroundImgUrl" +
    "        }" +
    "        tokenAsset {" +
    "          __typename" +
    "          name" +
    "          version" +
    "          floatingImgUrl" +
    "          smallImgUrl" +
    "          imageUrls" +
    "        }" +
    "      }" +
    "    }" +
    "  }" +
    "}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("tokopointsToken", type: .object(TokopointsToken.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(tokopointsToken: TokopointsToken? = nil) {
      self.init(snapshot: ["__typename": "Query", "tokopointsToken": tokopointsToken])
    }

    public var tokopointsToken: TokopointsToken? {
      get {
        return (snapshot["tokopointsToken"]! as! Snapshot?).flatMap { TokopointsToken(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "tokopointsToken")
      }
    }

    public struct TokopointsToken: GraphQLSelectionSet {
      public static let possibleTypes = ["TokenData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("resultStatus", type: .object(ResultStatus.self)),
        GraphQLField("offFlag", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("sumToken", type: .scalar(Int.self)),
        GraphQLField("floating", type: .object(Floating.self)),
        GraphQLField("home", type: .object(Home.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(resultStatus: ResultStatus? = nil, offFlag: Bool, sumToken: Int? = nil, floating: Floating? = nil, home: Home? = nil) {
        self.init(snapshot: ["__typename": "TokenData", "resultStatus": resultStatus, "offFlag": offFlag, "sumToken": sumToken, "floating": floating, "home": home])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var resultStatus: ResultStatus? {
        get {
          return (snapshot["resultStatus"]! as! Snapshot?).flatMap { ResultStatus(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "resultStatus")
        }
      }

      public var offFlag: Bool {
        get {
          return snapshot["offFlag"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "offFlag")
        }
      }

      public var sumToken: Int? {
        get {
          return snapshot["sumToken"]! as! Int?
        }
        set {
          snapshot.updateValue(newValue, forKey: "sumToken")
        }
      }

      public var floating: Floating? {
        get {
          return (snapshot["floating"]! as! Snapshot?).flatMap { Floating(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "floating")
        }
      }

      public var home: Home? {
        get {
          return (snapshot["home"]! as! Snapshot?).flatMap { Home(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "home")
        }
      }

      public struct ResultStatus: GraphQLSelectionSet {
        public static let possibleTypes = ["ResultStatus"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("code", type: .scalar(String.self)),
          GraphQLField("message", type: .list(.scalar(String.self))),
          GraphQLField("status", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(code: String? = nil, message: [String?]? = nil, status: String? = nil) {
          self.init(snapshot: ["__typename": "ResultStatus", "code": code, "message": message, "status": status])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var code: String? {
          get {
            return snapshot["code"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "code")
          }
        }

        public var message: [String?]? {
          get {
            return snapshot["message"]! as! [String?]?
          }
          set {
            snapshot.updateValue(newValue, forKey: "message")
          }
        }

        public var status: String? {
          get {
            return snapshot["status"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "status")
          }
        }
      }

      public struct Floating: GraphQLSelectionSet {
        public static let possibleTypes = ["TokenFloating"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("tokenId", type: .scalar(Int.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(tokenId: Int? = nil) {
          self.init(snapshot: ["__typename": "TokenFloating", "tokenId": tokenId])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var tokenId: Int? {
          get {
            return snapshot["tokenId"]! as! Int?
          }
          set {
            snapshot.updateValue(newValue, forKey: "tokenId")
          }
        }
      }

      public struct Home: GraphQLSelectionSet {
        public static let possibleTypes = ["TokenHome"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("emptyState", type: .object(EmptyState.self)),
          GraphQLField("countingMessage", type: .list(.scalar(String.self))),
          GraphQLField("tokensUser", type: .object(TokensUser.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(emptyState: EmptyState? = nil, countingMessage: [String?]? = nil, tokensUser: TokensUser? = nil) {
          self.init(snapshot: ["__typename": "TokenHome", "emptyState": emptyState, "countingMessage": countingMessage, "tokensUser": tokensUser])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var emptyState: EmptyState? {
          get {
            return (snapshot["emptyState"]! as! Snapshot?).flatMap { EmptyState(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "emptyState")
          }
        }

        public var countingMessage: [String?]? {
          get {
            return snapshot["countingMessage"]! as! [String?]?
          }
          set {
            snapshot.updateValue(newValue, forKey: "countingMessage")
          }
        }

        public var tokensUser: TokensUser? {
          get {
            return (snapshot["tokensUser"]! as! Snapshot?).flatMap { TokensUser(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "tokensUser")
          }
        }

        public struct EmptyState: GraphQLSelectionSet {
          public static let possibleTypes = ["EmptyState"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("buttonText", type: .scalar(String.self)),
            GraphQLField("buttonApplink", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(title: String? = nil, buttonText: String? = nil, buttonApplink: String? = nil) {
            self.init(snapshot: ["__typename": "EmptyState", "title": title, "buttonText": buttonText, "buttonApplink": buttonApplink])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var title: String? {
            get {
              return snapshot["title"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "title")
            }
          }

          public var buttonText: String? {
            get {
              return snapshot["buttonText"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "buttonText")
            }
          }

          public var buttonApplink: String? {
            get {
              return snapshot["buttonApplink"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "buttonApplink")
            }
          }
        }

        public struct TokensUser: GraphQLSelectionSet {
          public static let possibleTypes = ["TokenUser"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("tokenUserID", type: .scalar(Int.self)),
            GraphQLField("campaignID", type: .scalar(Int.self)),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("unixTimestampFetch", type: .scalar(Int.self)),
            GraphQLField("timeRemainingSeconds", type: .scalar(Int.self)),
            GraphQLField("isShowTime", type: .scalar(Bool.self)),
            GraphQLField("backgroundAsset", type: .object(BackgroundAsset.self)),
            GraphQLField("tokenAsset", type: .object(TokenAsset.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(tokenUserId: Int? = nil, campaignId: Int? = nil, title: String? = nil, unixTimestampFetch: Int? = nil, timeRemainingSeconds: Int? = nil, isShowTime: Bool? = nil, backgroundAsset: BackgroundAsset? = nil, tokenAsset: TokenAsset? = nil) {
            self.init(snapshot: ["__typename": "TokenUser", "tokenUserID": tokenUserId, "campaignID": campaignId, "title": title, "unixTimestampFetch": unixTimestampFetch, "timeRemainingSeconds": timeRemainingSeconds, "isShowTime": isShowTime, "backgroundAsset": backgroundAsset, "tokenAsset": tokenAsset])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var tokenUserId: Int? {
            get {
              return snapshot["tokenUserID"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "tokenUserID")
            }
          }

          public var campaignId: Int? {
            get {
              return snapshot["campaignID"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "campaignID")
            }
          }

          public var title: String? {
            get {
              return snapshot["title"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "title")
            }
          }

          public var unixTimestampFetch: Int? {
            get {
              return snapshot["unixTimestampFetch"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "unixTimestampFetch")
            }
          }

          public var timeRemainingSeconds: Int? {
            get {
              return snapshot["timeRemainingSeconds"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "timeRemainingSeconds")
            }
          }

          public var isShowTime: Bool? {
            get {
              return snapshot["isShowTime"]! as! Bool?
            }
            set {
              snapshot.updateValue(newValue, forKey: "isShowTime")
            }
          }

          public var backgroundAsset: BackgroundAsset? {
            get {
              return (snapshot["backgroundAsset"]! as! Snapshot?).flatMap { BackgroundAsset(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "backgroundAsset")
            }
          }

          public var tokenAsset: TokenAsset? {
            get {
              return (snapshot["tokenAsset"]! as! Snapshot?).flatMap { TokenAsset(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "tokenAsset")
            }
          }

          public struct BackgroundAsset: GraphQLSelectionSet {
            public static let possibleTypes = ["BackgroundAsset"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("version", type: .scalar(Int.self)),
              GraphQLField("backgroundImgUrl", type: .scalar(String.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(name: String? = nil, version: Int? = nil, backgroundImgUrl: String? = nil) {
              self.init(snapshot: ["__typename": "BackgroundAsset", "name": name, "version": version, "backgroundImgUrl": backgroundImgUrl])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var name: String? {
              get {
                return snapshot["name"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "name")
              }
            }

            public var version: Int? {
              get {
                return snapshot["version"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "version")
              }
            }

            public var backgroundImgUrl: String? {
              get {
                return snapshot["backgroundImgUrl"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "backgroundImgUrl")
              }
            }
          }

          public struct TokenAsset: GraphQLSelectionSet {
            public static let possibleTypes = ["TokenAsset"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("version", type: .scalar(Int.self)),
              GraphQLField("floatingImgUrl", type: .scalar(String.self)),
              GraphQLField("smallImgUrl", type: .scalar(String.self)),
              GraphQLField("imageUrls", type: .list(.scalar(String.self))),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(name: String? = nil, version: Int? = nil, floatingImgUrl: String? = nil, smallImgUrl: String? = nil, imageUrls: [String?]? = nil) {
              self.init(snapshot: ["__typename": "TokenAsset", "name": name, "version": version, "floatingImgUrl": floatingImgUrl, "smallImgUrl": smallImgUrl, "imageUrls": imageUrls])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var name: String? {
              get {
                return snapshot["name"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "name")
              }
            }

            public var version: Int? {
              get {
                return snapshot["version"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "version")
              }
            }

            public var floatingImgUrl: String? {
              get {
                return snapshot["floatingImgUrl"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "floatingImgUrl")
              }
            }

            public var smallImgUrl: String? {
              get {
                return snapshot["smallImgUrl"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "smallImgUrl")
              }
            }

            public var imageUrls: [String?]? {
              get {
                return snapshot["imageUrls"]! as! [String?]?
              }
              set {
                snapshot.updateValue(newValue, forKey: "imageUrls")
              }
            }
          }
        }
      }
    }
  }
}

public final class CrackResultMutation: GraphQLMutation {
  public static let operationString =
    "mutation CrackResult($tokenUserID: Int!, $campaignID: Int!) {" +
    "  crackResult(tokenUserID: $tokenUserID, campaignID: $campaignID) {" +
    "    __typename" +
    "    resultStatus {" +
    "      __typename" +
    "      code" +
    "      message" +
    "      status" +
    "    }" +
    "    imageUrl" +
    "    benefitType" +
    "    benefits {" +
    "      __typename" +
    "      text" +
    "      color" +
    "      size" +
    "    }" +
    "    ctaButton {" +
    "      __typename" +
    "      title" +
    "      applink" +
    "      type" +
    "    }" +
    "    returnButton {" +
    "      __typename" +
    "      title" +
    "      applink" +
    "      type" +
    "    }" +
    "  }" +
    "}"

  public var tokenUserID: Int
  public var campaignID: Int

  public init(tokenUserID: Int, campaignID: Int) {
    self.tokenUserID = tokenUserID
    self.campaignID = campaignID
  }

  public var variables: GraphQLMap? {
    return ["tokenUserID": tokenUserID, "campaignID": campaignID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("crackResult", arguments: ["tokenUserID": Variable("tokenUserID"), "campaignID": Variable("campaignID")], type: .object(CrackResult.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(crackResult: CrackResult? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "crackResult": crackResult])
    }

    public var crackResult: CrackResult? {
      get {
        return (snapshot["crackResult"]! as! Snapshot?).flatMap { CrackResult(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "crackResult")
      }
    }

    public struct CrackResult: GraphQLSelectionSet {
      public static let possibleTypes = ["CrackResult"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("resultStatus", type: .object(ResultStatus.self)),
        GraphQLField("imageUrl", type: .scalar(String.self)),
        GraphQLField("benefitType", type: .scalar(String.self)),
        GraphQLField("benefits", type: .nonNull(.list(.object(Benefit.self)))),
        GraphQLField("ctaButton", type: .nonNull(.object(CtaButton.self))),
        GraphQLField("returnButton", type: .nonNull(.object(ReturnButton.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(resultStatus: ResultStatus? = nil, imageUrl: String? = nil, benefitType: String? = nil, benefits: [Benefit?], ctaButton: CtaButton, returnButton: ReturnButton) {
        self.init(snapshot: ["__typename": "CrackResult", "resultStatus": resultStatus, "imageUrl": imageUrl, "benefitType": benefitType, "benefits": benefits, "ctaButton": ctaButton, "returnButton": returnButton])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var resultStatus: ResultStatus? {
        get {
          return (snapshot["resultStatus"]! as! Snapshot?).flatMap { ResultStatus(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "resultStatus")
        }
      }

      public var imageUrl: String? {
        get {
          return snapshot["imageUrl"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "imageUrl")
        }
      }

      public var benefitType: String? {
        get {
          return snapshot["benefitType"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "benefitType")
        }
      }

      public var benefits: [Benefit?] {
        get {
          return (snapshot["benefits"]! as! [Snapshot?]).map { $0.flatMap { Benefit(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "benefits")
        }
      }

      public var ctaButton: CtaButton {
        get {
          return CtaButton(snapshot: snapshot["ctaButton"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "ctaButton")
        }
      }

      public var returnButton: ReturnButton {
        get {
          return ReturnButton(snapshot: snapshot["returnButton"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "returnButton")
        }
      }

      public struct ResultStatus: GraphQLSelectionSet {
        public static let possibleTypes = ["CrackResultStatus"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("code", type: .scalar(String.self)),
          GraphQLField("message", type: .list(.scalar(String.self))),
          GraphQLField("status", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(code: String? = nil, message: [String?]? = nil, status: String? = nil) {
          self.init(snapshot: ["__typename": "CrackResultStatus", "code": code, "message": message, "status": status])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var code: String? {
          get {
            return snapshot["code"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "code")
          }
        }

        public var message: [String?]? {
          get {
            return snapshot["message"]! as! [String?]?
          }
          set {
            snapshot.updateValue(newValue, forKey: "message")
          }
        }

        public var status: String? {
          get {
            return snapshot["status"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "status")
          }
        }
      }

      public struct Benefit: GraphQLSelectionSet {
        public static let possibleTypes = ["CrackBenefit"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("text", type: .scalar(String.self)),
          GraphQLField("color", type: .scalar(String.self)),
          GraphQLField("size", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(text: String? = nil, color: String? = nil, size: String? = nil) {
          self.init(snapshot: ["__typename": "CrackBenefit", "text": text, "color": color, "size": size])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var text: String? {
          get {
            return snapshot["text"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "text")
          }
        }

        public var color: String? {
          get {
            return snapshot["color"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "color")
          }
        }

        public var size: String? {
          get {
            return snapshot["size"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "size")
          }
        }
      }

      public struct CtaButton: GraphQLSelectionSet {
        public static let possibleTypes = ["CrackButton"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .scalar(String.self)),
          GraphQLField("applink", type: .scalar(String.self)),
          GraphQLField("type", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(title: String? = nil, applink: String? = nil, type: String? = nil) {
          self.init(snapshot: ["__typename": "CrackButton", "title": title, "applink": applink, "type": type])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var title: String? {
          get {
            return snapshot["title"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var applink: String? {
          get {
            return snapshot["applink"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "applink")
          }
        }

        public var type: String? {
          get {
            return snapshot["type"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "type")
          }
        }
      }

      public struct ReturnButton: GraphQLSelectionSet {
        public static let possibleTypes = ["CrackButton"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .scalar(String.self)),
          GraphQLField("applink", type: .scalar(String.self)),
          GraphQLField("type", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(title: String? = nil, applink: String? = nil, type: String? = nil) {
          self.init(snapshot: ["__typename": "CrackButton", "title": title, "applink": applink, "type": type])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var title: String? {
          get {
            return snapshot["title"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "title")
          }
        }

        public var applink: String? {
          get {
            return snapshot["applink"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "applink")
          }
        }

        public var type: String? {
          get {
            return snapshot["type"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "type")
          }
        }
      }
    }
  }
}
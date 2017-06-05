//  This file was automatically generated and should not be edited.

import Apollo

public final class FeedDetailQuery: GraphQLQuery {
  public static let operationDefinition =
    "query FeedDetail($detailID: String!, $pageDetail: Int!, $limitDetail: Int!) {" +
    "  feed(detailID: $detailID, pageDetail: $pageDetail, limitDetail: $limitDetail) {" +
    "    __typename" +
    "    data {" +
    "      __typename" +
    "      id" +
    "      create_time" +
    "      type" +
    "      cursor" +
    "      source {" +
    "        __typename" +
    "        type" +
    "        shop {" +
    "          __typename" +
    "          id" +
    "          name" +
    "          avatar" +
    "          isOfficial" +
    "          isGold" +
    "          url" +
    "          shopLink" +
    "          shareLinkDescription" +
    "          shareLinkURL" +
    "        }" +
    "      }" +
    "      content {" +
    "        __typename" +
    "        type" +
    "        total_product" +
    "        products {" +
    "          __typename" +
    "          id" +
    "          name" +
    "          price" +
    "          image" +
    "          wholesale {" +
    "            __typename" +
    "            qty_min_fmt" +
    "          }" +
    "          freereturns" +
    "          preorder" +
    "          cashback" +
    "          url" +
    "          productLink" +
    "          wishlist" +
    "          rating" +
    "        }" +
    "        status_activity" +
    "      }" +
    "      meta {" +
    "        __typename" +
    "        has_next_page" +
    "      }" +
    "    }" +
    "    token" +
    "  }" +
    "}"

  public let detailId: String
  public let pageDetail: Int
  public let limitDetail: Int

  public init(detailId: String, pageDetail: Int, limitDetail: Int) {
    self.detailId = detailId
    self.pageDetail = pageDetail
    self.limitDetail = limitDetail
  }

  public var variables: GraphQLMap? {
    return ["detailID": detailId, "pageDetail": pageDetail, "limitDetail": limitDetail]
  }

  public struct Data: GraphQLMappable {
    public let feed: Feed?

    public init(reader: GraphQLResultReader) throws {
      feed = try reader.optionalValue(for: Field(responseName: "feed", arguments: ["detailID": reader.variables["detailID"], "pageDetail": reader.variables["pageDetail"], "limitDetail": reader.variables["limitDetail"]]))
    }

    public struct Feed: GraphQLMappable {
      public let __typename: String
      public let data: [Datum?]?
      public let token: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        data = try reader.optionalList(for: Field(responseName: "data"))
        token = try reader.optionalValue(for: Field(responseName: "token"))
      }

      public struct Datum: GraphQLMappable {
        public let __typename: String
        public let id: String?
        public let createTime: String?
        public let type: String?
        public let cursor: String?
        public let source: Source?
        public let content: Content?
        public let meta: Metum?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          id = try reader.optionalValue(for: Field(responseName: "id"))
          createTime = try reader.optionalValue(for: Field(responseName: "create_time"))
          type = try reader.optionalValue(for: Field(responseName: "type"))
          cursor = try reader.optionalValue(for: Field(responseName: "cursor"))
          source = try reader.optionalValue(for: Field(responseName: "source"))
          content = try reader.optionalValue(for: Field(responseName: "content"))
          meta = try reader.optionalValue(for: Field(responseName: "meta"))
        }

        public struct Source: GraphQLMappable {
          public let __typename: String
          public let type: Int?
          public let shop: Shop?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            type = try reader.optionalValue(for: Field(responseName: "type"))
            shop = try reader.optionalValue(for: Field(responseName: "shop"))
          }

          public struct Shop: GraphQLMappable {
            public let __typename: String
            public let id: Int?
            public let name: String?
            public let avatar: String?
            public let isOfficial: Bool?
            public let isGold: Bool?
            public let url: String?
            public let shopLink: String?
            public let shareLinkDescription: String?
            public let shareLinkUrl: String?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              id = try reader.optionalValue(for: Field(responseName: "id"))
              name = try reader.optionalValue(for: Field(responseName: "name"))
              avatar = try reader.optionalValue(for: Field(responseName: "avatar"))
              isOfficial = try reader.optionalValue(for: Field(responseName: "isOfficial"))
              isGold = try reader.optionalValue(for: Field(responseName: "isGold"))
              url = try reader.optionalValue(for: Field(responseName: "url"))
              shopLink = try reader.optionalValue(for: Field(responseName: "shopLink"))
              shareLinkDescription = try reader.optionalValue(for: Field(responseName: "shareLinkDescription"))
              shareLinkUrl = try reader.optionalValue(for: Field(responseName: "shareLinkURL"))
            }
          }
        }

        public struct Content: GraphQLMappable {
          public let __typename: String
          public let type: String?
          public let totalProduct: Int?
          public let products: [Product?]?
          public let statusActivity: String?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            type = try reader.optionalValue(for: Field(responseName: "type"))
            totalProduct = try reader.optionalValue(for: Field(responseName: "total_product"))
            products = try reader.optionalList(for: Field(responseName: "products"))
            statusActivity = try reader.optionalValue(for: Field(responseName: "status_activity"))
          }

          public struct Product: GraphQLMappable {
            public let __typename: String
            public let id: Int?
            public let name: String?
            public let price: String?
            public let image: String?
            public let wholesale: [Wholesale?]?
            public let freereturns: Bool?
            public let preorder: Bool?
            public let cashback: String?
            public let url: String?
            public let productLink: String?
            public let wishlist: Bool?
            public let rating: Int?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              id = try reader.optionalValue(for: Field(responseName: "id"))
              name = try reader.optionalValue(for: Field(responseName: "name"))
              price = try reader.optionalValue(for: Field(responseName: "price"))
              image = try reader.optionalValue(for: Field(responseName: "image"))
              wholesale = try reader.optionalList(for: Field(responseName: "wholesale"))
              freereturns = try reader.optionalValue(for: Field(responseName: "freereturns"))
              preorder = try reader.optionalValue(for: Field(responseName: "preorder"))
              cashback = try reader.optionalValue(for: Field(responseName: "cashback"))
              url = try reader.optionalValue(for: Field(responseName: "url"))
              productLink = try reader.optionalValue(for: Field(responseName: "productLink"))
              wishlist = try reader.optionalValue(for: Field(responseName: "wishlist"))
              rating = try reader.optionalValue(for: Field(responseName: "rating"))
            }

            public struct Wholesale: GraphQLMappable {
              public let __typename: String
              public let qtyMinFmt: String?

              public init(reader: GraphQLResultReader) throws {
                __typename = try reader.value(for: Field(responseName: "__typename"))
                qtyMinFmt = try reader.optionalValue(for: Field(responseName: "qty_min_fmt"))
              }
            }
          }
        }

        public struct Metum: GraphQLMappable {
          public let __typename: String
          public let hasNextPage: Bool?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            hasNextPage = try reader.optionalValue(for: Field(responseName: "has_next_page"))
          }
        }
      }
    }
  }
}

public final class FeedsQuery: GraphQLQuery {
  public static let operationDefinition =
    "query Feeds($userID: Int!, $limit: Int!, $cursor: String) {" +
    "  feed(limit: $limit, cursor: $cursor, userID: $userID) {" +
    "    __typename" +
    "    data {" +
    "      __typename" +
    "      id" +
    "      create_time" +
    "      type" +
    "      cursor" +
    "      source {" +
    "        __typename" +
    "        type" +
    "        shop {" +
    "          __typename" +
    "          id" +
    "          name" +
    "          avatar" +
    "          isOfficial" +
    "          isGold" +
    "          url" +
    "          shopLink" +
    "          shareLinkDescription" +
    "          shareLinkURL" +
    "        }" +
    "      }" +
    "      content {" +
    "        __typename" +
    "        type" +
    "        total_product" +
    "        products {" +
    "          __typename" +
    "          id" +
    "          name" +
    "          price" +
    "          image" +
    "          image_single" +
    "          wholesale {" +
    "            __typename" +
    "            qty_min_fmt" +
    "          }" +
    "          freereturns" +
    "          preorder" +
    "          cashback" +
    "          url" +
    "          productLink" +
    "          wishlist" +
    "          rating" +
    "        }" +
    "        promotions {" +
    "          __typename" +
    "          id" +
    "          name" +
    "          type" +
    "          thumbnail" +
    "          feature_image" +
    "          description" +
    "          periode" +
    "          code" +
    "          url" +
    "          min_transcation" +
    "        }" +
    "        status_activity" +
    "      }" +
    "    }" +
    "    links {" +
    "      __typename" +
    "      pagination {" +
    "        __typename" +
    "        has_next_page" +
    "      }" +
    "    }" +
    "    meta {" +
    "      __typename" +
    "      total_data" +
    "    }" +
    "    token" +
    "  }" +
    "}"

  public let userId: Int
  public let limit: Int
  public let cursor: String?

  public init(userId: Int, limit: Int, cursor: String? = nil) {
    self.userId = userId
    self.limit = limit
    self.cursor = cursor
  }

  public var variables: GraphQLMap? {
    return ["userID": userId, "limit": limit, "cursor": cursor]
  }

  public struct Data: GraphQLMappable {
    public let feed: Feed?

    public init(reader: GraphQLResultReader) throws {
      feed = try reader.optionalValue(for: Field(responseName: "feed", arguments: ["limit": reader.variables["limit"], "cursor": reader.variables["cursor"], "userID": reader.variables["userID"]]))
    }

    public struct Feed: GraphQLMappable {
      public let __typename: String
      public let data: [Datum?]?
      public let links: Link?
      public let meta: Metum?
      public let token: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        data = try reader.optionalList(for: Field(responseName: "data"))
        links = try reader.optionalValue(for: Field(responseName: "links"))
        meta = try reader.optionalValue(for: Field(responseName: "meta"))
        token = try reader.optionalValue(for: Field(responseName: "token"))
      }

      public struct Datum: GraphQLMappable {
        public let __typename: String
        public let id: String?
        public let createTime: String?
        public let type: String?
        public let cursor: String?
        public let source: Source?
        public let content: Content?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          id = try reader.optionalValue(for: Field(responseName: "id"))
          createTime = try reader.optionalValue(for: Field(responseName: "create_time"))
          type = try reader.optionalValue(for: Field(responseName: "type"))
          cursor = try reader.optionalValue(for: Field(responseName: "cursor"))
          source = try reader.optionalValue(for: Field(responseName: "source"))
          content = try reader.optionalValue(for: Field(responseName: "content"))
        }

        public struct Source: GraphQLMappable {
          public let __typename: String
          public let type: Int?
          public let shop: Shop?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            type = try reader.optionalValue(for: Field(responseName: "type"))
            shop = try reader.optionalValue(for: Field(responseName: "shop"))
          }

          public struct Shop: GraphQLMappable {
            public let __typename: String
            public let id: Int?
            public let name: String?
            public let avatar: String?
            public let isOfficial: Bool?
            public let isGold: Bool?
            public let url: String?
            public let shopLink: String?
            public let shareLinkDescription: String?
            public let shareLinkUrl: String?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              id = try reader.optionalValue(for: Field(responseName: "id"))
              name = try reader.optionalValue(for: Field(responseName: "name"))
              avatar = try reader.optionalValue(for: Field(responseName: "avatar"))
              isOfficial = try reader.optionalValue(for: Field(responseName: "isOfficial"))
              isGold = try reader.optionalValue(for: Field(responseName: "isGold"))
              url = try reader.optionalValue(for: Field(responseName: "url"))
              shopLink = try reader.optionalValue(for: Field(responseName: "shopLink"))
              shareLinkDescription = try reader.optionalValue(for: Field(responseName: "shareLinkDescription"))
              shareLinkUrl = try reader.optionalValue(for: Field(responseName: "shareLinkURL"))
            }
          }
        }

        public struct Content: GraphQLMappable {
          public let __typename: String
          public let type: String?
          public let totalProduct: Int?
          public let products: [Product?]?
          public let promotions: [Promotion?]?
          public let statusActivity: String?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            type = try reader.optionalValue(for: Field(responseName: "type"))
            totalProduct = try reader.optionalValue(for: Field(responseName: "total_product"))
            products = try reader.optionalList(for: Field(responseName: "products"))
            promotions = try reader.optionalList(for: Field(responseName: "promotions"))
            statusActivity = try reader.optionalValue(for: Field(responseName: "status_activity"))
          }

          public struct Product: GraphQLMappable {
            public let __typename: String
            public let id: Int?
            public let name: String?
            public let price: String?
            public let image: String?
            public let imageSingle: String?
            public let wholesale: [Wholesale?]?
            public let freereturns: Bool?
            public let preorder: Bool?
            public let cashback: String?
            public let url: String?
            public let productLink: String?
            public let wishlist: Bool?
            public let rating: Int?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              id = try reader.optionalValue(for: Field(responseName: "id"))
              name = try reader.optionalValue(for: Field(responseName: "name"))
              price = try reader.optionalValue(for: Field(responseName: "price"))
              image = try reader.optionalValue(for: Field(responseName: "image"))
              imageSingle = try reader.optionalValue(for: Field(responseName: "image_single"))
              wholesale = try reader.optionalList(for: Field(responseName: "wholesale"))
              freereturns = try reader.optionalValue(for: Field(responseName: "freereturns"))
              preorder = try reader.optionalValue(for: Field(responseName: "preorder"))
              cashback = try reader.optionalValue(for: Field(responseName: "cashback"))
              url = try reader.optionalValue(for: Field(responseName: "url"))
              productLink = try reader.optionalValue(for: Field(responseName: "productLink"))
              wishlist = try reader.optionalValue(for: Field(responseName: "wishlist"))
              rating = try reader.optionalValue(for: Field(responseName: "rating"))
            }

            public struct Wholesale: GraphQLMappable {
              public let __typename: String
              public let qtyMinFmt: String?

              public init(reader: GraphQLResultReader) throws {
                __typename = try reader.value(for: Field(responseName: "__typename"))
                qtyMinFmt = try reader.optionalValue(for: Field(responseName: "qty_min_fmt"))
              }
            }
          }

          public struct Promotion: GraphQLMappable {
            public let __typename: String
            public let id: GraphQLID
            public let name: String
            public let type: String
            public let thumbnail: String
            public let featureImage: String
            public let description: String
            public let periode: String
            public let code: String
            public let url: String
            public let minTranscation: String

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              id = try reader.value(for: Field(responseName: "id"))
              name = try reader.value(for: Field(responseName: "name"))
              type = try reader.value(for: Field(responseName: "type"))
              thumbnail = try reader.value(for: Field(responseName: "thumbnail"))
              featureImage = try reader.value(for: Field(responseName: "feature_image"))
              description = try reader.value(for: Field(responseName: "description"))
              periode = try reader.value(for: Field(responseName: "periode"))
              code = try reader.value(for: Field(responseName: "code"))
              url = try reader.value(for: Field(responseName: "url"))
              minTranscation = try reader.value(for: Field(responseName: "min_transcation"))
            }
          }
        }
      }

      public struct Link: GraphQLMappable {
        public let __typename: String
        public let pagination: Pagination?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          pagination = try reader.optionalValue(for: Field(responseName: "pagination"))
        }

        public struct Pagination: GraphQLMappable {
          public let __typename: String
          public let hasNextPage: Bool?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            hasNextPage = try reader.optionalValue(for: Field(responseName: "has_next_page"))
          }
        }
      }

      public struct Metum: GraphQLMappable {
        public let __typename: String
        public let totalData: Int?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          totalData = try reader.optionalValue(for: Field(responseName: "total_data"))
        }
      }
    }
  }
}
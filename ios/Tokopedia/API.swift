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
    "        new_status_activity {" +
    "          __typename" +
    "          source" +
    "          activity" +
    "          amount" +
    "        }" +
    "      }" +
    "      meta {" +
    "        __typename" +
    "        has_next_page" +
    "      }" +
    "    }" +
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

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        data = try reader.optionalList(for: Field(responseName: "data"))
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
          public let newStatusActivity: NewStatusActivity?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            type = try reader.optionalValue(for: Field(responseName: "type"))
            totalProduct = try reader.optionalValue(for: Field(responseName: "total_product"))
            products = try reader.optionalList(for: Field(responseName: "products"))
            statusActivity = try reader.optionalValue(for: Field(responseName: "status_activity"))
            newStatusActivity = try reader.optionalValue(for: Field(responseName: "new_status_activity"))
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

          public struct NewStatusActivity: GraphQLMappable {
            public let __typename: String
            public let source: String?
            public let activity: String?
            public let amount: Int?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              source = try reader.optionalValue(for: Field(responseName: "source"))
              activity = try reader.optionalValue(for: Field(responseName: "activity"))
              amount = try reader.optionalValue(for: Field(responseName: "amount"))
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
    "query Feeds($userID: Int!, $limit: Int!, $cursor: String, $page: Int!) {" +
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
    "        new_status_activity {" +
    "          __typename" +
    "          source" +
    "          activity" +
    "          amount" +
    "        }" +
    "        top_picks {" +
    "          __typename" +
    "          name" +
    "          url" +
    "          image_url" +
    "          image_landscape_url" +
    "          is_parent" +
    "        }" +
    "        seller_story {" +
    "          __typename" +
    "          id" +
    "          title" +
    "          date" +
    "          link" +
    "          image" +
    "          youtube" +
    "        }" +
    "        redirect_url_app" +
    "        official_store {" +
    "          __typename" +
    "          shop_id" +
    "          shop_apps_url" +
    "          shop_name" +
    "          logo_url" +
    "          microsite_url" +
    "          brand_img_url" +
    "          is_owner" +
    "          shop_tagline" +
    "          is_new" +
    "          title" +
    "          mobile_img_url" +
    "          feed_hexa_color" +
    "          redirect_url_app" +
    "          products {" +
    "            __typename" +
    "            brand_id" +
    "            brand_logo" +
    "            data {" +
    "              __typename" +
    "              id" +
    "              name" +
    "              url_app" +
    "              image_url" +
    "              image_url_700" +
    "              price" +
    "              shop {" +
    "                __typename" +
    "                name" +
    "                url_app" +
    "                location" +
    "              }" +
    "              original_price" +
    "              discount_percentage" +
    "              discount_expired" +
    "              badges {" +
    "                __typename" +
    "                title" +
    "                image_url" +
    "              }" +
    "              labels {" +
    "                __typename" +
    "                title" +
    "                color" +
    "              }" +
    "            }" +
    "          }" +
    "        }" +
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
    "  }" +
    "  inspiration(userID: $userID, page: $page) {" +
    "    __typename" +
    "    data {" +
    "      __typename" +
    "      source" +
    "      title" +
    "      foreign_title" +
    "      pagination {" +
    "        __typename" +
    "        current_page" +
    "        next_page" +
    "        prev_page" +
    "      }" +
    "      recommendation {" +
    "        __typename" +
    "        id" +
    "        name" +
    "        url" +
    "        app_url" +
    "        image_url" +
    "        price" +
    "      }" +
    "    }" +
    "  }" +
    "}"

  public let userId: Int
  public let limit: Int
  public let cursor: String?
  public let page: Int

  public init(userId: Int, limit: Int, cursor: String? = nil, page: Int) {
    self.userId = userId
    self.limit = limit
    self.cursor = cursor
    self.page = page
  }

  public var variables: GraphQLMap? {
    return ["userID": userId, "limit": limit, "cursor": cursor, "page": page]
  }

  public struct Data: GraphQLMappable {
    public let feed: Feed?
    public let inspiration: Inspiration?

    public init(reader: GraphQLResultReader) throws {
      feed = try reader.optionalValue(for: Field(responseName: "feed", arguments: ["limit": reader.variables["limit"], "cursor": reader.variables["cursor"], "userID": reader.variables["userID"]]))
      inspiration = try reader.optionalValue(for: Field(responseName: "inspiration", arguments: ["userID": reader.variables["userID"], "page": reader.variables["page"]]))
    }

    public struct Feed: GraphQLMappable {
      public let __typename: String
      public let data: [Datum?]?
      public let links: Link?
      public let meta: Metum?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        data = try reader.optionalList(for: Field(responseName: "data"))
        links = try reader.optionalValue(for: Field(responseName: "links"))
        meta = try reader.optionalValue(for: Field(responseName: "meta"))
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
          public let newStatusActivity: NewStatusActivity?
          public let topPicks: [TopPick?]?
          public let sellerStory: SellerStory?
          public let redirectUrlApp: String?
          public let officialStore: [OfficialStore?]?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            type = try reader.optionalValue(for: Field(responseName: "type"))
            totalProduct = try reader.optionalValue(for: Field(responseName: "total_product"))
            products = try reader.optionalList(for: Field(responseName: "products"))
            promotions = try reader.optionalList(for: Field(responseName: "promotions"))
            statusActivity = try reader.optionalValue(for: Field(responseName: "status_activity"))
            newStatusActivity = try reader.optionalValue(for: Field(responseName: "new_status_activity"))
            topPicks = try reader.optionalList(for: Field(responseName: "top_picks"))
            sellerStory = try reader.optionalValue(for: Field(responseName: "seller_story"))
            redirectUrlApp = try reader.optionalValue(for: Field(responseName: "redirect_url_app"))
            officialStore = try reader.optionalList(for: Field(responseName: "official_store"))
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

          public struct NewStatusActivity: GraphQLMappable {
            public let __typename: String
            public let source: String?
            public let activity: String?
            public let amount: Int?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              source = try reader.optionalValue(for: Field(responseName: "source"))
              activity = try reader.optionalValue(for: Field(responseName: "activity"))
              amount = try reader.optionalValue(for: Field(responseName: "amount"))
            }
          }

          public struct TopPick: GraphQLMappable {
            public let __typename: String
            public let name: String?
            public let url: String?
            public let imageUrl: String?
            public let imageLandscapeUrl: String?
            public let isParent: Bool?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              name = try reader.optionalValue(for: Field(responseName: "name"))
              url = try reader.optionalValue(for: Field(responseName: "url"))
              imageUrl = try reader.optionalValue(for: Field(responseName: "image_url"))
              imageLandscapeUrl = try reader.optionalValue(for: Field(responseName: "image_landscape_url"))
              isParent = try reader.optionalValue(for: Field(responseName: "is_parent"))
            }
          }

          public struct SellerStory: GraphQLMappable {
            public let __typename: String
            public let id: GraphQLID?
            public let title: String?
            public let date: String?
            public let link: String?
            public let image: String?
            public let youtube: String?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              id = try reader.optionalValue(for: Field(responseName: "id"))
              title = try reader.optionalValue(for: Field(responseName: "title"))
              date = try reader.optionalValue(for: Field(responseName: "date"))
              link = try reader.optionalValue(for: Field(responseName: "link"))
              image = try reader.optionalValue(for: Field(responseName: "image"))
              youtube = try reader.optionalValue(for: Field(responseName: "youtube"))
            }
          }

          public struct OfficialStore: GraphQLMappable {
            public let __typename: String
            public let shopId: Int?
            public let shopAppsUrl: String?
            public let shopName: String?
            public let logoUrl: String?
            public let micrositeUrl: String?
            public let brandImgUrl: String?
            public let isOwner: Bool?
            public let shopTagline: String?
            public let isNew: Bool?
            public let title: String?
            public let mobileImgUrl: String?
            public let feedHexaColor: String?
            public let redirectUrlApp: String?
            public let products: [Product?]?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              shopId = try reader.optionalValue(for: Field(responseName: "shop_id"))
              shopAppsUrl = try reader.optionalValue(for: Field(responseName: "shop_apps_url"))
              shopName = try reader.optionalValue(for: Field(responseName: "shop_name"))
              logoUrl = try reader.optionalValue(for: Field(responseName: "logo_url"))
              micrositeUrl = try reader.optionalValue(for: Field(responseName: "microsite_url"))
              brandImgUrl = try reader.optionalValue(for: Field(responseName: "brand_img_url"))
              isOwner = try reader.optionalValue(for: Field(responseName: "is_owner"))
              shopTagline = try reader.optionalValue(for: Field(responseName: "shop_tagline"))
              isNew = try reader.optionalValue(for: Field(responseName: "is_new"))
              title = try reader.optionalValue(for: Field(responseName: "title"))
              mobileImgUrl = try reader.optionalValue(for: Field(responseName: "mobile_img_url"))
              feedHexaColor = try reader.optionalValue(for: Field(responseName: "feed_hexa_color"))
              redirectUrlApp = try reader.optionalValue(for: Field(responseName: "redirect_url_app"))
              products = try reader.optionalList(for: Field(responseName: "products"))
            }

            public struct Product: GraphQLMappable {
              public let __typename: String
              public let brandId: Int?
              public let brandLogo: String?
              public let data: Datum?

              public init(reader: GraphQLResultReader) throws {
                __typename = try reader.value(for: Field(responseName: "__typename"))
                brandId = try reader.optionalValue(for: Field(responseName: "brand_id"))
                brandLogo = try reader.optionalValue(for: Field(responseName: "brand_logo"))
                data = try reader.optionalValue(for: Field(responseName: "data"))
              }

              public struct Datum: GraphQLMappable {
                public let __typename: String
                public let id: Int?
                public let name: String?
                public let urlApp: String?
                public let imageUrl: String?
                public let imageUrl_700: String?
                public let price: String?
                public let shop: Shop?
                public let originalPrice: String?
                public let discountPercentage: Int?
                public let discountExpired: String?
                public let badges: [Badge?]?
                public let labels: [Label?]?

                public init(reader: GraphQLResultReader) throws {
                  __typename = try reader.value(for: Field(responseName: "__typename"))
                  id = try reader.optionalValue(for: Field(responseName: "id"))
                  name = try reader.optionalValue(for: Field(responseName: "name"))
                  urlApp = try reader.optionalValue(for: Field(responseName: "url_app"))
                  imageUrl = try reader.optionalValue(for: Field(responseName: "image_url"))
                  imageUrl_700 = try reader.optionalValue(for: Field(responseName: "image_url_700"))
                  price = try reader.optionalValue(for: Field(responseName: "price"))
                  shop = try reader.optionalValue(for: Field(responseName: "shop"))
                  originalPrice = try reader.optionalValue(for: Field(responseName: "original_price"))
                  discountPercentage = try reader.optionalValue(for: Field(responseName: "discount_percentage"))
                  discountExpired = try reader.optionalValue(for: Field(responseName: "discount_expired"))
                  badges = try reader.optionalList(for: Field(responseName: "badges"))
                  labels = try reader.optionalList(for: Field(responseName: "labels"))
                }

                public struct Shop: GraphQLMappable {
                  public let __typename: String
                  public let name: String?
                  public let urlApp: String?
                  public let location: String?

                  public init(reader: GraphQLResultReader) throws {
                    __typename = try reader.value(for: Field(responseName: "__typename"))
                    name = try reader.optionalValue(for: Field(responseName: "name"))
                    urlApp = try reader.optionalValue(for: Field(responseName: "url_app"))
                    location = try reader.optionalValue(for: Field(responseName: "location"))
                  }
                }

                public struct Badge: GraphQLMappable {
                  public let __typename: String
                  public let title: String
                  public let imageUrl: String

                  public init(reader: GraphQLResultReader) throws {
                    __typename = try reader.value(for: Field(responseName: "__typename"))
                    title = try reader.value(for: Field(responseName: "title"))
                    imageUrl = try reader.value(for: Field(responseName: "image_url"))
                  }
                }

                public struct Label: GraphQLMappable {
                  public let __typename: String
                  public let title: String
                  public let color: String

                  public init(reader: GraphQLResultReader) throws {
                    __typename = try reader.value(for: Field(responseName: "__typename"))
                    title = try reader.value(for: Field(responseName: "title"))
                    color = try reader.value(for: Field(responseName: "color"))
                  }
                }
              }
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

    public struct Inspiration: GraphQLMappable {
      public let __typename: String
      public let data: [Datum?]?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        data = try reader.optionalList(for: Field(responseName: "data"))
      }

      public struct Datum: GraphQLMappable {
        public let __typename: String
        public let source: String?
        public let title: String?
        public let foreignTitle: String?
        public let pagination: Pagination?
        public let recommendation: [Recommendation?]?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          source = try reader.optionalValue(for: Field(responseName: "source"))
          title = try reader.optionalValue(for: Field(responseName: "title"))
          foreignTitle = try reader.optionalValue(for: Field(responseName: "foreign_title"))
          pagination = try reader.optionalValue(for: Field(responseName: "pagination"))
          recommendation = try reader.optionalList(for: Field(responseName: "recommendation"))
        }

        public struct Pagination: GraphQLMappable {
          public let __typename: String
          public let currentPage: Int?
          public let nextPage: Int?
          public let prevPage: Int?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            currentPage = try reader.optionalValue(for: Field(responseName: "current_page"))
            nextPage = try reader.optionalValue(for: Field(responseName: "next_page"))
            prevPage = try reader.optionalValue(for: Field(responseName: "prev_page"))
          }
        }

        public struct Recommendation: GraphQLMappable {
          public let __typename: String
          public let id: GraphQLID?
          public let name: String?
          public let url: String?
          public let appUrl: String?
          public let imageUrl: String?
          public let price: String?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            id = try reader.optionalValue(for: Field(responseName: "id"))
            name = try reader.optionalValue(for: Field(responseName: "name"))
            url = try reader.optionalValue(for: Field(responseName: "url"))
            appUrl = try reader.optionalValue(for: Field(responseName: "app_url"))
            imageUrl = try reader.optionalValue(for: Field(responseName: "image_url"))
            price = try reader.optionalValue(for: Field(responseName: "price"))
          }
        }
      }
    }
  }
}
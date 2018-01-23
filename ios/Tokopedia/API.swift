//  This file was automatically generated and should not be edited.

import Apollo

public final class FeedDetailQuery: GraphQLQuery {
  public static let operationString =
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

  public var detailID: String
  public var pageDetail: Int
  public var limitDetail: Int

  public init(detailID: String, pageDetail: Int, limitDetail: Int) {
    self.detailID = detailID
    self.pageDetail = pageDetail
    self.limitDetail = limitDetail
  }

  public var variables: GraphQLMap? {
    return ["detailID": detailID, "pageDetail": pageDetail, "limitDetail": limitDetail]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("feed", arguments: ["detailID": Variable("detailID"), "pageDetail": Variable("pageDetail"), "limitDetail": Variable("limitDetail")], type: .object(Feed.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(feed: Feed? = nil) {
      self.init(snapshot: ["__typename": "Query", "feed": feed])
    }

    public var feed: Feed? {
      get {
        return (snapshot["feed"]! as! Snapshot?).flatMap { Feed(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "feed")
      }
    }

    public struct Feed: GraphQLSelectionSet {
      public static let possibleTypes = ["Feeds"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .list(.object(Datum.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: [Datum?]? = nil) {
        self.init(snapshot: ["__typename": "Feeds", "data": data])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: [Datum?]? {
        get {
          return (snapshot["data"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Datum(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "data")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes = ["Feed"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(String.self)),
          GraphQLField("create_time", type: .scalar(String.self)),
          GraphQLField("type", type: .scalar(String.self)),
          GraphQLField("cursor", type: .scalar(String.self)),
          GraphQLField("source", type: .object(Source.self)),
          GraphQLField("content", type: .object(Content.self)),
          GraphQLField("meta", type: .object(Metum.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String? = nil, createTime: String? = nil, type: String? = nil, cursor: String? = nil, source: Source? = nil, content: Content? = nil, meta: Metum? = nil) {
          self.init(snapshot: ["__typename": "Feed", "id": id, "create_time": createTime, "type": type, "cursor": cursor, "source": source, "content": content, "meta": meta])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String? {
          get {
            return snapshot["id"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var createTime: String? {
          get {
            return snapshot["create_time"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "create_time")
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

        public var cursor: String? {
          get {
            return snapshot["cursor"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "cursor")
          }
        }

        public var source: Source? {
          get {
            return (snapshot["source"]! as! Snapshot?).flatMap { Source(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "source")
          }
        }

        public var content: Content? {
          get {
            return (snapshot["content"]! as! Snapshot?).flatMap { Content(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "content")
          }
        }

        public var meta: Metum? {
          get {
            return (snapshot["meta"]! as! Snapshot?).flatMap { Metum(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "meta")
          }
        }

        public struct Source: GraphQLSelectionSet {
          public static let possibleTypes = ["FeedSource"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .scalar(Int.self)),
            GraphQLField("shop", type: .object(Shop.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(type: Int? = nil, shop: Shop? = nil) {
            self.init(snapshot: ["__typename": "FeedSource", "type": type, "shop": shop])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: Int? {
            get {
              return snapshot["type"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "type")
            }
          }

          public var shop: Shop? {
            get {
              return (snapshot["shop"]! as! Snapshot?).flatMap { Shop(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "shop")
            }
          }

          public struct Shop: GraphQLSelectionSet {
            public static let possibleTypes = ["ShopDetail"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("avatar", type: .scalar(String.self)),
              GraphQLField("isOfficial", type: .scalar(Bool.self)),
              GraphQLField("isGold", type: .scalar(Bool.self)),
              GraphQLField("url", type: .scalar(String.self)),
              GraphQLField("shopLink", type: .scalar(String.self)),
              GraphQLField("shareLinkDescription", type: .scalar(String.self)),
              GraphQLField("shareLinkURL", type: .scalar(String.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(id: Int? = nil, name: String? = nil, avatar: String? = nil, isOfficial: Bool? = nil, isGold: Bool? = nil, url: String? = nil, shopLink: String? = nil, shareLinkDescription: String? = nil, shareLinkUrl: String? = nil) {
              self.init(snapshot: ["__typename": "ShopDetail", "id": id, "name": name, "avatar": avatar, "isOfficial": isOfficial, "isGold": isGold, "url": url, "shopLink": shopLink, "shareLinkDescription": shareLinkDescription, "shareLinkURL": shareLinkUrl])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: Int? {
              get {
                return snapshot["id"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "id")
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

            public var avatar: String? {
              get {
                return snapshot["avatar"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "avatar")
              }
            }

            public var isOfficial: Bool? {
              get {
                return snapshot["isOfficial"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "isOfficial")
              }
            }

            public var isGold: Bool? {
              get {
                return snapshot["isGold"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "isGold")
              }
            }

            public var url: String? {
              get {
                return snapshot["url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "url")
              }
            }

            public var shopLink: String? {
              get {
                return snapshot["shopLink"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shopLink")
              }
            }

            public var shareLinkDescription: String? {
              get {
                return snapshot["shareLinkDescription"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shareLinkDescription")
              }
            }

            public var shareLinkUrl: String? {
              get {
                return snapshot["shareLinkURL"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shareLinkURL")
              }
            }
          }
        }

        public struct Content: GraphQLSelectionSet {
          public static let possibleTypes = ["FeedContent"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .scalar(String.self)),
            GraphQLField("total_product", type: .scalar(Int.self)),
            GraphQLField("products", type: .list(.object(Product.self))),
            GraphQLField("status_activity", type: .scalar(String.self)),
            GraphQLField("new_status_activity", type: .object(NewStatusActivity.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(type: String? = nil, totalProduct: Int? = nil, products: [Product?]? = nil, statusActivity: String? = nil, newStatusActivity: NewStatusActivity? = nil) {
            self.init(snapshot: ["__typename": "FeedContent", "type": type, "total_product": totalProduct, "products": products, "status_activity": statusActivity, "new_status_activity": newStatusActivity])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
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

          public var totalProduct: Int? {
            get {
              return snapshot["total_product"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "total_product")
            }
          }

          public var products: [Product?]? {
            get {
              return (snapshot["products"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Product(snapshot: $0) } } }
            }
            set {
              snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "products")
            }
          }

          public var statusActivity: String? {
            get {
              return snapshot["status_activity"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "status_activity")
            }
          }

          public var newStatusActivity: NewStatusActivity? {
            get {
              return (snapshot["new_status_activity"]! as! Snapshot?).flatMap { NewStatusActivity(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "new_status_activity")
            }
          }

          public struct Product: GraphQLSelectionSet {
            public static let possibleTypes = ["ProductFeedType"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("price", type: .scalar(String.self)),
              GraphQLField("image", type: .scalar(String.self)),
              GraphQLField("wholesale", type: .list(.object(Wholesale.self))),
              GraphQLField("freereturns", type: .scalar(Bool.self)),
              GraphQLField("preorder", type: .scalar(Bool.self)),
              GraphQLField("cashback", type: .scalar(String.self)),
              GraphQLField("url", type: .scalar(String.self)),
              GraphQLField("productLink", type: .scalar(String.self)),
              GraphQLField("wishlist", type: .scalar(Bool.self)),
              GraphQLField("rating", type: .scalar(Double.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(id: Int? = nil, name: String? = nil, price: String? = nil, image: String? = nil, wholesale: [Wholesale?]? = nil, freereturns: Bool? = nil, preorder: Bool? = nil, cashback: String? = nil, url: String? = nil, productLink: String? = nil, wishlist: Bool? = nil, rating: Double? = nil) {
              self.init(snapshot: ["__typename": "ProductFeedType", "id": id, "name": name, "price": price, "image": image, "wholesale": wholesale, "freereturns": freereturns, "preorder": preorder, "cashback": cashback, "url": url, "productLink": productLink, "wishlist": wishlist, "rating": rating])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: Int? {
              get {
                return snapshot["id"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "id")
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

            public var price: String? {
              get {
                return snapshot["price"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "price")
              }
            }

            public var image: String? {
              get {
                return snapshot["image"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "image")
              }
            }

            public var wholesale: [Wholesale?]? {
              get {
                return (snapshot["wholesale"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Wholesale(snapshot: $0) } } }
              }
              set {
                snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "wholesale")
              }
            }

            public var freereturns: Bool? {
              get {
                return snapshot["freereturns"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "freereturns")
              }
            }

            public var preorder: Bool? {
              get {
                return snapshot["preorder"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "preorder")
              }
            }

            public var cashback: String? {
              get {
                return snapshot["cashback"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "cashback")
              }
            }

            public var url: String? {
              get {
                return snapshot["url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "url")
              }
            }

            public var productLink: String? {
              get {
                return snapshot["productLink"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "productLink")
              }
            }

            public var wishlist: Bool? {
              get {
                return snapshot["wishlist"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "wishlist")
              }
            }

            public var rating: Double? {
              get {
                return snapshot["rating"]! as! Double?
              }
              set {
                snapshot.updateValue(newValue, forKey: "rating")
              }
            }

            public struct Wholesale: GraphQLSelectionSet {
              public static let possibleTypes = ["Wholesale"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("qty_min_fmt", type: .scalar(String.self)),
              ]

              public var snapshot: Snapshot

              public init(snapshot: Snapshot) {
                self.snapshot = snapshot
              }

              public init(qtyMinFmt: String? = nil) {
                self.init(snapshot: ["__typename": "Wholesale", "qty_min_fmt": qtyMinFmt])
              }

              public var __typename: String {
                get {
                  return snapshot["__typename"]! as! String
                }
                set {
                  snapshot.updateValue(newValue, forKey: "__typename")
                }
              }

              public var qtyMinFmt: String? {
                get {
                  return snapshot["qty_min_fmt"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "qty_min_fmt")
                }
              }
            }
          }

          public struct NewStatusActivity: GraphQLSelectionSet {
            public static let possibleTypes = ["StatusActivity"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("source", type: .scalar(String.self)),
              GraphQLField("activity", type: .scalar(String.self)),
              GraphQLField("amount", type: .scalar(Int.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(source: String? = nil, activity: String? = nil, amount: Int? = nil) {
              self.init(snapshot: ["__typename": "StatusActivity", "source": source, "activity": activity, "amount": amount])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var source: String? {
              get {
                return snapshot["source"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "source")
              }
            }

            public var activity: String? {
              get {
                return snapshot["activity"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "activity")
              }
            }

            public var amount: Int? {
              get {
                return snapshot["amount"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "amount")
              }
            }
          }
        }

        public struct Metum: GraphQLSelectionSet {
          public static let possibleTypes = ["FeedMeta"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("has_next_page", type: .scalar(Bool.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(hasNextPage: Bool? = nil) {
            self.init(snapshot: ["__typename": "FeedMeta", "has_next_page": hasNextPage])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var hasNextPage: Bool? {
            get {
              return snapshot["has_next_page"]! as! Bool?
            }
            set {
              snapshot.updateValue(newValue, forKey: "has_next_page")
            }
          }
        }
      }
    }
  }
}

public final class FeedsQuery: GraphQLQuery {
  public static let operationString =
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
    "          price_int" +
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
    "        inspirasi {" +
    "          __typename" +
    "          source" +
    "          title" +
    "          foreign_title" +
    "          pagination {" +
    "            __typename" +
    "            current_page" +
    "            next_page" +
    "            prev_page" +
    "          }" +
    "          recommendation {" +
    "            __typename" +
    "            id" +
    "            name" +
    "            url" +
    "            click_url" +
    "            app_url" +
    "            image_url" +
    "            price" +
    "            price_int" +
    "            recommendation_type" +
    "          }" +
    "        }" +
    "        kolpost {" +
    "          __typename" +
    "          id" +
    "          headerTitle" +
    "          description" +
    "          commentCount" +
    "          likeCount" +
    "          showComment" +
    "          isLiked" +
    "          isFollowed" +
    "          createTime" +
    "          userId" +
    "          userName" +
    "          userInfo" +
    "          userPhoto" +
    "          userUrl" +
    "          content {" +
    "            __typename" +
    "            imageurl" +
    "            tags {" +
    "              __typename" +
    "              id" +
    "              type" +
    "              url" +
    "              link" +
    "              price" +
    "              caption" +
    "            }" +
    "          }" +
    "        }" +
    "        followedkolpost {" +
    "          __typename" +
    "          id" +
    "          headerTitle" +
    "          description" +
    "          commentCount" +
    "          likeCount" +
    "          showComment" +
    "          isLiked" +
    "          isFollowed" +
    "          createTime" +
    "          userId" +
    "          userName" +
    "          userInfo" +
    "          userPhoto" +
    "          userUrl" +
    "          content {" +
    "            __typename" +
    "            imageurl" +
    "            tags {" +
    "              __typename" +
    "              id" +
    "              type" +
    "              url" +
    "              link" +
    "              price" +
    "              caption" +
    "            }" +
    "          }" +
    "        }" +
    "        kolrecommendation {" +
    "          __typename" +
    "          index" +
    "          headerTitle" +
    "          exploreLink" +
    "          kols {" +
    "            __typename" +
    "            userName" +
    "            userId" +
    "            userPhoto" +
    "            isFollowed" +
    "            info" +
    "            url" +
    "          }" +
    "        }" +
    "        favorite_cta {" +
    "          __typename" +
    "          title_id" +
    "          subtitle_id" +
    "        }" +
    "        kol_cta {" +
    "          __typename" +
    "          img_header" +
    "          title" +
    "          subtitle" +
    "          button_text" +
    "          click_url" +
    "          click_applink" +
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
    "}"

  public var userID: Int
  public var limit: Int
  public var cursor: String?

  public init(userID: Int, limit: Int, cursor: String? = nil) {
    self.userID = userID
    self.limit = limit
    self.cursor = cursor
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "limit": limit, "cursor": cursor]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("feed", arguments: ["limit": Variable("limit"), "cursor": Variable("cursor"), "userID": Variable("userID")], type: .object(Feed.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(feed: Feed? = nil) {
      self.init(snapshot: ["__typename": "Query", "feed": feed])
    }

    public var feed: Feed? {
      get {
        return (snapshot["feed"]! as! Snapshot?).flatMap { Feed(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "feed")
      }
    }

    public struct Feed: GraphQLSelectionSet {
      public static let possibleTypes = ["Feeds"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .list(.object(Datum.self))),
        GraphQLField("links", type: .object(Link.self)),
        GraphQLField("meta", type: .object(Metum.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: [Datum?]? = nil, links: Link? = nil, meta: Metum? = nil) {
        self.init(snapshot: ["__typename": "Feeds", "data": data, "links": links, "meta": meta])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: [Datum?]? {
        get {
          return (snapshot["data"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Datum(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "data")
        }
      }

      public var links: Link? {
        get {
          return (snapshot["links"]! as! Snapshot?).flatMap { Link(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "links")
        }
      }

      public var meta: Metum? {
        get {
          return (snapshot["meta"]! as! Snapshot?).flatMap { Metum(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "meta")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes = ["Feed"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(String.self)),
          GraphQLField("create_time", type: .scalar(String.self)),
          GraphQLField("type", type: .scalar(String.self)),
          GraphQLField("cursor", type: .scalar(String.self)),
          GraphQLField("source", type: .object(Source.self)),
          GraphQLField("content", type: .object(Content.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String? = nil, createTime: String? = nil, type: String? = nil, cursor: String? = nil, source: Source? = nil, content: Content? = nil) {
          self.init(snapshot: ["__typename": "Feed", "id": id, "create_time": createTime, "type": type, "cursor": cursor, "source": source, "content": content])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String? {
          get {
            return snapshot["id"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var createTime: String? {
          get {
            return snapshot["create_time"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "create_time")
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

        public var cursor: String? {
          get {
            return snapshot["cursor"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "cursor")
          }
        }

        public var source: Source? {
          get {
            return (snapshot["source"]! as! Snapshot?).flatMap { Source(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "source")
          }
        }

        public var content: Content? {
          get {
            return (snapshot["content"]! as! Snapshot?).flatMap { Content(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "content")
          }
        }

        public struct Source: GraphQLSelectionSet {
          public static let possibleTypes = ["FeedSource"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .scalar(Int.self)),
            GraphQLField("shop", type: .object(Shop.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(type: Int? = nil, shop: Shop? = nil) {
            self.init(snapshot: ["__typename": "FeedSource", "type": type, "shop": shop])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var type: Int? {
            get {
              return snapshot["type"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "type")
            }
          }

          public var shop: Shop? {
            get {
              return (snapshot["shop"]! as! Snapshot?).flatMap { Shop(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "shop")
            }
          }

          public struct Shop: GraphQLSelectionSet {
            public static let possibleTypes = ["ShopDetail"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("avatar", type: .scalar(String.self)),
              GraphQLField("isOfficial", type: .scalar(Bool.self)),
              GraphQLField("isGold", type: .scalar(Bool.self)),
              GraphQLField("url", type: .scalar(String.self)),
              GraphQLField("shopLink", type: .scalar(String.self)),
              GraphQLField("shareLinkDescription", type: .scalar(String.self)),
              GraphQLField("shareLinkURL", type: .scalar(String.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(id: Int? = nil, name: String? = nil, avatar: String? = nil, isOfficial: Bool? = nil, isGold: Bool? = nil, url: String? = nil, shopLink: String? = nil, shareLinkDescription: String? = nil, shareLinkUrl: String? = nil) {
              self.init(snapshot: ["__typename": "ShopDetail", "id": id, "name": name, "avatar": avatar, "isOfficial": isOfficial, "isGold": isGold, "url": url, "shopLink": shopLink, "shareLinkDescription": shareLinkDescription, "shareLinkURL": shareLinkUrl])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: Int? {
              get {
                return snapshot["id"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "id")
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

            public var avatar: String? {
              get {
                return snapshot["avatar"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "avatar")
              }
            }

            public var isOfficial: Bool? {
              get {
                return snapshot["isOfficial"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "isOfficial")
              }
            }

            public var isGold: Bool? {
              get {
                return snapshot["isGold"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "isGold")
              }
            }

            public var url: String? {
              get {
                return snapshot["url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "url")
              }
            }

            public var shopLink: String? {
              get {
                return snapshot["shopLink"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shopLink")
              }
            }

            public var shareLinkDescription: String? {
              get {
                return snapshot["shareLinkDescription"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shareLinkDescription")
              }
            }

            public var shareLinkUrl: String? {
              get {
                return snapshot["shareLinkURL"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shareLinkURL")
              }
            }
          }
        }

        public struct Content: GraphQLSelectionSet {
          public static let possibleTypes = ["FeedContent"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .scalar(String.self)),
            GraphQLField("total_product", type: .scalar(Int.self)),
            GraphQLField("products", type: .list(.object(Product.self))),
            GraphQLField("promotions", type: .list(.object(Promotion.self))),
            GraphQLField("status_activity", type: .scalar(String.self)),
            GraphQLField("new_status_activity", type: .object(NewStatusActivity.self)),
            GraphQLField("top_picks", type: .list(.object(TopPick.self))),
            GraphQLField("redirect_url_app", type: .scalar(String.self)),
            GraphQLField("official_store", type: .list(.object(OfficialStore.self))),
            GraphQLField("inspirasi", type: .list(.object(Inspirasi.self))),
            GraphQLField("kolpost", type: .object(Kolpost.self)),
            GraphQLField("followedkolpost", type: .object(Followedkolpost.self)),
            GraphQLField("kolrecommendation", type: .object(Kolrecommendation.self)),
            GraphQLField("favorite_cta", type: .object(FavoriteCtum.self)),
            GraphQLField("kol_cta", type: .object(KolCtum.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(type: String? = nil, totalProduct: Int? = nil, products: [Product?]? = nil, promotions: [Promotion?]? = nil, statusActivity: String? = nil, newStatusActivity: NewStatusActivity? = nil, topPicks: [TopPick?]? = nil, redirectUrlApp: String? = nil, officialStore: [OfficialStore?]? = nil, inspirasi: [Inspirasi?]? = nil, kolpost: Kolpost? = nil, followedkolpost: Followedkolpost? = nil, kolrecommendation: Kolrecommendation? = nil, favoriteCta: FavoriteCtum? = nil, kolCta: KolCtum? = nil) {
            self.init(snapshot: ["__typename": "FeedContent", "type": type, "total_product": totalProduct, "products": products, "promotions": promotions, "status_activity": statusActivity, "new_status_activity": newStatusActivity, "top_picks": topPicks, "redirect_url_app": redirectUrlApp, "official_store": officialStore, "inspirasi": inspirasi, "kolpost": kolpost, "followedkolpost": followedkolpost, "kolrecommendation": kolrecommendation, "favorite_cta": favoriteCta, "kol_cta": kolCta])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
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

          public var totalProduct: Int? {
            get {
              return snapshot["total_product"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "total_product")
            }
          }

          public var products: [Product?]? {
            get {
              return (snapshot["products"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Product(snapshot: $0) } } }
            }
            set {
              snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "products")
            }
          }

          public var promotions: [Promotion?]? {
            get {
              return (snapshot["promotions"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Promotion(snapshot: $0) } } }
            }
            set {
              snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "promotions")
            }
          }

          public var statusActivity: String? {
            get {
              return snapshot["status_activity"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "status_activity")
            }
          }

          public var newStatusActivity: NewStatusActivity? {
            get {
              return (snapshot["new_status_activity"]! as! Snapshot?).flatMap { NewStatusActivity(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "new_status_activity")
            }
          }

          public var topPicks: [TopPick?]? {
            get {
              return (snapshot["top_picks"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { TopPick(snapshot: $0) } } }
            }
            set {
              snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "top_picks")
            }
          }

          public var redirectUrlApp: String? {
            get {
              return snapshot["redirect_url_app"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "redirect_url_app")
            }
          }

          public var officialStore: [OfficialStore?]? {
            get {
              return (snapshot["official_store"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { OfficialStore(snapshot: $0) } } }
            }
            set {
              snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "official_store")
            }
          }

          public var inspirasi: [Inspirasi?]? {
            get {
              return (snapshot["inspirasi"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Inspirasi(snapshot: $0) } } }
            }
            set {
              snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "inspirasi")
            }
          }

          public var kolpost: Kolpost? {
            get {
              return (snapshot["kolpost"]! as! Snapshot?).flatMap { Kolpost(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "kolpost")
            }
          }

          public var followedkolpost: Followedkolpost? {
            get {
              return (snapshot["followedkolpost"]! as! Snapshot?).flatMap { Followedkolpost(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "followedkolpost")
            }
          }

          public var kolrecommendation: Kolrecommendation? {
            get {
              return (snapshot["kolrecommendation"]! as! Snapshot?).flatMap { Kolrecommendation(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "kolrecommendation")
            }
          }

          public var favoriteCta: FavoriteCtum? {
            get {
              return (snapshot["favorite_cta"]! as! Snapshot?).flatMap { FavoriteCtum(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "favorite_cta")
            }
          }

          public var kolCta: KolCtum? {
            get {
              return (snapshot["kol_cta"]! as! Snapshot?).flatMap { KolCtum(snapshot: $0) }
            }
            set {
              snapshot.updateValue(newValue?.snapshot, forKey: "kol_cta")
            }
          }

          public struct Product: GraphQLSelectionSet {
            public static let possibleTypes = ["ProductFeedType"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("price", type: .scalar(String.self)),
              GraphQLField("price_int", type: .scalar(Int.self)),
              GraphQLField("image", type: .scalar(String.self)),
              GraphQLField("image_single", type: .scalar(String.self)),
              GraphQLField("wholesale", type: .list(.object(Wholesale.self))),
              GraphQLField("freereturns", type: .scalar(Bool.self)),
              GraphQLField("preorder", type: .scalar(Bool.self)),
              GraphQLField("cashback", type: .scalar(String.self)),
              GraphQLField("url", type: .scalar(String.self)),
              GraphQLField("productLink", type: .scalar(String.self)),
              GraphQLField("wishlist", type: .scalar(Bool.self)),
              GraphQLField("rating", type: .scalar(Double.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(id: Int? = nil, name: String? = nil, price: String? = nil, priceInt: Int? = nil, image: String? = nil, imageSingle: String? = nil, wholesale: [Wholesale?]? = nil, freereturns: Bool? = nil, preorder: Bool? = nil, cashback: String? = nil, url: String? = nil, productLink: String? = nil, wishlist: Bool? = nil, rating: Double? = nil) {
              self.init(snapshot: ["__typename": "ProductFeedType", "id": id, "name": name, "price": price, "price_int": priceInt, "image": image, "image_single": imageSingle, "wholesale": wholesale, "freereturns": freereturns, "preorder": preorder, "cashback": cashback, "url": url, "productLink": productLink, "wishlist": wishlist, "rating": rating])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: Int? {
              get {
                return snapshot["id"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "id")
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

            public var price: String? {
              get {
                return snapshot["price"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "price")
              }
            }

            public var priceInt: Int? {
              get {
                return snapshot["price_int"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "price_int")
              }
            }

            public var image: String? {
              get {
                return snapshot["image"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "image")
              }
            }

            public var imageSingle: String? {
              get {
                return snapshot["image_single"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "image_single")
              }
            }

            public var wholesale: [Wholesale?]? {
              get {
                return (snapshot["wholesale"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Wholesale(snapshot: $0) } } }
              }
              set {
                snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "wholesale")
              }
            }

            public var freereturns: Bool? {
              get {
                return snapshot["freereturns"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "freereturns")
              }
            }

            public var preorder: Bool? {
              get {
                return snapshot["preorder"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "preorder")
              }
            }

            public var cashback: String? {
              get {
                return snapshot["cashback"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "cashback")
              }
            }

            public var url: String? {
              get {
                return snapshot["url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "url")
              }
            }

            public var productLink: String? {
              get {
                return snapshot["productLink"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "productLink")
              }
            }

            public var wishlist: Bool? {
              get {
                return snapshot["wishlist"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "wishlist")
              }
            }

            public var rating: Double? {
              get {
                return snapshot["rating"]! as! Double?
              }
              set {
                snapshot.updateValue(newValue, forKey: "rating")
              }
            }

            public struct Wholesale: GraphQLSelectionSet {
              public static let possibleTypes = ["Wholesale"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("qty_min_fmt", type: .scalar(String.self)),
              ]

              public var snapshot: Snapshot

              public init(snapshot: Snapshot) {
                self.snapshot = snapshot
              }

              public init(qtyMinFmt: String? = nil) {
                self.init(snapshot: ["__typename": "Wholesale", "qty_min_fmt": qtyMinFmt])
              }

              public var __typename: String {
                get {
                  return snapshot["__typename"]! as! String
                }
                set {
                  snapshot.updateValue(newValue, forKey: "__typename")
                }
              }

              public var qtyMinFmt: String? {
                get {
                  return snapshot["qty_min_fmt"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "qty_min_fmt")
                }
              }
            }
          }

          public struct Promotion: GraphQLSelectionSet {
            public static let possibleTypes = ["FeedPromo"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
              GraphQLField("type", type: .nonNull(.scalar(String.self))),
              GraphQLField("thumbnail", type: .nonNull(.scalar(String.self))),
              GraphQLField("feature_image", type: .nonNull(.scalar(String.self))),
              GraphQLField("description", type: .nonNull(.scalar(String.self))),
              GraphQLField("periode", type: .nonNull(.scalar(String.self))),
              GraphQLField("code", type: .nonNull(.scalar(String.self))),
              GraphQLField("url", type: .nonNull(.scalar(String.self))),
              GraphQLField("min_transcation", type: .nonNull(.scalar(String.self))),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(id: GraphQLID, name: String, type: String, thumbnail: String, featureImage: String, description: String, periode: String, code: String, url: String, minTranscation: String) {
              self.init(snapshot: ["__typename": "FeedPromo", "id": id, "name": name, "type": type, "thumbnail": thumbnail, "feature_image": featureImage, "description": description, "periode": periode, "code": code, "url": url, "min_transcation": minTranscation])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID {
              get {
                return snapshot["id"]! as! GraphQLID
              }
              set {
                snapshot.updateValue(newValue, forKey: "id")
              }
            }

            public var name: String {
              get {
                return snapshot["name"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "name")
              }
            }

            public var type: String {
              get {
                return snapshot["type"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "type")
              }
            }

            public var thumbnail: String {
              get {
                return snapshot["thumbnail"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "thumbnail")
              }
            }

            public var featureImage: String {
              get {
                return snapshot["feature_image"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "feature_image")
              }
            }

            public var description: String {
              get {
                return snapshot["description"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "description")
              }
            }

            public var periode: String {
              get {
                return snapshot["periode"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "periode")
              }
            }

            public var code: String {
              get {
                return snapshot["code"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "code")
              }
            }

            public var url: String {
              get {
                return snapshot["url"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "url")
              }
            }

            public var minTranscation: String {
              get {
                return snapshot["min_transcation"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "min_transcation")
              }
            }
          }

          public struct NewStatusActivity: GraphQLSelectionSet {
            public static let possibleTypes = ["StatusActivity"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("source", type: .scalar(String.self)),
              GraphQLField("activity", type: .scalar(String.self)),
              GraphQLField("amount", type: .scalar(Int.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(source: String? = nil, activity: String? = nil, amount: Int? = nil) {
              self.init(snapshot: ["__typename": "StatusActivity", "source": source, "activity": activity, "amount": amount])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var source: String? {
              get {
                return snapshot["source"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "source")
              }
            }

            public var activity: String? {
              get {
                return snapshot["activity"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "activity")
              }
            }

            public var amount: Int? {
              get {
                return snapshot["amount"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "amount")
              }
            }
          }

          public struct TopPick: GraphQLSelectionSet {
            public static let possibleTypes = ["FeedToppick"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("url", type: .scalar(String.self)),
              GraphQLField("image_url", type: .scalar(String.self)),
              GraphQLField("image_landscape_url", type: .scalar(String.self)),
              GraphQLField("is_parent", type: .scalar(Bool.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(name: String? = nil, url: String? = nil, imageUrl: String? = nil, imageLandscapeUrl: String? = nil, isParent: Bool? = nil) {
              self.init(snapshot: ["__typename": "FeedToppick", "name": name, "url": url, "image_url": imageUrl, "image_landscape_url": imageLandscapeUrl, "is_parent": isParent])
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

            public var url: String? {
              get {
                return snapshot["url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "url")
              }
            }

            public var imageUrl: String? {
              get {
                return snapshot["image_url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "image_url")
              }
            }

            public var imageLandscapeUrl: String? {
              get {
                return snapshot["image_landscape_url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "image_landscape_url")
              }
            }

            public var isParent: Bool? {
              get {
                return snapshot["is_parent"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "is_parent")
              }
            }
          }

          public struct OfficialStore: GraphQLSelectionSet {
            public static let possibleTypes = ["FeedOfficialStore"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("shop_id", type: .scalar(Int.self)),
              GraphQLField("shop_apps_url", type: .scalar(String.self)),
              GraphQLField("shop_name", type: .scalar(String.self)),
              GraphQLField("logo_url", type: .scalar(String.self)),
              GraphQLField("microsite_url", type: .scalar(String.self)),
              GraphQLField("brand_img_url", type: .scalar(String.self)),
              GraphQLField("is_owner", type: .scalar(Bool.self)),
              GraphQLField("shop_tagline", type: .scalar(String.self)),
              GraphQLField("is_new", type: .scalar(Bool.self)),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("mobile_img_url", type: .scalar(String.self)),
              GraphQLField("feed_hexa_color", type: .scalar(String.self)),
              GraphQLField("redirect_url_app", type: .scalar(String.self)),
              GraphQLField("products", type: .list(.object(Product.self))),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(shopId: Int? = nil, shopAppsUrl: String? = nil, shopName: String? = nil, logoUrl: String? = nil, micrositeUrl: String? = nil, brandImgUrl: String? = nil, isOwner: Bool? = nil, shopTagline: String? = nil, isNew: Bool? = nil, title: String? = nil, mobileImgUrl: String? = nil, feedHexaColor: String? = nil, redirectUrlApp: String? = nil, products: [Product?]? = nil) {
              self.init(snapshot: ["__typename": "FeedOfficialStore", "shop_id": shopId, "shop_apps_url": shopAppsUrl, "shop_name": shopName, "logo_url": logoUrl, "microsite_url": micrositeUrl, "brand_img_url": brandImgUrl, "is_owner": isOwner, "shop_tagline": shopTagline, "is_new": isNew, "title": title, "mobile_img_url": mobileImgUrl, "feed_hexa_color": feedHexaColor, "redirect_url_app": redirectUrlApp, "products": products])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var shopId: Int? {
              get {
                return snapshot["shop_id"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shop_id")
              }
            }

            public var shopAppsUrl: String? {
              get {
                return snapshot["shop_apps_url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shop_apps_url")
              }
            }

            public var shopName: String? {
              get {
                return snapshot["shop_name"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shop_name")
              }
            }

            public var logoUrl: String? {
              get {
                return snapshot["logo_url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "logo_url")
              }
            }

            public var micrositeUrl: String? {
              get {
                return snapshot["microsite_url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "microsite_url")
              }
            }

            public var brandImgUrl: String? {
              get {
                return snapshot["brand_img_url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "brand_img_url")
              }
            }

            public var isOwner: Bool? {
              get {
                return snapshot["is_owner"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "is_owner")
              }
            }

            public var shopTagline: String? {
              get {
                return snapshot["shop_tagline"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "shop_tagline")
              }
            }

            public var isNew: Bool? {
              get {
                return snapshot["is_new"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "is_new")
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

            public var mobileImgUrl: String? {
              get {
                return snapshot["mobile_img_url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "mobile_img_url")
              }
            }

            public var feedHexaColor: String? {
              get {
                return snapshot["feed_hexa_color"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "feed_hexa_color")
              }
            }

            public var redirectUrlApp: String? {
              get {
                return snapshot["redirect_url_app"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "redirect_url_app")
              }
            }

            public var products: [Product?]? {
              get {
                return (snapshot["products"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Product(snapshot: $0) } } }
              }
              set {
                snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "products")
              }
            }

            public struct Product: GraphQLSelectionSet {
              public static let possibleTypes = ["ProductCampaignType"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("brand_id", type: .scalar(Int.self)),
                GraphQLField("brand_logo", type: .scalar(String.self)),
                GraphQLField("data", type: .object(Datum.self)),
              ]

              public var snapshot: Snapshot

              public init(snapshot: Snapshot) {
                self.snapshot = snapshot
              }

              public init(brandId: Int? = nil, brandLogo: String? = nil, data: Datum? = nil) {
                self.init(snapshot: ["__typename": "ProductCampaignType", "brand_id": brandId, "brand_logo": brandLogo, "data": data])
              }

              public var __typename: String {
                get {
                  return snapshot["__typename"]! as! String
                }
                set {
                  snapshot.updateValue(newValue, forKey: "__typename")
                }
              }

              public var brandId: Int? {
                get {
                  return snapshot["brand_id"]! as! Int?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "brand_id")
                }
              }

              public var brandLogo: String? {
                get {
                  return snapshot["brand_logo"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "brand_logo")
                }
              }

              public var data: Datum? {
                get {
                  return (snapshot["data"]! as! Snapshot?).flatMap { Datum(snapshot: $0) }
                }
                set {
                  snapshot.updateValue(newValue?.snapshot, forKey: "data")
                }
              }

              public struct Datum: GraphQLSelectionSet {
                public static let possibleTypes = ["BrandDataType"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("id", type: .scalar(Int.self)),
                  GraphQLField("name", type: .scalar(String.self)),
                  GraphQLField("url_app", type: .scalar(String.self)),
                  GraphQLField("image_url", type: .scalar(String.self)),
                  GraphQLField("image_url_700", type: .scalar(String.self)),
                  GraphQLField("price", type: .scalar(String.self)),
                  GraphQLField("shop", type: .object(Shop.self)),
                  GraphQLField("original_price", type: .scalar(String.self)),
                  GraphQLField("discount_percentage", type: .scalar(Int.self)),
                  GraphQLField("discount_expired", type: .scalar(String.self)),
                  GraphQLField("badges", type: .list(.object(Badge.self))),
                  GraphQLField("labels", type: .list(.object(Label.self))),
                ]

                public var snapshot: Snapshot

                public init(snapshot: Snapshot) {
                  self.snapshot = snapshot
                }

                public init(id: Int? = nil, name: String? = nil, urlApp: String? = nil, imageUrl: String? = nil, imageUrl_700: String? = nil, price: String? = nil, shop: Shop? = nil, originalPrice: String? = nil, discountPercentage: Int? = nil, discountExpired: String? = nil, badges: [Badge?]? = nil, labels: [Label?]? = nil) {
                  self.init(snapshot: ["__typename": "BrandDataType", "id": id, "name": name, "url_app": urlApp, "image_url": imageUrl, "image_url_700": imageUrl_700, "price": price, "shop": shop, "original_price": originalPrice, "discount_percentage": discountPercentage, "discount_expired": discountExpired, "badges": badges, "labels": labels])
                }

                public var __typename: String {
                  get {
                    return snapshot["__typename"]! as! String
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var id: Int? {
                  get {
                    return snapshot["id"]! as! Int?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "id")
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

                public var urlApp: String? {
                  get {
                    return snapshot["url_app"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "url_app")
                  }
                }

                public var imageUrl: String? {
                  get {
                    return snapshot["image_url"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "image_url")
                  }
                }

                public var imageUrl_700: String? {
                  get {
                    return snapshot["image_url_700"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "image_url_700")
                  }
                }

                public var price: String? {
                  get {
                    return snapshot["price"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "price")
                  }
                }

                public var shop: Shop? {
                  get {
                    return (snapshot["shop"]! as! Snapshot?).flatMap { Shop(snapshot: $0) }
                  }
                  set {
                    snapshot.updateValue(newValue?.snapshot, forKey: "shop")
                  }
                }

                public var originalPrice: String? {
                  get {
                    return snapshot["original_price"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "original_price")
                  }
                }

                public var discountPercentage: Int? {
                  get {
                    return snapshot["discount_percentage"]! as! Int?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "discount_percentage")
                  }
                }

                public var discountExpired: String? {
                  get {
                    return snapshot["discount_expired"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "discount_expired")
                  }
                }

                public var badges: [Badge?]? {
                  get {
                    return (snapshot["badges"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Badge(snapshot: $0) } } }
                  }
                  set {
                    snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "badges")
                  }
                }

                public var labels: [Label?]? {
                  get {
                    return (snapshot["labels"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Label(snapshot: $0) } } }
                  }
                  set {
                    snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "labels")
                  }
                }

                public struct Shop: GraphQLSelectionSet {
                  public static let possibleTypes = ["ProductCampaignShopType"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("name", type: .scalar(String.self)),
                    GraphQLField("url_app", type: .scalar(String.self)),
                    GraphQLField("location", type: .scalar(String.self)),
                  ]

                  public var snapshot: Snapshot

                  public init(snapshot: Snapshot) {
                    self.snapshot = snapshot
                  }

                  public init(name: String? = nil, urlApp: String? = nil, location: String? = nil) {
                    self.init(snapshot: ["__typename": "ProductCampaignShopType", "name": name, "url_app": urlApp, "location": location])
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

                  public var urlApp: String? {
                    get {
                      return snapshot["url_app"]! as! String?
                    }
                    set {
                      snapshot.updateValue(newValue, forKey: "url_app")
                    }
                  }

                  public var location: String? {
                    get {
                      return snapshot["location"]! as! String?
                    }
                    set {
                      snapshot.updateValue(newValue, forKey: "location")
                    }
                  }
                }

                public struct Badge: GraphQLSelectionSet {
                  public static let possibleTypes = ["Badge"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("title", type: .nonNull(.scalar(String.self))),
                    GraphQLField("image_url", type: .nonNull(.scalar(String.self))),
                  ]

                  public var snapshot: Snapshot

                  public init(snapshot: Snapshot) {
                    self.snapshot = snapshot
                  }

                  public init(title: String, imageUrl: String) {
                    self.init(snapshot: ["__typename": "Badge", "title": title, "image_url": imageUrl])
                  }

                  public var __typename: String {
                    get {
                      return snapshot["__typename"]! as! String
                    }
                    set {
                      snapshot.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var title: String {
                    get {
                      return snapshot["title"]! as! String
                    }
                    set {
                      snapshot.updateValue(newValue, forKey: "title")
                    }
                  }

                  public var imageUrl: String {
                    get {
                      return snapshot["image_url"]! as! String
                    }
                    set {
                      snapshot.updateValue(newValue, forKey: "image_url")
                    }
                  }
                }

                public struct Label: GraphQLSelectionSet {
                  public static let possibleTypes = ["Label"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("title", type: .nonNull(.scalar(String.self))),
                    GraphQLField("color", type: .nonNull(.scalar(String.self))),
                  ]

                  public var snapshot: Snapshot

                  public init(snapshot: Snapshot) {
                    self.snapshot = snapshot
                  }

                  public init(title: String, color: String) {
                    self.init(snapshot: ["__typename": "Label", "title": title, "color": color])
                  }

                  public var __typename: String {
                    get {
                      return snapshot["__typename"]! as! String
                    }
                    set {
                      snapshot.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var title: String {
                    get {
                      return snapshot["title"]! as! String
                    }
                    set {
                      snapshot.updateValue(newValue, forKey: "title")
                    }
                  }

                  public var color: String {
                    get {
                      return snapshot["color"]! as! String
                    }
                    set {
                      snapshot.updateValue(newValue, forKey: "color")
                    }
                  }
                }
              }
            }
          }

          public struct Inspirasi: GraphQLSelectionSet {
            public static let possibleTypes = ["FeedInpirationData"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("source", type: .scalar(String.self)),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("foreign_title", type: .scalar(String.self)),
              GraphQLField("pagination", type: .object(Pagination.self)),
              GraphQLField("recommendation", type: .list(.object(Recommendation.self))),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(source: String? = nil, title: String? = nil, foreignTitle: String? = nil, pagination: Pagination? = nil, recommendation: [Recommendation?]? = nil) {
              self.init(snapshot: ["__typename": "FeedInpirationData", "source": source, "title": title, "foreign_title": foreignTitle, "pagination": pagination, "recommendation": recommendation])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var source: String? {
              get {
                return snapshot["source"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "source")
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

            public var foreignTitle: String? {
              get {
                return snapshot["foreign_title"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "foreign_title")
              }
            }

            public var pagination: Pagination? {
              get {
                return (snapshot["pagination"]! as! Snapshot?).flatMap { Pagination(snapshot: $0) }
              }
              set {
                snapshot.updateValue(newValue?.snapshot, forKey: "pagination")
              }
            }

            public var recommendation: [Recommendation?]? {
              get {
                return (snapshot["recommendation"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Recommendation(snapshot: $0) } } }
              }
              set {
                snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "recommendation")
              }
            }

            public struct Pagination: GraphQLSelectionSet {
              public static let possibleTypes = ["FeedInspirationPagination"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("current_page", type: .scalar(Int.self)),
                GraphQLField("next_page", type: .scalar(Int.self)),
                GraphQLField("prev_page", type: .scalar(Int.self)),
              ]

              public var snapshot: Snapshot

              public init(snapshot: Snapshot) {
                self.snapshot = snapshot
              }

              public init(currentPage: Int? = nil, nextPage: Int? = nil, prevPage: Int? = nil) {
                self.init(snapshot: ["__typename": "FeedInspirationPagination", "current_page": currentPage, "next_page": nextPage, "prev_page": prevPage])
              }

              public var __typename: String {
                get {
                  return snapshot["__typename"]! as! String
                }
                set {
                  snapshot.updateValue(newValue, forKey: "__typename")
                }
              }

              public var currentPage: Int? {
                get {
                  return snapshot["current_page"]! as! Int?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "current_page")
                }
              }

              public var nextPage: Int? {
                get {
                  return snapshot["next_page"]! as! Int?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "next_page")
                }
              }

              public var prevPage: Int? {
                get {
                  return snapshot["prev_page"]! as! Int?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "prev_page")
                }
              }
            }

            public struct Recommendation: GraphQLSelectionSet {
              public static let possibleTypes = ["FeedInspirationItem"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .scalar(GraphQLID.self)),
                GraphQLField("name", type: .scalar(String.self)),
                GraphQLField("url", type: .scalar(String.self)),
                GraphQLField("click_url", type: .scalar(String.self)),
                GraphQLField("app_url", type: .scalar(String.self)),
                GraphQLField("image_url", type: .scalar(String.self)),
                GraphQLField("price", type: .scalar(String.self)),
                GraphQLField("price_int", type: .scalar(Int.self)),
                GraphQLField("recommendation_type", type: .scalar(String.self)),
              ]

              public var snapshot: Snapshot

              public init(snapshot: Snapshot) {
                self.snapshot = snapshot
              }

              public init(id: GraphQLID? = nil, name: String? = nil, url: String? = nil, clickUrl: String? = nil, appUrl: String? = nil, imageUrl: String? = nil, price: String? = nil, priceInt: Int? = nil, recommendationType: String? = nil) {
                self.init(snapshot: ["__typename": "FeedInspirationItem", "id": id, "name": name, "url": url, "click_url": clickUrl, "app_url": appUrl, "image_url": imageUrl, "price": price, "price_int": priceInt, "recommendation_type": recommendationType])
              }

              public var __typename: String {
                get {
                  return snapshot["__typename"]! as! String
                }
                set {
                  snapshot.updateValue(newValue, forKey: "__typename")
                }
              }

              public var id: GraphQLID? {
                get {
                  return snapshot["id"]! as! GraphQLID?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "id")
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

              public var url: String? {
                get {
                  return snapshot["url"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "url")
                }
              }

              public var clickUrl: String? {
                get {
                  return snapshot["click_url"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "click_url")
                }
              }

              public var appUrl: String? {
                get {
                  return snapshot["app_url"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "app_url")
                }
              }

              public var imageUrl: String? {
                get {
                  return snapshot["image_url"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "image_url")
                }
              }

              public var price: String? {
                get {
                  return snapshot["price"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "price")
                }
              }

              public var priceInt: Int? {
                get {
                  return snapshot["price_int"]! as! Int?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "price_int")
                }
              }

              public var recommendationType: String? {
                get {
                  return snapshot["recommendation_type"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "recommendation_type")
                }
              }
            }
          }

          public struct Kolpost: GraphQLSelectionSet {
            public static let possibleTypes = ["FeedKolType"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("headerTitle", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("commentCount", type: .scalar(Int.self)),
              GraphQLField("likeCount", type: .scalar(Int.self)),
              GraphQLField("showComment", type: .scalar(Bool.self)),
              GraphQLField("isLiked", type: .scalar(Bool.self)),
              GraphQLField("isFollowed", type: .scalar(Bool.self)),
              GraphQLField("createTime", type: .scalar(String.self)),
              GraphQLField("userId", type: .scalar(Int.self)),
              GraphQLField("userName", type: .scalar(String.self)),
              GraphQLField("userInfo", type: .scalar(String.self)),
              GraphQLField("userPhoto", type: .scalar(String.self)),
              GraphQLField("userUrl", type: .scalar(String.self)),
              GraphQLField("content", type: .list(.object(Content.self))),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(id: Int? = nil, headerTitle: String? = nil, description: String? = nil, commentCount: Int? = nil, likeCount: Int? = nil, showComment: Bool? = nil, isLiked: Bool? = nil, isFollowed: Bool? = nil, createTime: String? = nil, userId: Int? = nil, userName: String? = nil, userInfo: String? = nil, userPhoto: String? = nil, userUrl: String? = nil, content: [Content?]? = nil) {
              self.init(snapshot: ["__typename": "FeedKolType", "id": id, "headerTitle": headerTitle, "description": description, "commentCount": commentCount, "likeCount": likeCount, "showComment": showComment, "isLiked": isLiked, "isFollowed": isFollowed, "createTime": createTime, "userId": userId, "userName": userName, "userInfo": userInfo, "userPhoto": userPhoto, "userUrl": userUrl, "content": content])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: Int? {
              get {
                return snapshot["id"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "id")
              }
            }

            public var headerTitle: String? {
              get {
                return snapshot["headerTitle"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "headerTitle")
              }
            }

            public var description: String? {
              get {
                return snapshot["description"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "description")
              }
            }

            public var commentCount: Int? {
              get {
                return snapshot["commentCount"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "commentCount")
              }
            }

            public var likeCount: Int? {
              get {
                return snapshot["likeCount"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "likeCount")
              }
            }

            public var showComment: Bool? {
              get {
                return snapshot["showComment"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "showComment")
              }
            }

            public var isLiked: Bool? {
              get {
                return snapshot["isLiked"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "isLiked")
              }
            }

            public var isFollowed: Bool? {
              get {
                return snapshot["isFollowed"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "isFollowed")
              }
            }

            public var createTime: String? {
              get {
                return snapshot["createTime"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "createTime")
              }
            }

            public var userId: Int? {
              get {
                return snapshot["userId"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userId")
              }
            }

            public var userName: String? {
              get {
                return snapshot["userName"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userName")
              }
            }

            public var userInfo: String? {
              get {
                return snapshot["userInfo"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userInfo")
              }
            }

            public var userPhoto: String? {
              get {
                return snapshot["userPhoto"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userPhoto")
              }
            }

            public var userUrl: String? {
              get {
                return snapshot["userUrl"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userUrl")
              }
            }

            public var content: [Content?]? {
              get {
                return (snapshot["content"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Content(snapshot: $0) } } }
              }
              set {
                snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "content")
              }
            }

            public struct Content: GraphQLSelectionSet {
              public static let possibleTypes = ["contentFeedKol"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("imageurl", type: .scalar(String.self)),
                GraphQLField("tags", type: .list(.object(Tag.self))),
              ]

              public var snapshot: Snapshot

              public init(snapshot: Snapshot) {
                self.snapshot = snapshot
              }

              public init(imageurl: String? = nil, tags: [Tag?]? = nil) {
                self.init(snapshot: ["__typename": "contentFeedKol", "imageurl": imageurl, "tags": tags])
              }

              public var __typename: String {
                get {
                  return snapshot["__typename"]! as! String
                }
                set {
                  snapshot.updateValue(newValue, forKey: "__typename")
                }
              }

              public var imageurl: String? {
                get {
                  return snapshot["imageurl"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "imageurl")
                }
              }

              public var tags: [Tag?]? {
                get {
                  return (snapshot["tags"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Tag(snapshot: $0) } } }
                }
                set {
                  snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tags")
                }
              }

              public struct Tag: GraphQLSelectionSet {
                public static let possibleTypes = ["tagsFeedKol"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("id", type: .scalar(Int.self)),
                  GraphQLField("type", type: .scalar(String.self)),
                  GraphQLField("url", type: .scalar(String.self)),
                  GraphQLField("link", type: .scalar(String.self)),
                  GraphQLField("price", type: .scalar(String.self)),
                  GraphQLField("caption", type: .scalar(String.self)),
                ]

                public var snapshot: Snapshot

                public init(snapshot: Snapshot) {
                  self.snapshot = snapshot
                }

                public init(id: Int? = nil, type: String? = nil, url: String? = nil, link: String? = nil, price: String? = nil, caption: String? = nil) {
                  self.init(snapshot: ["__typename": "tagsFeedKol", "id": id, "type": type, "url": url, "link": link, "price": price, "caption": caption])
                }

                public var __typename: String {
                  get {
                    return snapshot["__typename"]! as! String
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var id: Int? {
                  get {
                    return snapshot["id"]! as! Int?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "id")
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

                public var url: String? {
                  get {
                    return snapshot["url"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "url")
                  }
                }

                public var link: String? {
                  get {
                    return snapshot["link"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "link")
                  }
                }

                public var price: String? {
                  get {
                    return snapshot["price"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "price")
                  }
                }

                public var caption: String? {
                  get {
                    return snapshot["caption"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "caption")
                  }
                }
              }
            }
          }

          public struct Followedkolpost: GraphQLSelectionSet {
            public static let possibleTypes = ["FeedKolType"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("headerTitle", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("commentCount", type: .scalar(Int.self)),
              GraphQLField("likeCount", type: .scalar(Int.self)),
              GraphQLField("showComment", type: .scalar(Bool.self)),
              GraphQLField("isLiked", type: .scalar(Bool.self)),
              GraphQLField("isFollowed", type: .scalar(Bool.self)),
              GraphQLField("createTime", type: .scalar(String.self)),
              GraphQLField("userId", type: .scalar(Int.self)),
              GraphQLField("userName", type: .scalar(String.self)),
              GraphQLField("userInfo", type: .scalar(String.self)),
              GraphQLField("userPhoto", type: .scalar(String.self)),
              GraphQLField("userUrl", type: .scalar(String.self)),
              GraphQLField("content", type: .list(.object(Content.self))),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(id: Int? = nil, headerTitle: String? = nil, description: String? = nil, commentCount: Int? = nil, likeCount: Int? = nil, showComment: Bool? = nil, isLiked: Bool? = nil, isFollowed: Bool? = nil, createTime: String? = nil, userId: Int? = nil, userName: String? = nil, userInfo: String? = nil, userPhoto: String? = nil, userUrl: String? = nil, content: [Content?]? = nil) {
              self.init(snapshot: ["__typename": "FeedKolType", "id": id, "headerTitle": headerTitle, "description": description, "commentCount": commentCount, "likeCount": likeCount, "showComment": showComment, "isLiked": isLiked, "isFollowed": isFollowed, "createTime": createTime, "userId": userId, "userName": userName, "userInfo": userInfo, "userPhoto": userPhoto, "userUrl": userUrl, "content": content])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: Int? {
              get {
                return snapshot["id"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "id")
              }
            }

            public var headerTitle: String? {
              get {
                return snapshot["headerTitle"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "headerTitle")
              }
            }

            public var description: String? {
              get {
                return snapshot["description"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "description")
              }
            }

            public var commentCount: Int? {
              get {
                return snapshot["commentCount"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "commentCount")
              }
            }

            public var likeCount: Int? {
              get {
                return snapshot["likeCount"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "likeCount")
              }
            }

            public var showComment: Bool? {
              get {
                return snapshot["showComment"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "showComment")
              }
            }

            public var isLiked: Bool? {
              get {
                return snapshot["isLiked"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "isLiked")
              }
            }

            public var isFollowed: Bool? {
              get {
                return snapshot["isFollowed"]! as! Bool?
              }
              set {
                snapshot.updateValue(newValue, forKey: "isFollowed")
              }
            }

            public var createTime: String? {
              get {
                return snapshot["createTime"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "createTime")
              }
            }

            public var userId: Int? {
              get {
                return snapshot["userId"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userId")
              }
            }

            public var userName: String? {
              get {
                return snapshot["userName"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userName")
              }
            }

            public var userInfo: String? {
              get {
                return snapshot["userInfo"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userInfo")
              }
            }

            public var userPhoto: String? {
              get {
                return snapshot["userPhoto"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userPhoto")
              }
            }

            public var userUrl: String? {
              get {
                return snapshot["userUrl"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "userUrl")
              }
            }

            public var content: [Content?]? {
              get {
                return (snapshot["content"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Content(snapshot: $0) } } }
              }
              set {
                snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "content")
              }
            }

            public struct Content: GraphQLSelectionSet {
              public static let possibleTypes = ["contentFeedKol"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("imageurl", type: .scalar(String.self)),
                GraphQLField("tags", type: .list(.object(Tag.self))),
              ]

              public var snapshot: Snapshot

              public init(snapshot: Snapshot) {
                self.snapshot = snapshot
              }

              public init(imageurl: String? = nil, tags: [Tag?]? = nil) {
                self.init(snapshot: ["__typename": "contentFeedKol", "imageurl": imageurl, "tags": tags])
              }

              public var __typename: String {
                get {
                  return snapshot["__typename"]! as! String
                }
                set {
                  snapshot.updateValue(newValue, forKey: "__typename")
                }
              }

              public var imageurl: String? {
                get {
                  return snapshot["imageurl"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "imageurl")
                }
              }

              public var tags: [Tag?]? {
                get {
                  return (snapshot["tags"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Tag(snapshot: $0) } } }
                }
                set {
                  snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tags")
                }
              }

              public struct Tag: GraphQLSelectionSet {
                public static let possibleTypes = ["tagsFeedKol"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("id", type: .scalar(Int.self)),
                  GraphQLField("type", type: .scalar(String.self)),
                  GraphQLField("url", type: .scalar(String.self)),
                  GraphQLField("link", type: .scalar(String.self)),
                  GraphQLField("price", type: .scalar(String.self)),
                  GraphQLField("caption", type: .scalar(String.self)),
                ]

                public var snapshot: Snapshot

                public init(snapshot: Snapshot) {
                  self.snapshot = snapshot
                }

                public init(id: Int? = nil, type: String? = nil, url: String? = nil, link: String? = nil, price: String? = nil, caption: String? = nil) {
                  self.init(snapshot: ["__typename": "tagsFeedKol", "id": id, "type": type, "url": url, "link": link, "price": price, "caption": caption])
                }

                public var __typename: String {
                  get {
                    return snapshot["__typename"]! as! String
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var id: Int? {
                  get {
                    return snapshot["id"]! as! Int?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "id")
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

                public var url: String? {
                  get {
                    return snapshot["url"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "url")
                  }
                }

                public var link: String? {
                  get {
                    return snapshot["link"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "link")
                  }
                }

                public var price: String? {
                  get {
                    return snapshot["price"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "price")
                  }
                }

                public var caption: String? {
                  get {
                    return snapshot["caption"]! as! String?
                  }
                  set {
                    snapshot.updateValue(newValue, forKey: "caption")
                  }
                }
              }
            }
          }

          public struct Kolrecommendation: GraphQLSelectionSet {
            public static let possibleTypes = ["KolRecommendedDataType"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("index", type: .scalar(Int.self)),
              GraphQLField("headerTitle", type: .scalar(String.self)),
              GraphQLField("exploreLink", type: .scalar(String.self)),
              GraphQLField("kols", type: .list(.object(Kol.self))),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(index: Int? = nil, headerTitle: String? = nil, exploreLink: String? = nil, kols: [Kol?]? = nil) {
              self.init(snapshot: ["__typename": "KolRecommendedDataType", "index": index, "headerTitle": headerTitle, "exploreLink": exploreLink, "kols": kols])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var index: Int? {
              get {
                return snapshot["index"]! as! Int?
              }
              set {
                snapshot.updateValue(newValue, forKey: "index")
              }
            }

            public var headerTitle: String? {
              get {
                return snapshot["headerTitle"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "headerTitle")
              }
            }

            public var exploreLink: String? {
              get {
                return snapshot["exploreLink"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "exploreLink")
              }
            }

            public var kols: [Kol?]? {
              get {
                return (snapshot["kols"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Kol(snapshot: $0) } } }
              }
              set {
                snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "kols")
              }
            }

            public struct Kol: GraphQLSelectionSet {
              public static let possibleTypes = ["FeedKolRecommendedType"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("userName", type: .scalar(String.self)),
                GraphQLField("userId", type: .scalar(Int.self)),
                GraphQLField("userPhoto", type: .scalar(String.self)),
                GraphQLField("isFollowed", type: .scalar(Bool.self)),
                GraphQLField("info", type: .scalar(String.self)),
                GraphQLField("url", type: .scalar(String.self)),
              ]

              public var snapshot: Snapshot

              public init(snapshot: Snapshot) {
                self.snapshot = snapshot
              }

              public init(userName: String? = nil, userId: Int? = nil, userPhoto: String? = nil, isFollowed: Bool? = nil, info: String? = nil, url: String? = nil) {
                self.init(snapshot: ["__typename": "FeedKolRecommendedType", "userName": userName, "userId": userId, "userPhoto": userPhoto, "isFollowed": isFollowed, "info": info, "url": url])
              }

              public var __typename: String {
                get {
                  return snapshot["__typename"]! as! String
                }
                set {
                  snapshot.updateValue(newValue, forKey: "__typename")
                }
              }

              public var userName: String? {
                get {
                  return snapshot["userName"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "userName")
                }
              }

              public var userId: Int? {
                get {
                  return snapshot["userId"]! as! Int?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "userId")
                }
              }

              public var userPhoto: String? {
                get {
                  return snapshot["userPhoto"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "userPhoto")
                }
              }

              public var isFollowed: Bool? {
                get {
                  return snapshot["isFollowed"]! as! Bool?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "isFollowed")
                }
              }

              public var info: String? {
                get {
                  return snapshot["info"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "info")
                }
              }

              public var url: String? {
                get {
                  return snapshot["url"]! as! String?
                }
                set {
                  snapshot.updateValue(newValue, forKey: "url")
                }
              }
            }
          }

          public struct FavoriteCtum: GraphQLSelectionSet {
            public static let possibleTypes = ["FeedsFavoriteCta"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("title_id", type: .scalar(String.self)),
              GraphQLField("subtitle_id", type: .scalar(String.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(titleId: String? = nil, subtitleId: String? = nil) {
              self.init(snapshot: ["__typename": "FeedsFavoriteCta", "title_id": titleId, "subtitle_id": subtitleId])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var titleId: String? {
              get {
                return snapshot["title_id"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "title_id")
              }
            }

            public var subtitleId: String? {
              get {
                return snapshot["subtitle_id"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "subtitle_id")
              }
            }
          }

          public struct KolCtum: GraphQLSelectionSet {
            public static let possibleTypes = ["FeedsKolCta"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("img_header", type: .scalar(String.self)),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("subtitle", type: .scalar(String.self)),
              GraphQLField("button_text", type: .scalar(String.self)),
              GraphQLField("click_url", type: .scalar(String.self)),
              GraphQLField("click_applink", type: .scalar(String.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(imgHeader: String? = nil, title: String? = nil, subtitle: String? = nil, buttonText: String? = nil, clickUrl: String? = nil, clickApplink: String? = nil) {
              self.init(snapshot: ["__typename": "FeedsKolCta", "img_header": imgHeader, "title": title, "subtitle": subtitle, "button_text": buttonText, "click_url": clickUrl, "click_applink": clickApplink])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            public var imgHeader: String? {
              get {
                return snapshot["img_header"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "img_header")
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

            public var subtitle: String? {
              get {
                return snapshot["subtitle"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "subtitle")
              }
            }

            public var buttonText: String? {
              get {
                return snapshot["button_text"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "button_text")
              }
            }

            public var clickUrl: String? {
              get {
                return snapshot["click_url"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "click_url")
              }
            }

            public var clickApplink: String? {
              get {
                return snapshot["click_applink"]! as! String?
              }
              set {
                snapshot.updateValue(newValue, forKey: "click_applink")
              }
            }
          }
        }
      }

      public struct Link: GraphQLSelectionSet {
        public static let possibleTypes = ["links"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("pagination", type: .object(Pagination.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(pagination: Pagination? = nil) {
          self.init(snapshot: ["__typename": "links", "pagination": pagination])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var pagination: Pagination? {
          get {
            return (snapshot["pagination"]! as! Snapshot?).flatMap { Pagination(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "pagination")
          }
        }

        public struct Pagination: GraphQLSelectionSet {
          public static let possibleTypes = ["feedpagination"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("has_next_page", type: .scalar(Bool.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(hasNextPage: Bool? = nil) {
            self.init(snapshot: ["__typename": "feedpagination", "has_next_page": hasNextPage])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var hasNextPage: Bool? {
            get {
              return snapshot["has_next_page"]! as! Bool?
            }
            set {
              snapshot.updateValue(newValue, forKey: "has_next_page")
            }
          }
        }
      }

      public struct Metum: GraphQLSelectionSet {
        public static let possibleTypes = ["feedTotalData"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("total_data", type: .scalar(Int.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(totalData: Int? = nil) {
          self.init(snapshot: ["__typename": "feedTotalData", "total_data": totalData])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var totalData: Int? {
          get {
            return snapshot["total_data"]! as! Int?
          }
          set {
            snapshot.updateValue(newValue, forKey: "total_data")
          }
        }
      }
    }
  }
}

public final class DoLikeKolPostMutation: GraphQLMutation {
  public static let operationString =
    "mutation DoLikeKOLPost($idPost: Int!, $action: Int!) {" +
    "  do_like_kol_post(idPost: $idPost, action: $action) {" +
    "    __typename" +
    "    error" +
    "    data {" +
    "      __typename" +
    "      success" +
    "    }" +
    "  }" +
    "}"

  public var idPost: Int
  public var action: Int

  public init(idPost: Int, action: Int) {
    self.idPost = idPost
    self.action = action
  }

  public var variables: GraphQLMap? {
    return ["idPost": idPost, "action": action]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("do_like_kol_post", arguments: ["idPost": Variable("idPost"), "action": Variable("action")], type: .object(DoLikeKolPost.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(doLikeKolPost: DoLikeKolPost? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "do_like_kol_post": doLikeKolPost])
    }

    public var doLikeKolPost: DoLikeKolPost? {
      get {
        return (snapshot["do_like_kol_post"]! as! Snapshot?).flatMap { DoLikeKolPost(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "do_like_kol_post")
      }
    }

    public struct DoLikeKolPost: GraphQLSelectionSet {
      public static let possibleTypes = ["DoLikePostType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("error", type: .scalar(String.self)),
        GraphQLField("data", type: .object(Datum.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(error: String? = nil, data: Datum? = nil) {
        self.init(snapshot: ["__typename": "DoLikePostType", "error": error, "data": data])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var error: String? {
        get {
          return snapshot["error"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "error")
        }
      }

      public var data: Datum? {
        get {
          return (snapshot["data"]! as! Snapshot?).flatMap { Datum(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "data")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes = ["DataLikePostType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("success", type: .scalar(Int.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(success: Int? = nil) {
          self.init(snapshot: ["__typename": "DataLikePostType", "success": success])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var success: Int? {
          get {
            return snapshot["success"]! as! Int?
          }
          set {
            snapshot.updateValue(newValue, forKey: "success")
          }
        }
      }
    }
  }
}

public final class DoFollowKolMutation: GraphQLMutation {
  public static let operationString =
    "mutation DoFollowKOL($userID: Int!, $action: Int!) {" +
    "  do_follow_kol(userID: $userID, action: $action) {" +
    "    __typename" +
    "    error" +
    "    data {" +
    "      __typename" +
    "      status" +
    "    }" +
    "  }" +
    "}"

  public var userID: Int
  public var action: Int

  public init(userID: Int, action: Int) {
    self.userID = userID
    self.action = action
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "action": action]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("do_follow_kol", arguments: ["userID": Variable("userID"), "action": Variable("action")], type: .object(DoFollowKol.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(doFollowKol: DoFollowKol? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "do_follow_kol": doFollowKol])
    }

    public var doFollowKol: DoFollowKol? {
      get {
        return (snapshot["do_follow_kol"]! as! Snapshot?).flatMap { DoFollowKol(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "do_follow_kol")
      }
    }

    public struct DoFollowKol: GraphQLSelectionSet {
      public static let possibleTypes = ["FollowerType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("error", type: .scalar(String.self)),
        GraphQLField("data", type: .object(Datum.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(error: String? = nil, data: Datum? = nil) {
        self.init(snapshot: ["__typename": "FollowerType", "error": error, "data": data])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var error: String? {
        get {
          return snapshot["error"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "error")
        }
      }

      public var data: Datum? {
        get {
          return (snapshot["data"]! as! Snapshot?).flatMap { Datum(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "data")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes = ["DataFollowerType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("status", type: .scalar(Int.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(status: Int? = nil) {
          self.init(snapshot: ["__typename": "DataFollowerType", "status": status])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var status: Int? {
          get {
            return snapshot["status"]! as! Int?
          }
          set {
            snapshot.updateValue(newValue, forKey: "status")
          }
        }
      }
    }
  }
}

public final class CreateCommentKolMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateCommentKOL($idPost: Int!, $comment: String) {" +
    "  create_comment_kol(idPost: $idPost, comment: $comment) {" +
    "    __typename" +
    "    error" +
    "    data {" +
    "      __typename" +
    "      id" +
    "      user {" +
    "        __typename" +
    "        iskol" +
    "        id" +
    "        name" +
    "        photo" +
    "      }" +
    "      comment" +
    "      create_time" +
    "    }" +
    "  }" +
    "}"

  public var idPost: Int
  public var comment: String?

  public init(idPost: Int, comment: String? = nil) {
    self.idPost = idPost
    self.comment = comment
  }

  public var variables: GraphQLMap? {
    return ["idPost": idPost, "comment": comment]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("create_comment_kol", arguments: ["idPost": Variable("idPost"), "comment": Variable("comment")], type: .object(CreateCommentKol.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createCommentKol: CreateCommentKol? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "create_comment_kol": createCommentKol])
    }

    public var createCommentKol: CreateCommentKol? {
      get {
        return (snapshot["create_comment_kol"]! as! Snapshot?).flatMap { CreateCommentKol(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "create_comment_kol")
      }
    }

    public struct CreateCommentKol: GraphQLSelectionSet {
      public static let possibleTypes = ["CreateCommentType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("error", type: .scalar(String.self)),
        GraphQLField("data", type: .object(Datum.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(error: String? = nil, data: Datum? = nil) {
        self.init(snapshot: ["__typename": "CreateCommentType", "error": error, "data": data])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var error: String? {
        get {
          return snapshot["error"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "error")
        }
      }

      public var data: Datum? {
        get {
          return (snapshot["data"]! as! Snapshot?).flatMap { Datum(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "data")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes = ["DataCreateCommentType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(Int.self)),
          GraphQLField("user", type: .object(User.self)),
          GraphQLField("comment", type: .scalar(String.self)),
          GraphQLField("create_time", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: Int? = nil, user: User? = nil, comment: String? = nil, createTime: String? = nil) {
          self.init(snapshot: ["__typename": "DataCreateCommentType", "id": id, "user": user, "comment": comment, "create_time": createTime])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: Int? {
          get {
            return snapshot["id"]! as! Int?
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var user: User? {
          get {
            return (snapshot["user"]! as! Snapshot?).flatMap { User(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "user")
          }
        }

        public var comment: String? {
          get {
            return snapshot["comment"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "comment")
          }
        }

        public var createTime: String? {
          get {
            return snapshot["create_time"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "create_time")
          }
        }

        public struct User: GraphQLSelectionSet {
          public static let possibleTypes = ["UserCreateCommentType"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("iskol", type: .scalar(Bool.self)),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("photo", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(iskol: Bool? = nil, id: Int? = nil, name: String? = nil, photo: String? = nil) {
            self.init(snapshot: ["__typename": "UserCreateCommentType", "iskol": iskol, "id": id, "name": name, "photo": photo])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var iskol: Bool? {
            get {
              return snapshot["iskol"]! as! Bool?
            }
            set {
              snapshot.updateValue(newValue, forKey: "iskol")
            }
          }

          public var id: Int? {
            get {
              return snapshot["id"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
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

          public var photo: String? {
            get {
              return snapshot["photo"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "photo")
            }
          }
        }
      }
    }
  }
}

public final class GetKolListCommentQuery: GraphQLQuery {
  public static let operationString =
    "query GetKOLListComment($idPost: Int!, $cursor: String, $limit: Int!) {" +
    "  get_kol_list_comment(idPost: $idPost, cursor: $cursor, limit: $limit) {" +
    "    __typename" +
    "    error" +
    "    data {" +
    "      __typename" +
    "      lastcursor" +
    "      total_data" +
    "      comment {" +
    "        __typename" +
    "        id" +
    "        userID" +
    "        userName" +
    "        userPhoto" +
    "        isKol" +
    "        comment" +
    "      }" +
    "    }" +
    "  }" +
    "}"

  public var idPost: Int
  public var cursor: String?
  public var limit: Int

  public init(idPost: Int, cursor: String? = nil, limit: Int) {
    self.idPost = idPost
    self.cursor = cursor
    self.limit = limit
  }

  public var variables: GraphQLMap? {
    return ["idPost": idPost, "cursor": cursor, "limit": limit]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("get_kol_list_comment", arguments: ["idPost": Variable("idPost"), "cursor": Variable("cursor"), "limit": Variable("limit")], type: .object(GetKolListComment.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getKolListComment: GetKolListComment? = nil) {
      self.init(snapshot: ["__typename": "Query", "get_kol_list_comment": getKolListComment])
    }

    public var getKolListComment: GetKolListComment? {
      get {
        return (snapshot["get_kol_list_comment"]! as! Snapshot?).flatMap { GetKolListComment(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "get_kol_list_comment")
      }
    }

    public struct GetKolListComment: GraphQLSelectionSet {
      public static let possibleTypes = ["ListCommentType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("error", type: .scalar(String.self)),
        GraphQLField("data", type: .object(Datum.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(error: String? = nil, data: Datum? = nil) {
        self.init(snapshot: ["__typename": "ListCommentType", "error": error, "data": data])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var error: String? {
        get {
          return snapshot["error"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "error")
        }
      }

      public var data: Datum? {
        get {
          return (snapshot["data"]! as! Snapshot?).flatMap { Datum(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "data")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes = ["DataCommentType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("lastcursor", type: .scalar(String.self)),
          GraphQLField("total_data", type: .scalar(Int.self)),
          GraphQLField("comment", type: .list(.object(Comment.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(lastcursor: String? = nil, totalData: Int? = nil, comment: [Comment?]? = nil) {
          self.init(snapshot: ["__typename": "DataCommentType", "lastcursor": lastcursor, "total_data": totalData, "comment": comment])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var lastcursor: String? {
          get {
            return snapshot["lastcursor"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "lastcursor")
          }
        }

        public var totalData: Int? {
          get {
            return snapshot["total_data"]! as! Int?
          }
          set {
            snapshot.updateValue(newValue, forKey: "total_data")
          }
        }

        public var comment: [Comment?]? {
          get {
            return (snapshot["comment"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Comment(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "comment")
          }
        }

        public struct Comment: GraphQLSelectionSet {
          public static let possibleTypes = ["CommentDetailType"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("userID", type: .scalar(Int.self)),
            GraphQLField("userName", type: .scalar(String.self)),
            GraphQLField("userPhoto", type: .scalar(String.self)),
            GraphQLField("isKol", type: .scalar(Bool.self)),
            GraphQLField("comment", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: Int? = nil, userId: Int? = nil, userName: String? = nil, userPhoto: String? = nil, isKol: Bool? = nil, comment: String? = nil) {
            self.init(snapshot: ["__typename": "CommentDetailType", "id": id, "userID": userId, "userName": userName, "userPhoto": userPhoto, "isKol": isKol, "comment": comment])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: Int? {
            get {
              return snapshot["id"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var userId: Int? {
            get {
              return snapshot["userID"]! as! Int?
            }
            set {
              snapshot.updateValue(newValue, forKey: "userID")
            }
          }

          public var userName: String? {
            get {
              return snapshot["userName"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "userName")
            }
          }

          public var userPhoto: String? {
            get {
              return snapshot["userPhoto"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "userPhoto")
            }
          }

          public var isKol: Bool? {
            get {
              return snapshot["isKol"]! as! Bool?
            }
            set {
              snapshot.updateValue(newValue, forKey: "isKol")
            }
          }

          public var comment: String? {
            get {
              return snapshot["comment"]! as! String?
            }
            set {
              snapshot.updateValue(newValue, forKey: "comment")
            }
          }
        }
      }
    }
  }
}

public final class MoEngageQuery: GraphQLQuery {
  public static let operationString =
    "query MoEngage($userID: Int!) {" +
    "  shopInfoMoengage(userID: $userID) {" +
    "    __typename" +
    "    info {" +
    "      __typename" +
    "      date_shop_created" +
    "      shop_id" +
    "      shop_location" +
    "      shop_name" +
    "      shop_score" +
    "      total_active_product" +
    "    }" +
    "    owner {" +
    "      __typename" +
    "      is_gold_merchant" +
    "      is_seller" +
    "    }" +
    "    stats {" +
    "      __typename" +
    "      shop_total_transaction" +
    "      shop_item_sold" +
    "    }" +
    "  }" +
    "  profile {" +
    "    __typename" +
    "    user_id" +
    "    first_name" +
    "    full_name" +
    "    email" +
    "    gender" +
    "    bday" +
    "    age" +
    "    phone" +
    "    phone_verified" +
    "    register_date" +
    "  }" +
    "  address {" +
    "    __typename" +
    "    addresses {" +
    "      __typename" +
    "      city_name" +
    "      province_name" +
    "    }" +
    "  }" +
    "  wallet {" +
    "    __typename" +
    "    linked" +
    "    balance" +
    "    rawBalance" +
    "    errors {" +
    "      __typename" +
    "      name" +
    "      message" +
    "    }" +
    "  }" +
    "  saldo {" +
    "    __typename" +
    "    deposit_fmt" +
    "    deposit" +
    "  }" +
    "  paymentAdminProfile {" +
    "    __typename" +
    "    is_purchased_marketplace" +
    "    is_purchased_digital" +
    "    is_purchased_ticket" +
    "    last_purchase_date" +
    "  }" +
    "  topadsDeposit(userID: $userID) {" +
    "    __typename" +
    "    topads_amount" +
    "    is_topads_user" +
    "  }" +
    "}"

  public var userID: Int

  public init(userID: Int) {
    self.userID = userID
  }

  public var variables: GraphQLMap? {
    return ["userID": userID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("shopInfoMoengage", arguments: ["userID": Variable("userID")], type: .object(ShopInfoMoengage.self)),
      GraphQLField("profile", type: .object(Profile.self)),
      GraphQLField("address", type: .object(Address.self)),
      GraphQLField("wallet", type: .object(Wallet.self)),
      GraphQLField("saldo", type: .object(Saldo.self)),
      GraphQLField("paymentAdminProfile", type: .object(PaymentAdminProfile.self)),
      GraphQLField("topadsDeposit", arguments: ["userID": Variable("userID")], type: .object(TopadsDeposit.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(shopInfoMoengage: ShopInfoMoengage? = nil, profile: Profile? = nil, address: Address? = nil, wallet: Wallet? = nil, saldo: Saldo? = nil, paymentAdminProfile: PaymentAdminProfile? = nil, topadsDeposit: TopadsDeposit? = nil) {
      self.init(snapshot: ["__typename": "Query", "shopInfoMoengage": shopInfoMoengage, "profile": profile, "address": address, "wallet": wallet, "saldo": saldo, "paymentAdminProfile": paymentAdminProfile, "topadsDeposit": topadsDeposit])
    }

    public var shopInfoMoengage: ShopInfoMoengage? {
      get {
        return (snapshot["shopInfoMoengage"]! as! Snapshot?).flatMap { ShopInfoMoengage(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "shopInfoMoengage")
      }
    }

    public var profile: Profile? {
      get {
        return (snapshot["profile"]! as! Snapshot?).flatMap { Profile(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "profile")
      }
    }

    public var address: Address? {
      get {
        return (snapshot["address"]! as! Snapshot?).flatMap { Address(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "address")
      }
    }

    public var wallet: Wallet? {
      get {
        return (snapshot["wallet"]! as! Snapshot?).flatMap { Wallet(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "wallet")
      }
    }

    public var saldo: Saldo? {
      get {
        return (snapshot["saldo"]! as! Snapshot?).flatMap { Saldo(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "saldo")
      }
    }

    public var paymentAdminProfile: PaymentAdminProfile? {
      get {
        return (snapshot["paymentAdminProfile"]! as! Snapshot?).flatMap { PaymentAdminProfile(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "paymentAdminProfile")
      }
    }

    public var topadsDeposit: TopadsDeposit? {
      get {
        return (snapshot["topadsDeposit"]! as! Snapshot?).flatMap { TopadsDeposit(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "topadsDeposit")
      }
    }

    public struct ShopInfoMoengage: GraphQLSelectionSet {
      public static let possibleTypes = ["ShopInfoDataMoengage"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("info", type: .object(Info.self)),
        GraphQLField("owner", type: .object(Owner.self)),
        GraphQLField("stats", type: .object(Stat.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(info: Info? = nil, owner: Owner? = nil, stats: Stat? = nil) {
        self.init(snapshot: ["__typename": "ShopInfoDataMoengage", "info": info, "owner": owner, "stats": stats])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var info: Info? {
        get {
          return (snapshot["info"]! as! Snapshot?).flatMap { Info(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "info")
        }
      }

      public var owner: Owner? {
        get {
          return (snapshot["owner"]! as! Snapshot?).flatMap { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "owner")
        }
      }

      public var stats: Stat? {
        get {
          return (snapshot["stats"]! as! Snapshot?).flatMap { Stat(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "stats")
        }
      }

      public struct Info: GraphQLSelectionSet {
        public static let possibleTypes = ["ShopInfoInfoMoengage"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("date_shop_created", type: .nonNull(.scalar(String.self))),
          GraphQLField("shop_id", type: .nonNull(.scalar(String.self))),
          GraphQLField("shop_location", type: .nonNull(.scalar(String.self))),
          GraphQLField("shop_name", type: .nonNull(.scalar(String.self))),
          GraphQLField("shop_score", type: .nonNull(.scalar(Int.self))),
          GraphQLField("total_active_product", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(dateShopCreated: String, shopId: String, shopLocation: String, shopName: String, shopScore: Int, totalActiveProduct: Int) {
          self.init(snapshot: ["__typename": "ShopInfoInfoMoengage", "date_shop_created": dateShopCreated, "shop_id": shopId, "shop_location": shopLocation, "shop_name": shopName, "shop_score": shopScore, "total_active_product": totalActiveProduct])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var dateShopCreated: String {
          get {
            return snapshot["date_shop_created"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "date_shop_created")
          }
        }

        public var shopId: String {
          get {
            return snapshot["shop_id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "shop_id")
          }
        }

        public var shopLocation: String {
          get {
            return snapshot["shop_location"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "shop_location")
          }
        }

        public var shopName: String {
          get {
            return snapshot["shop_name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "shop_name")
          }
        }

        public var shopScore: Int {
          get {
            return snapshot["shop_score"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "shop_score")
          }
        }

        public var totalActiveProduct: Int {
          get {
            return snapshot["total_active_product"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "total_active_product")
          }
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["ShopInfoOwnerMoengage"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("is_gold_merchant", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("is_seller", type: .nonNull(.scalar(Bool.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(isGoldMerchant: Bool, isSeller: Bool) {
          self.init(snapshot: ["__typename": "ShopInfoOwnerMoengage", "is_gold_merchant": isGoldMerchant, "is_seller": isSeller])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var isGoldMerchant: Bool {
          get {
            return snapshot["is_gold_merchant"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "is_gold_merchant")
          }
        }

        public var isSeller: Bool {
          get {
            return snapshot["is_seller"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "is_seller")
          }
        }
      }

      public struct Stat: GraphQLSelectionSet {
        public static let possibleTypes = ["ShopInfoStatsMoengage"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("shop_total_transaction", type: .nonNull(.scalar(String.self))),
          GraphQLField("shop_item_sold", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(shopTotalTransaction: String, shopItemSold: String) {
          self.init(snapshot: ["__typename": "ShopInfoStatsMoengage", "shop_total_transaction": shopTotalTransaction, "shop_item_sold": shopItemSold])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var shopTotalTransaction: String {
          get {
            return snapshot["shop_total_transaction"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "shop_total_transaction")
          }
        }

        public var shopItemSold: String {
          get {
            return snapshot["shop_item_sold"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "shop_item_sold")
          }
        }
      }
    }

    public struct Profile: GraphQLSelectionSet {
      public static let possibleTypes = ["Profile"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("user_id", type: .scalar(String.self)),
        GraphQLField("first_name", type: .scalar(String.self)),
        GraphQLField("full_name", type: .scalar(String.self)),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("gender", type: .scalar(String.self)),
        GraphQLField("bday", type: .scalar(String.self)),
        GraphQLField("age", type: .scalar(String.self)),
        GraphQLField("phone", type: .scalar(String.self)),
        GraphQLField("phone_verified", type: .scalar(Bool.self)),
        GraphQLField("register_date", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(userId: String? = nil, firstName: String? = nil, fullName: String? = nil, email: String? = nil, gender: String? = nil, bday: String? = nil, age: String? = nil, phone: String? = nil, phoneVerified: Bool? = nil, registerDate: String? = nil) {
        self.init(snapshot: ["__typename": "Profile", "user_id": userId, "first_name": firstName, "full_name": fullName, "email": email, "gender": gender, "bday": bday, "age": age, "phone": phone, "phone_verified": phoneVerified, "register_date": registerDate])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var userId: String? {
        get {
          return snapshot["user_id"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "user_id")
        }
      }

      public var firstName: String? {
        get {
          return snapshot["first_name"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "first_name")
        }
      }

      public var fullName: String? {
        get {
          return snapshot["full_name"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "full_name")
        }
      }

      public var email: String? {
        get {
          return snapshot["email"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "email")
        }
      }

      public var gender: String? {
        get {
          return snapshot["gender"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "gender")
        }
      }

      public var bday: String? {
        get {
          return snapshot["bday"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "bday")
        }
      }

      public var age: String? {
        get {
          return snapshot["age"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "age")
        }
      }

      public var phone: String? {
        get {
          return snapshot["phone"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "phone")
        }
      }

      public var phoneVerified: Bool? {
        get {
          return snapshot["phone_verified"]! as! Bool?
        }
        set {
          snapshot.updateValue(newValue, forKey: "phone_verified")
        }
      }

      public var registerDate: String? {
        get {
          return snapshot["register_date"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "register_date")
        }
      }
    }

    public struct Address: GraphQLSelectionSet {
      public static let possibleTypes = ["Addresses"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("addresses", type: .list(.object(Address.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(addresses: [Address?]? = nil) {
        self.init(snapshot: ["__typename": "Addresses", "addresses": addresses])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var addresses: [Address?]? {
        get {
          return (snapshot["addresses"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Address(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "addresses")
        }
      }

      public struct Address: GraphQLSelectionSet {
        public static let possibleTypes = ["Address"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("city_name", type: .scalar(String.self)),
          GraphQLField("province_name", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cityName: String? = nil, provinceName: String? = nil) {
          self.init(snapshot: ["__typename": "Address", "city_name": cityName, "province_name": provinceName])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cityName: String? {
          get {
            return snapshot["city_name"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "city_name")
          }
        }

        public var provinceName: String? {
          get {
            return snapshot["province_name"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "province_name")
          }
        }
      }
    }

    public struct Wallet: GraphQLSelectionSet {
      public static let possibleTypes = ["Wallet"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("linked", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("balance", type: .nonNull(.scalar(String.self))),
        GraphQLField("rawBalance", type: .nonNull(.scalar(Int.self))),
        GraphQLField("errors", type: .list(.object(Error.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(linked: Bool, balance: String, rawBalance: Int, errors: [Error?]? = nil) {
        self.init(snapshot: ["__typename": "Wallet", "linked": linked, "balance": balance, "rawBalance": rawBalance, "errors": errors])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var linked: Bool {
        get {
          return snapshot["linked"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "linked")
        }
      }

      public var balance: String {
        get {
          return snapshot["balance"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "balance")
        }
      }

      public var rawBalance: Int {
        get {
          return snapshot["rawBalance"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rawBalance")
        }
      }

      public var errors: [Error?]? {
        get {
          return (snapshot["errors"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Error(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "errors")
        }
      }

      public struct Error: GraphQLSelectionSet {
        public static let possibleTypes = ["Error"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .scalar(String.self)),
          GraphQLField("message", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String? = nil, message: String? = nil) {
          self.init(snapshot: ["__typename": "Error", "name": name, "message": message])
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

        public var message: String? {
          get {
            return snapshot["message"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "message")
          }
        }
      }
    }

    public struct Saldo: GraphQLSelectionSet {
      public static let possibleTypes = ["Saldo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("deposit_fmt", type: .nonNull(.scalar(String.self))),
        GraphQLField("deposit", type: .nonNull(.scalar(Int.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(depositFmt: String, deposit: Int) {
        self.init(snapshot: ["__typename": "Saldo", "deposit_fmt": depositFmt, "deposit": deposit])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var depositFmt: String {
        get {
          return snapshot["deposit_fmt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "deposit_fmt")
        }
      }

      public var deposit: Int {
        get {
          return snapshot["deposit"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "deposit")
        }
      }
    }

    public struct PaymentAdminProfile: GraphQLSelectionSet {
      public static let possibleTypes = ["DataPaymentAdminProfiling"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("is_purchased_marketplace", type: .scalar(Bool.self)),
        GraphQLField("is_purchased_digital", type: .scalar(Bool.self)),
        GraphQLField("is_purchased_ticket", type: .scalar(Bool.self)),
        GraphQLField("last_purchase_date", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(isPurchasedMarketplace: Bool? = nil, isPurchasedDigital: Bool? = nil, isPurchasedTicket: Bool? = nil, lastPurchaseDate: String? = nil) {
        self.init(snapshot: ["__typename": "DataPaymentAdminProfiling", "is_purchased_marketplace": isPurchasedMarketplace, "is_purchased_digital": isPurchasedDigital, "is_purchased_ticket": isPurchasedTicket, "last_purchase_date": lastPurchaseDate])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var isPurchasedMarketplace: Bool? {
        get {
          return snapshot["is_purchased_marketplace"]! as! Bool?
        }
        set {
          snapshot.updateValue(newValue, forKey: "is_purchased_marketplace")
        }
      }

      public var isPurchasedDigital: Bool? {
        get {
          return snapshot["is_purchased_digital"]! as! Bool?
        }
        set {
          snapshot.updateValue(newValue, forKey: "is_purchased_digital")
        }
      }

      public var isPurchasedTicket: Bool? {
        get {
          return snapshot["is_purchased_ticket"]! as! Bool?
        }
        set {
          snapshot.updateValue(newValue, forKey: "is_purchased_ticket")
        }
      }

      public var lastPurchaseDate: String? {
        get {
          return snapshot["last_purchase_date"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "last_purchase_date")
        }
      }
    }

    public struct TopadsDeposit: GraphQLSelectionSet {
      public static let possibleTypes = ["TopadsDeposit"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("topads_amount", type: .scalar(Int.self)),
        GraphQLField("is_topads_user", type: .scalar(Bool.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(topadsAmount: Int? = nil, isTopadsUser: Bool? = nil) {
        self.init(snapshot: ["__typename": "TopadsDeposit", "topads_amount": topadsAmount, "is_topads_user": isTopadsUser])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var topadsAmount: Int? {
        get {
          return snapshot["topads_amount"]! as! Int?
        }
        set {
          snapshot.updateValue(newValue, forKey: "topads_amount")
        }
      }

      public var isTopadsUser: Bool? {
        get {
          return snapshot["is_topads_user"]! as! Bool?
        }
        set {
          snapshot.updateValue(newValue, forKey: "is_topads_user")
        }
      }
    }
  }
}
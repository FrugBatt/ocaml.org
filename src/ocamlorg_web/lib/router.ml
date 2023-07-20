open Ocamlorg

let asset_loader =
  Static.loader
    ~read:(fun _root path -> Ocamlorg_static.Asset.read path |> Lwt.return)
    ~digest:(fun _root path ->
      Option.map Dream.to_base64url (Ocamlorg_static.Asset.digest path))
    ~not_cached:[ "robots.txt"; "/robots.txt" ]

let media_loader =
  Static.loader
    ~read:(fun _root path -> Ocamlorg_static.Media.read path |> Lwt.return)
    ~digest:(fun _root path ->
      Option.map Dream.to_base64url @@ Ocamlorg_static.Media.digest path)

let playground_loader =
  Static.loader
    ~read:(fun _root path -> Ocamlorg_static.Playground.read path)
    ~digest:(fun _root path ->
      Option.map Dream.to_base64url @@ Ocamlorg_static.Playground.digest path)

let page_routes =
  Dream.scope ""
    [ Dream_dashboard.analytics (); Dream_encoding.compress ]
    [
      Dream.get Url.index Handler.index;
      Dream.get Url.install Handler.install;
      Dream.get Url.learn Handler.learn;
      Dream.get Url.learn_get_started Handler.learn_get_started;
      Dream.get Url.learn_language Handler.learn_language;
      Dream.get Url.learn_guides Handler.learn_guides;
      Dream.get Url.platform Handler.platform;
      Dream.get Url.community Handler.community;
      Dream.get Url.changelog Handler.changelog;
      Dream.get (Url.changelog_entry ":id") Handler.changelog_entry;
      Dream.get (Url.success_story ":id") Handler.success_story;
      Dream.get Url.industrial_users Handler.industrial_users;
      Dream.get Url.academic_users Handler.academic_users;
      Dream.get Url.about Handler.about;
      Dream.get Url.books Handler.books;
      Dream.get Url.releases Handler.releases;
      Dream.get (Url.release ":id") Handler.release;
      Dream.get (Url.workshop ":id") Handler.workshop;
      Dream.get Url.blog Handler.blog;
      Dream.get (Url.blog_post ":id") Handler.blog_post;
      Dream.get Url.news Handler.news;
      Dream.get (Url.news_post ":id") Handler.news_post;
      Dream.get Url.jobs Handler.jobs;
      Dream.get Url.outreachy Handler.outreachy;
      Dream.get Url.carbon_footprint Handler.carbon_footprint;
      Dream.get Url.privacy_policy Handler.privacy_policy;
      Dream.get Url.governance Handler.governance;
      Dream.get Url.code_of_conduct Handler.code_of_conduct;
      Dream.get Url.papers Handler.papers;
      Dream.get Url.problems Handler.problems;
      Dream.get (Url.tutorial ":id") Handler.tutorial;
      Dream.get Url.playground Handler.playground;
      Dream.get Url.installer Handler.installer;
    ]

let package_route t =
  Dream.scope ""
    [ Dream_dashboard.analytics (); Dream_encoding.compress ]
    [
      Dream.get Url.packages (Handler.packages t);
      Dream.get Url.packages_search (Handler.packages_search t);
      Dream.get Url.packages_autocomplete_fragment
        (Handler.packages_autocomplete_fragment t);
      Dream.get
        (Url.Package.overview ":name" ~version:":version")
        ((Handler.package_overview t) Handler.Package);
      Dream.get
        (Url.Package.overview ~hash:":hash" ":name" ~version:":version")
        ((Handler.package_overview t) Handler.Universe);
      Dream.get
        (Url.Package.documentation ":name" ~version:":version" ~page:"**")
        ((Handler.package_documentation t) Handler.Package);
      Dream.get
        (Url.Package.documentation ~hash:":hash" ~page:"**" ":name"
           ~version:":version")
        ((Handler.package_documentation t) Handler.Universe);
      Dream.get
        (Url.Package.search_index ":name" ~version:":version" ~digest:":digest")
        ((Handler.package_search_index t) Handler.Package);
      Dream.get
        (Url.Package.file ":name" ~version:":version" ~filepath:"**")
        ((Handler.package_file t) Handler.Package);
      Dream.get
        (Url.Package.file ~hash:":hash" ":name" ~version:":version"
           ~filepath:"**")
        ((Handler.package_file t) Handler.Package);
    ]

let sitemap_routes = Dream.scope "" [] [ Dream.get Url.sitemap Handler.sitemap ]

let graphql_route t =
  Dream.scope ""
    [ Dream_encoding.compress ]
    [
      Dream.any "/graphql" (Dream.graphql Lwt.return (Graphql.schema t));
      Dream.get "/graphiql" (Dream.graphiql "/graphql");
    ]

let router t =
  Dream.router
    [
      Dream_dashboard.route ();
      Redirection.t;
      page_routes;
      package_route t;
      graphql_route t;
      sitemap_routes;
      Dream.scope ""
        [ Dream_encoding.compress ]
        [ Dream.get "/media/**" (Dream.static ~loader:media_loader "") ];
      Dream.scope ""
        [ Dream_encoding.compress ]
        [
          Dream.get
            (Ocamlorg_static.Playground.url_root ^ "/**")
            (Dream.static ~loader:playground_loader "");
        ];
      Dream.scope ""
        [ Dream_encoding.compress ]
        [ Dream.get "/**" (Dream.static ~loader:asset_loader "") ];
    ]

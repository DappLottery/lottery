#![allow(proc_macro_derive_resolution_fallback)]

use actix_cors::Cors;
// use actix_ratelimit::{MemoryStore, MemoryStoreActor, RateLimiter};
use actix_web::{middleware, web, App, HttpServer};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // std::env::set_var("RUST_LOG", "info,actix_web=info");

    let data = web::Data::new(lottery::mongo::init_mongo().await);

    // start http server
    HttpServer::new(move || {
        let cors = Cors::permissive().allowed_origin("http://localhost:5173");
        // let store = MemoryStore::new();
        // .allowed_origin("*")
        // .allowed_methods(vec!["GET", "POST"])
        // .max_age(3600);
        App::new()
            .wrap(cors)
            // Limitation: 70 Requests / Second
            // .wrap(
            //     RateLimiter::new(MemoryStoreActor::from(store.clone()).start())
            //         .with_interval(Duration::from_secs(60))
            //         .with_max_requests(70),
            // )
            .app_data(data.clone()) // <- store db pool in app state
            .wrap(middleware::Logger::default())
            .service(lottery::game::get_history)
            .service(lottery::game::post_history)
            .service(lottery::game::post_game)
            .service(lottery::game::get_all_ticket)
            .service(lottery::game::get_ticket_by_addr)
    })
    .bind(lottery::SERVER)?
    .run()
    .await
}

#![allow(proc_macro_derive_resolution_fallback)]
use crate::db::model::{History, Ticket};
use crate::db::query;
use crate::routes::DbPool;

use actix_web::{get, post, web, HttpRequest, HttpResponse, Responder};
use serde_json::Value;

#[get("/history")]
pub async fn get_history(req: HttpRequest, conn: web::Data<DbPool>) -> impl Responder {
    if let Some(val) = req.peer_addr() {
        println!("Address {:?}", val.ip());
    };

    let db = &conn;
    let result: Vec<History> = match query::get_history(db).await {
        Ok(r) => r,
        Err(_) => Vec::new(),
    };

    HttpResponse::Ok()
        .content_type("application/json")
        .body(serde_json::to_string(&result).unwrap())
}

#[post("/history/upload")]
pub async fn post_history(params: web::Json<Value>, conn: web::Data<DbPool>) -> impl Responder {
    // println!("{:#?}", params.as_array());

    match params.as_array() {
        Some(obj) => {
            let db = &conn;
            let result: Vec<History> = obj
                .iter()
                .map(|h| serde_json::from_value(h.to_owned()).unwrap())
                .collect();

            query::insert_history(db, result).await;
        }
        None => {
            return HttpResponse::BadRequest()
                .content_type("application/json")
                .body(r#"{"status": "Wrong format"}"#)
        }
    }
    HttpResponse::Ok()
        .content_type("application/json")
        .body(r#"{"status": "Post done successfully"}"#)
}

#[post("/game/upload")]
pub async fn post_game(params: web::Json<Value>, conn: web::Data<DbPool>) -> impl Responder {
    // println!("{:#?}", params.as_array());

    match params.as_array() {
        Some(obj) => {
            let db = &conn;
            let result: Vec<Ticket> = obj
                .iter()
                .map(|h| serde_json::from_value(h.to_owned()).unwrap())
                .collect();

            query::insert_play(db, result).await;
        }
        None => {
            return HttpResponse::BadRequest()
                .content_type("application/json")
                .body(r#"{"status": "Wrong format"}"#)
        }
    }
    HttpResponse::Ok()
        .content_type("application/json")
        .body(r#"{"status": "Post done successfully"}"#)
}

#[get("/ticket")]
pub async fn get_all_ticket(conn: web::Data<DbPool>) -> impl Responder {
    let db = &conn;
    let result: Vec<Ticket> = match query::get_all_ticket(db).await {
        Ok(r) => r,
        Err(_) => Vec::new(),
    };

    HttpResponse::Ok()
        .content_type("application/json")
        .body(serde_json::to_string(&result).unwrap())
}

#[get("/ticket/addr/{address}")]
pub async fn get_ticket_by_addr(
    path: web::Path<String>,
    conn: web::Data<DbPool>,
) -> impl Responder {
    // println!("{:#?}", params.as_array());
    let addr = path.into_inner();

    let db = &conn;
    let result: Vec<Ticket> = match query::get_ticket_by_addr(db, addr).await {
        Ok(r) => r,
        Err(_) => Vec::new(),
    };

    HttpResponse::Ok()
        .content_type("application/json")
        .body(serde_json::to_string(&result).unwrap())
}

#[get("/ticket/game/{number}")]
pub async fn get_ticket_by_number(path: web::Path<i32>, conn: web::Data<DbPool>) -> impl Responder {
    // println!("{:#?}", params.as_array());
    let game = path.into_inner();

    let db = &conn;
    let result: Vec<Ticket> = match query::get_ticket_by_game(db, game).await {
        Ok(r) => r,
        Err(_) => Vec::new(),
    };

    HttpResponse::Ok()
        .content_type("application/json")
        .body(serde_json::to_string(&result).unwrap())
}

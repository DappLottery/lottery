#![allow(proc_macro_derive_resolution_fallback)]
use crate::db::model::History;
use crate::db::query;
use crate::routes::DbPool;

use actix_web::{get, post, web, HttpResponse, Responder};
use serde_json::Value;

#[get("/history")]
pub async fn get_history(conn: web::Data<DbPool>) -> impl Responder {
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

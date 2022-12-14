#![feature(proc_macro_hygiene, decl_macro)]

extern crate actix_http;
extern crate actix_rt;
extern crate actix_web;

#[macro_use]
extern crate serde_derive;
// #[macro_use]
extern crate serde_json;

extern crate mongodb;

mod db;
mod routes;

pub use db::mongo;
pub use routes::game;
pub use routes::kakao;

pub const SERVER: &str = "0.0.0.0:8010";

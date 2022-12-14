#![allow(proc_macro_derive_resolution_fallback)]
use crate::db::model::{History, Ticket};
use crate::db::query;
use crate::routes::DbPool;

use kakao_rs::prelude::*;

use actix_web::{post, web, HttpResponse, Responder};
use serde_json::Value;

#[post("/kakao/history")]
pub async fn get_ticket_on_kakao(k: web::Json<Value>, conn: web::Data<DbPool>) -> impl Responder {
    let kakao_keyword = &k["action"]["params"];
    let mut result = Template::new();

    let addr = match kakao_keyword.get("address") {
        Some(v) => v.as_str().unwrap(),
        _ => {
            result.add_qr(QuickReply::new("내 티켓", "내 티켓"));
            result.add_output(SimpleText::new("다시 입력하세요.").build());

            return HttpResponse::Ok()
                .content_type("application/json")
                .body(serde_json::to_string(&result).unwrap());
        }
    };

    let mut carousel = Carousel::new();

    let db = &conn;
    let mut tickets: Vec<Ticket> = match query::get_ticket_by_addr(db, addr.to_string()).await {
        Ok(r) => r,
        Err(_) => Vec::new(),
    };

    carousel.set_header(
        format!("내 티켓 총 {}개", tickets.len()),
        format!("DApp Lottery"),
        "http://k.kakaocdn.net/dn/APR96/btqqH7zLanY/kD5mIPX7TdD2NAxgP29cC0/1x1.jpg".to_string(),
    );

    for ticket in tickets.iter_mut() {
        let title = format!("회차: {}번", ticket.game_number);
        let desc = format!("내 주소: {}\n내 티켓: {}", addr, ticket.lottery_number);
        let basic_card = BasicCard::new()
            .set_title(title)
            .set_desc(desc)
            // .add_button(
            //     Button::new(ButtonType::Link)
                    // .set_label()
                    // .set_link(),
            // )
            ;

        carousel.add_card(basic_card.build_card());
    }

    result.add_output(carousel.build()); // moved list_card's ownership

    HttpResponse::Ok()
        .content_type("application/json")
        .body(serde_json::to_string(&result).unwrap())
}

#[post("/kakao/status")] // 현재 게임
pub async fn get_game_status(conn: web::Data<DbPool>) -> impl Responder {
    let mut result = Template::new();

    let db = &conn;
    let tickets: Vec<Ticket> = match query::get_all_ticket(db).await {
        Ok(r) => r,
        Err(_) => Vec::new(),
    };

    let last_ticket = &tickets[tickets.len() - 1];
    let last_tickets: Vec<Ticket> =
        match query::get_ticket_by_game(db, last_ticket.game_number).await {
            Ok(r) => r,
            Err(_) => Vec::new(),
        };

    let title = format!("회차: {}번", last_ticket.game_number);
    let desc = format!(
        "총 상금: {}\n티켓 수: {}",
        (150000000000000000 * last_tickets.len()) / 1000000000000000000,
        last_tickets.len()
    );
    let basic_card = BasicCard::new().set_title(title).set_desc(desc).add_button(
        Button::new(ButtonType::Link)
            .set_label("플레이 하기")
            .set_link("http://"),
    );

    result.add_output(basic_card.build()); // moved list_card's ownership

    HttpResponse::Ok()
        .content_type("application/json")
        .body(serde_json::to_string(&result).unwrap())
}

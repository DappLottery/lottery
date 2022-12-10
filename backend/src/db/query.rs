#![allow(proc_macro_derive_resolution_fallback)]

use crate::routes::DbPool;
use futures::stream::TryStreamExt;
use mongodb::bson::doc;

use crate::db::model::{History, Ticket};

/************* MONGO *************/
pub async fn get_history(conn: &DbPool) -> Result<Vec<History>, ()> {
    let history_coll = conn
        .lock()
        .unwrap()
        .database("lottery")
        .collection::<History>("history");

    let mut history = history_coll.find(doc! {}, None).await.unwrap();
    let mut result: Vec<History> = Vec::new();
    while let Some(h) = history.try_next().await.unwrap() {
        result.push(h);
    }

    Ok(result)
}

// Post history
pub async fn insert_history(conn: &DbPool, history: Vec<History>) {
    let history_coll = conn
        .lock()
        .unwrap()
        .database("lottery")
        .collection::<History>("history");

    history_coll.insert_many(history, None).await.unwrap();
}

// Post history
pub async fn insert_play(conn: &DbPool, plays: Vec<Ticket>) {
    let game_coll = conn
        .lock()
        .unwrap()
        .database("lottery")
        .collection::<Ticket>("ticket");

    game_coll.insert_many(plays, None).await.unwrap();
}

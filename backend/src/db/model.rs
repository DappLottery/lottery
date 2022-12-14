#![allow(proc_macro_derive_resolution_fallback)]

#[derive(Serialize, Deserialize, Debug, Default)]
pub struct History {
    pub manager: String,
    pub ticket_sold: u64,
    pub game_money: u64,
    pub lucky_number: String,
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub first_winner: Vec<String>,
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub second_winner: Vec<String>,
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub third_winner: Vec<String>,
}

#[derive(Serialize, Deserialize, Debug, Default)]
pub struct Ticket {
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub game_number: u32,
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub player_address: String,
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub lottery_number: String,
}

#![allow(proc_macro_derive_resolution_fallback)]

#[derive(Serialize, Deserialize, Debug, Default)]
pub struct History {
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub first_winner: Vec<String>,
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub second_winner: Vec<String>,
    // #[serde(skip_serializing_if = "Option::is_none")]
    pub third_winner: Vec<String>,
}

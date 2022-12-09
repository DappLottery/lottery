#![allow(proc_macro_derive_resolution_fallback)]
#![allow(dead_code)]

#[derive(Serialize, Deserialize, Debug, Default)]
pub struct History {
    pub id: i32,
    pub winner: String,
}

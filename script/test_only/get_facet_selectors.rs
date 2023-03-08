use std::env;
use std::fs;
use std::process;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use rustc_hex::FromHex;
use itertools::Itertools;
use ethers::abi::Token;

#[allow(non_snake_case)]
#[derive(Serialize, Deserialize, Debug)]
struct Abi {
    methodIdentifiers: HashMap<String, String>
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        process::exit(0);
    }

    // Skip index 0 because that's the script name
    let contract_name: &String = args.get(1).unwrap();
    let mut file_path = String::new();
    file_path.push_str("./_out/");
    file_path.push_str(contract_name);
    file_path.push_str(".sol/");
    file_path.push_str(contract_name);
    file_path.push_str(".json");

    let contents = fs::read_to_string(file_path)
        .expect("Should have been able to read the file");
    let abi: Abi = serde_json::from_str(&contents).unwrap();

    let mut token_vec: Vec<Token> = Vec::<Token>::new();

    for (key, val) in abi.methodIdentifiers.iter().sorted() {
        if key == "init(bytes)" || (key == "supportsInterface(bytes4)" && !contract_name.to_lowercase().contains("loupe")) {
            continue;
        }

        token_vec.push(Token::FixedBytes(val.from_hex::<Vec<u8>>().unwrap()));
    }

    let token_array: Token = Token::Array(token_vec);
    let encoded: Vec<u8> = ethers::abi::encode(&[token_array]);

    println!("{}", ethers::types::Bytes::from(encoded));
}
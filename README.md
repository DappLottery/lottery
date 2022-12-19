<div align="center">

<p>
    <img width="380" height="300" src="https://user-images.githubusercontent.com/2356749/207507444-e338d9e6-516e-4ec6-8876-880696cc667f.png">
</p>
<h1>DApp Lottery</h1>

<h3>Embedded Software Team 5</h3>
    <ul><li>최석원 (<a target="_blank" rel="noopener" href="https://github.com/Alfex4936">@Alfex4936</a>)</li><li>이근호 (<a target="_blank" rel="noopener" href="https://github.com/RootLEE2">@RootLEE2</a>)</li><li>이한식 (<a target="_blank" rel="noopener" href="https://github.com/leehansik">@leehansik</a>)</li></ul>
</div>

## Requirements

- lang: [Rust](https://www.rust-lang.org/) (backend) + [Svelte](https://svelte.dev/) (Frontend) + [Solidity](https://docs.soliditylang.org/) (Smart Contract)
- stack: AWS EC2 + MongoDB + [Ganache](https://trufflesuite.com/ganache/) + [MetaMask](https://metamask.io/)

```bash
export LOTTERY_DB="private mongodb addr"
export LOTTERY_EC2="private ec2 addr"
export GANACHE="ganache addr"
```

```console
ubuntu:~$ cd backend && rustup override set nightly && cargo run --release

ubuntu:~$ cd frontend && yarn install && yarn dev --host

ubuntu:~$ truffle migrate --network dev
```

## Frontend

* Svelte
* ViteJS

## Backend

* Rust [actix-rs](https://actix.rs/)
* Rust [kakao-rs](https://github.com/Alfex4936/kakao-rs)
* MongoDB

## Limitations

- Cannot run ChainLink VRF v2 to use provably fair RNG
  - However, our implementation is hard to exploit as we generate the lottery number when the admin clicks the Pick Winner button.
  - On the call, it generates on the fly and sends money right away. No one can see the number before the game finishes.
  - The estimated gas fee to call of this library is about $4.

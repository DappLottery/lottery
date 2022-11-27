# 필요사항

truffle-config.js -> dev ganache network 설정, port 8545로 되어 있음

```
truffle migrate --network dev
```

MetaMask 설치 -> Ganache 계정 중 하나 private key 복사해서 계정 연동

copy abi jsons to frontend/abis folder (자동으로 하게 해둠)

copy Ganache's deployed Lottery contract address to `App.svelete` const

# 실행

(auto-hot reload)

```bash
yarn dev
```

# 할 것

- 플레이어 정보 예쁘기
- toast로 티켓 샀을 때 티켓 번호 보여주기
- Svelete 변수 업데이트 방식 변경 (html 자동 업데이트 잘못함)
- Admin 관련 메뉴 결과 예쁘게
- 컨트랙트 프론트에 맞춰 기능 수정 및 변경
- 최종 때 디자인

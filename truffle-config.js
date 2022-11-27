// by default the owner of the contract is account[0]
// to set an owner set the 'from' option with the address of the new owner

module.exports = {
  contracts_build_directory: "./frontend/src/abis",
  networks: {
    dev: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
    },
  },
  compilers: {
    solc: {
      version: "0.8.17",
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};


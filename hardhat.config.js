require("@nomicfoundation/hardhat-toolbox");
require('solidity-coverage');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.27",
      },
      {
        version: "0.8.0",
      },      
      {
        version: "0.7.0",
      },
      {
        version: "0.7.5",
      },
    ],
  },
  networks: {
    hardhat: {
        chainId: 1337,
    },
},
};


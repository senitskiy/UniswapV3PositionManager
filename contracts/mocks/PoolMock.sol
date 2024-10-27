// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0 || ^0.8.0;

interface IUniswapV3Pool {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function slot0() external view returns (uint160, int24, int24, int24, uint16, uint256, uint256);
}

contract PoolMock is IUniswapV3Pool {
    address public token0Address;
    address public token1Address;

    constructor(address _token0, address _token1) {
        token0Address = _token0;
        token1Address = _token1;
    }

    function token0() external view override returns (address) {
        return token0Address;
    }

    function token1() external view override returns (address) {
        return token1Address;
    }

    function slot0() external view override returns (uint160, int24, int24, int24, uint16, uint256, uint256) {
        return (1, 1, 1, 1, 1, 1, 1); // Мокаем возврат значений для slot0
    }
}
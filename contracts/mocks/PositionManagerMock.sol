// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0 || ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PositionManagerMock {
    event Minted(uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    function mint(
        address token0,
        address token1,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) {
        // Мокаем возврат значений для функции mint
        return (1, 100, amount0Desired, amount1Desired);
    }
    
    function approve(address spender, uint256 amount) external {}
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        return true; // Мокаем transferFrom
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0 || ^0.8.0;
pragma abicoder v2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract UniswapV3PositionManager {
    INonfungiblePositionManager public positionManager;

    constructor(address _positionManager) {
        positionManager = INonfungiblePositionManager(_positionManager);
    }

event PositionCreated(uint256 tokenId, address recipient, uint256 amount0, uint256 amount1);

    struct PositionParameters {
        address pool;         // Адрес пула Uniswap V3
        uint256 amount0;     // Количество первого токена
        uint256 amount1;     // Количество второго токена
        uint256 width;       // Ширина позиции в процентах
    }

    function createPosition(PositionParameters memory params) external {
        address token0 = IUniswapV3Pool(params.pool).token0();
        address token1 = IUniswapV3Pool(params.pool).token1();
        
        // Получаем текущую цену и диапазон цен
        (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(params.pool).slot0();
        uint256 price = (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) / (2**192); // Текущая цена в формате Q192

        // Вычисляем нижнюю и верхнюю границы
        uint256 lowerPrice = price * (10000 - params.width) / 10000;
        uint256 upperPrice = price * (10000 + params.width) / 10000;

        // Перевод токенов в контракт
        IERC20(token0).transferFrom(msg.sender, address(this), params.amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), params.amount1);

        // Утверждаем токены на позиции Uniswap
        IERC20(token0).approve(address(positionManager), params.amount0);
        IERC20(token1).approve(address(positionManager), params.amount1);

        // Устанавливаем параметры позиции
        INonfungiblePositionManager.MintParams memory mintParams = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: 3000, // Здесь необходимо указать правильный сбор за своп (например, 0.3%)
            tickLower: getTick(lowerPrice),
            tickUpper: getTick(upperPrice),
            amount0Desired: params.amount0,
            amount1Desired: params.amount1,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender,
            deadline: block.timestamp + 15
        });

        // Создаем позицию
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) =
            positionManager.mint(mintParams);

        // Проверка на лишние токены и возврат
        if (amount0 < params.amount0) {
            IERC20(token0).transfer(msg.sender, params.amount0 - amount0);
        }
        if (amount1 < params.amount1) {
            IERC20(token1).transfer(msg.sender, params.amount1 - amount1);
        }

        emit PositionCreated(tokenId, msg.sender, amount0, amount1);
    }

    function getTick(uint256 price) internal pure returns (int24) {
        return int24(uint256(price));
    }
}
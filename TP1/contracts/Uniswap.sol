pragma solidity ^0.8.0;

import "./IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Uniswap {

    address public tokenAddress;
    IERC20 MyToken;
    IUniswapV2Router02 Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

    mapping(address => uint256)public ETHStored;

    event AddLiquidity(address indexed, uint256 amount, address indexed);
    event SwapTokens(address indexed, uint256 amount);
    event Withdraw(address indexed, uint256 amount);


    constructor(address _token){
        require(_token != address(0), "Not the address 0");
        tokenAddress = _token;
        MyToken = IERC20(_token);
    }

    // important to receive ETH
    receive() external payable {}

    /// @notice It will add liquidity & create the pool
    /// @dev We will use Router to add liquidity and create pool.
    /// @param _tokenAmount The number token you want to deposit in pool.

    function addLiquidity(uint256 _tokenAmount) external payable {
        require(msg.value >= 1 ether, "Not enough balance");
        MyToken.transferFrom(msg.sender, address(this), _tokenAmount);
        MyToken.approve(ROUTER, _tokenAmount);
        Router.addLiquidityETH{value: msg.value}(tokenAddress, _tokenAmount, 1000, msg.value, msg.sender, block.timestamp + 666);

        emit AddLiquidity(msg.sender, _tokenAmount, address(this) );
    }

    /// @notice It will your token into ETH
    /// @dev We will use Router to swap the token.
    /// @param  _tokenAmount The number token you want swap.

    function swapTokensForETH(uint256 _tokenAmount) external {
        MyToken.transferFrom(msg.sender, address(this), _tokenAmount);
        MyToken.approve(ROUTER, _tokenAmount);

        address[] memory path = new address[](2);
        path[0] = address(MyToken);
        path[1] = WETH;
        (uint256[] memory amounts) = Router.swapExactTokensForETH(_tokenAmount, 2, path, address(this), block.timestamp + 7777);
        ETHStored[msg.sender] += amounts[1];
        emit SwapTokens(msg.sender, _tokenAmount);
    }

    /// @notice It will use to withdraw your ETH.
    /// @dev It will wtihdraw all your ETH which is swap.
    /// @param  _amount the number of ETH you want to withdraw.

    function withdrawETH(uint256 _amount) external {
        require(ETHStored[msg.sender] >= _amount, "Must have enough to withdraw");
        ETHStored[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);

        emit Withdraw(msg.sender, _amount);
    }
}
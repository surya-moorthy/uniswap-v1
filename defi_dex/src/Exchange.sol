// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './ERC20.sol';
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract Exchange is ERC20, ReentrancyGuard {
  address immutable tokenAddress;
  address immutable factoryAddress;

  event LiquidityAdded(address indexed provider,uint tokenAmount);
  event LiquidityRemoved(address indexed provider, uint tokenAmount);
  event TokenPurchased(address indexed buyer,uint TokenReceived);
  event TokenSold(address indexed seller,uint ethReceived);

   constructor(address _tokenAddress) ERC20("UNI-V1", "UNI-V1") {
        require(_tokenAddress != address(0), "Token address cannot be 0x0");
        tokenAddress = _tokenAddress;
        factoryAddress = msg.sender;
    }

  function AddLiquidity(uint tokenAdded) external payable nonReentrant returns(uint256) {
     require(msg.value > 0 && tokenAdded > 0 , "insufficient amount represented");

     uint ethbalance = address(this).balance;
     uint tokenBalance = getTokenReserves();     

     if(tokenBalance == 0) {
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= 0,"Insufficient token balance");
        IERC20(tokenAddress).transferFrom(msg.sender,address(this),tokenAdded);
        uint liquidity = ethbalance;

        _mint(msg.sender,liquidity);
        emit LiquidityAdded(msg.sender, liquidity);

        return liquidity;
     }else {
        uint256 liquidity = (msg.value * totalSupply())/(ethbalance - msg.value); 
           require(IERC20(tokenAddress).balanceOf(msg.sender) >= 0,"Insufficient token balance");
            IERC20(tokenAddress).transferFrom(msg.sender,address(this),tokenAdded);

            _mint(msg.sender,liquidity);
            emit LiquidityAdded(msg.sender, liquidity);

            return liquidity;
     }
  }
  function removeLiquidity(uint tokenAmount) external payable nonReentrant returns(uint , uint) {
           require(tokenAmount > 0, "Invalid token amount");


           uint ethAmt = (address(this).balance * tokenAmount)/ totalSupply();
           uint tokenAmt = (getTokenReserves() * tokenAmount)/ totalSupply();

           require(getTokenReserves()/address(this).balance == (getTokenReserves() + tokenAmt)/(address(this).balance + ethAmt),"Invariant check failed");
           _burn(msg.sender,tokenAmount);

           payable(msg.sender).transfer(ethAmt);
           IERC20(tokenAddress).transfer(msg.sender,tokenAmt);

           emit LiquidityRemoved(msg.sender,tokenAmount);
           return (ethAmt,tokenAmt);
     }
     function swapEthForTokens(uint minTokens, address recipient) external payable nonReentrant returns (uint) {
    uint tokenAmount = getTokenAmount(msg.value);
    require(tokenAmount >= minTokens, "Token amount less than expected");

    IERC20(tokenAddress).transfer(recipient, tokenAmount);
    emit TokenPurchased(msg.sender, msg.value);

    return tokenAmount;
}

function tokenForEthSwap(uint tokensSold, uint minEth) external nonReentrant returns(uint) {
    uint ethAmount = getEthAmount(tokensSold);
    require(ethAmount >= minEth, "ETH amount less than expected");

    IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokensSold);
    payable(msg.sender).transfer(ethAmount);
    emit TokenSold(msg.sender, ethAmount);

    return ethAmount;
}

// Pricing Functions
function getTokenAmount(uint ethSold) public view returns (uint256) {
    require(ethSold > 0, "ETH sold must be greater than 0");
    uint outputReserve = getTokenReserves();
    return getAmount(ethSold, address(this).balance - ethSold, outputReserve);
}

function getEthAmount(uint tokensSold) public view returns (uint256) {
    require(tokensSold > 0, "Tokens sold must be greater than 0"); 
    uint inputReserve = getTokenReserves();
    return getAmount(tokensSold, inputReserve - tokensSold, address(this).balance);
}

function getAmount(uint inputAmount, uint inputReserve, uint outputReserve) public pure returns (uint256) {
    require(inputReserve > 0 && inputAmount > 0, "Invalid values provided");
    uint256 inputAmountWithFee = inputAmount * 997;
    uint256 numerator = inputAmountWithFee * outputReserve;
    uint256 denominator = (inputReserve * 1000) + inputAmountWithFee;
    return numerator / denominator;
}

function getTokenReserves() public view returns (uint256) {
    return IERC20(tokenAddress).balanceOf(address(this));
}
}
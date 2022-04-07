
// contracts/ehStablejcad.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.5.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ehStablejcad is ReentrancyGuard {
    using SafeMath for uint256;

    address public admin;

    ERC20 jcad;
    ERC20 sask;

    uint256 public jcadRate;
    uint256 public saskRate;
    
    constructor(address _jcad, address _sask) public {
        admin = msg.sender;
        jcad = ERC20(_jcad);
        sask = ERC20(_sask);
        saskRate = 99;
        jcadRate = 101;
    }
    
    function setAdmin(address _admin) public {
        require(admin==msg.sender, "ser pls no hack");
        admin=_admin;
    }

    function transferToken(address token, uint256 amountToken) public {
        require(admin==msg.sender, "ser pls no hack");
        ERC20(token).transfer(admin, amountToken);
    }

    // this returns the reserves in the contract

    function getReserves() public view returns(uint256, uint256) {
        return ( sask.balanceOf(address(this)), jcad.balanceOf(address(this)) );
    }
    
    // the user must approve the balance so the contract can take it out of the user's account
    // else this will fail, and your day will be ruined.

    function swapFrom(uint256 amount) public nonReentrant {
        require(amount!=0, "swapFrom: invalid amount");
        require(sask.balanceOf(address(this))!=0, "swapFrom: Not enough SaskCoin in reserves");

        // for every 1.02 jcad we get 1.00 sask
            // 1020000 we get 1000000000000000000

        uint256 amountToSend = amount.mul(100000000000000).div(jcadRate);

        require(sask.balanceOf(address(this)) >= amountToSend, "swapFrom: Not enough SaskCoin in reserves");

        // Transfer jcad to contract
        jcad.transferFrom(msg.sender, address(this), amount);
        // Transfer SaskCoin to sender
        sask.transfer(msg.sender, amountToSend);
    }

    function swapTo(uint256 amount) public nonReentrant {
        require(amount!=0, "swapTo: invalid amount");
        require(jcad.balanceOf(address(this))!=0, "swapTo: Not enough JCAD in reserves");
        // for every 1.00 sask we get 0.98 jcad
            // 1000000000000000000 we get 980000 (bc decimals)
        uint256 amountToSend = amount.mul(saskRate).div(100000000000000);

        require(jcad.balanceOf(address(this)) >= amountToSend, "swapTo: Not enough jcad in reserves");

        // Tranfer tokens from sender to this contract
        sask.transferFrom(msg.sender, address(this), amount);
        // Transfer amount minus fees to sender
        jcad.transfer(msg.sender, amountToSend);
    }
}

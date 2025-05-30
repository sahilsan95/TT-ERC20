//SPDX-License-Identifier:MIT

pragma solidity ^0.8.28;

contract ManualToken {

    mapping(address => uint256) private s_balances;

    function name() public pure returns (string memory){
        return "Manual Token";
            }

    function totalSupply() public pure returns (uint256){
        return 100 ether;
    }        

    function decimals() public  pure returns (uint8){
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return s_balances[_owner];
        }

    function transfer(address _to, uint256 _amount) public {
        uint256 previousBalances = balanceOf(msg.sender) + balanceOf(_to);       //storing the total balance of sender and receiver before the transfer.
        s_balances[msg.sender]-=_amount;                                         //subtracting the _amount of tokens from the sender's balance.
        s_balances[_to]+=_amount;                                                //adding the _amount of tokens to the recipient's balance.
        require(balanceOf(msg.sender) + balanceOf(_to) == previousBalances);     //ensures that the total amount of tokens between the two accounts hasn't changed — i.e., no tokens were magically created or lost. if it fails, transcation reverts
    }
    }

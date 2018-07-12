pragma solidity ^0.4.23;

import "./erc721.sol";
import "./SafeMath.sol";

contract Database {
    
    using SafeMath for uint256;
    
    mapping (address => uint) private LordToEth;

    function addAccountEth(address _account, uint _val) external {
        require(_account != address(0));
        LordToEth[_account] = LordToEth[_account].add(_val);
    }

    function reduceAccountEth(address _account, uint _val) external {
        require(_account != address(0));
        LordToEth[_account] = LordToEth[_account].sub(_val);
    }
    function getAccountEth(address _account) external view returns(uint) {
        require(_account != address(0));
        return LordToEth[_account];
    }

}
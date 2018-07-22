pragma solidity ^0.4.23;

import "./erc721.sol";
import "./SafeMath.sol";
import "./Random.sol";
import "./WarriorBase.sol";
import "./Database.sol";

contract LordBase is Random{

    using SafeMath for uint256;
    using SafeMath for uint64;

    event Battle(uint attackId, uint defenceId, uint battleConsequence);
    
    WarriorBase private warriorBaseContract;
    Database private databaseContract;
    
    constructor(
        address _warriorBaseContract,
        address _databaseContract) public {
        warriorBaseContract = WarriorBase(_warriorBaseContract);
        databaseContract = Database(_databaseContract);
    }

    function setWarriorBaseContractd(address _warriorBaseContract) external {
        warriorBaseContract = WarriorBase(_warriorBaseContract);
    }
 
    function battle(
        uint attackId,
        uint defenceId) external returns(uint){
        
        address attackAddr = warriorBaseContract.getTokenOwner(attackId);
        address defenceAddr = warriorBaseContract.getTokenOwner(defenceId);
        

        require(attackAddr != address(0));
        require(defenceAddr != address(0));

        uint[9] memory attackToken = warriorBaseContract.getToken(attackId);
        uint[9] memory defenceToken = warriorBaseContract.getToken(defenceId);
        uint attackCE = attackToken[6];
        uint defenceCE = defenceToken[6];
        uint defenceTitle = defenceToken[4];
        uint dice = _rand() % (attackCE + defenceCE);
        uint battleConsequence;
        uint valToTransfer;
        
        if (defenceTitle >= 7)
            dice = dice.sub((dice / 100) * 5);
        
        if (dice < attackCE) {
            valToTransfer = warriorBaseContract.consequence(attackId, defenceId, attackAddr, defenceAddr);
            databaseContract.addAccountEth(attackAddr, valToTransfer);
            
            battleConsequence = 1;
        } else {
            valToTransfer = warriorBaseContract.consequence(defenceId, attackId, defenceAddr, attackAddr);
            databaseContract.addAccountEth(defenceAddr, valToTransfer);
            
            battleConsequence = 0;
        }

        emit Battle(attackId, defenceId, battleConsequence);
        return battleConsequence;
    }

}
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
    
    function checkCoachCoolDown(uint coachId, uint attackId) external view returns(uint) {
        require(coachId <= 4);
        uint[13] memory attackToken = warriorBaseContract.getToken(attackId);
        if (attackToken[8 + coachId] - now <= 60)
            return 0;
        return 1;
    }
    
    function battle(
        uint attackId,
        uint defenceId) external returns(uint){
        
        address attackAddr = warriorBaseContract.getTokenOwner(attackId);
        address defenceAddr = warriorBaseContract.getTokenOwner(defenceId);
        

        require(attackAddr != address(0));
        require(defenceAddr != address(0));

        uint[13] memory attackToken = warriorBaseContract.getToken(attackId);
        uint[13] memory defenceToken = warriorBaseContract.getToken(defenceId);
        uint attackCE = attackToken[6];
        uint defenceCE = defenceToken[6];
        uint defenceTitle = defenceToken[4];
        uint dice = _rand() % (attackCE + defenceCE);
        uint battleConsequence;
        uint valToTransfer;
        
        if (defenceTitle >= 7 && defenceTitle <= 10)
        {
            dice = dice.sub((dice / 100) * 5);
            warriorBaseContract.setCoachCoolDownTime(defenceId, attackId);
        }

        if (dice < attackCE) {
            valToTransfer = warriorBaseContract.consequence(attackId, defenceId, attackAddr, defenceAddr);
            databaseContract.addAccountEth(attackAddr, valToTransfer);
            if (defenceToken[4] < 7)
            databaseContract.reduceAccountEth(defenceAddr, valToTransfer);
            battleConsequence = 1;
        } else {
            valToTransfer = warriorBaseContract.consequence(defenceId, attackId, defenceAddr, attackAddr);
            databaseContract.addAccountEth(defenceAddr, valToTransfer);
            if (attackToken[4] < 7)
                databaseContract.reduceAccountEth(attackAddr, valToTransfer);
            battleConsequence = 0;
        }

        emit Battle(attackId, defenceId, battleConsequence);
        return battleConsequence;
    }

}
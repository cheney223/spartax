pragma solidity ^0.4.23;

import "./erc721.sol";
import "./SafeMath.sol";
import "./Random.sol";
import "./Database.sol";


contract WarriorBase is ERC721
{
    
    using SafeMath for uint256;
    using SafeMath for uint64;

    Random private randomContract;
    Database private databaseContract;

    /// @dev This emits when the token ownership changed 
    event Transfer(address indexed from, address indexed to, uint256 tokenId);
    /// @dev This emits when user charged his warrior
    event NewFund(uint _value);
    /// @dev This emits when a new warrior is created(adopted) by user
    event CreateWarrior(address _owner, uint newWarriorId, uint _val);

    event Consequence(uint winnerId, uint loserId, address winnerAddr, address loserAddr, uint valToTransfer, uint ceToTransfer, uint winnerTitle, uint loserTitle);

    event KillWarrior(uint _id, address owner, uint tokenToOwnerIndex);

    event AddPrestige(uint _id, uint winningPrestige, uint title);

    event SubPrestige(uint _id, uint winningPrestige);

    event SetCoachCoolDownTime(uint coachId, uint attackId, uint curTime);

    event SwitchRetirementStatus(uint tokenId, uint retirementStatus);
    
    mapping (uint => address) internal tokenApprovals;
    
    mapping (uint => address) internal tokenIndexToOwner;
    
    mapping (address => uint) internal ownerToTokenCount;

    mapping (address => uint[]) internal ownerToTokenArray;

    /// the id of the given token in owner's token list.
    mapping (uint => uint) internal tokenIndexToOwnerIndex;
    
    string public constant name = "SpartaxWarrior";
    string public constant symbol = "SW";

    uint constant greenhandProtection = 30 minutes;
    uint constant miniValue = 10 ** 16;

    struct Warrior {
        uint val;   /// 0
        uint winCount;  /// 1
        uint lossCount; /// 2
        uint combo; /// 3
        uint title;     /// 4 title: default--0 primary coach--7 intermediate coach--8 advanced coach--9 master--10
        uint prestige;  /// 5 
        uint ce;    /// 6 comat effectiveness
        uint createTime;    /// 7
        uint destroyTime;   /// 8
        uint lastAttackCoach1;  /// 9
        uint lastAttackCoach2;  /// 10
        uint lastAttackCoach3;  /// 11
        uint lastAttackCoach4;  /// 12
        uint retired;   /// 13
        
    }

    Warrior[] private WarriorList;
    uint private ActiveWarriorListLength; 

    /// @dev check the given tokenId is in the tokenList and its owner is not null.
    modifier tokenExist(uint256 _id) {
        require(_id >= 1 && _id <= WarriorList.length);
        require(tokenIndexToOwner[_id] != address(0));
        _;
    }

    /// @dev construction method.
    constructor(
        address _randomContract,
        address _databaseContract) public{

        randomContract = Random(_randomContract);
        databaseContract = Database(_databaseContract);

        /// warrior list contains the 4 coaches at the very beginning
        ActiveWarriorListLength = 4;

        /// drop index 0
        WarriorList.length += 1;

        /// primary coach : value 0.01ether  comat effectiveness 10   title 7
        uint newWarriorId = WarriorList.length;
        WarriorList.length += 1;
        Warrior storage war = WarriorList[newWarriorId];
        war.val = miniValue;    /// 0.01 ether in Wei
        war.winCount = 0;
        war.lossCount = 0;
        war.combo = 0;
        war.title = 7;
        war.prestige = 0;
        war.ce = 10;
        _transfer(0, msg.sender, newWarriorId);
        databaseContract.addAccountEth(msg.sender, war.val);

        /// primary coach : value 0.01ether  comat effectiveness 10   title 8
        newWarriorId = WarriorList.length;
        WarriorList.length += 1;
        war = WarriorList[newWarriorId];
        war.val = miniValue * 5; /// 0.05 ether in Wei
        war.winCount = 0;
        war.lossCount = 0;
        war.combo = 0;
        war.title = 8;
        war.prestige = 0;
        war.ce = 50;
        _transfer(0, msg.sender, newWarriorId);
        databaseContract.addAccountEth(msg.sender, war.val);

        /// primary coach : value 0.01ether  comat effectiveness 10   title 9
        newWarriorId = WarriorList.length;
        WarriorList.length += 1;
        war = WarriorList[newWarriorId];
        war.val = miniValue * 10;   /// 0.1 ether in Wei
        war.winCount = 0;
        war.lossCount = 0;
        war.combo = 0;
        war.title = 9;
        war.prestige = 0;
        war.ce = 100;
        _transfer(0, msg.sender, newWarriorId);
        databaseContract.addAccountEth(msg.sender, war.val);

        /// primary coach : value 0.01ether  comat effectiveness 10   title 10
        newWarriorId = WarriorList.length;
        WarriorList.length += 1;
        war = WarriorList[newWarriorId];
        war.val = miniValue * 50;   /// 0.5 ether in Wei;
        war.winCount = 0;
        war.lossCount = 0;
        war.combo = 0;
        war.title = 10;
        war.prestige = 0;
        war.ce = 500;
        _transfer(0, msg.sender, newWarriorId);
        databaseContract.addAccountEth(msg.sender, war.val);
    }

    /// @dev adopt a level 1 warrior (0.01 eth)
    function adoptLvOne() 
        external
        payable
        returns(uint256)
        {
        require(msg.sender != address(0));
        require(msg.value >= 0.01 ether);


        uint newWarriorId = WarriorList.length;
        WarriorList.length += 1;
        Warrior storage war = WarriorList[newWarriorId];
        war.val = msg.value;
        war.winCount = 0;
        war.lossCount = 0;
        war.combo = 0;
        war.title = 0;
        war.prestige = 0;
        war.ce = 10;
        war.createTime = now;
        war.destroyTime = 0;
        war.lastAttackCoach1 = 0;
        war.lastAttackCoach2 = 0;
        war.lastAttackCoach3 = 0;
        war.lastAttackCoach4 = 0;
        
        _transfer(0,msg.sender, newWarriorId);
        databaseContract.addAccountEth(msg.sender, msg.value);
        ActiveWarriorListLength = ActiveWarriorListLength.add(1);
        CreateWarrior(msg.sender,newWarriorId, msg.value);
        return newWarriorId;
    }

    /// @dev adopt a level 2 warrior (0.05 eth)
    function adoptLvTwo() 
        external
        payable
        returns(uint256)
        {
        require(msg.sender != address(0));
        require(msg.value >= 0.05 ether);


        uint newWarriorId = WarriorList.length;
        WarriorList.length += 1;
        Warrior storage war = WarriorList[newWarriorId];
        war.val = msg.value;
        war.winCount = 0;
        war.lossCount = 0;
        war.combo = 0;
        war.title = 0;
        war.prestige = 0;
        war.ce = 50;
        war.createTime = now;
        war.destroyTime = 0;
        war.lastAttackCoach1 = 0;
        war.lastAttackCoach2 = 0;
        war.lastAttackCoach3 = 0;
        war.lastAttackCoach4 = 0;

        _transfer(0,msg.sender, newWarriorId);
        databaseContract.addAccountEth(msg.sender, msg.value);
        ActiveWarriorListLength = ActiveWarriorListLength.add(1);
        CreateWarrior(msg.sender, newWarriorId, msg.value);
        return newWarriorId;
    }

    /// @dev adopt a level 3 warrior (0.1 eth)
    function adoptLvThree() 
        external
        payable
        returns(uint256)
        {
        require(msg.sender != address(0));
        require(msg.value >= 0.1 ether);


        uint newWarriorId = WarriorList.length;
        WarriorList.length += 1;
        Warrior storage war = WarriorList[newWarriorId];
        war.val = msg.value;
        war.winCount = 0;
        war.lossCount = 0;
        war.combo = 0;
        war.title = 0;
        war.prestige = 0;
        war.ce = 100;
        war.createTime = now;
        war.destroyTime = 0;
        war.lastAttackCoach1 = 0;
        war.lastAttackCoach2 = 0;
        war.lastAttackCoach3 = 0;
        war.lastAttackCoach4 = 0;

        _transfer(0,msg.sender, newWarriorId);
        databaseContract.addAccountEth(msg.sender, msg.value);
        ActiveWarriorListLength = ActiveWarriorListLength.add(1);
        CreateWarrior(msg.sender, newWarriorId, msg.value);
        return newWarriorId;
    }

    /// @dev adopt a level 4 warrior (0.5 eth)
    function adoptLvFour() 
        external
        payable
        returns(uint256)
        {
        require(msg.sender != address(0));
        require(msg.value >= 0.5 ether);


        uint newWarriorId = WarriorList.length;
        WarriorList.length += 1;
        Warrior storage war = WarriorList[newWarriorId];
        war.val = msg.value;
        war.winCount = 0;
        war.lossCount = 0;
        war.combo = 0;
        war.title = 0;
        war.prestige = 0;
        war.ce = 500;
        war.createTime = now;
        war.destroyTime = 0;
        war.lastAttackCoach1 = 0;
        war.lastAttackCoach2 = 0;
        war.lastAttackCoach3 = 0;
        war.lastAttackCoach4 = 0;

        _transfer(0,msg.sender, newWarriorId);
        databaseContract.addAccountEth(msg.sender, msg.value);
        ActiveWarriorListLength = ActiveWarriorListLength.add(1);
        CreateWarrior(msg.sender, newWarriorId, msg.value);
        return newWarriorId;
    }

    function setRandomAddr(address _randomContract) external {
        randomContract = Random(_randomContract);
    }

    /// @dev return the total number of tokens in the game
    function getTokenNum() external view returns(uint) {
        return WarriorList.length - 1;
    }

    /// @dev return the owner address of the token(warrior)
    function getTokenOwner(uint _id) external view tokenExist(_id) returns(address) {
        require(tokenIndexToOwner[_id] != address(0));
        return tokenIndexToOwner[_id];
    }

    /// @dev Ruturn token details by tokenId
    function getToken(uint256 _id) external view tokenExist(_id) returns (uint[13] datas) {
        Warrior storage warrior = WarriorList[_id];
        datas[0] = warrior.val;
        datas[1] = warrior.winCount;
        datas[2] = warrior.lossCount;
        datas[3] = warrior.combo;
        datas[4] = warrior.title;
        datas[5] = warrior.prestige;
        datas[6] = warrior.ce;
        datas[7] = warrior.createTime;
        datas[8] = warrior.destroyTime;
        datas[9] = warrior.lastAttackCoach1;
        datas[10] = warrior.lastAttackCoach2;
        datas[11] = warrior.lastAttackCoach3;
        datas[12] = warrior.lastAttackCoach4;
        
    }

    /// @dev return all tokens owned by owner
    function getOwnTokens(address _owner) external view returns(uint256[] tokens){
        require(_owner != address(0));
        uint256[] memory tokenArray = ownerToTokenArray[_owner];
        uint256 length = (uint256)(tokenArray.length);

        tokens = new uint256[](length);

        for (uint256 i = 0; i < length; ++i) {
            tokens[i] = tokenArray[i];
        }
    }

    /// @dev return all tokens not belong to owner
    function getEnemyTokens(address _owner) external view returns(uint[] tokens) {
        require(_owner != address(0));

        uint length = WarriorList.length - 1 - ownerToTokenArray[_owner].length;
        tokens = new uint256[](length);
        uint index = 0;
        for (uint256 i = 1; i < WarriorList.length; ++i) {
            if (tokenIndexToOwner[i] != _owner) {
                tokens[index] = i;
                index += 1;
            }
        }

    }

    /// @dev return active warrior numbers for now
    function getActiveWarriorListLength() external view returns(uint) {
        return ActiveWarriorListLength;
    }


    /// @dev set the timestamp of attacking each coach, you cannot attack them twice within an hour 
    function setCoachCoolDownTime(uint coachId, uint attackId) external tokenExist(attackId){
        Warrior storage attacker = WarriorList[attackId];
        
        if (coachId == 1)
            attacker.lastAttackCoach1 = uint(now);
        else if (coachId == 2)
            attacker.lastAttackCoach2 = uint(now);
        else if (coachId == 3)
            attacker.lastAttackCoach3 = uint(now);
        else if (coachId == 4)
            attacker.lastAttackCoach4 = uint(now);

        emit SetCoachCoolDownTime(coachId, attackId, now);
    }

    /// @dev calculate the consequece of a finished battle
    function consequence(
        uint winnerId,
        uint loserId, 
        address winnerAddr,
        address loserAddr) external tokenExist(winnerId) tokenExist(loserId) returns(uint){
        
        require(tokenIndexToOwner[winnerId] == winnerAddr);
        require(tokenIndexToOwner[loserId] == loserAddr);

        uint valToTransfer;
        uint ceToTransfer;

        if (WarriorList[loserId].ce <= 2) {
            valToTransfer = WarriorList[loserId].val;
            ceToTransfer = WarriorList[loserId].ce;
        } else {
            valToTransfer = WarriorList[loserId].val.div(2);
            ceToTransfer = WarriorList[loserId].ce.div(2);
        }

        Warrior storage winner = WarriorList[winnerId];
        winner.winCount = winner.winCount.add(1);
        winner.combo = winner.combo.add(1);

        Warrior storage loser = WarriorList[loserId];
        loser.lossCount = loser.lossCount.add(1);
        loser.combo = 0;

        if (loser.title < 7 || loser.title > 10)        /// if the loser is a coach, his value shall not be reduced.
        {
            loser.val = loser.val.sub(valToTransfer);
            loser.title = 0;
            loser.ce = loser.ce.sub(ceToTransfer);
        }

        if (winner.title < 7 || winner.title > 10) {
            winner.val = winner.val.add(valToTransfer);
            winner.ce = winner.ce.add(ceToTransfer);
            if (winner.title < 7)
            {
                if (winner.combo < 1)
                    winner.title = 0;
                else if (winner.combo < 2)
                    winner.title = 1;
                else if (winner.combo < 4)
                    winner.title = 2;
                else if (winner.combo < 8)
                    winner.title = 3;
                else if (winner.combo < 12)
                    winner.title = 4;
                else if (winner.combo < 20)
                    winner.title = 5;
                else
                    winner.title = 6;
            }
        }

        emit Consequence(winnerId,loserId, winnerAddr, loserAddr, valToTransfer, ceToTransfer, winner.title, loser.title);
        return valToTransfer;
    }

    function addPrestige(uint tokenId, uint prestigeAmt) tokenExist(tokenId) external {
        WarriorList[tokenId].prestige = WarriorList[tokenId].prestige.add(prestigeAmt);
        if ( WarriorList[tokenId].prestige >= 30 )
            WarriorList[tokenId].title = 11;
        if ( WarriorList[tokenId].prestige >= 40 )
            WarriorList[tokenId].title = 12;
        emit AddPrestige(tokenId, prestigeAmt, WarriorList[tokenId].title);
    }

    function subPrestige(uint tokenId, uint prestigeAmt) tokenExist(tokenId) external {
        WarriorList[tokenId].prestige = WarriorList[tokenId].prestige.sub(prestigeAmt);
        WarriorList[tokenId].title = 0;
        if ( WarriorList[tokenId].prestige >= 30 )
            WarriorList[tokenId].title = 11;
        if ( WarriorList[tokenId].prestige >= 40 )
            WarriorList[tokenId].title = 12;
        emit SubPrestige(tokenId, prestigeAmt);
    }

    function switchRetirementStatus(uint tokenId) tokenExist(tokenId) external {
        require(WarriorList[tokenId].title == 12);
        WarriorList[tokenId].retired = 1 - WarriorList[tokenId].retired;
        emit SwitchRetirementStatus(tokenId, WarriorList[tokenId].retired);
    }

    /// @dev "feed" the token with msg.value 
    function feedWarrior(uint _id) public tokenExist(_id) payable returns(uint) {
        require(tokenIndexToOwner[_id] == msg.sender);
        
        WarriorList[_id].val = WarriorList[_id].val.add(msg.value);
        databaseContract.addAccountEth(msg.sender, msg.value);
        NewFund(this.balance);
        return this.balance;
    }

    function _removeFromList(uint _id, address _owner) private {
      
        for (uint i = 0; i < ownerToTokenArray[_owner].length; i++) {
            if (ownerToTokenArray[_owner][i] == _id) {
                for (uint j = i; j < ownerToTokenArray[_owner].length - 1; j++)
                    ownerToTokenArray[_owner][j] = ownerToTokenArray[_owner][j + 1];
                ownerToTokenArray[_owner].length -= 1;
                return;
            }
        }
    }

    /// @dev "kill" the token and sent its ether value back to owner's wallet
    function killWarrior(uint _id) external tokenExist(_id) returns(uint) {
        require(tokenIndexToOwner[_id] == msg.sender);

        uint valToTransfer = WarriorList[_id].val;
        uint tokenToOwnerIndex = tokenIndexToOwnerIndex[_id];

        _removeFromList(_id, msg.sender);
        tokenIndexToOwner[_id] = address(0);
        ownerToTokenCount[msg.sender] = ownerToTokenCount[msg.sender].sub(1);
        tokenIndexToOwnerIndex[_id] = 0;

        databaseContract.reduceAccountEth(msg.sender,valToTransfer);
        ActiveWarriorListLength = ActiveWarriorListLength.sub(1);
        
        msg.sender.transfer(valToTransfer);
        emit KillWarrior(_id, msg.sender, tokenToOwnerIndex);
        return tokenToOwnerIndex;
    }

    function addFund() public payable  returns(uint) {
        require(msg.value > 0);
        emit NewFund(this.balance);
        return this.balance;
    }

    function getBalance() external returns(uint){
        return this.balance;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        if (_from != address(0)){
            
            uint256 indexFrom = tokenIndexToOwnerIndex[_tokenId];
            uint256[] storage tokenArray = ownerToTokenArray[_from];
            require(tokenArray[indexFrom] == _tokenId);

            if (indexFrom != tokenArray.length - 1){
                uint256 lastTokenId = tokenArray[tokenArray.length - 1];
                tokenArray[indexFrom] = lastTokenId;
                tokenIndexToOwnerIndex[lastTokenId] = indexFrom;
            }
            tokenArray.length.sub(1);
            }
        
        /// Transfer the token to address '_to'
        tokenIndexToOwner[_tokenId] = _to;
        if (ownerToTokenArray[_to].length == 0){
            ownerToTokenCount[_to] = 0;
        }
        ownerToTokenArray[_to].push(_tokenId);
        ownerToTokenCount[_to] = ownerToTokenCount[_to].add(1);
        tokenIndexToOwnerIndex[_tokenId] = (uint256)(ownerToTokenArray[_to].length.sub(1));

        emit Transfer(_from, _to, _tokenId);
    }


    ///@dev The function is to be called by former owner to tranfer the token to the new owner himself.
    function transfer(address _to, uint256 _tokenId) external{
        
        require(msg.sender == tokenIndexToOwner[_tokenId]);
        require(_to != 0x0);
        
        _transfer(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external{
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        require(_to != address(this));
        // Check for approval and valid ownership
        //require(_approvedFor(msg.sender, _tokenId));
        require(ownerOf(_tokenId) == _from);

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }
    
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return WarriorList.length - 1;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return ownerToTokenCount[_owner];
    } 
    

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        _owner = tokenIndexToOwner[_tokenId];
        require(_owner != address(0));
    }
    
    ///@dev The function is to be called by new owner to get the token from the former owner himself.
    function takeOwnership(uint256 _tokenId) public {
        require(tokenApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }

    ///@dev The function is to be called by former owner to assign the token ownership to the new owner.
    function approve(address _to, uint256 _tokenId) external{
        require(msg.sender == tokenIndexToOwner[_tokenId]);
        tokenApprovals[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId);
    }

    function destroyWeaponById(uint256 _tokenId) public {
        require(msg.sender == tokenIndexToOwner[_tokenId]);
        
    }
    
    // ERC721
    function supportsInterface(bytes4 _interfaceId) external view returns(bool) {
    // ERC165 || ERC721 || ERC165^ERC721
        return (_interfaceId == 0x01ffc9a7 || _interfaceId == 0x80ac58cd || _interfaceId == 0x8153916a) && (_interfaceId != 0xffffffff);
    }

}
    
pragma solidity ^0.4.11;

contract DMToken {

    address public owner;//合约创建者
    address public coreSender;
    string public constant name = "Hash Chain Token";
    string public constant symbol = "HASHChain";
    uint256 public constant decimals = 4;
    uint256 public  totalSupply = 15 * 100 * 1000 * 1000 * 10 ** decimals;

    // 提交数据分配代币流水
    struct TransationLogs {
        string ruleHash;
        string contractHash;
        uint256 transactionDateTime;// 交易时间
    }

    mapping(address => TransationLogs[]) public transationLogs;

    event TransationLogsed(address indexed _owner, string ruleHash, string contractHash, uint256 transactionDateTime);

    // 锁定期
    struct BalanceLock {
        uint256 amount;// 锁定金额
        uint256 unlockDate;// 解锁日期
    }

    mapping(address => BalanceLock) public balanceLocks;

    event BalanceLocked(address indexed _owner, uint256 indexed _amount, uint256 _expiry);

    // 可用token
    function availableBalance(address _owner) constant returns (uint256) {
        if (_owner == owner) {
            if (balanceLocks[_owner].unlockDate < now) {
                return balances[_owner];
            } else {
                assert(balances[_owner] >= balanceLocks[_owner].amount);
                return balances[_owner] - balanceLocks[_owner].amount;
            }
        } else {
            return balances[_owner];
        }
    }

    function DMToken()  {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function setSender(address _sender) public {
        if (msg.sender == owner) {
            coreSender = _sender;
        }
    }

    function transfer(address _to, uint256 _value)  returns (bool success) {
        require(availableBalance(msg.sender) >= _value);
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(availableBalance(_from) >= _value);
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping(address => uint256) public balances; // *added public
    mapping(address => mapping(address => uint256)) public allowed; // *added public

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    // 查询解锁日期
    function getReleaseDate(address _owner) constant returns (uint256 releaseDate) {
        BalanceLock balanceLock = balanceLocks[_owner];
        uint256 unlockDate = balanceLock.unlockDate;
        return unlockDate;
    }

    // 查询锁金额
    function getLockAmount(address _owner) constant returns (uint256 _amount) {
        BalanceLock balanceLock = balanceLocks[_owner];
        _amount = balanceLock.amount;
    }

    // 分配代币并设置锁定期
    function transferAndSetLockDate(address _to, uint256 _value, uint256 _period)  returns (bool success) {
        if (_period == 0) {
            transfer(_to, _value);
        } else {
            require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            balanceLocks[_to] = BalanceLock(_value, now + _period);
            BalanceLocked(_to, _value, now + _period);
            return true;
        }
    }

    // 按规则分配代币方法
    function transferForRules(address _to, uint256 _value, string contractHash, string _ruleHash)  returns (bool success) {
        transferFrom(coreSender, _to, _value);
        transationLogs[_to].push(TransationLogs(_ruleHash, contractHash, now));
        TransationLogsed(_to, _ruleHash, contractHash, now);
        return true;
    }

    // 根据地址查义交易记录
    function getTranstions(address _owner) returns (TransationLogs []){
        return transationLogs[_owner];
    }


    modifier onlyOwner {assert(msg.sender == owner);
        _;}

    // 增发代币
    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balances[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }

    // 销毁代币
    function kill(){
        if (msg.sender == owner)
            suicide(owner);
    }
}

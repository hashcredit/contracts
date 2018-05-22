pragma solidity ^0.4.11;


contract Token {

    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) public balances; // *added public
    mapping (address => mapping (address => uint256)) public allowed; // *added public
}


contract DMToken  is StandardToken {

    address public owner;
    string public constant name = "Dumai Test Token";
    string public constant symbol = "DumaiTT";
    uint256 public constant decimals = 4;
    uint256 public constant totalSupply = 15 * 100 * 1000 * 1000 * 10 ** decimals;

    // 2018-01-10 13:44:16
    uint256 becomesTransferable = 1515563056;

    // 六个月
    uint256 sixMonthPeriod = 15552000;
    uint256 sixMonthRate = 20;

    // 三个月
    uint256 threeMonthPeriod = 7776000;
    uint256 threeMonthRate = 15;

    //锁定期限
    modifier verifyLockBalance(uint256 _value) {
        if (msg.sender == owner) {
            uint256 balance = balanceOf(owner);
            uint256 sixAccount = totalSupply * sixMonthRate / 100;
            uint256 threeAccount = totalSupply * threeMonthRate / 100;
            if (now - becomesTransferable < sixMonthPeriod) {
                require(balance - _value >= sixAccount);
            }
            if (now - becomesTransferable < threeMonthPeriod) {
                require(balance - _value >= threeAccount);
            }
        }
        _;
    }

    function DMToken()  {
        owner = msg.sender;
        balances[owner] = totalSupply ;
    }

    function transfer(address _to, uint256 _value) verifyLockBalance(_value) returns (bool success) {
        require(balanceOf(msg.sender) >= _value);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)  verifyLockBalance(_value) returns (bool success) {
        require(balanceOf(_from) >= _value);
        return super.transferFrom(_from, _to, _value);
    }
}

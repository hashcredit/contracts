pragma solidity ^0.4.19;

contract DataSet {

    address public owner;
    string public constant name = "This is a contract to save hash";

    function DataSet()  {
        owner = msg.sender;
    }

    mapping(string => Hashes)  data;

    struct Hashes {
        string hashv;
        uint timestamp;
        uint256 blockhight;
    }

    event AddData(string indexed _hash, uint256 blockhight);

    event TestData(bytes n, bytes h, bool t);


    function addData(string _hash, uint256 _timestamp)  returns (bool status) {
        bytes memory n = bytes(_hash);
        bytes memory h = bytes(data[_hash].hashv);
        require(n.length != h.length);

        TestData(n, h, n.length != h.length);

        data[_hash] = Hashes(_hash, _timestamp, block.number);
        AddData(_hash, block.number);
        return true;
    }

    function getData(string _hash) constant returns (string hashv, uint timestamp, uint256 blockhight) {
        return (data[_hash].hashv, data[_hash].timestamp, data[_hash].blockhight);
    }

}
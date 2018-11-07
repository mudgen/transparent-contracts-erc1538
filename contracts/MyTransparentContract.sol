pragma solidity 0.4.24;
pragma experimental "v0.5.0";

/******************************************************************************\
* Author: Nick Mudge
*
* Implementation of a transparent contract.
* Function signatures are stored in an array so functions can be queried
/******************************************************************************/

import "./UpgradeStorage.sol";

contract MyTransparentContract is UpgradeStorage {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event CommitMessage(string message);
    event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);

    constructor(address _erc1538Delegate) public {
        contractOwner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

        //Adding ERC1538 updateContract function
        bytes memory signature = "updateContract(address,string,string)";
        bytes4 funcId = bytes4(keccak256(signature));
        delegates[funcId] = _erc1538Delegate;
        funcSignatures.push(signature);
        funcSignatureToIndex[signature] = funcSignatures.length;
        emit FunctionUpdate(funcId, address(0), _erc1538Delegate, string(signature));
        emit CommitMessage("Added ERC1538 updateContract function at contract creation");
    }

    function() external payable {
        address delegate = delegates[msg.sig];
        require(delegate != address(0), "Function does not exist.");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, delegate, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {revert(ptr, size)}
            default {return (ptr, size)}
        }
    }
}

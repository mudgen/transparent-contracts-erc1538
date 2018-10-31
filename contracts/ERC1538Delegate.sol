pragma solidity 0.4.24;
pragma experimental "v0.5.0";

/******************************************************************************\
* Author: Nick Mudge
*
* Implementation of ERC1538.
* Function signatures are stored in an array so functions can be queried.
/******************************************************************************/

interface ERC1538 {
    event CommitMessage(string message);
    event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);
    function updateContract(address _delegate, string _functionSignatures, string commitMessage) external;
}

contract ERC1538Delegate is ERC1538 {

    address internal contractOwner;

    // funcId => delegate contract
    mapping(bytes4 => address) internal delegates;
    bytes[] internal funcSignatures;
    // signature => index+1
    mapping(bytes => uint256) internal funcSignatureToIndex;

    function updateContract(address _delegate, string _functionSignatures, string commitMessage) external {
        require(msg.sender == contractOwner, "Must own the contract.");
        bytes memory signatures = bytes(_functionSignatures);
        uint256 signaturesEnd;
        uint256 pos;
        uint256 start;
        assembly {
            pos := add(signatures,32)
            start := pos
            signaturesEnd := add(pos,mload(signatures))
        }
        bytes4 funcId;
        address oldDelegate;
        uint256 num;
        uint256 char;
        uint256 index;
        uint256 lastIndex;
        // parse the _functionSignatures string and handle each function
        for (; pos < signaturesEnd; pos++) {
            assembly {char := byte(0,mload(pos))}
            // 0x29 == )
            if (char == 0x29) {
                pos++;
                num = (pos - start);
                start = pos;
                assembly {
                    mstore(signatures,num)
                }
                funcId = bytes4(keccak256(signatures));
                oldDelegate = delegates[funcId];
                if(_delegate == address(0)) {
                    index = funcSignatureToIndex[signatures];
                    require(index != 0, "Function does not exist.");
                    index--;
                    lastIndex = funcSignatures.length - 1;
                    if (index != lastIndex) {
                        funcSignatures[index] = funcSignatures[lastIndex];
                        funcSignatureToIndex[funcSignatures[lastIndex]] = index + 1;
                    }
                    funcSignatures.length--;
                    delete funcSignatureToIndex[signatures];
                    delete delegates[funcId];
                    emit FunctionUpdate(funcId, oldDelegate, address(0), string(signatures));
                }
                else if (funcSignatureToIndex[signatures] == 0) {
                    require(oldDelegate == address(0), "FuncId clash.");
                    delegates[funcId] = _delegate;
                    funcSignatures.push(signatures);
                    funcSignatureToIndex[signatures] = funcSignatures.length;
                    emit FunctionUpdate(funcId, address(0), _delegate, string(signatures));
                }
                else if (delegates[funcId] != _delegate) {
                    delegates[funcId] = _delegate;
                    emit FunctionUpdate(funcId, oldDelegate, _delegate, string(signatures));

                }
                assembly {signatures := add(signatures,num)}
            }
        }
        emit CommitMessage(commitMessage);
    }

}

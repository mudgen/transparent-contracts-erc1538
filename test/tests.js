const MyTransparentContract = artifacts.require("MyTransparentContract");
const ERC1538Delegate = artifacts.require("ERC1538Delegate");
const ERC1538QueryDelegates = artifacts.require("ERC1538QueryDelegates");

contract('testing', async (accounts) => {
  const bob = accounts[0];
  let tx;
  let functionSignatures;
  let erc1538Delegate, transparentContract, erc1538QueryDelegates;
  let result;

  it("deploy and add contracts", async () => {
    MyTransparentContract.abi = MyTransparentContract.abi.concat(ERC1538Delegate.abi);
    MyTransparentContract.abi = MyTransparentContract.abi.concat(ERC1538QueryDelegates.abi);
    erc1538Delegate = await ERC1538Delegate.new();
    transparentContract = await MyTransparentContract.new(erc1538Delegate.address);
    erc1538QueryDelegates = await ERC1538QueryDelegates.new();

    functionSignatures = "functionByIndex(uint256)functionExists(string)delegateAddress(string)delegateAddresses()delegateFunctionSignatures(address)functionById(bytes4)functionBySignature(string)functionSignatures()totalFunctions()";
    tx = await transparentContract.updateContract(erc1538QueryDelegates.address, functionSignatures, "Adding delegate query functions.");

    //console.log(tx);
    //console.log(transparentContract);
  });

  it("gets delegate query answers", async () => {
    result = await transparentContract.functionByIndex.call(0);
    console.log("functionByIndex:"+result);
    console.log("");

    result = await transparentContract.functionExists.call("delegateAddress(string)");
    console.log("functionExists:"+result);
    console.log("");

    result = await transparentContract.delegateAddress.call("delegateAddress(string)");
    console.log("delegateAddress:"+result);
    console.log("");

    result = await transparentContract.delegateFunctionSignatures.call(erc1538QueryDelegates.address);
    console.log("delegateFunctionSignatures:"+result);
    console.log("");

    result = await transparentContract.functionById.call("0x61455567");
    console.log("signature:"+result[0] + ", delegate address:"+result[1]);
    console.log("");

    result = await transparentContract.functionBySignature.call("delegateFunctionSignatures(address)");
    console.log("funcId:"+result[0] + ", delegate address:"+result[1]);
    console.log("");

    result = await transparentContract.functionSignatures.call();
    console.log("FunctionSignatures:"+result);
    console.log("");

    result = await transparentContract.totalFunctions.call();
    console.log("totalFunctions:"+result);

    assert.equal(result, 10, "Not all functions were added.")

  });

  it("two functions get removed", async () => {
    //functionSignatures = "functionByIndex(uint256)functionById(bytes4)";
    //tx = await transparentContract.updateContract("0x0000000000000000000000000000000000000000", functionSignatures, "Removing two functions.");

    result = await transparentContract.delegateFunctionSignatures.call(erc1538QueryDelegates.address);
    console.log("delegateFunctionSignatures:"+result);
    console.log("");

    //result = await transparentContract.totalFunctions.call();
    //console.log("totalFunctions:"+result);

    //assert.equal(result, 8, "Not all functions were removed.")

  });

});
